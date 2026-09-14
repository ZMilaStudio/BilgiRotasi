# Bilgi Rotası — Genel Proje Özeti

**Son güncelleme:** 14 Eylül 2026

## YENİ SOHBET DEVİR NOTU — ÖNCE BUNU OKU

Yeni sohbette işe başlamadan önce şu sırayı uygula:

1. Bu dosyanın tamamını oku: `docs/project-memory/GENEL_PROJE_OZETI.md`.
2. `docs/project-memory/KARARLAR.md` dosyasını oku.
3. Mevcutsa `docs/project-memory/DEVRALMA_1_AYLIK_GPT.md` dosyasındaki çalışma kurallarına uy.
4. Sonra canlı GitHub durumunu kendin doğrula: repo, branch, PR #198, exact HEAD, changed files ve GitHub Actions sonuçları.
5. Çelişki varsa öncelik: **canlı GitHub > proje bellek dosyaları > eski sohbetler**.

PR #198 için bağlayıcı durum: **OPEN / DRAFT / unmerged**. Branch: `feat/kelime-avi-scenic-theme-depth-20260912`, base: `release/final-closed-test-aab-1.68.8`. Bu dosya ürün koduyla aynı committe güncellenebilir; yeni sohbette exact HEAD'i mutlaka canlı fetch et.

> Kullanıcı özellikle şunu istemektedir: mockup/görsel üretip göndermek yerine değişikliği doğrudan oyuna uygula. Yeni görsel üretme; kullanıcı açıkça istemedikçe görsel gönderme. Görsel hedef premium, gerçekçi fantasy forest oyun hissidir.

## Kalıcı çalışma ve owner kuralları

- Repo: `ZMilaStudio/BilgiRotasi`.
- Canonical release branch: `release/final-closed-test-aab-1.68.8`.
- PR #198 kullanıcı açıkça ayrıca onay vermeden **Ready yapılmaz, merge edilmez, release/Play adımı başlatılmaz**.
- Her görev başında canlı branch, HEAD, PR ve CI yeniden doğrulanır.
- Build PASS tek başına yeterli değildir; diff + test + workflow + gerçek runtime kanıtı birlikte değerlendirilir.
- `assets/questions.json`, 67-node BoardMap, Firebase, signing, version ve Play kapsam dışıdır; kullanıcı açıkça izin vermeden dokunma.
- Görsel kabul yalnız gerçek/raw Android runtime üzerinden verilir; ImageGen/mockup/QA selector final kabul kanıtı değildir.

## Kelime Avı — KANONİK bölüm progression

Bu karar kesin ve kalıcıdır:

- Her 10-bölümlük rotada fresh/boş progress durumunda **yalnız Bölüm 1 açık/current** başlar.
- Bölüm **2–10 locked** başlar ve callback üretmez.
- Açılma sırası tam olarak `1→2→3→4→5→6→7→8→9→10`.
- Bir bölüm tamamlanınca yalnız bir sonraki bölüm açılır.
- Bölüm 8 normal bölümdür; Bölüm 9 ancak Bölüm 8 tamamlanınca açılır.
- Eski “7 bitince 8 ve 9 birlikte açılır” kararı **SUPERSEDED / GEÇERSİZ**.
- Ortak motor `WordHuntRouteProgressEngine.isLevelUnlocked`; tema/artwork bu mantığı değiştiremez.

## Production route catalog — KANONİK

Sıra:

1. **Başlangıç Limanı** — her zaman açık.
2. **Gökyüzü Adaları** — mevcut kural değişmedi: Başlangıç Limanı'ndan 18 yıldız.
3. **Orman Yolu** — owner kararı: **yalnız Başlangıç Limanı Bölüm 10 tamamlandığında açılır**.

Orman için önemli regresyon sözleşmeleri:

- Başlangıç Limanı 1–9 tamamlanmış ve 27 yıldız alınmış olsa bile B10 tamamlanmamışsa Orman **kilitli kalır**.
- B10 tamamlanınca Orman açılır.
- Orman açıldığında kendi içinde yine **1 açık/current, 2–10 locked** başlar.
- Kilit mesajı yıldız sayısına bağlanmaz; anlamı **“Başlangıç Limanı 10. bölümü tamamla”** olmalıdır.
- “0 yıldız gerekli” regresyonu geri gelmemelidir.

## PR #198 — Reusable rota görsel sistemi

PR: `#198 — feat(kelime-avi): add generic scenic depth to reusable map`

- Ortak `WordHuntRouteMapGeometry.normalizedStops` korunur.
- 10 node, 1–10 bağlantıları ve görünmez geniş touch/hitbox mantığı korunur.
- Liman / Gökyüzü / Orman progression mantığı ortaktır; route-id özel progression hilesi eklenmez.
- Orman production skin: `WordHuntRouteVisualThemes.ormanYolu`.
- Orman presentation: generic `themedReusable`.
- Artwork sahne tabanıdır; node, lock, yıldız ve progression state canlı Flutter katmanıdır.
- Onaylı Orman artwork'i 941×1672 olarak production'a bağlandı ve `2511d9e70d6e2aa52c82edc276408bc78d8e9c82` checkpointinde gerçek Android 16 ekranda doğrulandı.
- Orman route node görselleri owner onayıyla küçültüldü; rota geometrisi ve touch alanları değiştirilmedi.

## 14 Eylül 2026 — Orman Yolu UX kararı

Detaylı karar kaydı: `docs/project-memory/KARAR_2026-09-14_ORMAN_YOLU_UX.md`.

- Mevcut yön korunur: **Bölüm 1 üstte, Bölüm 10 altta**. Mevcut üç tema tersine çevrilmez.
- Bölüm 10 özel final kimliğini korur. Kilitliyken taç/prestij çerçevesi kalır fakat merkez kilit görünür ve yıldızlar pasif/gri olur; açılınca 10 ve aktif altın final görünümü geri gelir.
- Üst yeşil-altın panel yaklaşık %20–25 kompaktlaştırılır; geri ve bilgi kontrolünün görsel boyutu küçültülmez.
- Yıldız okunabilirliği artırılır fakat gameplay yıldız/progress verisi değiştirilmez.
- Pusula scroll/kamera hareketi yapmaz; yalnız `nextPlayableLevelIndex` node'unu kısa pulse/highlight ile gösterir.
- Kitap = mevcut/sıradaki bölümün konusu hakkında kısa öğretici bilgi.
- Sağ üst `i` = temalar arası genel Harita Rehberi. Kitap ve `i` görevleri ayrıdır.
- Arka plandaki **MEYDAN OKUMA** tabelası dekoratif kalır; buton değildir.
- SafeArea ve geniş touch target korunur; final node ile pusula/kitap touch alanı çakışmamalıdır.
- Açılış animasyonu sade fade + çok hafif depth hissidir; toplam 1 saniyenin altındadır, bounce yoktur.
- Test/proof ekranındaki örnek `0/30` veya yıldız görünümü progression bug kabul edilmez; gerçek veri kaynağı doğrulanmadan oyun veri sistemi değiştirilmez.
- Bu UX işi Orman 1 içindir; **Orman 2 üretimine başlanmaz**.

### Orman 2 gelecek pilotu

Orman 1 tamamen tamamlandıktan sonra ayrı pilot yapılacaktır. Orman 1 assetleri mümkün olduğunca yeniden kullanılarak ikinci bir Orman haritasının:

- üretim süresi,
- Orman 1'den yeterince farklı hissedilmesi,
- kalite kaybı olup olmaması

ölçülecektir. Pilot sonucu görülmeden ana tema başına 10'dan fazla bölüm/alt harita kararı verilmez.

## En son doğrulanmış test / Android checkpointi

UX rötuşlarından hemen önce doğrulanmış product checkpoint:

`2511d9e70d6e2aa52c82edc276408bc78d8e9c82`

Bu checkpointte:

- Kelime Avı route catalog kapısı: **SUCCESS**.
- Kelime Avı Android 16 görsel kanıtı: **SUCCESS**.
- AdMob PR doğrulaması: **SUCCESS**.
- Gerçek Android 16 screenshot üretildi.
- Fresh Orman runtime state: **Bölüm 1 açık, Bölüm 2–10 kilitli**.
- Onaylı 941×1672 Orman sahnesi ve küçültülmüş rota butonları gerçek runtime'da görüldü.

14 Eylül Orman UX rötuşları bu özetle aynı ürün commitine eklenir. Bu yeni commitin exact-head CI/Android 16 sonucu **canlı GitHub'dan yeniden doğrulanmadan PASS ilan edilmez**.

## Canonical gameplay ve release korumaları

- Grid: **8×8 / 64 hücre — LOCKED**.
- 6×10 tarihsel checkpointtir; geri dönmez.
- B5 60 sn, B10 120 sn soft challenge; hard-fail değildir.
- Minimum Kelime Avı yayın stoğu: **200 hazır/doğrulanmış bölüm**.
- 200/200 release-stock gate ve runtime/fiziksel kabul tamamlanmadan yeni Kelime Avı production release'i Play'e yüklenmez.
- Son production sürüm kaydı: **1.68.20+110**; yeni sohbette release HEAD/sürümü canlı doğrula.

## Yeni sohbette önerilen devam sırası

1. Bu dosya + `KARARLAR.md` + `KARAR_2026-09-14_ORMAN_YOLU_UX.md` dosyalarını oku.
2. PR #198'i canlı fetch et; OPEN/DRAFT/unmerged ve exact HEAD'i doğrula.
3. Exact HEAD'in route-catalog, Android 16 visual proof ve AdMob workflow durumlarını doğrula.
4. Progression/catalog mantığını tekrar kurcalama.
5. Orman'da 1 üstte → 10 altta yönünü değiştirme.
6. Final lock, pusula highlight, kitap/i görev ayrımı, SafeArea ve touch overlap regresyonlarını koru.
7. Kullanıcı ayrıca açıkça onay vermeden PR Ready/merge yapma.

**DEVİR SON DURUMU:** PR #198 OPEN/DRAFT/unmerged / production catalog = Başlangıç Limanı → Gökyüzü Adaları → Orman Yolu / Gökyüzü 18 yıldız kapısı değişmedi / Orman yalnız Başlangıç Limanı B10 completion ile açılır / Orman fresh state 1 açık 2–10 locked / strict 1→2→…→10 progression kalıcı / Orman yönü 1 üstte 10 altta / onaylı 941×1672 sahne production'da / son doğrulanmış checkpoint `2511d9e70d6e2aa52c82edc276408bc78d8e9c82` üç workflow SUCCESS / yeni Orman UX rötuşlarının exact-head CI sonucu canlı doğrulanacak / Orman 2 yalnız gelecekte ayrı pilot / merge ve Play yok.
