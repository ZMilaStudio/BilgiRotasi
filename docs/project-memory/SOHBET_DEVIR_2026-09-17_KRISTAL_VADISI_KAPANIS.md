# SOHBET DEVİR — 17 Eylül 2026 — KRİSTAL VADİSİ PRODUCTION KAPANIŞI

Bu dosya BilgiRotasi / Kelime Avı için **PR #210 — Kristal Vadisi 5. rota rollout** çalışmasının authoritative production kapanış notudur.

## Yeni sohbette okuma sırası

1. `docs/project-memory/GENEL_PROJE_OZETI.md`
2. Bu dosya: `docs/project-memory/SOHBET_DEVIR_2026-09-17_KRISTAL_VADISI_KAPANIS.md`
3. `docs/project-memory/SOHBET_DEVIR_2026-09-17_ROUTE_SELECTOR_GUIDED_POLISH_KAPANIS.md`
4. `docs/project-memory/SOHBET_DEVIR_2026-09-17_ROUTE_REWARD_FINAL_CEREMONY_KAPANIS.md`
5. `KELIME_AVI_REUSABLE_HARITA_KARARI.md`
6. Canlı GitHub target HEAD'i yeniden doğrula.

Çelişki halinde öncelik:
**canlı GitHub > bu kapanış dosyası > diğer project-memory / karar docs > eski sohbetler**.

---

# PR #210 — MERGED

Repo:
`ZMilaStudio/BilgiRotasi`

Target:
`release/final-closed-test-aab-1.68.8`

PR:
`#210 — feat(kelime-avi): add Kristal Vadisi route`

Final state:
**MERGED**

Squash merge SHA:
`008045caac340cd9a14d5e0ebc446a7240782bf3`

Merge parent/base SHA:
`89b4d4bae4af4bda35d77e7e8c52026fce4c271c`

Merge tree SHA:
`3b9e7177ac000d11baf68320252dc6df5fe7d680`

Final PR tip:
`9b3e7b1491b5dba1a36dffab01b6a2e1c34217ac`

Final PR tip tree:
`3b9e7177ac000d11baf68320252dc6df5fe7d680`

**PR tip tree == squash merge tree: EVET.**

---

# APPROVED RUNTIME / VISUAL SOURCE

Approved gated runtime HEAD:
`22b4995a88e0f8937bf716954edba79319d7ec99`

Owner-approved visual commit:
`3c5ff74c16d53ac5acba29ea95406ddf7d8df158`

Approved production runtime tree:
`4485b108c5b36d00af9e08897963c35cfde3dfeb`

`22b4995…` parent olarak `3c5ff74…` commit'ini taşır ve changed file içermez.

**22b4995 tree == 3c5ff74 tree: EVET.**

PR tip gated runtime HEAD sonrasında yalnız iki project-memory docs dosyasında değişiklik taşımıştır. Runtime/code/content/artwork drift yoktur.

---

# OWNER APPROVAL

Owner visual review:
**APPROVED**

Owner final merge approval:
**RECEIVED**

Yeni visual polish yapılmadı ve merge öncesi product/runtime scope değiştirilmedi.

---

# FINAL ROUTE ORDER / PROGRESSION

Production rota sırası artık:

1. Başlangıç Limanı
2. Gökyüzü Adaları
3. Orman Yolu
4. Kadim Orman
5. Kristal Vadisi

Exact chain:

**Başlangıç Limanı → Gökyüzü Adaları → Orman Yolu → Kadim Orman → Kristal Vadisi**

Kristal Vadisi:
- technical route ID: `kristal-vadisi`
- ordinal: **Beşinci rota**
- presentation: `themedReusable`
- unlock prerequisite: Kadim Orman `routeComplete`
- locked copy: **`Kadim Orman’ı tamamlayarak aç.`**
- own `unlockStarsRequired = 0`
- reward ID: `badge-kristal-kasifi`
- reward display: **Kristal Kaşifi**

Kadim Orman artık terminal değildir.
Generic next-catalog davranışı Kadim sonrası Kristal'i döndürür.

Kristal Vadisi terminal production rotadır.

Bütün beş rota complete ise terminal contract:

**`Tüm mevcut rotaları tamamladın.`**

Recommended route algoritması data-driven kalır: ilk `unlocked && !routeComplete` entry.

---

# CONTENT / BALANCE

Owner-approved production content:
- 10 level
- 56 mandatory target
- 14 bonus
- 70 unique route-internal listed word
- 10 deterministic 8×8 grid
- `straightEightDirections`
- listed target/bonus physical occurrence exact-one
- L5 challenge
- L10 routeFinal

L5:
- 3★: 0 mistake + <=30 sec
- 2★: <=1 mistake + <=44 sec

L10:
- 3★: 0 mistake + <=58 sec
- 2★: <=2 mistakes + <=78 sec

`timeLimitSeconds` soft metadata olmaya devam eder; hard timeout değildir.

Info cards:
- `kristal-info-mineral`
- `kristal-info-kuvars`
- `kristal-info-kristal`
- `kristal-info-obsidyen`
- `kristal-info-fay`
- `kristal-info-ametist`

---

# ARTWORK / VISUAL

Production path:
`assets/word_hunt/KRISTAL_VADISI_ENV_941x1672.webp`

Exact immutable contract:
- dimensions `941×1672`
- bytes `2,793,116`
- SHA-256 `189dec3f731f66e72449625457d35d28500fe5cbd5a69ab1f2f04f303ca1bc20`
- Git blob `3f96949385dba4b43b6a4062693e899c47b2f71d`

Artwork SHA değişmedi.

Owner-approved production visual:
- environment artwork
- broken/stepping turquoise path
- tall ambient
- faceted crystal node renderer
- L10 final > L5 challenge > normal hierarchy
- filled 5-prism final crest

Canonical node centers değişmedi.
Canonical hitbox değişmedi.

Reusable renderer generic kaldı; Kristal için route-id özel painter/widget/koordinat sistemi eklenmedi.

---

# PERSISTENCE / HISTORICAL REVEAL

Progress payload schema hâlâ **2**.

- schema 1 backward decode korunur.
- schema 2 current payload'dır.
- unknown future schema fail-closed.
- storage prefix: `bilgi_rotasi_word_hunt_progress_v1_`.
- `unlockedRouteRewardIds` persisted kalır.
- generic reward grant gerçek `routeComplete false → true` transition'ına bağlıdır.
- historical reward backfill sessiz ve idempotent'tır.

Historical four-route-complete kullanıcı:
- Kadim prerequisite zaten complete ise Kristal generic progression ile unlocked olur.
- Kristal selector'da recommended olabilir.
- schema migration hack yapılmaz.
- prerequisite bypass eklenmez.
- normal Kadim→Kristal completion ceremony ile duplicate reveal/message oluşturulmaz.

Bu historical reveal contract production davranışıdır.

---

# FINAL CI GATES

Gated runtime HEAD:
`22b4995a88e0f8937bf716954edba79319d7ec99`

Standard CI:
- Kelime Avı route catalog kapısı — Run #96 / ID `35268797339` — **SUCCESS**
- Kelime Avı Android 16 görsel kanıtı — Run #459 / ID `35268797332` — **SUCCESS**
- Orman Yolu Android çoklu ekran kanıtı — Run #41 / ID `35268797356` — **SUCCESS**
- AdMob PR doğrulaması — Run #836 / ID `35268797543` — **SUCCESS**

Exact-head Android proof:
- Run #7
- Run ID `35268889739`
- Job ID `105362896300`
- conclusion **SUCCESS**

Artifact:
- ID `10517963068`
- name `Kristal-Android-Proof-22b4995`
- size `13,683,837 bytes`

Verified PNG files:
- `KRISTAL_LOCKED_411x731.png` — 411×731
- `KRISTAL_LOCKED_720x1280.png` — 720×1280
- `KRISTAL_LOCKED_1080x1920.png` — 1080×1920
- `KRISTAL_LOCKED_1080x2400.png` — 1080×2400
- `KRISTAL_ACTIVE_FINAL_1080x1920.png` — 1080×1920

Route catalog, Android 16, Orman multi-screen, AdMob ve exact-head proof bütün required final gates için green kapanmıştır.

---

# CUMULATIVE / POST-MERGE GUARD

Pre-merge guard sonucu:
- PR open ve mergeable idi.
- base doğruydu.
- target beklenen `89b4d4…` SHA'sındaydı.
- current PR head `9b3e7b…` idi.
- `22b4995… → 9b3e7b…` yalnız project-memory docs değişikliği taşıyordu.
- runtime/code/content/artwork drift yoktu.

Squash merge sonrasında target merge SHA `008045ca…` oldu.

Merge tree PR tip tree ile birebir aynıydı.

Bu kapanış commit'i yalnız docs dosyalarını değiştirir; code/test/asset/workflow kapsamı yoktur.

---

# DURMA NOKTASI

Kristal Vadisi production rollout tamamlandı.

Release/tag yapılmadı.
Yeni feature başlatılmadı.
Source branch silinmedi.

Owner yeni prompt verene kadar burada DUR.
