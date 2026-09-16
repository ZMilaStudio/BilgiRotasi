# Sohbet Devri — Orman 2 Runtime Pilotu Kapanış

**Tarih:** 16 Eylül 2026  
**Repo:** `ZMilaStudio/BilgiRotasi`  
**Target branch:** `release/final-closed-test-aab-1.68.8`

## Nihai durum

**Orman 2 runtime pilotu tamamlandı, gerçek Android 16 kanıtları ve owner görsel QA kapıları geçti ve PR #202 ile squash merge edildi.**

Orman 2 ayrı route identity + generic presentation config ile production runtime mimarisine bağlandı. Pilot gameplay verisi Orman 1'den reuse edilir; Orman 2 kullanıcı selector'ında henüz açılmamıştır.

## PR #202 kapanış kaydı

- PR: **#202 — `feat(kelime-avi): Orman 2 runtime pilot integration`**
- Approved PR head: `62d33d9a332a281b2d703432472e3d802668c17c`
- Approved head tree: `a4742ad244ec90a9ae41bf2b55ad48d7ceed14e5`
- Squash merge commit: `9aa3a2e8392a8fb42646d23c1e89ea9b67789c5a`
- Merge commit tree: `a4742ad244ec90a9ae41bf2b55ad48d7ceed14e5`
- Merge commit parent: `ac444cbb8a6c98a0f6699e352f331724692a304c`
- Tree equality: **EVET — approved PR head tree ile squash merge tree birebir aynı.**
- Runtime kapanışında target HEAD: `9aa3a2e8392a8fb42646d23c1e89ea9b67789c5a`.
- Bu devir dokümanını ekleyen docs-only commit target HEAD'i bunun üstüne ilerletebilir; yeni sohbette canlı HEAD yeniden doğrulanmalıdır.

## Immutable Orman 2 asset freeze

Production asset:

`assets/word_hunt/ORMAN2_FINAL_941x1672.webp`

- dimensions: **941×1672**
- bytes: **1.109.268**
- SHA-256: `aede5c6f08b6fe4cd64d17a1ef309e13256dde1c1e97fbee0c53b019f63c6c8d`
- Git blob SHA: `43233bf2b0e8f16d59a15f0fe0bcda5f5e2bb80c`

Freeze bağlayıcıdır: **re-encode / recompress / resize / crop / recolor / yeniden üretme yok.**

## Merge edilen runtime kararları

- Orman 2 bağımsız route identity'ye sahiptir.
- Gameplay verisi pilot kapsamında Orman 1'den reuse edilir.
- Orman 2 selector'da kullanıcıya henüz açılmamıştır.
- Generic presentation config kullanılır.
- `referenceCanvasSize = 411×731`.
- `extendTallAmbientFromArtworkEdges = true`.
- `artworkOverlayMode = embeddedRouteLiveNodes`.
- Dekoratif route raster environment içindedir.
- Orman 2 live Flutter route painter **kapalıdır**.
- Progression/node/chrome Flutter katmanında canlı kalır.
- Orman 1 node asset ailesi reuse edilir.
- NodeSkin refactor yapılmadı.
- Route/theme-id özel hardcoded renderer `if` eklenmedi.
- `WordHuntRouteMapGeometry.normalizedStops` değiştirilmedi.
- Orman 1 / Başlangıç Limanı / Gökyüzü davranışı değiştirilmedi.

## Android 16 proof / CI kapanışı

Exact proof HEAD:
`62d33d9a332a281b2d703432472e3d802668c17c`

Workflow:
**Orman Yolu Android çoklu ekran kanıtı**

- Run: **#20**
- Run ID: `35082179184`
- Overall: **SUCCESS**

Orman 2 job:
**Orman 2 Android 16 çoklu ekran kanıtı**

- Job ID: `104748515371`
- Result: **SUCCESS**

Artifact:
`BilgiRotasi-KelimeAvi-Orman2-MultiSize-62d33d9a332a281b2d703432472e3d802668c17c`

- Artifact ID: `10440972427`

Gerçek Android 16 emulator proof:

- `WORD_HUNT_ORMAN2_ANDROID16_COMPACT_720x1280.png` — **720×1280**
- `WORD_HUNT_ORMAN2_ANDROID16_STANDARD_1080x1920.png` — **1080×1920**
- `WORD_HUNT_ORMAN2_ANDROID16_TALL_1080x2400.png` — **1080×2400**

Aynı exact HEAD'de mevcut Orman 1 regression job'u da **SUCCESS** tamamlandı.

Runtime proof ayrıca gerçek Orman 2 asset'ini direct `rootBundle.load(WordHuntOrman2VisualTheme.assetPath)` ile yükleyip **941×1672 / 1.109.268 byte** decode gate'ini ve frame-ready marker'ını geçti.

## Owner görsel QA sonucu

Owner tarafından gerçek Android proof'ları kabul edildi:

- double-route yok,
- ghost UI yok,
- node-route hizası kabul edildi,
- header/chrome tek,
- tall ambient kabul edildi,
- bloklayıcı seam/poster/letterbox sorunu yok,
- Orman 2 görsel kimliği Orman 1'den yeterince farklı.

**Codex kullanılmadı ve bu pilot için artık gerekli değildir.**

## Source branch

Source branch:
`feat/kelime-avi-orman2-runtime-pilot-20260916`

Branch merge sonrasında bilerek **henüz silinmedi**. Owner ayrıca istemeden silinmez.

## Sıradaki ürün kararı

**“Orman 2’nin kullanıcıya ne zaman ve nasıl açılacağı / progression içindeki konumu.”**

Bu karar verilene kadar:

- Orman 2 selector'a açılmaz,
- progression/navigation içinde yeni konum varsayılmaz,
- immutable asset veya merge edilmiş runtime sözleşmesi yeniden tasarlanmaz.

## Yeni sohbet başlangıç kuralı

1. `docs/project-memory/GENEL_PROJE_OZETI.md` dosyasını oku.
2. Bu devir notunu oku.
3. Canlı target HEAD ve source branch durumunu GitHub'dan doğrula.
4. Orman 2 runtime pilotunu yeniden açma; teknik pilot kapanmıştır.
5. Bir sonraki çalışma ancak Orman 2'nin kullanıcıya açılma/progression ürün kararı üzerinden başlatılır.

**DEVİR SON DURUMU:** PR #202 MERGED / runtime+CI+Android proof+owner visual QA PASS / immutable asset freeze aktif / Orman 2 selector'da kapalı / source branch tutuluyor / sıradaki karar Orman 2'nin kullanıcıya açılma şekli ve progression konumu.
