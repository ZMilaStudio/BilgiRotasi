# KELİME AVI 2.0 — ARCHITECTURE & MIGRATION AUDIT

Durum: **AUDIT / IMPLEMENTASYON YOK**

Tarih: 2026-09-20

## Authority

- Repo: `ZMilaStudio/BilgiRotasi`
- Production/release source branch: `release/final-closed-test-aab-1.68.8`
- Live release HEAD: `67c91fce5078bedfd14fb984eacd6f99a26f2792`
- Owner master contract branch: `docs/kelime-avi-2-0-master-contract`
- Live master contract HEAD: `a48a8603399e029e4003bc8ffd2898a6b3c3b6d6`
- Owner authority: `docs/project-memory/KELIME_AVI_2_0_MASTER_CONTRACT.md`
- Audit branch base: owner master contract HEAD

Bu doküman ürün kararı üretmez. Owner-approved master contract'a teknik olarak nasıl güvenli geçileceğini tanımlar. Bu aşamada ürün kodu, content, asset, persistence payload'ı, version, tag veya release değiştirilmemiştir.

---

# 1. EXECUTIVE VERDICT

## Overall classification

**C — additive persistence/schema migration gerekli; çekirdek architecture breaking rewrite gerektirmiyor.**

Buna ek olarak içerik genişletme hattında sınırlı bir:

**E — legacy Segment 1 word-uniqueness contract blocker**

vardır. Bu E blocker model/persistence/navigation foundation çalışmalarını bloklamaz; ancak 11–100 içerik üretimi production contract olarak kapatılmadan önce owner kararı gerekir.

Ana kararlar:

1. Mevcut `WordHuntRouteDefinition`, flat level listesi ve level-id bazlı progression korunabilir.
2. 100-level model için route içine nested progression state sokmak gerekmez.
3. Segment, progression state değil; **first-class metadata + derived runtime projection** olmalıdır.
4. Mevcut 10-node geometry 100-node'a büyütülmemeli; her segment için aynı 10-node renderer kullanılmalıdır.
5. Level display name first-class content field olmalıdır.
6. Route completion authority artık raw `WordHuntLevelType.routeFinal` değil, **gerçek route final position (Bölüm 100)** olmalıdır.
7. Gameplay engine korunmalı; route-aware görünüm catalog/config ile çözülen presentation profile üzerinden verilmelidir.
8. Route-id/name switch zinciri oluşturulmamalıdır.
9. Existing progress map 800 level için ölçeklenebilir; fakat 2.0 semantiği için additive schema migration gereklidir.
10. Existing level IDs 1–10 korunursa mevcut yıldızlar Segment 1'e doğal olarak taşınabilir.
11. Eski oyuncunun daha önce açtığı rotalar 100-level route-complete değişikliği yüzünden yeniden kilitlenmemelidir; grandfathered unlock entitlement gerekir.
12. Route-final bonus performansı için mevcut persistence yetersizdir.
13. Book/compass kaldırılması progression state'i bozmaz.
14. Mevcut info-card ownership korunabilir; grant trigger milestone modeline taşınabilir.
15. Existing locked environment WebP'ler immutable kalabilir.

---

# 2. TECHNICAL TRIGGER / DEVELOPMENT COMPASS

Bu liste ürün authority değildir; yalnız architecture audit girdisidir.

## KA-01 — Kelime Avı Integration Branch Strategy

**Tetiklendi.**

Neden:
- Canonical source bugün sürüm adı taşıyan uzun yaşayan `release/final-closed-test-aab-1.68.8` branch'idir.
- Kelime Avı 2.0 uzun süreli feature/migration hattıdır.
- Release snapshot ile yeni development/integration hattının aynı kavram olarak kalması ilerleyen wave'lerde source-of-truth belirsizliği yaratır.

Audit kararı:
- Mevcut release branch silinmez/rename edilmez.
- İlk implementation wave'inde owner-approved contract branch'ten kontrollü 2.0 integration branch stratejisi belirlenmelidir.
- Release branch korunmuş production snapshot olarak kalmalıdır.

## KA-02 — Automated Word Hunt Content Compiler

**2.0 tarafından ileriki content wave için tetiklendi; bu aşamada uygulanmaz.**

Neden:
- 8 × 100 hedefi manuel content üretimini riskli hale getirir.
- Runtime generation yasaktır.
- Deterministik development/content pipeline uygundur.

Ön koşul:
- Route-wide uniqueness gate,
- source format,
- determinism,
- final-grid lock contract.

## KA-03 — Route Map Renderer Decomposition

**Güçlü biçimde tetiklendi.**

Neden:
- `word_hunt_reusable_route_map_screen.dart` büyük ve 10-level route varsayımına sıkı bağlıdır.
- 2.0 segment projection, local/global node index ayrımı ve chrome cleanup gerektirir.
- Renderer değişikliği artık somut ürün ihtiyacıdır.

Korunacaklar:
- 10-node geometry,
- node hitbox contract,
- route IDs,
- progression,
- unlock/reward semantics,
- presentationOrder,
- locked artwork,
- pixel/regression proof.

## KA-04 — Content Quality Scoring for Generated Grids

**Şu an tetiklenmedi.**

KA-02 tamamlanıp gerçek generated candidates kalite puanlama ihtiyacı gösterirse ele alınmalıdır.

## KA-05 — Stale PR / QA Branch Cleanup

**2.0 architecture tarafından doğrudan tetiklenmedi.**

Ayrı bakım audit'i olarak kalır.

## INFRA-01 — Protect Production Branches

**Governance girdisi; activation bu scope'ta yok.**

Bilgi Rotası/Kelime Avı için mevcut audit sonucu partial-protection yaklaşımını destekler. Ancak branch protection/ruleset/required-check değişikliği bu işin parçası değildir ve ayrı owner onayı gerektirir.

---

# 3. CLASSIFICATION MATRIX

| Başlık | Sınıf | Kısa sonuç |
|---|---|---|
| 1. App entry / product split | **B** | İnce top-level product launcher + Word Hunt module boundary gerekir. |
| 2. Kelime Avı home | **C** | UI/projection B; exact “last active route” ve 2.0 migration state'i persistence v3'e bağlanır. |
| 3. 100-level route model | **B** | Flat route levels korunur; segment metadata + projection eklenir. |
| 4. Level name contract | **B** | First-class displayName additive field gerekir. |
| 5. Word uniqueness | **E** | Gate tasarımı net; dört legacy route ilk 10'da mevcut tekrar içeriyor. |
| 6. Variable word count | **A** | Mevcut list-based schema zaten destekliyor. |
| 7. Milestone model | **B** | Milestone derived projection; raw routeFinal enum completion authority olmamalı. |
| 8. Gameplay presentation | **B** | Route-aware presentation profile/skin foundation gerekir; KA-03 tetiklenir. |
| 9. Level completion flow | **B** | Parent orchestration üzerinden next destination; gameplay state authority olmaz. |
| 10. Route completion | **C** | Presentation B; aggregate bonus performance persistence gerektirir. |
| 11. Book / compass removal | **A** | State authority bağı yok; callbacks/chrome additive temizlenebilir. |
| 12. Info card model | **A** | Existing durable ownership korunur; milestone grant additive olabilir. |
| 13. Scene / artwork model | **B** | Scene catalog + segment→scene schedule gerekir; persistence gerekmez. |
| 14. Progression + persistence | **C** | Schema v3 additive migration ve legacy unlock entitlement gerekir. |
| 15. Existing content migration | **E** | Segment 1 korunabilir; uniqueness legacy conflict owner kararı ister. |
| 16. Existing visual migration | **B** | 10-node maps segment renderer'a projection ile taşınır; KA-03. |
| 17. Current production blockers | **E** | Harbor fallback ve completion/content contract blockers release öncesi kapanmalı. |
| 18. Release safety | **A** | Audit docs-only; production release/tag/version untouched. |

---

# 4. APP ENTRY / PRODUCT SPLIT

## Current state

`main.dart`, `main_navigation.dart` içindeki current graph:

`HomeScreen`
→ `MainNavigationGrid`
→ `PlayCenterScreen`
→ `PlayCenterEntryCatalog.buildWordHuntScreen()`
→ `WordHuntProductionEntryScreen`

Yani Kelime Avı şu anda **Oyna merkezi içinde bir alt oyun modu** olarak açılıyor.

## 2.0 minimum architecture

Yeni top-level boundary:

`ProductModeEntryScreen`
- Bilgi Yarışması
- Kelime Avı

Bilgi Yarışması:
- mevcut `HomeScreen` / mevcut Bilgi Rotası navigation graph'ına girer.
- mevcut Play/Daily/Career/Social/Settings yapısı bu split nedeniyle yeniden tasarlanmaz.

Kelime Avı:
- yeni `WordHuntHomeScreen` feature entry'sine gider.
- doğrudan route selector'a gitmez.

Bu split shared app shell, account/profile/privacy/monetization infrastructure'ını ortak bırakır; Word Hunt navigation/content/progression/presentation feature boundary içinde tutulur.

### Classification: B

---

# 5. KELİME AVI HOME / CONTINUE PROJECTION

Yeni home:
- Devam Et
- Rotalar
- Genel İlerleme

## Mevcut progress'ten deterministik türetilebilenler

`WordHuntProgressSnapshot` + catalog ile:

- route completed level count,
- route total stars,
- total completed levels,
- total stars,
- unlocked info-card count,
- completed routes,
- next playable level,
- active segment = `((nextLevelIndex - 1) ~/ 10) + 1`,
- route lock state

türetilebilir.

## Ne persist edilmeli?

Segment ve current level **persist edilmemeli**. Bunlar progress'ten derived olmalıdır.

Ancak owner contract exact olarak “son aktif rota” davranışını ister. Kullanıcı eski açık bir rotaya geri dönüp orada oynadığında yalnız canonical forward progress'e bakarak son ziyaret edilen route bilinemez.

Minimum persistence:
- optional `lastActiveRouteId`

Persist edilmemesi gerekenler:
- `lastActiveSegment`
- `lastActiveLevel`
- ayrı `nextPlayableLevel`

Bunlar her açılışta canonical progress'ten türetilir.

`lastActiveRouteId` yoksa veya artık geçersizse deterministic fallback:
1. en ileri unlocked ve tamamlanmamış route,
2. yoksa son unlocked route,
3. starter.

Bu field progression authority değil, **resume hint** olmalıdır.

### Classification: C

---

# 6. 100-LEVEL ROUTE + 10×10 SEGMENT MODEL

## Current model

`WordHuntRouteDefinition`:
- flat `levels`
- route metadata
- route reward

`WordHuntLevelDefinition`:
- stable id
- routeId
- absolute index
- type
- grid
- targetWords
- bonusWords
- starRules
- infoCardIds
- timeLimit

Bu model 100 level taşımaya uygundur.

## Karar

### A) Existing models additive genişletilebilir mi?
**Evet.**

### B) Breaking model change gerekir mi?
**Hayır.**

### C) Segment first-class olmalı mı?
**Metadata olarak evet. Progression state olarak hayır.**

Önerilen content metadata boundary:

`WordHuntSegmentDefinition`
- segmentIndex 1..10
- displayName
- optional scene/presentation reference

Route seviyeleri flat 1..100 olarak kalır.

### D) Runtime segment
Derived projection:

`WordHuntSegmentProjection`
- route
- segment definition
- absolute levels (ör. 31–40)
- local node index 1..10
- current/unlocked/completed state
- global next playable info

Bu projection persistence'a yazılmaz.

Neden nested `route.segments[].levels[]` source-of-truth önerilmiyor:
- mevcut level ID/star map authority korunur,
- migration daha küçük olur,
- unlock engine flat sequential chain'i sürdürebilir,
- renderer local 10-node projection tüketebilir.

### Classification: B

---

# 7. LEVEL NAME CONTRACT

Current:
- `WordHuntLevelDefinition` display name taşımıyor.
- Runtime çoğunlukla `Bölüm N` gösteriyor.
- Kayıp Şehir, Yeraltı Krallığı ve Güneş İmparatorluğu source dosyalarında levelNames listeleri var; fakat bunlar runtime model authority değil.

Karar:
- `WordHuntLevelDefinition` içine first-class `displayName` eklenmeli.
- Migration döneminde compatibility için nullable/fallback başlanabilir.
- Final 2.0 validator tüm production 2.0 levels için non-empty name istemelidir.
- Runtime header/map/completion display name'i level definition/projection'dan almalıdır.
- Kayıp/Yeraltı/Güneş locked isimleri değiştirilmeden bağlanmalıdır.

Segment isimleri:
- `WordHuntSegmentDefinition.displayName` authority'sinde tutulmalıdır.
- Level name'den türetilmemelidir.

Yeni isim content'i bu audit kapsamında üretilmez.

### Classification: B

---

# 8. WORD UNIQUENESS CONTRACT

Owner rule:
- route içinde TARGET/TARGET tekrar yok,
- BONUS/BONUS tekrar yok,
- TARGET/BONUS çapraz tekrar yok,
- başka route'ta aynı kelime olabilir.

## Normalization authority

Runtime'da mevcut:
`WordHuntPathEngine.normalizeWord`

Davranış:
- trim
- Turkish `i → İ`
- Turkish `ı → I`
- uppercase

Build/test gate aynı normalization authority'yi kullanmalıdır. Ayrı bir normalization implementasyonu yazılmamalıdır.

## Exact validation algorithm

Her route için level index sırasıyla:

1. `Map<String, WordUse> firstUse` oluştur.
2. Her level için önce TARGET, sonra BONUS listesini dolaş.
3. Her raw word'ü `WordHuntPathEngine.normalizeWord` ile normalize et.
4. İlk kullanımda:
   - normalized,
   - raw,
   - levelId,
   - absoluteLevelIndex,
   - role TARGET/BONUS
   kaydet.
5. Aynı normalized token tekrar görülürse hard error:
   - routeId,
   - normalized word,
   - first level/role,
   - second level/role.
6. Error route validator/test gate'i fail ettirsin.

Bu validator runtime işi değildir:
- unit test,
- content compiler,
- CI quality gate
katmanında koşmalıdır.

Ayrıca current per-level validator'daki raw `trim()` duplicate kontrolü zamanla aynı Turkish normalization helper'a taşınmalıdır.

## Live source audit sonucu

Existing first 10 levels içinde actual source repeats var:

- **Başlangıç Limanı:** 7 duplicate occurrence.
  Örnek/normalize repeated tokens: KALEM, ÇİÇEK, DOĞA, KOŞU, BİLGİ, YILDIZ, HEDEF.
- **Gökyüzü Adaları:** 14 duplicate occurrence.
  Tekrarlanan tokenlar arasında BULUT, KANAT, UÇUŞ, RÜZGAR, YAĞMUR, IŞIK, İSKELE, GÖLGE, YILDIZ, GÜNEŞ, GÖKYÜZÜ var.
- **Orman Yolu:** 18 duplicate occurrence.
  Tekrarlanan tokenlar arasında KÖK, ORMAN, MEŞE, KUŞ, TOPRAK, GÖLGE, KOZALAK, DERE, ÇİÇEK, OTLAR, SİNCAP, GEYİK, AĞAÇ, YAPRAK, DAL, PATİKA var.
- **Kadim Orman:** 7 duplicate occurrence.
  Tekrarlanan tokenlar arasında YANKI, AKINTI, SERİN, OYMA, HALKA, KABUK var.
- **Kristal Vadisi:** 0.
- **Kayıp Şehir:** 0.
- **Yeraltı Krallığı:** 0.
- **Güneş İmparatorluğu:** 0.

Bu nedenle oyuncu tarafındaki “kelime tekrar hissi” yalnız runtime resolution varsayımı değildir; en az ilk dört rotada source dataset gerçek tekrar içeriyor.

## Legacy Segment 1 migration gate

Existing first 10 locked content bu audit'te değiştirilmez.

11–100 üretimi için minimum güvenli kural:
- Segment 1'de görülen bütün normalized kelimeler reserved set olur.
- Level 11–100 bu setin hiçbir kelimesini kullanamaz.
- Level 11–100 kendi aralarında da strict unique olmalıdır.

Fakat bu yalnız **yeni tekrar eklenmesini** engeller; legacy first10 içindeki mevcut tekrarları master contract'a uygun hale getirmez.

Dolayısıyla final 2.0 strict gate için owner'ın daha sonra iki yoldan birini açıkça seçmesi gerekir:
1. legacy duplicate content correction onayı,
2. master contract'ta açık grandfather exception.

Audit bu iki ürün kararından birini kendiliğinden seçmez.

Geçici tooling gerekiyorsa frozen legacy duplicate baseline yalnız migration visibility için raporlanabilir; “strict PASS” olarak gösterilmemelidir.

### Classification: E — content expansion öncesi owner decision gate

---

# 9. VARIABLE WORD COUNT

Current model:
- `targetWords: List<String>`
- `bonusWords: List<String>`

Current production data zaten değişken:
- targets yaklaşık 4–9,
- bonus 0–2 örnekleri mevcut.

Dolayısıyla 4+1 sabit schema gerekmiyor ve önerilmiyor.

### Classification: A

---

# 10. MILESTONE / CHALLENGE / TRUE FINAL

Current:
`WordHuntLevelType { normal, challenge, bonus, routeFinal }`

Mevcut content genellikle:
- L5 = challenge
- L10 = routeFinal

2.0:
- her 10. level milestone,
- 50 major midpoint,
- 100 real route final.

## Karar

Milestone **derived semantic** olmalıdır:

- `level.index % 10 == 0` → segment milestone
- `level.index == 50` → major midpoint
- `level.index == route.levels.length` ve 100 → true route final

Bunlar persistence'a yazılmaz.

`WordHuntLevelType` gameplay/content variation için korunabilir.

Önemli compatibility:
- Legacy Segment 1 L10 `routeFinal` type'ını locked presentation/content compatibility nedeniyle ilk migration'da korumak mümkündür.
- Fakat orchestration artık `level.type == routeFinal` gördüğünde route'u bitirmemelidir.
- **Route completion authority = true final projection (level 100).**

Future segment 20/30/.../90:
- milestone olması raw `routeFinal` type gerektirmez.
- Gameplay variation normal/challenge vb. ayrı kalır.

Validator:
- true final L100 routeFinal olmalı,
- legacy L10 routeFinal compatibility erken final authority sayılmamalı.

### Classification: B

---

# 11. GAMEPLAY PRESENTATION ROOT CAUSE

Live code root cause:

`WordHuntProductionEntryScreen._gameplayBackgroundForLevel()`

- referenceRoute → null
- themedReusable → **null**
- gokyuzuMasterArt → route-specific background

`WordHuntLevelProductionScreen` null background görünce:
`assets/word_hunt/v5_reference_assets/harbor_background_1080x1920.png`
kullanıyor.

Ayrıca gameplay implementation:
- Harbor header,
- Harbor metric plates,
- Harbor word plates,
- Harbor grid skin,
- Harbor instruction panel,
- Harbor completion panel

ile sıkı bağlı.

## Architecture decision

Common gameplay engine korunmalı.

Catalog tarafından çözülen typed presentation profile kullanılmalı:

`WordHuntRoutePresentationProfile`
- existing map visual theme,
- gameplay skin,
- scene catalog,
- segment→scene schedule,
- completion presentation theme.

`WordHuntGameplayPresentation` / skin:
- background scene,
- header tokens,
- metric plate tokens/assets,
- word plate tokens/assets,
- grid tokens,
- instruction panel,
- completion panel.

Production entry:
1. catalog entry'yi bulur,
2. route presentation profile'ı çözer,
3. gameplay screen'e typed config geçirir.

**Route adına veya routeId'ye göre if/switch zinciri yapılmamalıdır.**

Existing `WordHuntRouteVisualTheme` çöpe atılmaz; map presentation alt-config'i olarak korunur.

### KA-03
Bu ihtiyaç KA-03 Route Map Renderer Decomposition tetikleyicisini karşılıyor.

### Classification: B

---

# 12. LEVEL COMPLETION FLOW

Current `WordHuntLevelPlayResult`:
- levelId
- stars
- unlockedInfoCardIds

Current progression write:
- gameplay widget içinde değil,
- parent `WordHuntProductionEntryScreen` / `WordHuntRouteRewardEngine` üzerinden.

Bu authority korunmalıdır.

## Navigation contract

Gameplay yalnız result fact döndürür.

Parent:
1. result'ı canonical progress'e kaydeder,
2. persistence'ı tamamlar,
3. yeni progress üzerinden destination projection hesaplar.

Derived destination:
- normal level → next level,
- segment end (<100) → next segment,
- level100 → route completion / next route.

Direct-next-level navigation:
- ayrı currentLevel state persist etmez,
- save sonrası canonical `nextPlayableLevelIndex` kullanır,
- gameplay widget progression authority olmaz.

`WordHuntLevelPlayResult` navigation action taşımamalıdır.

Ancak bonus performance persistence için additive:
- `foundBonusCount`
gibi result fact gerekebilir.

## Deferred final

Current deferred completion wrapper raw `level.type == routeFinal` kontrolüne bağlı olmamalıdır.

2.0:
- generic level completion presentation parent-controlled hale getirilmeli,
- true final only = level100 projection,
- Segment 1 legacy L10 erken route ceremony üretmemeli.

### Classification: B

---

# 13. ROUTE COMPLETION

Current authority:
- `WordHuntRouteProgressEngine.isRouteComplete`
- `WordHuntRouteRewardEngine.recordLevelResult`

Current presentation:
- generic `WordHuntRouteCompletionDialog`.

## 2.0 boundary

Authority engine:
- route complete yalnız true final 100 tamamlanınca.
- route reward grant parent/engine authority'de kalır.

Presentation:
- route-aware full-screen/strong presentation layer.
- presentation progression mutate etmez.

Önerilen read-only summary projection:
`WordHuntRouteCompletionSummary`
- route identity/title,
- total stars,
- maximum stars,
- bonus performance,
- reward/badge,
- next unlocked route,
- route presentation profile.

UI bu summary'yi render eder.

## Bonus persistence gap

Current snapshot bonus completion performansını saklamıyor.
Info-card unlock count bonus performansı değildir.

Bu nedenle historical route bonus performance için yeni additive persistence gerekir.

Öneri:
- `bestBonusFoundCountByLevelId: Map<String, int>`
- absence = legacy/unknown
- content'ten max bonus count derived
- replay sonrası level için value güncellenir
- düşük replay eski daha iyi bonus sayısını düşürmez.

Historical unknown, 0 olarak uydurulmamalıdır.

### Classification: C

---

# 14. BOOK / COMPASS REMOVAL

Current:
- map screens callbacks alıyor,
- themed chrome bottom-left compass,
- bottom-right book,
- book modal persisted `unlockedInfoCardIds` okuyor,
- compass next playable highlight/hint üretiyor.

Neither control:
- stars mutate etmiyor,
- level unlock mutate etmiyor,
- route reward mutate etmiyor.

Dolayısıyla:
- renderer chrome callback/visual removal progression'ı kırmaz.
- book modal kalkarken card ownership korunur.
- compass hint kalkarken nextPlayable engine korunur.

### Classification: A

---

# 15. INFO CARD MODEL

Current:
- level `infoCardIds`
- bulunan kelimeye bağlı card unlock
- result → parent
- persisted `unlockedInfoCardIds`

2.0:
- durable ownership set korunmalıdır.
- milestone/segment reward engine yeni card ID grant edebilir.
- old unlocked IDs grandfathered olarak görünür kalır.
- eski save migration sırasında card IDs kaybolmaz.

Yeni info-card içerik bu audit'te üretilmez.

Word-triggered unlock mekanizmasının tamamen kaldırılıp kaldırılmaması ayrı implementation/content transition kararıdır; mevcut ownership data migration gerektirmez.

### Classification: A

---

# 16. SCENE / ARTWORK MODEL

Current `WordHuntRouteVisualTheme` zaten:
- background asset/base64,
- fit/alignment,
- contrast/saturation,
- vignette,
- tall ambient,
- seal/path/chrome,
- presentationOrder

gibi presentation data taşıyor.

Kayıp Şehir / Yeraltı Krallığı / Güneş İmparatorluğu locked environment WebP'leri ve tall-screen edge-derived ambient config'i korunabilir.

## 2.0 additive scene model

Route başına:
`WordHuntSceneDefinition`
- id
- immutable artwork reference
- ambient/presentation overrides

Profile içinde:
- ~4–5 scenes
- `segmentSceneIds[10]` veya eşdeğer deterministic mapping

Segment→scene mapping:
- persistence değildir,
- content/presentation config'dir.

Her level için artwork alanı eklenmez.

Immutable environment assets değiştirilmez.

### Classification: B

---

# 17. PROGRESSION + PERSISTENCE MIGRATION

## Current schema authority

`WordHuntProgressCodec.schemaVersion = 2`

Storage owner scope:
- guest
- `user_<uid>`

Payload:
- bestStarsByLevelId
- unlockedInfoCardIds
- unlockedRouteRewardIds

Schema 1 decode compatibility mevcut.
Storage key prefix v1 olarak sabit ve test ile korunuyor.

## 800 levels scale

`Map<levelId, stars>` 800 level için teknik olarak yeterlidir.
Scale nedeniyle yeni database/persistence technology gerekmez.

## Neden schema migration yine gerekiyor?

### 1. Legacy route unlock preservation

Bugün route completion L10 üzerinden downstream route açıyor.

2.0'da route completion L100 olunca eski oyuncunun:
- daha önce açtığı Gökyüzü/Orman/... rotaları
yeniden kilitlenmemelidir.

Current stars tek başına yeni route-complete ile bunu garanti etmez.

### 2. Bonus performance

Route-final 2.0 bonus performance için durable data yok.

### 3. Exact last active route

Owner Continue contract'ındaki exact last-active-route davranışı için minimal resume hint gerekir.

## Proposed additive schema v3

Existing fields aynen korunur.

Additive:
- `bestBonusFoundCountByLevelId`
- `grandfatheredUnlockedRouteIds`
- optional `lastActiveRouteId`

Persist edilmeyecek:
- current segment
- current level
- next playable
- route totals
- general progress totals

Bunlar derived.

## Legacy migration contract

Schema 1/2 decode:
1. ownerScope doğrula.
2. all existing stars/cards/rewards aynen koru.
3. existing level IDs 1–10 aynı tutulduğu için stars Segment1'e otomatik map olsun.
4. migration, **legacy 10-level catalog semantics snapshot** üzerinden historically unlocked route entitlements çıkarır.
5. downstream route'ta herhangi bir progress varsa o route access de korunur.
6. inferred access `grandfatheredUnlockedRouteIds` içine yazılır.
7. route rewards historical ownership olarak korunur fakat 2.0 “route completed” truth'u olarak kullanılmaz.
8. bonus map absent entries = unknown.
9. lastActiveRouteId yoksa deterministic fallback kullan.
10. migrated payload idempotent schema3 olarak yazılır.

## Route completion after migration

- New route completed metric = level100 true final completed.
- Historical badge/reward ownership, new route completion metric'ten ayrı tutulmalıdır.
- Existing downstream access monotonik olmalıdır: migration hiçbir oyuncunun daha önce eriştiği route'u kilitlememelidir.

## Required migration tests

- schema1 → schema3 no star/card loss
- schema2 → schema3 no reward loss
- owner scope isolation
- existing level IDs stable
- route access never regresses
- downstream progress implies access
- migration idempotence
- future schema fail-closed
- unknown bonus history not converted to zero
- 800-level encode/decode roundtrip
- corrupt payload safe fallback contract

### Classification: C

---

# 18. EXISTING CONTENT MIGRATION

## Can current 10 levels become Segment 1?

**Structurally yes.**

Requirements:
- route IDs unchanged,
- level IDs unchanged,
- absolute level indices 1–10 unchanged,
- grids/target/bonus locked content unchanged during migration,
- current stars therefore remain valid.

This is the safest progress-preserving migration.

## Uniqueness caveat

Strict master contract currently fails in first four legacy routes due actual source duplicates.

Therefore:

- Segment1 preservation architecture is valid.
- Production 2.0 content contract cannot be called strict-compliant until legacy duplicate policy is owner-resolved.
- Level11–100 generation must reserve every word appearing in Segment1 and never introduce another occurrence.
- Existing duplicate pairs themselves remain explicit migration debt, not hidden PASS.

### Classification: E

---

# 19. EXISTING VISUAL MIGRATION

Current reusable map:
- exactly 10 normalized stops,
- connections 1→2→...→10,
- runtime assert requires exactly 10 route levels,
- presentationOrder forward/reverse,
- route skin separated from geometry.

Bu 2.0 için doğru temel yaklaşımdır.

## Do not build a 100-node renderer

Instead:
- canonical route = 100 levels,
- active segment projection = 10 levels,
- renderer consumes 10 node view models.

Renderer view model needs distinction:
- localNodeIndex 1..10,
- absoluteLevelIndex 1..100,
- level displayName,
- gameplay type,
- milestone/presentation role,
- unlock/completed/current.

## L5 / L10 special semantics

Current art/renderers often special-case:
- challenge via `WordHuntLevelType.challenge`,
- routeFinal via `WordHuntLevelType.routeFinal`,
- endpoint labels local 1 and 10.

2.0:
- local node 10 = segment boundary, not always route final.
- absolute 100 = only true route final.
- legacy Segment1 L5/L10 visual identity can be preserved.
- future segment endpoints should use a separate derived presentation role rather than falsely setting routeFinal.

This is a core KA-03 decomposition reason.

### Classification: B

---

# 20. CURRENT PRODUCTION BLOCKERS

Authority blockers:

1. themed gameplay Harbor fallback,
2. completion screen polish,
3. only “Rotaya Dön” flow,
4. route completion presentation quality,
5. route completion text/contrast quality,
6. level names not wired to runtime,
7. player word-repeat feeling,
8. 10-level-per-route scale limit.

Audit findings:
- Harbor fallback root cause confirmed in code.
- Completion/result flow root cause confirmed in code.
- Level-name model gap confirmed.
- 10-node renderer hard route-length assertion confirmed.
- Word-repeat issue: first four routes contain actual source duplicates; therefore it is not safe to attribute the whole symptom only to runtime resolution.
- Kristal/Kayıp/Yeraltı/Güneş current first10 source sets do not show route-wide repeats in this audit.

Release 2.0 readiness requires all blockers relevant to final 2.0 product to close before new production artifact.

### Classification: E

---

# 21. RELEASE SAFETY

Current production/release source remains:
`67c91fce5078bedfd14fb984eacd6f99a26f2792`

This audit:
- production tag değiştirmez,
- production GitHub Release overwrite etmez,
- release asset değiştirmez,
- version bump yapmaz,
- Play Console'a dokunmaz,
- release branch'e commit atmaz,
- merge yapmaz.

### Classification: A

---

# 22. RECOMMENDED IMPLEMENTATION WAVES

Toplam öneri: **11 wave (Wave 0–10).**

## Wave 0 — Authority, branch strategy and contract gates

**Scope**
- KA-01 integration branch strategy.
- Master contract invariants için executable test inventory.
- Legacy IDs/artwork/persistence baselines freeze.

**Touched authority**
- docs/master contract,
- CI/test contracts only.

**Migration risk**
- Low.

**Test gate**
- release HEAD unchanged,
- route IDs / level IDs / locked asset hashes baseline,
- current schema fixtures captured.

**Dependency**
- None.

**Rollback boundary**
- Docs/tests only; behavior değişmeden revert edilebilir.

---

## Wave 1 — Domain foundation: names, segments, milestone projection

**Scope**
- first-class level displayName,
- segment definition metadata,
- derived segment projection,
- true-final/milestone helpers.

**Touched authority**
- models / validators / pure projection tests.

**Migration risk**
- Low–medium.

**Test gate**
- current 10-level definitions still validate,
- old IDs unchanged,
- variable target/bonus unchanged,
- true final helper does not mark legacy L10 as 2.0 route complete when route length=100.

**Dependency**
- Wave 0.

**Rollback boundary**
- Additive model/projection layer only.

---

## Wave 2 — Persistence v3 and legacy entitlement migration

**Scope**
- schema3 fields,
- bonus performance state,
- grandfathered route unlocks,
- optional lastActiveRouteId,
- schema1/2 migration.

**Touched authority**
- progress snapshot / codec / repository.

**Migration risk**
- **High.**

**Test gate**
- no data loss,
- owner scope,
- idempotence,
- access monotonicity,
- unknown bonus history,
- 800-level roundtrip.

**Dependency**
- Wave 1 route/projection semantics.

**Rollback boundary**
- Decoder remains backward-compatible; no destructive rewrite until migration tests pass.

---

## Wave 3 — KA-03 renderer decomposition + 10-node segment host

**Scope**
- separate geometry, node projection, chrome and route map host responsibilities,
- renderer consumes segment projection,
- local vs absolute indices.

**Touched authority**
- route-map presentation only.

**Migration risk**
- Medium.

**Test gate**
- existing pixel/geometry/hitbox tests,
- 10 nodes exact,
- presentationOrder,
- L5/L10 Segment1 visual regression,
- multiple segment projections.

**Dependency**
- Wave 1.

**Rollback boundary**
- Old renderer retained until projection renderer passes equivalence.

---

## Wave 4 — Product entry split + Word Hunt home

**Scope**
- Bilgi Yarışması | Kelime Avı equal entry,
- WordHuntHome: Continue / Routes / General Progress,
- existing Bilgi Yarışması graph untouched downstream.

**Touched authority**
- app navigation boundary,
- Word Hunt home projections.

**Migration risk**
- Medium.

**Test gate**
- existing quiz navigation regression,
- owner/account scope passed,
- Continue resolves correct route/segment/level,
- locked route state.

**Dependency**
- Waves 1–2.

**Rollback boundary**
- Top-level launcher can revert independently.

---

## Wave 5 — Route-aware gameplay presentation

**Scope**
- catalog-resolved presentation profile,
- gameplay skin/theme config,
- scene mapping,
- eliminate themed Harbor fallback.

**Touched authority**
- presentation only; gameplay engine remains common.

**Migration risk**
- Medium–high visual risk.

**Test gate**
- no route-id switch chains,
- each production route resolves non-null gameplay presentation,
- locked asset hashes unchanged,
- Android multi-size visual proof,
- scoring/path engine regression.

**Dependency**
- Wave 1; can follow Wave 3.

**Rollback boundary**
- Presentation injection boundary, engine unchanged.

---

## Wave 6 — Completion navigation and true-final orchestration

**Scope**
- next level,
- next segment,
- next route,
- parent save-before-navigation,
- level100 route completion,
- route-aware completion summary/presentation.

**Touched authority**
- parent orchestration / completion UI / reward transition.

**Migration risk**
- High behavior risk.

**Test gate**
- no duplicate writes,
- normal→next,
- L10→segment2 not route complete,
- L50 midpoint,
- L100 final,
- next route unlock,
- deferred final regression.

**Dependency**
- Waves 1–3 and 2 for persistence facts.

**Rollback boundary**
- Completion coordinator isolated from gameplay engine.

---

## Wave 7 — Book/compass removal + milestone info rewards

**Scope**
- remove lower chrome book/compass,
- preserve card ownership,
- add milestone reward grant mechanism.

**Touched authority**
- map chrome / reward orchestration.

**Migration risk**
- Low–medium.

**Test gate**
- no progression regression,
- existing card IDs survive,
- no inaccessible mandatory state dependency,
- route map controls regression.

**Dependency**
- Wave 6 milestone transitions.

**Rollback boundary**
- UI/reward presentation layer.

---

## Wave 8 — Existing 10-level → Segment 1 migration

**Scope**
- existing levels become absolute 1–10,
- IDs/grids/words preserved,
- existing levelNames wired where present,
- progress proof,
- strict uniqueness debt report.

**Touched authority**
- content adapters / catalog wiring.

**Migration risk**
- High due locked content and legacy saves.

**Test gate**
- old stars still resolve,
- all old level IDs unchanged,
- all locked Kayıp/Yeraltı/Güneş names/assets unchanged,
- exact duplicate baseline reported.

**Dependency**
- Waves 1–3 and 2.

**Rollback boundary**
- Per-route migration, one route at a time.

**Blocker**
- Strict uniqueness sign-off waits for owner legacy-duplicate decision.

---

## Wave 9 — KA-02 content compiler + strict route validator

**Scope**
- deterministic content pipeline,
- route-wide uniqueness gate,
- 11–100 reserved word checking,
- source lock/determinism.

**Touched authority**
- tooling/tests, not runtime generator.

**Migration risk**
- Medium.

**Test gate**
- same input+seed deterministic,
- no TARGET/TARGET, BONUS/BONUS, cross repeats,
- every word exists in grid,
- variable word counts retained.

**Dependency**
- Wave 8 baseline + owner uniqueness resolution.

**Rollback boundary**
- Tooling only; generated candidates are not production until locked.

---

## Wave 10 — Staged 11–100 integration + full release validation

**Scope**
- content batches after owner approvals,
- segment names/scenes,
- route-level 100 completeness,
- production regression and device proof.

**Touched authority**
- content/presentation datasets.

**Migration risk**
- High volume, controlled by batches.

**Test gate**
- 100 levels/route,
- 10×10 segment shape,
- uniqueness strict PASS,
- all route presentation profiles,
- progression/migration fixtures,
- Android device proof,
- release quality gates.

**Dependency**
- Waves 0–9.

**Rollback boundary**
- Route/segment batch commits; no monolithic 800-level commit.

---

# 23. FIRST IMPLEMENTATION WAVE

Owner approval sonrası ilk implementation wave:

**Wave 0 — Authority, branch strategy and contract gates**

Neden:
- KA-01'i güvenli kapatır,
- production release branch'i yeni development hattından ayırır,
- persistence/content/artwork IDs için immutable baseline oluşturur,
- sonraki refactorların yanlış source üzerinde yapılmasını önler.

Wave 0 product behavior değiştirmemelidir.

---

# 24. BLOCKER REGISTER

## E-01 — Legacy route word uniqueness conflict

Scope:
- Başlangıç Limanı
- Gökyüzü Adaları
- Orman Yolu
- Kadim Orman

Impact:
- master contract strict route-wide uniqueness bugün mevcut first10 source ile sağlanmıyor.

Blocks:
- Wave 9 strict compiler final sign-off,
- Wave 10 production content completion.

Does not block:
- Waves 0–7 foundation,
- migration architecture,
- route-aware gameplay fix.

Required owner decision:
- correct legacy duplicate content later,
- or explicitly amend master contract with grandfather rule.

Audit bu kararı owner yerine vermez.

---

# 25. FINAL TECHNICAL ANSWERS

- Mandatory persistence migration: **YES — additive schema v3.**
- Storage technology rewrite: **NO.**
- Breaking architecture rewrite: **NO.**
- Existing 10 levels as Segment 1: **YES structurally and for progress preservation.**
- Strict word uniqueness with all legacy content untouched forever: **NO; first four routes conflict.**
- Route-aware gameplay root decision: **catalog-resolved presentation profile + common gameplay engine; no route switch chains.**
- Segment progression state persisted: **NO.**
- Segment metadata first-class: **YES.**
- Segment runtime state: **derived projection.**
- Level name first-class: **YES.**
- Milestone persisted: **NO; derived.**
- True route final: **level100 authority.**
- Book/compass removal state-safe: **YES.**
- Existing info-card ownership migration: **preserve; no reset.**
- Locked environment artwork: **immutable / preserve.**
- Overall: **C core migration with scoped E content blocker.**
