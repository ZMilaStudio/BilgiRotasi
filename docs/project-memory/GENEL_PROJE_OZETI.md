# Bilgi Rotası — Genel Proje Özeti

**Son güncelleme:** 17 Eylül 2026

## YENİ SOHBETTE ÖNCE BUNLARI OKU

1. `docs/project-memory/GENEL_PROJE_OZETI.md`
2. `docs/project-memory/SOHBET_DEVIR_2026-09-17_ROUTE_SELECTOR_GUIDED_POLISH_KAPANIS.md`
3. `KELIME_AVI_REUSABLE_HARITA_KARARI.md`
4. Ardından canlı GitHub durumunu yeniden doğrula: target branch exact HEAD, ilgili PR'lar ve Actions sonuçları.

Çelişki varsa öncelik: **canlı GitHub > proje memory/karar dosyaları > eski sohbetler**.

Repo: `ZMilaStudio/BilgiRotasi`  
Target branch: `release/final-closed-test-aab-1.68.8`  
PR #207 challenge/final balance merge: `4ffe63500363e6d976bb211f5e7d547a69859df9`  
PR #208 route reward/final ceremony merge: `c880550ef41841608d8aa664f6c24c54f3dd067d`  
PR #209 guided route selector polish merge: `92135e01a2c22f37441a4d7192265f3d9902ebc0`  
Bu dosyayı güncelleyen docs commit target HEAD'i ayrıca ilerletecektir; yeni sohbette exact HEAD mutlaka canlı doğrulanmalıdır.

---

## KELİME AVI — AUTHORITATIVE PRODUCTION DURUMU

Production rota sırası ve unlock zinciri:

**Başlangıç Limanı → Gökyüzü Adaları → Orman Yolu → Kadim Orman**

- Başlangıç Limanı: `always`.
- Gökyüzü Adaları: Başlangıç `routeComplete`; final complete + en az 18 yıldız.
- Orman Yolu: Gökyüzü `routeComplete`; final complete + en az 18 yıldız.
- Kadim Orman: Orman Yolu `routeComplete`; Orman Yolu `unlockStarsRequired = 0`, dolayısıyla final completion yeterli.

`routeComplete` authoritative olarak `WordHuntRouteProgressEngine.isRouteComplete(route, progress)` ile hesaplanır. Final type `routeFinal` olmalı, final tamamlanmış olmalı ve rota yıldız eşiği sağlanmalıdır.

Legacy/grandfather unlock istisnası yoktur. Eski downstream progress silinmez veya migrate edilmez; prerequisite'i bypass ettiremez.

---

## PR #207 — CHALLENGE / FINAL PROGRESSIVE STAR-TIME BALANCE — MERGED

PR: **#207 — `feat(kelime-avi): balance challenge and final stars`**

- Approved feature head: `9bbc3b8c6303dc390c79a2d178c03b803830c80c`
- Approved head tree: `7876ea9455465c3c1842cd391a94af9ab8365f6b`
- Squash merge commit: `4ffe63500363e6d976bb211f5e7d547a69859df9`
- Merge commit tree: `7876ea9455465c3c1842cd391a94af9ab8365f6b`
- Tree equality: **EVET**

Normal bölümler (`L1-L4`, `L6-L9`) mistake odaklıdır; seconds threshold yoktur.

L5 Challenge:
- 3★ = `0 hata` + rota-specific 3★ süre
- 2★ = `<=1 hata` + rota-specific 2★ süre
- targetWords tamamlandı fakat üst eşikler kaçtıysa 1★

L10 Final:
- 3★ = `0 hata` + rota-specific 3★ süre
- 2★ = `<=2 hata` + rota-specific 2★ süre
- targetWords tamamlandı fakat üst eşikler kaçtıysa 1★

Target tamamlanmadıysa 0★. Mistake + time birlikte varsa **AND** uygulanır. Sınırlar inclusive (`<=`).

| Rota | L5 3★ | L5 2★ | L5 timeLimit | L10 3★ | L10 2★ | L10 timeLimit |
|---|---:|---:|---:|---:|---:|---:|
| Başlangıç Limanı | 35 sn / 0 hata | 50 sn / <=1 hata | 60 | 75 sn / 0 hata | 100 sn / <=2 hata | 120 |
| Gökyüzü Adaları | 35 sn / 0 hata | 50 sn / <=1 hata | 60 | 75 sn / 0 hata | 100 sn / <=2 hata | 120 |
| Orman Yolu | 25 sn / 0 hata | 36 sn / <=1 hata | 60 | 50 sn / 0 hata | 66 sn / <=2 hata | 120 |
| Kadim Orman | 24 sn / 0 hata | 35 sn / <=1 hata | 60 | 48 sn / 0 hata | 64 sn / <=2 hata | 120 |

`timeLimitSeconds` hard fail değildir; süre dolunca oyun bitmez, input kapanmaz ve scoring engine bu alanı kullanmaz.

---

## PR #208 — ROUTE REWARD + FINAL CEREMONY — MERGED

PR: **#208 — `feat(kelime-avi): add route rewards and completion ceremony`**

- Approved exact head: `0d724e7544811cf74c85b9058800cee8396fea67`
- Approved head tree: `93c2858d3a37903564ec0cf4993d100c5442e9aa`
- Squash merge commit: `c880550ef41841608d8aa664f6c24c54f3dd067d`
- Merge tree: `93c2858d3a37903564ec0cf4993d100c5442e9aa`
- Tree equality: **EVET**
- Squash parent: `62969dfe17d660beae58aafca95168eaa64f057c`

### Authoritative reward IDs

| Rota | routeRewardId | Display |
|---|---|---|
| Başlangıç Limanı | `badge-kelime-yolcusu` | Kelime Yolcusu |
| Gökyüzü Adaları | `badge-gokyuzu-kasifi` | Gökyüzü Kaşifi |
| Orman Yolu | `badge-orman-kasifi` | Orman Kaşifi |
| Kadim Orman (`orman-2`) | `badge-kadim-orman-kasifi` | Kadim Orman Kaşifi |

Reward grant L10'a değil gerçek `routeComplete false → true` transition'ına bağlıdır. `WordHuntProgressSnapshot` kalıcı `unlockedRouteRewardIds` taşır. Payload schema **2**; decoder schema **1 ve 2** destekler, unknown future schema fail-closed kalır. Storage key/prefix korunur: `bilgi_rotasi_word_hunt_progress_v1_`.

Schema-v1 save stars/infoCards kaybetmeden açılır; historical routeComplete durumlarından eksik reward'lar sessiz ve idempotent biçimde backfill edilir.

Normal level **`Bölüm Tamamlandı`** davranışını korur. Incomplete first route-final: **`Final Tamamlandı`** + `Rotayı tamamlamak için X yıldız daha kazan.`. Gerçek false→true routeComplete: **`Rota Tamamlandı!`**, reward reveal ve varsa `<Gelecek rota adı> açıldı.`. Kadim terminal copy: **`Tüm mevcut rotaları tamamladın.`**

`WordHuntLevelProductionScreen.deferCompletionDialog` ile route-final double-dialog engellenir; exit confirmation korunur.

---

## PR #209 — GUIDED ROUTE SELECTOR POLISH — MERGED

PR: **#209 — `feat(kelime-avi): guide route selector progression`**

- Approved exact head: `5da106f4c52d7e8533d91878c8482b835a8b9dca`
- Approved head tree: `a71691ecfe04ff2850aa67fa0b6f08aafaa667bf`
- Squash merge commit: `92135e01a2c22f37441a4d7192265f3d9902ebc0`
- Squash merge tree: `a71691ecfe04ff2850aa67fa0b6f08aafaa667bf`
- Tree equality: **EVET**
- Squash parent: `8c810d46f4d2fb12616e97bfba310c2a2e2716a4`
- Source branch: `feat/kelime-avi-route-selector-guided-polish` — owner istemeden silinmez.

### Guided progression selector contract

Tek recommended rota catalog sırasındaki ilk:

`entry.isUnlocked(progress) && !WordHuntRouteProgressEngine.isRouteComplete(entry.route, progress)`

entry'dir. Route-id hardcode yoktur.

- Recommended + progress yok: **`Sıradaki`**
- Recommended + yıldız progress var: **`Devam Et`**
- `routeComplete=true`: **`Tamamlandı`**
- Persisted reward earned: **`Rozet kazanıldı`**
- Bütün production rotalar complete: recommended rota yok ve header **`Tüm mevcut rotaları tamamladın.`**

Completion ve reward ownership ayrı hesaplanır; reward state unlock/progression oluşturmaz.

### Progress / locked requirement presentation

Unlocked rota progress'i:

**`X / Y yıldız`**

olarak gösterilir; maximum `route.maximumStars` üzerinden türetilir.

`routeComplete` prerequisite için locked requirement:

1. prerequisite final incomplete → **`X / Y bölüm`**
2. final complete + `unlockStarsRequired > 0` + stars eksik → **`X / required yıldız`**
3. `unlockStarsRequired == 0` → bölüm/final progress korunur.

Kritik authoritative örnek:

Başlangıç final complete + 17★:
- Başlangıç: **`Devam Et`**, `17 / 30 yıldız`
- Gökyüzü: locked, authoritative locked copy + **`17 / 18 yıldız`**

Eski `10 / 10 bölüm` presentation'ı bu durumda superseded'dır.

Gökyüzü final complete +17★ → Orman locked **`17 / 18 yıldız`**.

Orman→Kadim için yapay 18★ gate yoktur.

### Locked / ordinal / identity

Authoritative locked copy'ler değişmedi.

Locked karta tap:
- route açmaz,
- `onRouteTap` çağırmaz,
- authoritative locked reason SnackBar ile tekrar gösterilir.

Locked leading icon artık generic büyük lock'a dönüşmez; route identity korunur:
- Başlangıç anchor
- Gökyüzü cloud
- Orman park
- Kadim forest

Ordinal bütün state'lerde görünür: **İlk rota / İkinci rota / Üçüncü rota / Dördüncü rota**.

### Responsive / accessibility

Selector focused regression baseline:
- 320×640 PASS
- 360×800 PASS
- 411×731 PASS
- 480 px reachability PASS
- 320 px + 1.5 text scale PASS

Status chip overflow gerçek olarak yakalanmış, test gevşetilmeden production chip `Wrap` tabanlı hale getirilmiştir.

Kart seviyesinde tek authoritative semantic label kullanılır. Recommended/complete/reward/locked state, reason ve unmet requirement semantics'e taşınır; nested visual children semantics'ten dışlanarak duplicate reward announce temizlenmiştir.

### PR #209 exact-head CI

Approved exact head `5da106f4c52d7e8533d91878c8482b835a8b9dca`:

- Kelime Avı route catalog kapısı — Run #92 / ID `35217743668` — **SUCCESS**
- Orman Yolu Android çoklu ekran kanıtı — Run #37 / ID `35217743501` — **SUCCESS**
- Kelime Avı Android 16 görsel kanıtı — Run #455 / ID `35217743468` — **SUCCESS**
- AdMob PR doğrulaması — Run #832 / ID `35217743499` — **SUCCESS**
- AdMob: analyze+full tests, release APK, package/merged manifest, Android 16 cold-start deneme 1 ve final application gate — **SUCCESS**

Kelime Avı Orman Yolu içerik kapısı selector-only path filter nedeniyle bu exact HEAD'de yeni run üretmedi.

---

## KORUNAN GENEL KELİME AVI KURALLARI

- Her rota 10 bölüm; canonical progression `1→2→3→4→5→6→7→8→9→10`.
- Grid: **8×8 / 64 hücre — LOCKED**.
- Production selector sırası: Başlangıç → Gökyüzü → Orman → Kadim.
- Tüm production rotaları generic/data-driven bilgi kartı sistemini kullanır: `_activeInfoCards + _progress.unlockedInfoCardIds`.
- Kadim Orman özgün deterministic content kullanır; Orman Yolu gameplay clone'u değildir.
- `assets/questions.json`, BoardMap/67 node, Firebase, signing, version ve Play kapsamı açık owner kararı olmadan değiştirilmez.
- Minimum Kelime Avı yayın stoğu: **200 hazır/doğrulanmış bölüm**.

## SOURCE BRANCH KORUMA

Owner açıkça istemeden silinmez:

- `feat/kelime-avi-route-selector-guided-polish`
- `feat/kelime-avi-route-reward-ceremony`
- `feat/kelime-avi-progressive-challenge-final-balance`
- `feat/kelime-avi-linear-route-progression`
- `feat/kelime-avi-orman-yolu-content-polish`
- `feat/kelime-avi-kadim-orman-original-content`
- `feat/kelime-avi-kadim-orman-progression`
- `feat/kelime-avi-orman2-runtime-pilot-20260916`

---

## SIRADAKİ BAŞLANGIÇ NOKTASI

### KELİME AVI — 5. ROTA READINESS / ÜRÜN + TEKNİK AUDIT

İlk tur **yalnız audit** olacak. Owner kararı verilmeden route/content/asset/branch/PR oluşturulmayacak.

Audit özellikle şunları incelemeli:

- dört rota progression zinciri ve catalog'un 5. entry hazırlığı,
- selector recommended algoritmasının 5. rotayı otomatik kapsaması,
- `Tüm mevcut rotaları tamamladın.` state'inin data-driven taşınması,
- Kadim'in terminal ceremony davranışının 5. rota ile next-route ceremony'ye dönüşmesi,
- `WordHuntRouteRewardEngine.nextCatalogEntry()` davranışı,
- Kadim→5. rota unlock prerequisite contract'ı,
- 5. rota routeRewardId / reward metadata,
- progress schema ve historical user/backfill etkisi,
- reusable themed renderer / map architecture,
- asset yaklaşımı,
- content difficulty curve,
- L5 challenge / L10 final balance,
- info-card contract,
- rota adı / tema / atmosfer alternatifleri,
- mevcut dört rota ile görsel/içerik ayrışması,
- Kadim terminal copy/testlerinin gelecekteki etkisi,
- terminal all-routes-complete state'in 5. rotaya taşınması,
- test / CI kapsamı.

**İlk audit kapanmadan 5. rota implementasyonu yapılmaz.**
