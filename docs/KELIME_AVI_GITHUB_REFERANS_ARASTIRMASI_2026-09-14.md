# Kelime Avı — GitHub Word Search Referans Araştırması

**Tarih:** 14 Eylül 2026  
**Amaç:** Kelime Avı'nda bölüm → rota → tema → görsel uygulama sürecini tasarlarken referans alınabilecek hazır Word Search oyunlarını GitHub üzerinden araştırmak.

> Bu dosya, 14 Eylül 2026 tarihli ilgili sohbetin kullanıcı ve asistan mesajlarını içerik olarak olduğu gibi devreder. Araştırma sonuçları kaynakların o anda görülen durumuna aittir; canlı repo/servis durumu değişebilir.

---

## Sohbet dökümü

### Kullanıcı
Sana bişey soracağım biz şimdi bölümlerde rota oluştur tema belirle uygula falan çok zorlanıyoruz ya ben sana kelime avı hazır bir apk versem sen inceleyebilirsin bence?

### Asistan
Tabii. Hatta bu, şu an yaşadığımız **“rota oluştur → tema belirle → uygula”** karmaşasını çözmek için iyi bir yöntem olabilir.

Senin kendi APK'nı değil, **başka bir geliştiricinin hazır Word Search / Kelime Avı oyununu** verirsen inceleyebiliriz.

İncelemekte özellikle şunları çıkarabilirim:

- Bölüm seçme ekranı ve ilerleme mantığı
- Rota / dünya haritası yapısı
- Bölüm düğümlerinin konumlandırılması
- Bölümler arası bağlantılar
- Tema değişimi nasıl yapılıyor
- Her temanın arka plan, dekor ve renk sistemi
- Harita üzerinde tekrar eden ama çeşitlenebilen tasarım kuralları
- Bölüm numarası / yıldız / kilit / tamamlanma göstergeleri
- Animasyonlar ve geçişler
- Word Search tahtasının görsel sistemi
- UX akışı
- Hangi şeylerin kodla üretildiği, hangilerinin asset olduğu

Sonra bunu **kopyalamak yerine**, Bilgi Rotası için uygulanabilir bir **tasarım sistemi / üretim standardına** çevirebiliriz.

Özellikle bizim ihtiyacımız şu:

**“Her bölüm için sıfırdan elle rota ve tema tasarlamak” yerine, birkaç kuralla yeni bölüm ve tema üretebilen bir sistem.**

APK'yı buraya yükleyebilirsen doğrudan inceleyelim. Play Store linki de varsa onu da gönder; oyun hakkında ek görsel/ürün bağlamı çıkarabiliriz.

---

### Kullanıcı
Hayır şöyle benim oyunum değil hazır bir kelime avı oyunu bulayım sana atayım sen onu incele.

### Asistan
Evet, şimdi tam olarak anladım.

**Başka bir geliştiricinin yaptığı hazır bir Kelime Avı / Word Search oyunu** bulacaksın, APK'sını bana vereceksin. Ben de onu referans olarak inceleyeceğim.

Özellikle şunları sökeceğiz:

1. **Bölüm haritası / rota sistemi**
2. Bölüm node'larının nasıl yerleştirildiği
3. Node'ların birbirine nasıl bağlandığı
4. Dünya/tema değişim sistemi
5. Bir temanın kaç bölüm sürdüğü
6. Bölüm ilerledikçe görsel değişim
7. Kilitli/açık/tamamlanmış bölüm görünümleri
8. Arka plan + dekor + renk + obje sistemi
9. Word Search oyun ekranı
10. Animasyon ve geçişler
11. Tekrar kullanılabilir tasarım kuralları

Ardından buradan **Bilgi Rotası'nın Kelime Avı için kendi özgün sistemimizi** çıkarırız.

Yani amaç oyunu kopyalamak değil; **“adamlar bunu nasıl sistemleştirmiş?”** sorusunun cevabını bulmak.

---

### Kullanıcı
Google playdan indirince apk gelmiyor sadace oyun yükleniyor sen @GitHub da geliştirici arasana?

### Asistan
GitHub'da aradım. İlk taramada doğrudan Play Store'daki belirli oyunun kaynağı olduğuna dair kanıt bulamadım; fakat referans olarak kullanılabilecek iki aday çıktı:

- `SpenceLabs/Word-Search-game`
- `jayydv18-ai/wordquest-hidden-trails`

Bunlar arasında özellikle ikinci isim, **level / trail / progression** fikri açısından daha ilginç görünüyor. Ancak bunların tam olarak aradığımız haritalı ve temalı Word Search yapısını içerdiğini henüz doğrulanmış kabul etmiyorum.

İstersen GitHub'ı daha hedefli tarayıp **5 iyi aday** çıkarabiliriz; özellikle `Word Search + level map + world map + chapter + stages + unlock + Android` özelliklerine odaklanabiliriz.

---

### Kullanıcı
Search GitHub for 5 good Word Search game candidates

### Asistan
GitHub'u taradım. Aradığımız şey **sadece basit bir Word Search kodu değil**, özellikle bizim Kelime Avı'ndaki **bölüm → harita/rota → tema → ilerleme** problemini çözmemize fikir verecek adaylar.

### En iyi 5 aday

1. **Colour-Word-Search — kai9987kai** ⭐
   - 10 farklı tema
   - Space Rocket, Ocean, Garden, Dino Valley, Candy Land, Robot Lab, Jungle, Pirate, Unicorn, Weather gibi dünyalar
   - Tema başına ayrı kelime listesi, renk paleti, görsel üretimi ve sticker sistemi var.
   - Bölüm/tema sistemimizi tasarlamak için **en ilginç aday bu**.
   - GitHub: https://github.com/kai9987kai/Colour-Word-Search

2. **Sopa-de-Letras — octavo-dev**
   - Gerçek Android Word Search uygulaması.
   - Grid, yatay/dikey/çapraz kelimeler ve Android arayüzü mevcut.
   - Basit ama Android tarafındaki oyun mimarisini incelemek için iyi.
   - GitHub: https://github.com/octavo-dev/Sopa-de-Letras

3. **Word Whizzle bot — jdalbey**
   - Burada ilginç olan oyun kodundan çok **gerçek bir mobil Word Search oyununun davranışının analiz edilmiş olması**.
   - Level tamamlanması, animasyon/geçişler ve oyun durumlarının nasıl ele alınabileceğine dair doğrudan gözlemler içeriyor.
   - GitHub: https://github.com/jdalbey/wordwhizzlebot

4. **Lexis — nadintamer**
   - Android uygulaması.
   - Word Search'i tek başına oyun olmaktan çıkarıp daha büyük bir ürün akışına bağlıyor.
   - Demo/wireframe ve ekran akışları bulunuyor; **UX açısından** bizim için değerli.
   - GitHub: https://github.com/nadintamer/Lexis

5. **Word_Search — Aatreyee23**
   - 10 ayrı level var.
   - Level 1 / Level 2 gibi ayrı aşamalar ve skor sistemi bulunuyor.
   - Görsel olarak daha basit, fakat **level progression** mantığını incelemek için kullanılabilir.
   - GitHub: https://github.com/Aatreyee23/Word_Search

### Fakat önemli nokta

Bunların içinde **“tam aradığımız, Candy Crush tarzı harita üzerinde ilerleyen Word Search”** adayını henüz bulmuş değilim.

Ben olsam **Colour-Word-Search'i ilk inceleme hedefi yaparım.** Çünkü bizim şu an en çok zorlandığımız **“tema nasıl değişecek, her bölüm nasıl farklı hissedecek?”** problemini doğrudan ele almış.

Ama bir sonraki aramada daha spesifik arayacağım:

**`Word Search + level map + world map + chapter + stages + unlock + Android`**

Çünkü bizim aradığımız şey aslında klasik Word Search değil; **haritalı, bölümlü, temalı Word Search oyunu.**

---

## Devir amacı

Emel'in kendi GPT'si bu dosyayı okuyarak araştırmanın neden yapıldığını ve hangi adayların bulunduğunu anlayabilir.

### Önemli çalışma çerçevesi

- Bu araştırma **Bilgi Rotası'nın mevcut gameplay sözleşmelerini değiştirme kararı değildir.**
- BoardMap / 67 node / 8×8 gameplay kuralları bu araştırma nedeniyle değiştirilmez.
- Amaç, mevcut Kelime Avı üretim sürecindeki rota + tema + bölüm görselleştirme zorluğuna referans olacak **tekrarlanabilir bir tasarım sistemi** bulmaktır.
- Referans oyundan kod, asset veya marka unsuru kopyalanmamalıdır.
- Öncelik: sistem mantığı, görsel dilin üretim kuralları, progression ve tema organizasyonu.
- Her aday için “DOĞRULANMIŞ” ve “DOĞRULANACAK” ayrımı korunmalıdır.
- Bu dosyadaki araştırma, canlı GitHub incelemesiyle yeniden doğrulanabilir.

## Sonraki araştırma hedefi

GitHub'da daha spesifik olarak şu özellikleri birlikte taşıyan Word Search oyunları aranacak:

`Word Search + level map + world map + chapter + stages + unlock + Android`

Aranan ideal referans:

**Harita/rota üzerinde node'larla ilerleyen → temalara ayrılmış → bölüm grupları olan → kilit açma/ilerleme sistemi bulunan → Word Search gameplay içeren bir oyun.**

Bu bulunursa önce **sadece inceleme ve sistem çıkarımı** yapılacak; Bilgi Rotası'na uygulanacak görsel veya teknik değişiklik için ayrıca ürün kararı/onay gerekir.
