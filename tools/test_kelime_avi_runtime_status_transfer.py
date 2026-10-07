"""Exercise the workflow's actual commands in separate shells; no Android proof."""

from pathlib import Path
import os
import shutil
import subprocess
import tempfile
import unittest


WORKFLOW = Path(__file__).resolve().parents[1] / ".github/workflows/kelime_avi_standalone_runtime_proof.yml"


def block_after(text, marker, indent):
    lines = text.split(marker, 1)[1].splitlines()
    result = []
    for line in lines:
        if not line.strip():
            continue
        if not line.startswith(" " * indent):
            break
        result.append(line[indent:])
    return "\n".join(result)


class RuntimeStatusTransferTest(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory(prefix="harbor-status-test-")
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        self.reports = self.root / "reports/kelime_avi_runtime"
        self.reports.mkdir(parents=True)
        self.bin = self.root / "bin"
        self.bin.mkdir()
        stub = self.bin / "python3"
        stub.write_text(
            '#!/bin/sh\n'
            'case "$1" in\n'
            '  *kelime_avi_journey_runtime_probe.py) echo journey >> probe_calls; exit "$JOURNEY_CODE" ;;\n'
            '  *kelime_avi_android_runtime_probe.py) echo standard >> probe_calls; exit "$STANDARD_CODE" ;;\n'
            '  *kelime_avi_harbor_runtime_probe.py) echo harbor >> probe_calls; exit "$HARBOR_CODE" ;;\n'
            '  *) exit 99 ;;\n'
            'esac\n', encoding="utf-8"
        )
        stub.chmod(0o755)
        apk = self.root / "apps/kelime_avi_standalone/build/app/outputs/flutter-apk/app-debug.apk"
        apk.parent.mkdir(parents=True)
        apk.write_bytes(b"synthetic debug APK placeholder")
        standard = self.root / "runner-temp/harbor-standard/app-debug.apk"
        standard.parent.mkdir(parents=True)
        standard.write_bytes(b"synthetic standard APK placeholder")
        for name in ("legacy-rollback", "harbor-proof"):
            copy = self.root / f"runner-temp/{name}/app-debug.apk"
            copy.parent.mkdir(parents=True)
            copy.write_bytes(b"synthetic isolated APK placeholder")
        self.env = dict(os.environ, RUNNER_TEMP="runner-temp", STANDARD_CODE="0", HARBOR_CODE="0",
                        PROOF_SOURCE_SHA="synthetic-test-sha", JOURNEY_CODE="0",
                        HEAD_BRANCH="feat/kelime-avi-checkpoint-c-fener-burnu")
        self.env["PATH"] = str(self.bin) + os.pathsep + self.env.get("PATH", "")
        self.sh = shutil.which("sh")
        self.bash = shutil.which("bash")
        if not self.sh or not self.bash:
            raise RuntimeError("Both sh and bash are required for real shell regression tests")
        text = WORKFLOW.read_text(encoding="utf-8")
        self.commands = block_after(text, "          script: |\n", 12).splitlines()
        self.gate = block_after(text.split("      - name: Harbor proof sonucunu", 1)[1], "        run: |\n", 10)
        self.gate = self.gate.replace("${{ steps.harbor_runtime.outcome }}", "success")
        (self.reports / "HARBOR_RESULT.json").write_text('{"synthetic":true}', encoding="utf-8")
        (self.reports / "HARBOR_RESULT.txt").write_text(
            "RESULT=PASS\nSOURCE_SHA=synthetic-test-sha\nCAPTURE_COUNT=10\n", encoding="utf-8")
        for viewport in ("360x800", "412x915"):
            for scenario in ("mixed", "l20_playable", "segment3", "segment4_mixed", "l40_playable"):
                for suffix in ("png", "xml"):
                    (self.reports / f"harbor_{viewport}_{scenario}.{suffix}").write_bytes(b"synthetic test only")

    def shell(self, command, bash=False):
        return subprocess.run([self.bash if bash else self.sh, "-c", command], cwd=self.root,
                              env=self.env, capture_output=True, text=True)

    def run_probes(self, standard=0, harbor=0, omit=None):
        self.env.update(STANDARD_CODE=str(standard), HARBOR_CODE=str(harbor))
        for command in self.commands:
            if omit and f"tools/kelime_avi_{omit}_runtime_probe.py" in command:
                continue
            result = self.shell(command)
            if result.returncode:
                return result
        return result

    def test_old_separate_shell_variables_reproduce_failure(self):
        self.assertEqual(self.shell("standard_status=0").returncode, 0)
        self.assertNotEqual(self.shell('test "$standard_status" -eq 0').returncode, 0)

    def test_both_success_codes_survive_separate_shells_and_final_gate(self):
        self.assertEqual(self.run_probes().returncode, 0)
        self.assertEqual((self.root / "probe_calls").read_text().splitlines(), ["standard", "harbor"])
        for probe in ("STANDARD", "HARBOR"):
            self.assertEqual((self.reports / f"{probe}_PROBE_EXIT_CODE.txt").read_bytes(), b"0\n")
        self.assertEqual(self.shell(self.gate, bash=True).returncode, 0)

    def test_either_failure_is_preserved_and_both_probes_still_run(self):
        for standard, harbor in ((1, 0), (0, 2), (7, 9), (127, 0)):
            with self.subTest(standard=standard, harbor=harbor):
                self.assertNotEqual(self.run_probes(standard, harbor).returncode, 0)
                self.assertNotEqual(self.shell(self.gate, bash=True).returncode, 0)
                self.assertEqual((self.reports / "STANDARD_PROBE_EXIT_CODE.txt").read_bytes(), f"{standard}\n".encode())
                self.assertEqual((self.reports / "HARBOR_PROBE_EXIT_CODE.txt").read_bytes(), f"{harbor}\n".encode())
        self.assertEqual((self.root / "probe_calls").read_text().splitlines(), ["standard", "harbor"] * 4)

    def test_unexecuted_probe_cannot_reuse_stale_success(self):
        for omit in ("android", "harbor"):
            with self.subTest(omit=omit):
                self.assertEqual(self.run_probes().returncode, 0)
                self.assertNotEqual(self.run_probes(omit=omit).returncode, 0)
                self.assertNotEqual(self.shell(self.gate, bash=True).returncode, 0)

    def test_missing_status_fails_final_gate(self):
        for probe in ("STANDARD", "HARBOR"):
            self.run_probes()
            (self.reports / f"{probe}_PROBE_EXIT_CODE.txt").unlink()
            self.assertNotEqual(self.shell(self.gate, bash=True).returncode, 0)

    def test_empty_invalid_or_nonzero_status_fails_both_gates(self):
        for probe in ("STANDARD", "HARBOR"):
            for value in (b"", b"abc\n", b"1\n", b"256\n", b"0", b"00\n", b"0\n0\n", b"0\x00\n"):
                with self.subTest(probe=probe, value=value):
                    self.run_probes()
                    (self.reports / f"{probe}_PROBE_EXIT_CODE.txt").write_bytes(value)
                    self.assertNotEqual(self.shell(self.commands[-1]).returncode, 0)
                    self.assertNotEqual(self.shell(self.gate, bash=True).returncode, 0)

    def test_runtime_failure_is_not_hidden_by_success_status_files(self):
        self.run_probes()
        self.assertNotEqual(self.shell(self.gate.replace('test "success"', 'test "failure"'), bash=True).returncode, 0)

    def test_harbor_result_failure_and_missing_capture_remain_fail_closed(self):
        self.run_probes()
        result = self.reports / "HARBOR_RESULT.txt"
        original = result.read_text()
        result.write_text(original.replace("RESULT=PASS", "RESULT=FAIL"))
        self.assertNotEqual(self.shell(self.gate, bash=True).returncode, 0)
        result.write_text(original)
        for suffix in ("png", "xml"):
            capture = self.reports / f"harbor_412x915_segment3.{suffix}"
            original_bytes = capture.read_bytes()
            capture.unlink()
            self.assertNotEqual(self.shell(self.gate, bash=True).returncode, 0)
            capture.write_bytes(original_bytes)

    def test_journey_three_authorities_and_each_failure_remain_fail_closed(self):
        self.env["HEAD_BRANCH"] = "feat/kelime-avi-infinite-journey-v1-slice1"
        for journey, legacy, harbor in ((0, 0, 0), (1, 0, 0), (0, 2, 0), (0, 0, 3)):
            with self.subTest(journey=journey, legacy=legacy, harbor=harbor):
                self.env["JOURNEY_CODE"] = str(journey)
                result = self.run_probes(legacy, harbor)
                self.assertEqual(result.returncode == 0, journey == legacy == harbor == 0)
                self.assertEqual(self.shell(self.gate, bash=True).returncode == 0,
                                 journey == legacy == harbor == 0)
                for name, value in (("DEFAULT_JOURNEY", journey),
                                    ("LEGACY_ROLLBACK", legacy), ("HARBOR", harbor)):
                    self.assertEqual((self.reports / f"{name}_PROBE_EXIT_CODE.txt").read_bytes(),
                                     f"{value}\n".encode())
        self.assertEqual((self.root / "probe_calls").read_text().splitlines(),
                         ["journey", "standard", "harbor"] * 4)

    def test_journey_missing_invalid_or_unexecuted_status_is_not_pass(self):
        self.env["HEAD_BRANCH"] = "feat/kelime-avi-infinite-journey-v1-slice1"
        for probe in ("DEFAULT_JOURNEY", "LEGACY_ROLLBACK"):
            for value in (None, b"", b"abc\n", b"1\n", b"0", b"00\n", b"0\n0\n"):
                self.run_probes()
                status = self.reports / f"{probe}_PROBE_EXIT_CODE.txt"
                if value is None:
                    status.unlink()
                else:
                    status.write_bytes(value)
                self.assertNotEqual(self.shell(self.commands[-1]).returncode, 0)
                self.assertNotEqual(self.shell(self.gate, bash=True).returncode, 0)
        for omit in ("journey", "android"):
            self.run_probes()
            self.assertNotEqual(self.run_probes(omit=omit).returncode, 0)
            self.assertNotEqual(self.shell(self.gate, bash=True).returncode, 0)


if __name__ == "__main__":
    unittest.main()
