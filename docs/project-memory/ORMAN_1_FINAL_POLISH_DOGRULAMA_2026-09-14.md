# Orman 1 final polish ve doğrulama planı — 14 Eylül 2026

## Owner onayı

Orman Yolu için mevcut production artwork ve mevcut 1→10 zig-zag kompozisyonu korunur. Koyu yeşil teknik/test görünümü final tasarım değildir. Final değerlendirme gerçek Orman production artwork'i ve canlı Flutter progression/UI katmanı birlikte render edildiğinde yapılır.

## Bu aşamada bağlayıcı kapsam

1. Gerçek Android Orman ekranı bütün olarak değerlendirilir.
2. Node konumları değiştirilmeden rota/patika okunurluğu kontrol edilir; yalnız gerçekten gerekli minimal düzeltme yapılır.
3. Final node kilitli / açık / tamamlanmış durumları ayrı ayrı doğrulanır.
4. Pusula yalnız sıradaki oynanabilir node'u vurgular; kitap bölüm konusunu, sağ üst `i` genel harita rehberini açar.
5. Node, geri, bilgi, pusula ve kitap touch target'ları ile SafeArea davranışı doğrulanır. Final node ile alt kontroller çakışmamalıdır.
6. Açılış animasyonu kısa fade + çok hafif depth hissinde kalır; toplam süre 1 saniyeyi geçmez ve bounce kullanılmaz.
7. Android 16 üzerinde standard, compact ve tall telefon boyutlarında gerçek screenshot kanıtı üretilir. Kanıt kapısı yalnız non-black kontrolüyle yetinmez; zengin Orman artwork'ünün gerçekten göründüğünü merkezi parlaklık/renk çeşitliliği ölçümüyle de doğrular.

## Değiştirilmeyecekler

- Yeni Orman artwork üretilmez.
- `WordHuntRouteMapGeometry.normalizedStops` ve 1 üstte / 10 altta yön değiştirilmez.
- Node'lar yeniden dizilmez.
- `MEYDAN OKUMA` tabelası interaktif yapılmaz.
- Gameplay progression veya yıldız verisi test/proof örneklerinden hareketle değiştirilmez.
- Başlangıç Limanı ve Gökyüzü Adaları redesign edilmez.

## Orman 2 geçidi

Orman 2 pilotuna başlanmaz. Owner açıkça **“Orman 1 tamam”** demeden asset-reuse pilotu açılmaz.

## Kanıt dosyaları

Yeni exact-head CI'da `Orman Yolu Android çoklu ekran kanıtı` workflow'u üç gerçek Android 16 screenshot'ı ve her screenshot için artwork-richness metriği üretir. Final rapor yalnız workflow SUCCESS ve görüntülerin elle kontrolü sonrasında verilir.
