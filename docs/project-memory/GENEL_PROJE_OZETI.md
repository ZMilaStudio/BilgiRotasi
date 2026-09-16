# Bilgi Rotası — Genel Proje Özeti

**Son güncelleme:** 16 Eylül 2026

## YENİ SOHBET DEVİR NOTU — ÖNCE BUNU OKU

Yeni sohbette işe başlamadan önce şu sırayı uygula:

1. Bu dosyanın tamamını oku: `docs/project-memory/GENEL_PROJE_OZETI.md`.
2. Son sohbet devrini oku: `docs/project-memory/SOHBET_DEVIR_2026-09-16_KADIM_ORMAN_PROGRESSION_KAPANIS.md`.
3. İlgili mimari karar için `KELIME_AVI_REUSABLE_HARITA_KARARI.md` dosyasını oku.
4. Sonra canlı GitHub durumunu kendin doğrula: repo, target branch, exact HEAD, açık PR'lar ve ilgili GitHub Actions sonuçları.
5. Çelişki varsa öncelik: **canlı GitHub > proje bellek dosyaları > eski sohbetler**.

Repo: `ZMilaStudio/BilgiRotasi`  
Target branch: `release/final-closed-test-aab-1.68.8`

## 16 Eylül 2026 — Kadim Orman progression kararı TAMAMLANDI / MERGED

Orman 2 runtime pilotunun kullanıcı-facing progression kararı PR #203 ile tamamlandı ve squash merge edildi.

- PR: **#203 — `feat(kelime-avi): unlock Kadim Orman after Orman Yolu`**
- Approved PR head: `c89926b270d89f52ca895b82a875c9b732fdb609`
- Approved head tree: `3e00a2d246f93eb3792a1d63748b2923fe30a13d`
- Squash merge commit / progression kapanış target HEAD: `f312a2333cb16e9a74f500fcc80c200325634439`
- Merge commit tree: `3e00a2d246f93eb3792a1d63748b2923fe30a13d`
- Squash commit parent: `044818e9c66eddc20f20b8a16e9497102736ddfa`
- Approved PR head tree ile squash merge tree **birebir aynıdır**.
- Source branch `feat/kelime-avi-kadim-orman-progression` bilerek henüz silinmedi.
- Bu kapanış dokümantasyon commit'i `f312a233...` üstüne docs-only olarak eklenir; yeni sohbette target exact HEAD her zaman canlı GitHub'dan doğrulanmalıdır.

### Onaylanan ürün davranışı

Teknik route identity değişmedi:

`orman-2`

Kullanıcı-facing ad:

**Kadim Orman**

Selector sırası:

**Başlangıç Limanı → Gökyüzü → Orman Yolu → Kadim Orman**

Kadim Orman progression sözleşmesi:

- selector'da en baştan görünür,
- fresh progress durumunda kilitlidir,
- exact locked mesaj: **“Orman Yolu’nu tamamlayarak aç.”**,
- Orman Yolu level 9 tamamlandığında kilitli kalır,
- Orman Yolu level 10 tamamlandığında açılır,
- 30/30 yıldız şartı yoktur,
- toplam yıldız sayısı unlock koşulu değildir,
- kendi içinde yine **1→10** progression kullanır; 21–30 numaralandırması yoktur,
- progression identity Orman Yolu'ndan bağımsızdır.

### Merge edilen mimari karar

- Mevcut generic `WordHuntRouteUnlockRule.routeComplete` kullanılır.
- Yeni prerequisite engine eklenmedi.
- Route-id özel selector/renderer `if` eklenmedi.
- Exact locked metin `WordHuntRouteCatalogEntry.lockedMessage` üzerinden data-driven taşınır.
- Kilitli selector kartı seçilemez.
- Başlangıç Limanı / Gökyüzü / Orman Yolu mevcut unlock davranışları korunur.
- Orman Yolu gameplay/progression verisi değiştirilmedi.
- Orman 2 visual theme, normalized stops ve immutable asset değiştirilmedi.

### CI / test kapanışı — PASS

Exact approved HEAD: `c89926b270d89f52ca895b82a875c9b732fdb609`

- Kelime Avı route catalog kapısı — Run **#80**, ID `35092666128`: **SUCCESS**
- Orman Yolu Android çoklu ekran kanıtı — Run **#21**, ID `35092666124`: **SUCCESS**
- Kelime Avı Android 16 görsel kanıtı — Run **#439**, ID `35092666125`: **SUCCESS**
- AdMob PR doğrulaması — Run **#816**, ID `35092666130`: **SUCCESS**
- Focused selector tests: **18/18 PASS**
- Orman 2 runtime regression: **PASS**
- Aynı exact HEAD üzerinde Orman Yolu ve Orman 2/Kadim Orman Android 16 multi-size proof job'ları PASS.
- Selector'a özel A/B Android screenshot artifact'i üretilmedi; bu bloklayıcı değildir. Fresh locked ve Orman Yolu final-complete unlocked state'leri gerçek Flutter widget testleriyle doğrulandı; production'a proof/debug hack eklenmedi.

## Orman 2 / Kadim Orman immutable asset freeze

Production asset:

`assets/word_hunt/ORMAN2_FINAL_941x1672.webp`

- dimensions: **941×1672**
- bytes: **1.109.268**
- SHA-256: `aede5c6f08b6fe4cd64d17a1ef309e13256dde1c1e97fbee0c53b019f63c6c8d`
- Git blob SHA: `43233bf2b0e8f16d59a15f0fe0bcda5f5e2bb80c`

Bu asset immutable'dır. **Re-encode / recompress / resize / crop / recolor / yeniden üretme yapılmaz.**

## Orman 2 runtime baseline — KORUNUYOR

PR #202 ile merge edilen runtime pilotu kapanmıştır ve PR #203 bu baseline'ı değiştirmemiştir.

- Technical route id: `orman-2`
- Visual theme id: `orman-2-production`
- `referenceCanvasSize = 411×731`
- `extendTallAmbientFromArtworkEdges = true`
- `artworkOverlayMode = embeddedRouteLiveNodes`
- dekoratif rota raster içindedir; live Flutter route painter kapalıdır,
- node/progression/chrome canlı Flutter katmanındadır,
- Orman 1 node asset ailesi reuse edilir,
- NodeSkin refactor yoktur,
- route/theme-id özel renderer `if` yoktur,
- normalized stops değiştirilmemiştir.

PR #202 kapanış referansı:

- Approved head `62d33d9a332a281b2d703432472e3d802668c17c`
- Squash merge `9aa3a2e8392a8fb42646d23c1e89ea9b67789c5a`
- Approved/merge tree `a4742ad244ec90a9ae41bf2b55ad48d7ceed14e5`
- Android 16 runtime proof + owner visual QA: PASS

## Source branch durumu

- PR #203 source branch: `feat/kelime-avi-kadim-orman-progression` — bilerek tutuluyor.
- PR #202 source branch: `feat/kelime-avi-orman2-runtime-pilot-20260916` — daha önce de bilerek tutuluyordu.

Owner açıkça istemeden bu branch'ler silinmez.

## Kelime Avı — korunan kanonik progression ve catalog kuralları

- Her 10-bölümlük rotada fresh progress: yalnız Bölüm 1 açık/current, Bölüm 2–10 locked.
- Sıralı unlock: `1→2→3→4→5→6→7→8→9→10`.
- Ortak motor `WordHuntRouteProgressEngine.isLevelUnlocked`; tema/artwork progression mantığını değiştiremez.
- Production selector sırası artık: Başlangıç Limanı → Gökyüzü → Orman Yolu → Kadim Orman.
- Gökyüzü kapısı: Başlangıç Limanı'ndan 18 yıldız.
- Orman Yolu kapısı: yalnız Başlangıç Limanı Bölüm 10 tamamlandığında açılır.
- Kadim Orman kapısı: yalnız Orman Yolu Bölüm 10 tamamlandığında açılır; yıldız toplamı şartı yoktur.

## Canonical gameplay/release korumaları

- Grid: **8×8 / 64 hücre — LOCKED**.
- 6×10 tarihsel checkpointtir; geri dönmez.
- B5 60 sn, B10 120 sn soft challenge; hard-fail değildir.
- Minimum Kelime Avı yayın stoğu: **200 hazır/doğrulanmış bölüm**.
- 200/200 release-stock gate ve runtime/fiziksel kabul tamamlanmadan yeni Kelime Avı production release'i Play'e yüklenmez.
- `assets/questions.json`, BoardMap/67 node, Firebase, signing, version ve Play kapsamı açık owner kararı olmadan değiştirilmez.

**DEVİR SON DURUMU:** PR #203 MERGED / approved head `c89926b...` / squash merge `f312a233...` / approved ve merge tree `3e00a2d...` birebir aynı / `orman-2` teknik identity korunuyor / kullanıcı adı Kadim Orman / selector'da dördüncü rota olarak görünür ve Orman Yolu level 10 completion ile açılır / yıldız şartı yok / 1–10 progression korunuyor / generic `routeComplete` + data-driven `lockedMessage` kullanılıyor / tüm ilgili CI SUCCESS / immutable Orman 2 asset freeze aktif / source branch bilerek tutuluyor.