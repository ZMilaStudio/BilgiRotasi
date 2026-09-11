#!/usr/bin/env python3
"""Kelime Avı toplu içerik üreticisi.

Bu araç runtime koduna dokunmadan, editoryal olarak hazırlanmış kelime listelerinden
8x8 bölüm gridleri üretir ve her hedef/bonus kelimenin gridde tam bir kez geçtiğini
doğrular.

Girdi: JSON manifest
Çıktı: JSON paket + doğrulama raporu

Örnek:
  python3 tools/word_hunt_batch_generator.py \
    --input tools/word_hunt_content_factory.sample.json \
    --output /tmp/word_hunt_generated.json \
    --report /tmp/word_hunt_report.txt
"""

from __future__ import annotations

import argparse
import json
import random
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, Sequence

GRID_SIZE = 8
ALPHABET = "ABCÇDEFGĞHIİJKLMNOÖPRSŞTUÜVYZ"
WORD_RE = re.compile(r"^[ABCÇDEFGĞHIİJKLMNOÖPRSŞTUÜVYZ]{3,8}$")
DIRECTIONS = (
    (-1, -1), (-1, 0), (-1, 1),
    (0, -1),           (0, 1),
    (1, -1),  (1, 0),  (1, 1),
)


class FactoryError(RuntimeError):
    pass


@dataclass(frozen=True)
class Placement:
    word: str
    row: int
    col: int
    dr: int
    dc: int


def normalize_word(value: str) -> str:
    word = value.strip().upper().replace(" ", "").replace("-", "")
    if not WORD_RE.fullmatch(word):
        raise FactoryError(
            f"Geçersiz kelime {value!r}; yalnız Türkçe harfler ve 3..8 uzunluk kabul edilir"
        )
    return word


def cells_for(word: str, row: int, col: int, dr: int, dc: int) -> list[tuple[int, int]] | None:
    end_row = row + dr * (len(word) - 1)
    end_col = col + dc * (len(word) - 1)
    if not (0 <= end_row < GRID_SIZE and 0 <= end_col < GRID_SIZE):
        return None
    return [(row + dr * i, col + dc * i) for i in range(len(word))]


def candidate_placements(word: str, grid: list[list[str | None]], rng: random.Random) -> list[Placement]:
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
    # Daha fazla harf çakışması olan yerleşimler daha kompakt ve üretilebilir grid verir.
    candidates.sort(
        key=lambda p: -sum(
            1
            for (r, c), ch in zip(cells_for(p.word, p.row, p.col, p.dr, p.dc) or (), p.word)
            if grid[r][c] == ch
        )
    )
    return candidates


def apply_placement(grid: list[list[str | None]], placement: Placement) -> list[tuple[int, int]]:
    changed: list[tuple[int, int]] = []
    cells = cells_for(placement.word, placement.row, placement.col, placement.dr, placement.dc)
    assert cells is not None
    for (r, c), ch in zip(cells, placement.word):
        if grid[r][c] is None:
            grid[r][c] = ch
            changed.append((r, c))
    return changed


def rollback(grid: list[list[str | None]], changed: Iterable[tuple[int, int]]) -> None:
    for r, c in changed:
        grid[r][c] = None


def place_all(words: Sequence[str], rng: random.Random) -> tuple[list[list[str | None]], list[Placement]]:
    grid: list[list[str | None]] = [[None] * GRID_SIZE for _ in range(GRID_SIZE)]
    ordered = sorted(words, key=lambda w: (-len(w), w))
    placements: list[Placement] = []

    def backtrack(index: int) -> bool:
        if index == len(ordered):
            return True
        word = ordered[index]
        for placement in candidate_placements(word, grid, rng):
            changed = apply_placement(grid, placement)
            placements.append(placement)
            if backtrack(index + 1):
                return True
            placements.pop()
            rollback(grid, changed)
        return False

    if not backtrack(0):
        raise FactoryError("Kelime seti 8x8 gride yerleştirilemedi")
    return grid, placements


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
                    path = tuple(cells)
                    reverse_path = tuple(reversed(path))
                    # Reverse gesture aynı fiziksel occurrence'ı temsil eder. Özellikle
                    # KÖK gibi palindromlarda ileri ve geri tarama iki kez sayılmamalıdır.
                    physical_paths.add(min(path, reverse_path))
    return len(physical_paths)


def finalize_grid(
    partial: list[list[str | None]],
    words: Sequence[str],
    rng: random.Random,
    max_fill_attempts: int = 600,
) -> list[str]:
    empty = [(r, c) for r in range(GRID_SIZE) for c in range(GRID_SIZE) if partial[r][c] is None]
    for _ in range(max_fill_attempts):
        grid = [row[:] for row in partial]
        for r, c in empty:
            grid[r][c] = rng.choice(ALPHABET)
        rows = ["".join(ch or "" for ch in row) for row in grid]
        if all(count_occurrences(rows, word) == 1 for word in words):
            return rows
    raise FactoryError("Dolgu harfleri exact-one occurrence sözleşmesini sağlayamadı")


def validate_word_sets(targets: Sequence[str], bonus: Sequence[str]) -> tuple[list[str], list[str]]:
    normalized_targets = [normalize_word(w) for w in targets]
    normalized_bonus = [normalize_word(w) for w in bonus]
    if len(set(normalized_targets)) != len(normalized_targets):
        raise FactoryError("Hedef kelimelerde tekrar var")
    if len(set(normalized_bonus)) != len(normalized_bonus):
        raise FactoryError("Bonus kelimelerde tekrar var")
    overlap = set(normalized_targets) & set(normalized_bonus)
    if overlap:
        raise FactoryError(f"Hedef/bonus çakışması: {sorted(overlap)}")
    combined = normalized_targets + normalized_bonus
    if len(combined) < 5:
        raise FactoryError("Bir bölüm en az 5 hedef+bonus kelime içermeli")
    if len(combined) > 10:
        raise FactoryError("Bir bölüm en fazla 10 hedef+bonus kelime içermeli")
    return normalized_targets, normalized_bonus


def generate_level(route_id: str, level: dict, global_seed: int) -> dict:
    index = int(level["index"])
    targets, bonus = validate_word_sets(level.get("targetWords", []), level.get("bonusWords", []))
    seed = int(level.get("seed", global_seed * 10000 + index))
    rng = random.Random(seed)
    all_words = targets + bonus

    last_error: Exception | None = None
    for retry in range(80):
        local_rng = random.Random(seed + retry * 7919)
        try:
            partial, placements = place_all(all_words, local_rng)
            rows = finalize_grid(partial, all_words, local_rng)
            break
        except FactoryError as exc:
            last_error = exc
    else:
        raise FactoryError(f"{route_id} bölüm {index}: üretilemedi: {last_error}")

    occurrences = {word: count_occurrences(rows, word) for word in all_words}
    bad = {word: count for word, count in occurrences.items() if count != 1}
    if bad:
        raise FactoryError(f"{route_id} bölüm {index}: exact-one ihlali: {bad}")

    level_type = level.get("type", "normal")
    if level_type not in {"normal", "challenge", "bonus", "routeFinal"}:
        raise FactoryError(f"{route_id} bölüm {index}: geçersiz type={level_type}")

    return {
        "id": level.get("id", f"{route_id}-{index:02d}"),
        "routeId": route_id,
        "index": index,
        "type": level_type,
        "grid": rows,
        "targetWords": targets,
        "bonusWords": bonus,
        "timeLimitSeconds": level.get("timeLimitSeconds"),
        "starRules": level.get(
            "starRules",
            {
                "twoStarMaxMistakes": 2,
                "threeStarMaxMistakes": 0,
            },
        ),
        "infoCardIds": level.get("infoCardIds", []),
        "seed": seed,
        "placements": [p.__dict__ for p in placements],
        "occurrences": occurrences,
    }


def generate_manifest(data: dict) -> dict:
    schema = int(data.get("schemaVersion", 1))
    if schema != 1:
        raise FactoryError(f"Desteklenmeyen schemaVersion={schema}")
    global_seed = int(data.get("seed", 20260906))
    routes_out = []
    seen_route_ids: set[str] = set()
    seen_level_ids: set[str] = set()
    total_levels = 0

    for route in data.get("routes", []):
        route_id = str(route["id"]).strip()
        if not route_id or route_id in seen_route_ids:
            raise FactoryError(f"Boş/tekrar route id: {route_id!r}")
        seen_route_ids.add(route_id)
        levels_in = route.get("levels", [])
        levels_out = []
        for expected_index, level in enumerate(levels_in, start=1):
            if int(level.get("index", expected_index)) != expected_index:
                raise FactoryError(f"{route_id}: bölüm indeksleri 1..N sıralı olmalı")
            generated = generate_level(route_id, level, global_seed + len(routes_out) * 1000)
            if generated["id"] in seen_level_ids:
                raise FactoryError(f"Tekrar level id: {generated['id']}")
            seen_level_ids.add(generated["id"])
            levels_out.append(generated)
        if levels_out and levels_out[-1]["type"] != "routeFinal":
            raise FactoryError(f"{route_id}: son bölüm routeFinal olmalı")
        total_levels += len(levels_out)
        routes_out.append(
            {
                "id": route_id,
                "title": route.get("title", route_id),
                "theme": route.get("theme", ""),
                "unlockStarsRequired": int(route.get("unlockStarsRequired", 0)),
                "routeRewardId": route.get("routeRewardId", f"reward-{route_id}"),
                "levels": levels_out,
            }
        )

    minimum = int(data.get("minimumReleaseLevels", 200))
    return {
        "schemaVersion": schema,
        "seed": global_seed,
        "minimumReleaseLevels": minimum,
        "totalLevels": total_levels,
        "releaseStockReady": total_levels >= minimum,
        "routes": routes_out,
    }


def write_report(result: dict) -> str:
    lines = [
        "KELİME AVI CONTENT FACTORY RAPORU",
        f"Toplam rota: {len(result['routes'])}",
        f"Toplam bölüm: {result['totalLevels']}",
        f"Minimum yayın stoğu: {result['minimumReleaseLevels']}",
        f"Yayın stoğu hazır: {'EVET' if result['releaseStockReady'] else 'HAYIR'}",
        "",
    ]
    for route in result["routes"]:
        words = sum(len(level["targetWords"]) + len(level["bonusWords"]) for level in route["levels"])
        lines.append(f"- {route['title']} ({route['id']}): {len(route['levels'])} bölüm, {words} hedef+bonus")
    lines.append("")
    lines.append("Tüm üretilen hedef/bonus kelimeler için exact-one occurrence: PASS")
    return "\n".join(lines) + "\n"


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--report", type=Path)
    parser.add_argument("--require-release-stock", action="store_true")
    args = parser.parse_args()

    try:
        data = json.loads(args.input.read_text(encoding="utf-8"))
        result = generate_manifest(data)
        if args.require_release_stock and not result["releaseStockReady"]:
            raise FactoryError(
                f"Yayın stoğu yetersiz: {result['totalLevels']} < {result['minimumReleaseLevels']}"
            )
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        report = write_report(result)
        if args.report:
            args.report.parent.mkdir(parents=True, exist_ok=True)
            args.report.write_text(report, encoding="utf-8")
        sys.stdout.write(report)
        return 0
    except (FactoryError, KeyError, ValueError, json.JSONDecodeError) as exc:
        print(f"CONTENT_FACTORY_FAIL: {exc}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
