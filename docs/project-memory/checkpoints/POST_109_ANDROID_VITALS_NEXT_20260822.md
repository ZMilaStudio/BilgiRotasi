# Bilgi Rotası - +108/+109 Yayın Sonrası Android Vitals Sonraki İş Checkpoint'i

**Tarih:** 22 Ağustos 2026  
**Durum:** `KULLANICI TEYİDİ + DOĞRULANACAK`  
**Amaç:** 1.68.18+108 ve 1.68.19+109 production yayın durumunu kaydetmek ve bir sonraki teknik işi Android vitals edge-to-edge/cutout uyarıları olarak kilitlemek.

## 1. Canlı repo durumu

- Kanonik release branch: `release/final-closed-test-aab-1.68.8`
- Bu checkpoint başlangıcında canlı release HEAD: `39c03f169bbdf5dabb207af95c1fccf365400f98`
- Canlı `pubspec.yaml`: `1.68.19+109`
- Paket: `com.leventua.bilgirotasi`
- `1.68.19+109` için final production AAB kabul/yayın checkpoint'i ayrıca PR #95 altında tutuluyor.

## 2. Google Play production yayın teyidi

Levent 22 Ağustos 2026'da aşağıdaki iki sürümün de yapıldığını ve Google Play production'a yayınlandığını açıkça bildirdi:

- `1.68.18+108` — **YAYINLANDI / KULLANICI TEYİDİ**
- `1.68.19+109` — **YAYINLANDI / KULLANICI TEYİDİ**

Bu kayıt, eski `+107 son production` veya `+108/+109 henüz yayınlanmadı` varsayımlarını güncel durum açısından geçersiz kılar.

Not: +109'un production AAB provenance/CI kabulü repo checkpoint'lerinde ayrıca kayıtlıdır. Bu dosyada Play Console public rollout yüzdesi, mağazadan teslim edilen binary hash'i veya cihaz bazlı rollout kapsamı bağımsız olarak yeniden doğrulanmamıştır; gerektiğinde canlı Play Console'dan kontrol edilir.

## 3. Sonraki teknik iş: Android vitals edge-to-edge / cutout uyarıları

Levent'in Play Console Android vitals ekranında iki öneri görüldü:

1. **“Uçtan uca ekran tüm kullanıcılara gösterilmeyebilir”**
2. **“Uygulamanız, uçtan uca ekran için desteği sonlandırılmış API'leri veya parametreleri kullanıyor”**

İkinci uyarıda görünen eski parametre/API:

- `LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES`
- Kaynak olarak Play Console'da obfuscate edilmiş `b3.c.t` sınıfı gösteriliyor.

### Kritik ayrım

Ekran görüntüsündeki her iki Android vitals önerisi de **sürüm kodu 107 / sürüm adı 1.68.17** etiketi taşıyordu. Bu nedenle uyarının +108 veya +109'da hâlâ mevcut olduğu **varsayılmayacak**.

## 4. Bir sonraki sohbet/görev ilk olarak ne yapacak

Kod değiştirmeden önce sırasıyla:

1. Canlı Play Console'da production sürümünün `1.68.19+109` olduğunu yeniden doğrula.
2. Android vitals'ta bu iki uyarının +109 için de üretildiğini mi, yoksa yalnız eski +107 verisi olduğunu mu doğrula.
3. Uyarı +109'da devam ediyorsa `LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES` kullanımının gerçek kaynağını bul:
   - uygulamanın kendi Android/Flutter katmanı mı,
   - Flutter engine/plugin mi,
   - üçüncü taraf Android bağımlılığı mı.
4. `b3.c.t` obfuscate sınıf adından kör tahminle yama üretme; AAB/APK dependency/manifest/decompile kanıtıyla gerçek kaynağı belirle.
5. Gerekli düzeltmeyi ayrı branch'te yap ve Android 15/16 edge-to-edge/inset davranışını test et.
6. Özellikle status bar, display cutout/kamera deliği, gesture navigation ve 3-button navigation altında içerik/buton örtüşmesi olmadığını doğrula.
7. Tam test -> commit -> push -> PR -> inceleme sırasını koru; Levent açık onayı olmadan kritik merge yapma.

## 5. Bitti ölçütü

- [ ] Play production +109 canlı sürümü yeniden doğrulandı.
- [ ] Android vitals uyarılarının +109'a uygulanıp uygulanmadığı canlı Play Console'da ayrıştırıldı.
- [ ] Uyarı yalnız +107'ye ait tarihsel veri ise gereksiz kod değişikliği yapılmadan kayıt kapatıldı.
- [ ] Uyarı +109'da sürüyorsa `SHORT_EDGES` kullanımının gerçek source/dependency kaynağı kanıtlandı.
- [ ] Gerekli minimum edge-to-edge/cutout düzeltmesi ayrı branch'te uygulandı.
- [ ] Android 15/16 üzerinde status/navigation/cutout inset kabulü PASS.
- [ ] Uygulama açılışı, ana ekran, Ayarlar, öğretici, sonuç ekranı ve kritik oyun akışlarında görsel regresyon yok.
- [ ] Tam test/log/diff/Git geçmişi birlikte incelendi.
- [ ] Yeni release ancak bu kanıtlar sonrası değerlendirilir.

## 6. Dokunulmayacak alanlar

Bu görev nedeniyle kontrolsüz biçimde dokunulmayacak:

- `assets/questions.json`
- BoardMap / 67 node düzeni
- 3B tahta geometri/oynanış sözleşmesi
- Canlı Düello oyun kuralları
- AdMob/SSV ürün sözleşmesi

`KARARLAR.md` bu checkpoint nedeniyle değişmez; yeni ürün kararı alınmadı. Bu bir Android platform uyumluluğu/kalite işi olarak tutulur.
