# KARAR — 14 Eylül 2026 — Orman Yolu Harita UX Son Rötuşları

## Kapsam
Bu karar yalnız mevcut Kelime Avı **Orman Yolu** rota/harita ekranının ürün ve UX son rötuşlarını kapsar. Orman sanat yönü, mevcut 1→10 geometri, progression motoru ve diğer iki mevcut tema yeniden tasarlanmaz.

## Kesin ürün kararları

- Orman Yolu ilerleme yönü **1 üstte → 10 altta** olarak korunur. Mevcut üç tema bu sistemde kalır; gelecekte yeni temalarda 1 altta → 10 üstte modeli ayrıca değerlendirilebilir.
- Ortak `WordHuntRouteMapGeometry` ve node konumları değiştirilmez.
- Bölüm 10 tema finalidir. Kilitliyken taç/prestij çerçevesi korunur fakat merkezde 10 yerine belirgin kilit görünür ve yıldızlar pasif/gri olur. Açılınca kilit kalkar, 10 görünür ve finalin altın aktif görünümü geri gelir. Tamamlanınca gerçek oyuncu yıldızı gösterilir.
- Orman node sanat dili korunur. Yıldızların okunabilirliği ve node altı hizası güçlendirilir; progression verisi değiştirilmez.
- Üst yeşil-altın başlık paneli yaklaşık %20–25 daha kompakt hale getirilir. Geri ve bilgi kontrollerinin görsel boyutu küçültülmez.
- Görsel node boyutundan bağımsız rahat touch target korunur. SafeArea zorunludur. Alt final node ile pusula/kitap touch alanları çakışmamalıdır.
- Pusula haritayı kaydırmaz ve kamera hareketi yapmaz. Yalnız `WordHuntRouteProgressEngine.nextPlayableLevelIndex` tarafından belirlenen sonraki oynanabilir node'u kısa ve zarif bir pulse/highlight ile vurgular.
- Kitap, Orman Yolu'nda sıradaki/mevcut bölümün konu rehberini açar. Oyun/harita kullanım rehberi değildir.
- Sağ üst `i` butonu temalar arası ortak kullanılabilecek kısa **Harita Rehberi** açar: sırayla ilerleme, 3 yıldız üst sınırı, yeni durakların açılması, final tacı, pusula ve kitap görevleri.
- Arka plandaki **MEYDAN OKUMA** tabelası dekoratif sahne öğesidir; buton değildir ve ayrı etkileşim/animasyon almaz.
- Harita açılışında toplamı 1 saniyenin altında sade fade + çok hafif depth hissi kullanılabilir. Bounce/zıplama yoktur.
- Test ekranındaki örnek yıldız/0÷30 görünümü progression bug kanıtı sayılmaz; gerçek veri kaynağı doğrulanmadan gameplay/veri motoru değiştirilmez.

## Kapsam dışı

- Yeni Orman arka planı veya sanat yönü üretmek.
- Başlangıç Limanı / Gökyüzü Adaları redesign.
- Haritayı scroll edilebilir yapmak.
- `questions.json`, BoardMap/67 node, Firebase, signing, version veya Play değişikliği.
- Orman 2 üretimine başlamak.

## Orman 2 gelecekteki pilot

Orman 1 tamamlandıktan sonra ayrı pilot çalışma yapılacaktır. Orman 1 assetleri mümkün olduğunca yeniden kullanılarak ikinci bir Orman haritası üretmenin:

- üretim süresi,
- Orman 1'den yeterince farklı hissedilmesi,
- kalite kaybı olup olmaması

ölçülecektir. Pilot sonucu görülmeden bir ana tema altında 10'dan fazla bölüm/alt harita ürün kararı verilmez.

## Doğrulama kapısı

- Farklı telefon boyutlarında overflow/SafeArea kontrolü.
- Final node ile alt kontrollerin touch rect çakışma kontrolü.
- Pusulanın yalnız doğru sonraki node'u vurguladığı widget testi.
- Kilitli final node'un lock + pasif yıldız görünümü.
- Kitap ve `i` görev ayrımı.
- Meydan Okuma tabelasının interaktif olmaması.
- Exact-head Android 16 raw visual proof.
- PR #198 owner açık Ready/merge onayı olmadan Draft/unmerged kalır.
