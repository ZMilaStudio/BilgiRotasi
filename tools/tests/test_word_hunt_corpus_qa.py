from __future__ import annotations

import copy
import unittest
from unittest import mock

from tools import word_hunt_corpus_qa as qa
from tools.word_hunt_batch_generator import (
    FactoryError,
    production_corpus_payload_digest,
    production_level_fingerprint,
    validate_production_corpus_lock,
)


def _grid(*words: str) -> list[str]:
    rows = []
    for word in words:
        rows.append(word + "A" * (8 - len(word)))
    while len(rows) < 8:
        rows.append("AAAAAAAA")
    return rows[:8]


def _level(index: int, level_id: str, word: str, grid: list[str] | None = None) -> dict:
    rows = grid or _grid(word)
    level = {
        "localIndex": index,
        "levelId": level_id,
        "type": "normal",
        "grid": rows,
        "targetWords": [word],
        "bonusWords": [],
        "starRules": {
            "twoStarMaxMistakes": 2,
            "threeStarMaxMistakes": 0,
            "twoStarMaxSeconds": None,
            "threeStarMaxSeconds": None,
        },
        "timeLimitSeconds": None,
        "gridHash": qa.sha256_text("\n".join(rows)),
    }
    level["levelFingerprint"] = production_level_fingerprint(level)
    return level


def _route(route_id: str, levels: list[dict], planned: int | None = None) -> dict:
    origins = []
    for level in levels:
        for role, words in (("TARGET", level["targetWords"]), ("BONUS", level["bonusWords"])):
            for word in words:
                origins.append(
                    {
                        "word": word,
                        "levelId": level["levelId"],
                        "localIndex": level["localIndex"],
                        "role": role,
                    }
                )
    origins.sort(key=lambda item: item["word"])
    reserved = [item["word"] for item in origins]
    return {
        "routeId": route_id,
        "availableLevelCount": len(levels),
        "plannedLevelCount": planned or len(levels),
        "reservedWordCount": len(reserved),
        "reservedWords": reserved,
        "wordOrigins": origins,
        "levels": levels,
    }


def _corpus(routes: list[dict]):
    raw = {
        "schemaVersion": 1,
        "kind": "WORD_HUNT_PRODUCTION_CORPUS_LOCK",
        "generatedBy": "tools/word_hunt_corpus_support.dart",
        "routeOrder": [route["routeId"] for route in routes],
        "routes": routes,
    }
    raw["sourceDigest"] = production_corpus_payload_digest(raw)
    return validate_production_corpus_lock(raw)


def _metric(index: int, level_id: str | None = None) -> dict:
    return {
        "routeId": "baslangic-limani",
        "levelId": level_id or f"level-{index}",
        "localIndex": index,
        "source": "production",
        "targetCount": 1,
        "bonusCount": 0,
        "totalWordCount": 1,
        "starRules": {},
        "timeLimitSeconds": None,
        "gridHash": f"grid-{index}",
        "levelFingerprint": f"fp-{index}",
        "occupiedCells": [index],
        "occupiedCellCount": 1,
        "directionDistribution": {name: 0 for name in qa.DIRECTION_NAMES},
        "pathCount": 1,
        "overlapDensity": 0.0,
        "wordLengthSummary": {
            "count": 1,
            "min": 5,
            "max": 5,
            "median": 5,
            "buckets": {"3-4": 0, "5-6": 1, "7-8": 0, "9+": 0},
        },
    }


class WordHuntCorpusQaTest(unittest.TestCase):
    def setUp(self) -> None:
        self.corpus = _corpus(
            [
                _route(
                    "baslangic-limani",
                    [_level(1, "baslangic-1", "KALEM")],
                    planned=10,
                )
            ]
        )

    def test_same_input_same_json_bytes(self) -> None:
        first = qa.pretty_json(qa.build_report(self.corpus))
        second = qa.pretty_json(qa.build_report(self.corpus))
        self.assertEqual(first.encode(), second.encode())

    def test_same_input_same_markdown_bytes(self) -> None:
        first = qa.render_markdown(qa.build_report(self.corpus))
        second = qa.render_markdown(qa.build_report(self.corpus))
        self.assertEqual(first.encode(), second.encode())

    def test_exact_grid_duplicate_detected(self) -> None:
        shared = _grid("KALEM", "BULUT")
        corpus = _corpus(
            [
                _route("baslangic-limani", [_level(1, "a-1", "KALEM", shared)]),
                _route("gokyuzu-adalari", [_level(1, "b-1", "BULUT", shared)]),
            ]
        )
        report = qa.build_report(corpus)
        self.assertEqual(report["summary"]["exactGridDuplicateGroupCount"], 1)
        self.assertTrue(
            any(flag["id"] == "EXACT_GRID_DUPLICATE" for flag in report["riskFlags"])
        )

    def test_normalized_word_reuse_detected(self) -> None:
        corpus = _corpus(
            [
                _route("baslangic-limani", [_level(1, "a-1", "KALEM")]),
                _route("gokyuzu-adalari", [_level(1, "b-1", "KALEM")]),
            ]
        )
        report = qa.build_report(corpus)
        entry = next(item for item in report["wordFrequencies"] if item["word"] == "KALEM")
        self.assertEqual(entry["wholeGameFrequency"], 2)
        self.assertEqual(entry["routeFrequency"], 2)

    def test_target_bonus_pair_canonicalization(self) -> None:
        self.assertEqual(
            qa.canonical_word_pair("BONUS", "KİRAZ", "TARGET", "ELMA"),
            ("TARGET:ELMA", "BONUS:KİRAZ", "TARGET_BONUS"),
        )

    def test_deterministic_physical_path_resolution(self) -> None:
        path = qa.resolve_physical_path(_grid("KALEM", "KALEM"), "KALEM")
        self.assertIsNotNone(path)
        assert path is not None
        self.assertEqual((path.start_row, path.start_column, path.direction), (0, 0, "E"))
        self.assertEqual(path.cells, (0, 1, 2, 3, 4))

    def test_structural_jaccard_known_fixture(self) -> None:
        self.assertAlmostEqual(qa.structural_jaccard({1, 2, 3}, {2, 3, 4}), 0.5)

    def test_overlap_density_known_fixture(self) -> None:
        paths = [
            qa.ResolvedPath("AAA", (0, 1, 2), "E", 0, 0),
            qa.ResolvedPath("BBB", (2, 3, 4), "E", 0, 2),
        ]
        self.assertAlmostEqual(qa.overlap_density(paths), 1 / 6)

    def test_direction_distribution(self) -> None:
        paths = [
            qa.ResolvedPath("AAA", (0, 1, 2), "E", 0, 0),
            qa.ResolvedPath("BBB", (0, 8, 16), "S", 0, 0),
            qa.ResolvedPath("CCC", (1, 2, 3), "E", 0, 1),
        ]
        result = qa.direction_distribution(paths)
        self.assertEqual(result["E"], 2)
        self.assertEqual(result["S"], 1)
        self.assertEqual(sum(result.values()), 3)

    def test_word_length_aggregation(self) -> None:
        result = qa.word_length_summary(["DAL", "KALEM", "MERDİVEN", "BULUT"])
        self.assertEqual(result["min"], 3)
        self.assertEqual(result["max"], 8)
        self.assertEqual(result["median"], 5)
        self.assertEqual(result["buckets"], {"3-4": 1, "5-6": 2, "7-8": 1, "9+": 0})

    def test_hard_risk_and_warning_are_separate(self) -> None:
        shared = _grid("KALEM", "BULUT")
        corpus = _corpus(
            [
                _route("baslangic-limani", [_level(1, "a-1", "KALEM", shared)]),
                _route("gokyuzu-adalari", [_level(1, "b-1", "BULUT", shared)]),
                _route("orman-yolu", [_level(1, "c-1", "KALEM")]),
            ]
        )
        report = qa.build_report(corpus)
        self.assertGreater(report["summary"]["hardRiskCount"], 0)
        self.assertGreater(report["summary"]["warningCount"], 0)

    def test_review_queue_deduplicates_levels(self) -> None:
        metrics = [_metric(index) for index in range(1, 11)]
        queue = qa.select_review_queue(
            metrics, [], [], ["baslangic-limani"], {"baslangic-limani": 20}
        )
        ids = [item["levelId"] for item in queue]
        self.assertEqual(len(ids), len(set(ids)))

    def test_segment_start_end_and_lower_median_selection(self) -> None:
        metrics = [_metric(index) for index in range(1, 11)]
        queue = qa.select_review_queue(
            metrics, [], [], ["baslangic-limani"], {"baslangic-limani": 20}
        )
        reasons = {
            item["levelId"]: {reason["id"] for reason in item["reviewReasons"]}
            for item in queue
        }
        self.assertIn("SEGMENT_START", reasons["level-1"])
        self.assertIn("REPRESENTATIVE_MEDIAN", reasons["level-5"])
        self.assertIn("SEGMENT_BOUNDARY", reasons["level-10"])
        self.assertIn("CONTENT_FRONTIER", reasons["level-10"])

    def test_highest_risk_level_is_included(self) -> None:
        metrics = [_metric(index) for index in range(1, 11)]
        flags = [
            {
                "severity": "WARNING",
                "id": "WORD_REUSE",
                "routeId": "baslangic-limani",
                "levelId": "level-7",
                "localIndex": 7,
                "source": "production",
                "evidence": {"word": "KALEM"},
            }
        ]
        queue = qa.select_review_queue(
            metrics, flags, [], ["baslangic-limani"], {"baslangic-limani": 20}
        )
        seven = next(item for item in queue if item["levelId"] == "level-7")
        self.assertIn("HIGHEST_RISK", {r["id"] for r in seven["reviewReasons"]})

    def test_all_flagged_levels_are_included(self) -> None:
        metrics = [_metric(index) for index in range(1, 11)]
        flags = []
        for index in (3, 8):
            flags.append(
                {
                    "severity": "WARNING",
                    "id": "WORD_REUSE",
                    "routeId": "baslangic-limani",
                    "levelId": f"level-{index}",
                    "localIndex": index,
                    "source": "production",
                    "evidence": {"word": f"WORD{index}"},
                }
            )
        queue = qa.select_review_queue(
            metrics, flags, [], ["baslangic-limani"], {"baslangic-limani": 20}
        )
        ids = {item["levelId"] for item in queue}
        self.assertTrue({"level-3", "level-8"}.issubset(ids))

    def test_candidate_optional_mode(self) -> None:
        candidate = {
            "sourceDigest": "a" * 64,
            "routes": [
                {
                    "routeId": "baslangic-limani",
                    "levels": [
                        {
                            "id": "candidate-2",
                            "routeId": "baslangic-limani",
                            "index": 2,
                            "grid": _grid("BULUT"),
                            "targetWords": ["BULUT"],
                            "bonusWords": [],
                            "starRules": {
                                "twoStarMaxMistakes": 2,
                                "threeStarMaxMistakes": 0,
                                "twoStarMaxSeconds": None,
                                "threeStarMaxSeconds": None,
                            },
                            "timeLimitSeconds": None,
                            "fingerprint": "b" * 64,
                        }
                    ],
                }
            ],
        }
        with mock.patch.object(qa, "validate_artifact_v2") as validator:
            report = qa.build_report(self.corpus, candidate)
        validator.assert_called_once()
        self.assertEqual(report["candidateDigest"], "a" * 64)
        self.assertEqual(report["candidateLevelCount"], 1)
        self.assertEqual(report["levelCount"], 2)

    def test_corpus_digest_propagated(self) -> None:
        report = qa.build_report(self.corpus)
        self.assertEqual(report["productionCorpusDigest"], self.corpus.source_digest)

    def test_malformed_corpus_hard_fails_validation(self) -> None:
        raw = copy.deepcopy(self.corpus.raw)
        raw["routes"][0]["levels"][0]["gridHash"] = "0" * 64
        raw["sourceDigest"] = production_corpus_payload_digest(raw)
        with self.assertRaises(FactoryError):
            validate_production_corpus_lock(raw)

    def test_turkish_normalization_regression(self) -> None:
        self.assertEqual(qa.normalize_runtime_semantics("çiğ"), "ÇİĞ")
        self.assertEqual(qa.normalize_runtime_semantics("ışık"), "IŞIK")
        self.assertEqual(qa.normalize_runtime_semantics("İNCİR"), "İNCİR")


if __name__ == "__main__":
    unittest.main()
