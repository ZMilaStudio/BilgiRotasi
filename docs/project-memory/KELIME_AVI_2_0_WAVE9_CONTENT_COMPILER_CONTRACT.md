# KELİME AVI 2.0 — WAVE 9 KA-02 CONTENT COMPILER CONTRACT

Status: IMPLEMENTATION CONTRACT / TOOLING ONLY

Wave:
- WAVE 9 — KA-02 CONTENT COMPILER + STRICT ROUTE-WIDE UNIQUENESS GATE

Scope:
- deterministic development/content compiler
- Segment1 source lock
- route-wide strict uniqueness
- Level 11–100 candidate validation
- source/output lock evidence
- tooling/tests/CI only

Out of scope:
- production Level 11–100 integration
- Segment2–10 runtime integration
- runtime generation
- player persistence changes
- KA-04 content-quality scoring
- owner editorial approval

## Canonical tool boundary

Canonical CLI:
- `tools/word_hunt_batch_generator.py`

Compiler contract version:
- `ka02-v1`

Canonical implementation rule:
- the existing batch generator was refactored into the single KA-02 core
- no second grid-generation algorithm exists
- no second normalization authority exists
- no second uniqueness authority exists

Legacy historical tooling:
- `tools/word_hunt_release_stock_manifest.py`
- `tools/word_hunt_release_stock_check.py`

These two scripts remain historical/release-stock utilities. They are not KA-02 authority and are not expanded into Kelime Avı 2.0 production-content authority.

## Source schema

Input schema:
- `schemaVersion: 2`

Required top-level fields:
- `schemaVersion`
- `seed`
- `routes`

Each production route candidate:
- `routeId`
- `levels`

Each candidate level requires:
- explicit `id`
- explicit absolute `index`
- explicit `type`
- `targetWords`
- `bonusWords`
- `starRules`

Optional passthrough:
- `displayName`
- `timeLimitSeconds`
- `infoCardIds`
- explicit per-level `seed`

Route title/theme/reward data are intentionally absent because those are owned by canonical production route definitions, not by candidate manifests.

Production candidate indexes are restricted to `11..100`. Partial/staged batches are valid. Candidate files do not need to start at 11 or contain all future levels.

`routeFinal` rules:
- L11–L99: `routeFinal` rejected
- L100: `routeFinal` required
- L20/L30/L40/L50/L60/L70/L80/L90 are not auto-final

The compiler never invents production level IDs.

## Canonical normalization

Runtime semantic authority:
- `WordHuntPathEngine.normalizeWord`

Compiler parity:
1. trim outer whitespace
2. Turkish `i` -> `İ`
3. Turkish `ı` -> `I`
4. uppercase

The compiler does not:
- remove spaces
- remove hyphens
- replace punctuation
- transliterate Turkish letters

Supported alphabet:
- `ABCÇDEFGĞHIİJKLMNOÖPRSŞTUÜVYZ`

Candidate word contract:
- non-empty after trim
- 3..8 runes
- supported alphabet only

Invalid source fails closed.

## Segment1 source lock

Machine-readable lock:
- `tools/word_hunt_segment1_source_lock.json`

Lock schema:
- `schemaVersion: 1`
- `lockVersion: wave8-segment1-v1`

Wave 8 authorities recorded in lock:
- implementation: `d07ec30d82ca97931d0a72589d649ff93daae366`
- final integration: `c289b09b186d3e97d7b13413f84ebc7c994a52f4`

Current lock payload SHA-256:
- `df568a0badaa5b5e122e9c49179d3ee9b6c4697b22192910a1e63b8c9546a537`

Each route entry contains:
- `routeId`
- Wave 8 Segment1 content fingerprint
- sorted normalized `reservedWords`
- `reservedWordCount`
- first-known `wordOrigins` with level/id/index/role

Mechanical parity gate:
- `test/word_hunt_2_0_wave9_content_compiler_test.dart`

That test derives current data again from `WordHuntRouteCatalog` and fails on:
- route order/id drift
- Segment1 level count/index drift
- fingerprint drift
- reserved-word drift
- reserved-count drift
- new Segment1 duplicate debt
- first-origin drift

Compiler also verifies the lock payload SHA-256 before using it.

Current Wave 8 lock:
- baslangic-limani — `39462daa` — 80
- gokyuzu-adalari — `2fd4e4af` — 80
- orman-yolu — `de4fe1f9` — 54
- orman-2 — `71084c8f` — 67
- kristal-vadisi — `fcd1e9ce` — 70
- kayip-sehir — `5c9041c4` — 70
- yeralti-kralligi — `71d752f6` — 70
- gunes-imparatorlugu — `0a6c7f40` — 70

All eight Segment1 datasets are expected to retain zero current duplicate debt.

## Route-wide uniqueness

Uniqueness scope is one route, never global game scope.

For each route:
1. initialize `seenWords` from Segment1 lock
2. process candidate levels in ascending absolute index order
3. process TARGET then BONUS entries using canonical normalization
4. reject any normalized word already present
5. store first-known source and role for actionable diagnostics

Rejected combinations include:
- Segment1 TARGET -> candidate TARGET
- Segment1 TARGET -> candidate BONUS
- Segment1 BONUS -> candidate TARGET
- Segment1 BONUS -> candidate BONUS
- candidate TARGET -> later TARGET
- candidate BONUS -> later BONUS
- candidate TARGET -> later BONUS
- candidate BONUS -> later TARGET
- same-level TARGET/TARGET duplicate
- same-level BONUS/BONUS duplicate
- same-level TARGET/BONUS collision

The same normalized word on two different routes is allowed.

## Variable word counts

KA-02 does not inherit the historical fixed combined 5..10 restriction.

Technical policy:
- at least one TARGET
- BONUS may be empty
- no compiler-invented 4+1 policy
- no compiler-invented challenge cadence
- no compiler-invented time limit
- no compiler-invented info-card assignment

If an editorial word set cannot be physically placed while satisfying the deterministic exact-one contract within bounded attempts, compilation fails.

## Deterministic seed derivation

Global source seed:
- supplied by input manifest

Explicit level seed:
- respected when supplied

Derived level seed:
- SHA-256 over stable identity:
  - compiler version
  - global seed
  - routeId
  - absolute level index

No route ordinal is included.

The generator uses an internal SHA-256 deterministic RNG. It does not use:
- Python `hash()`
- system clock
- filesystem order
- random UUID
- network services

Reordering unrelated routes therefore does not change a level's resolved seed identity.

## Grid generation contract

Grid:
- exactly 8x8

Path rule:
- `straightEightDirections`

Allowed physical directions:
- horizontal
- vertical
- diagonal
- forward or reverse gesture over the same physical line

Core generation:
- deterministic backtracking placement
- deterministic filler
- bounded backtracking budget
- bounded generation retries
- bounded filler retries

The compiler does not replace the established straight-line grid model with a separate algorithm.

## Exact-one physical occurrence

Every intended TARGET/BONUS word must have exactly one physical occurrence in its final 8x8 grid.

Physical occurrence identity canonicalizes a cell path and its reversed path to the same path. This prevents palindromes such as `KÖK` from being double-counted merely because the same cells can be traversed in both directions.

Filler is accepted only when it creates no second physical occurrence of any intended word.

If the bounded deterministic filler attempts cannot satisfy exact-one, compilation fails.

## Placement/path proof

Each compiled level stores placement evidence:
- word
- start row/column
- direction delta
- explicit cell coordinates

Validation mode independently re-reads the final grid and verifies:
- each placement is in one of the eight directions
- cells match row/column/delta
- reading the listed cells returns the intended word
- every intended word has one placement
- every intended word still has exactly one physical occurrence

Placement metadata is not trusted without grid revalidation.

## Source digest

Algorithm:
- SHA-256

Canonical source digest covers:
- compiler version
- generation contract
- normalized schema-v2 manifest
- global seed
- route IDs
- level IDs/indexes/types
- TARGET/BONUS inputs
- star rules and supplied generation-relevant metadata
- explicit level seeds
- Segment1 source-lock version/digest

It excludes:
- timestamps
- machine paths
- usernames
- temp directories
- CI run IDs

## Final-grid fingerprint

Algorithm:
- SHA-256

Per-level lock material includes:
- routeId
- level id/index/type
- final grid rows
- targetWords
- bonusWords
- starRules
- optional passthrough metadata
- explicit seed
- resolved seed
- placement evidence

Any change to relevant level identity, grid, intended words, seed or placement proof changes the level fingerprint.

## Deterministic output

Canonical artifact:
- `artifactKind: NON_PRODUCTION_KA02_CANDIDATE`
- `artifactSchemaVersion: 1`

Same semantic manifest + same Segment1 lock + same compiler version + same seed produces byte-identical canonical JSON and deterministic report text.

Output contains no timestamp or environment-dependent value.

Successful wording is intentionally limited to:
- `COMPILE PASS`
- `VALIDATION PASS`
- `CANDIDATE READY FOR REVIEW`

Compiler success is not owner production approval and is not a release decision.

## Validation CLI

Compile:

```bash
python3 tools/word_hunt_batch_generator.py \
  --input tools/word_hunt_content_factory.sample.json \
  --source-lock tools/word_hunt_segment1_source_lock.json \
  --output /tmp/word_hunt_candidate.json \
  --report /tmp/word_hunt_candidate.txt
```

Validate existing locked output:

```bash
python3 tools/word_hunt_batch_generator.py \
  --validate /tmp/word_hunt_candidate.json \
  --source-lock tools/word_hunt_segment1_source_lock.json
```

Verify source lock only:

```bash
python3 tools/word_hunt_batch_generator.py \
  --verify-source-lock-only \
  --source-lock tools/word_hunt_segment1_source_lock.json
```

NON-PRODUCTION sample:
- `tools/word_hunt_content_factory.sample.json`

The sample contains synthetic tooling vocabulary and must not be interpreted as approved Level 11+ production content.

## Validation mode contract

Validation mode rechecks:
- artifact schema/kind
- compiler version
- generation contract
- Segment1 lock identity
- source digest
- route IDs
- candidate indexes/types
- route-wide uniqueness
- Segment1 collisions
- TARGET/BONUS cross collisions
- resolved seeds
- 8x8 grid shape/alphabet
- exact-one physical occurrences
- placement/path integrity
- per-level SHA-256 fingerprint
- route summary counts
- total level count

Tampered locked output fails closed.

## Python tests

Canonical test module:
- `tools/tests/test_word_hunt_content_compiler.py`

Coverage includes:
- same-input/same-seed output byte determinism
- report determinism
- source digest determinism
- stable resolved seeds
- route-order independence
- different-seed behavior
- all Segment1-to-candidate role collision directions
- all candidate cross-level role collision directions
- cross-route word reuse
- same-level normalized duplicate rejection
- Turkish casing parity
- invalid space/hyphen/punctuation rejection
- variable word-count shapes including 4 TARGET + 0 BONUS
- 8x8/exact-one/palindrome/reverse-path checks
- staged L11/L20/L50/L90/L100 semantics
- L10/L101 rejection
- source-lock tamper detection
- output tamper detection
- explicit seed handling
- locked-output recompile proof
- fail-closed malformed source validation

No third-party Python package is required.

## CI

Cumulative workflow:
- `.github/workflows/word-hunt-2-0-wave0-validation.yml`
- workflow name remains `Kelime Avı 2.0 Cumulative Validation`

Dedicated Wave 9 gates:
- Segment1 source-lock parity
- Python compiler tests
- deterministic compile byte/report proof
- strict uniqueness/reserved-set source-lock proof
- locked-output validation proof

Historical Wave0–8 gates remain cumulative.

The separate `word-hunt-content-factory.yml` workflow now consumes the same KA-02 compiler/test/lock authority. It no longer expands the old 18x10 release-stock assumptions into 2.0 authority.

## Runtime and persistence safety

Wave 9 does not import tooling into `lib/`.

Wave 9 does not:
- generate levels at app startup
- persist generated levels into player storage
- add compiler seed/digest/reserved sets to player save
- change gameplay/navigation/presentation/completion architecture
- alter route reward or milestone reward logic

Required unchanged persistence:
- `WordHuntProgressCodec.schemaVersion = 3`
- storage prefix `bilgi_rotasi_word_hunt_progress_v1_`

## Production content safety

Wave 9 does not regenerate Segment1 and does not add production Level 11–100 definitions.

The eight production content files remain semantic authority for Levels 1–10 only.

Wave 9 does not create production Segment2–10 data.

## Wave 10 handoff

Wave 10 may later provide an owner-approved schema-v2 candidate manifest for any route/staged Level 11–100 range.

Without modifying compiler code per route, KA-02 must return:
- deterministic 8x8 candidate grids
- route-wide Segment1 + candidate reserved-word validation
- stable resolved seeds
- placement/path proof
- source digest
- per-level SHA-256 locks
- deterministic human-readable report

Wave 10 must still perform separate owner/editorial approval and production integration. KA-02 success alone never means production approval.
