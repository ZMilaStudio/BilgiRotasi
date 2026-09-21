# Bilgi Rotası — Genel Proje Özeti

**Son güncelleme:** 21 Eylül 2026 — Kelime Avı 2.0 Wave10A Başlangıç Limanı L11–20 implementation + validation closure

## YENİ SOHBETTE ÖNCE BUNLARI OKU

1. `docs/project-memory/GENEL_PROJE_OZETI.md`
2. `docs/project-memory/SOHBET_DEVIR_2026-09-21_WAVE10A_KAPANIS.md`
3. `docs/project-memory/KELIME_AVI_2_0_IMPLEMENTATION_AUTHORITY.md`
4. `docs/project-memory/KELIME_AVI_2_0_WAVE10_CONTENT_INTEGRATION_CONTRACT.md`
5. `docs/project-memory/KARARLAR.md`
6. Gerektiğinde önceki route/artwork kapanış notları

Çelişki halinde öncelik: **canlı GitHub > son kapanış/devir notu > diğer project-memory / karar docs > eski sohbetler**.

> Yeni sohbette exact integration/release HEAD canlı GitHub'dan yeniden doğrulanır. Docs memory hiçbir zaman canlı GitHub authority'nin yerine geçmez.

---

## 21 EYLÜL 2026 — KELİME AVI 2.0 WAVE10A CURRENT INTEGRATION AUTHORITY

Wave10A **IMPLEMENTATION + VALIDATION COMPLETE** durumundadır.

Implementation green HEAD:
`f6e8464540faeb78e3ff3306b0970335ecc4873a`

Integration branch:
`feat/kelime-avi-2-0-integration`

PR #213:
**OPEN / DRAFT / UNMERGED**

Base:
`release/final-closed-test-aab-1.68.8`

Bu kayıt integration branch authority'sidir; PR #213 henüz production/release branch'e merge edilmemiştir.

Başlangıç Limanı current Wave10A state:
- 20 available / 100 planned
- Segment1 L1–10
- Segment2 L11–20
- L10 Segment1 endpoint
- L20 current content frontier
- L20 true route final değil
- L20 route reward / fake completion / false next-route unlock / L21 navigation üretmez

Diğer yedi route Wave10A kapsamında 10 available level olarak kalır.

Internal progression local 1–100 authority kullanır. Global display projection:
1–100 / 101–200 / 201–300 / 301–400 / 401–500 / 501–600 / 601–700 / 701–800.

Persistence:
- schema v3
- prefix `bilgi_rotasi_word_hunt_progress_v1_`
- old v3 progress preserved
- historical Başlangıç Segment1/access/reward evaluation frozen legacy L1–10 authority üzerinden korunur

Exact implementation validation:
- Cumulative Validation #168 — Run ID `35646621194` — **SUCCESS**
- Content Factory #43 — Run ID `35646621195` — **SUCCESS**
- Route Catalog #264 — Run ID `35646621246` — **SUCCESS**
- Android Visual #648 — Run ID `35646621185` — **SUCCESS**
- Trilogy Runtime #157 — Run ID `35646621192` — **SUCCESS**
- Orman Content #54 — Run ID `35646621186` — **SUCCESS**
- Orman/Kadim #224 — Run ID `35646621268` — **SUCCESS**
- AdMob #1025 — Run ID `35646621209` — **SUCCESS**

**Şimdiki durma noktası:** Wave10A docs-only closure checkpoint + final docs-head validation. Wave10B ayrıca manager checkpoint'idir; bu kayıtla başlamaz.

---

## REPO / PRODUCTION BASELINE

Repo: `ZMilaStudio/BilgiRotasi`

Production target:
`release/final-closed-test-aab-1.68.8`

PR #210:
`feat(kelime-avi): add Kristal Vadisi route`

Durum:
**MERGED**

Squash merge SHA:
`008045caac340cd9a14d5e0ebc446a7240782bf3`

Merge parent/base SHA:
`89b4d4bae4af4bda35d77e7e8c52026fce4c271c`

Merge tree SHA:
`3b9e7177ac000d11baf68320252dc6df5fe7d680`

PR tip tree de `3b9e7177ac000d11baf68320252dc6df5fe7d680` idi; squash merge tree equality **EVET**.

Approved runtime HEAD:
`22b4995a88e0f8937bf716954edba79319d7ec99`

Owner-approved visual commit:
`3c5ff74c16d53ac5acba29ea95406ddf7d8df158`

Approved runtime/visual tree:
`4485b108c5b36d00af9e08897963c35cfde3dfeb`

`22b4995…` ile `3c5ff74…` tree-identical'dır; `22b4995…` yalnız CI retrigger commit'idir ve changed file yoktur.

PR tip `9b3e7b1491b5dba1a36dffab01b6a2e1c34217ac`, gated runtime HEAD sonrasında yalnız project-memory docs değişiklikleri taşımıştır. Runtime/code/content/artwork drift yoktur.

---

# KELİME AVI — AUTHORITATIVE PRODUCTION DURUMU

Production rota sırası artık:

**Başlangıç Limanı → Gökyüzü Adaları → Orman Yolu → Kadim Orman → Kristal Vadisi**

- Başlangıç Limanı: `always`.
- Gökyüzü Adaları: Başlangıç `routeComplete`; final complete + en az 18★.
- Orman Yolu: Gökyüzü `routeComplete`; final complete + en az 18★.
- Kadim Orman: Orman Yolu `routeComplete`; `unlockStarsRequired = 0`, final completion yeterli.
- Kristal Vadisi: Kadim Orman `routeComplete`; Kristal own `unlockStarsRequired = 0`, final completion yeterli.

Kadim Orman artık terminal rota değildir. Generic `nextCatalogEntry(Kadim)` Kristal Vadisi'ni döndürür.

Kristal Vadisi production'da **5. ve terminal rota**dır.

Bütün beş production rota complete ise terminal selector/ceremony contract:

**`Tüm mevcut rotaları tamamladın.`**

Tek recommended rota hâlâ catalog sırasındaki ilk:

`unlocked && !routeComplete`

entry'dir.

---

## KRİSTAL VADİSİ — PRODUCTION CONTRACT

- title: **Kristal Vadisi**
- technical route ID: `kristal-vadisi`
- ordinal: **Beşinci rota**
- presentation: `themedReusable`
- unlock: Kadim Orman `routeComplete`
- locked copy: **`Kadim Orman’ı tamamlayarak aç.`**
- reward ID: `badge-kristal-kasifi`
- reward display: **Kristal Kaşifi**
- own completion threshold: `unlockStarsRequired = 0`
- canonical progression: `1→2→3→4→5→6→7→8→9→10`
- canonical grid: **8×8 / 64 hücre**

Content owner-approved ve production'dadır:
- 10 level
- 56 mandatory target
- 14 bonus
- 70 unique route-internal listed word
- deterministic 8×8 grids
- `straightEightDirections`
- listed target/bonus exact-one physical occurrence
- L5 challenge
- L10 routeFinal
- 6 info card

L5:
- 3★ = 0 mistake + <=30 sec
- 2★ = <=1 mistake + <=44 sec

L10:
- 3★ = 0 mistake + <=58 sec
- 2★ = <=2 mistakes + <=78 sec

`timeLimitSeconds` soft metadata contract'ı korunur; hard timeout değildir.

---

## ARTWORK / VISUAL CONTRACT

Production artwork:
`assets/word_hunt/KRISTAL_VADISI_ENV_941x1672.webp`

Immutable exact contract:
- dimensions: `941×1672`
- bytes: `2,793,116`
- SHA-256: `189dec3f731f66e72449625457d35d28500fe5cbd5a69ab1f2f04f303ca1bc20`
- Git blob: `3f96949385dba4b43b6a4062693e899c47b2f71d`

Owner visual review: **APPROVED**.

Background, broken/stepping turquoise path, tall ambient ve son crystal node treatment owner-approved production visual'ıdır.

Canonical node centers ve hitbox değişmedi.

Renderer generic `WordHuntRouteNodeVisualStyle.facetedCrystal` üzerinden çalışır; route-id özel painter/widget/koordinat listesi eklenmedi.

Final hierarchy:
**L10 > L5 > normal**.

---

## PERSISTENCE / HISTORICAL USER CONTRACT

Progress schema hâlâ **2**.

- schema 1 backward decode korunur.
- schema 2 current payload'dır.
- unknown future schema fail-closed kalır.
- storage prefix değişmedi: `bilgi_rotasi_word_hunt_progress_v1_`.
- reward grant yalnız gerçek `routeComplete false → true` transition'ında olur.
- reward backfill sessiz ve idempotent'tır.

Historical four-route-complete kullanıcı için Kristal Vadisi generic progression üzerinden unlocked + recommended olur.

Historical reveal contract schema/progression hack kullanmaz; normal Kadim→Kristal ceremony ile duplicate reveal/message üretmez.

---

## FINAL CI / ANDROID PROOF KAPANIŞI

Approved gated runtime HEAD:
`22b4995a88e0f8937bf716954edba79319d7ec99`

Standard gates:
- Kelime Avı route catalog kapısı — Run #96 / ID `35268797339` — **SUCCESS**
- Kelime Avı Android 16 görsel kanıtı — Run #459 / ID `35268797332` — **SUCCESS**
- Orman Yolu Android çoklu ekran kanıtı — Run #41 / ID `35268797356` — **SUCCESS**
- AdMob PR doğrulaması — Run #836 / ID `35268797543` — **SUCCESS**

Exact-head Kristal Android proof:
- Run #7 / ID `35268889739` — **SUCCESS**
- job ID `105362896300`
- artifact ID `10517963068`
- artifact name `Kristal-Android-Proof-22b4995`
- artifact size `13,683,837 bytes`

Verified PNG set:
- `KRISTAL_LOCKED_411x731.png` — 411×731
- `KRISTAL_LOCKED_720x1280.png` — 720×1280
- `KRISTAL_LOCKED_1080x1920.png` — 1080×1920
- `KRISTAL_LOCKED_1080x2400.png` — 1080×2400
- `KRISTAL_ACTIVE_FINAL_1080x1920.png` — 1080×1920

---

## MERGED KELİME AVI MILESTONES

- Reusable 10-level map architecture — MERGED
- Kadim Orman runtime/content — MERGED
- Linear route progression — MERGED
- Challenge/final progressive star-time balance — PR #207 MERGED
- Route reward + final ceremony — PR #208 MERGED
- Guided route selector progression — PR #209 MERGED
- Kristal Vadisi 5. rota — PR #210 MERGED

---

# YENİ OWNER ÜRÜN KARARI — KAYIP ŞEHİR EVRENİ

**Durum:** OWNER PRODUCT DECISION / DESIGN-ONLY NEXT PHASE

Kristal Vadisi sonrasında gelecek yeni dünya için yapı kesinleşmiştir:

**KAYIP ŞEHİR EVRENİ = 3 ayrı rota × 10 bölüm = 30 yeni bölüm.**

Bu dünya tek 10 bölümlük rota olarak tasarlanmayacaktır.

Mevcut production kapsamı:
- 5 rota
- 50 bölüm

Kayıp Şehir Evreni tamamlandığında planlanan toplam:
- 8 rota
- 80 bölüm

### Üçlemeli rota yapısı

6. **Kayıp Şehir** — 10 bölüm
7. **Yeraltı Krallığı** — 10 bölüm
8. **Güneş İmparatorluğu** — 10 bölüm

Bu üç isim owner ürün kararının mevcut design baseline'ıdır. Implementation başlamadan önceki ürün tasarımı aşamasında adlar ayrıca son kez doğrulanıp freeze edilecektir.

Üç rota aynı anlatı evreninde birbirinin devamıdır; ancak her rota **ayrı görsel, tematik ve atmosferik kimlik** taşımalıdır.

### 6. rota — Kayıp Şehir

Tematik yön:
- yüzey keşfi
- çöl
- kum altında kalmış şehir
- eski kapılar
- çarşılar
- avlular
- saray kalıntıları
- tapınak kalıntıları

Görsel palet / materyal yönü:
- sıcak kum
- terracotta
- turkuaz
- eski altın

Duygusal/narrative işlev:
**ŞEHRİ BUL.**

### 7. rota — Yeraltı Krallığı

Tematik yön:
- şehrin altındaki ikinci dünya
- tüneller
- sarnıçlar
- mühürlü odalar
- antik mekanizmalar
- gizli geçitler
- mezar odaları
- hazine odaları

Görsel palet / ışık yönü:
- lacivert
- bakır
- turkuaz
- meşale ışığı

Atmosfer:
- gizemli
- keşif odaklı
- **korku DEĞİL**

Duygusal/narrative işlev:
**ŞEHRİN ALTINDAKİ SIRRI KEŞFET.**

### 8. rota — Güneş İmparatorluğu

Üçlemenin büyük final rotasıdır.

Tematik yön:
- kayıp uygarlığın merkezi
- astronomi
- kutsal alanlar
- dev tapınaklar
- kraliyet salonları
- altın mekanizmalar
- görkemli final

Görsel palet / materyal yönü:
- eski altın
- kızıl
- koyu mavi
- açık taş tonları

L10 büyük final yönü:
**Güneş Tahtı 👑**

Duygusal/narrative işlev:
**KAYIP İMPARATORLUĞUN MERKEZİNE ULAŞ.**

### Narrative progression

**ŞEHRİ BUL**
→ **ŞEHRİN ALTINDAKİ SIRRI KEŞFET**
→ **KAYIP İMPARATORLUĞUN MERKEZİNE ULAŞ**

Bu progression üç rotanın birbirini takip eden tek bir büyük macera gibi hissedilmesini sağlamalı; buna rağmen rota bazında görsel kimlikler birbirine karışmamalıdır.

### Şimdilik kesinlikle yapılmayacaklar

Bu ürün kararı aşamasında:
- kod yazılmayacak,
- branch açılmayacak,
- PR açılmayacak,
- asset üretilmeyecek,
- test kapsamı eklenmeyecek,
- mevcut production rotalar değiştirilmeyecek,
- unlock/reward/schema/runtime implementasyonu yapılmayacak.

### Sonraki aşama — yalnız ürün tasarımı

Owner yeni komut verdiğinde yalnız şu konular tasarlanacaktır:
- üç rotanın kesin adlarının son doğrulaması,
- 30 bölümün adları,
- 30 bölümün tema dağılımı,
- target / bonus kelime setleri,
- info card planı,
- her rotanın L5 challenge yapısı,
- her rotanın L10 final yapısı,
- üç haritanın ayrı görsel kimliği,
- üç rota için unlock zinciri,
- üç rota için reward isimleri.

Bu maddeler tasarım aşamasında netleşmeden implementation başlamaz.

---

## SOURCE BRANCH KORUMA

Owner açıkça istemeden source branch silinmez.

Özellikle:
`feat/kelime-avi-kristal-vadisi`

release/tag kapsamında ayrıca owner komutu gerekir.

---

## ŞİMDİKİ DURMA NOKTASI

**Kristal Vadisi rollout production merge + docs kapanışı tamamlandı.**

**Kayıp Şehir Evreni için 3×10 / 30 bölüm owner ürün kararı kaydedildi.**

Bir sonraki aşama yalnız **ürün tasarımıdır**. Owner yeni prompt vermeden:
- kod yazılmaz,
- branch/PR açılmaz,
- asset üretilmez,
- production rotalar değiştirilmez,
- implementation başlatılmaz,
- release/tag yapılmaz.

**Owner komutu beklenir.**
