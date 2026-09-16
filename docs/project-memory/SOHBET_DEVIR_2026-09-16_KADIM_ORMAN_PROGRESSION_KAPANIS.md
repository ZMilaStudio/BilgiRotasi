# Sohbet Devri — Kadim Orman Progression Kapanışı

**Tarih:** 16 Eylül 2026  
**Repo:** `ZMilaStudio/BilgiRotasi`  
**Target branch:** `release/final-closed-test-aab-1.68.8`

## Nihai durum

**Kadim Orman progression kararı tamamlandı, test/CI kapıları geçti ve PR #203 ile squash merge edildi.**

PR #202 ile production runtime'a bağlanan teknik `orman-2` rotası artık kullanıcı-facing olarak **Kadim Orman** adını kullanır ve production selector'da dördüncü rota olarak görünür.

## PR #203 kapanış kaydı

- PR: **#203 — `feat(kelime-avi): unlock Kadim Orman after Orman Yolu`**
- Approved PR head: `c89926b270d89f52ca895b82a875c9b732fdb609`
- Approved head tree: `3e00a2d246f93eb3792a1d63748b2923fe30a13d`
- Squash merge commit: `f312a2333cb16e9a74f500fcc80c200325634439`
- Merge commit tree: `3e00a2d246f93eb3792a1d63748b2923fe30a13d`
- Squash commit parent: `044818e9c66eddc20f20b8a16e9497102736ddfa`
- Tree equality: **EVET — approved PR head tree ile squash merge tree birebir aynı.**
- Progression kapanışında target HEAD: `f312a2333cb16e9a74f500fcc80c200325634439`.
- Bu devir dokümanını ekleyen docs-only commit target HEAD'i bunun üstüne ilerletebilir; yeni sohbette canlı HEAD yeniden doğrulanmalıdır.

## Onaylanan ürün kararı

Teknik route id:

`orman-2`

Kullanıcı-facing ad:

**Kadim Orman**

Selector sırası:

1. Başlangıç Limanı
2. Gökyüzü
3. Orman Yolu
4. Kadim Orman

Kadim Orman:

- selector'da en baştan görünür,
- fresh progress durumunda kilitlidir,
- locked copy tam olarak **“Orman Yolu’nu tamamlayarak aç.”** şeklindedir,
- Orman Yolu level 9 tamamlandığında kilitli kalır,
- Orman Yolu level 10 tamamlandığında açılır,
- 30/30 yıldız şartı yoktur,
- toplam yıldız sayısı unlock koşulu değildir,
- kendi içinde 1→10 olarak görünür; 21–30 numaralandırması yapılmaz,
- progression identity Orman Yolu'ndan ayrıdır.

## Mimari kapanış

- Mevcut generic `WordHuntRouteUnlockRule.routeComplete` kullanıldı.
- Yeni prerequisite engine eklenmedi.
- `if (route.id == 'orman-2')` benzeri route-id özel selector/renderer davranışı eklenmedi.
- Exact locked ürün metni catalog entry içindeki `lockedMessage` alanı üzerinden data-driven taşınır.
- Kilitli selector kartı `onTap: null` ile seçilemez.
- Başlangıç Limanı / Gökyüzü / Orman Yolu mevcut unlock contract'ları korunur.
- Orman Yolu gameplay/progression verisi değiştirilmedi.
- Orman 2 visual theme / normalized stops / runtime composition değiştirilmedi.
- NodeSkin refactor yapılmadı.

## Immutable Kadim Orman asset freeze

Production asset:

`assets/word_hunt/ORMAN2_FINAL_941x1672.webp`

- dimensions: **941×1672**
- bytes: **1.109.268**
- SHA-256: `aede5c6f08b6fe4cd64d17a1ef309e13256dde1c1e97fbee0c53b019f63c6c8d`
- Git blob SHA: `43233bf2b0e8f16d59a15f0fe0bcda5f5e2bb80c`

Freeze bağlayıcıdır: **re-encode / recompress / resize / crop / recolor / yeniden üretme yok.**

## CI / test kapanışı

Exact approved HEAD:

`c89926b270d89f52ca895b82a875c9b732fdb609`

- Kelime Avı route catalog kapısı — Run **#80**, ID `35092666128`: **SUCCESS**
- Orman Yolu Android çoklu ekran kanıtı — Run **#21**, ID `35092666124`: **SUCCESS**
- Kelime Avı Android 16 görsel kanıtı — Run **#439**, ID `35092666125`: **SUCCESS**
- AdMob PR doğrulaması — Run **#816**, ID `35092666130`: **SUCCESS**
- Focused selector tests: **18/18 PASS**
- Orman 2/Kadim Orman runtime regression: **PASS**
- Aynı exact HEAD üzerinde Orman Yolu ve Orman 2 Android 16 multi-size jobs: **SUCCESS**
- Repo-geneli analiz ve tüm Flutter testleri: **SUCCESS**
- Release APK / manifest / Android 16 cold-start gate: **SUCCESS**

Selector'a özel fresh-vs-unlocked A/B Android screenshot artifact'i üretilmedi. Bu bilinçli olarak bloklayıcı kabul edilmedi; state davranışları gerçek Flutter widget testleriyle doğrulandı ve production'a proof/debug hack eklenmedi.

## PR #202 runtime baseline — korunuyor

Kadim Orman progression değişikliği PR #202 ile merge edilmiş runtime baseline'ını değiştirmedi:

- route id `orman-2`,
- theme id `orman-2-production`,
- `referenceCanvasSize = 411×731`,
- `extendTallAmbientFromArtworkEdges = true`,
- `artworkOverlayMode = embeddedRouteLiveNodes`,
- decorative route raster içinde,
- live Flutter route painter kapalı,
- node/progression/chrome canlı Flutter katmanında,
- normalized stops değişmedi.

## Source branch

Source branch:

`feat/kelime-avi-kadim-orman-progression`

Branch merge sonrasında bilerek **henüz silinmedi**. Owner ayrıca istemeden silinmez.

PR #202 source branch `feat/kelime-avi-orman2-runtime-pilot-20260916` da daha önce bilerek tutulmuştu.

## Yeni sohbet başlangıç kuralı

1. `docs/project-memory/GENEL_PROJE_OZETI.md` dosyasını oku.
2. Bu devir notunu oku.
3. `KELIME_AVI_REUSABLE_HARITA_KARARI.md` dosyasını oku.
4. Canlı target HEAD ve source branch durumunu GitHub'dan doğrula.
5. Kadim Orman selector/progression kararını yeniden açma; PR #203 ile kapanmıştır.
6. Yeni ürün işi, bundan sonraki açık karar veya yeni rota içeriği üzerinden başlatılmalıdır.

**DEVİR SON DURUMU:** PR #203 MERGED / technical route `orman-2` korunuyor / kullanıcı-facing ad Kadim Orman / selector'da dördüncü rota / fresh locked / exact copy “Orman Yolu’nu tamamlayarak aç.” / Orman Yolu level 10 completion ile açılır / yıldız şartı yok / 1–10 progression korunuyor / generic `routeComplete` + data-driven `lockedMessage` / tüm ilgili CI PASS / immutable asset freeze aktif / source branch tutuluyor.