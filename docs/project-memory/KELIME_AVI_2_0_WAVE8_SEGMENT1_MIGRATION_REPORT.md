# KELİME AVI 2.0 — WAVE 8 SEGMENT 1 MIGRATION REPORT

## 1. Scope and starting authority

Wave:
**WAVE 8 — EXISTING 10-LEVEL → SEGMENT 1 MIGRATION + LEGACY DUPLICATE CONTENT CORRECTION**

Starting integration HEAD:
`f9600e03379d4ba36720c34b9b06326ff2cb9085`

Production authority remained:
`release/final-closed-test-aab-1.68.8@67c91fce5078bedfd14fb984eacd6f99a26f2792`

This report records only Wave 8 migration evidence. It does not define Wave 9 compiler behavior or Wave 10 content.

## 2. Segment 1 representation

Wave 8 keeps the Wave 3 legacy adapter as the canonical representation for the current 10-level production routes:

- `route.segments.isEmpty` remains true,
- `WordHuntRouteSegmentHost` projects the existing route as legacy Segment 1,
- absolute indexes remain 1–10,
- local node indexes remain 1–10,
- renderer input remains exactly 10 nodes,
- existing level IDs and route mappings remain unchanged,
- current legacy L10 completion/reward/visual compatibility remains unchanged.

No one-segment product metadata and no owner-facing segment name was introduced.

Future explicit V2 authority remains separate:
- 100 levels + 10 segments are required for `WordHuntSegmentProjection.isExplicitV2Route`,
- only explicit V2 absolute L100 is the future true route final.

## 3. Frozen pre-Wave8 duplicate debt

Historical extra occurrences:

| Route | Pre-Wave8 duplicate extra occurrences |
|---|---:|
| baslangic-limani | 7 |
| gokyuzu-adalari | 14 |
| orman-yolu | 18 |
| orman-2 | 7 |
| kristal-vadisi | 0 |
| kayip-sehir | 0 |
| yeralti-kralligi | 0 |
| gunes-imparatorlugu | 0 |

The exact historical pair list remains frozen in
`test/word_hunt_2_0_wave0_baseline_test.dart`.

## 4. Duplicate replacement ledger

Grid edit scope is the number of changed cells in that level after all replacements in the same level are applied together. All listed target/bonus paths remain valid after the combined edit.

| Route | Level ID | Role | Old | New | Preserved occurrence / rationale | Grid edit scope | Info-card impact |
|---|---|---|---|---|---|---:|---|
| Başlangıç Limanı | baslangic-3 | TARGET | KALEM | KAĞIT | baslangic-1 TARGET; earliest/source-stable | 4 cells | none |
| Başlangıç Limanı | baslangic-7 | TARGET | ÇİÇEK | MEYVE | baslangic-6 TARGET; earliest/source-stable | 7 cells total in level | none |
| Başlangıç Limanı | baslangic-7 | BONUS | DOĞA | ÇAYIR | baslangic-6 TARGET; earliest/source-stable | 7 cells total in level | none |
| Başlangıç Limanı | baslangic-8 | TARGET | KOŞU | FAUL | baslangic-4 BONUS; earliest/source-stable | 3 cells | none |
| Başlangıç Limanı | baslangic-10 | TARGET | BİLGİ | İPUCU | baslangic-1 TARGET; earliest/source-stable | 13 cells total in level | none |
| Başlangıç Limanı | baslangic-10 | TARGET | YILDIZ | PARKUR | baslangic-9 TARGET; earliest/source-stable | 13 cells total in level | none |
| Başlangıç Limanı | baslangic-10 | TARGET | HEDEF | NİŞAN | baslangic-4 TARGET; earliest/source-stable | 13 cells total in level | none |
| Gökyüzü Adaları | gokyuzu-1 | TARGET | BULUT | SERAP | gokyuzu-2 TARGET preserved for `gok-info-bulut` | 4 cells | linked BULUT occurrence preserved |
| Gökyüzü Adaları | gokyuzu-3 | TARGET | KANAT | PENÇE | gokyuzu-1 TARGET; earliest/source-stable | 6 cells total in level | none |
| Gökyüzü Adaları | gokyuzu-3 | TARGET | UÇUŞ | UÇAK | gokyuzu-1 TARGET; earliest/source-stable | 6 cells total in level | none |
| Gökyüzü Adaları | gokyuzu-4 | TARGET | GÜNEŞ | GÜNDÜZ | gokyuzu-10 TARGET preserved for GÜNEŞ info card | 5 cells | linked GÜNEŞ occurrence preserved |
| Gökyüzü Adaları | gokyuzu-5 | TARGET | RÜZGAR | MELTEM | gokyuzu-1 TARGET preserved for RÜZGAR info card | 10 cells total in level | linked RÜZGAR occurrence preserved |
| Gökyüzü Adaları | gokyuzu-5 | TARGET | YAĞMUR | YAĞIŞ | gokyuzu-4 TARGET; earliest/source-stable | 10 cells total in level | none |
| Gökyüzü Adaları | gokyuzu-5 | TARGET | BULUT | DUMAN | gokyuzu-2 TARGET preserved for `gok-info-bulut` | 10 cells total in level | linked BULUT occurrence preserved |
| Gökyüzü Adaları | gokyuzu-7 | TARGET | IŞIK | ALEV | gokyuzu-4 TARGET; earliest/source-stable | 12 cells total in level | none |
| Gökyüzü Adaları | gokyuzu-7 | TARGET | İSKELE | RIHTIM | gokyuzu-6 TARGET; earliest/source-stable | 12 cells total in level | none |
| Gökyüzü Adaları | gokyuzu-7 | TARGET | GÖLGE | SİLÜET | gokyuzu-2 TARGET; earliest/source-stable | 12 cells total in level | none |
| Gökyüzü Adaları | gokyuzu-9 | TARGET | YILDIZ | METEOR | gokyuzu-7 TARGET; earliest/source-stable | 6 cells total in level | none |
| Gökyüzü Adaları | gokyuzu-9 | TARGET | IŞIK | IŞIN | gokyuzu-4 TARGET; earliest/source-stable | 6 cells total in level | none |
| Gökyüzü Adaları | gokyuzu-10 | TARGET | IŞIK | ŞULE | gokyuzu-4 TARGET; earliest/source-stable | 8 cells total in level | none |
| Gökyüzü Adaları | gokyuzu-10 | TARGET | GÖKYÜZÜ | GÖKLER | gokyuzu-7 TARGET; earliest/source-stable | 8 cells total in level | none |
| Orman Yolu | orman-yolu-02 | TARGET | KÖK | KORU | orman-yolu-01 TARGET; earliest/source-stable | 5 cells total in level | none |
| Orman Yolu | orman-yolu-02 | TARGET | ORMAN | FİDAN | orman-yolu-01 TARGET; earliest/source-stable | 5 cells total in level | none |
| Orman Yolu | orman-yolu-03 | TARGET | MEŞE | KAVAK | orman-yolu-02 TARGET preserved for MEŞE info card | 5 cells total in level | linked MEŞE occurrence preserved |
| Orman Yolu | orman-yolu-03 | TARGET | KUŞ | ARI | orman-yolu-02 TARGET; earliest/source-stable | 5 cells total in level | none |
| Orman Yolu | orman-yolu-04 | TARGET | TOPRAK | KUMSAL | orman-yolu-03 TARGET; earliest/source-stable | 7 cells total in level | none |
| Orman Yolu | orman-yolu-04 | TARGET | GÖLGE | SERİN | orman-yolu-03 BONUS; earliest/source-stable | 7 cells total in level | none |
| Orman Yolu | orman-yolu-05 | TARGET | KOZALAK | PALAMUT | orman-yolu-04 TARGET preserved for KOZALAK info card | 6 cells total in level | linked KOZALAK occurrence preserved |
| Orman Yolu | orman-yolu-05 | TARGET | DERE | ÇAY | orman-yolu-04 TARGET; earliest/source-stable | 6 cells total in level | none |
| Orman Yolu | orman-yolu-06 | TARGET | ÇİÇEK | LALE | orman-yolu-05 TARGET; earliest/source-stable | 8 cells total in level | none |
| Orman Yolu | orman-yolu-06 | TARGET | OTLAR | ÇİMEN | orman-yolu-05 TARGET; earliest/source-stable | 8 cells total in level | none |
| Orman Yolu | orman-yolu-06 | BONUS | GEYİK | KİRPİ | orman-yolu-07 TARGET preserved because GEYİK card is linked there | 8 cells total in level | linked GEYİK occurrence preserved; intentional non-earliest keep |
| Orman Yolu | orman-yolu-07 | TARGET | SİNCAP | TAVŞAN | orman-yolu-06 TARGET preserved for SİNCAP info card | 12 cells total in level | linked SİNCAP occurrence preserved |
| Orman Yolu | orman-yolu-07 | TARGET | AĞAÇ | FİDE | orman-yolu-01 TARGET preserved for AĞAÇ info card | 12 cells total in level | linked AĞAÇ occurrence preserved |
| Orman Yolu | orman-yolu-07 | TARGET | YAPRAK | SÜRGÜN | orman-yolu-01 TARGET; earliest/source-stable | 12 cells total in level | none |
| Orman Yolu | orman-yolu-07 | TARGET | DAL | KOL | orman-yolu-01 TARGET; earliest/source-stable | 12 cells total in level | none |
| Orman Yolu | orman-yolu-08 | TARGET | DERE | PINAR | orman-yolu-04 TARGET; earliest/source-stable | 7 cells total in level | none |
| Orman Yolu | orman-yolu-08 | TARGET | PATİKA | PARKUR | orman-yolu-05 TARGET; earliest/source-stable | 7 cells total in level | none |
| Orman Yolu | orman-yolu-10 | TARGET | ORMAN | BAHÇE | orman-yolu-01 TARGET; earliest/source-stable | 4 cells | none |
| Kadim Orman | orman-2-05 | BONUS | YANKI | FISILTI | orman-2-02 BONUS; earliest/source-stable | 7 cells | none |
| Kadim Orman | orman-2-07 | TARGET | AKINTI | NEHİR | orman-2-03 BONUS; earliest/source-stable | 4 cells total in level | none |
| Kadim Orman | orman-2-07 | BONUS | SERİN | ILIK | orman-2-02 TARGET; earliest/source-stable | 4 cells total in level | none |
| Kadim Orman | orman-2-08 | TARGET | OYMA | YAZI | orman-2-06 TARGET; earliest/source-stable | 5 cells total in level | none |
| Kadim Orman | orman-2-08 | BONUS | HALKA | DAİRE | orman-2-04 BONUS; earliest/source-stable | 5 cells total in level | none |
| Kadim Orman | orman-2-09 | TARGET | HALKA | YÜZÜK | orman-2-04 BONUS; earliest/source-stable | 8 cells total in level | none |
| Kadim Orman | orman-2-09 | TARGET | KABUK | LİKEN | orman-2-01 TARGET; earliest/source-stable | 8 cells total in level | none |

## 5. Fingerprints and strict uniqueness result

| Route | Pre-Wave8 fingerprint | Wave8 fingerprint | Pre debt | Post debt | Corrected Segment1 reserved count |
|---|---|---|---:|---:|---:|
| baslangic-limani | `31f8e6fa` | `39462daa` | 7 | 0 | 80 |
| gokyuzu-adalari | `0466644f` | `2fd4e4af` | 14 | 0 | 80 |
| orman-yolu | `c297be09` | `7aae6da3` | 18 | 0 | 54 |
| orman-2 | `de83535d` | `71084c8f` | 7 | 0 | 67 |
| kristal-vadisi | `fcd1e9ce` | `fcd1e9ce` | 0 | 0 | 70 |
| kayip-sehir | `5c9041c4` | `5c9041c4` | 0 | 0 | 70 |
| yeralti-kralligi | `71d752f6` | `71d752f6` | 0 | 0 | 70 |
| gunes-imparatorlugu | `0a6c7f40` | `0a6c7f40` | 0 | 0 | 70 |

Post-migration strict target:
- TARGET/TARGET duplicates: 0
- BONUS/BONUS duplicates: 0
- TARGET/BONUS cross duplicates: 0
- normalized route-wide duplicate extra occurrences: 0 for all 8 routes.

The reserved set for future validation is not persisted. It is deterministically enumerable from current Segment 1 `targetWords + bonusWords`.

## 6. Content safety

For all existing 80 levels:
- route ID unchanged,
- level ID unchanged,
- level index unchanged,
- level routeId unchanged,
- level type unchanged,
- star rules unchanged,
- time limit unchanged,
- infoCardIds unchanged,
- target count unchanged,
- bonus count unchanged,
- grid remains rectangular,
- grid dimensions remain 8×8.

For the four zero-debt routes:
- Kristal Vadisi grid/target/bonus bytes at source level are unchanged,
- Kayıp Şehir grid/target/bonus are unchanged,
- Yeraltı Krallığı grid/target/bonus are unchanged,
- Güneş İmparatorluğu grid/target/bonus are unchanged.

Only first-four duplicate replacements and their minimum required grid cells changed.

## 7. Info-card compatibility

The keep decision prioritized existing linked card words.

Explicit linked-word preservation includes:
- Gökyüzü: BULUT at `gokyuzu-2`, RÜZGAR at `gokyuzu-1`, GÜNEŞ at `gokyuzu-10`,
- Orman: AĞAÇ at `orman-yolu-01`, MEŞE at `orman-yolu-02`, KOZALAK at `orman-yolu-04`, SİNCAP at `orman-yolu-06`, GEYİK at `orman-yolu-07`.

The GEYİK decision intentionally preserves the later occurrence because that exact level owns the linked card; `orman-yolu-06` BONUS GEYİK is the occurrence replaced.

All current `infoCardIds` must resolve and their card word must remain listed in the linked level.

## 8. Level display-name migration

Only existing source authority is wired:

- Kayıp Şehir: 10 existing names,
- Yeraltı Krallığı: 10 existing names,
- Güneş İmparatorluğu: 10 existing names.

The names are copied exactly from each route's existing `levelNames` source authority into `WordHuntLevelDefinition.displayName`.

Başlangıç Limanı, Gökyüzü Adaları, Orman Yolu, Kadim Orman and Kristal Vadisi remain unnamed at model level and keep `displayNameOrFallback -> Bölüm N`.

Runtime consumption is data-driven:
- map accessibility uses `displayNameOrFallback`,
- gameplay header already uses `displayNameOrFallback`,
- parent completion destination carries existing explicit `displayName` when present.

No route-ID/title name switch is introduced.

## 9. Progress and persistence mapping

Existing persistence remains identity-based on level IDs.

No persistence migration is required solely for the content correction because:
- all 80 level IDs are unchanged,
- `bestStarsByLevelId` keys remain valid,
- `bestBonusFoundCountByLevelId` keys remain valid.

Preserved snapshot fields:
- `bestStarsByLevelId`,
- `unlockedInfoCardIds`,
- `unlockedRouteRewardIds`,
- `bestBonusFoundCountByLevelId`,
- `grandfatheredUnlockedRouteIds`,
- `lastActiveRouteId`.

Persistence remains:
- schema: `3`,
- storage prefix: `bilgi_rotasi_word_hunt_progress_v1_`.

## 10. Explicit non-scope

Wave 8 does not add:
- Level 11–100 production content,
- Segment 2–10 production metadata,
- final future segment names,
- content compiler,
- generator,
- seeded grid builder,
- new scene expansion,
- new artwork,
- version/release/tag/Play changes.

Wave 8 validation and final PASS authority are recorded separately in
`KELIME_AVI_2_0_IMPLEMENTATION_AUTHORITY.md` only after exact-HEAD validation succeeds.
