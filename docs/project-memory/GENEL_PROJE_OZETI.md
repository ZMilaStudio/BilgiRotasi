<!-- GOKYUZU_R7_ANDROID16_START -->
## 5 Eylül 2026 — Gökyüzü Adaları R7 current checkpoint
- Canlı canonical release: `3557a7e4f2f2917d61ba61866c6d4c8561994667`; sürüm `1.68.19+109`.
- Gökyüzü görünür rota mimarisi artık bağlayıcı olarak **phone MASTER ART raster + transparent hitbox + minimum lokal runtime-state overlay** yaklaşımıdır; önceki modüler görünür renderer kararı bu rota için superseded edilmiştir.
- PR #175 OPEN/DRAFT; exact ürün HEAD `f35082c44e637cb7e6e3815c7d54d38a58b776df`.
- Güncel MASTER ART `941×1672`, `510998` bayt, SHA256 `913ee19df9fcb1eba2ac6ca3a500979c960d31dd369e204d2f79064be9664b1d`.
- R7'de yalnız eski 8/9/10 alt bölgesindeki bağımsız merkez kilit + üç yıldız görseli kaldırıldı; dinamik node lock badge/progression ayrı runtime state olarak korunur.
- Test-before-commit `33971902782` SUCCESS; Android16 `33972011069` / job `101322071661` SUCCESS; analyze temiz; 39/39 PASS; raw screenshot `1080×1920`, SHA256 `79edc57a575d2bdf59407260fe272993e69400a23d520687ac71680d58228637`, artifact `9971319096`.
- Teknik Android16 kapısı PASS; Levent human visual acceptance hâlâ AÇIK. Görsel PASS sonrası gerçek cihaz APK kabulü; Ready/merge ve Play ayrıca açık onay gerektirir.
<!-- GOKYUZU_R7_ANDROID16_END -->

<!-- GOKYUZU_R6_ANDROID16_START -->
## 5 Eylül 2026 — Gökyüzü R6 Android16 devir checkpointi
Gökyüzü Adaları current replacement hattı PR #175'tir: **OPEN / DRAFT / mergeable**, exact ürün HEAD `560d76bd828e0b4d813218f1000b895da9d0c7fa`; canonical release `3557a7e4f2f2917d61ba61866c6d4c8561994667`, sürüm `1.68.19+109` değişmedi.

Phone MASTER ART `941×1672`, `437438` bayt, SHA256 `db44920c5e25163d0b3f317a96d6e7bcc9e48aa7a4ce8654573728a423dc7f34`. Son düzeltme commit'i `560d76bd...` (`fix(kelime-avi): stretch gokyuzu phone viewport`) full-width parent stretch ekledi. Canonical → product diff yalnız 5 ürün dosyasıdır; protected scope temizdir.

Final R6 raw Android16 run `33967506643` / job `101310099566` **SUCCESS**: analyzer No issues found, focused + Başlangıç Limanı regression 39/39 PASS, APK/API36/install/launch/resumed/semantics/crash-ANR taraması PASS. APK SHA256 `ddd6284d21387b7ab0762ef10856bcc2401b5ce8aa2da3b786b90aa85a1f2a39`; raw screenshot exact 1080×1920, SHA256 `2c4da0a1a22f443b65b5656d71d4ccfef983f0600ba6effcd3bc9e27dbe18e44`; artifact `9970009097`.

Teknik kapı **PASS**. Tek mevcut ürün kapısı Levent'in raw R6 ekranına human visual PASS/FAIL vermesidir. PASS sonrası gerçek cihaz APK kabulü gelir. PR #175 Ready/merge ve Play ayrı açık onay olmadan yapılmaz. R3/R4 artık current teknik aday değildir; geçmiş kanıt olarak korunur. Codex kullanılmadı.
<!-- GOKYUZU_R6_ANDROID16_END -->

<!-- GOKYUZU_R4_STATIC_PROOF_START -->
## 5 Eylül 2026 — Gökyüzü R4 tall-viewport statik aday
- Approved Gökyüzü Adaları V2 master art production tabanı olarak uygulanıyor; PR #175 OPEN/DRAFT @ `4145f0fe...`.
- R3 Android16 teknik PASS; merkez V2 doğru, üst/alt düz letterbox human visual PASS değil.
- R4 statik 1080×1920 aday hazır: `gokyuzu_tall_viewport_static_proof_r4e.png`, SHA256 `96cef05fdf9f5f59ed37ad4829cef1e225858905d1fb01d20b826f8e402ae8bf`.
- R4 yalnız MASTER ART dışındaki üst/alt alanı gökyüzü/bulut uzatmasıyla doldurur; merkez approved V2 değişmez.
- R4 gerçek Android kanıtı değildir. Levent görsel PASS bekleniyor; PASS olmadan #175 ürün branch'i değiştirilmez.
<!-- GOKYUZU_R4_STATIC_PROOF_END -->

# Bilgi Rotası — Genel Proje Özeti

<!-- GOKYUZU_VIEWPORT_R3_START -->
## 5 Eylül 2026 — Gökyüzü V2 viewport R3 devir checkpointi
Gökyüzü Adaları replacement MASTER ART hattı teknik olarak çalışıyor. #175 OPEN/DRAFT ve exact product HEAD `4145f0fe8d716d6951e1ee53215812b56150c73c`; canonical release `3557a7e4f2f2917d61ba61866c6d4c8561994667`, sürüm `1.68.19+109` değişmedi.

R2 raw Android16 ekranında approved V2 merkez sanat doğruydu fakat koyulaştırılmış aynı MASTER ART'ın `BoxFit.cover` arka kopyası üst/alt sahneyi tekrarladı; bu nedenle R2 görsel kabul edilmedi. Product branch'i değiştirmeden yapılan QA-only R3, duplicate cover arka planı kaldırdı ve sadece dış alan için gökyüzü gradienti kullandı. Final run `33952294411` / job `101269226635` SUCCESS; analyzer PASS, 39/39 regression PASS, APK/API36/install/launch/runtime/semantic/crash-ANR taraması PASS. R3 APK SHA256 `cd74d995b644a339074ad600cec7497103613f80bfcaf11d04a1d2e83eecb742`; raw 1080×1920 screenshot SHA256 `fcf7b065fc58453fe343bb7fedb9feb1641ae06df8348cec4debfd77bef65aa7`; artifact `9965315644`.

R3 ile approved V2 kompozisyon doğru biçimde görünür hale geldi fakat 1085×1536 kaynak `contain` edildiğinde tall-device üst/alt letterbox alanı kalıyor. Bu yüzden teknik R3 PASS, nihai görsel PASS değildir. Sıradaki iş Flutter/merge değil: approved V2 çekirdeğini değiştirmeden yalnız üst/alt alanı doğal gökyüzü/dünya uzatmasıyla tamamlayan statik full-screen proof üretmek ve Levent görsel PASS almak. Sonra #175 productize + yeniden raw Android16. Ready/merge/Play yok. Codex kullanılmadı.
<!-- GOKYUZU_VIEWPORT_R3_END -->


**Son güncelleme:** 5 Eylül 2026 — Kelime Avı V9: Gökyüzü onaylı V2 referansı File Library'de yeniden bulundu (`Gökyüzü Adaları: Büyülü Seviye Haritası.png`, id `file_00000000fe7c81f4aec58eee1d5c702d`). #173 raw renderer görsel FAIL'in kökü koddan doğrulandı: beyaz top chrome/Material kontroller, küçük scene ölçeği, beyaz label kapsülleri ve basit CustomPainter rota V2 tasarım dilini taşımıyor. Mevcut 48 runtime assetle deterministik statik production proof hazır; Levent görsel incelemesi bekleniyor. PASS olmadan Flutter/APK aşamasına geçilmez. Canonical release `3557a7e4...`, sürüm `1.68.19+109`; Ready/merge/Play yok.

> Teknik doğrulukta tek kanonik kaynak canlı `ZMilaStudio/BilgiRotasi` deposu ve ilgili canlı servislerdir. Bu dosya canlı branch/PR/CI/pubspec doğrulamasının yerine geçmez. Ayrıntılı eski üretim günlükları Git geçmişinde ve `docs/project-memory/archive/` altında korunur.

## Kalıcı Çalışma Kuralı

- Her görev başında canlı hedef branch, `pubspec.yaml`, son commit, PR ve CI yeniden doğrulanır.
- `main` güncel/yayın kaynağı varsayılmaz.
- Sıra: branch → test → commit → push → PR → inceleme → merge.
- Kritik merge/release yalnız Levent’in açık onayıyla yapılır.
- Build PASS tek başına kanıt değildir; diff, test, workflow, log, Git geçmişi ve gerçek runtime kanıtı birlikte değerlendirilir.
- Görsel kabul yalnız gerçek/raw Android runtime üzerinden verilir; ImageGen/mockup/QA selector acceptance kanıtı değildir. Statik mock onayı yalnız tasarım yönü kabulüdür.
- `assets/questions.json` kontrolsüz değiştirilmez; ilgisiz değişiklikler silinmez.
- Codex yalnız mevcut araçlarla yapılamayan zorunlu yerel kod/test işi olduğunda kullanılır; gereksiz Codex kredisi harcanmaz.
- Kelime Avı için WORK V2 geçerlidir: mikro adım + rapor + bekleme döngüsü yerine mümkün olan en büyük mantıklı üretim bloğu tek çalışma döngüsünde tamamlanır.

## Canlı Release Hattı

- Repo: `ZMilaStudio/BilgiRotasi`.
- Canonical release branch: `release/final-closed-test-aab-1.68.8`.
- Canonical release HEAD: **`3557a7e4f2f2917d61ba61866c6d4c8561994667`**.
- Aktif ürün sürümü: **1.68.19+109**.
- Paket: `com.leventua.bilgirotasi`.
- PR #158 canonical gameplay paketini release’e taşıdı; merge commit `189864c92a605e7bb960460300714049c730ea39`.
- PR #169 production ana navigasyon entegrasyonunu release’e taşıdı; merge commit `0c84aefd8a5ef591aaaab9eaa30bed2e044190cf`.
- PR #168 canonical checkpoint belgelerini release’e taşıdı; docs-only merge commit `3557a7e4f2f2917d61ba61866c6d4c8561994667`.
- Play Console’a bu çalışma için yeni yükleme veya yayınlama yapılmadı.

## Başlangıç Limanı — RELEASE PASS / KORUNACAK

- İlk rota/paket: **Başlangıç Limanı**.
- Rota hedefi: 10 bölüm / 30 yıldız.
- Issue #109 `Photo 1.jpg` rota ekranı için bağlayıcı görsel kaynaktır.
- Production rota tabanı: MASTER ART raster + şeffaf hitbox + minimum lokal runtime-state override.
- Level 7 tamamlanınca bonus 8 ve normal 9 birlikte açılır; bonus 8, 9 için gate değildir; 10, node 9 tamamlanmadan locked/no-callback.
- BoardMap / 67 node sözleşmesi kontrolsüz değiştirilmez.
- Bu MASTER ART istisnası sonraki Kelime Avı rotalarına otomatik genellenmez.
- Production Oyna menüsüne `Kelime Avı` kartı release üzerinde entegredir.
- PR #169 full-suite/release APK/Android16 run `33754851284`: SUCCESS.
- Kelime Avı Android16 görsel run `33754851205`: SUCCESS; 126/126 PASS; artifact `9893332600`.

## Canonical Gameplay Sözleşmesi — LOCKED

- Grid: **8×8 / 64 hücre — LOCKED**.
- Önceki 6×10 yalnız tarihsel checkpointtir; ürüne geri dönmez.
- Target+bonus eğrisi: B1 5+1, B2 5+1, B3 6+1, B4 6+1, B5 7+1, B6 7+1, B7 8+1, B8 7+2, B9 9+1, B10 9+1; toplam **80**.
- Her target/bonus 8 düz yönde exactly-one fiziksel occurrence taşır; ters gesture aynı canonical kelimeye çözülür.
- B5 60 sn ve B10 120 sn soft challenge; hard-fail değildir.
- Engine/path/scoring/timer/progression sözleşmesi görsel tema uğruna değiştirilmez.
- Swipe false-positive toleransı: kelime olamayacak kısa gesture cezasız iptal; yalnız son hücre çıkarılınca exact çözüm oluşuyorsa tek trailing hücre kırpılır; ilk aktif pointer gesture boyunca kilitlenir; iki hücre taşma ve gerçek yanlış seçim hata kalır.

## V5 / V6 Ürün Kabulü — PASS / YENİDEN AÇILMAZ

- Found-state exact commit `4dddf00178ef9f14b8edb3fc706114be72f477a4`; Android16 run `33486609120`: SUCCESS; raw Android kullanıcı PASS.
- Error-state: fill `0xB35A1F2B`, border `0xFFFF6B57`, transient 280 ms; Android16 `33524578623`: SUCCESS; raw Android kullanıcı PASS.
- Completion/result: targetlar tamam bonus eksikse otomatik popup yok; tüm target+bonus tamamlanınca popup otomatik açılır.
- Static/productize `33629855060`: SUCCESS, Word Hunt 139/139 PASS.
- Android16 `33655562508`: SUCCESS; raw Android B5/B10 kullanıcı PASS.
- B5 tuning sonrası insan testi **32 sn** → süre PASS; Android16 tuning `33670657723`: SUCCESS.
- Swipe ürün commit `749c678b885d6cefec428c603c55a83a4190152c`; fast `33724552713`: SUCCESS; Android16 `33724549202`: SUCCESS.
- Yeni belirti yoksa bu kabul kapıları yeniden açılmaz.

## Gökyüzü Adaları — Paket 2 LOCKED Kararlar

- Paket adı: **Gökyüzü Adaları — LOCKED**.
- Görsel yön: **Konsept C — Neşeli & Parlak — LOCKED**.
- Teknik görsel mimari: **modüler asset yaklaşımı — LOCKED**.
- Atmosfer: neşeli, renkli, pozitif, eğlenceli, çocuk dostu, hafif ve canlı.
- Palet: açık gök mavisi/camgöbeği/turkuaz; yeşil yüzen adalar; sarı-turuncu sıcak vurgu; destekleyici pembe/mercan; parlak beyaz bulutlar.
- Konsept C yalnız sanat yönü referansıdır; final production veya raw Android acceptance kanıtı değildir.

### Kilitli rota

1. Rüzgâr Kapısı
2. Bulut Bahçesi
3. Kuş Geçidi
4. Gökkuşağı Köprüsü
5. Fırtına Kulesi
6. Hava Gemisi Limanı
7. Ay İskelesi
8. Gizli Ada — bonus
9. Yıldız Gözlemevi
10. Güneş Sarayı

- 7 sonrası bonus 8 ve normal 9 birlikte açılır; bonus 8, 9 için gate değildir.
- 10, node 9 tamamlanmadan locked kalır.

### Rota mock V2 — STATİK GÖRSEL PASS

- İlk mock'taki `Mağaza / Başarılar / Oyna / Sıralama / Rozetler` genel alt menüsü rota ekranına ait olmadığı için **REJECTED / superseded**.
- V2 Başlangıç Limanı rota kabuğuyla hizalıdır: alt genel menü yok; sol üst geri, sağ üst bilgi, alt köşelerde yalnız rota içi kontroller.
- 10 bölüm ayrı UI kullanmaz. Ortak node/plaque/star/progression dili korunur; bölüm farkı landmark, ada ve lokal atmosferle verilir.
- Levent 3 Eylül 2026'da düzeltilmiş rota mock V2'yi **onayladı**.
- Bu kabul yalnız **statik tasarım yönü PASS**'idir; raw Android runtime acceptance değildir.

## Gökyüzü Adaları — Runtime Asset Checkpointi

### Production yönünün rafinesi

- İlk 48-asset taslağındaki ayrı `ada tabanı + landmark overlay` zorlaması, üretilen sanatın doğal kompozisyonunu bozduğu için runtime core sözleşmesinde rafine edildi.
- Kullanıcıya görünen V2 tasarım yönü değiştirilmedi.
- Runtime core: **41 asset** = 14 atmosfer/yol + 10 `scene_level_01..10` bölüm sahne composite + 17 node/progression UI/dekor.
- Opsiyonel kütüphane: **7 island variant**.
- Toplam logical runtime asset: **48 WebP**.
- Dinamik bölüm numarası, yıldız sayısı, kilit/progression metni core node assetlerine bake edilmez.
- Büyük gradient/renk alanları Flutter tarafından çizilebilir; illüstratif parçalar modüler raster asset olur.

### Production/Runtime QA

- 48 production candidate PNG'den runtime WebP seti hazırlandı.
- Runtime ZIP boyutu: **557.120 bayt**.
- ZIP SHA256: **`d219c6233fa27f5e3e04687ec5fd15dab1f24500584e78d6a7c80036ee68f5ca`**.
- ZIP integrity/test: PASS.
- İçerik: **48/48 WebP**.
- 48/48 dosyada alpha kanalı mevcut.
- 8 px dış kenarda `alpha >= 8` yok; maksimum yalnız düşük alpha fringe (`alpha 4`) görüldü. Doğru QA ifadesi: **8px border alpha<8 PASS**. `tamamen sıfır alpha border` iddiası kullanılmayacak.
- Bu QA dosya/format/alpha/crop güvenlik QA'sıdır; **raw Android runtime görsel PASS değildir**.
- Flutter rota entegrasyonu tamamlandıktan sonra Android16 raw screenshot + crash/ANR/log kanıtı ve Levent'in gerçek görsel kabulü ayrıca gerekir.

## Gökyüzü Adaları — Canonical 8×8 İçerik Paketi / PR #171

- PR #171: **OPEN / DRAFT / mergeable=true**.
- Başlık: `feat(kelime-avi): add Gokyuzu 8x8 content pack`.
- Base: `release/final-closed-test-aab-1.68.8` @ `3557a7e4f2f2917d61ba61866c6d4c8561994667`.
- Exact HEAD: `4ec33de7438fcbd15ed63b1ae2adda127da3be8c`.
- Değişiklik: yalnız 2 dosya; `lib/word_hunt/word_hunt_gokyuzu_content.dart` + `test/word_hunt_gokyuzu_content_test.dart`.
- 10 bölüm / 30 yıldız / toplam **80 target+bonus**.
- Eğri: `5+1, 5+1, 6+1, 6+1, 7+1, 7+1, 8+1, 7+2, 9+1, 9+1`.
- Her kelime exactly-one fiziksel occurrence taşır; forward/reverse gesture aynı canonical kelimeye çözülür.
- B1–B2 yatay/dikey başlangıç; B5 ve B10 yatay+dikey+çapraz yön ailelerini birlikte taşır.
- B5 60 sn; B10 120 sn.
- Gökyüzü içerik özel bonusları: B8 `SIRLAR` + `HAZİNE`, B9 `ROKET`, B10 `ZAFER`.
- `assets/questions.json`, Başlangıç Limanı, gameplay engine/path/scoring/timer/progression, BoardMap/67 node, Firebase/AdMob/signing/Android config ve package/version değişmedi.
- Exact HEAD üzerinde ilgili CI kanıtları SUCCESS olarak doğrulandı.
- Ready/merge yalnız Levent'in ayrı açık onayıyla yapılır.

## Firestorage Binary Transfer Checkpointi — 5 Eylül 2026

- Büyük binary dosyaları GitHub connector üzerinden base64/blob parçalarıyla taşımak uzun, kırılgan ve sohbeti kilitlemeye yatkın çıktı.
- Birden fazla 8k/12k/18k/20k/30k/50k parça denemesi yapıldı; bazı unreferenced bloblar erişilemez oldu veya payload kesilmesi nedeniyle beklenen Git SHA eşleşmedi.
- Bu eski chunk/blob aktarım yolu **ABANDONED / final ürün akışında kullanılmayacak**.
- Eski `.transfer`, `raw8`, `v5`, `tmp/gokyuzu-materialize-*` veya benzeri deneme branch/objeleri **canonical ürün asseti değildir**; final asset PR'a taşınmamalıdır.
- 5 Eylül 2026'da `firestorage.ai` bağlantısı başarıyla kuruldu.
- Google Drive'daki native `gokyuzu_transfer_chunks18_native` Sheet XLSX olarak dışa aktarıldı.
- Firestorage'a başarıyla yüklenen dosya: `gokyuzu_transfer_chunks18_native`.
- Firestorage file id: `01a06e6342ff774994dd33280571724e`.
- Firestorage public id: `G2aJFQx9RHUWoAue`.
- Share URL: `https://firestorage.ai/ja/f/hc_Qp-jw2yHk`.
- Boyut: **1.129.386 bayt**.
- Retention: **72 saat**; Firestorage kayıtlarında expiry `2026-09-07T21:46:34Z`.
- Share URL'yi bilen kişiler erişebilir; yalnız geçici teknik transfer için kullanılacaktır.
- Firestorage'ın bu projedeki yeni tercih edilen rolü: büyük ZIP/XLSX/görsel paketlerini kullanıcıyı manuel taşıma operatörü yapmadan geçici olarak GitHub materialization akışına ulaştırmak.
- Codex bu transfer işi için kullanılmadı ve gerekmiyor.

### Firestorage sonrası sıradaki exact teknik işlem

1. Firestorage'daki `gokyuzu_transfer_chunks18_native` XLSX'i GitHub tarafında tek-seferlik materialization akışına indir.
2. XLSX `chunks` tablosundaki base64 içeriklerini indeks sırasıyla birleştir.
3. Base64 decode ile runtime ZIP'i yeniden kur.
4. ZIP byte boyutu **557.120** ve SHA256 **`d219c6233fa27f5e3e04687ec5fd15dab1f24500584e78d6a7c80036ee68f5ca`** değilse işlem FAIL; asset commit oluşturma.
5. ZIP PASS ise tam **48 WebP** bulunduğunu doğrula ve `assets/word_hunt/gokyuzu_adalari/` altına çıkar.
6. Transfer XLSX/ZIP/workflow/chunk dosyalarını final ürün tree'sinde bırakma.
7. Canonical release `3557a7e4...` tabanından tek temiz ürün commit'i oluştur: **`feat(kelime-avi): add gokyuzu runtime assets`**.
8. Exact diff yalnız 48 runtime WebP + gerekli asset QA/manifest kayıtları olmalı; ürün kodu/pubspec/Flutter entegrasyonu bu committe olmamalı.
9. Asset PR **DRAFT** aç; Ready/merge yapma.
10. Asset PR QA PASS sonrası ayrı Flutter rota entegrasyon branch/PR'ına geç.

## PR / Branch Durumu — Devir Noktası

- PR #170: **OPEN / DRAFT / mergeable=true** — docs/checkpoint PR. Head: `docs/kelime-avi-v8-final-checkpoint-20260903`.
- PR #171: **OPEN / DRAFT / mergeable=true** — Gökyüzü 8×8 içerik PR'ı. Head: `feat/kelime-avi-gokyuzu-content-20260903` @ `4ec33de...`.
- Final temiz Gökyüzü asset PR **henüz oluşturulmadı**.
- `feat/kelime-avi-gokyuzu-assets-v2-20260903` ve `tmp/gokyuzu-materialize-20260905` üzerindeki transfer denemeleri final ürün geçmişi olarak kabul edilmez.
- Canonical release hiçbir transfer denemesiyle değiştirilmedi.
- Play yükleme/yayınlama yapılmadı.

## Release Merge Zinciri — TAMAMLANDI

- PR #167 — MERGED → `c5d57e98866e244fdf36d5e7b6ad4684c5f935f4`.
- PR #163 — MERGED → `806c4bfc01f2ab9211a2684bff36f76a82e4ac8d`.
- PR #162 — MERGED → `929bb13177e03a0962464e21f6c174d4b3439349`.
- PR #161 — MERGED → `4aa490e7c2d5e7547dc95f9463dbbb9adeb85e5a`.
- PR #158 — MERGED → `189864c92a605e7bb960460300714049c730ea39`.
- PR #169 — MERGED → `0c84aefd8a5ef591aaaab9eaa30bed2e044190cf`.
- PR #168 — DOCS-ONLY MERGED → `3557a7e4f2f2917d61ba61866c6d4c8561994667`.
- PR #166 tarihsel geliştirme/QA hattıdır; merge edilmeyecektir.

## Ölçeklenebilir Üretim/Test — KALICI KARAR

- Temel üretim birimi 10 bölümlük rota/pakettir.
- Bölüm başına ayrı branch/Android Action/APK/insan testi yapılmaz.
- Her bölüm otomatik 8×8, kelime sayısı, exactly-one occurrence, yön, reverse gesture, timer/yıldız ve render kapılarından geçer.
- İnsan denge örneklemesi varsayılan B1 + B5 + B10; otomatik outlier varsa yalnız ilgili ek bölüm oynanır.
- Android16 tam runtime paket tamamlanınca, engine/ortak UI değişiminde ve release entegrasyonu öncesinde çalışır.

## WORK V2 — AKTİF

- Mikro değişiklik → tam test → rapor → bekleme döngüsü kullanılmaz.
- İlişkili işler mümkün olan en büyük mantıklı üretim bloğunda tamamlanır.
- Çözülebilen hata/fixture/test sorunları kullanıcıyı test operatörü yapmadan giderilir ve yeniden doğrulanır.
- Kullanıcı ürün yönü, gerçek görsel/fiziksel kabul ve Ready/merge/release kararlarında devreye girer.

## Reference Font

- Runtime `fontFamily: 'serif'` kullanır.
- Repo içinde exact custom font kaynağı yoktur.
- `REFERENCE_FONT = DOĞRULANACAK / DEFERRED`; spekülatif font değişikliği yapılmaz.

## Korunan Alanlar

- `assets/questions.json` kontrolsüz değiştirilmez.
- BoardMap / 67 node değiştirilmez.
- Canonical 8×8 / 64 hücre sözleşmesi korunur.
- Firebase / AdMob / release signing değişiklikleri ayrı scope gerektirir.
- package name / version değiştirilmez.
- Gökyüzü statik mock onayı raw Android PASS sayılmaz.
- Asset transfer kolaylığı uğruna gameplay veya görsel sözleşme değiştirilmez.

## Kalan Aktif Sıra — YENİ SOHBET BURADAN DEVAM ETSİN

1. Her görev başında canonical release branch, `pubspec.yaml`, son commit ve açık PR/CI durumunu canlı doğrula.
2. Başlangıç Limanı release/görsel/gameplay kabul kapılarını yeni belirti yoksa yeniden açma.
3. Gökyüzü tema + C görsel yön + 10 bölüm rota + modüler mimari + rota mock V2 statik PASS kararlarını yeniden tartışma.
4. Firestorage paylaşımındaki `gokyuzu_transfer_chunks18_native` XLSX'i kullanarak runtime ZIP'i GitHub materialization akışında yeniden kur.
5. ZIP için zorunlu gate: **557.120 bayt + SHA256 `d219c6233fa27f5e3e04687ec5fd15dab1f24500584e78d6a7c80036ee68f5ca` + 48 WebP**.
6. PASS sonrası transfer kalıntısı olmadan canonical `3557a7e4...` tabanından tek temiz `feat(kelime-avi): add gokyuzu runtime assets` commit'i oluştur.
7. Exact asset diff/QA yap ve DRAFT asset PR aç. Ready/merge YAPMA.
8. Asset PR QA PASS sonrası ayrı Flutter rota entegrasyonu başlat; 41 core asset zorunlu, 7 island variant opsiyonel kütüphanedir.
9. PR #171 içerik paketi DRAFT kalır; Ready/merge ayrı Levent onayı gerektirir.
10. Flutter entegrasyonu sonrasında static/widget testleri + Android16 raw screenshot/crash/ANR/log kanıtı al.
11. Levent raw Android görsel kabulü olmadan Gökyüzü Adaları runtime görsel PASS verme.
12. `REFERENCE_FONT` — DOĞRULANACAK / DEFERRED.
13. Play yükleme/yayınlama — yalnız ayrı açık Levent onayıyla.

**SON DURUM: 8×8 LOCKED / BAŞLANGIÇ LİMANI RELEASE PASS / GÖKYÜZÜ ADALARI TEMA+KONSEPT+ROTA+MODÜLER MİMARİ LOCKED / ROTA MOCK V2 STATİK GÖRSEL PASS / GÖKYÜZÜ 10 BÖLÜM-80 KELİME İÇERİK PR #171 DRAFT / 48 RUNTIME WEBP QA HAZIR / FIRESTORAGE TRANSFER HATTI ÇALIŞIYOR / FİNAL TEMİZ ASSET COMMIT+PR HENÜZ YOK / FLUTTER-APK ENTEGRASYONU YOK / CANONICAL RELEASE `3557a7e4...` / WORK V2 AKTİF / PLAY YAYINI YOK.**

## Kelime Avı V9 — Gökyüzü Adaları Asset Intake Checkpoint — 5 Eylül 2026

- Canonical release: `release/final-closed-test-aab-1.68.8` @ `3557a7e4f2f2917d61ba61866c6d4c8561994667`; sürüm `1.68.19+109`.
- Başlangıç Limanı release/gameplay/görsel/navigasyon PASS; yeni belirti yok, yeniden açılmadı.
- İçerik PR #171: OPEN / DRAFT; exact HEAD `4ec33de7438fcbd15ed63b1ae2adda127da3be8c`; Ready/merge yapılmadı.
- Firestorage file id `01a06e6342ff774994dd33280571724e`: 42 chunk index `0..41`, 42/42 expected Git blob SHA ve strict base64 decode PASS.
- Rebuilt ZIP: 557120 bayt PASS; SHA256 `d219c6233fa27f5e3e04687ec5fd15dab1f24500584e78d6a7c80036ee68f5ca` PASS; ZIP integrity PASS.
- Runtime asset QA: 48/48 WebP PASS; 41 core + 7 optional island variant PASS; 48/48 decode/alpha PASS. Bu raw Android görsel PASS değildir.
- Materialization run `33923955868`, job `101188228034`: SUCCESS.
- Asset branch `feat/kelime-avi-gokyuzu-runtime-assets`; tek temiz commit `8508e6bfe03d0772cf2bd371d9d3ea4b4177b7fb` (`feat(kelime-avi): add gokyuzu runtime assets`); parent exact canonical `3557a7e4f2f2917d61ba61866c6d4c8561994667`.
- Exact compare: ahead_by=1, behind_by=0, total_commits=1; yalnız `assets/word_hunt/gokyuzu_adalari/*.webp`; 48 changed file. Final ürün tree'sinde transfer XLSX/ZIP/workflow/chunk kalıntısı yok.
- Asset PR #172: OPEN / DRAFT; base `3557a7e4...`, head `8508e6bf...`, 1 commit / 48 file; Ready/merge yapılmadı.
- Bu checkpoint sırasında #172 otomatik kontrolleri sürüyor; ASSET_PR_PASS henüz verilmedi.
- Flutter rota entegrasyonu #172 gerçek PASS sonrası ayrı branch/PR olarak BEKLİYOR.
- Android 16 raw screenshot + crash/ANR/log ve Levent gerçek cihaz görsel kabulü BEKLİYOR.
- `assets/questions.json`, BoardMap/67 node, Firebase, AdMob, signing, package/version ve Play release'e dokunulmadı. Play yalnız Levent'in ayrı açık onayıyla.

## Kelime Avı V9 — Gökyüzü Rota Entegrasyonu + Android16 Teknik Kanıtı — 5 Eylül 2026

- Canonical release değişmedi: `release/final-closed-test-aab-1.68.8` @ `3557a7e4f2f2917d61ba61866c6d4c8561994667`; sürüm `1.68.19+109`.
- Başlangıç Limanı release/gameplay/görsel/navigasyon PASS durumu korunuyor; yeniden açılmadı.
- İçerik PR #171: **OPEN / DRAFT / mergeable=true**; exact HEAD `4ec33de7438fcbd15ed63b1ae2adda127da3be8c`; Ready/merge yok.
- Asset PR #172: **OPEN / DRAFT / mergeable=true / ASSET_PR_PASS**; exact HEAD `8508e6bfe03d0772cf2bd371d9d3ea4b4177b7fb`; 48 WebP; otomatik kontroller SUCCESS; Ready/merge yok.
- Flutter rota entegrasyonu ayrı ürün branch'inde tamamlandı: `feat/kelime-avi-gokyuzu-route-integration-20260905`.
- Entegrasyon commit'i: `3abe69ac329fba76ecfeb780ecdf3bfc68da578e` — `feat(kelime-avi): integrate gokyuzu route`; parent exact asset HEAD `8508e6bf...`.
- Exact integration diff: ahead 1 / behind 0 / 1 commit; yalnız 6 dosya: Gökyüzü route screen, production entry dar route seçimi, progression bonus-bypass genellemesi, `pubspec.yaml` asset kaydı ve 2 focused test dosyası.
- Pre-commit integration gate run `33925674228`, job `101193533261`: SUCCESS; focused regresyon **39/39 PASS**; yeni analyzer error yok; `assets/questions.json`, `android/`, package/version korunuyor.
- DRAFT entegrasyon PR #173: **OPEN / DRAFT / mergeable=true**; base `feat/kelime-avi-gokyuzu-runtime-assets`, exact head `3abe69ac...`; Ready/merge yok.
- Gökyüzü progression LOCKED davranışı testle korunuyor: node 7 sonrası bonus 8 + normal 9 birlikte açılır; node 10, 9 tamamlanmadan locked kalır; Başlangıç Limanı regresyonu PASS.
- Android16 source capture run `33928436133`, job `101201894979`: exact integration HEAD `3abe69ac...` + exact runner-only content HEAD `4ec33de...`; analyzer **No issues found**; Gökyüzü focused **6/6 PASS**; isolated debug APK build PASS; APK SHA256 `cbcb0daa63a3b96727a9e4af827c2a03ded6242b27a0021b912dcbc166a8efbb`.
- Aynı run Android API 36 emulatoru boot etti, APK'yı kurup açtı ve raw screenshot aldı. Screenshot **1080×1920**; `[GOKYUZU_ANDROID16_RUNTIME_READY]` marker mevcut; `MainActivity` resumed/focused; UI dump başlık + 10 bölüm + Pusula + Bilgi Kitabı taşıyor.
- Source capture step sonucu, kanıt dosyaları üretildikten sonra `android-emulator-runner` çok satırlı `grep \\` ifadesini ayrı `/bin/sh` çağrılarına böldüğü için false-negative `failure` oldu. Bu uygulama/runtime hatası değildir. Source artifact: `9957851560`.
- Raw artifact bağımsız validator run `33929151047`, job `101204015094`: **SUCCESS**. Exact SHA'lar, 1080×1920 PNG, resumed/focused activity, runtime marker, 10 node semantics ve `FATAL EXCEPTION` / package ANR-crash-proc-died / `A RenderFlex overflowed` / `FlutterError` yokluğu tekrar doğrulandı. Validated artifact: `9957897368`.
- Sonuç: `GOKYUZU_ANDROID16_TECHNICAL_RUNTIME` — **PASS / KAPANDI**.
- `GOKYUZU_REAL_DEVICE_VISUAL_ACCEPTANCE` — **AÇIK / LEVENT GERÇEK CİHAZ-NİHAİ GÖRSEL KABULÜ GEREKLİ**. Emulator teknik PASS, insan/fiziksel cihaz kabulünün yerine geçmez.
- #171, #172, #173 DRAFT kalır. Ready/merge/Play işlemi yapılmadı; Play yalnız Levent'in ayrı açık onayıyla.
- `assets/questions.json`, BoardMap/67 node, Firebase, AdMob, signing, package/version ve Play release korunmuştur.
- Bu blokta yeni ürün kararı alınmadı; `KARARLAR.md` değişmedi.

## Kelime Avı V9 — Gökyüzü raw runtime görsel reddi — 5 Eylül 2026

- Levent raw Android16 Gökyüzü rota ekranını açıkça **GÖRSEL FAIL / REJECTED** olarak değerlendirdi: gösterilen runtime, daha önce onaylanan Gökyüzü Adaları **Rota mock V2** hedefi değildir.
- Android16 teknik/runtime kanıtı geçerlidir ancak yalnız teknik kanıttır; görsel ürün kabulü değildir.
- PR #173 entegrasyonu **görsel olarak blokeli** kalır; Ready/merge yapılmaz.
- Bağlayıcı görsel hedef değişmedi: `C — Neşeli & Parlak`, Rota mock V2 statik kabulü ve aynı rota kabuğu/landmark kompozisyon dili korunur.
- Mevcut raw runtime; büyük beyaz üst panel, boş/cyan ağırlıklı sahne, küçültülmüş ada/landmarklar, basit şerit rota ve dağınık dekor kompozisyonu nedeniyle V2 hedefini taşımıyor; bu görünüm yeni ürün yönü olarak kabul edilmez.
- Görev sırası düzeltilmiştir: önce onaylı V2 görsel hedefiyle gerçek production kompozisyon/export eşleşmesi yeniden kurulacak; görsel karşılaştırma PASS olmadan yeni gerçek-cihaz kabul APK'sına geçilmeyecek.
- `qa/gokyuzu-real-device-apk-20260905` run `33929590990`: split APK build/test adımı PASS, Android16 isolated launch adımı FAIL; artifact upload SKIPPED. Kullanıcı görsel reddi nedeniyle bu hat ürün kabul kanıtı olarak kullanılmayacak ve QA branch canonical release'e resetlendi.
- Exact V2 mock raster dosyasının repo/File Library içinde yeniden erişilebilir kaynak yolu **DOĞRULANACAK**; belge kayıtlarındaki V2 görsel sözleşmesi korunur, tahminle yeni kompozisyon uydurulmaz.
- `assets/questions.json`, BoardMap/67 node, Firebase, AdMob, signing, package/version, canonical release ve Play korunmuştur.
- Yeni ürün kararı yok; `KARARLAR.md` değişmedi.

## Kelime Avı V9 — Gökyüzü V2 kaynak/audit checkpointi — 5 Eylül 2026

- File Library içinde onay kaydıyla eşleşen V2 referans yeniden bulundu: **`Gökyüzü Adaları: Büyülü Seviye Haritası.png`**, File Library id `file_00000000fe7c81f4aec58eee1d5c702d`, oluşturma zamanı `2026-09-03T18:47:34Z`.
- Dosya tanımı kayıtlı V2 sözleşmesiyle örtüşüyor: koyu lacivert/mor + altın üst kabuk, `KELİME AVI`, büyük `GÖKYÜZÜ ADALARI` paneli, `0 / 30`, `Bölüm: 1`, zengin yüzen ada/landmark kompozisyonu, kıvrımlı ışıklı rota, 8 bonus dalı, alt köşe pusula/kitap ve genel alt menü yok.
- Companion kaynaklar da yeniden bulundu: `Gökyüzü Adaları Rota Konseptleri.png` (C — Neşeli & Parlak) ve `Gökyüzü Adaları Renkli Asset Sheet.png`.
- #173 renderer kök görsel sapması koddan doğrulandı: beyaz/yarı saydam 218 px top chrome, beyaz Material butonları, düz gradient taban, küçük `178–205 px` scene assetleri, ayrı ada+scene üst üste bindirme, beyaz label kapsülleri ve CustomPainter ile basit 18/10 px stroked route. Bunlar V2'nin koyu süslü kabuğu, büyük landmark ölçeği ve cloud/glow rota dilini taşımıyor.
- Mevcut 48 runtime WebP teknik olarak kullanılabilir; görsel FAIL'in önemli bölümü asset bozukluğundan değil **kompozisyon/ölçek/chrome renderer kararından** kaynaklanıyor. Asset stil uygunluğu yine V2'ye karşı gözle doğrulanacak.
- Flutter'a yeni düzeltme yazılmadan önce mevcut 48 runtime assetle deterministik statik production kompozisyon proof üretildi. Lokal proof SHA256: `9b40fa2d0898c62ae26f565f0fd2f8f7acb892b3420a65aefaccaf6c2dbc6edd`. Bu dosya Android/runtime kanıtı değildir ve Levent görsel incelemesi **BEKLİYOR**.
- Önceki raw Android FAIL screenshot SHA256 `743771f97b4c60126fe624f9d4c4aec54bc4ce83b8046551c28741f83e977415` olarak korunur.
- `GOKYUZU_EXACT_V2_REFERENCE_SOURCE` artık **DOĞRULANDI**; `GOKYUZU_STATIC_PRODUCTION_COMPOSITION_ACCEPTANCE` **AÇIK / BEKLİYOR**.
- #173 DRAFT/görsel blokeli kalır. Ready/merge/Play yok. `assets/questions.json`, BoardMap/67 node, Firebase, AdMob, signing, package/version ve canonical release korunur.
- Yeni ürün kararı yok; `KARARLAR.md` değişmedi.
