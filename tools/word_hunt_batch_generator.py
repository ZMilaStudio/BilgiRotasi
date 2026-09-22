#!/usr/bin/env python3
"""Kelime Avı 2.0 KA-02 deterministic candidate content compiler.

Development/content tooling only. It never runs inside Flutter runtime and its
output is a NON-PRODUCTION candidate artifact until separately owner-approved
and integrated by a later wave.
"""

from __future__ import annotations

import argparse
import copy
import hashlib
import json
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Iterable, Sequence

COMPILER_VERSION = "ka02-v1"
V2_COMPILER_VERSION = "ka02-v2"
INPUT_SCHEMA_VERSION = 2
ARTIFACT_SCHEMA_VERSION = 1
V2_ARTIFACT_SCHEMA_VERSION = 2
PRODUCTION_CORPUS_SCHEMA_VERSION = 1
PRODUCTION_CORPUS_KIND = "WORD_HUNT_PRODUCTION_CORPUS_LOCK"
GRID_SIZE = 8
ALPHABET = "ABCÇDEFGĞHIİJKLMNOÖPRSŞTUÜVYZ"
PRODUCTION_GRID_ALPHABET = ALPHABET + "Â"
WORD_RE = re.compile(r"^[ABCÇDEFGĞHIİJKLMNOÖPRSŞTUÜVYZ]{3,8}$")
DIRECTIONS = (
    (-1, -1), (-1, 0), (-1, 1),
    (0, -1),           (0, 1),
    (1, -1),  (1, 0),  (1, 1),
)
LEVEL_TYPES = {"normal", "challenge", "bonus", "routeFinal"}
STAR_RULE_KEYS = (
    "twoStarMaxMistakes",
    "threeStarMaxMistakes",
    "twoStarMaxSeconds",
    "threeStarMaxSeconds",
)
MAX_GENERATION_ATTEMPTS = 80
MAX_FILL_ATTEMPTS = 600
MAX_BACKTRACK_NODES = 50_000
MAX_SEED = (1 << 63) - 1
DEFAULT_SOURCE_LOCK = Path(__file__).with_name("word_hunt_segment1_source_lock.json")
DEFAULT_PRODUCTION_CORPUS_LOCK = Path(__file__).with_name(
    "word_hunt_production_corpus.lock.json"
)

GENERATION_CONTRACT = {
    "alphabet": ALPHABET,
    "directions": [list(direction) for direction in DIRECTIONS],
    "gridSize": GRID_SIZE,
    "maxBacktrackNodes": MAX_BACKTRACK_NODES,
    "maxFillAttempts": MAX_FILL_ATTEMPTS,
    "maxGenerationAttempts": MAX_GENERATION_ATTEMPTS,
    "pathRule": "straightEightDirections",
}


class FactoryError(RuntimeError):
    pass


class _SearchBudgetExceeded(FactoryError):
    pass


@dataclass(frozen=True)
class Placement:
    word: str
    row: int
    col: int
    dr: int
    dc: int


@dataclass(frozen=True)
class SourceLockRoute:
    route_id: str
    content_fingerprint: str
    reserved_words: tuple[str, ...]
    origins: dict[str, dict[str, Any]]


@dataclass(frozen=True)
class SourceLock:
    raw: dict[str, Any]
    lock_version: str
    lock_digest: str
    routes: dict[str, SourceLockRoute]


@dataclass(frozen=True)
class ProductionCorpusRoute:
    route_id: str
    available_level_count: int
    planned_level_count: int
    reserved_words: tuple[str, ...]
    origins: dict[str, dict[str, Any]]
    levels: tuple[dict[str, Any], ...]


@dataclass(frozen=True)
class ProductionCorpusLock:
    raw: dict[str, Any]
    source_digest: str
    route_order: tuple[str, ...]
    routes: dict[str, ProductionCorpusRoute]


class StableRng:
    """Small SHA-256 based deterministic RNG independent of Python hash/random."""

    def __init__(self, seed_material: str) -> None:
        self._seed = seed_material.encode("utf-8")
        self._counter = 0

    def _u64(self) -> int:
        material = self._seed + b"\0" + self._counter.to_bytes(8, "big")
        self._counter += 1
        return int.from_bytes(hashlib.sha256(material).digest()[:8], "big")

    def randbelow(self, upper: int) -> int:
        if upper <= 0:
            raise ValueError("upper must be positive")
        return self._u64() % upper

    def choice(self, values: Sequence[str]) -> str:
        return values[self.randbelow(len(values))]

    def shuffle(self, values: list[Any]) -> None:
        for index in range(len(values) - 1, 0, -1):
            other = self.randbelow(index + 1)
            values[index], values[other] = values[other], values[index]


def canonical_json(value: Any) -> str:
    return json.dumps(
        value,
        ensure_ascii=False,
        sort_keys=True,
        separators=(",", ":"),
    )


def pretty_json(value: Any) -> str:
    return json.dumps(value, ensure_ascii=False, indent=2) + "\n"


def sha256_text(value: str) -> str:
    return hashlib.sha256(value.encode("utf-8")).hexdigest()


def source_lock_payload_digest(raw: dict[str, Any]) -> str:
    payload = copy.deepcopy(raw)
    payload.pop("lockDigest", None)
    return sha256_text(canonical_json(payload))


def _require_int(value: Any, label: str, *, minimum: int | None = None) -> int:
    if isinstance(value, bool) or not isinstance(value, int):
        raise FactoryError(f"{label}: integer gerekli")
    if minimum is not None and value < minimum:
        raise FactoryError(f"{label}: {minimum} veya daha büyük olmalı")
    if value > MAX_SEED and "seed" in label.lower():
        raise FactoryError(f"{label}: {MAX_SEED} değerini aşamaz")
    return value


def normalize_runtime_semantics(value: Any) -> str:
    if not isinstance(value, str):
        raise FactoryError(f"kelime string olmalı: {value!r}")
    return value.strip().replace("i", "İ").replace("ı", "I").upper()


def normalize_locked_word(value: Any) -> str:
    normalized = normalize_runtime_semantics(value)
    if not normalized:
        raise FactoryError("Segment1 locked word trim sonrası boş olamaz")
    if normalized != value:
        raise FactoryError(
            f"Segment1 locked word canonical runtime-normalized olmalı: {value!r} -> {normalized!r}"
        )
    return normalized


def normalize_word(value: Any) -> str:
    normalized = normalize_runtime_semantics(value)
    if not normalized:
        raise FactoryError("kelime trim sonrası boş olamaz")
    if not WORD_RE.fullmatch(normalized):
        raise FactoryError(
            f"geçersiz kelime {value!r} -> {normalized!r}; "
            "yalnız ABCÇDEFGĞHIİJKLMNOÖPRSŞTUÜVYZ ve 3..8 rune kabul edilir; "
            "space/hyphen/punctuation dönüştürülmez"
        )
    return normalized


def validate_source_lock(raw: dict[str, Any]) -> SourceLock:
    if not isinstance(raw, dict):
        raise FactoryError("Segment1 source lock object olmalı")
    if raw.get("schemaVersion") != 1:
        raise FactoryError(f"Segment1 source lock schema unsupported: {raw.get('schemaVersion')!r}")
    lock_version = raw.get("lockVersion")
    if not isinstance(lock_version, str) or not lock_version.strip():
        raise FactoryError("Segment1 source lock lockVersion eksik")
    stored_digest = raw.get("lockDigest")
    if not isinstance(stored_digest, str) or not re.fullmatch(r"[0-9a-f]{64}", stored_digest):
        raise FactoryError("Segment1 source lock lockDigest geçersiz/eksik")
    actual_digest = source_lock_payload_digest(raw)
    if stored_digest != actual_digest:
        raise FactoryError(
            "Segment1 source lock digest mismatch: "
            f"stored={stored_digest} actual={actual_digest}"
        )

    routes_raw = raw.get("routes")
    if not isinstance(routes_raw, list) or not routes_raw:
        raise FactoryError("Segment1 source lock routes boş/eksik")

    routes: dict[str, SourceLockRoute] = {}
    seen_order: list[str] = []
    for route in routes_raw:
        if not isinstance(route, dict):
            raise FactoryError("Segment1 source lock route object olmalı")
        route_id = route.get("routeId")
        if not isinstance(route_id, str) or not route_id or route_id.strip() != route_id:
            raise FactoryError(f"Segment1 routeId geçersiz: {route_id!r}")
        if route_id in routes:
            raise FactoryError(f"Segment1 duplicate routeId: {route_id}")
        fingerprint = route.get("contentFingerprint")
        if not isinstance(fingerprint, str) or not re.fullmatch(r"[0-9a-f]{8}", fingerprint):
            raise FactoryError(f"{route_id}: contentFingerprint geçersiz")
        words_raw = route.get("reservedWords")
        if not isinstance(words_raw, list):
            raise FactoryError(f"{route_id}: reservedWords list olmalı")
        words = tuple(normalize_locked_word(word) for word in words_raw)
        if tuple(sorted(words)) != words:
            raise FactoryError(f"{route_id}: reservedWords canonical sorted olmalı")
        if len(set(words)) != len(words):
            raise FactoryError(f"{route_id}: reservedWords duplicate içeriyor")
        count = _require_int(route.get("reservedWordCount"), f"{route_id}.reservedWordCount", minimum=0)
        if count != len(words):
            raise FactoryError(
                f"{route_id}: reservedWordCount mismatch {count} != {len(words)}"
            )
        origins_raw = route.get("wordOrigins")
        if not isinstance(origins_raw, list) or len(origins_raw) != len(words):
            raise FactoryError(f"{route_id}: wordOrigins reservedWords ile birebir olmalı")
        origins: dict[str, dict[str, Any]] = {}
        for origin in origins_raw:
            if not isinstance(origin, dict):
                raise FactoryError(f"{route_id}: wordOrigin object olmalı")
            word = normalize_locked_word(origin.get("word"))
            if word in origins:
                raise FactoryError(f"{route_id}: duplicate wordOrigin {word}")
            if word not in words:
                raise FactoryError(f"{route_id}: wordOrigin reserved dışı {word}")
            level_id = origin.get("levelId")
            index = origin.get("index")
            role = origin.get("role")
            if not isinstance(level_id, str) or not level_id:
                raise FactoryError(f"{route_id}:{word}: origin levelId geçersiz")
            _require_int(index, f"{route_id}:{word}.origin.index", minimum=1)
            if role not in {"TARGET", "BONUS"}:
                raise FactoryError(f"{route_id}:{word}: origin role geçersiz {role!r}")
            origins[word] = {
                "word": word,
                "levelId": level_id,
                "index": index,
                "role": role,
            }
        if set(origins) != set(words):
            raise FactoryError(f"{route_id}: wordOrigins set mismatch")
        routes[route_id] = SourceLockRoute(
            route_id=route_id,
            content_fingerprint=fingerprint,
            reserved_words=words,
            origins=origins,
        )
        seen_order.append(route_id)

    if len(seen_order) != len(set(seen_order)):
        raise FactoryError("Segment1 route order duplicate içeriyor")

    return SourceLock(
        raw=raw,
        lock_version=lock_version,
        lock_digest=stored_digest,
        routes=routes,
    )


def load_source_lock(path: Path) -> SourceLock:
    try:
        raw = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise FactoryError(f"Segment1 source lock okunamadı: {path}: {exc}") from exc
    return validate_source_lock(raw)



def production_corpus_payload_digest(raw: dict[str, Any]) -> str:
    payload = copy.deepcopy(raw)
    payload.pop("sourceDigest", None)
    return sha256_text(canonical_json(payload))


def _production_level_material(level: dict[str, Any]) -> dict[str, Any]:
    return {
        "localIndex": level["localIndex"],
        "levelId": level["levelId"],
        "type": level["type"],
        "grid": level["grid"],
        "targetWords": level["targetWords"],
        "bonusWords": level["bonusWords"],
        "starRules": level["starRules"],
        "timeLimitSeconds": level["timeLimitSeconds"],
        "gridHash": level["gridHash"],
    }


def production_level_fingerprint(level: dict[str, Any]) -> str:
    return sha256_text(canonical_json(_production_level_material(level)))


def validate_production_corpus_lock(raw: dict[str, Any]) -> ProductionCorpusLock:
    if not isinstance(raw, dict):
        raise FactoryError("production corpus lock object olmalı")
    if raw.get("schemaVersion") != PRODUCTION_CORPUS_SCHEMA_VERSION:
        raise FactoryError("production corpus schema mismatch")
    if raw.get("kind") != PRODUCTION_CORPUS_KIND:
        raise FactoryError("production corpus kind mismatch")
    if raw.get("generatedBy") != "tools/word_hunt_corpus_support.dart":
        raise FactoryError("production corpus generatedBy mismatch")

    source_digest = raw.get("sourceDigest")
    if not isinstance(source_digest, str) or not re.fullmatch(
        r"[0-9a-f]{64}", source_digest
    ):
        raise FactoryError("production corpus sourceDigest geçersiz/eksik")
    actual_digest = production_corpus_payload_digest(raw)
    if source_digest != actual_digest:
        raise FactoryError(
            "production corpus sourceDigest mismatch: "
            f"stored={source_digest} actual={actual_digest}"
        )

    route_order_raw = raw.get("routeOrder")
    routes_raw = raw.get("routes")
    if not isinstance(route_order_raw, list) or not route_order_raw:
        raise FactoryError("production corpus routeOrder boş/eksik")
    if not isinstance(routes_raw, list) or not routes_raw:
        raise FactoryError("production corpus routes boş/eksik")
    route_order = tuple(route_order_raw)
    if any(
        not isinstance(route_id, str) or not route_id or route_id.strip() != route_id
        for route_id in route_order
    ):
        raise FactoryError("production corpus routeOrder geçersiz")
    if len(set(route_order)) != len(route_order):
        raise FactoryError("production corpus routeOrder duplicate içeriyor")
    if [route.get("routeId") for route in routes_raw] != list(route_order):
        raise FactoryError("production corpus routes routeOrder ile eşleşmiyor")

    routes: dict[str, ProductionCorpusRoute] = {}
    for route in routes_raw:
        if not isinstance(route, dict):
            raise FactoryError("production corpus route object olmalı")
        route_id = route.get("routeId")
        if route_id in routes:
            raise FactoryError(f"production corpus duplicate routeId {route_id}")

        levels_raw = route.get("levels")
        if not isinstance(levels_raw, list) or not levels_raw:
            raise FactoryError(f"{route_id}: production levels boş/eksik")
        available = _require_int(
            route.get("availableLevelCount"),
            f"{route_id}.availableLevelCount",
            minimum=1,
        )
        planned = _require_int(
            route.get("plannedLevelCount"),
            f"{route_id}.plannedLevelCount",
            minimum=1,
        )
        if available != len(levels_raw):
            raise FactoryError(
                f"{route_id}: availableLevelCount mismatch {available} != {len(levels_raw)}"
            )
        if planned < available or planned > 100:
            raise FactoryError(
                f"{route_id}: plannedLevelCount {planned} available={available} dışında"
            )

        seen_level_ids: set[str] = set()
        projected_words: dict[str, dict[str, Any]] = {}
        validated_levels: list[dict[str, Any]] = []
        for offset, raw_level in enumerate(levels_raw):
            if not isinstance(raw_level, dict):
                raise FactoryError(f"{route_id}: production level object olmalı")
            level = copy.deepcopy(raw_level)
            index = _require_int(
                level.get("localIndex"),
                f"{route_id}.level.localIndex",
                minimum=1,
            )
            if index != offset + 1:
                raise FactoryError(
                    f"{route_id}: production localIndex 1..N sıralı olmalı"
                )
            level_id = level.get("levelId")
            if not isinstance(level_id, str) or not level_id:
                raise FactoryError(f"{route_id}: production levelId geçersiz")
            if level_id in seen_level_ids:
                raise FactoryError(f"{route_id}: duplicate production levelId {level_id}")
            seen_level_ids.add(level_id)
            if level.get("type") not in LEVEL_TYPES:
                raise FactoryError(f"{route_id}/{level_id}: production type geçersiz")

            grid = level.get("grid")
            if not isinstance(grid, list) or len(grid) != GRID_SIZE:
                raise FactoryError(f"{route_id}/{level_id}: production grid 8 row olmalı")
            if any(not isinstance(row, str) or len(row) != GRID_SIZE for row in grid):
                raise FactoryError(f"{route_id}/{level_id}: production grid 8x8 olmalı")
            unsupported = sorted({
                char
                for row in grid
                for char in row
                if char not in PRODUCTION_GRID_ALPHABET
            })
            if unsupported:
                raise FactoryError(
                    f"{route_id}/{level_id}: production grid unsupported alphabet "
                    f"chars={unsupported}"
                )

            targets_raw = level.get("targetWords")
            bonus_raw = level.get("bonusWords")
            if not isinstance(targets_raw, list) or not targets_raw:
                raise FactoryError(f"{route_id}/{level_id}: production targets eksik")
            if not isinstance(bonus_raw, list):
                raise FactoryError(f"{route_id}/{level_id}: production bonus list olmalı")
            targets = [normalize_locked_word(word) for word in targets_raw]
            bonus = [normalize_locked_word(word) for word in bonus_raw]
            level["targetWords"] = targets
            level["bonusWords"] = bonus
            level["starRules"] = _validate_star_rules(
                level.get("starRules"),
                f"{route_id}/{level_id}",
            )
            time_limit = level.get("timeLimitSeconds")
            if time_limit is not None:
                _require_int(
                    time_limit,
                    f"{route_id}/{level_id}.timeLimitSeconds",
                    minimum=1,
                )

            grid_hash = level.get("gridHash")
            if grid_hash != sha256_text("\n".join(grid)):
                raise FactoryError(f"{route_id}/{level_id}: gridHash mismatch")
            fingerprint = level.get("levelFingerprint")
            if not isinstance(fingerprint, str) or not re.fullmatch(
                r"[0-9a-f]{64}", fingerprint
            ):
                raise FactoryError(f"{route_id}/{level_id}: levelFingerprint geçersiz")
            if fingerprint != production_level_fingerprint(level):
                raise FactoryError(f"{route_id}/{level_id}: levelFingerprint mismatch")

            for role, words in (("TARGET", targets), ("BONUS", bonus)):
                for word in words:
                    if word in projected_words:
                        previous = projected_words[word]
                        raise FactoryError(
                            f"route={route_id} word={word} duplicate production "
                            f"existing={previous['levelId']} "
                            f"new={level_id}"
                        )
                    projected_words[word] = {
                        "word": word,
                        "levelId": level_id,
                        "localIndex": index,
                        "role": role,
                    }
            validated_levels.append(level)

        reserved_raw = route.get("reservedWords")
        if not isinstance(reserved_raw, list):
            raise FactoryError(f"{route_id}: reservedWords list olmalı")
        reserved_words = tuple(normalize_locked_word(word) for word in reserved_raw)
        if tuple(sorted(reserved_words)) != reserved_words:
            raise FactoryError(f"{route_id}: reservedWords canonical sorted olmalı")
        if len(set(reserved_words)) != len(reserved_words):
            raise FactoryError(f"{route_id}: reservedWords duplicate içeriyor")
        if set(reserved_words) != set(projected_words):
            raise FactoryError(f"{route_id}: reservedWords production levels ile uyuşmuyor")
        reserved_count = _require_int(
            route.get("reservedWordCount"),
            f"{route_id}.reservedWordCount",
            minimum=0,
        )
        if reserved_count != len(reserved_words):
            raise FactoryError(f"{route_id}: reservedWordCount mismatch")

        origins_raw = route.get("wordOrigins")
        if not isinstance(origins_raw, list) or len(origins_raw) != len(reserved_words):
            raise FactoryError(f"{route_id}: wordOrigins reservedWords ile birebir olmalı")
        origins: dict[str, dict[str, Any]] = {}
        for origin in origins_raw:
            if not isinstance(origin, dict):
                raise FactoryError(f"{route_id}: wordOrigin object olmalı")
            word = normalize_locked_word(origin.get("word"))
            expected = projected_words.get(word)
            if expected is None or origin != expected:
                raise FactoryError(f"{route_id}:{word}: wordOrigin mismatch")
            origins[word] = copy.deepcopy(origin)
        if tuple(origin.get("word") for origin in origins_raw) != reserved_words:
            raise FactoryError(f"{route_id}: wordOrigins canonical word order olmalı")

        routes[route_id] = ProductionCorpusRoute(
            route_id=route_id,
            available_level_count=available,
            planned_level_count=planned,
            reserved_words=reserved_words,
            origins=origins,
            levels=tuple(validated_levels),
        )

    return ProductionCorpusLock(
        raw=copy.deepcopy(raw),
        source_digest=source_digest,
        route_order=route_order,
        routes=routes,
    )


def load_production_corpus_lock(path: Path) -> ProductionCorpusLock:
    try:
        raw = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise FactoryError(
            f"production corpus lock okunamadı: {path}: {exc}"
        ) from exc
    return validate_production_corpus_lock(raw)

def _validate_star_rules(value: Any, label: str) -> dict[str, int | None]:
    if not isinstance(value, dict):
        raise FactoryError(f"{label}: starRules object olmalı")
    unknown = sorted(set(value) - set(STAR_RULE_KEYS))
    if unknown:
        raise FactoryError(f"{label}: starRules unknown keys: {unknown}")
    out: dict[str, int | None] = {}
    for key in STAR_RULE_KEYS:
        raw = value.get(key)
        if raw is None:
            out[key] = None
        else:
            out[key] = _require_int(raw, f"{label}.starRules.{key}", minimum=0)
    if (
        out["twoStarMaxMistakes"] is not None
        and out["threeStarMaxMistakes"] is not None
        and out["threeStarMaxMistakes"] > out["twoStarMaxMistakes"]
    ):
        raise FactoryError(f"{label}: threeStarMaxMistakes twoStarMaxMistakes'tan gevşek olamaz")
    if (
        out["twoStarMaxSeconds"] is not None
        and out["threeStarMaxSeconds"] is not None
        and out["threeStarMaxSeconds"] > out["twoStarMaxSeconds"]
    ):
        raise FactoryError(f"{label}: threeStarMaxSeconds twoStarMaxSeconds'tan gevşek olamaz")
    return out


def _normalize_info_cards(value: Any, label: str) -> list[str]:
    if value is None:
        return []
    if not isinstance(value, list):
        raise FactoryError(f"{label}: infoCardIds list olmalı")
    out: list[str] = []
    seen: set[str] = set()
    for raw in value:
        if not isinstance(raw, str) or not raw or raw.strip() != raw:
            raise FactoryError(f"{label}: infoCardIds non-empty exact string olmalı")
        if raw in seen:
            raise FactoryError(f"{label}: duplicate infoCardId {raw}")
        seen.add(raw)
        out.append(raw)
    return out


def normalize_manifest(data: dict[str, Any], lock: SourceLock) -> dict[str, Any]:
    if not isinstance(data, dict):
        raise FactoryError("manifest object olmalı")
    if data.get("schemaVersion") != INPUT_SCHEMA_VERSION:
        raise FactoryError(f"desteklenmeyen schemaVersion={data.get('schemaVersion')!r}")
    allowed_top = {"schemaVersion", "seed", "routes"}
    unknown_top = sorted(set(data) - allowed_top)
    if unknown_top:
        raise FactoryError(f"manifest unknown top-level keys: {unknown_top}")
    global_seed = _require_int(data.get("seed"), "seed", minimum=0)
    routes_raw = data.get("routes")
    if not isinstance(routes_raw, list) or not routes_raw:
        raise FactoryError("routes boş/eksik")

    seen_route_ids: set[str] = set()
    seen_level_ids: set[str] = set()
    routes_out: list[dict[str, Any]] = []
    for route_raw in routes_raw:
        if not isinstance(route_raw, dict):
            raise FactoryError("route object olmalı")
        unknown_route = sorted(set(route_raw) - {"routeId", "levels"})
        if unknown_route:
            raise FactoryError(f"route unknown keys: {unknown_route}")
        route_id = route_raw.get("routeId")
        if not isinstance(route_id, str) or not route_id or route_id.strip() != route_id:
            raise FactoryError(f"missing/invalid routeId: {route_id!r}")
        if route_id not in lock.routes:
            raise FactoryError(f"unknown production routeId: {route_id}")
        if route_id in seen_route_ids:
            raise FactoryError(f"duplicate routeId in manifest: {route_id}")
        seen_route_ids.add(route_id)
        levels_raw = route_raw.get("levels")
        if not isinstance(levels_raw, list) or not levels_raw:
            raise FactoryError(f"{route_id}: levels boş/eksik")

        seen_indexes: set[int] = set()
        levels_out: list[dict[str, Any]] = []
        for level_raw in levels_raw:
            if not isinstance(level_raw, dict):
                raise FactoryError(f"{route_id}: level object olmalı")
            allowed_level = {
                "id", "index", "type", "targetWords", "bonusWords", "starRules",
                "displayName", "timeLimitSeconds", "infoCardIds", "seed",
            }
            unknown_level = sorted(set(level_raw) - allowed_level)
            if unknown_level:
                raise FactoryError(f"{route_id}: level unknown keys: {unknown_level}")
            level_id = level_raw.get("id")
            if not isinstance(level_id, str) or not level_id or level_id.strip() != level_id:
                raise FactoryError(f"{route_id}: explicit non-empty level id required")
            if level_id in seen_level_ids:
                raise FactoryError(f"duplicate level id: {level_id}")
            seen_level_ids.add(level_id)
            index = _require_int(level_raw.get("index"), f"{route_id}/{level_id}.index")
            if index < 11 or index > 100:
                raise FactoryError(f"{route_id}/{level_id}: candidate index {index} outside 11..100")
            if index in seen_indexes:
                raise FactoryError(f"{route_id}: duplicate candidate index {index}")
            seen_indexes.add(index)
            level_type = level_raw.get("type")
            if level_type not in LEVEL_TYPES:
                raise FactoryError(f"{route_id}/{level_id}: invalid type={level_type!r}")
            if index < 100 and level_type == "routeFinal":
                raise FactoryError(f"{route_id}/{level_id}: routeFinal forbidden before L100")
            if index == 100 and level_type != "routeFinal":
                raise FactoryError(f"{route_id}/{level_id}: L100 must use routeFinal")

            if "targetWords" not in level_raw or not isinstance(level_raw["targetWords"], list):
                raise FactoryError(f"{route_id}/{level_id}: targetWords list required")
            if "bonusWords" not in level_raw or not isinstance(level_raw["bonusWords"], list):
                raise FactoryError(f"{route_id}/{level_id}: bonusWords list required")
            targets = [normalize_word(word) for word in level_raw["targetWords"]]
            bonus = [normalize_word(word) for word in level_raw["bonusWords"]]
            if not targets:
                raise FactoryError(f"{route_id}/{level_id}: at least one target word required")

            star_rules = _validate_star_rules(level_raw.get("starRules"), f"{route_id}/{level_id}")
            display_name = level_raw.get("displayName")
            if display_name is not None:
                if not isinstance(display_name, str) or not display_name.strip():
                    raise FactoryError(f"{route_id}/{level_id}: displayName invalid")
            time_limit = level_raw.get("timeLimitSeconds")
            if time_limit is not None:
                time_limit = _require_int(
                    time_limit,
                    f"{route_id}/{level_id}.timeLimitSeconds",
                    minimum=1,
                )
            info_cards = _normalize_info_cards(level_raw.get("infoCardIds"), f"{route_id}/{level_id}")
            explicit_seed = level_raw.get("seed")
            if explicit_seed is not None:
                explicit_seed = _require_int(
                    explicit_seed,
                    f"{route_id}/{level_id}.seed",
                    minimum=0,
                )

            levels_out.append({
                "id": level_id,
                "index": index,
                "type": level_type,
                "targetWords": targets,
                "bonusWords": bonus,
                "starRules": star_rules,
                "displayName": display_name,
                "timeLimitSeconds": time_limit,
                "infoCardIds": info_cards,
                "seed": explicit_seed,
            })

        levels_out.sort(key=lambda level: (level["index"], level["id"]))
        routes_out.append({"routeId": route_id, "levels": levels_out})

    routes_out.sort(key=lambda route: route["routeId"])
    return {"schemaVersion": INPUT_SCHEMA_VERSION, "seed": global_seed, "routes": routes_out}


def source_digest_for_manifest(manifest: dict[str, Any], lock: SourceLock) -> str:
    payload = {
        "compilerVersion": COMPILER_VERSION,
        "generationContract": GENERATION_CONTRACT,
        "manifest": manifest,
        "segment1SourceLock": {
            "lockDigest": lock.lock_digest,
            "lockVersion": lock.lock_version,
        },
    }
    return sha256_text(canonical_json(payload))


def derive_level_seed(
    global_seed: int,
    route_id: str,
    index: int,
    *,
    compiler_version: str = COMPILER_VERSION,
) -> int:
    material = f"{compiler_version}\n{global_seed}\n{route_id}\n{index}".encode("utf-8")
    return int.from_bytes(hashlib.sha256(material).digest()[:8], "big") & MAX_SEED


def cells_for(word: str, row: int, col: int, dr: int, dc: int) -> list[tuple[int, int]] | None:
    end_row = row + dr * (len(word) - 1)
    end_col = col + dc * (len(word) - 1)
    if not (0 <= end_row < GRID_SIZE and 0 <= end_col < GRID_SIZE):
        return None
    return [(row + dr * i, col + dc * i) for i in range(len(word))]


def candidate_placements(word: str, grid: list[list[str | None]], rng: StableRng) -> list[Placement]:
    candidates: list[Placement] = []
    for row in range(GRID_SIZE):
        for col in range(GRID_SIZE):
            for dr, dc in DIRECTIONS:
                cells = cells_for(word, row, col, dr, dc)
                if cells is None:
                    continue
                if all(grid[r][c] in (None, ch) for (r, c), ch in zip(cells, word)):
                    candidates.append(Placement(word, row, col, dr, dc))
    rng.shuffle(candidates)
    candidates.sort(
        key=lambda placement: -sum(
            1
            for (r, c), ch in zip(
                cells_for(
                    placement.word,
                    placement.row,
                    placement.col,
                    placement.dr,
                    placement.dc,
                ) or (),
                placement.word,
            )
            if grid[r][c] == ch
        )
    )
    return candidates


def apply_placement(grid: list[list[str | None]], placement: Placement) -> list[tuple[int, int]]:
    changed: list[tuple[int, int]] = []
    cells = cells_for(placement.word, placement.row, placement.col, placement.dr, placement.dc)
    if cells is None:
        raise FactoryError(f"placement outside grid: {placement}")
    for (row, col), char in zip(cells, placement.word):
        if grid[row][col] is None:
            grid[row][col] = char
            changed.append((row, col))
    return changed


def rollback(grid: list[list[str | None]], changed: Iterable[tuple[int, int]]) -> None:
    for row, col in changed:
        grid[row][col] = None


def place_all(words: Sequence[str], rng: StableRng) -> tuple[list[list[str | None]], list[Placement]]:
    grid: list[list[str | None]] = [[None] * GRID_SIZE for _ in range(GRID_SIZE)]
    ordered = sorted(words, key=lambda word: (-len(word), word))
    placements: list[Placement] = []
    visited_nodes = 0

    def backtrack(index: int) -> bool:
        nonlocal visited_nodes
        if index == len(ordered):
            return True
        word = ordered[index]
        for placement in candidate_placements(word, grid, rng):
            visited_nodes += 1
            if visited_nodes > MAX_BACKTRACK_NODES:
                raise _SearchBudgetExceeded(
                    f"backtracking budget exceeded ({MAX_BACKTRACK_NODES})"
                )
            changed = apply_placement(grid, placement)
            placements.append(placement)
            if backtrack(index + 1):
                return True
            placements.pop()
            rollback(grid, changed)
        return False

    if not backtrack(0):
        raise FactoryError("word set could not be placed in 8x8 grid")
    return grid, placements


def canonical_physical_path(cells: Sequence[tuple[int, int]]) -> tuple[tuple[int, int], ...]:
    path = tuple(cells)
    reverse = tuple(reversed(path))
    return min(path, reverse)


def count_occurrences(grid_rows: Sequence[str], word: str) -> int:
    physical_paths: set[tuple[tuple[int, int], ...]] = set()
    for row in range(GRID_SIZE):
        for col in range(GRID_SIZE):
            for dr, dc in DIRECTIONS:
                cells = cells_for(word, row, col, dr, dc)
                if cells is None:
                    continue
                candidate = "".join(grid_rows[r][c] for r, c in cells)
                if candidate == word:
                    physical_paths.add(canonical_physical_path(cells))
    return len(physical_paths)


def finalize_grid(
    partial: list[list[str | None]],
    words: Sequence[str],
    rng: StableRng,
) -> list[str]:
    empty = [
        (row, col)
        for row in range(GRID_SIZE)
        for col in range(GRID_SIZE)
        if partial[row][col] is None
    ]
    for _ in range(MAX_FILL_ATTEMPTS):
        grid = [row[:] for row in partial]
        for row, col in empty:
            grid[row][col] = rng.choice(ALPHABET)
        rows = ["".join(char or "" for char in row) for row in grid]
        if all(count_occurrences(rows, word) == 1 for word in words):
            return rows
    raise FactoryError(
        f"filler could not satisfy exact-one after {MAX_FILL_ATTEMPTS} deterministic attempts"
    )


def _placement_dict(placement: Placement) -> dict[str, Any]:
    cells = cells_for(placement.word, placement.row, placement.col, placement.dr, placement.dc)
    if cells is None:
        raise FactoryError("internal placement outside grid")
    return {
        "word": placement.word,
        "row": placement.row,
        "col": placement.col,
        "dr": placement.dr,
        "dc": placement.dc,
        "cells": [[row, col] for row, col in cells],
    }


def _level_lock_material(level: dict[str, Any]) -> dict[str, Any]:
    return {
        "bonusWords": level["bonusWords"],
        "displayName": level["displayName"],
        "grid": level["grid"],
        "id": level["id"],
        "index": level["index"],
        "infoCardIds": level["infoCardIds"],
        "placements": level["placements"],
        "resolvedSeed": level["resolvedSeed"],
        "routeId": level["routeId"],
        "seed": level["seed"],
        "starRules": level["starRules"],
        "targetWords": level["targetWords"],
        "timeLimitSeconds": level["timeLimitSeconds"],
        "type": level["type"],
    }


def level_fingerprint(level: dict[str, Any]) -> str:
    return sha256_text(canonical_json(_level_lock_material(level)))


def _duplicate_message(
    *,
    route_id: str,
    word: str,
    new_level: dict[str, Any],
    new_role: str,
    first: dict[str, Any],
) -> str:
    if first.get("source") == "Segment1":
        existing = (
            f"Segment1 {first.get('levelId')} L{first.get('index')} "
            f"{first.get('role', 'UNKNOWN')}"
        )
    elif first.get("source") == "production":
        existing = (
            f"production {first.get('levelId')} L{first.get('index')} "
            f"{first.get('role', 'UNKNOWN')}"
        )
    else:
        existing = (
            f"candidate {first.get('levelId')} L{first.get('index')} "
            f"{first.get('role', 'UNKNOWN')}"
        )
    return (
        f"route={route_id} word={word} "
        f"new={new_level['id']} L{new_level['index']} {new_role} "
        f"existing={existing}"
    )


def _origin_index_for_diagnostic(origin: dict[str, Any]) -> int:
    index_keys = [
        key
        for key in ("localIndex", "index")
        if key in origin
    ]
    if len(index_keys) != 1:
        raise FactoryError(
            "word origin tam bir index contract taşımalı: "
            "production=localIndex legacy=index"
        )
    key = index_keys[0]
    return _require_int(
        origin[key],
        f"wordOrigin.{key}",
        minimum=1,
    )


def enforce_route_uniqueness(
    route_id: str,
    levels: Sequence[dict[str, Any]],
    lock_route: SourceLockRoute | ProductionCorpusRoute,
) -> tuple[int, int, int]:
    seen: dict[str, dict[str, Any]] = {}
    source_name = (
        "production"
        if isinstance(lock_route, ProductionCorpusRoute)
        else "Segment1"
    )
    for word in lock_route.reserved_words:
        origin = lock_route.origins[word]
        seen[word] = {
            "source": source_name,
            "levelId": origin["levelId"],
            "index": _origin_index_for_diagnostic(origin),
            "role": origin["role"],
        }

    target_count = 0
    bonus_count = 0
    for level in sorted(levels, key=lambda item: (item["index"], item["id"])):
        for role, key in (("TARGET", "targetWords"), ("BONUS", "bonusWords")):
            for word in level[key]:
                first = seen.get(word)
                if first is not None:
                    raise FactoryError(
                        _duplicate_message(
                            route_id=route_id,
                            word=word,
                            new_level=level,
                            new_role=role,
                            first=first,
                        )
                    )
                seen[word] = {
                    "source": "candidate",
                    "levelId": level["id"],
                    "index": level["index"],
                    "role": role,
                }
                if role == "TARGET":
                    target_count += 1
                else:
                    bonus_count += 1
    return target_count, bonus_count, len(seen)


def generate_level(
    route_id: str,
    source_level: dict[str, Any],
    global_seed: int,
    *,
    compiler_version: str = COMPILER_VERSION,
) -> dict[str, Any]:
    resolved_seed = (
        source_level["seed"]
        if source_level["seed"] is not None
        else derive_level_seed(
            global_seed,
            route_id,
            source_level["index"],
            compiler_version=compiler_version,
        )
    )
    words = source_level["targetWords"] + source_level["bonusWords"]
    last_error: FactoryError | None = None
    for retry in range(MAX_GENERATION_ATTEMPTS):
        rng = StableRng(f"{compiler_version}:{resolved_seed}:attempt:{retry}")
        try:
            partial, placements = place_all(words, rng)
            rows = finalize_grid(partial, words, rng)
            break
        except FactoryError as exc:
            last_error = exc
    else:
        raise FactoryError(
            f"route={route_id} level={source_level['id']} L{source_level['index']} "
            f"generation failed after {MAX_GENERATION_ATTEMPTS} attempts: {last_error}"
        )

    placement_rows = sorted(
        (_placement_dict(placement) for placement in placements),
        key=lambda item: item["word"],
    )
    level = {
        "id": source_level["id"],
        "routeId": route_id,
        "index": source_level["index"],
        "type": source_level["type"],
        "grid": rows,
        "targetWords": source_level["targetWords"],
        "bonusWords": source_level["bonusWords"],
        "starRules": source_level["starRules"],
        "displayName": source_level["displayName"],
        "timeLimitSeconds": source_level["timeLimitSeconds"],
        "infoCardIds": source_level["infoCardIds"],
        "seed": source_level["seed"],
        "resolvedSeed": resolved_seed,
        "placements": placement_rows,
    }
    validate_generated_level(level)
    level["fingerprint"] = level_fingerprint(level)
    return level


def validate_generated_level(level: dict[str, Any]) -> None:
    grid = level.get("grid")
    if not isinstance(grid, list) or len(grid) != GRID_SIZE:
        raise FactoryError(f"{level.get('id')}: grid must have {GRID_SIZE} rows")
    if any(not isinstance(row, str) or len(row) != GRID_SIZE for row in grid):
        raise FactoryError(f"{level.get('id')}: every grid row must have {GRID_SIZE} runes")
    for row in grid:
        if any(char not in ALPHABET for char in row):
            raise FactoryError(f"{level.get('id')}: grid contains unsupported alphabet char")

    intended = level["targetWords"] + level["bonusWords"]
    for word in intended:
        count = count_occurrences(grid, word)
        if count != 1:
            raise FactoryError(f"{level['id']}: exact-one violation word={word} count={count}")

    placements = level.get("placements")
    if not isinstance(placements, list) or len(placements) != len(intended):
        raise FactoryError(f"{level['id']}: placement count mismatch")
    by_word: dict[str, dict[str, Any]] = {}
    for placement in placements:
        if not isinstance(placement, dict):
            raise FactoryError(f"{level['id']}: placement object required")
        word = placement.get("word")
        if word not in intended or word in by_word:
            raise FactoryError(f"{level['id']}: placement word invalid/duplicate {word!r}")
        row = _require_int(placement.get("row"), f"{level['id']}:{word}.row", minimum=0)
        col = _require_int(placement.get("col"), f"{level['id']}:{word}.col", minimum=0)
        dr = placement.get("dr")
        dc = placement.get("dc")
        if (dr, dc) not in DIRECTIONS:
            raise FactoryError(f"{level['id']}:{word}: placement direction invalid")
        cells = cells_for(word, row, col, dr, dc)
        if cells is None:
            raise FactoryError(f"{level['id']}:{word}: placement outside grid")
        expected_cells = [[r, c] for r, c in cells]
        if placement.get("cells") != expected_cells:
            raise FactoryError(f"{level['id']}:{word}: placement cells mismatch")
        read = "".join(grid[r][c] for r, c in cells)
        if read != word:
            raise FactoryError(
                f"{level['id']}:{word}: placement/grid mismatch read={read}"
            )
        by_word[word] = placement
    if set(by_word) != set(intended):
        raise FactoryError(f"{level['id']}: placement intended-word set mismatch")


def _source_projection_from_artifact(artifact: dict[str, Any]) -> dict[str, Any]:
    routes: list[dict[str, Any]] = []
    for route in artifact["routes"]:
        levels: list[dict[str, Any]] = []
        for level in route["levels"]:
            levels.append({
                "id": level["id"],
                "index": level["index"],
                "type": level["type"],
                "targetWords": level["targetWords"],
                "bonusWords": level["bonusWords"],
                "starRules": level["starRules"],
                "displayName": level["displayName"],
                "timeLimitSeconds": level["timeLimitSeconds"],
                "infoCardIds": level["infoCardIds"],
                "seed": level["seed"],
            })
        routes.append({"routeId": route["routeId"], "levels": levels})
    routes.sort(key=lambda route: route["routeId"])
    for route in routes:
        route["levels"].sort(key=lambda level: (level["index"], level["id"]))
    return {
        "schemaVersion": artifact["inputSchemaVersion"],
        "seed": artifact["globalSeed"],
        "routes": routes,
    }


def compile_manifest(data: dict[str, Any], lock: SourceLock) -> dict[str, Any]:
    manifest = normalize_manifest(data, lock)
    source_digest = source_digest_for_manifest(manifest, lock)
    routes_out: list[dict[str, Any]] = []
    total_levels = 0
    for route in manifest["routes"]:
        route_id = route["routeId"]
        lock_route = lock.routes[route_id]
        target_count, bonus_count, ending_reserved = enforce_route_uniqueness(
            route_id,
            route["levels"],
            lock_route,
        )
        levels_out = [
            generate_level(route_id, level, manifest["seed"])
            for level in route["levels"]
        ]
        total_levels += len(levels_out)
        routes_out.append({
            "routeId": route_id,
            "startingReservedWordCount": len(lock_route.reserved_words),
            "candidateTargetCount": target_count,
            "candidateBonusCount": bonus_count,
            "endingReservedWordCount": ending_reserved,
            "strictUniqueness": "PASS",
            "exactOneGrid": "PASS",
            "levels": levels_out,
        })

    artifact = {
        "artifactSchemaVersion": ARTIFACT_SCHEMA_VERSION,
        "artifactKind": "NON_PRODUCTION_KA02_CANDIDATE",
        "compilerVersion": COMPILER_VERSION,
        "inputSchemaVersion": INPUT_SCHEMA_VERSION,
        "globalSeed": manifest["seed"],
        "generationContract": GENERATION_CONTRACT,
        "segment1SourceLock": {
            "lockVersion": lock.lock_version,
            "lockDigest": lock.lock_digest,
            "wave8ImplementationAuthority": lock.raw.get("wave8ImplementationAuthority"),
            "wave8FinalIntegrationAuthority": lock.raw.get("wave8FinalIntegrationAuthority"),
        },
        "sourceDigest": source_digest,
        "status": "CANDIDATE_READY_FOR_REVIEW",
        "totalCandidateLevels": total_levels,
        "routes": routes_out,
    }
    validate_artifact(artifact, lock)
    return artifact


def validate_artifact(artifact: dict[str, Any], lock: SourceLock) -> dict[str, Any]:
    if not isinstance(artifact, dict):
        raise FactoryError("artifact object olmalı")
    if artifact.get("artifactSchemaVersion") != ARTIFACT_SCHEMA_VERSION:
        raise FactoryError("artifact schema mismatch")
    if artifact.get("artifactKind") != "NON_PRODUCTION_KA02_CANDIDATE":
        raise FactoryError("artifactKind mismatch")
    if artifact.get("compilerVersion") != COMPILER_VERSION:
        raise FactoryError(
            f"compilerVersion mismatch {artifact.get('compilerVersion')!r} != {COMPILER_VERSION}"
        )
    if artifact.get("inputSchemaVersion") != INPUT_SCHEMA_VERSION:
        raise FactoryError("inputSchemaVersion mismatch")
    if artifact.get("generationContract") != GENERATION_CONTRACT:
        raise FactoryError("generationContract mismatch")
    lock_info = artifact.get("segment1SourceLock")
    if not isinstance(lock_info, dict):
        raise FactoryError("segment1SourceLock missing")
    if lock_info.get("lockVersion") != lock.lock_version:
        raise FactoryError("Segment1 lockVersion mismatch")
    if lock_info.get("lockDigest") != lock.lock_digest:
        raise FactoryError("Segment1 source lock identity mismatch")
    if artifact.get("status") != "CANDIDATE_READY_FOR_REVIEW":
        raise FactoryError("artifact status mismatch")

    manifest = _source_projection_from_artifact(artifact)
    normalized_manifest = normalize_manifest(manifest, lock)
    expected_source_digest = source_digest_for_manifest(normalized_manifest, lock)
    if artifact.get("sourceDigest") != expected_source_digest:
        raise FactoryError(
            "sourceDigest mismatch: "
            f"stored={artifact.get('sourceDigest')} actual={expected_source_digest}"
        )

    routes = artifact.get("routes")
    if not isinstance(routes, list) or not routes:
        raise FactoryError("artifact routes missing")
    if [route.get("routeId") for route in routes] != sorted(route.get("routeId") for route in routes):
        raise FactoryError("artifact routes must be canonical routeId order")

    total_levels = 0
    for route in routes:
        route_id = route.get("routeId")
        if route_id not in lock.routes:
            raise FactoryError(f"artifact unknown routeId {route_id!r}")
        levels = route.get("levels")
        if not isinstance(levels, list) or not levels:
            raise FactoryError(f"{route_id}: artifact levels missing")
        if [level.get("index") for level in levels] != sorted(level.get("index") for level in levels):
            raise FactoryError(f"{route_id}: levels not index-sorted")

        projected_route = next(item for item in normalized_manifest["routes"] if item["routeId"] == route_id)
        target_count, bonus_count, ending_reserved = enforce_route_uniqueness(
            route_id,
            projected_route["levels"],
            lock.routes[route_id],
        )
        if route.get("startingReservedWordCount") != len(lock.routes[route_id].reserved_words):
            raise FactoryError(f"{route_id}: startingReservedWordCount mismatch")
        if route.get("candidateTargetCount") != target_count:
            raise FactoryError(f"{route_id}: candidateTargetCount mismatch")
        if route.get("candidateBonusCount") != bonus_count:
            raise FactoryError(f"{route_id}: candidateBonusCount mismatch")
        if route.get("endingReservedWordCount") != ending_reserved:
            raise FactoryError(f"{route_id}: endingReservedWordCount mismatch")
        if route.get("strictUniqueness") != "PASS" or route.get("exactOneGrid") != "PASS":
            raise FactoryError(f"{route_id}: validation status fields must be PASS")

        for source_level, level in zip(projected_route["levels"], levels, strict=True):
            if level.get("routeId") != route_id:
                raise FactoryError(f"{route_id}/{level.get('id')}: routeId mismatch")
            expected_seed = (
                source_level["seed"]
                if source_level["seed"] is not None
                else derive_level_seed(normalized_manifest["seed"], route_id, source_level["index"])
            )
            if level.get("resolvedSeed") != expected_seed:
                raise FactoryError(f"{route_id}/{level.get('id')}: resolvedSeed mismatch")
            validate_generated_level(level)
            actual_fingerprint = level_fingerprint(level)
            if level.get("fingerprint") != actual_fingerprint:
                raise FactoryError(
                    f"{route_id}/{level.get('id')}: fingerprint mismatch "
                    f"stored={level.get('fingerprint')} actual={actual_fingerprint}"
                )
        total_levels += len(levels)

    if artifact.get("totalCandidateLevels") != total_levels:
        raise FactoryError("totalCandidateLevels mismatch")
    return artifact



def validate_append_contract(
    manifest: dict[str, Any],
    corpus: ProductionCorpusLock,
) -> None:
    for route in manifest["routes"]:
        route_id = route["routeId"]
        production = corpus.routes[route_id]
        levels = route["levels"]
        indexes = [level["index"] for level in levels]
        expected_start = production.available_level_count + 1
        expected = list(range(expected_start, expected_start + len(indexes)))

        if any(index <= production.available_level_count for index in indexes):
            raise FactoryError(
                f"{route_id}: existing localIndex overwrite yasak; "
                f"available={production.available_level_count} candidate={indexes}"
            )
        if indexes != expected:
            raise FactoryError(
                f"{route_id}: candidate current frontier'dan contiguous append olmalı; "
                f"expected={expected} actual={indexes}"
            )
        if indexes[-1] > production.planned_level_count:
            raise FactoryError(
                f"{route_id}: candidate plannedLevelCount aşar; "
                f"planned={production.planned_level_count} candidate={indexes}"
            )


def source_digest_for_manifest_v2(
    manifest: dict[str, Any],
    corpus: ProductionCorpusLock,
) -> str:
    payload = {
        "compilerVersion": V2_COMPILER_VERSION,
        "generationContract": GENERATION_CONTRACT,
        "manifest": manifest,
        "productionCorpusLock": {
            "schemaVersion": PRODUCTION_CORPUS_SCHEMA_VERSION,
            "sourceDigest": corpus.source_digest,
        },
    }
    return sha256_text(canonical_json(payload))


def compile_manifest_v2(
    data: dict[str, Any],
    corpus: ProductionCorpusLock,
) -> dict[str, Any]:
    manifest = normalize_manifest(data, corpus)
    validate_append_contract(manifest, corpus)
    source_digest = source_digest_for_manifest_v2(manifest, corpus)
    routes_out: list[dict[str, Any]] = []
    total_levels = 0

    for route in manifest["routes"]:
        route_id = route["routeId"]
        corpus_route = corpus.routes[route_id]
        target_count, bonus_count, ending_reserved = enforce_route_uniqueness(
            route_id,
            route["levels"],
            corpus_route,
        )
        levels_out = [
            generate_level(
                route_id,
                level,
                manifest["seed"],
                compiler_version=V2_COMPILER_VERSION,
            )
            for level in route["levels"]
        ]
        total_levels += len(levels_out)
        routes_out.append({
            "routeId": route_id,
            "startingReservedWordCount": len(corpus_route.reserved_words),
            "candidateTargetCount": target_count,
            "candidateBonusCount": bonus_count,
            "endingReservedWordCount": ending_reserved,
            "strictUniqueness": "PASS",
            "exactOneGrid": "PASS",
            "levels": levels_out,
        })

    artifact = {
        "artifactSchemaVersion": V2_ARTIFACT_SCHEMA_VERSION,
        "artifactKind": "NON_PRODUCTION_KA02_CANDIDATE",
        "compilerVersion": V2_COMPILER_VERSION,
        "inputSchemaVersion": INPUT_SCHEMA_VERSION,
        "globalSeed": manifest["seed"],
        "generationContract": GENERATION_CONTRACT,
        "productionCorpusLock": {
            "schemaVersion": PRODUCTION_CORPUS_SCHEMA_VERSION,
            "sourceDigest": corpus.source_digest,
        },
        "sourceDigest": source_digest,
        "status": "CANDIDATE_READY_FOR_REVIEW",
        "totalCandidateLevels": total_levels,
        "routes": routes_out,
    }
    validate_artifact_v2(artifact, corpus)
    return artifact


def validate_artifact_v2(
    artifact: dict[str, Any],
    corpus: ProductionCorpusLock,
) -> dict[str, Any]:
    if not isinstance(artifact, dict):
        raise FactoryError("artifact object olmalı")
    if artifact.get("artifactSchemaVersion") != V2_ARTIFACT_SCHEMA_VERSION:
        raise FactoryError("v2 artifact schema mismatch")
    if artifact.get("artifactKind") != "NON_PRODUCTION_KA02_CANDIDATE":
        raise FactoryError("v2 artifactKind mismatch")
    if artifact.get("compilerVersion") != V2_COMPILER_VERSION:
        raise FactoryError("v2 compilerVersion mismatch")
    if artifact.get("inputSchemaVersion") != INPUT_SCHEMA_VERSION:
        raise FactoryError("v2 input schema mismatch")
    if artifact.get("generationContract") != GENERATION_CONTRACT:
        raise FactoryError("v2 generationContract mismatch")
    lock_info = artifact.get("productionCorpusLock")
    if lock_info != {
        "schemaVersion": PRODUCTION_CORPUS_SCHEMA_VERSION,
        "sourceDigest": corpus.source_digest,
    }:
        raise FactoryError("production corpus lock identity mismatch")
    if artifact.get("status") != "CANDIDATE_READY_FOR_REVIEW":
        raise FactoryError("v2 artifact status mismatch")

    manifest = _source_projection_from_artifact(artifact)
    normalized_manifest = normalize_manifest(manifest, corpus)
    validate_append_contract(normalized_manifest, corpus)
    expected_source_digest = source_digest_for_manifest_v2(
        normalized_manifest,
        corpus,
    )
    if artifact.get("sourceDigest") != expected_source_digest:
        raise FactoryError(
            "v2 sourceDigest mismatch: "
            f"stored={artifact.get('sourceDigest')} actual={expected_source_digest}"
        )

    routes = artifact.get("routes")
    if not isinstance(routes, list) or not routes:
        raise FactoryError("v2 artifact routes missing")
    if [route.get("routeId") for route in routes] != sorted(
        route.get("routeId") for route in routes
    ):
        raise FactoryError("v2 artifact routes must be canonical routeId order")

    total_levels = 0
    for route in routes:
        route_id = route.get("routeId")
        if route_id not in corpus.routes:
            raise FactoryError(f"v2 artifact unknown routeId {route_id!r}")
        levels = route.get("levels")
        if not isinstance(levels, list) or not levels:
            raise FactoryError(f"{route_id}: v2 artifact levels missing")
        projected_route = next(
            item
            for item in normalized_manifest["routes"]
            if item["routeId"] == route_id
        )
        corpus_route = corpus.routes[route_id]
        target_count, bonus_count, ending_reserved = enforce_route_uniqueness(
            route_id,
            projected_route["levels"],
            corpus_route,
        )
        if route.get("startingReservedWordCount") != len(
            corpus_route.reserved_words
        ):
            raise FactoryError(f"{route_id}: v2 startingReservedWordCount mismatch")
        if route.get("candidateTargetCount") != target_count:
            raise FactoryError(f"{route_id}: v2 candidateTargetCount mismatch")
        if route.get("candidateBonusCount") != bonus_count:
            raise FactoryError(f"{route_id}: v2 candidateBonusCount mismatch")
        if route.get("endingReservedWordCount") != ending_reserved:
            raise FactoryError(f"{route_id}: v2 endingReservedWordCount mismatch")
        if (
            route.get("strictUniqueness") != "PASS"
            or route.get("exactOneGrid") != "PASS"
        ):
            raise FactoryError(f"{route_id}: v2 validation status must PASS")

        for source_level, level in zip(
            projected_route["levels"],
            levels,
            strict=True,
        ):
            expected_seed = (
                source_level["seed"]
                if source_level["seed"] is not None
                else derive_level_seed(
                    normalized_manifest["seed"],
                    route_id,
                    source_level["index"],
                    compiler_version=V2_COMPILER_VERSION,
                )
            )
            if level.get("resolvedSeed") != expected_seed:
                raise FactoryError(
                    f"{route_id}/{level.get('id')}: v2 resolvedSeed mismatch"
                )
            validate_generated_level(level)
            if level.get("fingerprint") != level_fingerprint(level):
                raise FactoryError(
                    f"{route_id}/{level.get('id')}: v2 fingerprint mismatch"
                )
        total_levels += len(levels)

    if artifact.get("totalCandidateLevels") != total_levels:
        raise FactoryError("v2 totalCandidateLevels mismatch")
    return artifact


def write_report_v2(
    artifact: dict[str, Any],
    *,
    validation_only: bool = False,
) -> str:
    status = "VALIDATION PASS" if validation_only else "COMPILE PASS"
    lock = artifact["productionCorpusLock"]
    lines = [
        "KELİME AVI KA-02 CONTENT COMPILER",
        f"Compiler version: {artifact['compilerVersion']}",
        f"Status: {status}",
        "Candidate state: CANDIDATE READY FOR REVIEW",
        f"Source digest: {artifact['sourceDigest']}",
        (
            "Production corpus: "
            f"schema={lock['schemaVersion']} sourceDigest={lock['sourceDigest']}"
        ),
        f"Candidate levels: {artifact['totalCandidateLevels']}",
        "",
    ]
    for route in artifact["routes"]:
        lines.append(
            f"- route={route['routeId']} levels={len(route['levels'])} "
            f"reserved={route['startingReservedWordCount']} "
            f"targets={route['candidateTargetCount']} "
            f"bonus={route['candidateBonusCount']} "
            f"endingReserved={route['endingReservedWordCount']} "
            "uniqueness=PASS exactOne=PASS"
        )
        for level in route["levels"]:
            lines.append(
                f"  L{level['index']} id={level['id']} "
                f"seed={level['resolvedSeed']} "
                f"fingerprint={level['fingerprint']}"
            )
    lines.extend([
        "",
        "Strict cumulative route-wide uniqueness: PASS",
        "Contiguous current-frontier append: PASS",
        "Every intended word exact-one physical occurrence: PASS",
        (
            "This artifact is NON-PRODUCTION tooling output; "
            "owner production approval is separate."
        ),
    ])
    return "\n".join(lines) + "\n"


def validate_legacy_v1_evidence(
    evidence: dict[str, Any],
    source_lock: SourceLock,
) -> dict[str, Any]:
    if evidence.get("schemaVersion") != 1:
        raise FactoryError("legacy evidence schema mismatch")
    if evidence.get("compilerVersion") != COMPILER_VERSION:
        raise FactoryError("legacy evidence compilerVersion mismatch")
    if not isinstance(evidence.get("sourceDigest"), str) or not re.fullmatch(
        r"[0-9a-f]{64}",
        evidence["sourceDigest"],
    ):
        raise FactoryError("legacy evidence sourceDigest invalid")
    lock_info = evidence.get("segment1SourceLock")
    if not isinstance(lock_info, dict):
        raise FactoryError("legacy evidence segment1SourceLock missing")
    if lock_info.get("lockVersion") != source_lock.lock_version:
        raise FactoryError("legacy evidence lockVersion mismatch")
    if lock_info.get("lockDigest") != source_lock.lock_digest:
        raise FactoryError("legacy evidence lockDigest mismatch")

    route_id = evidence.get("routeId")
    if route_id not in source_lock.routes:
        raise FactoryError(f"legacy evidence unknown routeId {route_id!r}")
    levels = evidence.get("levels")
    if not isinstance(levels, list) or not levels:
        raise FactoryError("legacy evidence levels missing")

    normalized_levels: list[dict[str, Any]] = []
    for raw_level in levels:
        if not isinstance(raw_level, dict):
            raise FactoryError("legacy evidence level object required")
        level = copy.deepcopy(raw_level)
        level_id = level.get("id")
        if level.get("routeId") != route_id:
            raise FactoryError(f"{level_id}: legacy routeId mismatch")
        index = _require_int(level.get("index"), f"{level_id}.index", minimum=11)
        if index > 100:
            raise FactoryError(f"{level_id}: legacy index > 100")
        if level.get("type") not in LEVEL_TYPES:
            raise FactoryError(f"{level_id}: legacy type invalid")
        level["targetWords"] = [
            normalize_word(word) for word in level.get("targetWords", [])
        ]
        level["bonusWords"] = [
            normalize_word(word) for word in level.get("bonusWords", [])
        ]
        level["starRules"] = _validate_star_rules(
            level.get("starRules"),
            f"legacy/{level_id}",
        )
        grid = level.get("grid")
        if not isinstance(grid, list) or len(grid) != GRID_SIZE:
            raise FactoryError(f"{level_id}: legacy grid rows invalid")
        if any(not isinstance(row, str) or len(row) != GRID_SIZE for row in grid):
            raise FactoryError(f"{level_id}: legacy grid shape invalid")
        for word in level["targetWords"] + level["bonusWords"]:
            if count_occurrences(grid, word) != 1:
                raise FactoryError(
                    f"{level_id}: legacy exact-one violation word={word}"
                )
        if not isinstance(level.get("fingerprint"), str) or not re.fullmatch(
            r"[0-9a-f]{64}",
            level["fingerprint"],
        ):
            raise FactoryError(f"{level_id}: legacy fingerprint invalid")
        _require_int(
            level.get("resolvedSeed"),
            f"{level_id}.resolvedSeed",
            minimum=0,
        )
        normalized_levels.append(level)

    target_count, bonus_count, ending_reserved = enforce_route_uniqueness(
        route_id,
        normalized_levels,
        source_lock.routes[route_id],
    )
    if evidence.get("startingReservedWordCount") != len(
        source_lock.routes[route_id].reserved_words
    ):
        raise FactoryError("legacy startingReservedWordCount mismatch")
    if evidence.get("candidateTargetCount") != target_count:
        raise FactoryError("legacy candidateTargetCount mismatch")
    if evidence.get("candidateBonusCount") != bonus_count:
        raise FactoryError("legacy candidateBonusCount mismatch")
    if evidence.get("endingReservedWordCount") != ending_reserved:
        raise FactoryError("legacy endingReservedWordCount mismatch")
    if (
        evidence.get("strictUniqueness") != "PASS"
        or evidence.get("exactOneGrid") != "PASS"
    ):
        raise FactoryError("legacy evidence validation status mismatch")
    return evidence

def write_report(artifact: dict[str, Any], *, validation_only: bool = False) -> str:
    status = "VALIDATION PASS" if validation_only else "COMPILE PASS"
    lines = [
        "KELİME AVI KA-02 CONTENT COMPILER",
        f"Compiler version: {artifact['compilerVersion']}",
        f"Status: {status}",
        "Candidate state: CANDIDATE READY FOR REVIEW",
        f"Source digest: {artifact['sourceDigest']}",
        (
            "Segment1 lock: "
            f"{artifact['segment1SourceLock']['lockVersion']} / "
            f"{artifact['segment1SourceLock']['lockDigest']}"
        ),
        f"Candidate levels: {artifact['totalCandidateLevels']}",
        "",
    ]
    for route in artifact["routes"]:
        lines.append(
            f"- route={route['routeId']} levels={len(route['levels'])} "
            f"reserved={route['startingReservedWordCount']} "
            f"targets={route['candidateTargetCount']} bonus={route['candidateBonusCount']} "
            f"endingReserved={route['endingReservedWordCount']} "
            "uniqueness=PASS exactOne=PASS"
        )
        for level in route["levels"]:
            lines.append(
                f"  L{level['index']} id={level['id']} seed={level['resolvedSeed']} "
                f"fingerprint={level['fingerprint']}"
            )
    lines.extend([
        "",
        "Strict route-wide uniqueness: PASS",
        "Every intended word exact-one physical occurrence: PASS",
        "This artifact is NON-PRODUCTION tooling output; owner production approval is separate.",
    ])
    return "\n".join(lines) + "\n"


def _read_json(path: Path, label: str) -> dict[str, Any]:
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise FactoryError(f"{label} okunamadı: {path}: {exc}") from exc
    if not isinstance(value, dict):
        raise FactoryError(f"{label} JSON object olmalı")
    return value


def main() -> int:
    parser = argparse.ArgumentParser(
        description=(
            "Kelime Avı 2.0 KA-02 deterministic NON-PRODUCTION "
            "candidate compiler"
        )
    )
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument(
        "--input",
        type=Path,
        help="schema v2 editorial candidate manifest",
    )
    mode.add_argument(
        "--validate",
        type=Path,
        help="validate a KA-02 v2 candidate artifact",
    )
    mode.add_argument(
        "--verify-source-lock-only",
        action="store_true",
        help="validate historical Segment1 source-lock digest/shape only",
    )
    mode.add_argument(
        "--verify-production-corpus-lock-only",
        action="store_true",
        help="validate generated current production corpus lock only",
    )
    mode.add_argument(
        "--validate-legacy-v1-evidence",
        type=Path,
        help="read-only validate immutable ka02-v1 locked evidence",
    )
    parser.add_argument("--source-lock", type=Path, default=DEFAULT_SOURCE_LOCK)
    parser.add_argument(
        "--production-corpus-lock",
        type=Path,
        default=DEFAULT_PRODUCTION_CORPUS_LOCK,
    )
    parser.add_argument(
        "--legacy-v1-mode",
        action="store_true",
        help=argparse.SUPPRESS,
    )
    parser.add_argument("--output", type=Path)
    parser.add_argument("--report", type=Path)
    args = parser.parse_args()

    try:
        if args.verify_source_lock_only:
            lock = load_source_lock(args.source_lock)
            report = (
                "SEGMENT1_SOURCE_LOCK: PASS\n"
                f"lockVersion={lock.lock_version}\n"
                f"lockDigest={lock.lock_digest}\n"
                f"routes={len(lock.routes)}\n"
            )
            sys.stdout.write(report)
            return 0

        if args.verify_production_corpus_lock_only:
            corpus = load_production_corpus_lock(args.production_corpus_lock)
            report = (
                "PRODUCTION_CORPUS_LOCK: PASS\n"
                f"schemaVersion={PRODUCTION_CORPUS_SCHEMA_VERSION}\n"
                f"sourceDigest={corpus.source_digest}\n"
                f"routes={len(corpus.routes)}\n"
                f"levels={sum(route.available_level_count for route in corpus.routes.values())}\n"
            )
            sys.stdout.write(report)
            return 0

        if args.validate_legacy_v1_evidence is not None:
            lock = load_source_lock(args.source_lock)
            evidence = _read_json(
                args.validate_legacy_v1_evidence,
                "legacy v1 evidence",
            )
            validate_legacy_v1_evidence(evidence, lock)
            report = (
                "KA02_LEGACY_V1_EVIDENCE: PASS\n"
                f"route={evidence['routeId']}\n"
                f"levels={len(evidence['levels'])}\n"
                f"sourceDigest={evidence['sourceDigest']}\n"
            )
            sys.stdout.write(report)
            return 0

        if args.legacy_v1_mode:
            lock = load_source_lock(args.source_lock)
            if args.input is not None:
                if args.output is None:
                    raise FactoryError("compile mode requires --output")
                source = _read_json(args.input, "manifest")
                artifact = compile_manifest(source, lock)
                args.output.parent.mkdir(parents=True, exist_ok=True)
                args.output.write_text(pretty_json(artifact), encoding="utf-8")
                report = write_report(artifact)
            else:
                artifact = _read_json(args.validate, "artifact")
                validate_artifact(artifact, lock)
                report = write_report(artifact, validation_only=True)
        else:
            corpus = load_production_corpus_lock(args.production_corpus_lock)
            if args.input is not None:
                if args.output is None:
                    raise FactoryError("compile mode requires --output")
                source = _read_json(args.input, "manifest")
                artifact = compile_manifest_v2(source, corpus)
                args.output.parent.mkdir(parents=True, exist_ok=True)
                args.output.write_text(pretty_json(artifact), encoding="utf-8")
                report = write_report_v2(artifact)
            else:
                artifact = _read_json(args.validate, "artifact")
                validate_artifact_v2(artifact, corpus)
                report = write_report_v2(artifact, validation_only=True)

        if args.report:
            args.report.parent.mkdir(parents=True, exist_ok=True)
            args.report.write_text(report, encoding="utf-8")
        sys.stdout.write(report)
        return 0
    except FactoryError as exc:
        print(f"KA02_FAIL: {exc}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
