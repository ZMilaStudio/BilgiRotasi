# KELİME AVI 2.0 — MASTER CONTRACT

Durum: **OWNER-APPROVED / LIVING MASTER CONTRACT**

Tarih: 2026-09-20

Kaynak authority:
- Repo: `ZMilaStudio/BilgiRotasi`
- Contract branch başlangıç SHA: `67c91fce5078bedfd14fb984eacd6f99a26f2792`
- Bu dosya ürün kararlarını ve yeni Kelime Avı 2.0 yönünü taşır.
- Bu doküman tek başına implementasyon yetkisi değildir. Kod aşamaları ayrı scope/prompt ile yürütülür.

---

## 1. ÜRÜN KONUMLANDIRMASI

Uygulamanın görünen adı:

**Bilgi Rotası & Kelime Avı**

Ana uygulama logosu:
- Değişmeyecek.
- Mevcut logo korunacak.

Ana giriş iki eşit oyun alanına ayrılacak:

1. **Bilgi Yarışması**
2. **Kelime Avı**

### Bilgi Yarışması
- Mevcut Bilgi Rotası ana ekranını açar.
- Mevcut Bilgi Yarışması ana ekran yapısı bu karar nedeniyle yeniden tasarlanmaz.

### Kelime Avı
- Artık Bilgi Rotası/Bilgi Yarışması içinde bir alt özellik gibi açılmayacak.
- Ana girişteki Kelime Avı kartından bağımsız bir Kelime Avı ana ekranına gidilecek.
- Navigation, progression, content ve presentation mümkün olduğunca kendi modül sınırında tutulacak.

Gelecek opsiyonu:
- Kelime Avı içerik ölçeği çok büyüdüğünde (ör. yaklaşık 1000 bölüm seviyesinde) ayrı bir **Kelime Avı** uygulaması üretme seçeneği açık tutulacak.
- Bu bir mevcut release şartı değil, geleceğe dönük ürün opsiyonudur.

---

## 2. KELİME AVI ANA EKRANI

Kelime Avı kartına basınca yeni, ayrı bir Kelime Avı ana ekranı açılacak.

İlk sürümde ana yapı sade tutulacak:

### A. Devam Et
- Oyuncunun kaldığı yere doğrudan götürür.
- Örnek: `Başlangıç Limanı • Bölüm 37`

### B. Rotalar
- Mevcut rota dünyalarını gösterir.
- Rota kartlarında ilerleme görülebilir:
  - tamamlanan bölüm / 100
  - toplam yıldız
  - aktif segment / 10
  - açık/kilitli durumu

### C. Genel İlerleme
- Toplam tamamlanan bölüm
- Toplam yıldız
- Bulunan bonuslar
- Tamamlanan rotalar gibi üst seviye istatistikler gösterilebilir.

Ana ekran menü kalabalığına dönüştürülmeyecek.

---

## 3. ROTA MODELİ

Her görsel rota artık:

**100 bölüm**

içerecek.

Her rota:

**10 segment × 10 bölüm = 100 bölüm**

şeklinde yapılandırılacak.

### Temel kural
**Rota = görsel dünya / atmosfer**
**Rota ≠ kelime konusu**

Örnek:
- Başlangıç Limanı'nda bulunan kelimelerin liman, deniz veya gemiyle ilgili olması zorunlu değildir.
- Orman Yolu'nda sürekli ağaç/yaprak/kök kelimeleri dönmeyecek.
- Kelime içeriği; günlük hayat, bilim, doğa, eşya, meslek, kültür, spor, tarih vb. alanlardan karışık gelebilir.

Bu ayrım yeni sistemin ana ürün kuralıdır.

---

## 4. SEGMENT MODELİ

Bir rota 10 adet 10-bölümlük segmente ayrılır.

Örnek:
- 1–10 → Segment 1
- 11–20 → Segment 2
- ...
- 91–100 → Segment 10

Segmentlerin kendine ait isimleri olacak.

Örnek isimleme mantığı:
- İskele
- Fener Yolu
- Eski Çarşı
- vb.

İsimler rota atmosferini anlatabilir fakat bölüm kelimelerini sınırlamaz.

### Harita görünümü
- Aynı anda 100 node gösterilmeyecek.
- Oyuncu aktif segmentte yalnız ilgili 10 node'u görecek.
- Mevcut premium 10-node harita yaklaşımı korunup segment sistemine ölçeklenecek.
- Tamamlanmış segmentlere geri dönüş mümkün olacak.
- Açılışta current/next playable node'a odaklanma desteklenecek.

---

## 5. SAHNE / ARTWORK ÜRETİMİ

Her bölüm için yeni sahne üretme zorunluluğu **yoktur**.

Rota başına yaklaşık:

**4–5 güçlü ana sahne**

yeterli kabul edilir.

Bu sahneler:
- farklı segmentlerde yeniden kullanılabilir,
- ışık,
- sis,
- saat,
- ambient,
- küçük dekorasyon,
- çevresel ton

gibi düşük maliyetli varyasyonlarla tazelenebilir.

Amaç:
- 100 bölüm için 100 artwork üretmemek,
- aynı zamanda 100 bölüm boyunca tek statik görüntüye mahkûm olmamak.

Mevcut owner-approved rota görsel kimlikleri korunacaktır. Önceden kilitlenmiş artwork dosyaları, ayrıca açık karar verilmeden değiştirilmez.

---

## 6. KELİME TEKRAR KURALI

Global oyun çapında benzersizlik zorunlu değildir.

### Kural:
**Aynı rota içinde bir kelime tekrar kullanılmayacak.**

Bir kelime:
- TARGET olarak,
- BONUS olarak

aynı rotanın başka bir bölümünde tekrar görünemez.

TARGET ↔ BONUS çapraz tekrar da rota içinde yasaktır.

### Yeni rotaya geçildiğinde
Kelime havuzu sıfırlanır.

Örnek:
- `ELMA` Başlangıç Limanı'nda bir kez kullanılabilir.
- Gökyüzü Adaları'nda yeniden kullanılabilir.

Bu kontrol insan gözüne bırakılmayacak; otomatik test/gate ile korunacaktır.

---

## 7. BÖLÜMDEKİ KELİME SAYISI

Bölümler:

`4 ana + 1 bonus`

gibi tek bir sabit yapıya zorlanmayacak.

Owner kararı:
- Mevcut değişken kelime sayısı yaklaşımı korunacak.
- Bölüm tipi ve zorluğa göre target/bonus sayıları değişebilir.

İçerik üretim sistemi bu esnekliği koruyacak.

---

## 8. ZORLUK PROGRESYONU

Zorluk yalnız kelime sayısını artırarak yükseltilmeyecek.

Kullanılabilecek eksenler:
- kelime uzunluğu
- kelime aşinalığı
- grid yoğunluğu
- ters yerleşim
- çapraz yerleşim
- benzer harf desenleri
- süre
- hata limiti
- bonus yapısı
- challenge kuralları

Genel eğri:
- 1–20 daha erişilebilir
- 21–50 orta
- 51–80 daha zor
- 81–100 ileri

Ancak oyuncuyu sözlükte nadiren görülen yapay kelimelerle boğmak hedef değildir.

---

## 9. MILESTONE / CHALLENGE YAPISI

Her 10. bölüm bir milestone'dur:

- 10
- 20
- 30
- 40
- 50
- 60
- 70
- 80
- 90
- 100

Milestone oynanışı normal bölümün birebir kopyası olmak zorunda değildir.

Aynı temel Kelime Avı motoru korunarak:
- süreli,
- daha sıkı hata limiti,
- daha uzun kelime,
- daha yoğun ters/çapraz,
- özel bonus şartı

gibi varyasyonlar uygulanabilir.

### Bölüm 50
**Büyük ara final / major midpoint**

### Bölüm 100
**Gerçek rota finali**

100. bölüm rota completion authority'sidir.

---

## 10. BİLGİ KARTLARI

Haritadaki sürekli **kitap** butonu kaldırılacak.

Bilgi kartları artık haritada ayrı bir kitap menüsüne bağımlı olmayacak.

Yeni yön:
- milestone ödülü,
- segment tamamlanma sürprizi,
- isteğe bağlı kısa bilgi ekranı

olarak sunulabilir.

İleride ayrı bir `Keşifler` arşivi düşünülebilir fakat mevcut master contract bunun yapılmasını zorunlu kılmaz.

---

## 11. ALT HARİTA KONTROLLERİ

Mevcut haritadaki:

- sağ alttaki **kitap**
- sol alttaki **pusula / rota shortcut**

kaldırılacak.

Rota/selector'a geri dönüş için mevcut geri navigation yeterli olacak.

Amaç:
- haritayı temizlemek,
- gereksiz chrome azaltmak,
- artwork ve progression'a daha fazla alan bırakmak.

---

## 12. LEVEL COMPLETION AKIŞI

Mevcut `Bölüm Tamamlandı → yalnız Rotaya Dön` akışı kaldırılacak.

### Normal bölüm
Primary CTA:
**Sonraki Bölüm**

Secondary CTA:
**Haritaya / Rotaya Dön**

### Segment sonu
Primary CTA:
**Sonraki Bölge**

### Rota finali — Bölüm 100
Primary CTA:
**Sonraki Rotaya Geç**

Uygun yerde secondary route/home navigation korunabilir.

Completion ekranları bulunduğu rotanın görsel dilini taşımalıdır.

---

## 13. SEGMENT GEÇİŞLERİ

Her 10'luk segment bittiğinde kısa bir geçiş ekranı kullanılabilir.

Bu ekran:
- yeni segment adı
- yeni sahne / atmosfer
- kısa `Yeni bölge açıldı` hissi

verir.

Büyük animasyon veya ağır asset üretimi zorunlu değildir.

---

## 14. YILDIZ VE TAMAMLAMA MOTİVASYONU

Yıldız sistemi korunabilir fakat yalnız dekor olarak kalmamalıdır.

Önerilen kullanım:
- segment içinde maksimum yıldız başarısı
- segment kartında özel görsel durum / çerçeve / madalya
- completionist oyuncuya ikincil hedef

Ancak yeni rota açmak için agresif yıldız duvarları oluşturmak zorunlu değildir.

Progression'ın ana authority'si bölüm tamamlama zinciri olmalıdır.

---

## 15. ROTA FİNALİ

Bölüm 100 tamamlandığında basit Material dialog yeterli değildir.

Rota finali:
- tam ekran veya güçlü presentation
- rota adı
- toplam yıldız
- bonus performansı
- kazanılan rota rozeti
- completion hissi
- sonraki rotaya geçiş

sunmalıdır.

Mevcut basit `Rota Tamamlandı` dialogu yeni sistemin kalite hedefi değildir.

---

## 16. GAMEPLAY PRESENTATION

Gameplay ekranı route-aware olmalıdır.

Mevcut production problem:
- themed reusable rotalarda gameplay background null kalınca Başlangıç Limanı/Harbor background fallback'i kullanılmaktadır.
- Header, metric plates, grid skin, instruction plate ve completion presentation da Harbor kimliğine sıkı bağlıdır.

Yeni contract:
- rota haritası ile gameplay görsel dili kopmayacak.
- Kayıp Şehir oynanırken Harbor'a dönülmeyecek.
- Yeraltı Krallığı / Güneş İmparatorluğu / Orman / Kristal vb. kendi route-theme presentation'ını taşıyacak.
- Ortak gameplay engine korunabilir; skin/theme dışarıdan çözülecek.

Bu bir production blocker olarak kabul edilir.

---

## 17. BÖLÜM İSİMLERİ

Bölümlerin kullanıcıya görünen isimleri runtime modelinde gerçek first-class alan olmalıdır.

Yalnız `Bölüm 1`, `Bölüm 2` yazmak yeterli değildir.

Önceden tasarlanan:
- Kervan İzi
- Fırtına Geçidi
- Halka Kilidi
- Göksel Mühür
- Ekinoks Kapısı
- Güneş Tahtı

gibi isimler runtime UI'da gerçekten gösterilebilmelidir.

100-bölüm sisteminde segment/bölüm adlandırma content contract'ın bir parçası olacak.

---

## 18. DEVAM ET DAVRANIŞI

Kelime Avı ana ekranında bir `Devam Et` authority'si olacak.

Oyuncu uygulamaya döndüğünde:
- son aktif rota
- son aktif segment
- next playable bölüm

çözülerek tek dokunuşla kaldığı yerden devam edebilecek.

Örnek:
`Devam Et — Başlangıç Limanı • 37. Bölüm`

---

## 19. MODÜLER MİMARİ HEDEFİ

Kelime Avı:
- aynı uygulamanın içinde kalacak,
- fakat mümkün olduğunca bağımsız bir feature/module gibi tasarlanacak.

Ayrı tutulması istenen alanlar:
- navigation
- content
- progression
- gameplay presentation
- route/segment model
- Kelime Avı home

Ortak app katmanında kalabilecekler:
- profil
- settings
- privacy
- monetization infrastructure
- shared app shell
- gerekli ortak servisler

Amaç:
ileride standalone `Kelime Avı` uygulamasına geçiş maliyetini azaltmak.

---

## 20. MEVCUT ROTALAR

Mevcut sekiz görsel dünya korunur:

1. Başlangıç Limanı
2. Gökyüzü Adaları
3. Orman Yolu
4. Kadim Orman
5. Kristal Vadisi
6. Kayıp Şehir
7. Yeraltı Krallığı
8. Güneş İmparatorluğu

Yeni contract ile:

**8 × 100 = 800 bölüm**

kapasitesi oluşur.

İleride yeni rotalar eklenebilir.

---

## 21. PRODUCTION RELEASE DURUMU

Mevcut production artifact:

`1.68.21+111`

GitHub production release olarak başarıyla üretilmiş olsa da cihaz testi sırasında Kelime Avı tarafında production blockers bulunmuştur.

Play Console rollout:
**DURDURULDU / YAPILMAMALI**

Bilinen blocker sınıfları:
- gameplay Harbor fallback / theme kopukluğu
- level completion UX ve navigation
- route completion UX/polish
- runtime content/level resolution için tekrar görünümü şüphesi
- yeni 100-bölüm/segment ürün modeline geçiş ihtiyacı

Bu nedenle mevcut artifact Play'e production rollout için onaylanmış kabul edilmez.

---

## 22. IMPLEMENTASYON PRENSİBİ

Bu master contract sonrası:

1. Önce yeni ürün/teknik contract tamamlanır.
2. Sonra migration ve architecture audit yapılır.
3. Sonra küçük, doğrulanabilir implementation wave'lerine ayrılır.
4. Her wave exact-HEAD test/gate ile kapanır.
5. Yeni production artifact owner cihaz testinden geçmeden Play Console'a gönderilmez.

Kafadan toplu rewrite yapılmaz.

---

## 23. KİLİTLİ OWNER KARARLARI — KISA ÖZET

- [x] Uygulama adı: Bilgi Rotası & Kelime Avı
- [x] Ana logo aynı
- [x] Ana giriş: Bilgi Yarışması | Kelime Avı
- [x] Bilgi Yarışması mevcut kendi ana ekranını kullanır
- [x] Kelime Avı'nın ayrı kendi ana ekranı olacak
- [x] Kelime Avı home: Devam Et + Rotalar + Genel İlerleme
- [x] Her rota 100 bölüm
- [x] 10 segment × 10 bölüm
- [x] Aynı anda 10 node
- [x] Rota kelime konusu değildir
- [x] Kelime tekrar yasağı rota içindedir
- [x] Yeni rotada kelimeler yeniden kullanılabilir
- [x] Kelime sayısı sabit 4+1 yapılmayacak
- [x] Mevcut değişken target/bonus yapısı korunacak
- [x] Rota başına yaklaşık 4–5 ana sahne yeterli
- [x] Her bölüm için yeni artwork gerekmiyor
- [x] Segment isimleri olacak
- [x] Her 10. bölüm milestone
- [x] 50 büyük ara final
- [x] 100 rota finali
- [x] Kitap kaldırılacak
- [x] Alt pusula/rota shortcut kaldırılacak
- [x] Bilgi kartları milestone ödülüne taşınacak
- [x] Sonraki Bölüm / Sonraki Bölge / Sonraki Rotaya Geç akışı
- [x] Route-aware gameplay skin
- [x] Bölüm isimleri runtime'da gösterilecek
- [x] Kelime Avı modüler tasarlanacak
- [x] İleride standalone Kelime Avı opsiyonu açık
- [x] Mevcut 1.68.21+111 Play rollout için onaylı değil

---

Bu dosya owner açıkça değiştirmedikçe yukarıdaki kararların authority kaydıdır.
