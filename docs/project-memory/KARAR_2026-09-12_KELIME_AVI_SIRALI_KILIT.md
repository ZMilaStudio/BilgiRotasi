# Kelime Avı — Sıralı Bölüm Kilidi Kararı

Tarih: 12 Eylül 2026
Durum: KESİN / KANONİK

Bu karar bütün 10 bölümlük Kelime Avı rotalarında geçerlidir.

- Yeni/boş ilerleme durumunda **yalnız Bölüm 1 açıktır**.
- **Bölüm 2–10 kilitlidir**.
- Bölüm 2 yalnız Bölüm 1 tamamlandıktan sonra açılır.
- Bölüm 3 yalnız Bölüm 2 tamamlandıktan sonra açılır.
- Aynı kural sıralı olarak devam eder: `1 → 2 → 3 → 4 → 5 → 6 → 7 → 8 → 9 → 10`.
- Hiçbir bölüm kendinden önceki bölüm tamamlanmadan açılamaz.
- Bir bölümün tamamlanması yalnızca **bir sonraki** bölümü açar; aynı anda iki ileri bölüm açılmaz.
- Bölüm 8 normal bölümdür; bonus atlama kapısı değildir.
- Bu kural rota teması, görsel skin veya artwork nedeniyle değiştirilemez.
- Görsel proof ve Android kabul ekranları da varsayılan olarak bu ilk açılış durumunu göstermelidir: **1 açık/current, 2–10 locked**.

## Supersede

Bu karar, eski `KARARLAR.md` içindeki “Level 7 tamamlanınca 8 ve 9 birlikte açılır / 8 zorunlu kapı değildir” şeklindeki tarihsel Başlangıç Limanı kararını **supersede eder ve geçersiz kılar**. Güncel davranış kesin olarak sıralıdır.

## Kod sözleşmesi

Kanonik motor `WordHuntRouteProgressEngine.isLevelUnlocked` içinde bunu uygular: Bölüm 1 her zaman açıktır; `N > 1` için yalnız `N-1` tamamlanmışsa N açılır. Bu sözleşme regresyon testleri ve gerçek Android görsel kanıtı ile korunacaktır.
