#!/usr/bin/env python3
"""Deterministic Kelime Avı corpus QA + risk-based human review evidence."""
from __future__ import annotations

import argparse
import json
import sys
from collections import Counter, defaultdict
from dataclasses import dataclass
from pathlib import Path
from statistics import median
from typing import Any, Iterable, Sequence

try:
    from tools.word_hunt_batch_generator import (
        DIRECTIONS, FactoryError, ProductionCorpusLock, canonical_json,
        load_production_corpus_lock, normalize_runtime_semantics, sha256_text,
        validate_artifact_v2,
    )
except ModuleNotFoundError:
    from word_hunt_batch_generator import (  # type: ignore[no-redef]
        DIRECTIONS, FactoryError, ProductionCorpusLock, canonical_json,
        load_production_corpus_lock, normalize_runtime_semantics, sha256_text,
        validate_artifact_v2,
    )

SCHEMA_VERSION = 1
KIND = "WORD_HUNT_CORPUS_QA_REPORT"
DIR_NAMES = ("NW", "N", "NE", "W", "E", "SW", "S", "SE")
DIR_BY_DELTA = dict(zip(DIRECTIONS, DIR_NAMES, strict=True))
DIRECTION_NAMES = DIR_NAMES
ROLE_ORDER = {"TARGET": 0, "BONUS": 1}
STRUCTURAL_WARNING = 0.85
DIRECTION_WARNING = 0.75
DIRECTION_MIN_PATHS = 4
WORD_REUSE_WARNING = 4
PAIR_REUSE_WARNING = 3
REASONS = {
    "EXACT_GRID_DUPLICATE": "Exact gridHash başka bir level ile aynı.",
    "WORD_REUSE": "Normalized kelime corpus içinde yoğun biçimde tekrar kullanılıyor.",
    "WORD_PAIR_REUSE": "Canonical kelime çifti corpus içinde yoğun biçimde tekrar kullanılıyor.",
    "UNRESOLVABLE_QA_PATH": "QA geometry resolver fiziksel path bulamadı.",
    "HIGH_STRUCTURAL_SIMILARITY": "Occupied-cell Jaccard benzerliği yüksek.",
    "DIRECTION_CONCENTRATION": "Path yönleri tek yönde aşırı yoğunlaşıyor.",
    "OVERLAP_OUTLIER": "Overlap density üst Tukey outlier.",
    "WORD_LENGTH_OUTLIER": "Level kelime-uzunluğu medyanı Tukey outlier.",
    "SEGMENT_START": "10-level batch/segment başlangıç temsilcisi.",
    "SEGMENT_BOUNDARY": "10-level batch/segment sonu temsilcisi.",
    "CONTENT_FRONTIER": "Mevcut staged/candidate frontier temsilcisi.",
    "REPRESENTATIVE_MEDIAN": "Batch lower-median temsilcisi.",
    "HIGHEST_RISK": "Batch içindeki en yüksek risk yoğunluğu temsilcisi.",
    "STRUCTURAL_OUTLIER": "Batch içindeki en yüksek structural-similarity temsilcisi.",
}


@dataclass(frozen=True)
class Level:
    route_id: str
    level_id: str
    index: int
    source: str
    grid: tuple[str, ...]
    targets: tuple[str, ...]
    bonuses: tuple[str, ...]
    star_rules: dict[str, int | None]
    time_limit: int | None
    grid_hash: str
    fingerprint: str


@dataclass(frozen=True)
class PathHit:
    word: str
    cells: tuple[int, ...]
    direction: str
    row: int
    column: int

    @property
    def start_row(self) -> int:
        return self.row

    @property
    def start_column(self) -> int:
        return self.column


ResolvedPath = PathHit


def pretty_json(value: Any) -> str:
    return json.dumps(value, ensure_ascii=False, sort_keys=True, indent=2) + "\n"


def _round(value: float) -> float:
    return round(value, 6)


def _load_json(path: Path) -> dict[str, Any]:
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise FactoryError(f"candidate artifact okunamadı: {path}: {exc}") from exc
    if not isinstance(value, dict):
        raise FactoryError("candidate artifact object olmalı")
    return value


def _production_levels(corpus: ProductionCorpusLock) -> list[Level]:
    out: list[Level] = []
    for route_id in corpus.route_order:
        for raw in corpus.routes[route_id].levels:
            out.append(Level(
                route_id, raw["levelId"], raw["localIndex"], "production",
                tuple(raw["grid"]), tuple(raw["targetWords"]), tuple(raw["bonusWords"]),
                dict(raw["starRules"]), raw["timeLimitSeconds"], raw["gridHash"],
                raw["levelFingerprint"],
            ))
    return out


def _candidate_levels(artifact: dict[str, Any], corpus: ProductionCorpusLock) -> tuple[list[Level], str]:
    validate_artifact_v2(artifact, corpus)
    digest = artifact.get("sourceDigest")
    if not isinstance(digest, str) or len(digest) != 64:
        raise FactoryError("candidate sourceDigest geçersiz")
    out: list[Level] = []
    for route in artifact["routes"]:
        route_id = route["routeId"]
        for raw in route["levels"]:
            grid = tuple(raw["grid"])
            out.append(Level(
                route_id, raw["id"], raw["index"], "candidate", grid,
                tuple(normalize_runtime_semantics(w) for w in raw["targetWords"]),
                tuple(normalize_runtime_semantics(w) for w in raw["bonusWords"]),
                dict(raw["starRules"]), raw.get("timeLimitSeconds"),
                sha256_text("\n".join(grid)), raw["fingerprint"],
            ))
    return out, digest


def resolve_path(grid: Sequence[str], raw_word: str) -> PathHit | None:
    """Row-major starts + compiler DIRECTIONS order = deterministic QA geometry."""
    if not grid:
        return None
    rows = [tuple(normalize_runtime_semantics(row)) for row in grid]
    width = len(rows[0])
    if width == 0 or any(len(row) != width for row in rows):
        return None
    word = tuple(normalize_runtime_semantics(raw_word))
    for sr in range(len(rows)):
        for sc in range(width):
            for delta in DIRECTIONS:
                dr, dc = delta
                cells: list[int] = []
                for offset, expected in enumerate(word):
                    row, col = sr + dr * offset, sc + dc * offset
                    if row < 0 or row >= len(rows) or col < 0 or col >= width or rows[row][col] != expected:
                        break
                    cells.append(row * width + col)
                else:
                    return PathHit("".join(word), tuple(cells), DIR_BY_DELTA[delta], sr, sc)
    return None


resolve_physical_path = resolve_path


def jaccard(left: Iterable[int], right: Iterable[int]) -> float:
    a, b = set(left), set(right)
    union = a | b
    return 1.0 if not union else len(a & b) / len(union)


structural_jaccard = jaccard


def overlap_density(paths: Sequence[PathHit]) -> float:
    uses = sum(len(path.cells) for path in paths)
    if not uses:
        return 0.0
    occupied = {cell for path in paths for cell in path.cells}
    return (uses - len(occupied)) / uses


def direction_distribution(paths: Sequence[PathHit]) -> dict[str, int]:
    counts = Counter(path.direction for path in paths)
    return {name: counts.get(name, 0) for name in DIR_NAMES}


def word_length_summary(words: Sequence[str]) -> dict[str, Any]:
    lengths = sorted(len(normalize_runtime_semantics(word)) for word in words)
    buckets = {"3-4": 0, "5-6": 0, "7-8": 0, "9+": 0}
    for length in lengths:
        buckets["3-4" if length <= 4 else "5-6" if length <= 6 else "7-8" if length <= 8 else "9+"] += 1
    if not lengths:
        return {"count": 0, "min": None, "max": None, "median": None, "buckets": buckets}
    middle = median(lengths)
    return {
        "count": len(lengths), "min": lengths[0], "max": lengths[-1],
        "median": int(middle) if float(middle).is_integer() else middle,
        "buckets": buckets,
    }


def canonical_pair(a_role: str, a_word: str, b_role: str, b_word: str) -> tuple[str, str, str]:
    endpoints = [
        (ROLE_ORDER[a_role], a_role, normalize_runtime_semantics(a_word)),
        (ROLE_ORDER[b_role], b_role, normalize_runtime_semantics(b_word)),
    ]
    endpoints.sort(key=lambda item: (item[0], item[2]))
    return (
        f"{endpoints[0][1]}:{endpoints[0][2]}",
        f"{endpoints[1][1]}:{endpoints[1][2]}",
        f"{endpoints[0][1]}_{endpoints[1][1]}",
    )


canonical_word_pair = canonical_pair


def _tukey(values: Sequence[float]) -> tuple[float, float] | None:
    ordered = sorted(values)
    if len(ordered) < 4:
        return None
    mid = len(ordered) // 2
    lower = ordered[:mid]
    upper = ordered[mid:] if len(ordered) % 2 == 0 else ordered[mid + 1:]
    q1, q3 = float(median(lower)), float(median(upper))
    spread = q3 - q1
    return q1 - 1.5 * spread, q3 + 1.5 * spread


def _words(level: Level) -> list[tuple[str, str]]:
    return [("TARGET", w) for w in level.targets] + [("BONUS", w) for w in level.bonuses]


def _metrics(levels: Sequence[Level]) -> tuple[list[dict[str, Any]], list[dict[str, Any]]]:
    out, hard = [], []
    for level in levels:
        paths: list[PathHit] = []
        for role, word in _words(level):
            hit = resolve_path(level.grid, word)
            if hit is None:
                hard.append({
                    "severity": "HARD", "id": "UNRESOLVABLE_QA_PATH",
                    "routeId": level.route_id, "levelId": level.level_id,
                    "localIndex": level.index, "source": level.source,
                    "evidence": {"role": role, "word": word},
                })
            else:
                paths.append(hit)
        occupied = sorted({cell for path in paths for cell in path.cells})
        words = [word for _, word in _words(level)]
        out.append({
            "routeId": level.route_id, "levelId": level.level_id,
            "localIndex": level.index, "source": level.source,
            "targetCount": len(level.targets), "bonusCount": len(level.bonuses),
            "totalWordCount": len(words), "starRules": level.star_rules,
            "timeLimitSeconds": level.time_limit, "gridHash": level.grid_hash,
            "levelFingerprint": level.fingerprint, "occupiedCells": occupied,
            "occupiedCellCount": len(occupied), "pathCount": len(paths),
            "directionDistribution": direction_distribution(paths),
            "overlapDensity": _round(overlap_density(paths)),
            "wordLengthSummary": word_length_summary(words),
        })
    return out, hard


def _word_frequency(levels: Sequence[Level]) -> list[dict[str, Any]]:
    groups: dict[str, list[dict[str, Any]]] = defaultdict(list)
    for level in levels:
        for role, raw in _words(level):
            word = normalize_runtime_semantics(raw)
            groups[word].append({
                "routeId": level.route_id, "levelId": level.level_id,
                "localIndex": level.index, "role": role, "source": level.source,
            })
    result = []
    for word in sorted(groups):
        origins = sorted(groups[word], key=lambda x: (x["routeId"], x["localIndex"], x["source"], x["levelId"], ROLE_ORDER[x["role"]]))
        result.append({
            "word": word, "wholeGameFrequency": len(origins),
            "routeFrequency": len({o["routeId"] for o in origins}),
            "roles": sorted({o["role"] for o in origins}, key=ROLE_ORDER.__getitem__),
            "origins": origins,
        })
    return result


def _pair_frequency(levels: Sequence[Level]) -> list[dict[str, Any]]:
    groups: dict[tuple[str, str, str], list[dict[str, Any]]] = defaultdict(list)
    for level in levels:
        words = _words(level)
        for i in range(len(words)):
            for j in range(i + 1, len(words)):
                key = canonical_pair(words[i][0], words[i][1], words[j][0], words[j][1])
                groups[key].append({
                    "routeId": level.route_id, "levelId": level.level_id,
                    "localIndex": level.index, "source": level.source,
                })
    return [{
        "first": key[0], "second": key[1], "pairType": key[2],
        "frequency": len(groups[key]),
        "origins": sorted(groups[key], key=lambda x: (x["routeId"], x["localIndex"], x["source"], x["levelId"])),
    } for key in sorted(groups)]


def _grid_duplicates(levels: Sequence[Level]) -> list[dict[str, Any]]:
    groups: dict[str, list[Level]] = defaultdict(list)
    for level in levels:
        groups[level.grid_hash].append(level)
    return [{
        "gridHash": grid_hash,
        "levels": [{"routeId": l.route_id, "levelId": l.level_id, "localIndex": l.index, "source": l.source}
                   for l in sorted(group, key=lambda x: (x.route_id, x.index, x.source, x.level_id))],
    } for grid_hash, group in sorted(groups.items()) if len(group) > 1]


def _structural(metrics: Sequence[dict[str, Any]]) -> list[dict[str, Any]]:
    result = []
    for i, left in enumerate(metrics):
        for right in metrics[i + 1:]:
            result.append({
                "leftRouteId": left["routeId"], "leftLevelId": left["levelId"],
                "leftLocalIndex": left["localIndex"], "leftSource": left["source"],
                "rightRouteId": right["routeId"], "rightLevelId": right["levelId"],
                "rightLocalIndex": right["localIndex"], "rightSource": right["source"],
                "jaccard": _round(jaccard(left["occupiedCells"], right["occupiedCells"])),
            })
    result.sort(key=lambda x: (-x["jaccard"], x["leftRouteId"], x["leftLocalIndex"], x["leftLevelId"], x["rightRouteId"], x["rightLocalIndex"], x["rightLevelId"]))
    return result


def _flag(severity: str, reason: str, metric: dict[str, Any], evidence: Any, counterpart: str | None = None) -> dict[str, Any]:
    value = {
        "severity": severity, "id": reason, "routeId": metric["routeId"],
        "levelId": metric["levelId"], "localIndex": metric["localIndex"],
        "source": metric["source"], "evidence": evidence,
    }
    if counterpart is not None:
        value["counterpartLevelId"] = counterpart
    return value


def _risks(levels: Sequence[Level], metrics: Sequence[dict[str, Any]], initial: Sequence[dict[str, Any]], words: Sequence[dict[str, Any]], pairs: Sequence[dict[str, Any]], grids: Sequence[dict[str, Any]], structural: Sequence[dict[str, Any]], route_order: Sequence[str]) -> list[dict[str, Any]]:
    flags = [dict(item) for item in initial]
    by_key = {(m["routeId"], m["levelId"], m["localIndex"], m["source"]): m for m in metrics}
    by_level = {(m["routeId"], m["levelId"], m["localIndex"]): m for m in metrics}
    for duplicate in grids:
        for member in duplicate["levels"]:
            metric = by_key[(member["routeId"], member["levelId"], member["localIndex"], member["source"])]
            counterparts = [x["levelId"] for x in duplicate["levels"] if x != member]
            flags.append(_flag("HARD", "EXACT_GRID_DUPLICATE", metric, {"gridHash": duplicate["gridHash"], "counterpartLevelIds": counterparts}))
    for entry in words:
        if entry["wholeGameFrequency"] <= 1:
            continue
        per_route = Counter(o["routeId"] for o in entry["origins"])
        for origin in entry["origins"]:
            same_route = per_route[origin["routeId"]] > 1
            if not same_route and entry["wholeGameFrequency"] < WORD_REUSE_WARNING:
                continue
            metric = by_key[(origin["routeId"], origin["levelId"], origin["localIndex"], origin["source"])]
            flags.append(_flag("HARD" if same_route else "WARNING", "WORD_REUSE", metric, {
                "word": entry["word"], "wholeGameFrequency": entry["wholeGameFrequency"],
                "routeFrequency": entry["routeFrequency"], "warningThreshold": WORD_REUSE_WARNING,
            }))
    for entry in pairs:
        if entry["frequency"] < PAIR_REUSE_WARNING:
            continue
        for origin in entry["origins"]:
            metric = by_key[(origin["routeId"], origin["levelId"], origin["localIndex"], origin["source"])]
            flags.append(_flag("WARNING", "WORD_PAIR_REUSE", metric, {
                "first": entry["first"], "second": entry["second"], "pairType": entry["pairType"],
                "frequency": entry["frequency"], "warningThreshold": PAIR_REUSE_WARNING,
            }))
    for pair in structural:
        if pair["jaccard"] < STRUCTURAL_WARNING:
            break
        left = by_key[(pair["leftRouteId"], pair["leftLevelId"], pair["leftLocalIndex"], pair["leftSource"])]
        right = by_key[(pair["rightRouteId"], pair["rightLevelId"], pair["rightLocalIndex"], pair["rightSource"])]
        flags += [
            _flag("WARNING", "HIGH_STRUCTURAL_SIMILARITY", left, {"jaccard": pair["jaccard"]}, right["levelId"]),
            _flag("WARNING", "HIGH_STRUCTURAL_SIMILARITY", right, {"jaccard": pair["jaccard"]}, left["levelId"]),
        ]
    for metric in metrics:
        if metric["pathCount"] >= DIRECTION_MIN_PATHS:
            name, count = max(metric["directionDistribution"].items(), key=lambda x: (x[1], -DIR_NAMES.index(x[0])))
            share = count / metric["pathCount"]
            if share >= DIRECTION_WARNING:
                flags.append(_flag("WARNING", "DIRECTION_CONCENTRATION", metric, {"direction": name, "share": _round(share), "pathCount": metric["pathCount"]}))
    overlap_bounds = _tukey([float(m["overlapDensity"]) for m in metrics])
    if overlap_bounds:
        for metric in metrics:
            if metric["overlapDensity"] > overlap_bounds[1]:
                flags.append(_flag("WARNING", "OVERLAP_OUTLIER", metric, {"overlapDensity": metric["overlapDensity"], "upperTukeyFence": _round(overlap_bounds[1])}))
    medians = [float(m["wordLengthSummary"]["median"]) for m in metrics if m["wordLengthSummary"]["median"] is not None]
    length_bounds = _tukey(medians)
    if length_bounds:
        for metric in metrics:
            value = metric["wordLengthSummary"]["median"]
            if value is not None and (float(value) < length_bounds[0] or float(value) > length_bounds[1]):
                flags.append(_flag("WARNING", "WORD_LENGTH_OUTLIER", metric, {"medianWordLength": value, "lowerTukeyFence": _round(length_bounds[0]), "upperTukeyFence": _round(length_bounds[1])}))
    order = {route_id: i for i, route_id in enumerate(route_order)}
    severity = {"HARD": 0, "WARNING": 1}
    flags.sort(key=lambda f: (severity[f["severity"]], order.get(f["routeId"], 999), f["localIndex"], f["source"], f["levelId"], f["id"], f.get("counterpartLevelId", "")))
    return flags


def _aggregate_direction(metrics: Sequence[dict[str, Any]]) -> dict[str, int]:
    counts = Counter()
    for metric in metrics:
        counts.update(metric["directionDistribution"])
    return {name: counts.get(name, 0) for name in DIR_NAMES}


def _aggregate_overlap(metrics: Sequence[dict[str, Any]]) -> dict[str, Any]:
    values = [float(m["overlapDensity"]) for m in metrics]
    return {"min": None, "max": None, "median": None, "average": None} if not values else {
        "min": _round(min(values)), "max": _round(max(values)),
        "median": _round(float(median(values))), "average": _round(sum(values) / len(values)),
    }


def _review_queue(metrics: Sequence[dict[str, Any]], flags: Sequence[dict[str, Any]], structural: Sequence[dict[str, Any]], route_order: Sequence[str], planned: dict[str, int]) -> list[dict[str, Any]]:
    def key(m: dict[str, Any]) -> tuple[str, str, int, str]:
        return m["routeId"], m["levelId"], m["localIndex"], m["source"]
    by_key = {key(m): m for m in metrics}
    reasons: dict[tuple[str, str, int, str], dict[str, dict[str, Any]]] = defaultdict(dict)
    risk_by_key: dict[tuple[str, str, int, str], list[dict[str, Any]]] = defaultdict(list)
    def add(k: tuple[str, str, int, str], reason: str, evidence: Any = None) -> None:
        reasons[k][reason] = {"id": reason, "description": REASONS[reason], **({"evidence": evidence} if evidence is not None else {})}
    for flag in flags:
        k = flag["routeId"], flag["levelId"], flag["localIndex"], flag["source"]
        risk_by_key[k].append(flag); add(k, flag["id"], flag.get("evidence"))
    by_route: dict[str, list[dict[str, Any]]] = defaultdict(list)
    for metric in metrics:
        by_route[metric["routeId"]].append(metric)
    for route_id in route_order:
        route_levels = sorted(by_route.get(route_id, []), key=lambda m: m["localIndex"])
        frontier = max((m["localIndex"] for m in route_levels), default=0)
        batches: dict[int, list[dict[str, Any]]] = defaultdict(list)
        for metric in route_levels:
            batches[(metric["localIndex"] - 1) // 10 + 1].append(metric)
        for batch_id, batch in sorted(batches.items()):
            batch.sort(key=lambda m: m["localIndex"])
            start, end, mid = batch[0], batch[-1], batch[(len(batch) - 1) // 2]
            add(key(start), "SEGMENT_START"); add(key(mid), "REPRESENTATIVE_MEDIAN")
            if end["localIndex"] % 10 == 0:
                add(key(end), "SEGMENT_BOUNDARY")
            if end["localIndex"] == frontier and frontier < planned.get(route_id, frontier):
                add(key(end), "CONTENT_FRONTIER")
            risky = [m for m in batch if risk_by_key.get(key(m))]
            if risky:
                def score(m: dict[str, Any]) -> tuple[int, int, int]:
                    fs = risk_by_key[key(m)]
                    return sum(f["severity"] == "HARD" for f in fs), sum(f["severity"] == "WARNING" for f in fs), -m["localIndex"]
                chosen = max(risky, key=score)
                add(key(chosen), "HIGHEST_RISK", {"riskFlagCount": len(risk_by_key[key(chosen)])})
            candidates = [p for p in structural if p["leftRouteId"] == route_id and p["rightRouteId"] == route_id and (p["leftLocalIndex"] - 1) // 10 + 1 == batch_id and (p["rightLocalIndex"] - 1) // 10 + 1 == batch_id]
            if candidates:
                top = candidates[0]
                left = (top["leftRouteId"], top["leftLevelId"], top["leftLocalIndex"], top["leftSource"])
                right = (top["rightRouteId"], top["rightLevelId"], top["rightLocalIndex"], top["rightSource"])
                chosen, other = (left, right) if left[2] <= right[2] else (right, left)
                add(chosen, "STRUCTURAL_OUTLIER", {"counterpartLevelId": other[1], "jaccard": top["jaccard"]})
    order = {route_id: i for i, route_id in enumerate(route_order)}
    queue = []
    for k in sorted(reasons, key=lambda x: (order.get(x[0], 999), x[2], x[3], x[1])):
        metric = by_key[k]
        queue.append({
            "routeId": metric["routeId"], "levelId": metric["levelId"],
            "localIndex": metric["localIndex"], "source": metric["source"],
            "globalDisplayNumber": order.get(metric["routeId"], 0) * 100 + metric["localIndex"],
            "reviewReasons": [reasons[k][name] for name in sorted(reasons[k])],
            "keyMetrics": {
                "targetCount": metric["targetCount"], "bonusCount": metric["bonusCount"],
                "overlapDensity": metric["overlapDensity"], "occupiedCellCount": metric["occupiedCellCount"],
                "wordLengthMedian": metric["wordLengthSummary"]["median"],
            },
        })
    return queue


select_review_queue = _review_queue


def build_report(corpus: ProductionCorpusLock, candidate: dict[str, Any] | None = None) -> dict[str, Any]:
    production = _production_levels(corpus)
    candidates, candidate_digest = ([], None) if candidate is None else _candidate_levels(candidate, corpus)
    levels = production + candidates
    metrics, initial = _metrics(levels)
    words, pairs, grids, structural = _word_frequency(levels), _pair_frequency(levels), _grid_duplicates(levels), _structural(metrics)
    flags = _risks(levels, metrics, initial, words, pairs, grids, structural, corpus.route_order)
    planned = {route_id: corpus.routes[route_id].planned_level_count for route_id in corpus.route_order}
    review = _review_queue(metrics, flags, structural, corpus.route_order, planned)
    by_route: dict[str, list[dict[str, Any]]] = defaultdict(list)
    for metric in metrics:
        by_route[metric["routeId"]].append(metric)
    level_map = {(l.route_id, l.level_id, l.index, l.source): l for l in levels}
    routes = []
    for route_id in corpus.route_order:
        route_metrics = sorted(by_route.get(route_id, []), key=lambda m: m["localIndex"])
        batches: dict[int, list[dict[str, Any]]] = defaultdict(list)
        for metric in route_metrics:
            batches[(metric["localIndex"] - 1) // 10 + 1].append(metric)
        segments = []
        for segment_id, segment_metrics in sorted(batches.items()):
            segment_metrics.sort(key=lambda m: m["localIndex"])
            segment_words = [word for m in segment_metrics for _, word in _words(level_map[(m["routeId"], m["levelId"], m["localIndex"], m["source"])])]
            segments.append({
                "segmentIndex": segment_id, "startLocalIndex": segment_metrics[0]["localIndex"],
                "endLocalIndex": segment_metrics[-1]["localIndex"], "levelCount": len(segment_metrics),
                "directionDistribution": _aggregate_direction(segment_metrics),
                "wordLengthSummary": word_length_summary(segment_words),
                "overlapDensitySummary": _aggregate_overlap(segment_metrics),
            })
        route_words = [word for m in route_metrics for _, word in _words(level_map[(m["routeId"], m["levelId"], m["localIndex"], m["source"])])]
        routes.append({
            "routeId": route_id,
            "productionAvailableLevelCount": corpus.routes[route_id].available_level_count,
            "combinedLevelCount": len(route_metrics), "plannedLevelCount": planned[route_id],
            "directionDistribution": _aggregate_direction(route_metrics),
            "wordLengthSummary": word_length_summary(route_words),
            "overlapDensitySummary": _aggregate_overlap(route_metrics), "segments": segments,
            "levels": [{k: m[k] for k in (
                "routeId", "levelId", "localIndex", "source", "targetCount", "bonusCount",
                "totalWordCount", "starRules", "timeLimitSeconds", "gridHash", "levelFingerprint",
                "occupiedCellCount", "directionDistribution", "overlapDensity", "wordLengthSummary",
            )} for m in route_metrics],
        })
    all_words = [word for level in levels for _, word in _words(level)]
    return {
        "schemaVersion": SCHEMA_VERSION, "kind": KIND,
        "productionCorpusDigest": corpus.source_digest, "candidateDigest": candidate_digest,
        "routeCount": len(corpus.route_order), "levelCount": len(levels),
        "productionLevelCount": len(production), "candidateLevelCount": len(candidates),
        "summary": {
            "hardRiskCount": sum(f["severity"] == "HARD" for f in flags),
            "warningCount": sum(f["severity"] == "WARNING" for f in flags),
            "reviewQueueCount": len(review), "exactGridDuplicateGroupCount": len(grids),
            "wordReuseCount": sum(w["wholeGameFrequency"] > 1 for w in words),
            "wordPairReuseCount": sum(p["frequency"] > 1 for p in pairs),
            "structuralSimilarityWarningPairCount": sum(p["jaccard"] >= STRUCTURAL_WARNING for p in structural),
        },
        "directionDistribution": _aggregate_direction(metrics),
        "wordLengthSummary": word_length_summary(all_words),
        "overlapDensitySummary": _aggregate_overlap(metrics),
        "wordFrequencies": words, "wordPairFrequencies": pairs,
        "exactGridDuplicates": grids, "topStructuralSimilarities": structural[:25],
        "riskFlags": flags, "reviewQueue": review, "routes": routes,
    }


def render_markdown(report: dict[str, Any]) -> str:
    s = report["summary"]
    lines = [
        "# Word Hunt Corpus QA Report", "", "## Authority", "",
        f"- Production corpus digest: `{report['productionCorpusDigest']}`",
        f"- Route count: {report['routeCount']}", f"- Level count: {report['levelCount']}",
        f"- Production levels: {report['productionLevelCount']}", f"- Candidate levels: {report['candidateLevelCount']}",
        f"- Candidate digest: `{report['candidateDigest']}`" if report["candidateDigest"] else "- Candidate digest: none",
        "", "## Summary", "", f"- Hard risks: {s['hardRiskCount']}", f"- Warnings: {s['warningCount']}",
        f"- Review queue: {s['reviewQueueCount']}", f"- Exact-grid duplicate groups: {s['exactGridDuplicateGroupCount']}",
        f"- Reused normalized words: {s['wordReuseCount']}", f"- Reused canonical word pairs: {s['wordPairReuseCount']}",
        f"- High structural-similarity pairs: {s['structuralSimilarityWarningPairCount']}",
        "", "## Corpus metrics", "", f"- Direction usage: `{canonical_json(report['directionDistribution'])}`",
        f"- Word lengths: `{canonical_json(report['wordLengthSummary'])}`",
        f"- Overlap density: `{canonical_json(report['overlapDensitySummary'])}`", "", "## Human review queue", "",
    ]
    by_route: dict[str, list[dict[str, Any]]] = defaultdict(list)
    for item in report["reviewQueue"]:
        by_route[item["routeId"]].append(item)
    for route in report["routes"]:
        route_id, current = route["routeId"], None
        lines += [f"### {route_id}", ""]
        for item in by_route.get(route_id, []):
            segment = (item["localIndex"] - 1) // 10 + 1
            if segment != current:
                current = segment; lines += [f"#### Batch / Segment {segment}", ""]
            reasons = ", ".join(r["id"] for r in item["reviewReasons"])
            m = item["keyMetrics"]
            lines += [
                f"**{item['levelId']}** — local L{item['localIndex']} — display #{item['globalDisplayNumber']} — {item['source']}", "",
                f"- Review reasons: {reasons}",
                f"- Key metrics: target={m['targetCount']}, bonus={m['bonusCount']}, overlap={m['overlapDensity']}, occupied={m['occupiedCellCount']}, word-length median={m['wordLengthMedian']}",
                "- [ ] ACCEPT  [ ] REGENERATE  [ ] EDIT WORD SET", "",
            ]
            for reason in item["reviewReasons"]:
                if "evidence" in reason:
                    lines.append(f"  - `{reason['id']}` evidence: `{canonical_json(reason['evidence'])}`")
            if any("evidence" in r for r in item["reviewReasons"]):
                lines.append("")
    return "\n".join(lines).rstrip() + "\n"


def parse_args(argv: Sequence[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--production-corpus-lock", type=Path, required=True)
    parser.add_argument("--candidate", type=Path)
    parser.add_argument("--json-report", type=Path)
    parser.add_argument("--markdown-report", type=Path)
    parser.add_argument("--fail-on-hard-risk", action="store_true")
    return parser.parse_args(argv)


def main(argv: Sequence[str] | None = None) -> int:
    args = parse_args(sys.argv[1:] if argv is None else argv)
    try:
        corpus = load_production_corpus_lock(args.production_corpus_lock)
        candidate = _load_json(args.candidate) if args.candidate else None
        report = build_report(corpus, candidate)
        if args.json_report:
            args.json_report.write_text(pretty_json(report), encoding="utf-8")
        if args.markdown_report:
            args.markdown_report.write_text(render_markdown(report), encoding="utf-8")
        print(f"Word Hunt corpus QA: routes={report['routeCount']} levels={report['levelCount']} hard={report['summary']['hardRiskCount']} warnings={report['summary']['warningCount']} review={report['summary']['reviewQueueCount']}")
        return 2 if args.fail_on_hard_risk and report["summary"]["hardRiskCount"] else 0
    except FactoryError as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
