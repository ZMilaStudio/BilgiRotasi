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
- Gökyüzü Adaları: Başlangıç `routeComplete`, final complete + en az 18 yıldız.
- Orman Yolu: Gökyüzü `routeComplete`, final complete + en az 18 yıldız.
- Kadim Orman: Orman Yolu `routeComplete`; `unlockStarsRequired = 0`, final completion yeterli.

`WordHuntRouteUnlockRule.routeComplete`, `WordHuntRouteProgressEngine.isRouteComplete(prerequisiteRoute, progress)` kullanır. Legacy downstream progress prerequisite'i bypass ettiremez; ancak silinmez ve prerequisite sağlanınca korunur.

## Kadim Orman runtime/content baseline

- technical route id: `orman-2`
- user-facing title: **Kadim Orman**
- visual theme id: `orman-2-production`
- route reward id: `reward-orman-2`
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
- squash parent: `d81b6777065e88d3a1eba8716364e12bac071975`
- source branch: `feat/kelime-avi-progressive-challenge-final-balance` — owner istemeden silinmez.

### Authoritative scoring semantiği

Normal levels (`L1-L4`, `L6-L9`):

- mistake odaklı,
- seconds threshold yok,
- mevcut normal-level contract korunur.

L5 Challenge:

- 3★ = 0 hata + rota-specific `threeStarMaxSeconds`
- 2★ = <=1 hata + rota-specific `twoStarMaxSeconds`
- üst eşikler kaçarsa ama bölüm complete ise 1★

L10 Final:

- 3★ = 0 hata + rota-specific `threeStarMaxSeconds`
- 2★ = <=2 hata + rota-specific `twoStarMaxSeconds`
- üst eşikler kaçarsa ama bölüm complete ise 1★

Target tamamlanmadıysa 0★. Mistake ve time threshold birlikte varsa **AND** uygulanır. Boundary inclusive (`<=`). `WordHuntScoringEngine` route id/type özel branch kullanmaz; zorluk yalnız `starRules` datasından gelir.

### Exact production matrix

| Rota | L5 3★ sec | L5 2★ sec | L5 mistakes 3★/2★ | L5 timeLimit | L10 3★ sec | L10 2★ sec | L10 mistakes 3★/2★ | L10 timeLimit |
|---|---:|---:|---|---:|---:|---:|---|---:|
| Başlangıç Limanı | 35 | 50 | 0 / <=1 | 60 | 75 | 100 | 0 / <=2 | 120 |
| Gökyüzü Adaları | 35 | 50 | 0 / <=1 | 60 | 75 | 100 | 0 / <=2 | 120 |
| Orman Yolu | 25 | 36 | 0 / <=1 | 60 | 50 | 66 | 0 / <=2 | 120 |
| Kadim Orman | 24 | 35 | 0 / <=1 | 60 | 48 | 64 | 0 / <=2 | 120 |

Kadim artık Orman Yolu timing contract'ının exact clone'u değildir.

### `timeLimitSeconds` authoritative semantiği

`timeLimitSeconds` **hard fail değildir**:

- süre dolunca oyun bitmez,
- timeout/failure/retry yok,
- input kapanmaz,
- scoring engine `timeLimitSeconds` kullanmaz,
- star scoring yalnız `threeStarMaxSeconds` / `twoStarMaxSeconds` üzerinden çalışır.

60 / 120 değerleri şimdilik metadata olarak korunur. Future cleanup'ta remove/rename değerlendirilebilir; mevcut closure'da refactor yapılmaz.

### Bonus/content koruması

- bonus kelimeler optional,
- completion veya star için zorunlu değil,
- grid / targetWords / bonusWords / infoCards değişmedi,
- scoring engine / progression / selector / route unlock değişmedi,
- asset / visual theme / renderer / map geometry / NodeSkin değişmedi.

### PR #207 exact-head CI

Approved exact head `9bbc3b8c6303dc390c79a2d178c03b803830c80c`:

- Kelime Avı Orman Yolu içerik kapısı — Run #8 / ID `35150882939` — SUCCESS
- Orman Yolu Android çoklu ekran kanıtı — Run #29 / ID `35150882942` — SUCCESS
- Kelime Avı Android 16 görsel kanıtı — Run #447 / ID `35150882917` — SUCCESS
- AdMob PR doğrulaması — Run #824 / ID `35150882966` — SUCCESS
- code analyze / focused Kelime Avı suite / full tests / release APK / package-manifest / Android 16 cold-start — PASS

Boundary regression:

- Orman L5: `25s/0 → 3★`, `36s/1 → 2★`, `37s/0 → 1★`
- Kadim L5: `24s/0 → 3★`, `35s/1 → 2★`, `36s/0 → 1★`
- Orman L10: `50s/0 → 3★`, `66s/2 → 2★`, `67s/0 → 1★`
- Kadim L10: `48s/0 → 3★`, `64s/2 → 2★`, `65s/0 → 1★`
- incomplete target set → `0★`

---

## Sıradaki audit — ROUTE REWARD + FINAL CEREMONY / ROTA TAMAMLAMA ÖDÜLÜ

İlk tur yalnız audit olacak. Henüz reward sistemi uygulanmaz, final ceremony tasarlanmaz, `routeRewardId` rename edilmez ve 5. rota oluşturulmaz.

İncelenecekler:

1. Dört rotanın exact `routeRewardId` değerleri.
2. Runtime consumer var mı?
3. Route complete olduğunda reward/badge grant var mı?
4. Progress'e persist ediliyor mu?
5. UI/selector/completion dialog bunu kullanıyor mu?
6. `routeRewardId metadata-only` bulgusunu canlı koddan yeniden doğrula.
7. L10 routeFinal tamamlanınca oyuncuya bugün ne gösteriliyor?
8. Normal completion ve routeFinal completion UX farkı nedir?
9. Özel başlık, kutlama, reward reveal, badge, animation, next-route unlocked messaging ve CTA parçaları mevcut mu?
10. Route completion snackbar/dialog/navigation davranışı nedir?
11. Reward sistemi eklenirse progress codec/persistence etkisi ne olur?
12. `badge-*` / `reward-*` karışık ID ailelerinin etkisi nedir?

Önce audit + owner seçenekleri. **5. rota reward/final ceremony konusu kapanmadan tasarlanmaz.**

## Source branch koruma

Owner açıkça istemeden silinmez:

- `feat/kelime-avi-progressive-challenge-final-balance`
- `feat/kelime-avi-linear-route-progression`
- `feat/kelime-avi-orman-yolu-content-polish`
- `feat/kelime-avi-kadim-orman-original-content`
- `feat/kelime-avi-kadim-orman-progression`
- `feat/kelime-avi-orman2-runtime-pilot-20260916`

**Durum:** REUSABLE 10-LEVEL MAP ARCHITECTURE — MERGED. KADİM ORMAN RUNTIME/CONTENT — MERGED. LINEER ROUTE PROGRESSION — MERGED. CHALLENGE / FINAL PROGRESSIVE STAR-TIME BALANCE — MERGED / CI GREEN. SIRADAKİ KONU — ROUTE REWARD + FINAL CEREMONY AUDITİ.
