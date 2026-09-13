# Bilgi Rotası — Genel Proje Özeti

**Son güncelleme:** 13 Eylül 2026

## YENİ SOHBET DEVİR NOTU — ÖNCE BUNU OKU

Yeni sohbette işe başlamadan önce şu sırayı uygula:

1. Bu dosyanın tamamını oku: `docs/project-memory/GENEL_PROJE_OZETI.md`.
2. `docs/project-memory/KARARLAR.md` dosyasını oku.
3. `docs/project-memory/DEVRALMA_1_AYLIK_GPT.md` dosyasındaki çalışma kurallarına uy.
4. Sonra canlı GitHub durumunu kendin doğrula: repo, branch, PR #198, exact HEAD, changed files ve GitHub Actions sonuçları.
5. Çelişki varsa öncelik: **canlı GitHub > proje bellek dosyaları > eski sohbetler**.

Bu özet yazılmadan hemen önce PR #198 canlı olarak **OPEN / DRAFT / unmerged / mergeable** durumundaydı. Branch: `feat/kelime-avi-scenic-theme-depth-20260912`, base: `release/final-closed-test-aab-1.68.8`. O anda canlı PR HEAD `5c4e577b4bea71cc9940c3f53481d82d97335d94` idi. **Bu özet güncellemesi docs-only yeni commit oluşturacağı için yeni sohbette HEAD'i mutlaka yeniden fetch et.**

> Kullanıcı özellikle şunu istemektedir: mockup/görsel üretip göndermek yerine değişikliği doğrudan oyuna uygula. Yeni görsel üretme; kullanıcı açıkça istemedikçe görsel gönderme. Kullanıcı “bebek çizimi/cartoon” hissini istemiyor; hedef premium, gerçekçi fantasy forest oyun hissi.

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
3. **Orman Yolu** — owner tarafından 13 Eylül 2026'da onaylanan kural: **yalnız Başlangıç Limanı Bölüm 10 tamamlandığında açılır**.

Orman için önemli regresyon sözleşmeleri:

- Başlangıç Limanı 1–9 tamamlanmış ve 27 yıldız alınmış olsa bile B10 tamamlanmamışsa Orman **kilitli kalır**.
- B10 tamamlanınca Orman açılır.
- Orman açıldığında kendi içinde yine **1 açık/current, 2–10 locked** başlar.
- Kilit mesajı kullanıcıya yıldız sayısı söylemez; anlamı **“Başlangıç Limanı 10. bölümü tamamla”** olmalıdır.
- “0 yıldız gerekli” regresyonuna karşı test eklenmiştir.

## PR #198 — Reusable rota görsel sistemi

PR: `#198 — feat(kelime-avi): add generic scenic depth to reusable map`

- Ortak `WordHuntRouteMapGeometry.normalizedStops` korunur.
- 10 node, 1–10 bağlantıları ve **86×82 hitbox** korunur.
- Liman / Gökyüzü / Orman aynı generic renderer üzerinden çalışır; route-id özel koordinat/painter hilesi eklenmez.
- Orman production skin: `WordHuntRouteVisualThemes.ormanYolu`.
- Orman presentation: generic `themedReusable`.
- Artwork yalnız sahne tabanıdır; node, lock, yıldız ve progression state canlı Flutter katmanıdır ve asset içine bake edilmez.
- Scenic görünümde üst header daha küçük/ahşap-plaka hissine çekildi; açık/current node ahşap stump, locked node taş/kaya görünümüne yaklaştırıldı; kilit taşın içine entegre edildi; kalın yapay yol bandı azaltılıp hafif stepping-stone/earth path kullanıldı.
- Ortak geometri/progression bu görsel düzenlemeler uğruna değiştirilmedi.

## Doğrulanmış test / Android durumu

En son doğrulanmış **ürün/test checkpoint**: `827643972fc991cb63c594dc2e326d03594b2a71`.

Bu ürün/test checkpointinde:

- Route catalog gate: **12/12 PASS**.
- Orman `routeComplete` kapısı ve “27 yıldız ama B10 yok → kilitli / B10 tamam → açık” testleri PASS.
- Locked Orman mesajı “0 yıldız” regresyon testi PASS.
- Gerçek Android 16 raw visual proof: **SUCCESS**.
- 1080×1920 screenshot üretildi; frame-ready/artwork marker ve non-black/visible pixel gate PASS.
- Uygulama crash/ANR/process-death taraması PASS.
- AdMob / release APK / Android 16 cold-start gate: **SUCCESS**.
- Fresh Orman runtime state: **Bölüm 1 açık, Bölüm 2–10 kilitli**.

Not: Bundan sonraki docs-only commitler ürün kodunu değiştirmeyebilir. Yeni sohbet exact HEAD'de workflow sonuçlarını yine canlı kontrol etmelidir.

## Orman artwork — kalan tek gerçek görsel kalite borcu

Mevcut production Orman rasterı gerçekten **200×400** çözünürlükte decode ediliyor. Android 1080×1920 ekranda büyütülerek gösterildiği için sahne yumuşak/blur görünüyor.

- Bu 200×400 kaynak final yüksek çözünürlük artwork olarak kabul edilmez.
- Yapay upscale/sharpen işlemini “HD” diye final kabul etme; gerçek detay üretmez.
- Üzerinde node/yazı/UI bake edilmiş yüksek çözünürlüklü referans görselleri doğrudan background olarak kullanma; canlı Flutter node'larıyla çift node/UI üretir.
- Sohbet/Library/repo geçmişinde çeşitli yüksek çözünürlüklü referanslar bulundu ancak **temiz, onaylı, background-only gerçek HD master** bulunmadı.
- Yeni temiz ve onaylı yüksek çözünürlüklü Orman background master geldiğinde generic artwork katmanından bağla ve raw Android 16 proof'u tekrar çalıştır.
- Kullanıcı açıkça “resim oluşturma, oyuna uygula” dediği için yeni generatif artwork üretme.

## Canonical gameplay ve release korumaları

- Grid: **8×8 / 64 hücre — LOCKED**.
- 6×10 tarihsel checkpointtir; geri dönmez.
- B5 60 sn, B10 120 sn soft challenge; hard-fail değildir.
- Minimum Kelime Avı yayın stoğu: **200 hazır/doğrulanmış bölüm**.
- 200/200 release-stock gate ve runtime/fiziksel kabul tamamlanmadan yeni Kelime Avı production release'i Play'e yüklenmez.
- Son production sürüm kaydı: **1.68.20+110**; yeni sohbette release HEAD/sürümü canlı doğrula.

## Yeni sohbette önerilen devam sırası

1. Bu dosya + `KARARLAR.md` + `DEVRALMA_1_AYLIK_GPT.md` dosyalarını oku.
2. PR #198'i canlı fetch et; OPEN/DRAFT/unmerged ve exact HEAD'i doğrula.
3. Son exact HEAD'in route-catalog, Android 16 visual proof ve AdMob/release workflow durumlarını doğrula.
4. Progression/catalog mantığını tekrar kurcalama; owner kararları tamamlandı ve testli.
5. Görsel tarafta yalnız **temiz/onaylı gerçek yüksek çözünürlüklü Orman background master** bulunduğunda asset değiştir.
6. Asset değişirse fresh state `1 açık / 2–10 locked` kalmalı ve raw Android 16 proof tekrar PASS olmalı.
7. Kullanıcı ayrıca açıkça onay vermeden PR Ready/merge yapma.

**DEVİR SON DURUMU:** PR #198 OPEN/DRAFT/unmerged / production catalog = Başlangıç Limanı → Gökyüzü Adaları → Orman Yolu / Gökyüzü 18 yıldız kapısı değişmedi / Orman yalnız Başlangıç Limanı B10 completion ile açılır / Orman fresh state 1 açık 2–10 locked / strict 1→2→…→10 progression kalıcı / son doğrulanmış product-test checkpoint `827643972fc991cb63c594dc2e326d03594b2a71` üzerinde route catalog 12/12 PASS + Android 16 visual proof SUCCESS + AdMob/release Android gate SUCCESS / mevcut Orman artwork 200×400 ve final HD değil / temiz onaylı gerçek HD background master bekleniyor / merge ve Play yok.
