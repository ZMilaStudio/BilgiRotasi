# Bilgi Rotası — Genel Proje Özeti

**Son güncelleme:** 16 Eylül 2026

## YENİ SOHBET DEVİR NOTU — ÖNCE BUNU OKU

Yeni sohbette işe başlamadan önce şu sırayı uygula:

1. Bu dosyanın tamamını oku: `docs/project-memory/GENEL_PROJE_OZETI.md`.
2. Son sohbet devrini oku: `docs/project-memory/SOHBET_DEVIR_2026-09-16_ORMAN2_RUNTIME_PILOT_KAPANIS.md`.
3. İlgili mimari karar için `KELIME_AVI_REUSABLE_HARITA_KARARI.md` dosyasını oku.
4. Sonra canlı GitHub durumunu kendin doğrula: repo, target branch, exact HEAD, açık PR'lar ve ilgili GitHub Actions sonuçları.
5. Çelişki varsa öncelik: **canlı GitHub > proje bellek dosyaları > eski sohbetler**.

Repo: `ZMilaStudio/BilgiRotasi`  
Target branch: `release/final-closed-test-aab-1.68.8`

## 16 Eylül 2026 — Orman 2 runtime pilotu TAMAMLANDI / MERGED

Orman 2 runtime pilotu teknik, gerçek Android runtime ve owner görsel QA kapılarından geçerek PR #202 ile squash merge edildi.

- PR: **#202 — `feat(kelime-avi): Orman 2 runtime pilot integration`**
- Approved PR head: `62d33d9a332a281b2d703432472e3d802668c17c`
- Approved head tree: `a4742ad244ec90a9ae41bf2b55ad48d7ceed14e5`
- Squash merge commit / Orman 2 runtime kapanış target HEAD: `9aa3a2e8392a8fb42646d23c1e89ea9b67789c5a`
- Merge commit tree: `a4742ad244ec90a9ae41bf2b55ad48d7ceed14e5`
- Merge commit parent: `ac444cbb8a6c98a0f6699e352f331724692a304c`
- Approved PR head tree ile squash merge tree **birebir aynıdır**.
- Bu kapanış dokümantasyon commit'i `9aa3a2e...` üstüne docs-only olarak eklenir; yeni sohbette target exact HEAD her zaman canlı GitHub'dan doğrulanmalıdır.

### Orman 2 immutable asset freeze

Production asset:

`assets/word_hunt/ORMAN2_FINAL_941x1672.webp`

- dimensions: **941×1672**
- bytes: **1.109.268**
- SHA-256: `aede5c6f08b6fe4cd64d17a1ef309e13256dde1c1e97fbee0c53b019f63c6c8d`
- Git blob SHA: `43233bf2b0e8f16d59a15f0fe0bcda5f5e2bb80c`

Bu asset immutable'dır. **Re-encode / recompress / resize / crop / recolor / yeniden üretme yapılmaz.**

### Merge edilen Orman 2 runtime sözleşmesi

- Orman 2 bağımsız route identity'ye sahiptir.
- Pilot gameplay verisi Orman 1'den reuse edilir.
- Orman 2 **selector'da henüz kullanıcıya açılmamıştır**.
- Generic presentation config kullanılır.
- `referenceCanvasSize = 411×731`.
- `extendTallAmbientFromArtworkEdges = true`.
- `artworkOverlayMode = embeddedRouteLiveNodes`.
- Dekoratif rota raster environment içindedir; live Flutter route painter kapalıdır.
- Progression, node ve chrome Flutter katmanında canlıdır.
- Orman 1 node asset ailesi reuse edilir.
- NodeSkin refactor yapılmadı.
- Route/theme-id özel hardcoded renderer `if` eklenmedi.
- `WordHuntRouteMapGeometry.normalizedStops` değiştirilmedi.
- Orman 1 / Başlangıç Limanı / Gökyüzü davranışları değiştirilmedi.

### Android 16 proof / CI — PASS

Exact proof HEAD: `62d33d9a332a281b2d703432472e3d802668c17c`

- Workflow: **Orman Yolu Android çoklu ekran kanıtı**
- Run: **#20**
- Run ID: `35082179184`
- Overall: **SUCCESS**
- Orman 2 job: **Orman 2 Android 16 çoklu ekran kanıtı**
- Job ID: `104748515371`
- Result: **SUCCESS**
- Artifact: `BilgiRotasi-KelimeAvi-Orman2-MultiSize-62d33d9a332a281b2d703432472e3d802668c17c`
- Artifact ID: `10440972427`
- Gerçek Android 16 emulator proof boyutları: **720×1280 / 1080×1920 / 1080×2400**
- Aynı exact HEAD'de mevcut Orman 1 regression job'u da **SUCCESS**.
- Codex kullanılmadı ve bu pilotun kapanışı için gerekli değildir.

Owner görsel QA sonucu:

- double-route yok,
- ghost UI yok,
- node-route hizası kabul edildi,
- header/chrome tek,
- tall ambient kabul edildi,
- bloklayıcı seam/poster/letterbox sorunu yok,
- Orman 2 görsel kimliği Orman 1'den yeterince farklı.

### Source branch durumu

Source branch: `feat/kelime-avi-orman2-runtime-pilot-20260916`.

Branch bilerek **henüz silinmedi**. Owner açıkça istemeden silinmez.

## Bir sonraki ürün kararı

**“Orman 2’nin kullanıcıya ne zaman ve nasıl açılacağı / progression içindeki konumu.”**

Bu karar verilene kadar Orman 2 selector'a açılmaz ve progression/navigation davranışı varsayımla değiştirilmez.

## Kelime Avı — korunan kanonik progression ve catalog kuralları

- Her 10-bölümlük rotada fresh progress: yalnız Bölüm 1 açık/current, Bölüm 2–10 locked.
- Sıralı unlock: `1→2→3→4→5→6→7→8→9→10`.
- Ortak motor `WordHuntRouteProgressEngine.isLevelUnlocked`; tema/artwork progression mantığını değiştiremez.
- Mevcut kullanıcıya açık production catalog davranışı korunur; Orman 2'nin selector/progression konumu ayrıca owner kararı bekler.
- Gökyüzü kapısı: Başlangıç Limanı'ndan 18 yıldız.
- Orman 1 kapısı: yalnız Başlangıç Limanı Bölüm 10 tamamlandığında açılır.

## Orman 1 — kapanmış baseline

Orman 1 temiz environment entegrasyonu 15 Eylül 2026'da tamamlandı ve merge edildi. Taş rota environment içinde, live route painter kapalı, node/progression/chrome Flutter katmanındadır. Orman 2 pilotu bu generic/config-driven zemini bozmaz.

## Canonical gameplay/release korumaları

- Grid: **8×8 / 64 hücre — LOCKED**.
- 6×10 tarihsel checkpointtir; geri dönmez.
- B5 60 sn, B10 120 sn soft challenge; hard-fail değildir.
- Minimum Kelime Avı yayın stoğu: **200 hazır/doğrulanmış bölüm**.
- 200/200 release-stock gate ve runtime/fiziksel kabul tamamlanmadan yeni Kelime Avı production release'i Play'e yüklenmez.
- `assets/questions.json`, BoardMap/67 node, Firebase, signing, version ve Play kapsamı açık owner kararı olmadan değiştirilmez.

**DEVİR SON DURUMU:** Orman 2 runtime pilotu PR #202 ile MERGED / approved head `62d33d9...` / squash merge `9aa3a2e...` / approved ve merge tree `a4742ad...` birebir aynı / immutable Orman 2 WebP freeze korunuyor / CI + gerçek Android 16 üç boyut + Orman 1 regression PASS / owner visual QA PASS / Orman 2 selector'da kapalı / source branch bilerek tutuluyor / sıradaki ürün kararı Orman 2'nin kullanıcıya açılma zamanı-yöntemi ve progression içindeki konumu.
