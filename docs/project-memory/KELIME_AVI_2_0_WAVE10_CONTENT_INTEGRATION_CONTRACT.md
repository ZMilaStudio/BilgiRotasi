# KELİME AVI 2.0 — WAVE 10 CONTENT INTEGRATION CONTRACT

## Scope

Wave 10 is staged. Wave 10A integrates only **Başlangıç Limanı local Level 11–20**.
No Level 21+, no other route Level 11+, no Wave 10B, no release and no merge belong to this scope.

Starting integration authority:
- `feat/kelime-avi-2-0-integration@e4ae40b403cc6b35c39670a7d52f8dafdb675a43`
- Wave 9 implementation authority: `b05c3d3ef2773265b5eba99c2df917f16166db41`
- Production snapshot: `release/final-closed-test-aab-1.68.8@67c91fce5078bedfd14fb984eacd6f99a26f2792`
- Owner master: `eafb6ceb94848cae7d0723fbe269615c2c62fa0b`
- Architecture audit: `8462cc32d438084754bc715e64ff58bfcb9d5b47`

## Owner decision — local progression vs global display numbering

Progression identity remains route-local.

- `WordHuntLevelDefinition.index` stays local `1..100`.
- Segment projection, milestone semantics and true-final semantics use local indexes.
- Player save remains keyed by existing level IDs.
- Global display number is a derived presentation-only value.
- No persistence migration or schema change is permitted for numbering.

Canonical display formula:

`globalDisplayNumber = routeDisplayOffset + localIndex`

Locked route order and offsets:

| Route | Local | Display | Offset |
| --- | --- | --- | ---: |
| baslangic-limani | 1–100 | 1–100 | 0 |
| gokyuzu-adalari | 1–100 | 101–200 | 100 |
| orman-yolu | 1–100 | 201–300 | 200 |
| orman-2 | 1–100 | 301–400 | 300 |
| kristal-vadisi | 1–100 | 401–500 | 400 |
| kayip-sehir | 1–100 | 501–600 | 500 |
| yeralti-kralligi | 1–100 | 601–700 | 600 |
| gunes-imparatorlugu | 1–100 | 701–800 | 700 |

The centralized runtime projection is `WordHuntGlobalLevelNumbering`.
Widgets must not grow route-name arithmetic chains. Catalog/order drift must be caught by tests because a reorder would be player-visible renumbering.

Explicit `displayName` remains authoritative. Only missing display names receive `Bölüm <globalDisplayNumber>` fallback.

## Wave 10A partial V2 representation

Başlangıç Limanı becomes a staged segmented route:

- available production content: local `1..20`
- planned route size: `100`
- Segment 1: local `1..10`
- Segment 2: local `11..20`
- renderer continues to project exactly 10 nodes at once
- L10 is a Segment 1 endpoint, not a route final
- L20 is a Segment 2 endpoint/content frontier, not a route final
- only local L100 may be the true route final

A staged segmented route must not pretend its current last available level is complete route authority.
Complete V2 remains exactly 100 levels / 10 ten-level segments.

Segment IDs are progression-stable and independent of display names:
- `baslangic-limani-segment-01`
- `baslangic-limani-segment-02`

No owner-approved lore name for Başlangıç Segment 2 exists in the audited authority. Until owner naming exists, its provisional non-lore display fallback is **`Segment 2`**. Segment 1 uses the same neutral technical naming style when explicit metadata first becomes necessary.

## Content frontier

Completing current available L20 must:
- persist stars and bonus count normally,
- grant only applicable derived milestone info reward,
- perform one canonical save,
- not navigate to nonexistent L21,
- not mark the route complete,
- not grant the route reward,
- not unlock Gökyüzü through true completion,
- not show route-final presentation.

The completion layer uses an explicit typed content-frontier destination rather than overloading terminal-game semantics.

## Planned vs available progress

Wave 10A must distinguish:
- available content count = 20,
- planned route level count = 100.

Player-facing route progress must not imply `20/20` completion. Segment progress may still be `x/10`.
Currently obtainable stars remain derived from available content; no save migration is introduced.

## Production content pipeline

Wave 10A Level 11–20 content must use:
- `tools/word_hunt_batch_generator.py`
- compiler contract `ka02-v1`
- source schema `2`
- Segment1 source lock `tools/word_hunt_segment1_source_lock.json`

Required order:
1. editorial manifest,
2. KA-02 compile,
3. locked artifact validation,
4. deterministic report review,
5. route-wide uniqueness review,
6. grid review,
7. production Dart integration from locked output,
8. production validation against the lock.

The compiler does not invent vocabulary. Production grids must not be hand-authored around the compiler.

## Safety

- Existing 80 level IDs are not rewritten.
- Başlangıç L1–10 words and grids remain byte/semantic content-locked.
- Wave 8 Segment1 fingerprint `39462daa` remains authority.
- Wave 9 Segment1 source lock remains Segment1-only and is not expanded.
- Other seven routes remain at their existing 10 production levels in Wave 10A.
- No new artwork is required.
- Immutable trilogy artwork remains untouched.
- Schema remains v3.
- Storage prefix remains `bilgi_rotasi_word_hunt_progress_v1_`.
- Global display numbers are never persisted.
- KA-04 scoring is out of scope.
- Play release remains blocked while staged content is partial.
