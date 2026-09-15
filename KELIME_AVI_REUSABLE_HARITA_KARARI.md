# Kelime Avı — Reusable Harita Mimari Kararı

**Karar tarihi:** 12 Eylül 2026

Bu belge, Kelime Avı'nın yeni 10 bölümlük rotaları için owner tarafından kabul edilip merge edilen harita mimarisi kararını kilitler. Amaç, önceki haritalarda yaşanan rota başına yaklaşık bir haftalık elle koordinat / görsel yerleşim döngüsünün tekrarlanmamasıdır.

## Kilitli ürün/mimari sözleşmesi

- Her rota 10 bölümden oluşur.
- Canonical sıra **1 → 2 → 3 → 4 → 5 → 6 → 7 → 8 → 9 → 10** şeklindedir.
- **8. bölüm bonus değildir; normal bölümdür.**
- Progression tamamen sıralıdır: 7 tamamlanınca 8, 8 tamamlanınca 9, 9 tamamlanınca 10 açılır.
- 10 node'un geometri/hitbox kaynağı tek reusable motordur; rota bazında ayrı node koordinat listesi yazılmaz.
- Yol geometrisi rota bazında elle Bézier koordinatı taşımaz; ortak motor deterministik üretir.
- Yeni rota için ayrı ekran/widget yazılmaz. Tek generic ekran sözleşmesi: `WordHuntThemedRouteMapScreen(route + visualTheme)`.
- Görsel skin verisi `WordHuntRouteVisualTheme` içinde tutulur: map theme, motif, palette, seed, dekor yoğunluğu/opacity. Bu veri paketi node koordinatı, hitbox veya progression taşıyamaz.
- Dekor yerleşimi normalize 0..1 yüzeyde seed tabanlı deterministik üretilir.
- Dekorlar node-safe bölgelere giremez.
- Katman sırası sabittir: **dekor → yol → node**.
- Dekor `IgnorePointer` altında olduğundan bölüm dokunmalarını engelleyemez.
- Forest / Sky / Harbor proof skinleri aynı generic ekran ve aynı geometri ile çalışır; motif türleri ayrı koordinat listesi taşımaz.
- Yeni rota eklemek için rota-id özel Widget/Painter/koordinat listesi gerekiyorsa bu mimari başarısız sayılır ve bu kalıp çoğaltılmaz.

## Merge zinciri

- PR #184 `feat(kelime-avi): introduce reusable 10-level route map engine`
  - exact HEAD: `b34bfddff5183692e62ac7c9bd49ad15140dae31`
  - merge commit: `1cf71e959177cbe05c01590091a4b69b7e3583cf`
  - exact-head Kelime Avı Android 16 workflow: SUCCESS
  - exact-head AdMob/full validation workflow: SUCCESS
- PR #186 `feat(kelime-avi): add deterministic route decoration layout`
  - exact HEAD: `6a3097b6d00738eb1d0f6ba7dd14aefe735eea76`
  - merge commit: `accc3cb861ab50c287ecf3b6461e00882ff1f2be`
  - #186 merge edilmeden önce doğrudan canonical release base'e retarget edildi ve mergeable doğrulandı.
  - exact-head Kelime Avı Android 16 workflow `34656596117`: SUCCESS
  - exact-head AdMob/full validation workflow `34656596109`: SUCCESS
  - focused Kelime Avı suite yeni dekor/layer/visual-theme testleri dahil PASS
  - analyzer + tüm testler PASS
  - release APK build + paket/manifest doğrulaması PASS
  - Android 16 cold-start ilk deneme PASS
  - AdMob application gate PASS

## Merge edilen ağaç ile test edilen ağaç eşitliği

Canonical release branch merge sonrası HEAD:

`accc3cb861ab50c287ecf3b6461e00882ff1f2be`

Test edilen PR HEAD:

`6a3097b6d00738eb1d0f6ba7dd14aefe735eea76`

Her iki commit'in Git tree SHA'sı aynıdır:

`73663864e1fd02deb511beac7014351ff010b000`

Bu nedenle `6a3097b...` üzerinde üretilen Action APK ve Android 16 kanıtları, merge edilen ürün kod ağacıyla birebir aynıdır.

## Action artifact kayıtları

- Release APK / AdMob kanıt artifact'i: `BilgiRotasi-AdMob-1.68.20-110-kanitlari`
  - artifact ID: `10286447609`
  - workflow run: `34656596109`
  - artifact digest: `sha256:457f06b1a7506448ada2b41882adf76e07b9fa8e9d980c36342aa7bd2f0c649e`
- Reusable map gerçek Android 16 artifact'i: `BilgiRotasi-KelimeAvi-ReusableMap-Android16-6a3097b6d00738eb1d0f6ba7dd14aefe735eea76`
  - artifact ID: `10286287449`
  - digest: `sha256:e002a00e5316efaceb9a26d24a04d239daba50f39bdcdd15db05f2439fef94ba`
- Reusable map widget proof artifact'i: `BilgiRotasi-KelimeAvi-ReusableMap-6a3097b6d00738eb1d0f6ba7dd14aefe735eea76`
  - artifact ID: `10285662241`
- Pixel proof artifact'i: `BilgiRotasi-KelimeAvi-PixelProof-6a3097b6d00738eb1d0f6ba7dd14aefe735eea76`
  - artifact ID: `10286267477`

## Bilerek henüz yapılmayanlar

Bu mimari merge'i aşağıdakileri **yapmaz**:

- yeni 180 bölümü runtime kataloğuna bağlamaz,
- 200 bölümün playable olduğunu iddia etmez,
- Orman Yolu veya diğer yeni rotaları production navigasyona otomatik eklemez,
- `assets/questions.json` dosyasını değiştirmez,
- BoardMap / 67 node'u değiştirmez,
- Firebase'i değiştirmez,
- production AdMob ayarlarını değiştirmez,
- signing/package-version değiştirmez,
- Play Console yükleme/yayınlama yapmaz.

## Sonraki uygulama kuralı

Yeni rotalar runtime'a bağlanırken önce bu reusable mimari kullanılacaktır. Rota entegrasyonu yapılırken canonical 1–10 geometri veya progression tekrar rota özel kodla kopyalanmayacaktır. Her yeni rota mümkün olduğunca yalnız **route data + visualTheme data** sağlayacaktır.

## Orman 2 pilot genericization zemini — tamamlandı

PR #201 ile Orman 2 asset-reuse pilotundan önce gereken minimum generic presentation zemini tamamlandı ve squash merge edildi.

- Onaylı/test edilen PR HEAD: `834ba8458a5493c336d5ac06e1735062100e9a4c`
- Squash merge commit: `19dd5ffa3a5d4b9d2588ef5030b99459fd04d37e`
- Approved PR HEAD ile squash merge commit aynı Git tree SHA'sına sahiptir: `73946e2d2b00f21f2e3dc09040ee3330f0696d1f`.
- **Reference canvas + tall ambient artık config-driven.** Orman 1'in 411×731 reference canvas ve mevcut tall ambient davranışı config üzerinden korunur.
- **Embedded decorative route + live nodes artık `artworkOverlayMode` ile config-driven.** Orman 1'de raster içindeki dekoratif rota korunurken canlı Flutter node/UI katmanı aynı davranışı sürdürür.
- **NodeSkin refactor pilot için ertelendi.** Mevcut node skin asset yollarına bu aşamada dokunulmadı.
- Orman 2 environment üretimi, yeni environment asset entegrasyonu veya Orman 2 production runtime bağlantısı bu adımın parçası değildir ve henüz başlatılmamıştır.

**Durum:** REUSABLE 10-LEVEL MAP ARCHITECTURE — OWNER APPROVED / MERGED / CI GREEN. ORMAN 2 PILOT GENERICIZATION ZEMİNİ TAMAMLANDI. ORMAN 2 ENVIRONMENT ENTEGRASYONU HENÜZ BAŞLAMADI.