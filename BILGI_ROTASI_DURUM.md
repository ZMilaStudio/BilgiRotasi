# Bilgi Rotası – Güncel Proje Durumu

**Son güncelleme:** 11 Eylül 2026

## 1. Kritik gerçek durum

- Repo: `ZMilaStudio/BilgiRotasi`
- Default branch: `main`
- **Önemli:** `main` güncel ürün tabanı olarak varsayılmayacak. Canlı geliştirme/release zinciri `release/final-closed-test-aab-1.68.8` ve ondan türeyen branch/PR'ler üzerinden ilerliyor.
- `main` HEAD: `a5494b6f9c93b9d07ae04c45dc8360208ca5acf7` — `docs: update project status and add one-month GPT handover`.
- Canonical release branch: `release/final-closed-test-aab-1.68.8`.
- Canlı release HEAD: `d72b034a30bf32893b8a807ba4791d637880d989`.
- Release branch `pubspec.yaml`: **1.68.20+110**.
- PR #179 (`1.68.20+110`) **MERGED**; merge commit `a43d85eae86eac335c7e09a832152667ba608c53`.
- PR #180 **OPEN / DRAFT / mergeable**: `feat(kelime-avi): add 200-level content production pipeline`.
- PR #180 branch: `feat/kelime-avi-200-level-content-pipeline-20260906`.
- PR #180 HEAD: `dd99b25ccb7d437ba6d05ea5dea26356a8d99032`.
- PR #180 base: `release/final-closed-test-aab-1.68.8`; PR açılışındaki base SHA `a43d85eae86eac335c7e09a832152667ba608c53`.
- PR #180 sürümü: **1.68.20+110**.
- PR #180 Play yükleme/yayınlama yapmaz ve **Levent'in açık onayı olmadan Ready/merge yapılmaz**.

## 2. Kelime Avı / PR #180

PR #180'deki 200 bölüm üretim hattının canlı CI doğrulaması tamamlandı.

- Kök neden düzeltmesi: `dd99b25ccb7d437ba6d05ea5dea26356a8d99032` — palindrome kelimelerde ileri/geri yönün aynı fiziksel hücre yolunu iki occurrence saymaması düzeltildi.
- `Kelime Avı Content Factory` run `34610110468`: **SUCCESS**.
- 18 yeni rota × 10 bölüm = **180 yeni bölüm** üretildi/doğrulandı.
- Mevcut 20 + yeni 180 = **200/200 release-stock gate PASS**.
- Target/bonus exact-one physical occurrence gate: **PASS**.

PR #180 korunan alanları:
- `assets/questions.json`
- BoardMap / 67 node
- Firebase
- AdMob production ayarları
- signing
- package/version
- Play release/yayın

PR #180 teknik olarak yeşil olsa da **DRAFT kalır**; teknik PASS ürün/merge kabulü değildir.

## 3. AdMob / Android 16 kanıtı

PR #180 exact HEAD `dd99b25ccb7d437ba6d05ea5dea26356a8d99032` üzerinde:

- `AdMob PR doğrulaması` run `34610110384`: **SUCCESS**.
- Flutter analyze/test kapıları: **PASS**.
- Release APK build: **PASS**.
- package/manifest/signing doğrulamaları: **PASS**.
- Android 16 gerçek cold-start: **ilk denemede PASS**; ikinci denemeye ihtiyaç kalmadı.
- Final AdMob uygulama kapısı: **PASS**.
- Kanıt artifact: `BilgiRotasi-AdMob-1.68.20-110-kanitlari`.
- Artifact ID: `10267918735`.
- Artifact digest: `sha256:6a457d250981bf21f2bad01ec266a9f4af5afd51a8a5bd3885c67eef38920685`.

AdMob çalışma kuralı korunur:
1. Gerçek Android `adb logcat` / `AndroidRuntime` hatası görülmeden neden tahmin edilmez.
2. Tam workflow, YAML, script, path ve shell davranışı birlikte incelenir.
3. Yalnız son kırmızı satıra kör yama yapılmaz.
4. `MobileAdsInitProvider` gibi kritik provider davranışları kanıtsız kaldırılmaz.
5. Test App ID ile production App ID karıştırılmaz.

## 4. Kelime Avı – kilitli ürün sözleşmeleri

- Canonical gameplay grid: **8×8 / 64 hücre**.
- Başlangıç Limanı: 10 bölüm / 30 yıldız / 80 target+bonus.
- Gökyüzü Adaları: 10 bölüm / 30 yıldız / 80 target+bonus.
- Her canonical kelime için exactly-one **fiziksel** occurrence gate korunur.
- Reverse gesture aynı canonical kelimeyi üretir.
- Nearest-word/autocomplete yok.
- B5 ve B10 süreleri soft challenge olarak ele alınır.
- **İlerleme sıralıdır: 7 tamamlanınca 8 açılır; 8 tamamlanınca 9 açılır; 9 tamamlanınca 10 açılır. 8 normal bölümdür, bonus değildir.**
- Kullanıcı kabulü olmadan görsel yön değiştirilemez.
- Gökyüzü Adaları scenic gameplay görsel yönü kullanıcı tarafından PASS edilmiştir.

## 5. KRİTİK KARAR — Kelime Avı 200 bölüm harita mimarisi

**Karar tarihi: 11 Eylül 2026. Bu karar, yeni runtime bölüm entegrasyonundan önce uygulanacak mimari kapıdır.**

- Ürün yapısı **20 rota × 10 bölüm = 200 bölüm** olarak ele alınır.
- Amaç tek tek üçüncü, dördüncü veya sonraki haritaları yapmak değil; **20 rotanın tamamını taşıyabilecek tek bir yeniden kullanılabilir 10-bölümlük harita motoru** kurmaktır.
- Bölüm 1–10 düğüm geometrisi tek ve normalize edilmiş bir şablondan üretilir. Rota başına elle piksel/koordinat ayarı yapılmaz.
- Rotalar arasındaki farklar kod kopyasıyla değil **veri/config/assets/theme** katmanından gelir: rota adı, tema, renk, arka plan, dekor ve içerik.
- Rota özel Widget/Painter/layout dalı, rota özel koordinat listesi ve her yeni rota için yeniden elle hizalama **kabul edilmez**.
- Unlock/progression kuralları tek merkezde tutulur; harita görseli bu kuralları tekrar tanımlamaz.
- İlk kabul çıktısı yalnızca **yol + 1–10 numaralı düğümler + başlangıç/bitiş iskeleti** olacaktır. Dekor, ağaç, ada, efekt, karakter, animasyon ve sanat katmanı bu geometri onayından önce eklenmez.
- Aynı motor, kod/layout değişikliği olmadan **en az 3 görsel olarak farklı rota** ile kanıtlanır. Üçüncü rota için özel koordinat veya özel layout kodu gerekirse mimari **başarısız** kabul edilir ve ölçeklemeye geçilmez.
- Mevcut ilk iki 10-bölümlük rota uzun vadede aynı motora taşınmalıdır; ayrı/eski one-off harita sistemleri kalıcı mimari olarak korunmaz.
- **200 düğümlük tek sonsuz harita yapılmaz.** Kullanıcı rota seçer ve rotanın 10 bölümlük haritasına girer.
- Bu çalışma korunan **BoardMap / 67 node** oyunundan tamamen ayrıdır; BoardMap/67 node'a dokunulmaz.
- **Orman Yolu Bölüm 1 dahil yeni 180 bölüm runtime kataloğuna bu harita motorunun geometri/mimari kapısı kabul edilmeden bağlanmaz.**
- Başarı ölçütü: yeni bir rota eklemek günlerce Flutter harita/layout çalışması değil, doğrulanmış rota verisi + tema/assets ekleme işi olmalıdır.

## 6. Soru bankası

Canlı release zincirinde Türkiye özel 2.000 kolay soru paketi **merge edilmiştir**.

- Türkiye paket commit'i: `eba69f72471ee1585de9f9c165d2db90c3f7c028`.
- Türkiye paketinden sonraki başarılı kalite doğrulamasında validator: **8.710 questions validated**.
- İlgili kalite run'ı: `30860039360`.
- İlgili job: `91839799008`.
- Kritik sorun: **0**.
- Uyarı: **0**.
- Test sonucu: **213 PASS**.
- Paket sonrası `assets/questions.json` değişiklikleri düzeltme/replacement niteliğindedir; net soru sayısını değiştirmemiştir.
- Bu nedenle canonical canlı release soru bankası: **8.710 soru**.

`assets/questions.json` kontrolsüz biçimde değiştirilmez. Soru düzeltmesi yapılacaksa metin + seçenekler + doğru indeks + açıklama + kategori + zorluk birlikte kontrol edilir.

## 7. Production AAB / GitHub Release / Play ayrımı

- GitHub Release `v1.68.20+110` mevcuttur.
- Bu production AAB'nin kaynak commit'i: `a43d85eae86eac335c7e09a832152667ba608c53`.
- Bu SHA, bugünkü release HEAD `d72b034a30bf32893b8a807ba4791d637880d989` ile aynı değildir.
- Dolayısıyla mevcut `v1.68.20+110` AAB **bugünkü release HEAD'in exact build'i değildir**.
- GitHub Release akışı AAB/GitHub Release üretir; release kaydı açıkça Play Console'a otomatik yükleme yapılmadığını belirtir.
- PR #180 kararı gereği mevcut `1.68.20+110` AAB, minimum 200 Kelime Avı bölüm stoğu tamamlanmadan önce üretildiği için Play'e yeni aday olarak taşınmayacaktır.
- **Play Console'daki mevcut production/candidate sürümün gerçek durumu GitHub verisiyle tek başına doğrulanamaz: DOĞRULANACAK.**
- Play yükleme/yayınlama, build/release üretiminden ayrı bir karar ve açık onay kapısıdır.

## 8. 3B tahta

- Oynanışa, BoardMap'e ve **67 node** düzenine dokunulmaz.
- Önce numaralı deterministik geometri.
- Kullanıcı onayı olmadan stil/Flutter/APK aşamasına geçilmez.
- Tek Matrix4 ile bütün 2B sahne eğilmez.
- 8 rozet / 6 pozisyon eşlemesi çözülmeden ilerlenmez.

## 9. CI / GitHub çalışma standardı

- Canlı GitHub > durum dosyası > karar/görev kayıtları > eski sohbetler.
- `main` güncel ürün tabanı varsayılmaz.
- İş ayrı branch'te yapılır; `main`/release'e doğrudan yazılmaz.
- Sıra: **canlı durum → kararlar → görev/bitti ölçütü → branch → değişiklik → test → commit → push → PR → inceleme → açık onay → merge**.
- Kritik merge/release/Play işlemleri için Levent'in açık onayı gerekir.
- Build PASS tek başına çalışma/ürün kabulü değildir.
- Full log + workflow + diff + Git geçmişi birlikte incelenir.
- Public Actions politikası gereği gereksiz workflow/artifact üretimi azaltılır; aynı PR'daki eski koşular concurrency ile iptal edilir, ilgisiz değişikliklerde ağır Android/görsel doğrulama çalıştırılmaz.
- APK/AAB yalnız test/release ihtiyacında üretilir.
- Artifact kalıcı sürüm çıktısı olarak gerekiyorsa GitHub Release tercih edilir.

## 10. Şu anki açık işler

Tamamlanan doğrulamalar:
- [x] PR #180 exact HEAD/CI doğrulandı.
- [x] Minimum 200 Kelime Avı bölüm stoğu gate'i PASS.
- [x] AdMob exact PR HEAD + Android 16 cold-start/logcat kapısı PASS.
- [x] `assets/questions.json` canlı toplamı ve Türkiye 2.000 paket merge durumu doğrulandı: **8.710**.
- [x] Mevcut production AAB'nin kaynak SHA'sı ve GitHub Release zinciri doğrulandı.
- [x] 200 bölüm harita ölçekleme mimarisi kritik karar olarak kilitlendi.

Açık/onay gerektirenler:
- [ ] Mevcut iki Kelime Avı haritasının neden rota başına uzun manuel çalışma gerektirdiğini canlı release kodundan çıkar ve yeni motor için anti-pattern listesini oluştur.
- [ ] Tek 10-bölümlük motorun yalnız numaralı geometri iskeletini tanımla; sanat/dekor aşamasına geçme.
- [ ] Aynı motoru 3 farklı rota temasıyla özel layout/koordinat kodu olmadan kanıtla.
- [ ] Harita mimarisi kabul edilmeden Orman Yolu B1 veya diğer yeni bölümleri runtime kataloğuna bağlama.
- [ ] Play Console'daki gerçek production/candidate sürümü harici canlı kaynaktan doğrula ve GitHub release zinciriyle eşleştir.
- [ ] PR #180 için ürün/owner kabulü alınmadan Ready/merge yapma.
- [ ] Yeni Play adayı gerekiyorsa ancak PR #180 merge/onay zincirinden sonra exact HEAD'den yeniden build et; bunu ayrıca onayla.

## 11. Korunan sınırlar

- `assets/questions.json` kontrolsüz değiştirilmez.
- BoardMap / 67 node ve mevcut oyun oynanışı korunur.
- Firebase/AdMob/signing/package/Play yapılandırması ayrı karar olmadan değiştirilmez.
- Kullanıcının yerel değişiklikleri silinmez.
- `git reset --hard` rutin çözüm değildir.
- Gizli bilgi, parola, anahtar, testçi e-postası, UID/FID/token loglanmaz.
- Bir bilgi doğrulanmamışsa **DOĞRULANACAK** yazılır; tahmin edilmez.

## 12. Devir notu

Bu dosya proje durumunun kısa kanonik özeti olarak tutulur. Geçici `DEVRALMA_1_AYLIK_GPT.md` belgesi, canlı durum bağımsız doğrulandıktan ve bu dosya güncellendikten sonra ayrı branch/PR üzerinden kaldırılabilir.
