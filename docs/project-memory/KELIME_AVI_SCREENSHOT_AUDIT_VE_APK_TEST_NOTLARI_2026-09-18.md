# Kelime Avı — Production Screenshot Audit ve APK Test Notları

**Tarih:** 18 Eylül 2026
**Kapsam:** Production screenshot görsel incelemesi + Kayıp Şehir üçlemesi sonrası manuel APK test kararı

## Production screenshot audit özeti

İncelenen gerçek Android production screenshot paketi: `kelime_avi_production_screenshots_PARTIAL_7of10.zip`.

Toplanan 7 gerçek PNG:
- Başlangıç Limanı — harita
- Başlangıç Limanı — gameplay (Bölüm 10)
- Gökyüzü Adaları — harita
- Gökyüzü Adaları — gameplay (Bölüm 1)
- Orman Yolu — harita
- Kadim Orman — harita
- Kristal Vadisi — harita

Eksik gerçek gameplay screenshotları:
- Orman Yolu
- Kadim Orman
- Kristal Vadisi

Eksik 3 gameplay karesi mockup/üretilmiş görselle tamamlanmadı. Fırsat olduğunda gerçek Android runtime üzerinden ayrıca toplanacak.

## Görsel inceleme notları

Genel değerlendirme:
- Beş production rota birbirinden yeterince farklı dünya kimliği taşıyor.
- Başlangıç Limanı, Gökyüzü Adaları, Orman Yolu, Kadim Orman ve Kristal Vadisi görsel olarak ayrışıyor.
- Orman Yolu → Kadim Orman geçişi aynı ana evrenin daha derin/kadim varyantı gibi çalışıyor.
- Kristal Vadisi önceki rotalardan belirgin biçimde ayrılıyor.
- Gameplay düzeninin temel yapısı rotalar arasında tutarlı: üst bilgi → hedef kelimeler → 8×8 grid → alt yönlendirme.

İleride genel polish/audit turunda değerlendirilecek notlar:

1. **Orman Yolu / Kadim Orman locked node numaraları**
   - Kilitli node'larda bölüm numarası görünürlüğü zayıf/kayıp.
   - Başlangıç, Gökyüzü ve Kristal'de rota sırasını gözle takip etmek daha kolay.
   - Kritik blocker değil; ileride genel route-map polish kapsamında değerlendirilebilir.

2. **Gökyüzü Adaları gameplay başlık kontrastı**
   - `Gökyüzü Adaları` alt başlığı parlak gökyüzü üzerinde Başlangıç Limanı kadar güçlü kontrast taşımıyor.
   - Kritik blocker değil; ileride typography/contrast polish notu.

3. **Kristal Vadisi chrome stil farkı**
   - Harita/node dili mor-turkuaz ve modern kristal kimliğinde.
   - Pusula/kitap/back/info ortak siyah-altın chrome ile daha eski bir stil taşıyor.
   - Çirkin veya blocker değil; tüm haritalar yan yana değerlendirildiğinde stil farkı belirginleşiyor.

4. **Progress/star screenshot güvenilirliği**
   - Gökyüzü haritasında `0/30` gösterirken bazı altın yıldızlar görünmesi,
   - Kristal haritasında `9/30` gösterirken birden fazla node altında altın yıldızlar görünmesi,
   geçmiş proof/staged progress state kaynaklı olabilir.
   - Bu screenshotlar progress/star doğruluğu için authoritative kanıt sayılmayacak.
   - Gerekirse gerçek kullanıcı save state'i ile ayrıca kontrol edilecek.

5. **Eksik gameplay görsel doğrulaması**
   - Orman Yolu, Kadim Orman ve Kristal Vadisi gerçek gameplay ekranları ayrıca alınmadan bu rotalarda grid okunabilirliği, target chip kontrastı ve üst başlık davranışı tam görsel audit olarak kapanmış sayılmayacak.

Bu maddelerin hiçbiri mevcut production için acil kod değişikliği / blocker olarak sınıflandırılmadı.

## Kayıp Şehir üçlemesi için görsel yön notu

Mevcut beş rotanın yan yana değerlendirilmesi, yeni Kayıp Şehir üçlemesinin üç ayrı rota kimliğiyle tasarlanması kararını destekliyor.

Kayıp Şehir → Yeraltı Krallığı → Güneş İmparatorluğu aynı anlatı evreninde olmalı, ancak her 10 bölümde oyuncuya gerçekten yeni bir dünya/katman hissi vermeli.

## OWNER KARARI — APK üretim ve manuel test

**Kayıp Şehir üçlemesi tamamen bittikten sonra APK üretilecek ve owner tarafından gerçek cihazda manuel test yapılacak.**

Bu APK testi üçleme tamamlandıktan sonra yapılacak final ürün doğrulama adımıdır.

Manuel testte özellikle:
- rota seçim ekranı,
- unlock zinciri,
- üç yeni haritanın görünümü,
- node/readability,
- gameplay grid okunabilirliği,
- target/bonus kelime davranışı,
- L5 challenge ve L10 final akışı,
- reward/ceremony,
- eski 5 rota ile regression,
- farklı ekran boyutlarında görsel bütünlük

kontrol edilecek.

APK üretimi/testi, üçlemenin tasarım ve implementation'ı tamamlanmadan başlatılmayacak.

## Durum

Bu dosya yalnız audit ve owner test planı notudur.
Kod, asset, test veya runtime contract değiştirmez.
