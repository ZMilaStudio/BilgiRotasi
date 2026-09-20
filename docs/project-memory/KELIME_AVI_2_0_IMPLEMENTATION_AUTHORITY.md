# KELİME AVI 2.0 — IMPLEMENTATION AUTHORITY

Durum: **WAVE 0 / IMPLEMENTATION AUTHORITY BASELINE**

Tarih: 2026-09-20

Bu dosya Kelime Avı 2.0 implementation wave'lerinin exact authority manifestidir. Owner açıkça authority değiştirmedikçe sonraki implementation çalışmaları bu manifestte kayıtlı source, migration ve immutable baseline sınırlarını korur.

## 1. LIVE SOURCE AUTHORITIES

### Production source baseline

- Branch: `release/final-closed-test-aab-1.68.8`
- Exact SHA: `67c91fce5078bedfd14fb984eacd6f99a26f2792`
- Role: mevcut production source-code baseline
- Bu branch rename edilmez, silinmez ve Kelime Avı 2.0 uzun ömürlü implementation branch'i olarak kullanılmaz.

### Owner master contract

- Branch: `docs/kelime-avi-2-0-master-contract`
- Exact SHA: `eafb6ceb94848cae7d0723fbe269615c2c62fa0b`
- Authority file: `docs/project-memory/KELIME_AVI_2_0_MASTER_CONTRACT.md`
- Role: OWNER PRODUCT AUTHORITY

### Architecture & migration audit

- Branch: `docs/kelime-avi-2-0-architecture-audit`
- Exact SHA: `8462cc32d438084754bc715e64ff58bfcb9d5b47`
- Authority file: `docs/project-memory/KELIME_AVI_2_0_ARCHITECTURE_MIGRATION_AUDIT.md`
- Audit PR: `#212` — open / Draft / unmerged at Wave 0 start

## 2. LONG-LIVED INTEGRATION AUTHORITY

- Integration branch: `feat/kelime-avi-2-0-integration`
- Integration branch creation/base SHA: `67c91fce5078bedfd14fb984eacd6f99a26f2792`
- Base source tree: `d3415ef0e1f027ee6725b97268c8f288d966065d`
- Strategy: integration branch production source baseline'ından exact SHA ile ayrılır; latest owner master contract ve latest architecture audit docs bu branch'e authority copies olarak alınır.
- Docs authority branches implementation branch'e dönüştürülmez.
- Production release branch implementation branch'e dönüştürülmez.
- Future Wave commits bu integration branch üzerinde ilerler.
- Owner contract veya audit authority daha sonra advance ederse integration branch'e yalnız explicit authority-refresh commit ile alınır; sessiz drift kabul edilmez.

## 3. EXISTING PRODUCTION RELEASE IDENTITY

- Product version: `1.68.21+111`
- Production GitHub Release tag: `v1.68.21+111`
- Production GitHub Release name: `Bilgi Rotası 1.68.21+111`
- Release status at Wave 0 start: published, non-draft, non-prerelease
- Play rollout status: **BLOCKED / YAPILMAMALI**
- Existing production release/tag/assets overwrite edilmez.
- Wave 0 version bump, tag, release asset replacement, workflow release dispatch veya Play upload yapmaz.

## 4. CURRENT PERSISTENCE AUTHORITY

Current production authority:

- `WordHuntProgressCodec.schemaVersion = 2`
- owner scope: `guest` veya `user_<uid>`
- persisted fields:
  - `bestStarsByLevelId`
  - `unlockedInfoCardIds`
  - `unlockedRouteRewardIds`
- schema 1 decode compatibility korunur.
- storage key prefix mevcut v1 identity ile korunur.

Proposed schema v3 architecture auditte tanımlanmıştır fakat:

**SCHEMA V3 WAVE 0'DA IMPLEMENT EDİLMEMİŞTİR.**

Wave 2 explicit owner scope'u olmadan persistence/schema değişikliği yapılmaz.

## 5. MIGRATION PRINCIPLES

1. Route identity korunur.
2. Existing level identity ve absolute indexes 1–10 korunur.
3. Existing star/progression mapping level ID üzerinden korunur.
4. Existing info-card ownership reset edilmez.
5. Existing route reward ownership reset edilmez.
6. Segment/current-level gibi derived state gereksiz yere persist edilmez.
7. Future migration existing player access'ini sessizce geriye götürmez.
8. Production 10-level dataset Segment 1 migration input'udur; Wave 0 content değiştirmez.
9. Route-aware gameplay, segment model, completion flow ve Word Hunt home Wave 0 scope'unda değildir.
10. Kafadan toplu rewrite yapılmaz; her wave exact-head gate ile kapanır.

## 6. WORD UNIQUENESS OWNER RESOLUTION

Owner master contract latest authority:

**GRANDFATHER EXCEPTION YOK.**

Legacy Segment 1'de route-wide duplicate bulunan rotalar:
- `baslangic-limani`
- `gokyuzu-adalari`
- `orman-yolu`
- `orman-2`

Bu duplicate content ilgili content-migration wave'inde düzeltilecektir.

Mutlak korunacak:
- route IDs
- level IDs 1–10
- absolute level indexes 1–10
- progression mapping

Owner-approved olarak ileride değiştirilebilecek:
- duplicate target/bonus words
- bunları taşıyan grid placements
- gerekli validation fixtures

Wave 0:
- duplicate content değiştirmez,
- debt'i exact baseline ile görünür kılar,
- bunu strict uniqueness PASS olarak raporlamaz.

## 7. IMMUTABLE ARTWORK AUTHORITY

Aşağıdaki exact environment WebP'ler owner-approved **FINAL / IMMUTABLE** authority'dir.

### Kayıp Şehir
- Path: `assets/word_hunt/KAYIP_SEHIR_ENV_941x1672.webp`
- Size: 941×1672
- Bytes: 2,092,556
- SHA-256: `0f22a3c56060ce19febaef552458657630751cb4ab016d0884a21d37178eb314`
- Lock doc: `docs/project-memory/KELIME_AVI_KAYIP_SEHIR_ASAMA9A_ARTWORK_FINAL_LOCK.md`

### Yeraltı Krallığı
- Path: `assets/word_hunt/YERALTI_KRALLIGI_ENV_941x1672.webp`
- Size: 941×1672
- Bytes: 2,238,174
- SHA-256: `9d99111c7a949519745e44d4386fd0cdab774e10e74bc30e34fee9e410ca3fb5`
- Lock doc: `docs/project-memory/KELIME_AVI_YERALTI_KRALLIGI_ASAMA9B_ARTWORK_FINAL_LOCK.md`

### Güneş İmparatorluğu
- Path: `assets/word_hunt/GUNES_IMPARATORLUGU_ENV_941x1672.webp`
- Size: 941×1672
- Bytes: 1,774,348
- SHA-256: `4515ece9196cbb0699366b37cb46ca28f3d4f453b489c3983dc69c5261d48bf9`
- Lock doc: `docs/project-memory/KELIME_AVI_GUNES_IMPARATORLUGU_ASAMA9C_ARTWORK_FINAL_LOCK.md`

Existing byte-level authority test:
`test/word_hunt_trilogy_asset_lock_test.dart`

Bu asset'lerde explicit new owner approval olmadan re-encode, resize, crop, recolor, overwrite veya binary edit yoktur.

## 8. IMMUTABLE ROUTE ID BASELINE

Exact production route IDs:

1. `baslangic-limani`
2. `gokyuzu-adalari`
3. `orman-yolu`
4. `orman-2`
5. `kristal-vadisi`
6. `kayip-sehir`
7. `yeralti-kralligi`
8. `gunes-imparatorlugu`

Bu IDs migration identity authority'sidir.

## 9. LEGACY LEVEL ID + INDEX BASELINE

### baslangic-limani
- 1 → `baslangic-1`
- 2 → `baslangic-2`
- 3 → `baslangic-3`
- 4 → `baslangic-4`
- 5 → `baslangic-5`
- 6 → `baslangic-6`
- 7 → `baslangic-7`
- 8 → `baslangic-8`
- 9 → `baslangic-9`
- 10 → `baslangic-10`

### gokyuzu-adalari
- 1 → `gokyuzu-1`
- 2 → `gokyuzu-2`
- 3 → `gokyuzu-3`
- 4 → `gokyuzu-4`
- 5 → `gokyuzu-5`
- 6 → `gokyuzu-6`
- 7 → `gokyuzu-7`
- 8 → `gokyuzu-8`
- 9 → `gokyuzu-9`
- 10 → `gokyuzu-10`

### orman-yolu
- 1 → `orman-yolu-01`
- 2 → `orman-yolu-02`
- 3 → `orman-yolu-03`
- 4 → `orman-yolu-04`
- 5 → `orman-yolu-05`
- 6 → `orman-yolu-06`
- 7 → `orman-yolu-07`
- 8 → `orman-yolu-08`
- 9 → `orman-yolu-09`
- 10 → `orman-yolu-10`

### orman-2
- 1 → `orman-2-01`
- 2 → `orman-2-02`
- 3 → `orman-2-03`
- 4 → `orman-2-04`
- 5 → `orman-2-05`
- 6 → `orman-2-06`
- 7 → `orman-2-07`
- 8 → `orman-2-08`
- 9 → `orman-2-09`
- 10 → `orman-2-10`

### kristal-vadisi
- 1 → `kristal-vadisi-01`
- 2 → `kristal-vadisi-02`
- 3 → `kristal-vadisi-03`
- 4 → `kristal-vadisi-04`
- 5 → `kristal-vadisi-05`
- 6 → `kristal-vadisi-06`
- 7 → `kristal-vadisi-07`
- 8 → `kristal-vadisi-08`
- 9 → `kristal-vadisi-09`
- 10 → `kristal-vadisi-10`

### kayip-sehir
- 1 → `kayip-sehir-01`
- 2 → `kayip-sehir-02`
- 3 → `kayip-sehir-03`
- 4 → `kayip-sehir-04`
- 5 → `kayip-sehir-05`
- 6 → `kayip-sehir-06`
- 7 → `kayip-sehir-07`
- 8 → `kayip-sehir-08`
- 9 → `kayip-sehir-09`
- 10 → `kayip-sehir-10`

### yeralti-kralligi
- 1 → `yeralti-kralligi-01`
- 2 → `yeralti-kralligi-02`
- 3 → `yeralti-kralligi-03`
- 4 → `yeralti-kralligi-04`
- 5 → `yeralti-kralligi-05`
- 6 → `yeralti-kralligi-06`
- 7 → `yeralti-kralligi-07`
- 8 → `yeralti-kralligi-08`
- 9 → `yeralti-kralligi-09`
- 10 → `yeralti-kralligi-10`

### gunes-imparatorlugu
- 1 → `gunes-imparatorlugu-01`
- 2 → `gunes-imparatorlugu-02`
- 3 → `gunes-imparatorlugu-03`
- 4 → `gunes-imparatorlugu-04`
- 5 → `gunes-imparatorlugu-05`
- 6 → `gunes-imparatorlugu-06`
- 7 → `gunes-imparatorlugu-07`
- 8 → `gunes-imparatorlugu-08`
- 9 → `gunes-imparatorlugu-09`
- 10 → `gunes-imparatorlugu-10`

IDs, indexes ve routeId mapping migration sırasında değişirse baseline gate fail etmelidir.

## 10. WAVE 0 NO-PRODUCT-BEHAVIOR-CHANGE BOUNDARY

Wave 0 sonunda bilinçli olarak değişmeden kalacak:

- app entry mevcut haliyle kalır,
- ayrı Kelime Avı home henüz yoktur,
- route model production'da hâlâ 10 levels'dır,
- persistence schema hâlâ 2'dir,
- themed gameplay Harbor fallback henüz düzeltilmemiştir,
- completion flow henüz değiştirilmemiştir,
- book/compass henüz kaldırılmamıştır,
- content/grid/target/bonus henüz değiştirilmemiştir,
- binary artwork değişmemiştir.

Wave 1+ explicit owner onayı olmadan bu sınırlar aşılmaz.

## 11. FUTURE AUTHORITY REFRESH RULE

Bu manifestteki production/master/audit SHA'lardan biri future owner kararıyla değişirse:
1. live GitHub tekrar doğrulanır,
2. değişiklik owner authority ile karşılaştırılır,
3. integration branch'e explicit docs-only authority refresh yapılır,
4. manifest exact SHA'larla güncellenir,
5. ardından implementation devam eder.

Sessiz SHA drift veya eski docs üzerinden implementation yapılmaz.

## 12. WAVE 1 — DOMAIN FOUNDATION CLOSURE

Durum: **PASS**

Wave 1 validated implementation HEAD:
`bd71206401d50c2943892441da85c85207334645`

Validation authority:
- Workflow: `.github/workflows/word-hunt-2-0-wave0-validation.yml`
- Workflow name: `Kelime Avı 2.0 Cumulative Validation`
- Run: `#10`
- Run ID: `35508634764`
- Exact source HEAD: `bd71206401d50c2943892441da85c85207334645`
- Result: **SUCCESS**
- Full repository analyzer: **92 issues**, Wave 0 baseline olan 92'den kötüleşme yok
- Wave 1 targeted analyze: **No issues found**
- Full Flutter suite: **726 tests passed**

Domain foundation files:
- `lib/word_hunt/word_hunt_models.dart`
- `lib/word_hunt/word_hunt_segment_projection.dart`
- `test/word_hunt_2_0_wave1_domain_foundation_test.dart`

Chosen level display-name compatibility rule:
- `WordHuntLevelDefinition.displayName` first-class fakat nullable/additive authority'dir.
- Legacy level definitions field vermeden geçerli kalır.
- Deterministic fallback: `displayNameOrFallback` explicit non-empty name varsa onu, yoksa `Bölüm <index>` döndürür.
- Explicit `displayName` trim sonrası boşsa validator error üretir.
- Existing 80 production level definition Wave 1'de yeniden yazılmamıştır.

Chosen segment metadata architecture:
- `WordHuntSegmentDefinition` first-class domain metadata'dır.
- Stable id, segment index, display name, start absolute level index ve end absolute level index taşır.
- `WordHuntRouteDefinition.segments` additive/optional'dır.
- Empty `segments` mevcut 10-level production routes için legacy compatibility authority'sidir.
- Explicit metadata verilen rota segment validation'a girer.
- 100-level explicit 2.0 rota için tam 10 segment × 10 level contractı doğrulanır.
- Segment metadata progression state değildir ve persist edilmez.
- Permanent architecture runtime-generated anonymous segment metadata'ya dayanmaz.

Chosen projection/milestone authority:
- `WordHuntSegmentProjection` pure deterministic domain projection'dır.
- `absoluteLevelIndex`, `segmentIndex`, `localLevelIndex`, segment start/end, segment definition ve level definition çözer.
- Segment start/end ve segment milestone semantics derived'dır.
- Explicit 100-level / 10-segment 2.0 route için:
  - every segment end = segment milestone,
  - absolute level 50 = major midpoint,
  - absolute level 100 = true route final.
- Legacy raw `WordHuntLevelType.routeFinal` tek başına future true-route-final authority değildir.
- Synthetic 100-level testte L10 raw `routeFinal` olsa bile `isTrueRouteFinal == false`; L100 için true'dur.
- Mevcut `WordHuntRouteProgressEngine.isRouteComplete` Wave 1'de değiştirilmemiştir.

Persistence:
- `WordHuntProgressCodec.schemaVersion = 2` korunmuştur.
- Segment/current-segment/local-index/milestone için yeni persisted field eklenmemiştir.
- Proposed schema v3 **HALA IMPLEMENT EDİLMEMİŞTİR**.

No-product-behavior-change closure:
- production routes hâlâ 10 level,
- route IDs ve legacy level IDs unchanged,
- grids / targetWords / bonusWords unchanged,
- duplicate debt baseline unchanged,
- route map UI unchanged,
- gameplay UI/behavior unchanged,
- Harbor fallback unchanged,
- completion flow unchanged,
- book/compass unchanged,
- immutable assets unchanged,
- release identity unchanged,
- release/tag/Play Console işlemi yok.

Wave 2 readiness:
- Domain segment/display-name/projection semantics Wave 2 persistence-v3 tasarımı için hazırdır.
- Wave 2 implementation **owner'ın sonraki explicit onayı olmadan başlamaz**.

Not: Bu docs-only closure commit'inin SHA'sı commit içeriğine bağlı olduğundan manifest kendi commit SHA'sını kriptografik olarak self-reference edemez. Yukarıdaki SHA Wave 1 code/test validation exact HEAD'idir; docs-only closure sonrası final integration HEAD manager summary'de exact olarak raporlanır ve aynı cumulative CI hattında yeniden doğrulanır.

## 13. WAVE 2 — PERSISTENCE V3 + LEGACY ACCESS MIGRATION CLOSURE

Durum: **PASS**

Wave 2 code/test validated implementation HEAD:
`8b545bdc43138753cc98e71285249687623a433b`

Validation authority:
- Workflow: `.github/workflows/word-hunt-2-0-wave0-validation.yml`
- Workflow name: `Kelime Avı 2.0 Cumulative Validation`
- Run: `#16`
- Run ID: `35512145973`
- Exact source HEAD: `8b545bdc43138753cc98e71285249687623a433b`
- Result: **SUCCESS**
- Full repository analyzer: **92 issues**, Wave 0 baseline olan 92'den kötüleşme yok
- Wave 1+2 targeted analyze: **No issues found**
- Full Flutter suite: **749 tests passed**

Persistence authority:
- `WordHuntProgressCodec.schemaVersion = 3`
- Historical storage key prefix **DEĞİŞMEDİ**:
  `bilgi_rotasi_word_hunt_progress_v1_`
- Schema 1, schema 2 ve schema 3 decode edilir.
- Unknown future schema fail-closed / `FormatException` davranışı korunur.
- `decode()` backward-compatible kalır.
- `decodeWithMetadata()` source schema version ve migration-writeback gereksinimini taşır.

Schema v3 additive fields:
- `bestBonusFoundCountByLevelId: Map<String, int>`
- `grandfatheredUnlockedRouteIds: Set<String>`
- `lastActiveRouteId: String?`

Persist edilmeyen derived state:
- current level,
- current segment,
- local level index,
- milestone flags,
- route totals,
- next playable state.

Bonus authority:
- Missing bonus-map key = **historical / unknown**.
- Explicit key with value `0` = known zero.
- Unknown legacy values topluca sıfıra çevrilmez.
- Best bonus count monotonic olarak merge edilir.
- Production gameplay result `foundBonusCount` fact'ini additive olarak parent'a taşır.
- Route-aware reward/persistence boundary bonus count'ı level bonusWords upper bound'ına göre doğrular.

Frozen legacy access migration:
- Migration future `WordHuntRouteProgressEngine.isRouteComplete` semantiğine bağlı değildir.
- Frozen production order:
  1. `baslangic-limani`
  2. `gokyuzu-adalari`
  3. `orman-yolu`
  4. `orman-2`
  5. `kristal-vadisi`
  6. `kayip-sehir`
  7. `yeralti-kralligi`
  8. `gunes-imparatorlugu`
- Frozen legacy completion:
  - existing legacy final = route'un mevcut son level'ı,
  - son level en az 1 yıldızla tamamlanmış,
  - legacy `unlockStarsRequired` threshold sağlanmış.
- Historical olarak açılan route'lar `grandfatheredUnlockedRouteIds` içine alınır.
- Bir downstream route'ta persisted level progress bulunması o route'a kadar access'i monotonik olarak korur.
- Access entitlement route completion, reward ownership veya star değildir.
- Word-uniqueness owner kararındaki **NO GRANDFATHER EXCEPTION** ile bu access entitlement kavramı karıştırılmaz.

Last-active authority:
- `lastActiveRouteId` yalnız minimal resume hint'tir.
- Production'da yalnız geçerli/unlocked bir level gerçekten açılırken route ID işaretlenir.
- Route browsing veya locked-card tap bunu değiştirmez.
- Legacy schema1/2 için fallback, persisted progress bulunan en ileri frozen catalog route'tur.
- Persisted progress yoksa fallback null'dır.
- `currentLevelId` persist edilmez.

Migration writeback:
1. owner scope doğrulanır,
2. schema1/2/3 codec metadata ile decode edilir,
3. schema1/2 için frozen legacy access + deterministic last-active migration uygulanır,
4. mevcut route reward backfill korunur,
5. migration veya reward-backfill gerekirse aynı historical storage key'e schema3 writeback yapılır,
6. sonraki schema3 load destructive legacy migration'ı yeniden çalıştırmaz.

Safety/scale:
- Guest ve `user_<uid>` owner-scope isolation korunur.
- Corrupt/unsupported payload Kelime Avı UI'sını açılmaz hale getirmez; production load empty snapshot safety fallback'ını korur.
- Valid schema1/2 fixture'larda stars/cards/rewards data loss yoktur.
- 8×100 = **800 distinct level ID** synthetic v3 encode/decode roundtrip PASS.
- Yeni database/storage technology eklenmemiştir.

Current production behavior intentionally unchanged:
- `WordHuntRouteProgressEngine.isRouteComplete` mevcut 10-level production semantiğinde kaldı.
- Grandfathered access henüz selector/unlock authority'sine bağlanmadı.
- Production routes hâlâ 10 level.
- Content, grids, targetWords, bonusWords ve duplicate debt değişmedi.
- App entry, Word Hunt Home, map UI, gameplay visuals, Harbor fallback, completion UX, book/compass değişmedi.
- Immutable artwork ve release identity değişmedi.
- Version/tag/release/Play işlemi yapılmadı.

Wave 3 readiness:
- Persistence v3 ve frozen access migration foundation KA-03 renderer decomposition için hazırdır.
- Wave 3 implementation **owner'ın sonraki explicit onayı olmadan başlamaz**.

Not: Manifest kendi docs-only closure commit SHA'sını self-reference edemez. Yukarıdaki SHA Wave 2 code/test exact validation HEAD'idir. Bu closure commit'inden sonra oluşan final integration HEAD aynı cumulative validation workflow'unda tekrar doğrulanır ve manager summary'de final exact HEAD olarak raporlanır.

