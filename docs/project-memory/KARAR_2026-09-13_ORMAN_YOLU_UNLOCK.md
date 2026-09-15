# Karar — Orman Yolu production unlock

**Tarih:** 13 Eylül 2026
**Durum:** KANONİK / OWNER ONAYLI

## Kesin karar

- `Orman Yolu`, production Kelime Avı rota kataloğunda üçüncü rota olarak görünür.
- `Orman Yolu` yalnız `Başlangıç Limanı` **10. bölüm tamamlandığında** açılır.
- Bu kapı yıldız toplamına bağlı değildir. Başlangıç Limanı 1–9'dan yüksek yıldız toplamı almak, 10. bölüm tamamlanmadıysa Orman Yolu'nu açmaz.
- `Gökyüzü Adaları` için mevcut **18 Başlangıç Limanı yıldızı** kapısı değişmez ve Orman Yolu kapısından bağımsızdır.
- Orman Yolu açıldığında rotanın kendi yeni/boş progress durumu değişmez: yalnız Bölüm 1 açık/current; Bölüm 2–10 locked.
- Orman Yolu içindeki bölüm ilerleyişi kesin olarak `1→2→3→4→5→6→7→8→9→10` sırasındadır; her tamamlanan bölüm yalnız bir sonrakini açar.
- Orman Yolu production presentation'ı generic `themedReusable` renderer ve `WordHuntRouteVisualThemes.ormanYolu` skinidir; route-id özel renderer koşulu eklenmez.

## Uygulama

- `WordHuntRouteUnlockKind.routeComplete` generic catalog kapısı olarak kullanılır.
- Orman prerequisite rotası `WordHuntStarterContent.baslangicLimani`dır.
- Unlock doğrulaması prerequisite rotanın son level'ının tamamlanmış olmasına bakar.
- Selector kilit metni yıldız yerine `Başlangıç Limanı 10. bölümü tamamla` sözleşmesini gösterir.
- Production locked snackbar aynı completion koşulunu kullanıcıya söyler.
- Route catalog testi; 27 yıldız / Bölüm 10 eksik durumunda Orman'ın kapalı, Bölüm 10 en az 1 yıldızla tamamlandığında açık olduğunu doğrular.

## Kapsam dışı

- Bu karar PR #198'i Ready/merge etme izni değildir. PR owner açıkça ayrıca onay verene kadar Draft/Open kalır.
- Play/release/deploy izni değildir.
- `questions.json`, BoardMap/67 node, Firebase, signing veya uygulama sürümü değiştirilmez.
