"""Owner-approved permanent signing boundary; independent of validation."""
import os

REPOSITORY = "ZMilaStudio/BilgiRotasi"
PUSH_REFS = frozenset({
    "refs/heads/codex/admob-safe-integration",
    "refs/heads/codex/admob-production-ids",
    "refs/heads/update/closed-test-next-release",
})


def authorized(repository, event, ref):
    return repository == REPOSITORY and event == "push" and ref in PUSH_REFS


if __name__ == "__main__":
    value = str(authorized(os.environ.get("GITHUB_REPOSITORY"),
                           os.environ.get("GITHUB_EVENT_NAME"),
                           os.environ.get("GITHUB_REF"))).lower()
    print(f"SIGNED_BUILD_AUTHORIZED={value}")
    with open(os.environ["GITHUB_OUTPUT"], "a", encoding="utf-8") as output:
        output.write(f"authorized={value}\n")
