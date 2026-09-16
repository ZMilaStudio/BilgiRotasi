# SOHBET DEVİR — 17 Eylül 2026 — CHALLENGE / FINAL BALANCE KAPANIŞI

Bu dosya BilgiRotasi / Kelime Avı challenge/final star-time balance çalışmasının authoritative kapanış ve sonraki audit başlangıç notudur.

## Yeni sohbette okuma sırası

1. `docs/project-memory/GENEL_PROJE_OZETI.md`
2. Bu dosya: `docs/project-memory/SOHBET_DEVIR_2026-09-17_CHALLENGE_FINAL_BALANCE_KAPANIS.md`
3. `KELIME_AVI_REUSABLE_HARITA_KARARI.md`
4. Canlı GitHub durumunu yeniden doğrula: target branch exact HEAD, ilgili PR/Actions durumu.

Çelişki varsa öncelik: **canlı GitHub > proje memory/karar dosyaları > eski sohbetler**.

## Repo / kapanış baseline

- Repo: `ZMilaStudio/BilgiRotasi`
- Target branch: `release/final-closed-test-aab-1.68.8`
- PR #207: `feat(kelime-avi): balance challenge and final stars`
- PR state: **MERGED**
- Approved feature head: `9bbc3b8c6303dc390c79a2d178c03b803830c80c`
- Approved head tree: `7876ea9455465c3c1842cd391a94af9ab8365f6b`
- Squash merge commit: `4ffe63500363e6d976bb211f5e7d547a69859df9`
- Merge commit tree: `7876ea9455465c3c1842cd391a94af9ab8365f6b`
- Tree equality: **EVET**
- Squash parent: `d81b6777065e88d3a1eba8716364e12bac071975`
- Source branch: `feat/kelime-avi-progressive-challenge-final-balance`
- Source branch owner istemeden silinmez.

Bu kapanış dokümantasyon commit'i target HEAD'i merge commit sonrasından ayrıca ilerletecektir; yeni sohbette exact HEAD mutlaka canlı doğrulanmalıdır.

---

## AUTHORITATIVE STAR / TIME BALANCE

Normal bölümler (`L1-L4`, `L6-L9`):

- mistake odaklı kalır,
- seconds threshold yoktur,
- mevcut normal-level contract korunur.

L5 Challenge:

- 3★ = 0 hata + rota-specific `threeStarMaxSeconds`
- 2★ = <=1 hata + rota-specific `twoStarMaxSeconds`
- upper tier'lar kaçarsa ama targetWords tamamlandıysa 1★

L10 Final:

- 3★ = 0 hata + rota-specific `threeStarMaxSeconds`
- 2★ = <=2 hata + rota-specific `twoStarMaxSeconds`
- upper tier'lar kaçarsa ama targetWords tamamlandıysa 1★

Target tamamlanmadıysa 0★. Mistake + time birlikte varsa **AND** uygulanır. Boundary inclusive (`<=`).

## Exact production matrix

### Başlangıç Limanı

L5 Challenge:

- 3★ mistakes = 0
- 2★ mistakes <=1
- 3★ seconds = 35
- 2★ seconds = 50
- `timeLimitSeconds = 60`

L10 Final:

- 3★ mistakes = 0
- 2★ mistakes <=2
- 3★ seconds = 75
- 2★ seconds = 100
- `timeLimitSeconds = 120`

### Gökyüzü Adaları

L5 Challenge:

- 3★ mistakes = 0
- 2★ mistakes <=1
- 3★ seconds = 35
- 2★ seconds = 50
- `timeLimitSeconds = 60`

L10 Final:

- 3★ mistakes = 0
- 2★ mistakes <=2
- 3★ seconds = 75
- 2★ seconds = 100
- `timeLimitSeconds = 120`

### Orman Yolu

L5 Challenge:

- 3★ mistakes = 0
- 2★ mistakes <=1
- 3★ seconds = 25
- 2★ seconds = 36
- `timeLimitSeconds = 60`

L10 Final:

- 3★ mistakes = 0
- 2★ mistakes <=2
- 3★ seconds = 50
- 2★ seconds = 66
- `timeLimitSeconds = 120`

### Kadim Orman

L5 Challenge:

- 3★ mistakes = 0
- 2★ mistakes <=1
- 3★ seconds = 24
- 2★ seconds = 35
- `timeLimitSeconds = 60`

L10 Final:

- 3★ mistakes = 0
- 2★ mistakes <=2
- 3★ seconds = 48
- 2★ seconds = 64
- `timeLimitSeconds = 120`

Kadim Orman artık Orman Yolu timing contract'ının exact clone'u değildir.

---

## TIME LIMIT SEMANTİĞİ

`timeLimitSeconds` **HARD FAIL değildir**.

Korunan authoritative davranış:

- süre dolunca oyun bitmez,
- timeout/failure/retry yoktur,
- input kapanmaz,
- forced result yoktur,
- scoring engine `timeLimitSeconds` kullanmaz,
- star scoring yalnız `threeStarMaxSeconds` / `twoStarMaxSeconds` üzerinden çalışır.

60 / 120 değerleri şimdilik metadata olarak korunur. Future cleanup konusu olabilir; bu kapanışta rename/remove/refactor yapılmamıştır.

---

## BONUS / CONTENT / GAMEPLAY KORUMASI

- bonus kelimeler optional,
- bonuslar completion için zorunlu değil,
- bonuslar star scoring için zorunlu değil,
- grid değişmedi,
- targetWords değişmedi,
- bonusWords değişmedi,
- infoCards değişmedi,
- level IDs / route IDs / route titles değişmedi,
- scoring engine değişmedi,
- progression değişmedi,
- route unlock değişmedi,
- selector değişmedi,
- assets / visual themes / renderer / map geometry / NodeSkin değişmedi,
- routeRewardId değişmedi,
- reward persistence eklenmedi,
- final ceremony eklenmedi.

---

## CI KAPANIŞI

Approved exact head: `9bbc3b8c6303dc390c79a2d178c03b803830c80c`

- Kelime Avı Orman Yolu içerik kapısı — Run #8 / ID `35150882939` — **SUCCESS**
- Orman Yolu Android çoklu ekran kanıtı — Run #29 / ID `35150882942` — **SUCCESS**
- Kelime Avı Android 16 görsel kanıtı — Run #447 / ID `35150882917` — **SUCCESS**
- AdMob PR doğrulaması — Run #824 / ID `35150882966` — **SUCCESS**

Ayrıca:

- code analyze — PASS
- focused Kelime Avı suite — PASS
- full tests — PASS
- release APK — PASS
- package/manifest — PASS
- Android 16 cold-start — PASS

---

## REGRESSION BASELINE

Orman L5:

- `25s/0 → 3★`
- `36s/1 → 2★`
- `37s/0 → 1★`

Kadim L5:

- `24s/0 → 3★`
- `35s/1 → 2★`
- `36s/0 → 1★`

Orman L10:

- `50s/0 → 3★`
- `66s/2 → 2★`
- `67s/0 → 1★`

Kadim L10:

- `48s/0 → 3★`
- `64s/2 → 2★`
- `65s/0 → 1★`

Incomplete target set → `0★`.

---

## ESKİ / SUPERSEDED BİLGİLER

Aşağıdakiler artık authoritative değildir:

- Orman/Kadim L5 `twoStarMaxMistakes = 2`
- Orman/Kadim L5/L10 seconds threshold = `null`
- Kadim Orman timing contract'ının Orman Yolu ile birebir clone olduğu bilgisi
- challenge/final star-time auditinin hâlâ beklediği bilgisi
- PR #207'nin draft veya merge bekliyor olduğu bilgisi

Eski `SOHBET_DEVIR_2026-09-16_CHALLENGE_FINAL_AUDIT_BASLANGIC.md` dosyası tarihsel başlangıç notudur ve bu kapanış dosyası tarafından supersede edilmiştir.

---

## SIRADAKİ AUTHORITATIVE AUDIT

# ROUTE REWARD + FINAL CEREMONY / ROTA TAMAMLAMA ÖDÜLÜ AUDITİ

İlk tur **yalnız audit** olacak.

İncelenecekler:

1. Dört rotanın exact `routeRewardId` değerleri.
2. `routeRewardId` için production runtime consumer var mı?
3. Route tamamlanınca badge/reward grant var mı?
4. Reward progress'e persist ediliyor mu?
5. Reward/badge UI'da gösteriliyor mu?
6. Selector `routeRewardId` kullanıyor mu?
7. Completion dialog `routeRewardId` kullanıyor mu?
8. Önceki audit bulgusunu canlı koddan yeniden doğrula: `routeRewardId` metadata-only mı?
9. L10 `routeFinal` tamamlanınca oyuncuya bugün tam olarak ne gösteriliyor?
10. Normal level completion ile routeFinal completion UX farkı nedir?
11. Rota tamamlanınca özel başlık / kutlama / reward reveal / badge / animation / next-route unlocked messaging / CTA parçalarının hangileri mevcut veya eksik?
12. Mevcut route completion snackbar / dialog / navigation davranışını çıkar.
13. Reward sistemi eklenirse mevcut progress codec/persistence üzerindeki etkisini incele.
14. Reward ID ailelerinin `badge-*` ve `reward-*` olarak karışık adlandırılmasının teknik/product etkisini incele.

### Bu auditin ilk turunda YAPMA

- reward sistemi uygulama,
- final ceremony tasarlama/uygulama,
- `routeRewardId` rename yapma,
- progress codec değiştirme,
- runtime/content/scoring değiştirme,
- 5. rota oluşturma veya tasarlama.

Önce canlı runtime contract audit edilip owner'a seçenekler getirilecek.

## 5. ROTA

Henüz 5. rota oluşturulmaz veya tasarlanmaz. Önce reward/final ceremony konusu kapanmalıdır.

## DEVİR CÜMLESİ

Yeni sohbet şu prompt ile başlayabilir:

`GENEL_PROJE_OZETI.md ve SOHBET_DEVIR_2026-09-17_CHALLENGE_FINAL_BALANCE_KAPANIS.md dosyalarını oku; canlı target HEAD'i doğrula ve ROUTE REWARD + FINAL CEREMONY / ROTA TAMAMLAMA ÖDÜLÜ auditinden devam et. İlk tur yalnız audit; runtime değişikliği yapma.`
