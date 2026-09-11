# Bilgi Rotası – Güncel Proje Durumu

**Son güncelleme:** 11 Eylül 2026

## 1. Kritik gerçek durum

- Repo: `ZMilaStudio/BilgiRotasi`
- Default branch: `main`
- **Önemli:** `main` güncel ürün tabanı olarak varsayılmayacak. Canlı geliştirme/release zinciri `release/final-closed-test-aab-1.68.8` ve ondan türeyen branch/PR'ler üzerinden ilerliyor.
- `main` HEAD: `653e176625111a7d3b2ed9d600a91ed009fd2af2` — `ci: document public Actions and storage policy`
- `main` içindeki `pubspec.yaml`: **1.68.6+96**. Bu nedenle yalnız `main` sürümüne bakarak ürünün güncel sürümünü belirleme.
- PR #179 (`1.68.20+110`) **MERGED**; merge commit `a43d85eae86eac335c7e09a832152667ba608c53`.
- PR #180 **OPEN / DRAFT / mergeable**: `feat(kelime-avi): add 200-level content production pipeline`.
- PR #180 HEAD: `618404e281bca91cdd2e9eb03761f47784690353`.
- PR #180 base: `release/final-closed-test-aab-1.68.8` / `a43d85eae86eac335c7e09a832152667ba608c53`.
- PR #180 sürümü: `1.68.20+110`; Play'e yükleme/yayınlama yok.

## 2. Son ürün/release zinciri

Kelime Avı / Gökyüzü Adaları V9 zincirinde:

- PR #175: Gökyüzü Adaları onaylı gameplay görsel yönü; Android16 + fiziksel kabul PASS; merge zincirinin parçası.
- PR #176: canonical Gökyüzü Adaları 10 bölüm / 8×8 içerik entegrasyonu; Android16 + AdMob PR doğrulaması PASS.
- PR #177: production rota selector; merge edildi.
- PR #178: V9 merged checkpoint; docs-only.
- PR #179: `1.68.20+110` release version bump; **MERGED**.
- PR #180: 20 bölümden minimum **200 hazır/doğrulanmış Kelime Avı bölümü** üretmek için deterministik batch üretim + doğrulama altyapısı; **DRAFT**, merge edilmedi.

PR #180 korunan alanları:
- `assets/questions.json`
- BoardMap / 67 node
- Firebase
- AdMob
- signing
- package/version
- Play release/yayın

PR #180'un sonraki hedefi: altyapı PASS olduktan sonra 18 yeni 10-bölümlük rota için toplu içerik üretimi; mevcut 20 + yeni 180 = minimum 200 bölüm.

## 3. AdMob durumu

AdMob geçmişte V2–V7 denemelerinde açılış çökmesine yol açtığı için güvenli teşhis yaklaşımına dönüldü. Son çalışma kuralı:

1. Gerçek Android `adb logcat` / `AndroidRuntime` hatası görülmeden neden tahmin edilmez.
2. Tam workflow, YAML, script, dosya yolları, shell davranışı ve CI logu birlikte incelenir.
3. Yalnız son kırmızı satıra tek satırlık yama yapılmaz.
4. `MobileAdsInitProvider` gibi kritik Android provider davranışları, gerçek kanıt olmadan kaldırılmaz.
5. SDK başlangıcı reklam yüklenmeden önce yapılır; uygulama açılışı gereksiz yere SDK başlangıcına kilitlenmez.
6. Test App ID ile production App ID birbirine karıştırılmaz.

**AdMob canlı entegrasyonunun hangi exact HEAD'de ve hangi son CI run'ında olduğu DOĞRULANACAK.** Eski sohbetlerdeki sürüm/branch bilgileri canlı GitHub karşısında geçersiz kabul edilir.

## 4. Kelime Avı – kilitli ürün sözleşmeleri

- Canonical gameplay grid: **8×8 / 64 hücre**.
- Başlangıç Limanı: 10 bölüm / 30 yıldız / 80 target+bonus.
- Gökyüzü Adaları: 10 bölüm / 30 yıldız / 80 target+bonus.
- Her canonical kelime için exactly-one fiziksel occurrence gate korunur.
- Reverse gesture aynı canonical kelimeyi üretir.
- Nearest-word/autocomplete yok.
- B5 ve B10 süreleri soft challenge olarak ele alınır.
- 7 tamamlanınca 8 ve 9 açılır; 8 bonus node'dur ve 9 için gate değildir; 10 yalnız 9 tamamlanınca açılır.
- Kullanıcı kabulü olmadan görsel yön değiştirilemez.
- Gökyüzü Adaları scenic gameplay görsel yönü kullanıcı tarafından PASS edilmiştir.

## 5. Soru bankası

- Önceki kanonik kayıt: **6.710 soru**.
- Türkiye özel 2.000 kolay soru paketi hazırlanmış durumda; çakışma yedekleri ve kurulum aracı bulunuyor.
- Paketin canlı `assets/questions.json` içine gerçekten merge edilip edilmediği ve güncel toplam soru sayısı bu durum dosyasından tek başına doğrulanmış değildir: **DOĞRULANACAK**.
- `assets/questions.json` kontrolsüz biçimde değiştirilmez.
- Soru düzeltmesi yapılacaksa metin + seçenekler + doğru indeks + açıklama + kategori + zorluk birlikte kontrol edilir.

## 6. 3B tahta

- Oynanışa, BoardMap'e ve **67 node** düzenine dokunulmaz.
- Önce numaralı deterministik geometri.
- Kullanıcı onayı olmadan stil/Flutter/APK aşamasına geçilmez.
- Tek Matrix4 ile bütün 2B sahne eğilmez.
- 8 rozet / 6 pozisyon eşlemesi çözülmeden ilerlenmez.

## 7. CI / GitHub çalışma standardı

- `main` güncel varsayılmaz.
- İş ayrı branch'te yapılır.
- Sıra: **test → commit → push → PR → inceleme → merge**.
- Kritik merge için Levent'in açık onayı gerekir.
- Build PASS tek başına çalışma/ürün kabulü değildir.
- Full log + workflow + diff + Git geçmişi birlikte incelenir.
- Public Actions politikası gereği gereksiz workflow/artifact üretimi azaltılır; aynı PR'daki eski koşular concurrency ile iptal edilir, ilgisiz değişikliklerde ağır Android/görsel doğrulama çalıştırılmaz.
- APK/AAB yalnız test/release ihtiyacında üretilir.
- Artifact kalıcı sürüm çıktısı olarak gerekiyorsa GitHub Release tercih edilir.

## 8. Son sohbet – CI hatası düzeltme devri

Son sohbetten alınan temel yöntem:

- Önce tam teşhis.
- Tam CI logu baştan sona okunacak.
- Mevcut workflow ve `main` birlikte incelenecek, ancak `main` güncel kabul edilmeyecek.
- YAML, script, dosya yolları, shell davranışı ve sonraki adımlar uçtan uca doğrulanacak.
- Gerçek `AndroidRuntime` / `adb logcat` kanıtı olmadan crash nedeni kesin ilan edilmeyecek.
- Eski AdMob yamaları kör biçimde tekrar uygulanmayacak.

Son sohbetin exact son CI run ID'si, failure job ID'si ve son düzeltme commit'i mevcut dosya indeksinden güvenilir biçimde çıkarılamadı: **DOĞRULANACAK**.

## 9. Şu anki açık işler

### P0
1. PR #180 batch içerik üretim hattının CI sonucunu exact HEAD `618404e...` üzerinden doğrula.
2. Minimum 200 Kelime Avı bölüm stoğu üretim gate'ini tamamla.
3. AdMob'un güncel exact production/release HEAD, workflow ve son cold-start kanıtını doğrula.

### P1
4. `assets/questions.json` güncel soru sayısını ve Türkiye 2.000 paketinin canlı merge durumunu doğrula.
5. Güncel release AAB/APK sürümünün gerçekten hangi branch/HEAD'den üretildiğini doğrula.
6. Play Console'daki mevcut production/candidate sürüm ile GitHub release zincirini eşleştir.

## 10. Korunan sınırlar

- `assets/questions.json` kontrolsüz değiştirilmez.
- BoardMap / 67 node ve mevcut oyun oynanışı korunur.
- Firebase/AdMob/signing/package/Play yapılandırması ayrı karar olmadan değiştirilmez.
- Kullanıcının yerel değişiklikleri silinmez.
- `git reset --hard` rutin çözüm değildir.
- Gizli bilgi, parola, anahtar, testçi e-postası, UID/FID/token loglanmaz.
- Bir bilgi doğrulanmamışsa **DOĞRULANACAK** yazılır; tahmin edilmez.

## 11. Devir notu

Bu dosya proje durumunun kısa kanonik özeti olarak tutulur. Daha kapsamlı 1 aylık devir talimatı `DEVRALMA_1_AYLIK_GPT.md` dosyasındadır.
