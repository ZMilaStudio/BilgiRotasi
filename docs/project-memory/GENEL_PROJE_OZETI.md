# Bilgi Rotası — Genel Proje Özeti

**Son güncelleme:** 17 Eylül 2026 — Kristal Vadisi / PR #210 production merge kapanışı

## YENİ SOHBETTE ÖNCE BUNLARI OKU

1. `docs/project-memory/GENEL_PROJE_OZETI.md`
2. `docs/project-memory/SOHBET_DEVIR_2026-09-17_KRISTAL_VADISI_KAPANIS.md`
3. `docs/project-memory/SOHBET_DEVIR_2026-09-17_ROUTE_SELECTOR_GUIDED_POLISH_KAPANIS.md`
4. `docs/project-memory/SOHBET_DEVIR_2026-09-17_ROUTE_REWARD_FINAL_CEREMONY_KAPANIS.md`
5. `KELIME_AVI_REUSABLE_HARITA_KARARI.md`

Çelişki halinde öncelik: **canlı GitHub > son kapanış/devir notu > diğer project-memory / karar docs > eski sohbetler**.

> Yeni sohbette exact target HEAD canlı GitHub'dan yeniden doğrulanır. Bu docs kapanış commit'i PR #210 squash merge SHA'sından sonra target HEAD'i ayrıca ilerletir.

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

## SOURCE BRANCH KORUMA

Owner açıkça istemeden source branch silinmez.

Özellikle:
`feat/kelime-avi-kristal-vadisi`

release/tag kapsamında ayrıca owner komutu gerekir.

---

## ŞİMDİKİ DURMA NOKTASI

**Kristal Vadisi rollout production merge + docs kapanışı tamamlandı.**

Yeni feature, release veya tag owner yeni prompt vermeden başlatılmaz.
