from __future__ import annotations

import copy
import importlib.util
import json
import sys
import tempfile
import unittest
from pathlib import Path

COMPILER_PATH = Path(__file__).resolve().parents[1] / "word_hunt_batch_generator.py"
spec = importlib.util.spec_from_file_location("word_hunt_batch_generator", COMPILER_PATH)
assert spec is not None and spec.loader is not None
compiler = importlib.util.module_from_spec(spec)
sys.modules[spec.name] = compiler
spec.loader.exec_module(compiler)


def make_lock() -> compiler.SourceLock:
    routes = []
    for route_id, fingerprint in (
        ("baslangic-limani", "11111111"),
        ("gokyuzu-adalari", "22222222"),
    ):
        words = ["KÖPRÜ", "MÜHÜR"]
        origins = [
            {"word": "KÖPRÜ", "levelId": f"{route_id}-01", "index": 1, "role": "TARGET"},
            {"word": "MÜHÜR", "levelId": f"{route_id}-02", "index": 2, "role": "BONUS"},
        ]
        routes.append(
            {
                "routeId": route_id,
                "contentFingerprint": fingerprint,
                "reservedWordCount": len(words),
                "reservedWords": words,
                "wordOrigins": origins,
            }
        )
    raw = {
        "schemaVersion": 1,
        "lockVersion": "wave8-segment1-test-v1",
        "purpose": "NON-PRODUCTION TEST FIXTURE",
        "wave8ImplementationAuthority": "test-wave8-implementation",
        "wave8FinalIntegrationAuthority": "test-wave8-closure",
        "routes": routes,
    }
    raw["lockDigest"] = compiler.source_lock_payload_digest(raw)
    return compiler.validate_source_lock(raw)


def level(
    index: int,
    *,
    level_id: str | None = None,
    level_type: str = "normal",
    targets: list[str] | None = None,
    bonus: list[str] | None = None,
    seed: int | None = None,
) -> dict:
    result = {
        "id": level_id or f"fixture-{index}",
        "index": index,
        "type": level_type,
        "targetWords": targets if targets is not None else ["KUMRU"],
        "bonusWords": bonus if bonus is not None else [],
        "starRules": {
            "twoStarMaxMistakes": 2,
            "threeStarMaxMistakes": 0,
        },
    }
    if seed is not None:
        result["seed"] = seed
    return result


def manifest(routes: list[dict], seed: int = 20260921) -> dict:
    return {"schemaVersion": 2, "seed": seed, "routes": routes}


def route(route_id: str, levels: list[dict]) -> dict:
    return {"routeId": route_id, "levels": levels}


class ContentCompilerTests(unittest.TestCase):
    def setUp(self) -> None:
        self.lock = make_lock()

    def compile(self, routes: list[dict], seed: int = 20260921) -> dict:
        return compiler.compile_manifest(manifest(routes, seed), self.lock)

    def test_runtime_normalization_parity_and_rejection(self) -> None:
        self.assertEqual(compiler.normalize_runtime_semantics("i"), "İ")
        self.assertEqual(compiler.normalize_runtime_semantics("ı"), "I")
        self.assertEqual(compiler.normalize_word("incir"), "İNCİR")
        self.assertEqual(compiler.normalize_word("ırmak"), "IRMAK")
        self.assertEqual(compiler.normalize_word("  güneş  "), "GÜNEŞ")
        for invalid in ("KUM SAL", "KUM-SAL", "KUM!SAL"):
            with self.subTest(invalid=invalid):
                with self.assertRaises(compiler.FactoryError):
                    compiler.normalize_word(invalid)

    def test_legacy_segment1_lock_may_preserve_runtime_normalized_diacritic(self) -> None:
        raw = copy.deepcopy(self.lock.raw)
        route_lock = raw["routes"][0]
        route_lock["reservedWords"].append("RÜZGÂR")
        route_lock["reservedWords"].sort()
        route_lock["wordOrigins"].append(
            {
                "word": "RÜZGÂR",
                "levelId": "baslangic-limani-legacy",
                "index": 3,
                "role": "TARGET",
            }
        )
        route_lock["wordOrigins"].sort(key=lambda item: item["word"])
        route_lock["reservedWordCount"] = len(route_lock["reservedWords"])
        raw["lockDigest"] = compiler.source_lock_payload_digest(raw)
        validated = compiler.validate_source_lock(raw)
        self.assertIn(
            "RÜZGÂR",
            validated.routes["baslangic-limani"].reserved_words,
        )
        with self.assertRaises(compiler.FactoryError):
            compiler.normalize_word("RÜZGÂR")

    def test_same_input_seed_is_byte_and_report_identical(self) -> None:
        source = [
            route(
                "baslangic-limani",
                [
                    level(11, targets=["KUMRU", "BAMBU", "İNCİR", "VAGON"], bonus=[]),
                    level(20, targets=["KUMSAL", "TURNA"], bonus=["BAVUL"], seed=77),
                ],
            )
        ]
        first = self.compile(source)
        second = self.compile(copy.deepcopy(source))
        self.assertEqual(compiler.pretty_json(first), compiler.pretty_json(second))
        self.assertEqual(compiler.write_report(first), compiler.write_report(second))
        self.assertEqual(first["sourceDigest"], second["sourceDigest"])
        self.assertEqual(
            [item["resolvedSeed"] for item in first["routes"][0]["levels"]],
            [item["resolvedSeed"] for item in second["routes"][0]["levels"]],
        )
        self.assertEqual(
            [item["fingerprint"] for item in first["routes"][0]["levels"]],
            [item["fingerprint"] for item in second["routes"][0]["levels"]],
        )

    def test_route_order_does_not_change_output_or_level_seed_identity(self) -> None:
        first_routes = [
            route("gokyuzu-adalari", [level(11, level_id="sky-11", targets=["KUMRU"])]),
            route("baslangic-limani", [level(11, level_id="start-11", targets=["KUMRU"])]),
        ]
        second_routes = list(reversed(copy.deepcopy(first_routes)))
        first = self.compile(first_routes)
        second = self.compile(second_routes)
        self.assertEqual(compiler.pretty_json(first), compiler.pretty_json(second))
        self.assertEqual(first["sourceDigest"], second["sourceDigest"])

    def test_different_seed_changes_lock_identity_but_remains_valid(self) -> None:
        routes = [route("baslangic-limani", [level(11, targets=["KUMRU"])])]
        first = self.compile(routes, seed=1)
        second = self.compile(routes, seed=2)
        a = first["routes"][0]["levels"][0]
        b = second["routes"][0]["levels"][0]
        self.assertNotEqual(a["resolvedSeed"], b["resolvedSeed"])
        self.assertNotEqual(a["fingerprint"], b["fingerprint"])
        compiler.validate_artifact(first, self.lock)
        compiler.validate_artifact(second, self.lock)

    def test_segment1_collision_matrix(self) -> None:
        cases = [
            ("KÖPRÜ", "TARGET"),
            ("KÖPRÜ", "BONUS"),
            ("MÜHÜR", "TARGET"),
            ("MÜHÜR", "BONUS"),
        ]
        for word, candidate_role in cases:
            with self.subTest(word=word, candidate_role=candidate_role):
                candidate = (
                    level(11, targets=[word])
                    if candidate_role == "TARGET"
                    else level(11, targets=["KUMRU"], bonus=[word])
                )
                with self.assertRaisesRegex(
                    compiler.FactoryError,
                    rf"route=baslangic-limani word={word}",
                ):
                    self.compile([route("baslangic-limani", [candidate])])

    def test_candidate_cross_level_collision_matrix(self) -> None:
        for first_role, second_role in (
            ("TARGET", "TARGET"),
            ("BONUS", "BONUS"),
            ("TARGET", "BONUS"),
            ("BONUS", "TARGET"),
        ):
            with self.subTest(first=first_role, second=second_role):
                collision = "İNCİR"
                first = (
                    level(11, level_id="first", targets=[collision])
                    if first_role == "TARGET"
                    else level(11, level_id="first", targets=["KUMRU"], bonus=[collision])
                )
                second = (
                    level(12, level_id="second", targets=[collision])
                    if second_role == "TARGET"
                    else level(12, level_id="second", targets=["BAMBU"], bonus=[collision])
                )
                with self.assertRaisesRegex(
                    compiler.FactoryError,
                    "existing=candidate first L11",
                ):
                    self.compile([route("baslangic-limani", [first, second])])

    def test_same_word_on_different_routes_is_allowed(self) -> None:
        artifact = self.compile(
            [
                route(
                    "baslangic-limani",
                    [level(11, level_id="start-11", targets=["KUMRU"])],
                ),
                route(
                    "gokyuzu-adalari",
                    [level(11, level_id="sky-11", targets=["KUMRU"])],
                ),
            ]
        )
        self.assertEqual(len(artifact["routes"]), 2)
        compiler.validate_artifact(artifact, self.lock)

    def test_same_level_normalized_target_bonus_collision_fails(self) -> None:
        with self.assertRaisesRegex(compiler.FactoryError, "word=İNCİR"):
            self.compile(
                [
                    route(
                        "baslangic-limani",
                        [level(11, targets=["incir"], bonus=["İNCİR"])],
                    )
                ]
            )

    def test_variable_word_counts_do_not_use_old_five_word_minimum(self) -> None:
        artifact = self.compile(
            [
                route(
                    "baslangic-limani",
                    [
                        level(
                            11,
                            targets=["KUMRU", "BAMBU", "İNCİR", "VAGON"],
                            bonus=[],
                        ),
                        level(
                            12,
                            targets=["KUMSAL"],
                            bonus=["BAVUL", "ÇINAR"],
                        ),
                    ],
                )
            ]
        )
        levels = artifact["routes"][0]["levels"]
        self.assertEqual(
            (len(levels[0]["targetWords"]), len(levels[0]["bonusWords"])),
            (4, 0),
        )
        self.assertEqual(
            (len(levels[1]["targetWords"]), len(levels[1]["bonusWords"])),
            (1, 2),
        )

    def test_grid_exact_one_paths_palindrome_and_reverse_path(self) -> None:
        artifact = self.compile(
            [
                route(
                    "baslangic-limani",
                    [level(11, targets=["KÖK", "KUMRU"], bonus=["BAMBU"])],
                )
            ]
        )
        generated = artifact["routes"][0]["levels"][0]
        self.assertEqual(len(generated["grid"]), 8)
        self.assertTrue(all(len(row) == 8 for row in generated["grid"]))
        for word in generated["targetWords"] + generated["bonusWords"]:
            self.assertEqual(
                compiler.count_occurrences(generated["grid"], word),
                1,
            )
        palindrome = next(
            item for item in generated["placements"] if item["word"] == "KÖK"
        )
        cells = [tuple(cell) for cell in palindrome["cells"]]
        self.assertEqual(
            compiler.canonical_physical_path(cells),
            compiler.canonical_physical_path(list(reversed(cells))),
        )
        kumru = next(
            item for item in generated["placements"] if item["word"] == "KUMRU"
        )
        reversed_read = "".join(
            generated["grid"][row][col]
            for row, col in reversed([tuple(cell) for cell in kumru["cells"]])
        )
        self.assertEqual(reversed_read, "KUMRU"[::-1])

    def test_staged_indexes_and_route_final_contract(self) -> None:
        artifact = self.compile(
            [
                route(
                    "baslangic-limani",
                    [
                        level(11, level_id="l11", targets=["KUMRU"]),
                        level(
                            20,
                            level_id="l20",
                            level_type="challenge",
                            targets=["BAMBU"],
                        ),
                        level(
                            50,
                            level_id="l50",
                            level_type="bonus",
                            targets=["İNCİR"],
                        ),
                        level(90, level_id="l90", targets=["VAGON"]),
                        level(
                            100,
                            level_id="l100",
                            level_type="routeFinal",
                            targets=["ÇINAR"],
                        ),
                    ],
                )
            ]
        )
        self.assertEqual(
            [item["index"] for item in artifact["routes"][0]["levels"]],
            [11, 20, 50, 90, 100],
        )
        for bad in (
            level(10, level_id="bad10", targets=["KUMRU"]),
            level(101, level_id="bad101", targets=["KUMRU"]),
            level(
                20,
                level_id="bad20",
                level_type="routeFinal",
                targets=["KUMRU"],
            ),
            level(
                100,
                level_id="bad100",
                level_type="normal",
                targets=["KUMRU"],
            ),
        ):
            with self.subTest(index=bad["index"], type=bad["type"]):
                with self.assertRaises(compiler.FactoryError):
                    self.compile([route("baslangic-limani", [bad])])

    def test_source_lock_drift_fails_closed(self) -> None:
        base = copy.deepcopy(self.lock.raw)
        mutations = []
        changed_fingerprint = copy.deepcopy(base)
        changed_fingerprint["routes"][0]["contentFingerprint"] = "abcdef12"
        mutations.append(changed_fingerprint)
        changed_word = copy.deepcopy(base)
        changed_word["routes"][0]["reservedWords"][0] = "KUMRU"
        mutations.append(changed_word)
        changed_count = copy.deepcopy(base)
        changed_count["routes"][0]["reservedWordCount"] += 1
        mutations.append(changed_count)
        for changed in mutations:
            with self.subTest(changed=changed["routes"][0]):
                with self.assertRaisesRegex(
                    compiler.FactoryError,
                    "digest mismatch",
                ):
                    compiler.validate_source_lock(changed)

    def test_output_grid_and_target_tamper_fail_validation(self) -> None:
        artifact = self.compile(
            [route("baslangic-limani", [level(11, targets=["KUMRU"])])]
        )
        grid_tamper = copy.deepcopy(artifact)
        row = grid_tamper["routes"][0]["levels"][0]["grid"][0]
        grid_tamper["routes"][0]["levels"][0]["grid"][0] = (
            ("A" if row[0] != "A" else "B") + row[1:]
        )
        with self.assertRaises(compiler.FactoryError):
            compiler.validate_artifact(grid_tamper, self.lock)

        target_tamper = copy.deepcopy(artifact)
        target_tamper["routes"][0]["levels"][0]["targetWords"][0] = "BAMBU"
        with self.assertRaisesRegex(
            compiler.FactoryError,
            "sourceDigest mismatch",
        ):
            compiler.validate_artifact(target_tamper, self.lock)

    def test_recompile_contract_and_explicit_seed(self) -> None:
        source = [
            route(
                "baslangic-limani",
                [level(11, targets=["KUMRU"], seed=123456)],
            )
        ]
        first = self.compile(source)
        second = self.compile(source)
        a = first["routes"][0]["levels"][0]
        b = second["routes"][0]["levels"][0]
        self.assertEqual(a["resolvedSeed"], 123456)
        self.assertEqual(a["grid"], b["grid"])
        self.assertEqual(a["fingerprint"], b["fingerprint"])

    def test_fail_closed_source_shape(self) -> None:
        cases = [
            {"schemaVersion": 99, "seed": 1, "routes": []},
            manifest([route("unknown-route", [level(11)])]),
            manifest([{"routeId": "baslangic-limani", "levels": []}]),
            manifest(
                [route("baslangic-limani", [{**level(11), "id": ""}])]
            ),
            manifest(
                [
                    route(
                        "baslangic-limani",
                        [level(11), level(11, level_id="other")],
                    )
                ]
            ),
            manifest(
                [
                    route(
                        "baslangic-limani",
                        [{**level(11), "targetWords": []}],
                    )
                ]
            ),
            manifest(
                [
                    route(
                        "baslangic-limani",
                        [{**level(11), "timeLimitSeconds": 0}],
                    )
                ]
            ),
            manifest(
                [
                    route(
                        "baslangic-limani",
                        [{**level(11), "infoCardIds": "bad"}],
                    )
                ]
            ),
            manifest(
                [
                    route(
                        "baslangic-limani",
                        [{**level(11), "starRules": []}],
                    )
                ]
            ),
        ]
        for source in cases:
            with self.subTest(source=source):
                with self.assertRaises(compiler.FactoryError):
                    compiler.compile_manifest(source, self.lock)

    def test_cli_deterministic_bytes_and_validation_mode(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            lock_path = root / "lock.json"
            manifest_path = root / "manifest.json"
            out_a = root / "a.json"
            out_b = root / "b.json"
            report_a = root / "a.txt"
            report_b = root / "b.txt"
            lock_path.write_text(
                compiler.pretty_json(self.lock.raw),
                encoding="utf-8",
            )
            manifest_path.write_text(
                compiler.pretty_json(
                    manifest(
                        [
                            route(
                                "baslangic-limani",
                                [level(11, targets=["KUMRU"])],
                            )
                        ]
                    )
                ),
                encoding="utf-8",
            )
            old_argv = compiler.sys.argv
            try:
                compiler.sys.argv = [
                    "compiler",
                    "--legacy-v1-mode",
                    "--input",
                    str(manifest_path),
                    "--source-lock",
                    str(lock_path),
                    "--output",
                    str(out_a),
                    "--report",
                    str(report_a),
                ]
                self.assertEqual(compiler.main(), 0)
                compiler.sys.argv = [
                    "compiler",
                    "--legacy-v1-mode",
                    "--input",
                    str(manifest_path),
                    "--source-lock",
                    str(lock_path),
                    "--output",
                    str(out_b),
                    "--report",
                    str(report_b),
                ]
                self.assertEqual(compiler.main(), 0)
                self.assertEqual(out_a.read_bytes(), out_b.read_bytes())
                self.assertEqual(report_a.read_bytes(), report_b.read_bytes())
                compiler.sys.argv = [
                    "compiler",
                    "--legacy-v1-mode",
                    "--validate",
                    str(out_a),
                    "--source-lock",
                    str(lock_path),
                ]
                self.assertEqual(compiler.main(), 0)
            finally:
                compiler.sys.argv = old_argv


PRODUCTION_CORPUS_PATH = Path(__file__).resolve().parents[1] / (
    "word_hunt_production_corpus.lock.json"
)
LEGACY_SOURCE_LOCK_PATH = Path(__file__).resolve().parents[1] / (
    "word_hunt_segment1_source_lock.json"
)
LEGACY_WAVE10A_EVIDENCE_PATH = Path(__file__).resolve().parents[1] / (
    "word_hunt_wave10a_baslangic_segment2.lock.json"
)


class ContentCompilerV2Tests(unittest.TestCase):
    def setUp(self) -> None:
        self.corpus = compiler.load_production_corpus_lock(
            PRODUCTION_CORPUS_PATH
        )

    def candidate_levels(self) -> list[dict]:
        return [
            level(
                31,
                level_id="candidate-31",
                targets=["LAVANTA", "YELPAZE"],
                bonus=["CEYLAN"],
            ),
            level(
                32,
                level_id="candidate-32",
                targets=["DÜDÜK", "ZAMBAK"],
                bonus=["KAZMA"],
            ),
        ]

    def compile(
        self,
        levels: list[dict] | None = None,
        *,
        corpus: compiler.ProductionCorpusLock | None = None,
        seed: int = 20260922,
    ) -> dict:
        return compiler.compile_manifest_v2(
            manifest(
                [
                    route(
                        "baslangic-limani",
                        levels if levels is not None else self.candidate_levels(),
                    )
                ],
                seed,
            ),
            corpus or self.corpus,
        )

    def test_current_production_corpus_lock_shape_and_digest(self) -> None:
        self.assertEqual(self.corpus.route_order[0], "baslangic-limani")
        self.assertEqual(len(self.corpus.routes), 8)
        self.assertEqual(
            sum(
                route.available_level_count
                for route in self.corpus.routes.values()
            ),
            100,
        )
        self.assertEqual(
            self.corpus.source_digest,
            compiler.production_corpus_payload_digest(self.corpus.raw),
        )

        starter = self.corpus.routes["baslangic-limani"]
        self.assertEqual(starter.available_level_count, 30)
        self.assertEqual(starter.planned_level_count, 100)
        self.assertEqual(len(starter.reserved_words), 196)

    def test_wave10a_l11_to_l20_is_current_reserved_corpus(self) -> None:
        starter = self.corpus.routes["baslangic-limani"]
        self.assertEqual(starter.origins["BARDAK"]["localIndex"], 11)
        self.assertEqual(starter.origins["FİDAN"]["localIndex"], 11)
        self.assertEqual(starter.origins["MANDAL"]["localIndex"], 20)
        self.assertEqual(starter.origins["ŞEMSİYE"]["localIndex"], 20)

    def test_v2_same_input_is_byte_deterministic(self) -> None:
        first = self.compile()
        second = self.compile()
        self.assertEqual(compiler.pretty_json(first), compiler.pretty_json(second))
        self.assertEqual(first["compilerVersion"], "ka02-v2")
        self.assertEqual(first["artifactSchemaVersion"], 2)
        self.assertEqual(
            first["productionCorpusLock"],
            {
                "schemaVersion": 1,
                "sourceDigest": self.corpus.source_digest,
            },
        )

    def test_current_production_duplicate_word_fails(self) -> None:
        with self.assertRaisesRegex(
            compiler.FactoryError,
            r"route=baslangic-limani word=BARDAK.*existing=production",
        ):
            self.compile(
                [
                    level(
                        31,
                        level_id="duplicate-current",
                        targets=["BARDAK"],
                    )
                ]
            )

    def test_same_candidate_batch_duplicate_fails(self) -> None:
        with self.assertRaisesRegex(
            compiler.FactoryError,
            r"word=LAVANTA.*existing=candidate candidate-31 L31",
        ):
            self.compile(
                [
                    level(
                        31,
                        level_id="candidate-31",
                        targets=["LAVANTA"],
                    ),
                    level(
                        32,
                        level_id="candidate-32",
                        targets=["LAVANTA"],
                    ),
                ]
            )

    def test_existing_index_overwrite_fails(self) -> None:
        with self.assertRaisesRegex(
            compiler.FactoryError,
            "existing localIndex overwrite",
        ):
            self.compile(
                [level(20, level_id="overwrite-20", targets=["LAVANTA"])]
            )

    def test_gap_or_wrong_frontier_fails(self) -> None:
        with self.assertRaisesRegex(
            compiler.FactoryError,
            "contiguous append",
        ):
            self.compile(
                [level(32, level_id="gap-32", targets=["LAVANTA"])]
            )

    def test_contiguous_append_passes(self) -> None:
        artifact = self.compile()
        self.assertEqual(
            [level["index"] for level in artifact["routes"][0]["levels"]],
            [31, 32],
        )
        compiler.validate_artifact_v2(artifact, self.corpus)

    def test_planned_level_count_overflow_fails(self) -> None:
        raw = copy.deepcopy(self.corpus.raw)
        starter = next(
            route
            for route in raw["routes"]
            if route["routeId"] == "baslangic-limani"
        )
        starter["plannedLevelCount"] = 30
        raw["sourceDigest"] = compiler.production_corpus_payload_digest(raw)
        capped = compiler.validate_production_corpus_lock(raw)

        with self.assertRaisesRegex(
            compiler.FactoryError,
            "plannedLevelCount aşar",
        ):
            self.compile(
                [level(31, level_id="past-plan", targets=["LAVANTA"])],
                corpus=capped,
            )

    def test_route_final_remains_forbidden_before_l100(self) -> None:
        with self.assertRaisesRegex(
            compiler.FactoryError,
            "routeFinal forbidden before L100",
        ):
            self.compile(
                [
                    level(
                        31,
                        level_id="false-final",
                        level_type="routeFinal",
                        targets=["LAVANTA"],
                    )
                ]
            )

    def test_corpus_digest_participates_in_v2_candidate_identity(self) -> None:
        first = self.compile()
        raw = copy.deepcopy(self.corpus.raw)
        starter = next(
            route
            for route in raw["routes"]
            if route["routeId"] == "baslangic-limani"
        )
        starter["plannedLevelCount"] = 99
        raw["sourceDigest"] = compiler.production_corpus_payload_digest(raw)
        changed_corpus = compiler.validate_production_corpus_lock(raw)
        second = self.compile(corpus=changed_corpus)

        self.assertNotEqual(
            first["productionCorpusLock"]["sourceDigest"],
            second["productionCorpusLock"]["sourceDigest"],
        )
        self.assertNotEqual(first["sourceDigest"], second["sourceDigest"])

    def test_legacy_wave10a_v1_evidence_remains_read_only_valid(self) -> None:
        legacy_lock = compiler.load_source_lock(LEGACY_SOURCE_LOCK_PATH)
        evidence = json.loads(
            LEGACY_WAVE10A_EVIDENCE_PATH.read_text(encoding="utf-8")
        )
        validated = compiler.validate_legacy_v1_evidence(
            evidence,
            legacy_lock,
        )
        self.assertEqual(validated["compilerVersion"], "ka02-v1")
        self.assertEqual(validated["routeId"], "baslangic-limani")
        self.assertEqual(len(validated["levels"]), 10)

    def test_production_grid_runtime_diacritic_is_separate_from_candidate_alphabet(self) -> None:
        self.assertNotIn("Â", compiler.ALPHABET)
        self.assertIn("Â", compiler.PRODUCTION_GRID_ALPHABET)
        self.assertEqual(
            compiler.normalize_runtime_semantics("rüzgâr"),
            "RÜZGÂR",
        )

        kayip = self.corpus.routes["kayip-sehir"]
        level2 = next(
            level
            for level in kayip.levels
            if level["levelId"] == "kayip-sehir-02"
        )
        self.assertIn("Â", "".join(level2["grid"]))

        with self.assertRaises(compiler.FactoryError):
            compiler.normalize_word("RÜZGÂR")

    def test_v2_turkish_normalization_parity(self) -> None:
        self.assertEqual(compiler.normalize_runtime_semantics("i"), "İ")
        self.assertEqual(compiler.normalize_runtime_semantics("ı"), "I")
        self.assertEqual(compiler.normalize_runtime_semantics("İ"), "İ")
        self.assertEqual(compiler.normalize_runtime_semantics("I"), "I")


if __name__ == "__main__":
    unittest.main()
