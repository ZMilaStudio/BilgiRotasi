# Kelime Avı — 200 Bölüm Üretim Hattı

Tarih: 6 Eylül 2026

## Kilit ürün kararı

Kelime Avı, yalnız 20 bölümle Google Play'e çıkarılmayacak.

Yeni minimum yayın stoğu:

- en az **200 hazır ve doğrulanmış bölüm**,
- 200 bölüm altı build Kelime Avı için production Play adayı sayılmaz,
- mevcut 20 bölüm kalite/ürün tabanı olarak korunur,
- `1.68.20+110` GitHub production AAB Kelime Avı içerdiği için Play'e yüklenmez.

Bu karar yalnız Kelime Avı kapsamındadır; mevcut Bilgi Rotası ana uygulamasının diğer modlarını otomatik olarak bloke eden genel bir release kuralı değildir.

## Neden üretim hattı değişiyor?

İlk iki 10 bölümlük rota, görsel ve runtime kaliteyi kurmak için yoğun el emeği gerektirdi. Aynı mikro üretim yöntemi 200+ bölüme ölçeklenemez. Bundan sonra iki iş birbirinden ayrılır:

1. **Ürün/görsel sistemleri**: rota MASTER ART, gameplay arka planı, selector ve canonical UI. Bunlar rota başına hazırlanır ve sık değiştirilmez.
2. **İçerik fabrikası**: kelime listesi → deterministik 8x8 grid → exact-one doğrulama → toplu rapor.

Kullanıcı her bölümün gridini tek tek test etmez. İnsan incelemesi kelime kalitesi, tema ve nihai fiziksel kabul katmanında yapılır; mekanik grid doğrulaması otomatik yapılır.

## Teknik content factory

Yeni araç:

`tools/word_hunt_batch_generator.py`

Amaç:

- 8x8 canonical grid üretmek,
- yatay/dikey/çapraz ve ters yönleri desteklemek,
- hedef + bonus kelimeyi aynı gridde yerleştirmek,
- her hedef/bonus kelimenin fiziksel occurrence sayısını **tam 1** olarak doğrulamak,
- deterministik seed kullanmak,
- duplicate / hedef-bonus çakışması / geçersiz kelime / bozuk sıra / final bölümü hatalarını reddetmek,
- toplam hazır bölüm sayısını raporlamak,
- `--require-release-stock` ile 200 altını release gate'te FAIL yapmak.

Bu araç production runtime'a henüz bağlanmaz. Önce içerik üretim ve doğrulama hattıdır.

## CI

`.github/workflows/word-hunt-content-factory.yml`

PR üzerinde:

- Python syntax kontrolü,
- örnek manifestten gerçek 8x8 üretim,
- exact-one occurrence kontrolü,
- 200 bölüm altı release gate'in gerçekten FAIL verdiğinin negatif testi

çalışır.

## Üretim hedefi

Minimum stok modeli:

- mevcut: 2 rota × 10 = 20 bölüm,
- hedef: en az 20 rota × 10 = 200 bölüm,
- tercih edilen yayın tamponu: 200–300 bölüm.

20 rota zorunlu değildir; toplam bölüm sayısı 200'ün üzerinde olduğu sürece farklı rota/bölüm dağılımları kullanılabilir. Ancak mevcut ürün dili 10 bölümlük rota yapısına uygun olduğu için varsayılan üretim birimi **10 bölümlük paket** olarak kalır.

## Kalite kapıları

Bir bölüm ancak şu kapılardan geçince 'hazır' sayılır:

1. Kelime listesi editoryal olarak anlamlı ve tema ile uyumlu.
2. Kelimeler 3–8 harf ve canonical Türkçe karakter sözleşmesine uygun.
3. Hedef/bonus duplicate yok.
4. 8x8 grid üretimi başarılı.
5. Her hedef/bonus exact-one occurrence PASS.
6. Bölüm tipi / süre / yıldız kuralları geçerli.
7. Rota sıra/final sözleşmesi geçerli.
8. İlgili toplu CI PASS.

## Korunan kapsam

Bu üretim hattı kurulurken aşağıdakilere dokunulmaz:

- `assets/questions.json`
- BoardMap / 67 node
- Firebase
- AdMob
- signing
- package id
- production version
- Play release/yayın işlemleri

## Sonraki büyük üretim bloğu

1. 18 yeni rota/paket için tema ve kelime havuzları hazırlanacak.
2. Kelime havuzlarından 180 yeni bölüm manifesti toplu üretilecek.
3. Content factory ile 180 yeni bölümün 8x8 gridleri ve exact-one raporları otomatik oluşturulacak.
4. Mevcut 20 + yeni 180 = minimum 200 hazır bölüm eşiği doğrulanacak.
5. Ancak bundan sonra runtime katalog entegrasyonu ve yeni Play adayı değerlendirilecek.
