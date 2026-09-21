from __future__ import annotations

import copy
import importlib.util
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
                    "--validate",
                    str(out_a),
                    "--source-lock",
                    str(lock_path),
                ]
                self.assertEqual(compiler.main(), 0)
            finally:
                compiler.sys.argv = old_argv


if __name__ == "__main__":
    unittest.main()
