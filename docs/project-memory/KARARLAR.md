<!-- GOKYUZU_R7_ANDROID16_START -->
## 5 Eylül 2026 — Gökyüzü Adaları görünür rota mimarisi / CURRENT
- Gökyüzü Adaları için önceki **modüler görünür renderer** kararı supersede edilmiştir.
- Bağlayıcı production görünür mimari: **telefon oranına hazırlanmış tek MASTER ART raster + şeffaf hitbox'lar + yalnız gerçek state farklarında minimum lokal Flutter override**.
- Onaylı V2 / `C — Neşeli & Parlak` kompozisyon dili bağlayıcı kalır; ada/landmark/rota/plaque/dekor sanatı Flutter ile ikinci kez komple çizilmez.
- Current R7 MASTER ART: `941×1672`, `510998` bayt, SHA256 `913ee19df9fcb1eba2ac6ca3a500979c960d31dd369e204d2f79064be9664b1d`; exact ürün HEAD `f35082c44e637cb7e6e3815c7d54d38a58b776df`.
- 8/9/10 alt rota bölgesindeki eski bağımsız **merkez kilit + üç yıldız** görsel işareti kaldırılmıştır ve geri getirilmez. Bu, runtime'daki node bazlı dinamik lock badge'lerden ayrıdır.
- Progression değişmez: 7 tamamlanınca 8 ve 9 birlikte açılır; 8, 9 için gate değildir; 10 yalnız 9 tamamlanınca açılır.
- Build/test başarısı görsel kabul değildir. Human visual PASS yalnız exact raw Android screenshot üzerinden Levent tarafından verilir.
<!-- GOKYUZU_R7_ANDROID16_END -->

<!-- GOKYUZU_MASTER_ART_DECISION_20260905_START -->
## 5 Eylül 2026 — Gökyüzü Adaları V2 production MASTER ART kararı
- Levent'in açık ürün onayıyla Gökyüzü Adaları rota ekranının görünür production tabanı, 3 Eylül'de onaylanan V2 görselinin **MASTER ART raster** sürümüdür.
- Flutter bu görünür sahneyi yeniden sentetik/modüler olarak çizmez; yalnız gerçek etkileşim/progression için minimum lokal overlay ve şeffaf hitbox kullanır.
- Bu karar, Gökyüzü rota ekranı için önceki “flattened MASTER ART kopyalanmaz / yalnız modüler görünür renderer” şartını **supersede eder**.
- PR #172'deki 48 modüler asset teknik olarak korunur ancak #175 MASTER ART renderer'ının dependency'si değildir; tarihsel/opsiyonel üretim varlığıdır.
- Approved V2 merkez kompozisyonu crop/germe/yeniden çizimle değiştirilmez. Tall-device uyarlaması yalnız MASTER ART dışındaki viewport alanında çözülür.
- Android visual PASS yalnız raw Android screenshot/artifact ile verilir; statik proof veya ImageGen çıktısı kanıt değildir.
<!-- GOKYUZU_MASTER_ART_DECISION_20260905_END -->

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
- Level 7 tamamlanınca 8 ve normal 9 birlikte açılır. Bonus 8, node 9 için zorunlu kapı değildir.
- Node 9 callback üretir. Node 10, node 9 tamamlanmadan locked ve callback üretmeyen durumda kalır.
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

## 8. 29 Ağustos 2026 — Başlangıç Limanı 8×8 ürün geometrisi

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
- İnsan süre-zorluk playtesti scripted QA’dan ayrı tutulur: Levent B5’i **115 sn / 2 hata** ile tamamladı; 60 sn soft challenge hedefi karşılanmadı. B10’u **109 sn / 4 hata** ile tamamladı; 120 sn soft challenge hedefi karşılandı. Overall timing sonucu **MIXED**; B5 tuning kararı ayrıca verilecektir.
- Soft challenge hard-fail değildir; yalnız bu ölçüm nedeniyle timer/gameplay otomatik değiştirilmez.
- PR #163 **Draft/Open** kalır; görsel PASS Ready veya merge onayı değildir. Merge için Levent’in ayrıca açık onay zorunludur.

---

## 12. 3 Eylül 2026 — Kelime Avı paket bazlı üretim ve risk bazlı test kararı

- Her bölüm için ayrı branch, ayrı Android 16 Action, ayrı APK ve ayrı insan testi yapılması ölçeklenebilir değildir ve terk edilmiştir.
- Temel üretim birimi **bir rota/paket = 10 bölüm**dür. Aynı paketin 10 bölümü tek içerik branch’inde topluca geliştirilir.
- Her bölüm için otomatik kapılar zorunludur: 8×8/64 hücre, hedef+bonus sayısı, her kelimenin exactly-one fiziksel occurrence taşıması, izinli yönler, intended/opposite gesture eşitliği, timer/yıldız sözleşmesi ve grid render sınırları.
- İnsan denge testi varsayılan olarak paketin temsili **B1 + B5 + B10** bölümlerinde yapılır. Otomatik zorluk/kontrat kapısı şüpheli outlier bulursa yalnız o bölüm ayrıca test edilir.
- Onaylanmış ortak gameplay görseli her içerik/grid değişikliğinde yeniden kullanıcı kabulüne açılmaz.
- Android 16 tam runtime kapısı şu durumlarda çalışır: 10 bölümlük paket tamamlandığında; engine/swipe/scoring/timer/progression/result UI veya ortak görsel sistem değiştiğinde; release entegrasyonu öncesinde.
- Yalnız kelime/grid içeriği değişen tek bölüm için otomatik içerik testleri yeterlidir; paket tamamlanmadan ayrı Android Action/APK üretilmez.
- Paket QA APK’sı tek uygulama içinde B1–B10 bölüm seçici, yeniden başlatma ve sonuç özeti sağlamalıdır; on ayrı APK üretilmez.
- Hata bulunursa bütün paket yeniden üretilmez; yalnız başarısız bölüm/dosya düzeltilir ve ilgili otomatik kapılar tekrarlanır.
- Bu hızlandırma test standardını düşürmez: riskli ürün/runtime değişiklikleri ve final release için ham Android ekranı, logcat/crash-ANR taraması, exact SHA ve artifact kanıtı korunur.

## 13. 3 Eylül 2026 — Swipe false-positive dar tolerans kararı

- Kelime olamayacak kadar kısa dokunma/sürükleme seçim veya hata sayılmaz.
- Seçim yalnız son hücresi çıkarıldığında exact target, bonus veya zaten bulunmuş kelime oluyorsa tek trailing hücre kırpılır; daha geniş yakın-kelime tahmini yapılmaz.
- Gesture boyunca ilk aktif pointer kilitlenir, diğer temaslar seçim yolunu değiştirmez.
- Yeterince uzun gerçek yanlış düz seçimlerin hata sayımı korunur; canonical path engine, scoring, timer ve yıldız eşikleri değiştirilmez.
- Düzeltme hedefli unit/widget testleriyle doğrulanır; merge yine Levent'in ayrı açık onayını gerektirir.

## 14. 3 Eylül 2026 — WORK V2 hızlı otonom üretim kararı

- Mikro değişiklik → tam test → rapor → kullanıcı bekleme döngüsü kullanılmaz; ilişkili işler mantıklı üretim bloklarında tamamlanır.
- Testler risk bazlı checkpointlerde toplanır. Açıkça çözülebilen fixture, test ve uygulama hataları kullanıcı onayı beklenmeden düzeltilip yeniden doğrulanır.
- Kullanıcı ürün yönü, gerçek görsel/fiziksel kabul ve Ready/merge/release kararlarında devreye girer; merge/release için açık onay zorunluluğu değişmez.
- Kelime Avı ilgili PR push'ları otomatik focused analyze/test/diff fast gate'inden geçer; kullanıcı workflow başlatan test operatörü olarak kullanılmaz.
- Canonical 8×8, kabul edilmiş görsel durumlar, engine/path/scoring/timer/progression ve korunan ürün alanları hız uğruna değiştirilmez.
- Ayrıntılı çalışma sözleşmesi `docs/project-memory/KELIME_AVI_WORK_V2.md` dosyasında tutulur.

## 15. 3 Eylül 2026 — Gökyüzü Adaları tema ve görsel yön kararı

- Kelime Avı ikinci 10 bölümlük rota/paket adı **Gökyüzü Adaları** olarak Levent tarafından onaylandı ve **LOCKED** kabul edilir.
- Kullanıcıya sunulan üç görsel yön arasından **Konsept C — Neşeli & Parlak** seçildi ve bağlayıcı sanat yönü olarak **LOCKED** kabul edilir.
- Atmosfer neşeli, renkli, pozitif, eğlenceli, çocuk dostu, hafif ve canlı olacaktır.
- Palet yönü: açık gök mavisi / camgöbeği / turkuaz ana zemin; yeşil yüzen adalar; sarı-turuncu sıcak vurgu; gerektiğinde pembe/mercan destek ayrıntıları; parlak beyaz bulutlar.
- Dünya öğeleri: yüzen çimenli adalar, bulut köprüleri/geçişleri, renkli balon ve hava gemileri, rüzgâr yapıları, masalsı kuleler ve sıcak-altın final sarayı hissi.
- Bu karar **görsel sanat yönü** kararıdır. Onaylanan konsept görsel final production MASTER ART, exact node geometrisi veya raw Android kullanıcı kabulü değildir.
- 10 bölümün adları, rota/node sıralaması ve exact görsel kompozisyon ayrıca ürün kararıyla kilitlenecektir.
- Başlangıç Limanı için kullanılan `MASTER ART raster + transparent hitbox + minimum local override` mimarisi Gökyüzü Adaları’na otomatik genellenmez. MASTER ART / katmanlı Flutter / modüler asset teknik yaklaşımı ayrıca seçilecektir.
- Canonical **8×8 / 64 hücre**, 10 bölüm / 30 yıldız, exactly-one occurrence, reverse gesture ve paket bazlı QA kararları korunur.
- Bu aşamada Flutter, production asset veya APK üretimine geçilmez; önce rota/bölüm yapısı ve ardından görsel teknik mimari kilitlenir.

## 16. 3 Eylül 2026 — Gökyüzü Adaları rota ve modüler asset mimarisi

- Levent aşağıdaki 10 bölüm sırasını onayladı ve **LOCKED** kabul edilir: `Rüzgâr Kapısı`, `Bulut Bahçesi`, `Kuş Geçidi`, `Gökkuşağı Köprüsü`, `Fırtına Kulesi`, `Hava Gemisi Limanı`, `Ay İskelesi`, `Gizli Ada`, `Yıldız Gözlemevi`, `Güneş Sarayı`.
- Bölüm/node 8 **Gizli Ada bonus node** olarak kalır. Bölüm 7 sonrası bonus 8 ve normal 9 birlikte erişilebilir; bonus 8, node 9 için zorunlu kapı değildir. Node 10, node 9 tamamlanmadan kilitli kalır.
- Gökyüzü Adaları görsel teknik mimarisi Levent tarafından **modüler asset yaklaşımı** olarak onaylandı ve **LOCKED** kabul edilir.
- Başlangıç Limanı gibi tek flatten edilmiş MASTER ART rota ekranı kullanılmaz. Büyük renk/gradient alanları Flutter ile çizilebilir; yüzen adalar, bulutlar, yollar, landmarklar, node/state ve dekorlar bağımsız modüler raster asset'lerdir.
- Dinamik bölüm numarası, yıldız, kilit/progression state'i veya kullanıcıya göre değişen metin asset içine bake edilmez; runtime tarafından üretilir.
- V1 üretim sözleşmesi **48 atomik asset** ve stil tutarlılığı için **5 sprite sheet** üretim birimidir. Ayrıntılı dosya listesi `docs/project-memory/GOKYUZU_ADALARI_ASSET_PLANI.md` içinde tutulur.
- Referans tasarım tuvali **1080×1920 dikey**dir. Assetler bağımsız taşınabilir ve ölçeklenebilir olmalıdır.
- WORK V2 gereği 48 ayrı görsel üretim döngüsü yapılmaz; beş toplu sheet üretilir, parçalanır, toplu QA yapılır ve yalnız başarısız parçalar yeniden üretilir.
- Flutter/production entegrasyonuna geçmeden önce 48 atomik asset ile hazırlanmış 1080×1920 statik rota mock'ı Levent'in görsel kabulüne sunulur.
- Bu karar canonical 8×8 gameplay engine/path/scoring/timer/progression sözleşmesini değiştirmez; yalnız Gökyüzü Adaları rota görsel üretim mimarisini tanımlar.

## 17. 3 Eylül 2026 — Gökyüzü Adaları rota mock V2 kullanıcı görsel kabulü

- Levent, Başlangıç Limanı ekranıyla karşılaştırarak ilk Gökyüzü Adaları mock'ındaki `Mağaza / Başarılar / Oyna / Sıralama / Rozetler` genel alt menü barının rota ekranına ait olmadığını belirtti; bu alt bar **REJECTED** ve superseded kabul edilir.
- Düzeltilmiş V2 rota mock'ı Başlangıç Limanı rota kabuğuna uyumlu olacak şekilde alt genel menüsüz, sol üst geri + sağ üst bilgi + alt köşelerde yalnız rota içi kontroller yaklaşımıyla üretildi.
- Levent düzeltilmiş V2 mock'ı 3 Eylül 2026'da açıkça **onayladı**; bu nedenle Gökyüzü Adaları statik rota görsel yönü **PASS / LOCKED** kabul edilir.
- 10 bölüm tamamen ayrı UI kullanmayacaktır. Ortak node/plaque/star/progression kabuğu korunur; bölüm farkı landmark, ada dekoru ve lokal atmosfer ile verilir.
- Bölüm görsel kimlikleri: Rüzgâr Kapısı giriş/değirmen; Bulut Bahçesi çiçek/pembe ağaç; Kuş Geçidi kuş/kemer; Gökkuşağı Köprüsü gökkuşağı; Fırtına Kulesi dramatik fırtına; Hava Gemisi Limanı hava gemisi; Ay İskelesi ay; Gizli Ada bonus/gizli ada; Yıldız Gözlemevi gözlemevi; Güneş Sarayı altın final sarayı.
- V2 kabulü **statik tasarım kabulüdür**; raw Android runtime acceptance değildir.
- V2 kabulünden sonra gerçek production asset aşaması açılır: 5 şeffaf, yazısız/etiketsiz sprite sheet → 48 atomik asset → şeffaflık/kenar/ölçek/stil QA → ardından Flutter entegrasyonu.
- Production raster assetlere bölüm numarası, yıldız durumu, kilit/progression veya değişken metin bake edilmeyeceği kararı aynen korunur.
