# Bilgi Rotası — Genel Proje Özeti

**Son güncelleme:** 17 Eylül 2026 — Kristal Vadisi / PR #210 owner visual review devri

## YENİ SOHBETTE ÖNCE BUNLARI OKU

1. `docs/project-memory/GENEL_PROJE_OZETI.md`
2. `docs/project-memory/SOHBET_DEVIR_2026-09-17_KRISTAL_VADISI_PR210_OWNER_VISUAL_REVIEW.md`
3. `docs/project-memory/SOHBET_DEVIR_2026-09-17_ROUTE_SELECTOR_GUIDED_POLISH_KAPANIS.md`
4. `docs/project-memory/SOHBET_DEVIR_2026-09-17_ROUTE_REWARD_FINAL_CEREMONY_KAPANIS.md`
5. `KELIME_AVI_REUSABLE_HARITA_KARARI.md`

Çelişki halinde öncelik: **canlı GitHub > son sohbet devir notu > project-memory / karar docs > eski sohbetler**.

> **YENİ SOHBET DUR KURALI:** Dosyaları okuduktan sonra kullanıcı yeni prompt vermeden hiçbir işe devam etme. CI takip etme, commit/PR/merge yapma, kod/test/docs/asset değiştirme. Bağlamı devral ve komut bekle.

---

## REPO / CANLI BASELINE

Repo: `ZMilaStudio/BilgiRotasi`

Production target:
`release/final-closed-test-aab-1.68.8`

Target HEAD, bu özet hazırlanırken:
`89b4d4bae4af4bda35d77e7e8c52026fce4c271c`

Target'ta merge edilmiş son büyük Kelime Avı işleri:
- PR #207 challenge/final balance → `4ffe63500363e6d976bb211f5e7d547a69859df9`
- PR #208 route reward/final ceremony → `c880550ef41841608d8aa664f6c24c54f3dd067d`
- PR #209 guided route selector polish → `92135e01a2c22f37441a4d7192265f3d9902ebc0`
- PR #209 docs closure → target HEAD `89b4d4bae4af4bda35d77e7e8c52026fce4c271c`

**Production target henüz dört rota taşır. Kristal Vadisi PR #210 merge edilmemiştir.**

Production rota sırası target'ta:

**Başlangıç Limanı → Gökyüzü Adaları → Orman Yolu → Kadim Orman**

---

## MERGED AUTHORITATIVE KELİME AVI CONTRACT'LARI

### Progression

- Her rota 10 bölüm; canonical progression `1→2→3→4→5→6→7→8→9→10`.
- Grid: **8×8 / 64 hücre**.
- Başlangıç Limanı: always unlocked.
- Gökyüzü Adaları: Başlangıç routeComplete; final + en az 18★.
- Orman Yolu: Gökyüzü routeComplete; final + en az 18★.
- Kadim Orman: Orman Yolu routeComplete; `unlockStarsRequired = 0`, final completion yeterli.
- `routeComplete`: `WordHuntRouteProgressEngine.isRouteComplete(route, progress)`.

### Challenge / final star-time contract

Normal seviyeler seconds threshold kullanmaz.

L5 challenge:
- 3★ = 0 hata + route-specific 3★ süre
- 2★ = <=1 hata + route-specific 2★ süre
- completion fallback = 1★

L10 routeFinal:
- 3★ = 0 hata + route-specific 3★ süre
- 2★ = <=2 hata + route-specific 2★ süre
- completion fallback = 1★

`timeLimitSeconds` soft metadata'dır; hard timeout değildir.

Merged dört rota matrix:

| Rota | L5 3★ | L5 2★ | L10 3★ | L10 2★ |
|---|---:|---:|---:|---:|
| Başlangıç | 35 sn / 0 hata | 50 sn / <=1 | 75 sn / 0 hata | 100 sn / <=2 |
| Gökyüzü | 35 / 0 | 50 / <=1 | 75 / 0 | 100 / <=2 |
| Orman | 25 / 0 | 36 / <=1 | 50 / 0 | 66 / <=2 |
| Kadim | 24 / 0 | 35 / <=1 | 48 / 0 | 64 / <=2 |

### Reward / persistence

Authoritative merged reward IDs:

| Rota | routeRewardId | Display |
|---|---|---|
| Başlangıç Limanı | `badge-kelime-yolcusu` | Kelime Yolcusu |
| Gökyüzü Adaları | `badge-gokyuzu-kasifi` | Gökyüzü Kaşifi |
| Orman Yolu | `badge-orman-kasifi` | Orman Kaşifi |
| Kadim Orman | `badge-kadim-orman-kasifi` | Kadim Orman Kaşifi |

Reward grant yalnız gerçek `routeComplete false → true` transition'ında olur. Duplicate grant/reveal yoktur.

`WordHuntProgressSnapshot`:
- `bestStarsByLevelId`
- `unlockedInfoCardIds`
- `unlockedRouteRewardIds`

taşır.

Payload schema **2**; schema **1 ve 2** decode edilir, unknown future schema fail-closed. Storage prefix korunur:
`bilgi_rotasi_word_hunt_progress_v1_`

Schema-v1 historical save için stars/infoCards korunur; reward backfill sessiz ve idempotent'tır.

### Completion ceremony

Normal level: **`Bölüm Tamamlandı`**.

Route final tamamlandı ama routeComplete değil: **`Final Tamamlandı`** + eksik yıldız copy'si.

Gerçek routeComplete transition: **`Rota Tamamlandı!`** + reward + varsa `<Gelecek rota> açıldı.`.

Route-final generic double dialog `deferCompletionDialog` ile suppress edilir; exit confirmation korunur.

Target'ta Kadim mevcut son rota olduğu için terminal copy:
**`Tüm mevcut rotaları tamamladın.`**

### Guided selector

Tek recommended rota catalog sırasındaki ilk:

`unlocked && !routeComplete`

- progress yok → **Sıradaki**
- progress var → **Devam Et**
- complete → **Tamamlandı**
- reward owned → **Rozet kazanıldı**

Locked requirement:
- prerequisite final incomplete → `X / Y bölüm`
- final complete + star gate eksik → `X / required yıldız`
- threshold 0 → bölüm/final progress

Kritik örnek:
Başlangıç final +17★ → Başlangıç **Devam Et**, Gökyüzü locked **17 / 18 yıldız**.

Locked tap route açmaz; authoritative reason SnackBar verir. Route identity ve ordinal locked halde korunur.

Selector responsive regression baseline:
- 320×640
- 360×800
- 411×731
- 480 reachability
- 320 + 1.5 text scale

---

# AKTİF İŞ — PR #210 / KRİSTAL VADİSİ

PR:
`#210 — feat(kelime-avi): add Kristal Vadisi route`

Feature branch:
`feat/kelime-avi-kristal-vadisi`

PR durumu bu özet hazırlanırken:
- OPEN
- DRAFT
- merged=false
- mergeable=true

PR base:
`release/final-closed-test-aab-1.68.8`

Son runtime feature HEAD, docs devrinden hemen önce:
`22b4995a88e0f8937bf716954edba79319d7ec99`

Parent visual polish commit:
`3c5ff74c16d53ac5acba29ea95406ddf7d8df158`

`22b4995…` yalnız tree-identical CI retrigger commit'idir; changed file yoktur. Runtime tree:
`4485b108c5b36d00af9e08897963c35cfde3dfeb`

Bu summary + handoff docs commit'leri feature branch HEAD'ini yalnız docs değişikliğiyle ilerletebilir. Yeni sohbet canlı HEAD'i doğrulamalı ve runtime tree ile docs-only HEAD'i ayırmalıdır.

## Kristal route identity

- title: **Kristal Vadisi**
- technical ID: `kristal-vadisi`
- ordinal: **Beşinci rota**
- presentation: `themedReusable`
- unlock: Kadim Orman routeComplete
- locked copy: **`Kadim Orman’ı tamamlayarak aç.`**
- own `unlockStarsRequired = 0`
- reward ID: `badge-kristal-kasifi`
- reward display: **Kristal Kaşifi**

Feature merge edilirse rota sırası:

**Başlangıç → Gökyüzü → Orman → Kadim → Kristal**

Kadim non-terminal olur; Kristal terminal olur.

Historical four-complete user için Kristal generic progression üzerinden unlocked + recommended olur. Historical reveal implementation varsa schema/progression hack yapmamalı ve normal Kadim→Kristal ceremony ile duplicate mesaj üretmemelidir.

## Kristal content — owner approved

- 10 levels
- 56 mandatory target
- 14 bonus
- 70 unique route-internal word
- deterministic 8×8 grids
- `straightEightDirections`
- listed target/bonus exact-one physical occurrence
- L5 = challenge
- L10 = routeFinal

L5:
- 3★ <=30 sec + 0 mistake
- 2★ <=44 sec + <=1 mistake

L10:
- 3★ <=58 sec + 0 mistake
- 2★ <=78 sec + <=2 mistakes

Info cards:
`kristal-info-mineral`, `kristal-info-kuvars`, `kristal-info-kristal`, `kristal-info-obsidyen`, `kristal-info-fay`, `kristal-info-ametist`.

## Kristal approved environment artwork

Path:
`assets/word_hunt/KRISTAL_VADISI_ENV_941x1672.webp`

Exact immutable candidate contract:
- 941×1672
- 2,793,116 bytes
- SHA-256 `189dec3f731f66e72449625457d35d28500fe5cbd5a69ab1f2f04f303ca1bc20`
- Git blob `3f96949385dba4b43b6a4062693e899c47b2f71d`

**Artwork değiştirilmez:** regenerate/re-encode/resize/crop/recolor/edit yok.

Owner visual review'da background, broken/stepping turquoise path ve tall ambient **APPROVED**. Yeni prompt açıkça istemedikçe bunları kurcalama.

## Kristal node renderer — son owner talebi ve implementation

Run #4 Android artifact teknik PASS olmasına rağmen owner node visual'ı reddetti. Root visual problem:

**Painter detayı değil, gerçek pixel footprint ve silhouette küçüktü.**

Owner son hedefi:
**BIGGER + SIMPLER + STRONGER SILHOUETTE**; 411×731 ana referans.

Son visual polish implementation (`3c5ff74…`) generic `facetedCrystal` renderer'a şu metrikleri verdi:

- normalScale `1.00`
- challengeScale `1.06`
- finalScale `1.11`
- normal body `48×46`
- normal shard silhouette `58`
- final body `52×50`
- final shard silhouette `62`
- final crest `52×32`

Canonical geometry ve hitbox değişmedi.

Normal node:
- büyük amethyst gem body
- 6 belirgin shard
- daha az fakat büyük facet planes
- turquoise/mineral ring

Locked normal:
- smoky violet/obsidian gem
- silver/lavender ring/shards
- integrated crystal lock badge

L5:
- %6 civarı scale
- gold accent
- finalden daha basit silhouette

L10:
- final medallion + double/faceted ring
- **5 filled crystal prism crest**
- locked dormant silver/lavender
- active amethyst + gold edge + turquoise accent
- outline crown / Material crown yok

Hierarchy contract:
**L10 FINAL > L5 CHALLENGE > NORMAL**

## Son Android proof

Visual runtime tree `3c5ff74…` üzerinde:

Run ID: `35267683267` — **SUCCESS**

Artifact:
- ID `10518395359`
- `Kristal-Android-Proof-3c5ff74`
- 13,688,635 bytes

PNG set:
- `KRISTAL_LOCKED_411x731.png`
- `KRISTAL_LOCKED_720x1280.png`
- `KRISTAL_LOCKED_1080x1920.png`
- `KRISTAL_LOCKED_1080x2400.png`
- `KRISTAL_ACTIVE_FINAL_1080x1920.png`

Asistanın son inspection sonucu: 411 px'de medallion/shard formu daha belirgin; locked seals daha kristal/obsidyen; L10 crest artık dolu 5-prism formation; active L10 en prestijli treatment olarak okunuyor.

**Owner bu son artifact setine henüz final görsel onay vermedi. PR #210 merge-ready kabul edilmez.**

## CI snapshot

Runtime HEAD `22b4995…` üzerinde devir hazırlanırken:

- Route catalog gate — Run #96 / `35268797339` — **SUCCESS**
- Kelime Avı Android 16 — Run #459 / `35268797332` — **IN PROGRESS**
- Orman multi-screen — Run #41 / `35268797356` — **IN PROGRESS**
- AdMob PR validation — Run #836 / `35268797543` — **IN PROGRESS**

Exact runtime-head Android proof rerun:
- Run `35268889739`
- Job `105362896300`
- devir anında capture süreci henüz tamamlanmamıştı.

Bunlar snapshot'tır. Prompt geldiğinde live GitHub yeniden doğrulanmalıdır.

---

## SOURCE BRANCH KORUMA

Owner açıkça istemeden silinmez:

- `feat/kelime-avi-kristal-vadisi`
- `feat/kelime-avi-route-selector-guided-polish`
- `feat/kelime-avi-route-reward-ceremony`
- `feat/kelime-avi-progressive-challenge-final-balance`
- `feat/kelime-avi-linear-route-progression`
- `feat/kelime-avi-orman-yolu-content-polish`
- `feat/kelime-avi-kadim-orman-original-content`
- `feat/kelime-avi-kadim-orman-progression`
- `feat/kelime-avi-orman2-runtime-pilot-20260916`

---

## ŞİMDİKİ DURMA NOKTASI

Aktif iş: **PR #210 Kristal Vadisi owner visual + technical approval bekliyor.**

Yeni sohbet bu noktada **kendiliğinden devam etmeyecek**.

Kullanıcı prompt vermeden:
- CI takip etme,
- yeni artifact indirme,
- screenshot inceleme,
- kod/test/docs değiştirme,
- commit atma,
- PR body/state değiştirme,
- merge etme,
- source branch silme,
- release/tag oluşturma.

**Sadece devri al ve owner komutunu bekle.**
