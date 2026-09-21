# Bilgi Rotası — Kesinleşen Kararlar

> Bu dosya aktif/kanonik karar özetidir. 26 Ağustos 2026 release entegrasyonu öncesindeki iki tam karar dosyası `docs/project-memory/archive/` altında birebir korunur. Burada yazılmayan eski kararlar, açıkça supersede edilmedikçe geçerliliğini korur.

---

## 0A. Kelime Avı / Başlangıç Limanı bağlayıcı görsel kararı

- Issue #109 `Photo 1.jpg`, Başlangıç Limanı rota ekranı için tek bağlayıcı görsel kaynaktır.
- **Levent açık mimari onayı:** production rota görünür tabanı MASTER ART raster olacaktır.
- Level 1–10 ile geri/bilgi/pusula/kitap davranışları şeffaf hitbox'larla gerçek callback/progression akışına bağlanır.
- MASTER ART üzerindeki rota, node, plaque, yıldız, crown, pusula, kitap ve panel sanatı ikinci kez komple Flutter katmanı olarak çizilmez.
- Yalnız runtime oyun state'i MASTER ART'tan gerçekten farklı olduğunda minimum lokal override uygulanır.
- MASTER ART içindeki demo `X/30`, yıldız ve lock state'i gerçek progression'ı temsil etmek zorunda değildir; production ekranda gerçek state lokal override ile gösterilir.
- **12 Eylül 2026 güncellemesi:** eski “Level 7 tamamlanınca 8 ve 9 birlikte açılır / bonus 8 zorunlu değildir” davranışı **SUPERSEDED / GEÇERSİZ**. Güncel kural Bölüm 15'tir: yalnız 1 açık başlar ve bölümler kesin olarak `1→2→3→4→5→6→7→8→9→10` sırasıyla açılır.
- Node 9 yalnız node 8 tamamlandıktan sonra açılır ve callback üretir. Node 10 yalnız node 9 tamamlandıktan sonra açılır; kilitliyken callback üretmez.
- Bu karar Başlangıç Limanı için önceki “tamamen layered/modüler görünür sahne” şartını **supersede eder**.
- Bu istisna diğer Kelime Avı tema/rotalarına otomatik genellenmez; her yeni rota ayrıca görsel/teknik karar ister.
- PR #146 / `c42a9ff...` ve önceki ChatGPT-generated hedef asset'ler görsel kaynak değildir.

---

## 1. Çalışma ve Git düzeni

- `main` otomatik güncel kabul edilmez; canlı hedef branch ve `pubspec.yaml` işe başlamadan doğrulanır.
- Doğrudan main/release'e rastgele yazılmaz; ayrı branch/PR kullanılır.
- Sıra: **test → commit → push → PR → inceleme → merge**.
- Kritik merge/deploy için Levent'in açık onayı gerekir.
- Build PASS tek başına çalışma kanıtı değildir; log, diff, workflow, test ve Git geçmişi birlikte incelenir.
- `assets/questions.json` kontrolsüz değiştirilmez.
- İlgisiz yerel değişiklikler silinmez; `git reset --hard` rutin çözüm değildir.
- Gizli bilgi, testçi e-postası, parola veya anahtar repoya eklenmez.
- Doğrulanmamış bilgi `DOĞRULANACAK` olarak işaretlenir.
- Uzun teknik işler kısa geri alınabilir checkpoint'lere bölünür; merge öncesi base/head/CI tekrar canlı doğrulanır.

---

## 2. Kalıcı proje hafızası

- Yeni sohbet önce `GENEL_PROJE_OZETI.md`, ardından `BILGI_ROTASI_DURUM.md`, `KARARLAR.md`, `GOREV_HAVUZU.md` ve gerektiğinde açık sorular dosyasını okur.
- `GENEL_PROJE_OZETI.md` her proje yanıtından sonra yalnız gerekli farklarla güncel tutulur.
- Özet canlı GitHub doğrulamasının yerine geçmez.
- Önemli geçmiş silinmez; eski tam kayıtlar Git geçmişi ve `docs/project-memory/archive/` altında korunur.

---

## 3. Ürün/yayın temel kararları

- Uygulama: **Bilgi Rotası**; yayıncı **ZMila Studio**.
- Paket adı: `com.leventua.bilgirotasi`.
- Yeni özellik uğruna çalışan yayın sürümü bozulmaz.
- Play yükleme/yayınlama ayrı açık karar gerektirir; teknik release merge otomatik Play yayını anlamına gelmez.
- Kişisel bilgi mağaza/tanıtım görsellerine girmez.

---

## 4. Kelime Avı ürün kararı

- Kelime Avı Bilgi Rotası içinde Flutter ile geliştirilecektir; Godot runtime bağımlılığı değildir.
- İlk rota/paket Başlangıç Limanı'dır.
- Hedef: 10 bölüm / 30 yıldız ve gerçek rota → bölüm → oyun → sonuç/yıldız → rota döngüsü.
- Production `lib/main.dart` ana navigasyon bağlantısı ayrı geliştirme branch/PR kapsamıdır.
- Başlangıç Limanı kabul edilen görünüm tamamlandıktan sonra oyun geliştirmesine devam edilecek; PR zinciri teknik borç olarak bırakılmayacaktır.

---

## 5. Oyun, reklam ve veri koruma kararları

- Yerel oyun 2–6 oyuncuyu destekler.
- Canlı Düello 10/20/30 soru; ana düello otomatik eşleştirme kullanır; oda kodu ana akış değildir.
- BoardMap ve 67 node / 3B tahta sözleşmesi kontrolsüz değiştirilmez.
- Aktif soru ekranında reklam gösterilmez; kritik oyun/canlı maç akışı reklamla kesilmez.
- Ödüllü reklam kullanıcı isteğiyle açılır; aynı tamamlanmış oyun ikinci ödülü vermez.
- Soru kalitesi sayıdan önce gelir; soru + 4 seçenek + doğru indeks + açıklama + kategori + zorluk birlikte doğrulanır.
- Analytics varsayılan kapalı/açık opt-in ilkesini ve kişisel kimlik göndermeme kararını korur.
- FCM bildirimleri açık kullanıcı opt-in'i olmadan başlatılmaz; production bildirim gönderimi ayrıca karar gerektirir.

---

## 6. Release/CI korunacak kararlar

- Android 16 emülatör altyapı arızası ile gerçek uygulama crash/ANR/FATAL/process-death ayrı sınıflandırılır.
- Uygulama hatası infrastructure retry ile PASS'e çevrilmez.
- Canonical release branch'in mevcut artifact-retention politikaları korunur.
- Android release binary'lerinin GitHub Releases üzerinden üretilmesine yönelik mevcut release workflow'ları korunur.
- Kelime Avı release entegrasyonu mevcut AdMob/Firebase/Android release yapılandırmasını değiştirmez.
- `ZMilaStudio/BilgiRotasi` public repo olduğu sürece standart GitHub-hosted Actions dakika kotası proje için kısıt/fren olarak kullanılmaz. Buna rağmen gereksiz workflow döngüsü yapılmaz; artifact/cache storage kotası ayrı izlenir ve larger/paid runner kullanımı ayrıca onay gerektirir.

---

## 7. 26 Ağustos 2026 Başlangıç Limanı kabul/merge durumu

- MASTER ART görsel kullanıcı kabulü: **PASS**.
- MASTER ART raster + transparent hitbox mimari kabulü: **PASS**.
- Dynamic progression görsel/interaction senkronu: **PASS**.
- Final Android 16 production + pixel-proof: **PASS**.
- PR #132 merge: tamamlandı (`60991051a255608bc631b1341001748aa1a754b8`).
- PR #110 merge: tamamlandı (`33a08e589f00928306f759fc4f20738991323896`).
- PR #107 merge: tamamlandı (`ef34a1858d1a16da829a77c125d4953f7336b06d`).
- Eski PR #96 branch'i güncel release ile diverged olduğu için zorla merge edilmez; current release tabanından temiz entegrasyon yapılır.
- Release'e geçmeden exact release-context CI ve Android 16 kanıtı zorunludur.

---

## 8. 29 Ağustos 2026 Başlangıç Limanı 8×8 ürün geometrisi

- Levent'in yeni ürün kararıyla Başlangıç Limanı bölüm grid standardı **8 satır × 8 sütun**dur.
- Önceki 6×10 starter-content geometrisi bu yeni çalışma için **superseded** edilmiştir; 6×10 geçmiş teknik checkpoint ve kanıtları silinmez.
- 10 bölüm / 30 yıldız / 80 toplam target+bonus kelime eğrisi korunur.
- Her target/bonus 8 düz yönde **exactly one physical occurrence** taşımalıdır.
- Intended ve opposite gesture aynı canonical kelimeye dönmelidir.
- İlk bölümlerde yatay/dikey yollar baskın olabilir; ilerleyen bölümlerde çapraz/ters yön çeşitliliği artırılır.
- B5 ve B10 yatay + dikey + çapraz yön ailelerini birlikte taşımalıdır.
- B8 iki bonus (`HIZ`, `SKOR`), B9 `ROKET` bonusu ve B10 `YOL` hedefi / `HAZİNE` bonusu korunur; `AY` ve `ROTA` geri dönmez.
- Süreler hard-fail değildir; B5 60 saniye, B10 120 saniye soft challenge sözleşmesi korunur.
- 8×8 dönüşümü `lib/main.dart`, `assets/questions.json`, MASTER ART, AdMob/Firebase, signing veya BoardMap/67 node kapsamını açmaz.
- 8×8 için Flutter analyze/test ve Android 16 kanıtı olmadan PR Ready/merge yapılmaz.
- QA-only entrypoint/araçlar ürün commitine girmeyecek; ürün scope'u açık allowlist ile sınırlandırılacaktır.

---

## 9. 31 Ağustos 2026 — Başlangıç Limanı gameplay exact-reference görsel mimarisi / DÜZELTİLMİŞ KARAR

Kelime Avı / Başlangıç Limanı gameplay ekranında bağlayıcı görsel kaynak gece limanı, lacivert-altın premium referanstır. Önceki “background-only + Flutter ile chrome yeniden çizimi” yaklaşımı, kullanıcı exact-reference talebi nedeniyle bu karar tarafından **supersede** edilmiştir.

- Canonical gameplay geometrisi **8×8 / LOCKED** kalır; hiçbir raster asset grid geometrisi bake etmez.
- Referansın 6×10 düzeni yalnız görsel kaynak geçmişidir ve product geometry olarak kullanılamaz.
- Flattened referans screenshot bütün ekran olarak production'a gömülmez.
- Production mimarisi: **approved raster reference asset pack + dinamik Flutter text/state + canonical 8×8 engine**.
- Kullanıcı tarafından görsel QA ile kilitlenen 11 production asset dışında yeni chrome/ikon/hücre tasarımı eklenmez:
  - `harbor_background_1080x1920.png`
  - `cell_idle.png`
  - `cell_selected_found.png`
  - `status_panel_empty.png`
  - `word_plaque_empty.png`
  - `bonus_plaque_empty.png`
  - `instruction_panel_empty.png`
  - `icon_back.png`
  - `icon_search.png`
  - `icon_mistake.png`
  - `icon_timer.png`
- `icon_anchor.png` ve `icon_compass.png` production overlay değildir; instruction panel asset'i içinde dekor bake olduğu için **UNUSED / REJECTED** kalır.
- Dinamik içerik (başlık, sayaç, süre, target/bonus metni, hücre harfleri, found/error state) Flutter/runtime tarafından üretilir; asset içine kelime/grid bake edilmez.
- Gameplay engine, swipe, timer, hata, bonus, scoring ve progression sözleşmeleri görsel tema uğruna değiştirilmez.
- **Bağlayıcı runtime hedefi**, kullanıcının 31 Ağustos'taki son mesajında **Görsel 1** olarak işaretlediği ekrandır. Bu görsel hedef/reference'tır; gerçek Android kanıtı değildir.
- Kullanıcının son mesajındaki **Görsel 2**, gerçek Android runtime found-state çıktısıdır ve **FAIL** olarak reddedilmiştir.
- Görsel 1 veya başka herhangi bir image-edit / ImageGen / mockup çıktısı **gerçek Android screenshot diye sunulamaz ve Android visual PASS kanıtı sayılamaz**.
- Görsel PASS yalnız raw Android artifact/screenshot üzerinden verilir. Runtime ekranının bağlayıcı Görsel 1 hedefiyle yerleşim, ölçek, panel/plaque ölçüleri, grid aralıkları, found-state ve alt panel sunumu açısından kabul edilebilir biçimde eşleşmesi gerekir.
- Exact product SHA `50ab6c8da3a4d6683568c71d52f893c5dfe2e9f7` için initial Android 16 run `33384781507` teknik olarak screenshot üretmiştir; found-state artifact `9756762383` gerçek gesture/state üretmiştir. **Ancak bu gerçek runtime görünümü kullanıcı tarafından görsel olarak FAIL edilmiştir.**
- Daha önce image-edit hedef üzerinden alınan “PASS” yanlış kanıt sunumuna dayandığı için **GEÇERSİZDİR / GERİ ÇEKİLMİŞTİR**.
- Önceki `67f7365...` refined-V5 kabul kaydı da current karar değildir.

`ERROR_STATE_VISUAL` ve exact `REFERENCE_FONT` kaynağı referansta bağımsız olarak doğrulanamadığı sürece **DOĞRULANACAK** kalır. Mevcut runtime sırf teknik testler geçti diye görsel PASS sayılmaz.

---

## 10. 1 Eylül 2026 — V6 raw Android edge-fuse found-state kullanıcı kabulü

- Kullanıcı kabulü yalnız **ham Android runtime** ekranından alınır; QA selector, ImageGen, image-edit veya mockup hiçbir zaman acceptance kanıtı değildir.
- Raw Android sonuçları kullanıcıya her zaman gösterilir.
- Kabul edilen V6 found-state biçimi: found hücrelerin kendi kutu/formu korunur; yalnız ardışık found hücrelerin görünür kenar boşluğu sıcak altın/turuncu dolu birleşimle kapanır. Merkezden merkeze uzun bar veya ayrı kapsül görünümü kullanılmaz.
- Exact Android-tested edge-fuse commit: `4dddf00178ef9f14b8edb3fc706114be72f477a4`.
- Exact tested `word_hunt_screens.dart` blob: `f43deaad5328f6263f9479de1738cc1f4ac465e0`.
- Android 16 run `33486609120`: **SUCCESS**; API 36 / 1080×1920 / 420 dpi; analyze PASS; focused Kelime Avı **138/138 PASS**; gerçek YOL `0/9 → 1/9`; `YOL_SEMANTIC_VISUAL_GATE=PASS`; `YOL_EDGE_FUSE_PIXEL_GATE=PASS`.
- Artifact `9792346079`, digest `sha256:f5a1592ce074a6e0a8f3bc1f7c88baf5bd9ec9b6bf5337327d7368aea83046d8`.
- Levent, aynı artifact’tan gösterilen raw B10 initial ve raw `YOL / 1/9` edge-fuse ekranlarını **PASS** olarak kabul etti.
- Temiz ürün branch `fix/kelime-avi-v6-found-path-connector-product-20260901`; ürün commit `217beb83c31976436a6f26ec43ae4e35a0c7f05c` aynı exact `f43deaad...` blob’u taşır.
- Draft PR #163 kullanıcı görsel PASS aldı fakat **Ready veya merge otomatik değildir**.
- Merge için Levent’in ayrıca açık merge onayı zorunludur.

---

## 11. 2 Eylül 2026 — V6 error + completion + kompakt sonuç popup kabulü

Bu bölüm, 31 Ağustos kayıtlarındaki `ERROR_STATE_VISUAL = DOĞRULANACAK` durumunu güncel kabul kararıyla supersede eder. `REFERENCE_FONT` kaynak yetersizliği nedeniyle ayrı olarak açık/deferred kalır.

- Error-state kullanıcı görsel kabulü **PASS**: fill `0xB35A1F2B`, border `0xFFFF6B57`; 280 ms geri bildirim değişmedi; Android 16 run `33524578623` SUCCESS.
- Completion davranış sözleşmesi: ana hedefler tamam fakat bonus eksikse otomatik sonuç popup’ı açılmaz; oyuncu bonusu aramaya devam edebilir ve manuel `Bölümü Tamamla` yolu korunur. Tüm target+bonus tamamlandığında popup otomatik açılır. Yeni/fresh bölüm oturumunda completion popup yeniden tetiklenebilir.
- Completion UI standart Material/mavi dialog değildir; Başlangıç Limanı lacivert/bronze/altın görsel diline ait premium sonuç panelidir.
- Kullanıcı, büyük ilk tasarımı beğendi ancak kaba/büyük buldu; popup yaklaşık %20 kompaktlaştırıldı. Kabul edilen compact parametreler: `maxWidth: 300`, padding `18/15/18/15`, result button height `44`.
- Exact compact tested product commit: `7fa81663cb93c3f9f43b5c1bb7cd8f4d11929fd8`.
- Exact compact tested `word_hunt_screens.dart` blob: `6ce2830a7df8eb696a9df589c91c544df7712969`.
- Static/productize run `33629855060`: SUCCESS; analyze + Word Hunt **139/139 PASS**.
- Final clean Android 16 compact run `33655562508`: **SUCCESS**. B5 target-only no-dialog, B5 all-words auto-dialog, B5 fresh replay auto-dialog, B10 target-only no-dialog, B10 all-words auto-dialog ve process failure scan PASS.
- Raw Android B5/B10 kompakt popup ekranları Levent’e gösterildi ve **PASS** verildi.
- Exact tested compact blob PR #163 ürün branch’ine QA-only dosya taşınmadan productize edildi: commit `9a6fede2c4aed4fdbaa6c9ba427fa84e0ce418da`; branch `fix/kelime-avi-v6-found-path-connector-product-20260901`; blob exact `6ce2830...`.
- İnsan süre-zorluk playtesti scripted QA’dan ayrı tutulur: Levent B5’i **115 sn / 2 hata** ile tamamladı; 60 sn soft challenge hedefi karşılanmadı. B10'u **109 sn / 4 hata** ile tamamladı; 120 sn soft challenge hedefi karşılandı. Overall timing sonucu **MIXED**; B5 tuning kararı ayrıca verilecektir.
- Soft challenge hard-fail değildir; yalnız bu ölçüm nedeniyle timer/gameplay otomatik değiştirilmez.
- PR #163 **Draft/Open** kalır; görsel PASS Ready veya merge onayı değildir. Merge için Levent’in ayrıca açık onayı zorunludur.

---

## 12. 3 Eylül 2026 — Kelime Avı paket bazlı üretim ve risk bazlı test kararı

- Her bölüm için ayrı branch, ayrı Android 16 Action, ayrı APK ve ayrı insan testi yapılması ölçeklenebilir değildir ve terk edilmiştir.
- Temel üretim birimi **bir rota/paket = 10 bölüm**dür. Aynı paketin 10 bölümü tek içerik branch'inde topluca geliştirilir.
- Her bölüm için otomatik kapılar zorunludur: 8×8/64 hücre, hedef+bonus sayısı, her kelimenin exactly-one fiziksel occurrence taşıması, izinli yönler, intended/opposite gesture eşitliği, timer/yıldız sözleşmesi ve grid render sınırları.
- İnsan denge testi varsayılan olarak paketin temsili **B1 + B5 + B10** bölümlerinde yapılır. Otomatik zorluk/kontrat kapısı şüpheli outlier bulursa yalnız o bölüm ayrıca test edilir.
- Onaylanmış ortak gameplay görseli her içerik/grid değişikliğinde yeniden kullanıcı kabulüne açılmaz.
- Android 16 tam runtime kapısı şu durumlarda çalışır: 10 bölümlük paket tamamlandığında; engine/swipe/scoring/timer/progression/result UI veya ortak görsel sistem değiştiğinde; release entegrasyonu öncesinde.
- Yalnız kelime/grid içeriği değişen tek bölüm için otomatik içerik testleri yeterlidir; paket tamamlanmadan ayrı Android Action/APK üretilmez.
- Paket QA APK'sı tek uygulama içinde B1–B10 bölüm seçici, yeniden başlatma ve sonuç özeti sağlamalıdır; on ayrı APK üretilmez.
- Hata bulunursa bütün paket yeniden üretilmez; yalnız başarısız bölüm/dosya düzeltilir ve ilgili otomatik kapılar tekrarlanır.
- Bu hızlandırma test standardını düşürmez: riskli ürün/runtime değişiklikleri ve final release için ham Android ekranı, logcat/crash-ANR taraması, exact SHA ve artifact kanıtı korunur.

## 13. 3 Eylül 2026 — Swipe false-positive dar tolerans kararı

- Kelime olamayacak kadar kısa dokunma/sürükleme seçim veya hata sayılmaz.
- Seçim yalnız son hücresi çıkarıldığında exact target, bonus veya zaten bulunmuş kelime oluyorsa tek trailing hücre kırpılır; daha geniş yakın-kelime tahmini yapılmaz.
- Gesture boyunca ilk aktif pointer kilitlenir, diğer temaslar seçim yolunu değiştirmez.
- Yeterince uzun gerçek yanlış düz seçimlerin hata sayımı korunur; canonical path engine, scoring, timer ve yıldız eşikleri değiştirilmez.
- Düzeltme hedefli unit/widget testleriyle doğrulanır; merge yine Levent’in ayrı açık onayını gerektirir.

## 14. 3 Eylül 2026 — WORK V2 hızlı otonom üretim kararı

- Mikro değişiklik → tam test → rapor → kullanıcı bekleme döngüsü kullanılmaz; ilişkili işler mantıklı üretim bloklarında tamamlanır.
- Testler risk bazlı checkpointlerde toplanır. Açıkça çözülebilen fixture, test ve uygulama hataları kullanıcı onayı beklenmeden düzeltilip yeniden doğrulanır.
- Kullanıcı ürün yönü, gerçek görsel/fiziksel kabul ve Ready/merge/release kararlarında devreye girer; merge/release için açık onay zorunluluğu değişmez.
- Kelime Avı ilgili PR push'ları otomatik focused analyze/test/diff fast gate'inden geçer; kullanıcı workflow başlatan test operatörü olarak kullanılmaz.
- Canonical 8×8, kabul edilmiş görsel durumlar, engine/path/scoring/timer/progression ve korunan ürün alanları hız uğruna değiştirilmez.
- Ayrıntılı çalışma sözleşmesi `docs/project-memory/KELIME_AVI_WORK_V2.md` dosyasında tutulur.

## 15. 12 Eylül 2026 — bütün 10-bölümlük rotalarda kesin sıralı kilit

- Yeni/boş progress durumunda yalnız Bölüm 1 açık/current başlar; Bölüm 2–10 locked olur.
- Bölümler yalnız bir önceki tamamlanınca açılır: `1→2→3→4→5→6→7→8→9→10`.
- Bir bölüm tamamlandığında yalnız bir sonraki bölüm açılır; iki ileri bölüm aynı anda açılmaz.
- Bölüm 8 normal bölümdür ve Bölüm 9 için zorunlu kapıdır.
- Bu kural tema/route fark etmeksizin ortak `WordHuntRouteProgressEngine` sözleşmesidir.
- Locked node callback üretmez; Android proof da fresh progress ile 1 açık / 2–10 locked göstermelidir.
- Görsel skin veya raster artwork bu progression kuralını değiştiremez.
- Eski “7 tamamlanınca 8 ve 9 birlikte açılır” kararı geçersizdir.

## 16. 12 Eylül 2026 — raster artwork kalite katmanı

- Final raster artwork kullanıldığında proof amaçlı procedural ağaç/mantar/dekor katmanı varsayılan olarak **çizilmez**.
- Raster artwork aktifken procedural atmosfer glow/depth kapatılır; sahnenin kendi ışığı ve derinliği korunur.
- Artwork kadrajı yalnız tema verisiyle ölçek/hizalama alabilir; canonical 10-node geometri ve 86×82 hitbox değişmez.
- Canlı path/node/kilit/yıldız/progression katmanı artwork üzerinde runtime state olarak kalır.
- Orman Yolu Android görsel proof'u artık `WordHuntRouteVisualThemes.ormanYolu` production skin verisini render eder; `forest-proof` production kabul kaynağı değildir.

---

## 17. 21 Eylül 2026 — Kelime Avı 2.0 Wave10A staged Başlangıç Limanı closure kararı

- Wave10A kapsamı yalnız Başlangıç Limanı **L11–20** entegrasyonudur ve implementation + validation tamamlanmıştır.
- Implementation green HEAD: `f6e8464540faeb78e3ff3306b0970335ecc4873a`.
- PR #213 **Open / Draft / Unmerged** kalır; closure Ready/merge/release onayı değildir.
- Başlangıç Limanı **20 available / 100 planned** olarak modellenir.
- Segment1 = L1–10; Segment2 = L11–20.
- L10 yalnız Segment1 endpoint'tir.
- L20 current content frontier'dır; **true route final değildir**.
- L20 route reward, fake route completion, Gökyüzü false unlock veya nonexistent L21 navigation üretemez.
- Internal progression route-local 1–100 kalır.
- Global 1–800 numbering yalnız player-facing display projection'dır ve persist edilmez.
- Persistence/progression/segment/milestone/route-final semantics local index authority kullanır.
- Schema v3 ve `bilgi_rotasi_word_hunt_progress_v1_` storage prefix korunur.
- Old v3 progress korunur.
- Historical Başlangıç Segment1 access/reward semantics frozen legacy L1–10 authority üzerinden değerlendirilir; current L11–20 historical completion'a dahil edilmez.
- Locked production L11–20 evidence korunur; Segment1 L1–10 unchanged kalır.
- Exact implementation validation seti:
- Cumulative Validation #168 — Run ID `35646621194` — **SUCCESS**
- Content Factory #43 — Run ID `35646621195` — **SUCCESS**
- Route Catalog #264 — Run ID `35646621246` — **SUCCESS**
- Android Visual #648 — Run ID `35646621185` — **SUCCESS**
- Trilogy Runtime #157 — Run ID `35646621192` — **SUCCESS**
- Orman Content #54 — Run ID `35646621186` — **SUCCESS**
- Orman/Kadim #224 — Run ID `35646621268` — **SUCCESS**
- AdMob #1025 — Run ID `35646621209` — **SUCCESS**
- Wave10B bu closure ile başlamaz. Başlangıç L21+ veya başka rota L11+ ayrı owner/manager checkpoint gerektirir.
- No artwork/version/tag/release/Play/merge action bu karara dahil değildir.

