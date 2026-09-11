# Bilgi Rotası — 1 Aylık GPT Devir Dosyası

**Devir amacı:** Levent bu projeyi yaklaşık 1 ay boyunca Emel'e devrediyor. Bu dosya, Emel'in ChatGPT'sinin Bilgi Rotası'nı başka bir sohbetten mümkün olduğunca kayıpsız devralması için hazırlanmıştır.

> **ÖNEMLİ:** Bu dosya geçici devir belgesidir. Emel'in ChatGPT'si dosyayı tamamen okuduktan ve canlı GitHub durumunu doğruladıktan sonra bu dosyayı silebilir. Silmeden önce `BILGI_ROTASI_DURUM.md` güncel tutulmalıdır.

---

## 1. İLK KURAL — ESKİ SOHBETTEN DEĞİL, CANLI GITHUB'DAN DEVİR AL

İşe başlamadan önce mutlaka:

1. `BILGI_ROTASI_DURUM.md` oku.
2. `KARARLAR.md` varsa ilgili kararları oku. Dosya bulunamazsa **DOĞRULANACAK** olarak bırak; uydurma.
3. `GOREV_HAVUZU.md` varsa aktif görevi ve bitti ölçütünü oku. Dosya bulunamazsa **DOĞRULANACAK**.
4. `ACIK_SORULAR_VE_DOGRULAMALAR.md` varsa açık doğrulamaları oku.
5. GitHub'da canlı branch, PR, HEAD ve CI durumunu kontrol et.
6. `main` dalını güncel ürün tabanı kabul etme.
7. Eski sohbetlerdeki branch/SHA/sürüm bilgilerini canlı GitHub ile karşılaştırmadan doğru kabul etme.
8. `pubspec.yaml` sürümünü exact HEAD üzerinden kontrol et.
9. Son commit'i ve ilgili PR'ı exact SHA ile doğrula.

**Canlı teknik kaynak = GitHub deposu ve ilgili canlı servisler. Eski sohbet = yalnız tarihçe/bağlam.**

---

## 2. REPO KİMLİĞİ

- GitHub repo: `ZMilaStudio/BilgiRotasi`
- Default branch: `main`
- Android paket adı: `com.leventua.bilgirotasi`
- Framework: Flutter / Dart
- Hedef: Android
- Uygulama: Bilgi yarışması + oyunlaştırılmış bilgi deneyimi + Kelime Avı yan oyunu
- Google Play durumu: Bilgi Rotası production'da yayınlanmış projedir; Play kapalı testteymiş gibi davranma.

---

## 3. CANLI GITHUB'DA 11 EYLÜL 2026 İTİBARIYLA DOĞRULANAN TABLO

### `main`

- `main` HEAD: `653e176625111a7d3b2ed9d600a91ed009fd2af2`
- Commit: `ci: document public Actions and storage policy`
- `main/pubspec.yaml`: **1.68.6+96**

Bu sürüm, ürünün güncel çalışma/release sürümü olarak kullanılmamalıdır; `main` geriden gelmektedir.

### Canonical release zinciri

- PR #179: `1.68.20+110` version bump
- PR #179: **MERGED**
- merge commit: `a43d85eae86eac335c7e09a832152667ba608c53`
- PR #179 head: `ad186ab00c96b840fae4edbf76fde236ecce457f`

### Şu an açık PR

**PR #180 — `feat(kelime-avi): add 200-level content production pipeline`**

- durum: **OPEN / DRAFT / mergeable**
- branch: `feat/kelime-avi-200-level-content-pipeline-20260906`
- HEAD: `618404e281bca91cdd2e9eb03761f47784690353`
- base: `release/final-closed-test-aab-1.68.8`
- base SHA: `a43d85eae86eac335c7e09a832152667ba608c53`
- sürüm: `1.68.20+110`
- kapsam: Kelime Avı için 20 bölümden minimum 200 hazır/doğrulanmış bölüme ölçekleme altyapısı
- Play yükleme/yayınlama: **YOK**
- merge: **YOK**

PR #180'in koruduğu alanlar:
- `assets/questions.json`
- BoardMap / 67 node
- Firebase
- AdMob
- signing
- package/version
- Play release/yayın

PR #180'un hedefi:
- deterministic batch generator
- canonical 8×8 grid
- yatay/dikey/çapraz + ters yön
- deterministic seed
- target/bonus validation
- exactly-one physical occurrence gate
- 200 bölüm release-stock gate
- 18 yeni 10-bölümlük rota için sonraki toplu üretim

**PR #180 DRAFT kalır. Levent'in açık merge onayı olmadan Ready/merge yapılmaz.**

---

## 4. KELİME AVI KİLİTLİ ÜRÜN KURALLARI

- Canonical gameplay: **8×8 / 64 hücre**.
- Başlangıç Limanı: 10 bölüm / 30 yıldız / 80 target+bonus.
- Gökyüzü Adaları: 10 bölüm / 30 yıldız / 80 target+bonus.
- Her canonical kelimede exactly-one fiziksel occurrence.
- Reverse gesture aynı canonical kelimeyi üretir.
- Nearest-word/autocomplete yok.
- B5 ve B10 süreleri soft challenge.
- 7 tamamlanınca 8 ve 9 açılır.
- 8 bonus node'dur; 9 için gate değildir.
- 10 yalnız 9 tamamlanınca açılır.
- Kullanıcı görsel/oynanış kabulü olmadan görsel yön değişmez.
- Gökyüzü Adaları scenic gameplay yönü kullanıcı tarafından kabul edilmiştir.

**3B TAHTA / MEVCUT BİLGİ OYUNU:** BoardMap, 67 node ve mevcut oynanışa Kelime Avı işi için dokunma.

---

## 5. ADMOB — EN ÖNEMLİ TEKNİK GEÇMİŞ

AdMob daha önce V2–V7 denemelerinde açılış çökmesi problemine yol açtı. Bu nedenle çalışma yöntemi değiştirildi.

Son güvenli yaklaşım:

1. Gerçek Android `adb logcat` / `AndroidRuntime` hatası görülmeden crash nedeni kesin ilan edilmez.
2. Tam CI logu baştan sona okunur.
3. Workflow YAML, script, dosya yolları ve shell davranışı birlikte incelenir.
4. Sadece son kırmızı satıra kör yama yapılmaz.
5. `MobileAdsInitProvider` gibi kritik provider davranışları kanıtsız kaldırılmaz.
6. `MobileAds.instance.initialize()` reklam istenmeden önce başlatılır.
7. SDK başlangıcı uygulamanın ilk karesini gereksiz yere kilitlememelidir.
8. Test App ID ve production App ID karıştırılmaz.

Eski dosya/sohbet notlarında V7 provider kaldırma yaklaşımının şüpheli olduğu özellikle kaydedilmiştir.

**Güncel exact AdMob HEAD/CI kanıtı, bu devir belgesi hazırlanırken canlı repo ile ayrıca doğrulanmalıdır.** Eski sohbetlerdeki AdMob sürümünü otomatik kullanma.

---

## 6. SON "CI HATASINI DÜZELTME" SOHBETİNDEN DEVRALINAN ÇALIŞMA YÖNTEMİ

Son sohbetten güvenilir biçimde çıkarılan ana ders şudur:

> **Önce tam teşhis, sonra tek ve kapsamlı düzeltme.**

Yani:

- Tam logu baştan sona oku.
- Mevcut workflow'u ve hedef branch'i birlikte incele.
- `main` güncel varsayma.
- YAML + script + path + shell + sonraki adımları uçtan uca kontrol et.
- Gerçek log kanıtı olmadan "kesin sebep" deme.
- Build PASS sonucunu tek başına ürün çalışma kanıtı sayma.
- Cold-start, logcat ve gerekiyorsa gerçek cihaz kanıtı ara.
- Yeni bir V2/V3/V4/V5/V6/V7 tarzı kör yama zinciri başlatma.

**Not:** Son sohbetin exact son CI run/job/commit numaraları bu devir sırasında erişilebilen dosya indeksinden güvenilir biçimde yeniden çıkarılamadı. Bu nedenle bunlar **DOĞRULANACAK** olarak kabul edilmelidir. Tahmin edilmemelidir.

---

## 7. SORU BANKASI

- Daha önce kanonik olarak doğrulanan soru sayısı: **6.710**.
- Türkiye özel 2.000 kolay soru paketi hazırlandı.
- Paket: 2.000 ana + 120 yedek.
- Ana ID aralığı: `q59121–q61120`.
- Yedek ID aralığı: `q61121–q61240`.
- Altı kategoriye dağılım:
  - Coğrafya: 320
  - Türk dizileri/filmleri/müzikleri/eğlence: 500
  - Türk tarihi: 280
  - Türk sanat ve edebiyatı: 300
  - Türk bilim ve doğası: 220
  - Türk sporu: 380
- Paket SHA-256: `6eeeae49913140ae241e5655d0b585cb4c316b50d3d023af4c97cb91af8b2a78`

**Kritik:** Bu 2.000 sorunun güncel canlı `assets/questions.json` içine gerçekten merge edildiği ve güncel toplamın ne olduğu canlı repo üzerinden doğrulanmalıdır. Sırf eski sohbet notuna güvenme.

Soru değiştirirken her soru için birlikte kontrol:
- soru metni
- dört seçenek
- doğru indeks
- açıklama
- kategori
- zorluk

`assets/questions.json` kontrolsüz değiştirilmez.

---

## 8. ADMOB / FIREBASE / HESAP SİSTEMİ

Projede Firebase altyapısı bulunmaktadır:

- Firebase Core
- Firebase Authentication
- Cloud Firestore
- Google ile giriş

Canlı Düello sisteminde kullanıcı adı, eşleştirme, maç ekranı, soru seçimi, ilerleme, sonuç, lig/sıralama gibi modüller bulunur.

Daha önce kaydedilen güvenlik davranışları:
- kullanıcı adı benzersizdir
- hesap kayıtları birbirinden izole edilir
- Google hesabı ve misafir kayıtları ayrıdır
- BR puanı / lig / sıralama / maç geçmişi vardır
- doğru/yanlış puanları Firestore tarafından doğrulanır
- özel cevap anahtarı koleksiyonu vardır

Bu maddelerin exact güncel uygulama durumunu teknik değişiklik yapmadan önce canlı HEAD'den doğrula.

---

## 9. APK / AAB / CI

GitHub Actions projede kalite ve release doğrulaması için kullanılır.

Beklenen/korunan kalite kapıları:
- soru ve asset kalite kapısı
- Flutter analyze
- Flutter test
- Firebase yapılandırması
- kalıcı signing
- release APK
- Google Play AAB
- package/version/signature doğrulaması
- Android 16/cold-start gerektiğinde gerçek çalışma kanıtı

**Build PASS = otomatik kabul değildir.** Diff + test + log + artifact + Git geçmişi birlikte incelenir.

Public repo Actions politikası:
- gereksiz workflow/artifact üretme
- aynı PR'daki eski koşuları concurrency ile iptal et
- `paths` ile ilgisiz değişikliklerde ağır Android/görsel doğrulama çalıştırma
- APK/AAB yalnız ihtiyaç olduğunda üret
- kalıcı release çıktısını gerektiğinde GitHub Release'te tut

---

## 10. ÇALIŞMA PROTOKOLÜ

Her teknik işte şu sıra korunacak:

**Canlı durum → kararlar → görev/bitti ölçütü → branch → değişiklik → test → commit → push → PR → inceleme → açık onay → merge**

Kurallar:

- `main`/release'e doğrudan yazma.
- Ayrı branch aç.
- Levent açıkça onaylamadan kritik merge yapma.
- Kullanıcının ilgisiz yerel değişikliklerini silme.
- `git reset --hard` rutin çözüm olarak verme.
- Telefonda uygulanacak komut gerekiyorsa tek parça, doğrudan uygulanabilir ver.
- Commit adını açıkça belirt.
- Secret, parola, API key, testçi e-postası, UID/FID/token dosyalara/loglara koyma.
- Doğrulanmamış bilgiyi **DOĞRULANACAK** diye işaretle.

---

## 11. 3B TAHTA SINIRI

Bu proje alanına dönüldüğünde:

- Oynanışa dokunma.
- BoardMap / 67 node düzenine dokunma.
- Önce numaralı deterministik geometri.
- Kullanıcı onayı olmadan stil/Flutter/APK aşamasına geçme.
- Tek Matrix4 ile bütün 2B sahneyi eğme.
- 8 rozet / 6 pozisyon eşlemesi çözülmeden devam etme.

---

## 12. SORU GERİ BİLDİRİMİ SINIRI

Bir soru düzeltme kaydını gerçek düzeltme merge edilmeden kapatma.

Her soru için metin + seçenekler + doğru indeks + açıklama + kategori + zorluk birlikte kontrol edilir.

---

## 13. 1 AYLIK DEVİRDE PRATİK ÇALIŞMA ŞEKLİ

Emel'in ChatGPT'si bir görev aldığında:

### Eğer hata/CI ise
1. Canlı branch + PR + HEAD bul.
2. Son kırmızı workflow'u ve ilgili job logunu bul.
3. Failure'ın gerçek nedenini belirle.
4. Önceki başarısız denemeleri incele.
5. En küçük ama sistematik düzeltmeyi ayrı branch'te uygula.
6. Test et.
7. Commit/push/PR oluştur.
8. CI kanıtını kontrol et.
9. Merge için Levent onayını bekle.

### Eğer Kelime Avı ise
- 8×8 kilidini koru.
- 67 node'a dokunma.
- exact-one occurrence kuralını koru.
- kullanıcı kabulünü teknik PASS'tan ayır.
- PR #180'i temel bağlam olarak kontrol et.

### Eğer soru içeriği ise
- önce canlı `assets/questions.json` durumunu doğrula.
- kontrolsüz büyük dosya değişikliği yapma.
- kalite kapısını çalıştır.
- çakışma ve duplicate kontrolü yap.

### Eğer yayın/Play ise
- hangi AAB'nin hangi exact HEAD'den üretildiğini doğrula.
- package/version/signature eşleşmesini kontrol et.
- Play yükleme/yayınlamayı ayrı karar olarak ele al.

---

## 14. ŞU ANKİ ÖNCELİKLER

1. PR #180 CI sonucunu ve exact HEAD `618404e...` durumunu doğrula.
2. 200 bölüm Kelime Avı üretim hattını PASS et.
3. AdMob'un güncel exact HEAD + workflow + cold-start/logcat kanıtını doğrula.
4. `assets/questions.json` canlı toplamını ve Türkiye 2.000 paketinin merge durumunu doğrula.
5. Güncel production AAB/Play durumunu GitHub exact HEAD ile eşleştir.
6. Yeni teknik işlerde bu devir dosyasındaki kuralları koru.

---

## 15. MERGE / ONAY SINIRI

Bu dosyanın varlığı veya bir CI'ın yeşil olması merge yetkisi vermez.

**Levent'in açık onayı olmadan kritik merge/release/Play yayını yapılmaz.**

---

## 16. BU DOSYA NE ZAMAN SİLİNEBİLİR?

Emel'in ChatGPT'si:

1. Bu dosyayı tamamen okur.
2. `BILGI_ROTASI_DURUM.md` okur.
3. Canlı GitHub branch/HEAD/PR/CI durumunu doğrular.
4. İlgili karar ve görev dosyalarını bulur.
5. Proje durumunu bağımsız olarak anladığını doğrular.

Bunlardan sonra `DEVRALMA_1_AYLIK_GPT.md` dosyasını silebilir.

Silme commit'i örneği:

`docs: remove temporary one-month handover guide`

Silme işlemi ayrı branch/PR üzerinden yapılır; `main` üzerine doğrudan silme yapılmaz.

---

## SON NOT

Bu dosya özellikle yeni GPT'nin eski sohbetlerdeki yanlış sürüm/branch bilgilerini gerçek sanmasını engellemek için hazırlanmıştır.

**Kuralın özü:**

> **Canlı GitHub > proje durum dosyası > karar/görev kayıtları > eski sohbetler.**
>
> **Doğrulanmamış bilgi = DOĞRULANACAK.**
>
> **Build PASS = ürün kabulü değildir.**
>
> **Levent açık onayı olmadan kritik merge yok.**
