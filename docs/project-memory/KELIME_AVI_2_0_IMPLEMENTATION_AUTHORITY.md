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
