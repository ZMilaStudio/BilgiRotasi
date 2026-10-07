from pathlib import Path
import unittest
from admob_signed_build_policy import authorized, PUSH_REFS, REPOSITORY


class SigningPolicyTest(unittest.TestCase):
    def test_matrix(self):
        for ref in PUSH_REFS:
            self.assertTrue(authorized(REPOSITORY, "push", ref))
        for repo, event, ref in [
            (REPOSITORY, "push", "refs/heads/arbitrary"),
            (REPOSITORY, "pull_request", "refs/pull/230/merge"),
            (REPOSITORY, "pull_request", "refs/pull/229/merge"),
            (REPOSITORY, "pull_request", "refs/heads/arbitrary"),
            ("fork/BilgiRotasi", "pull_request", "refs/pull/230/merge"),
            (REPOSITORY, "workflow_dispatch", next(iter(PUSH_REFS))),
            ("other/repo", "push", next(iter(PUSH_REFS))),
            (REPOSITORY, "push", "refs/tags/codex/admob-safe-integration"),
            (REPOSITORY, "", ""),
        ]:
            with self.subTest(repo=repo, event=event, ref=ref):
                self.assertFalse(authorized(repo, event, ref))

    def test_entire_signed_tail_uses_one_boundary_and_validation_is_not_skipped(self):
        workflow = (Path(__file__).resolve().parents[1] /
                    ".github/workflows/admob-pr-validation.yml").read_text(encoding="utf-8")
        before, tail = workflow.split("      - name: Kalıcı Android imzasını hazırla", 1)
        self.assertNotIn("    if:", before.split("jobs:", 1)[1].split("steps:", 1)[0])
        self.assertIn("flutter analyze", before)
        self.assertIn("flutter test", before)
        self.assertIn("git diff --check", before)
        self.assertNotIn("secrets.", before)
        signed_steps = ("      - name: Kalıcı Android imzasını hazırla" + tail).split("      - name: ")[1:]
        self.assertEqual(len(signed_steps), 10)
        for step in signed_steps:
            header = step.split("        run:", 1)[0].split("        uses:", 1)[0]
            self.assertIn("steps.signing.outputs.authorized == 'true'", header)


if __name__ == "__main__":
    unittest.main()
