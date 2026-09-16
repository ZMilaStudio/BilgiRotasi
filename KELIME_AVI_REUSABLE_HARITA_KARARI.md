# Kelime Avı — Reusable Harita Mimari Kararı

**Karar tarihi:** 12 Eylül 2026  
**Son durum güncellemesi:** 16 Eylül 2026

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
- Katman sırası sabittir: **dekor → yol → node**; embedded-route artwork modunda yol raster içinde olduğundan canlı route path ikinci kez çizilmez.
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
- yeni rotaları production navigasyona otomatik açmaz,
- `assets/questions.json` dosyasını değiştirmez,
- BoardMap / 67 node'u değiştirmez,
- Firebase'i değiştirmez,
- production AdMob ayarlarını değiştirmez,
- signing/package-version değiştirmez,
- Play Console yükleme/yayınlama yapmaz.

## Sonraki uygulama kuralı

Yeni rotalar runtime'a bağlanırken önce bu reusable mimari kullanılacaktır. Rota entegrasyonu yapılırken canonical 1–10 geometri veya progression tekrar rota özel kodla kopyalanmayacaktır. Her yeni rota mümkün olduğunca yalnız **route data + visualTheme data** sağlayacaktır.

## Orman 2 pilot genericization zemini — TAMAMLANDI

PR #201 ile Orman 2 asset-reuse pilotundan önce gereken minimum generic presentation zemini tamamlandı ve squash merge edildi.

- Onaylı/test edilen PR HEAD: `834ba8458a5493c336d5ac06e1735062100e9a4c`
- Squash merge commit: `19dd5ffa3a5d4b9d2588ef5030b99459fd04d37e`
- Approved PR HEAD ile squash merge commit aynı Git tree SHA'sına sahiptir: `73946e2d2b00f21f2e3dc09040ee3330f0696d1f`.
- **Reference canvas + tall ambient config-driven'dır.**
- **Embedded decorative route + live nodes `artworkOverlayMode` ile config-driven'dır.**
- NodeSkin refactor pilot için yapılmadı; mevcut Orman 1 node asset ailesi reuse edilebilir durumda bırakıldı.

## Orman 2 runtime pilotu — TAMAMLANDI / MERGED

PR #202 ile genericization zemini gerçek Orman 2 runtime pilotunda kullanıldı.

- PR: **#202 — `feat(kelime-avi): Orman 2 runtime pilot integration`**
- Approved PR head: `62d33d9a332a281b2d703432472e3d802668c17c`
- Approved head tree: `a4742ad244ec90a9ae41bf2b55ad48d7ceed14e5`
- Squash merge commit: `9aa3a2e8392a8fb42646d23c1e89ea9b67789c5a`
- Merge commit tree: `a4742ad244ec90a9ae41bf2b55ad48d7ceed14e5`
- Tree equality: **approved PR head ve squash merge tree birebir aynı**.

Merge edilen runtime sözleşmesi:

- Orman 2 ayrı route identity kullanır.
- PR #202 zamanındaki pilot gameplay verisi Orman 1'den reuse ediyordu; **bu gameplay reuse durumu PR #204 ile SUPERSEDED edilmiştir.** Runtime/presentation baseline'ı ise korunur.
- `referenceCanvasSize = 411×731`.
- `extendTallAmbientFromArtworkEdges = true`.
- `artworkOverlayMode = embeddedRouteLiveNodes`.
- Dekoratif rota raster içindedir; live Flutter route painter kapalıdır.
- Node/progression/chrome canlı Flutter katmanındadır.
- Orman 1 node asset ailesi reuse edilir.
- NodeSkin refactor yoktur.
- Route/theme-id özel renderer `if` yoktur.
- Canonical normalized stops değiştirilmemiştir.
- Başlangıç Limanı / Gökyüzü / Orman 1 davranışı değiştirilmemiştir.

Immutable asset:

`assets/word_hunt/ORMAN2_FINAL_941x1672.webp`

- 941×1672
- 1.109.268 byte
- SHA-256: `aede5c6f08b6fe4cd64d17a1ef309e13256dde1c1e97fbee0c53b019f63c6c8d`
- Git blob SHA: `43233bf2b0e8f16d59a15f0fe0bcda5f5e2bb80c`
- Re-encode / recompress / resize / crop / recolor yapılmaz.

Android 16 gerçek runtime proof:

- Workflow: `Orman Yolu Android çoklu ekran kanıtı`
- Run #20 / ID `35082179184`: **SUCCESS**
- Orman 2 job ID `104748515371`: **SUCCESS**
- 720×1280 / 1080×1920 / 1080×2400 gerçek emulator PNG proof: **PASS**
- Aynı exact HEAD'de Orman 1 regression job: **SUCCESS**
- Owner visual QA: double-route yok, ghost UI yok, node-route hizası kabul, tek header/chrome, tall ambient kabul, bloklayıcı seam/poster/letterbox yok.

Source branch `feat/kelime-avi-orman2-runtime-pilot-20260916` merge sonrası bilerek tutulmaktadır.

## Kadim Orman progression — TAMAMLANDI / MERGED

PR #203 ile Orman 2'nin kullanıcı-facing progression kararı tamamlandı. Teknik identity değişmeden `orman-2` kaldı; kullanıcı-facing ad **Kadim Orman** oldu.

- PR: **#203 — `feat(kelime-avi): unlock Kadim Orman after Orman Yolu`**
- Approved PR head: `c89926b270d89f52ca895b82a875c9b732fdb609`
- Approved head tree: `3e00a2d246f93eb3792a1d63748b2923fe30a13d`
- Squash merge commit: `f312a2333cb16e9a74f500fcc80c200325634439`
- Merge commit tree: `3e00a2d246f93eb3792a1d63748b2923fe30a13d`
- Squash commit parent: `044818e9c66eddc20f20b8a16e9497102736ddfa`
- Tree equality: **approved PR head ve squash merge tree birebir aynı**.

Onaylanan selector/progression sözleşmesi:

- Selector sırası: **Başlangıç Limanı → Gökyüzü → Orman Yolu → Kadim Orman**.
- Kadim Orman selector'da en baştan görünür.
- Fresh progress durumunda locked'dır.
- Exact locked metin: **“Orman Yolu’nu tamamlayarak aç.”**
- Orman Yolu level 9 tamamken locked kalır.
- Orman Yolu level 10 tamamlanınca unlocked olur.
- 30/30 yıldız şartı yoktur; toplam yıldız unlock koşulu değildir.
- Kadim Orman kendi içinde yine 1→10 progression kullanır.
- Orman Yolu ve Kadim Orman progression identity'leri ayrıdır.

Mimari uygulama:

- Mevcut generic `WordHuntRouteUnlockRule.routeComplete` kullanılır.
- Yeni prerequisite engine yoktur.
- Route-id özel selector/renderer `if` yoktur.
- Locked ürün metni catalog entry'deki `lockedMessage` üzerinden data-driven taşınır.
- Kilitli kart seçilemez.
- Orman 2 runtime theme/geometry/asset baseline'ı değişmemiştir.

CI kapanışı — exact approved HEAD `c89926b270d89f52ca895b82a875c9b732fdb609`:

- Route catalog Run #80 / ID `35092666128`: **SUCCESS**
- Orman multi-size Run #21 / ID `35092666124`: **SUCCESS**
- Kelime Avı Android 16 Run #439 / ID `35092666125`: **SUCCESS**
- AdMob PR validation Run #816 / ID `35092666130`: **SUCCESS**
- Focused selector tests: **18/18 PASS**
- Orman 2 runtime regression: **PASS**

Selector'a özel A/B Android screenshot artifact'i üretilmedi; fresh locked ve Orman Yolu final-complete unlocked state'leri gerçek Flutter widget testleriyle doğrulandı ve production'a proof/debug hack eklenmedi.

Source branch `feat/kelime-avi-kadim-orman-progression` merge sonrasında bilerek tutulmaktadır.

## Kadim Orman özgün gameplay/content — TAMAMLANDI / MERGED

PR #204 ile pilot dönemindeki Orman Yolu gameplay clone/reuse borcu kaldırıldı. Teknik route/level/progression identity korunurken Kadim Orman kendi production content'ine geçti.

- PR: **#204 — `feat(kelime-avi): give Kadim Orman original content`**
- Approved PR head: `a17cdcd4dab03dad567852db7421b3ce139f0213`
- Approved head tree: `a98c7cb23621276d36cd84f0d9055e535328d1cb`
- Squash merge commit / target HEAD: `755e90725d3062b74c0ce228bb1b6d7bbdfda4c0`
- Merge commit tree: `a98c7cb23621276d36cd84f0d9055e535328d1cb`
- Squash commit parent: `47855a96e51567782318f32990c76703813b9341`
- Tree equality: **approved PR head ve squash merge tree birebir aynı**.

Production content sözleşmesi:

- route id `orman-2`, title **Kadim Orman**, theme `orman`, reward `reward-orman-2` korunur,
- level id'leri `orman-2-01` … `orman-2-10` ve index 1..10 korunur,
- 10 bölümün tamamı özgün, statik ve deterministic 8×8 grid kullanır,
- targetWords ve bonusWords Kadim Orman'a özgüdür,
- B5 **Gece Gözleri** challenge / 60 sn,
- B10 **Ormanın Kalbi** routeFinal / 120 sn,
- runtime random grid generation yoktur,
- `WordHuntOrmanContent.infoCards` reuse, `WordHuntOrmanContent.ormanYolu.levels` clone/map ve `_clonePilotLevels()` artık yoktur.

Kadim Orman'ın kendi 6 bilgi kartı:

- `kadim-info-egrelti` — L1
- `kadim-info-sis` — L2
- `kadim-info-misel` — L4
- `kadim-info-baykus` — L5
- `kadim-info-kaynak` — L7
- `kadim-info-cinar` — L9

Kalite/CI kapanışı — exact approved HEAD `a17cdcd4dab03dad567852db7421b3ce139f0213`:

- 10/10 grid unique: **PASS**
- Orman Yolu gridleriyle birebir eşleşme yok: **PASS**
- corresponding targetWords listeleri birebir aynı değil: **PASS**
- target/bonus overlap yok: **PASS**
- `WordHuntDefinitionValidator` + `WordHuntContentValidator`: **PASS**
- info-card uniqueness/mapping + source-level clone/reuse regression + progression isolation: **PASS**
- selector/unlock, immutable asset, visual theme, normalized stops regressions: **PASS**
- Orman multi-size Run #22 / ID `35102022425`: **SUCCESS**
- Kelime Avı Android 16 Run #440 / ID `35102022388`: **SUCCESS**
- AdMob PR validation Run #817 / ID `35102022445`: **SUCCESS**
- repo-geneli analiz/tüm testler + release APK + manifest + Android 16 cold-start: **SUCCESS**

PR #204 source branch `feat/kelime-avi-kadim-orman-original-content` merge sonrasında bilerek tutulmaktadır.

## Sıradaki inceleme konusu

Yeni rota üretmeden önce **Orman Yolu content / bilgi kartı kalite-polisajı** incelenecektir. Orman Yolu `infoCards` şu anda boştur; kitap butonuna gerçek içerik kazandırılması ve target kelime havuzundaki tekrarların kalite açısından değerlendirilmesi sıradaki inceleme konusudur. Bu kayıt henüz ürün çözümü belirlemez.

**Durum:** REUSABLE 10-LEVEL MAP ARCHITECTURE — OWNER APPROVED / MERGED / CI GREEN. ORMAN 2 GENERICIZATION — MERGED. ORMAN 2 RUNTIME PILOT — MERGED / ANDROID 16 PROOF PASS / OWNER VISUAL QA PASS. KADİM ORMAN PROGRESSION — MERGED / SELECTOR'DA DÖRDÜNCÜ ROTA / ORMAN YOLU LEVEL 10 COMPLETION İLE UNLOCK / YILDIZ ŞARTI YOK / CI GREEN. KADİM ORMAN ORIGINAL CONTENT — MERGED / 10 ÖZGÜN STATİK 8×8 BÖLÜM / 6 ÖZGÜN INFO CARD / CLONE-REUSE BORCU KAPALI / CI GREEN.