# Bilgi Rotası — Genel Proje Özeti

**Son güncelleme:** 17 Eylül 2026

## YENİ SOHBETTE ÖNCE BUNLARI OKU

1. `docs/project-memory/GENEL_PROJE_OZETI.md`
2. `docs/project-memory/SOHBET_DEVIR_2026-09-17_CHALLENGE_FINAL_BALANCE_KAPANIS.md`
3. `KELIME_AVI_REUSABLE_HARITA_KARARI.md`
4. Ardından canlı GitHub durumunu yeniden doğrula: target branch exact HEAD, ilgili açık PR'lar ve Actions sonuçları.

Çelişki varsa öncelik: **canlı GitHub > proje memory/karar dosyaları > eski sohbetler**.

Repo: `ZMilaStudio/BilgiRotasi`  
Target branch: `release/final-closed-test-aab-1.68.8`  
Challenge/final product baseline merge: `4ffe63500363e6d976bb211f5e7d547a69859df9` (PR #207)  
Bu dosyayı güncelleyen docs commit target HEAD'i ayrıca ilerletecektir; yeni sohbette exact HEAD mutlaka canlı doğrulanmalıdır.

---

## KELİME AVI — AUTHORITATIVE PRODUCTION DURUMU

Production rota sırası ve unlock zinciri:

**Başlangıç Limanı → Gökyüzü Adaları → Orman Yolu → Kadim Orman**

- Başlangıç Limanı: `always`.
- Gökyüzü Adaları: Başlangıç `routeComplete`; final complete + en az 18 yıldız.
- Orman Yolu: Gökyüzü `routeComplete`; final complete + en az 18 yıldız.
- Kadim Orman: Orman Yolu `routeComplete`; Orman Yolu `unlockStarsRequired = 0`, dolayısıyla final completion yeterli.

`routeComplete` authoritative olarak `WordHuntRouteProgressEngine.isRouteComplete(prerequisiteRoute, progress)` kullanır. Final type `routeFinal` olmalı, final tamamlanmış olmalı ve rota yıldız eşiği sağlanmalıdır.

Legacy/grandfather unlock istisnası yoktur. Eski downstream progress silinmez veya migrate edilmez; prerequisite'i bypass ettiremez.

---

## PR #207 — CHALLENGE / FINAL PROGRESSIVE STAR-TIME BALANCE — MERGED

PR: **#207 — `feat(kelime-avi): balance challenge and final stars`**

- Approved feature head: `9bbc3b8c6303dc390c79a2d178c03b803830c80c`
- Approved head tree: `7876ea9455465c3c1842cd391a94af9ab8365f6b`
- Squash merge commit: `4ffe63500363e6d976bb211f5e7d547a69859df9`
- Merge commit tree: `7876ea9455465c3c1842cd391a94af9ab8365f6b`
- Tree equality: **EVET**
- Squash parent: `d81b6777065e88d3a1eba8716364e12bac071975`
- Source branch: `feat/kelime-avi-progressive-challenge-final-balance` — owner istemeden silinmez.

### Authoritative star/time contract

Normal bölümler (`L1-L4`, `L6-L9`):

- mistake odaklı kalır,
- seconds threshold yoktur,
- mevcut normal-level contract korunur.

L5 Challenge:

- 3★ = `0 hata` + rota-specific 3★ süre,
- 2★ = `<=1 hata` + rota-specific 2★ süre,
- üst eşikler kaçarsa ama targetWords tamamlandıysa 1★.

L10 Final:

- 3★ = `0 hata` + rota-specific 3★ süre,
- 2★ = `<=2 hata` + rota-specific 2★ süre,
- üst eşikler kaçarsa ama targetWords tamamlandıysa 1★.

Target tamamlanmadıysa 0★. Mistake + time birlikte varsa **AND** uygulanır. Sınırlar inclusive (`<=`).

### Exact production matrix

| Rota | L5 3★ | L5 2★ | L5 timeLimit | L10 3★ | L10 2★ | L10 timeLimit |
|---|---:|---:|---:|---:|---:|---:|
| Başlangıç Limanı | 35 sn / 0 hata | 50 sn / <=1 hata | 60 | 75 sn / 0 hata | 100 sn / <=2 hata | 120 |
| Gökyüzü Adaları | 35 sn / 0 hata | 50 sn / <=1 hata | 60 | 75 sn / 0 hata | 100 sn / <=2 hata | 120 |
| Orman Yolu | 25 sn / 0 hata | 36 sn / <=1 hata | 60 | 50 sn / 0 hata | 66 sn / <=2 hata | 120 |
| Kadim Orman | 24 sn / 0 hata | 35 sn / <=1 hata | 60 | 48 sn / 0 hata | 64 sn / <=2 hata | 120 |

### `timeLimitSeconds` semantiği

`timeLimitSeconds` **HARD FAIL değildir**:

- süre dolunca oyun bitmez,
- timeout/failure/retry yoktur,
- input kapanmaz,
- scoring engine `timeLimitSeconds` kullanmaz,
- star scoring yalnız `threeStarMaxSeconds` / `twoStarMaxSeconds` üzerinden çalışır.

60 / 120 değerleri şimdilik mevcut metadata olarak korunur. Future cleanup konusu olabilir; bu kapanışta refactor yoktur.

### Bonus/content/gameplay koruması

- bonus kelimeler optional,
- bonuslar completion için zorunlu değil,
- bonuslar star scoring için zorunlu değil,
- grid / targetWords / bonusWords değişmedi,
- scoring engine değişmedi,
- progression / route unlock / selector değişmedi,
- asset / visual / map / renderer değişmedi.

### PR #207 exact-head CI

Approved exact head `9bbc3b8c6303dc390c79a2d178c03b803830c80c`:

- Kelime Avı Orman Yolu içerik kapısı — Run #8 / ID `35150882939` — **SUCCESS**
- Orman Yolu Android çoklu ekran kanıtı — Run #29 / ID `35150882942` — **SUCCESS**
- Kelime Avı Android 16 görsel kanıtı — Run #447 / ID `35150882917` — **SUCCESS**
- AdMob PR doğrulaması — Run #824 / ID `35150882966` — **SUCCESS**
- code analyze, focused Kelime Avı suite, full tests, release APK, package/manifest, Android 16 cold-start — **PASS**

Regression baseline:

- Orman L5: `25s/0 → 3★`, `36s/1 → 2★`, `37s/0 → 1★`
- Kadim L5: `24s/0 → 3★`, `35s/1 → 2★`, `36s/0 → 1★`
- Orman L10: `50s/0 → 3★`, `66s/2 → 2★`, `67s/0 → 1★`
- Kadim L10: `48s/0 → 3★`, `64s/2 → 2★`, `65s/0 → 1★`
- incomplete target set → `0★`

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

- `feat/kelime-avi-progressive-challenge-final-balance`
- `feat/kelime-avi-linear-route-progression`
- `feat/kelime-avi-orman-yolu-content-polish`
- `feat/kelime-avi-kadim-orman-original-content`
- `feat/kelime-avi-kadim-orman-progression`
- `feat/kelime-avi-orman2-runtime-pilot-20260916`

---

## SIRADAKİ BAŞLANGIÇ NOKTASI

### ROUTE REWARD + FINAL CEREMONY / ROTA TAMAMLAMA ÖDÜLÜ AUDITİ

İlk tur **yalnız audit** olacak. Henüz reward sistemi uygulanmayacak, ceremony tasarlanmayacak, `routeRewardId` rename edilmeyecek ve 5. rota oluşturulmayacak.

İncelenecekler:

1. Dört rotanın exact `routeRewardId` değerleri.
2. `routeRewardId` için gerçek production runtime consumer var mı?
3. Route tamamlanınca reward/badge grant, persistence ve UI gösterimi var mı?
4. Selector veya completion dialog `routeRewardId` kullanıyor mu?
5. Mevcut `routeRewardId metadata-only` audit bulgusunu canlı koddan yeniden doğrula.
6. L10 `routeFinal` tamamlanınca oyuncuya bugün tam olarak ne gösteriliyor?
7. Normal completion ile routeFinal completion UX farkını çıkar.
8. Özel başlık, kutlama, reward reveal, badge, animation, next-route unlocked messaging ve CTA parçalarının hangileri var/yok?
9. Mevcut route completion snackbar/dialog/navigation davranışını çıkar.
10. Reward sistemi eklenirse progress codec/persistence etkisini incele.
11. `badge-*` ve `reward-*` ID ailelerinin karışık adlandırılmasının teknik/product etkisini değerlendir.

Önce mevcut runtime contract audit edilip owner'a seçenekler getirilecek. **5. rota bu konu kapanmadan açılmayacak.**
