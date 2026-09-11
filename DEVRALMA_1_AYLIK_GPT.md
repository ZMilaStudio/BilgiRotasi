# Bilgi Rotası — 1 Aylık GPT Devir Dosyası

**Son canlı doğrulama/checkpoint:** 12 Eylül 2026

**Devir amacı:** Levent projeyi geçici olarak Emel'e devrediyor. Bu dosya, başka bir sohbetten gelen GPT'nin eski sohbet/varsayım yerine canlı GitHub üzerinden doğru biçimde devam etmesi için çalışma protokolüdür.

> **ÖNEMLİ:** Canlı GitHub her zaman bu dosyadan üstündür. SHA, branch, PR, workflow veya sürüm çelişirse önce canlı GitHub'ı doğrula. Bu dosya geçici devir belgesidir; silinecekse önce `BILGI_ROTASI_DURUM.md` güncel olmalıdır ve silme ayrı branch/PR ile yapılmalıdır.

---

## 1. İLK KURAL — ESKİ SOHBETTEN DEĞİL, CANLI GITHUB'DAN DEVİR AL

İşe başlamadan önce mutlaka:

1. `BILGI_ROTASI_DURUM.md` oku.
2. `KARARLAR.md` varsa ilgili kararları oku; yoksa **DOĞRULANACAK** de.
3. `GOREV_HAVUZU.md` varsa aktif görevi/bitti ölçütünü oku; yoksa **DOĞRULANACAK** de.
4. `ACIK_SORULAR_VE_DOGRULAMALAR.md` varsa açık doğrulamaları oku.
5. Canlı branch, PR, exact HEAD, base SHA ve CI durumunu GitHub'dan kontrol et.
6. `main` dalını güncel ürün tabanı kabul etme.
7. `pubspec.yaml` sürümünü ilgili exact release/PR HEAD üzerinden oku.
8. Eski sohbetten gelen SHA/run/version bilgilerini canlı GitHub ile karşılaştırmadan doğru kabul etme.

**Öncelik sırası:** canlı GitHub > proje durum dosyası > karar/görev kayıtları > eski sohbetler.

---

## 2. REPO KİMLİĞİ VE KORUNAN SINIRLAR

- Repo: `ZMilaStudio/BilgiRotasi`
- Default branch: `main`
- Canonical release branch: `release/final-closed-test-aab-1.68.8`
- Android paket: `com.leventua.bilgirotasi`
- Framework: Flutter / Dart
- Hedef: Android

Ayrı açık karar olmadan değiştirme:
- `assets/questions.json`
- BoardMap / 67 node
- mevcut ana oyun oynanışı
- Firebase
- AdMob production ayarları
- signing
- package/version
- Play release/yayın

---

## 3. 12 EYLÜL 2026 CANLI GITHUB CHECKPOINT

### `main`

- Bu docs checkpoint branch'i açılırken `main` HEAD: `a5494b6f9c93b9d07ae04c45dc8360208ca5acf7`.
- `main` ürün/release gerçeği değildir; geriden gelebilir.

### Canonical release

- Branch: `release/final-closed-test-aab-1.68.8`
- HEAD: `d72b034a30bf32893b8a807ba4791d637880d989`
- Commit: `docs(kelime-avi): add V9 200-level conversation handoff`
- Release `pubspec.yaml`: **1.68.20+110**
- Play yükleme/yayınlama bu çalışma kapsamında yapılmadı.

### PR #180 — 200 bölüm Content Factory

- Durum: **OPEN / DRAFT / mergeable / merged=false**
- Branch: `feat/kelime-avi-200-level-content-pipeline-20260906`
- HEAD: `dd99b25ccb7d437ba6d05ea5dea26356a8d99032`
- Base: `release/final-closed-test-aab-1.68.8`
- `Kelime Avı Content Factory` run `34610110468`: **SUCCESS**
- `AdMob PR doğrulaması` run `34610110384`: **SUCCESS**
- 18 rota / 180 yeni bölüm + mevcut 20 = **200/200 release-stock gate PASS**
- Palindrome `KÖK` exact-one fiziksel occurrence hesabı aynı hücre yolunun ileri/geri yönünü tek fiziksel occurrence sayacak biçimde düzeltildi.
- Bu 200 bölüm **henüz release'e/runtime'a merge edilmiş değildir**.
- PR #180 Levent'in açık Ready/merge onayı olmadan merge edilmez.

### PR #184 — reusable 10-level route map engine

- Durum: **OPEN / DRAFT / mergeable / merged=false**
- Branch: `feat/kelime-avi-reusable-route-map-engine-20260911`
- HEAD: `b34bfddff5183692e62ac7c9bd49ad15140dae31`
- Base: release `d72b034a30bf32893b8a807ba4791d637880d989`
- `Kelime Avı Android 16 görsel kanıtı` run `34636992893`: **SUCCESS**
- `AdMob PR doğrulaması` run `34636992854`: **SUCCESS**
- Analyzer + tüm testler: PASS
- Focused Kelime Avı suite: PASS
- Reusable Orman Yolu proof APK: PASS
- Gerçek Android16 reusable screenshot: PASS
- Release APK/signing/package/manifest: PASS
- Android16 cold-start ilk deneme: PASS; ikinci deneme gerekmedi
- Final AdMob app gate: PASS

PR #184 artifact'leri:
- widget proof: `10278822820`
- gerçek Android16 reusable proof: `10278274442`
- mevcut Başlangıç Limanı pixel proof: `10278559423`

PR #184 amacı:
- rota başına ayrı master-art/piksel hitbox/özel layout çoğaltmasını bitirmek,
- tek normalized 10-stop geometri,
- tek reusable widget/painter,
- tema = renk/veri; geometri değil,
- yeni rota için özel Widget/Painter/koordinat listesi gerekmemesi.

**Kabul kapısı:** owner mimariyi kabul etmeden PR #184 Ready/merge yapılmaz ve yeni 180 bölüm runtime kataloğuna bağlanmaz.

---

## 4. PROGRESSION — RELEASE GERÇEĞİ İLE PR #184 ÖNERİSİNİ KARIŞTIRMA

### Mevcut canonical release `d72b034...`

Release kodunda hâlâ route-id özel istisna vardır:
- `baslangic-limani` ve `gokyuzu-adalari` için 7 tamamlanınca 9 da açılır,
- 8 bonus geçiş noktasıdır ve 9 için gate değildir,
- 10 yalnız 9 tamamlanınca açılır.

### PR #184 önerilen/kanıtlanmış yeni mimari

- sıra tamamen `1→2→3→4→5→6→7→8→9→10`,
- **8 normal bölümdür**, bonus node değildir,
- her bölüm yalnız önceki bölüm tamamlanınca açılır,
- route-id özel progression istisnası yoktur.

PR #184 merge edilmeden bu yeni modeli "canlı release davranışı" kabul etme.

---

## 5. KELİME AVI KİLİTLİ ÜRÜN KURALLARI

Release'e göre korunan kurallar:
- Canonical gameplay: **8×8 / 64 hücre**.
- Başlangıç Limanı: 10 bölüm / 30 yıldız / 80 target+bonus.
- Gökyüzü Adaları: 10 bölüm / 30 yıldız / 80 target+bonus.
- Her canonical kelimede exactly-one fiziksel occurrence.
- Reverse gesture aynı canonical kelimeyi üretir.
- Nearest-word/autocomplete yok.
- B5 ve B10 süreleri soft challenge.
- Kullanıcı görsel/oynanış kabulü olmadan görsel yön değiştirilmez.
- Gökyüzü Adaları scenic gameplay yönü kullanıcı tarafından kabul edilmiştir.

PR #184 kabul edilirse progression kuralı yukarıdaki sıralı modele taşınacaktır; kabul/merge öncesinde release gerçeği değişmiş sayılmaz.

---

## 6. REUSABLE HARİTA GÖRSEL KANITI

Gerçek Android16 Orman Yolu proof ekranında doğrulananlar:
- `Orman Yolu` başlığı ve yıldız sayacı okunaklı,
- 1–10 ortak geometri taşmasız,
- proof state'te 1–7 tamamlanmış, 8 açık, 9–10 kilitli,
- ortak painter/geometry kullanılıyor,
- route-id özel koordinat/layout yok.

Bu ekran **mimari iskelet kanıtıdır**; nihai Orman Yolu art/dekor tasarımı değildir. Production navigasyona bağlı değildir.

---

## 7. ADMOB — ÇALIŞMA YÖNTEMİ

AdMob geçmişte açılış çökmesi problemleri yarattığı için:

1. Gerçek Android `adb logcat` / `AndroidRuntime` hatası olmadan crash nedeni kesin ilan etme.
2. Full CI logunu baştan sona oku.
3. Workflow YAML + script + path + shell davranışını birlikte incele.
4. Yalnız son kırmızı satıra kör yama yapma.
5. `MobileAdsInitProvider` gibi kritik provider davranışlarını kanıtsız kaldırma.
6. Test App ID ile production App ID'yi karıştırma.
7. Build PASS'i tek başına ürün çalışma kanıtı sayma.
8. Cold-start + process/activity + logcat + artifact kanıtını birlikte değerlendir.

PR #184 exact HEAD'de AdMob validation `34636992854` SUCCESS'tır ve Android16 ilk cold-start denemesi PASS'tır.

---

## 8. HATA / CI ÇALIŞMA YÖNTEMİ

**Önce tam teşhis, sonra en küçük sistematik düzeltme.**

- Exact branch + PR + HEAD bul.
- Son kırmızı workflow/job'u bul.
- Tam logu oku.
- Önceki başarısız denemeleri incele.
- Gerçek neden kanıtlanmadan kesin sebep ilan etme.
- Değişikliği ayrı branch'te yap.
- Test et, commit/push/PR oluştur.
- Exact HEAD CI sonucunu kontrol et.
- Merge için açık onay bekle.

---

## 9. SORU BANKASI

- Önceki kanonik kayıt: **6.710 soru**.
- Türkiye özel 2.000 kolay soru paketi hazırlanmıştır.
- Paketin canlı `assets/questions.json` içine gerçekten merge edilip edilmediği ve güncel toplam soru sayısı: **DOĞRULANACAK**.
- `assets/questions.json` kontrolsüz değiştirilmez.

Soru değiştirirken birlikte kontrol:
- soru metni,
- dört seçenek,
- doğru indeks,
- açıklama,
- kategori,
- zorluk.

---

## 10. FIREBASE / HESAP SİSTEMİ

Projede Firebase Core, Authentication, Firestore, Google giriş ve canlı düello altyapıları bulunur. Eski kayıtlardaki kullanıcı adı/hesap izolasyonu/BR/lig/sıralama/server validation davranışlarını yeni teknik değişiklik öncesinde canlı HEAD'den doğrula.

Firebase rules/model ayrı karar olmadan değiştirilmez.

---

## 11. APK / AAB / CI

Beklenen kalite kapıları:
- Flutter analyze
- Flutter test
- asset/soru kalite gate'leri
- kalıcı signing
- release APK/AAB gerektiğinde
- package/version/signature doğrulaması
- Android16/cold-start gerçek çalışma kanıtı gerektiğinde

Public repo Actions için:
- gereksiz ağır workflow/artifact üretme,
- ilgisiz path değişikliklerinde Android/görsel workflow çalıştırma,
- aynı PR'daki eski koşuları mümkünse concurrency ile iptal et,
- APK/AAB yalnız ihtiyaç olduğunda üret.

---

## 12. ÇALIŞMA PROTOKOLÜ

Her teknik işte sıra:

**Canlı durum → kararlar → görev/bitti ölçütü → branch → değişiklik → test → commit → push → PR → inceleme → açık onay → merge**

Kurallar:
- `main`/release'e doğrudan yazma.
- Ayrı branch aç.
- Levent açıkça onaylamadan kritik Ready/merge/release/Play yapma.
- Kullanıcının ilgisiz değişikliklerini silme.
- `git reset --hard` rutin çözüm değildir.
- Secret/parola/API key/testçi e-postası/UID/FID/token loglama.
- Doğrulanmamış bilgi = **DOĞRULANACAK**.

---

## 13. 3B TAHTA SINIRI

- Oynanışa dokunma.
- BoardMap / 67 node düzenine dokunma.
- Önce numaralı deterministik geometri.
- Kullanıcı onayı olmadan stil/Flutter/APK aşamasına geçme.
- Tek Matrix4 ile bütün 2B sahneyi eğme.
- 8 rozet / 6 pozisyon eşlemesi çözülmeden devam etme.

---

## 14. 1 AYLIK DEVİRDE PRATİK ÖNCELİKLER

### P0
1. PR #184 için owner mimari kabul kararını bekle; açık onay olmadan Ready/merge yapma.
2. PR #180 200/200 content-stock gate'in PASS olduğunu koru; açık onay olmadan Ready/merge yapma.
3. PR #184 kabul edilirse production entegrasyonu **ayrı branch/PR** olarak planla; 180 bölümü bu mimari PR içinde runtime'a bağlama.

### P1
4. `assets/questions.json` canlı toplamını ve Türkiye 2.000 paketinin merge durumunu doğrula.
5. Play Console production/candidate sürümü ile GitHub exact HEAD eşleşmesini doğrula; Play aksiyonu ayrı açık onay gerektirir.

---

## 15. MERGE / ONAY SINIRI

Bu dosyanın varlığı, CI'ın yeşil olması veya kullanıcının genel "devam et" demesi kritik merge/release/Play yetkisi vermez.

**Levent'in ayrı ve açık Ready/merge/release/Play onayı olmadan kritik geçiş yapılmaz.**

---

## 16. BU DOSYA NE ZAMAN SİLİNEBİLİR?

Emel'in ChatGPT'si:
1. bu dosyayı tamamen okur,
2. `BILGI_ROTASI_DURUM.md` okur,
3. canlı GitHub branch/HEAD/PR/CI durumunu doğrular,
4. ilgili karar/görev dosyalarını kontrol eder,
5. proje durumunu bağımsız anladığını doğrular.

Bundan sonra dosya gerekiyorsa ayrı docs branch/PR ile silinebilir. `main` üzerine doğrudan silme yapılmaz.

---

## SON NOT

> **Canlı GitHub > proje durum dosyası > karar/görev kayıtları > eski sohbetler.**
>
> **Doğrulanmamış bilgi = DOĞRULANACAK.**
>
> **Build PASS = ürün kabulü değildir.**
>
> **Açık onay olmadan kritik merge/release/Play yok.**
