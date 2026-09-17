# Kelime Avı — Reusable Harita Mimari Kararı

**Karar tarihi:** 12 Eylül 2026  
**Son durum güncellemesi:** 17 Eylül 2026

Bu belge, Kelime Avı'nın reusable 10-bölümlük rota mimarisi ile production kararlarını authoritative olarak kaydeder.

## Kilitli reusable harita sözleşmesi

- Her rota 10 bölümden oluşur.
- Canonical sıra **1 → 2 → 3 → 4 → 5 → 6 → 7 → 8 → 9 → 10**.
- **8. bölüm bonus değildir; normal bölümdür.**
- 10 node'un geometri/hitbox kaynağı tek reusable motordur; rota bazında ayrı node koordinat listesi yazılmaz.
- Yol geometrisi ortak motor tarafından deterministik üretilir.
- Yeni rota için ayrı ekran/widget yazılmaz; generic ekran route + visualTheme verisiyle çalışır.
- Görsel skin verisi `WordHuntRouteVisualTheme` içinde tutulur; progression/hitbox mantığını taşımaz.
- Embedded-route artwork modunda dekoratif rota raster içindedir; live Flutter route painter ikinci kez çizilmez.
- Rota-id özel Widget/Painter/koordinat listesi reusable mimariyle uyumsuz kabul edilir.

## Production route baseline

Sıra:

**Başlangıç Limanı → Gökyüzü Adaları → Orman Yolu → Kadim Orman**

Unlock contract:

- Başlangıç Limanı: `always`.
- Gökyüzü Adaları: Başlangıç `routeComplete`; final complete + en az 18 yıldız.
- Orman Yolu: Gökyüzü `routeComplete`; final complete + en az 18 yıldız.
- Kadim Orman: Orman Yolu `routeComplete`; `unlockStarsRequired = 0`, final completion yeterli.

`WordHuntRouteUnlockRule.routeComplete`, `WordHuntRouteProgressEngine.isRouteComplete(prerequisiteRoute, progress)` kullanır. Legacy downstream progress prerequisite'i bypass ettiremez; ancak silinmez ve prerequisite sağlanınca korunur.

## Kadim Orman runtime/content baseline

- technical route id: `orman-2`
- user-facing title: **Kadim Orman**
- visual theme id: `orman-2-production`
- route reward id: `badge-kadim-orman-kasifi`
- reward display: **Kadim Orman Kaşifi**
- özgün level id'leri: `orman-2-01` … `orman-2-10`
- 10 özgün deterministic 8×8 grid + özgün target/bonus content + 6 özgün info card
- Orman Yolu gameplay clone/reuse yoktur.

Immutable asset:

`assets/word_hunt/ORMAN2_FINAL_941x1672.webp`

- dimensions: 941×1672
- bytes: 1.109.268
- SHA-256: `aede5c6f08b6fe4cd64d17a1ef309e13256dde1c1e97fbee0c53b019f63c6c8d`
- Git blob SHA: `43233bf2b0e8f16d59a15f0fe0bcda5f5e2bb80c`
- re-encode / recompress / resize / crop / recolor yapılmaz.

## Generic/data-driven production book

Tüm production rotaları aynı bilgi kartı contract'ını kullanır:

`_activeInfoCards + _progress.unlockedInfoCardIds`

Legacy forest özel book branch'leri kaldırılmıştır. Kitap yalnız aktif rotanın unlock edilmiş kartlarını gösterir. Cross-route card isolation korunur.

---

## Challenge / final progressive star-time balance — TAMAMLANDI / MERGED

PR #207 — `feat(kelime-avi): balance challenge and final stars`

- approved head: `9bbc3b8c6303dc390c79a2d178c03b803830c80c`
- approved head tree: `7876ea9455465c3c1842cd391a94af9ab8365f6b`
- squash merge commit: `4ffe63500363e6d976bb211f5e7d547a69859df9`
- merge tree: `7876ea9455465c3c1842cd391a94af9ab8365f6b`
- tree equality: **EVET**

Normal levels (`L1-L4`, `L6-L9`) mistake odaklıdır ve seconds threshold yoktur.

L5 Challenge: 3★ = 0 hata + rota-specific 3★ süre; 2★ = <=1 hata + rota-specific 2★ süre.  
L10 Final: 3★ = 0 hata + rota-specific 3★ süre; 2★ = <=2 hata + rota-specific 2★ süre.  
Target tamamlanmadıysa 0★; mistake+time birlikte varsa AND; boundary inclusive (`<=`).

| Rota | L5 3★ sec | L5 2★ sec | L10 3★ sec | L10 2★ sec |
|---|---:|---:|---:|---:|
| Başlangıç Limanı | 35 | 50 | 75 | 100 |
| Gökyüzü Adaları | 35 | 50 | 75 | 100 |
| Orman Yolu | 25 | 36 | 50 | 66 |
| Kadim Orman | 24 | 35 | 48 | 64 |

`timeLimitSeconds` 60/120 soft metadata'dır; hard fail değildir ve scoring engine tarafından kullanılmaz.

---

## Route reward + final ceremony — TAMAMLANDI / MERGED

PR #208 — `feat(kelime-avi): add route rewards and completion ceremony`

- approved head: `0d724e7544811cf74c85b9058800cee8396fea67`
- approved head tree: `93c2858d3a37903564ec0cf4993d100c5442e9aa`
- squash merge commit: `c880550ef41841608d8aa664f6c24c54f3dd067d`
- merge tree: `93c2858d3a37903564ec0cf4993d100c5442e9aa`
- tree equality: **EVET**
- squash parent: `62969dfe17d660beae58aafca95168eaa64f057c`

### Authoritative reward catalog

| Rota | routeRewardId | Display |
|---|---|---|
| Başlangıç Limanı | `badge-kelime-yolcusu` | Kelime Yolcusu |
| Gökyüzü Adaları | `badge-gokyuzu-kasifi` | Gökyüzü Kaşifi |
| Orman Yolu | `badge-orman-kasifi` | Orman Kaşifi |
| Kadim Orman | `badge-kadim-orman-kasifi` | Kadim Orman Kaşifi |

Reward grant yalnız gerçek `routeComplete false → true` transition'ında olur. `WordHuntProgressSnapshot` kalıcı `bestStarsByLevelId`, `unlockedInfoCardIds`, `unlockedRouteRewardIds` taşır.

Payload schema **2**'dir. Decoder schema **1 ve 2**'yi destekler; unknown future schema fail-closed kalır. Storage prefix: `bilgi_rotasi_word_hunt_progress_v1_`.

Historical schema-v1 progress stars/infoCards kaybetmeden açılır; eksik reward'lar sessiz, sadece-ekleme ve idempotent backfill ile tamamlanır.

Route-final presentation:
- Normal level: **`Bölüm Tamamlandı`**
- Incomplete first final: **`Final Tamamlandı`** + `Rotayı tamamlamak için X yıldız daha kazan.`
- Gerçek routeComplete: **`Rota Tamamlandı!`** + reward + varsa `<Gelecek rota adı> açıldı.`
- Kadim terminal copy: **`Tüm mevcut rotaları tamamladın.`**

`WordHuntLevelProductionScreen.deferCompletionDialog` first-route-final double-dialog'u önler; exit confirmation korunur.

---

## Guided route selector progression — TAMAMLANDI / MERGED

PR #209 — `feat(kelime-avi): guide route selector progression`

- approved head: `5da106f4c52d7e8533d91878c8482b835a8b9dca`
- approved head tree: `a71691ecfe04ff2850aa67fa0b6f08aafaa667bf`
- squash merge commit: `92135e01a2c22f37441a4d7192265f3d9902ebc0`
- squash merge tree: `a71691ecfe04ff2850aa67fa0b6f08aafaa667bf`
- tree equality: **EVET**
- squash parent: `8c810d46f4d2fb12616e97bfba310c2a2e2716a4`
- source branch: `feat/kelime-avi-route-selector-guided-polish` — owner istemeden silinmez.

### Recommended / completed / reward state

Selector'daki tek recommended rota catalog sırasındaki ilk:

`unlocked && !routeComplete`

rotadır.

- progress yok → **`Sıradaki`**
- progress var → **`Devam Et`**
- routeComplete → **`Tamamlandı`**
- rewardEarned → **`Rozet kazanıldı`**

Completion ve reward ownership ayrı hesaplanır. Reward state unlock/progression üretmez.

Bütün mevcut production rotalar complete ise recommended rota yoktur ve selector header exact:

**`Tüm mevcut rotaları tamamladın.`**

### Progress / locked requirement contract

Unlocked rota progress'i:

**`X / Y yıldız`**

ve maximum `route.maximumStars` üzerinden türetilir.

`routeComplete` prerequisite locked progress:

- prerequisite final incomplete → **`X / Y bölüm`**
- prerequisite final complete + yıldız gate eksik → **`X / required yıldız`**
- prerequisite `unlockStarsRequired == 0` → bölüm/final progress

Kritik örnek:

Başlangıç final complete +17★:
- Başlangıç **`Devam Et`**, `17 / 30 yıldız`
- Gökyüzü locked, authoritative locked copy + **`17 / 18 yıldız`**

Gökyüzü final complete +17★ → Orman **`17 / 18 yıldız`**.

Orman→Kadim için yapay 18★ gate yoktur.

### Locked identity / interaction / ordinal

Locked route identity icon korunur; generic büyük leading lock ile değiştirilmez. Lock ayrı treatment ile anlatılır.

Locked card tap:
- route açmaz,
- `onRouteTap` çağırmaz,
- authoritative locked reason SnackBar gösterir.

Ordinal bütün state'lerde görünür:

**İlk rota / İkinci rota / Üçüncü rota / Dördüncü rota**

### Responsive / semantics baseline

Focused regression:
- 320×640 PASS
- 360×800 PASS
- 411×731 PASS
- 480 px reachability PASS
- 320 px + 1.5 text scale PASS
- semantics PASS

Status chip overflow testle yakalanmış, test gevşetilmeden `Wrap` tabanlı production presentation ile düzeltilmiştir.

Card-level tek authoritative semantics label kullanılır; nested visual children semantics'ten dışlanır ve duplicate reward announce oluşmaz.

### PR #209 CI baseline

Approved exact head `5da106f4c52d7e8533d91878c8482b835a8b9dca`:

- Kelime Avı route catalog kapısı — Run #92 / ID `35217743668` — SUCCESS
- Orman Yolu Android çoklu ekran kanıtı — Run #37 / ID `35217743501` — SUCCESS
- Kelime Avı Android 16 görsel kanıtı — Run #455 / ID `35217743468` — SUCCESS
- AdMob PR doğrulaması — Run #832 / ID `35217743499` — SUCCESS
- analyze/full tests, release APK, package/merged manifest, Android 16 cold-start deneme 1 ve final application gate — SUCCESS

Kelime Avı Orman Yolu içerik kapısı selector-only path filter nedeniyle yeni run üretmedi.

---

## Sıradaki audit — KELİME AVI / 5. ROTA READINESS / ÜRÜN + TEKNİK AUDIT

İlk tur yalnız audit olacak. Owner kararı verilmeden route/content/asset/branch/PR oluşturulmaz.

İncelenecek ana başlıklar:

1. Mevcut dört rota progression zinciri.
2. Catalog'un 5. entry eklemeye hazır olup olmadığı.
3. Selector recommended algoritmasının 5. rotayı otomatik kapsayıp kapsamadığı.
4. `Tüm mevcut rotaları tamamladın.` state'inin data-driven taşınması.
5. Kadim terminal ceremony'nin 5. rota eklenince next-route ceremony'ye dönüşmesi.
6. `WordHuntRouteRewardEngine.nextCatalogEntry()` davranışı.
7. Kadim→5. rota unlock prerequisite contract'ı.
8. 5. rota routeRewardId / reward metadata.
9. Progress schema ve historical users/backfill etkisi.
10. Reusable themed renderer / map architecture ve asset yaklaşımı.
11. Content difficulty curve, L5 challenge / L10 final balance ve info-card contract.
12. Rota adı / tema / atmosfer alternatifleri ve mevcut rotalarla ayrışma.
13. Kadim terminal copy/testlerinin gelecekteki etkisi.
14. Terminal all-routes-complete state'in 5. rotaya taşınması.
15. Test / CI kapsamı.

**Audit sonrası owner kararı olmadan 5. rota implementasyonu yapılmaz.**

## Source branch koruma

Owner açıkça istemeden silinmez:

- `feat/kelime-avi-route-selector-guided-polish`
- `feat/kelime-avi-route-reward-ceremony`
- `feat/kelime-avi-progressive-challenge-final-balance`
- `feat/kelime-avi-linear-route-progression`
- `feat/kelime-avi-orman-yolu-content-polish`
- `feat/kelime-avi-kadim-orman-original-content`
- `feat/kelime-avi-kadim-orman-progression`
- `feat/kelime-avi-orman2-runtime-pilot-20260916`

**Durum:** REUSABLE 10-LEVEL MAP ARCHITECTURE — MERGED. KADİM ORMAN RUNTIME/CONTENT — MERGED. LINEER ROUTE PROGRESSION — MERGED. CHALLENGE/FINAL BALANCE — MERGED. ROUTE REWARD + FINAL CEREMONY — MERGED. GUIDED ROUTE SELECTOR POLISH — MERGED / CI GREEN. SIRADAKİ KONU — 5. ROTA READINESS / ÜRÜN + TEKNİK AUDIT.
