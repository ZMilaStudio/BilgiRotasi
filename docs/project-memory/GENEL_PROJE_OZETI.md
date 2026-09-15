# Bilgi Rotası — Genel Proje Özeti

**Son güncelleme:** 15 Eylül 2026

## YENİ SOHBET DEVİR NOTU — ÖNCE BUNU OKU

Yeni sohbette işe başlamadan önce şu sırayı uygula:

1. Bu dosyanın tamamını oku: `docs/project-memory/GENEL_PROJE_OZETI.md`.
2. Son sohbet devrini oku: `docs/project-memory/SOHBET_DEVIR_2026-09-15_ORMAN_YOLU_TEMIZ_ASSET_ENTEGRASYONU.md`.
3. `docs/project-memory/KARARLAR.md`, `docs/project-memory/KARAR_2026-09-14_ORMAN_YOLU_UX.md` ve mevcutsa `docs/project-memory/DEVRALMA_1_AYLIK_GPT.md` dosyalarını oku.
4. Sonra canlı GitHub durumunu kendin doğrula: repo, branch, PR #198, exact HEAD, changed files ve GitHub Actions sonuçları.
5. Çelişki varsa öncelik: **canlı GitHub > proje bellek dosyaları > eski sohbetler**.

Repo: `ZMilaStudio/BilgiRotasi`  
Branch: `feat/kelime-avi-scenic-theme-depth-20260912`  
Base: `release/final-closed-test-aab-1.68.8`  
PR: **#198 — OPEN / DRAFT / unmerged**.

**Çok önemli:** Bu devir hazırlanırken ürün/runtime kodunun son gerçek baseline commit'i `ec0b501b7c9d05af03d273000a48af88e4a4bd3c` idi. Bu dosyaları güncellemek için bunun üstüne yalnız dokümantasyon commit'i eklenebilir. Yeni sohbette PR HEAD'i canlı fetch et; docs-only HEAD ile runtime baseline'ı birbirine karıştırma.

## Kalıcı çalışma ve owner kuralları

- PR #198 kullanıcı ayrıca açıkça onay vermeden **Ready yapılmaz, merge edilmez, release/Play adımı başlatılmaz**.
- Her görev başında branch, HEAD, PR ve CI canlı GitHub'dan yeniden doğrulanır.
- Build PASS tek başına yeterli değildir; diff + test + workflow + **gerçek Android runtime** kanıtı birlikte değerlendirilir.
- Mockup/ImageGen final runtime kanıtı değildir. Kullanıcı final doğrulamada yalnız gerçek emulator/build ekranlarını kabul eder.
- `assets/questions.json`, 67-node BoardMap, Firebase, signing, version ve Play kapsam dışıdır; açık izin olmadan dokunma.
- **Orman 1 kullanıcı tarafından “Orman 1 tamam” denmeden tamamlanmış sayılmaz. Orman 2 pilotuna başlanmaz.**

## Kelime Avı — kanonik progression ve catalog

- Her 10-bölümlük rotada fresh progress: yalnız **Bölüm 1 açık/current**, Bölüm 2–10 locked.
- Sıralı unlock: `1→2→3→4→5→6→7→8→9→10`.
- Ortak motor `WordHuntRouteProgressEngine.isLevelUnlocked`; tema/artwork progression mantığını değiştiremez.
- Production catalog: **Başlangıç Limanı → Gökyüzü Adaları → Orman Yolu**.
- Gökyüzü kapısı: Başlangıç Limanı'ndan 18 yıldız; değişmedi.
- Orman kapısı: yalnız Başlangıç Limanı **Bölüm 10 tamamlandığında** açılır. B1–B9 tamam + 27 yıldız tek başına yetmez.

## Orman Yolu — onaylı UX / geometri kararları

Detaylı karar: `docs/project-memory/KARAR_2026-09-14_ORMAN_YOLU_UX.md`.

- Mevcut yön korunur: **Bölüm 1 üstte, Bölüm 10 altta**.
- Mevcut zig-zag node anchor geometrisi değiştirilmez.
- Node görsel ölçüsü owner onayıyla küçültülmüştür; görünmez rahat touch/hitbox alanları korunur.
- Bölüm 10 final kimliği özel kalır:
  - locked: prestige/taç çerçevesi + merkez kilit + gri/pasif yıldızlar,
  - unlocked: 10 + aktif altın final,
  - completed: gerçek oyuncu yıldızları.
- Üst yeşil-altın panel kompakt; geri/bilgi görsel boyutu küçültülmez.
- Pusula scroll/kamera yapmaz; yalnız sıradaki oynanabilir node'u kısa pulse/highlight ile vurgular.
- Kitap = bölüm konusu bilgisi. Sağ üst `i` = genel harita kullanım rehberi.
- **MEYDAN OKUMA** tabelası dekoratif environment öğesidir, interaktif değildir.
- Açılış animasyonu kısa fade + çok hafif depth, 1 saniyenin altında, bounce yok.
- SafeArea ve touch target korunur; final node ile pusula/kitap alanı çakışmamalıdır.
- Test ekranındaki `0/30` veya örnek yıldızlar gameplay bug varsayılmaz; veri sistemi tahminle değiştirilmez.

## 15 Eylül 2026 — kritik raster teşhisi

Orman production raster'ı doğrudan APK/runtime asset zincirinden açılıp incelendi. Mevcut `orman_yolu_scene_00.b64 ... orman_yolu_scene_06.b64` birleşimi **941×1672 WebP** olmakla birlikte temiz environment değildi; eski tam UI kompozisyonu raster pikseline bake edilmişti.

Eski raster'ın içine gömülü olduğu doğrulanan öğeler:

- eski geri ve bilgi butonları,
- büyük header kartı,
- `KELİME AVI`, `Orman Yolu`, header yaprakları, yıldız simgesi ve eski `21/30`,
- level 1–10 node görselleri,
- level numaraları ve kilit ikonları,
- final node, taç ve `10`,
- bütün eski yıldız sıraları,
- alt soldaki pusula ve alt sağdaki kitap,
- ayrıca environment parçası olarak taş rota/patika ve MEYDAN OKUMA tabelası.

Flutter aynı UI öğelerinin çoğunu canlı olarak tekrar çizdiği için header/node/yıldız/pusula/kitap ghosting ve double-image oluşuyordu. Tall ambient da aynı eski raster'ı kullandığı için blur altında eski UI izleri taşıyabiliyordu. **Kök neden widget hizası değil, UI-bake edilmiş raster'ın production environment olarak kullanılmasıydı.**

## Owner tarafından onaylanan temiz Orman environment source

Temizleme sonrası owner **ham temiz 941×1672 Orman environment asset'ini onayladı**.

Konuşma çalışma alanında doğrulanmış dosyalar:

- `ORMAN_ENVIRONMENT_CLEAN_ROUTE_941x1672.png` — 941×1672
- `ORMAN_ENVIRONMENT_CLEAN_ROUTE_941x1672.webp` — 941×1672
- `ORMAN_ROUTE_ANCHOR_DEBUG_941x1672.png` — yalnız doğrulama overlay'i, production asset değildir
- `ORMAN_ENVIRONMENT_DIMENSION_PROOF.txt`
- `ORMAN_ENVIRONMENT_941x1672_PACKAGE.zip`

Temiz environment içinde **korunacaklar**:

- doğal Orman sahnesi,
- ağaçlar, şelale/su, kayalar, bitki örtüsü, ışık,
- köprü ve çevresel dekorlar,
- **1→10 taş rota/patika**,
- **MEYDAN OKUMA** tabelası.

Temiz environment içinde **bulunmayacaklar**:

- eski header/back/info,
- eski node 1–10,
- numaralar/kilitler,
- eski yıldızlar,
- final node/taç/10,
- eski pusula/kitap,
- bunların halo/gölge/çerçeve kalıntıları.

Node-anchor debug doğrulamasında mevcut canlı anchor noktaları temiz environment üstüne bindirildi; 1→10 taş rota bağlantılarının anchor akışıyla korunduğu kontrol edildi. Debug overlay final asset'e dahil edilmeyecek.

## Hedef production mimarisi — bağlayıcı

Bir sonraki kod adımı budur; başka redesign yapma:

1. **Foreground environment:** yalnız yeni temiz 941×1672 Orman asset'i.
2. **Canlı Flutter UI:** header, geri/bilgi, node 1–10, kilitler, numaralar, yıldızlar, final node, pusula ve kitap yalnız Flutter tarafından **bir kez** çizilir.
3. **Tall ambient:** gerekirse yalnız aynı yeni temiz environment asset'i kaynak olur. Eski UI-bake raster kesinlikle ambient kaynağı olamaz.
4. Taş rota temiz environment içinde bulunduğu için mevcut Orman live route painter **kapalı kalır**.
5. `WordHuntRouteMapGeometry.normalizedStops`, node anchor'ları ve hitbox düzeni **değişmez**.
6. Eski `orman_yolu_scene_00...06` UI-bake composite üretim runtime seçiminden tamamen çıkarılır. Tarihsel/test amaçla tutulursa production runtime'dan erişilemez olmalıdır.

## Entegrasyon henüz tamamlanmadı — kritik devir durumu

Kullanıcı temiz asset'i onayladı ve koda entegrasyon talimatını verdi, ancak bu sohbet sonunda **entegrasyon tamamlanmış/push edilmiş değildir**.

- Runtime/game-code baseline: `ec0b501b7c9d05af03d273000a48af88e4a4bd3c`.
- Temiz asset'i Base64/runtime parçalarına hazırlamak için yerel çalışma yapıldı; bazı Git blob hazırlıkları denenmiş olabilir.
- **Bunlar production branch'te tamamlanmış bir clean-asset commit anlamına gelmez.**
- Yeni sohbette hiçbir yarım blob'u “entegre edildi” sayma; önce canlı branch diff/HEAD'i doğrula.

`ec0b501...` üzerinde eski baked raster ile şu exact-head kontroller PASS olmuştu:

- Route Catalog ✅
- Android 16 ana proof ✅
- 3 ekran boyutu Android proof ✅
- AdMob exact-head ✅

Ancak bu görsel checkpoint **final kabul değildir**, çünkü baked eski UI raster hâlâ runtime zincirindeydi.

## Yeni sohbette sıradaki uygulama

1. `GENEL_PROJE_OZETI.md` ve `SOHBET_DEVIR_2026-09-15_ORMAN_YOLU_TEMIZ_ASSET_ENTEGRASYONU.md` dosyalarını oku.
2. PR #198 ve branch exact HEAD'i canlı doğrula. Docs-only handoff commit'i varsa runtime baseline'ın hâlâ `ec0b501...` olduğunu ayır.
3. Onaylı temiz 941×1672 environment asset'ini repo/runtime'a ekle.
4. `WordHuntRouteVisualThemes.ormanYolu` ve ilgili asset seçimini yalnız temiz environment'a geçir.
5. Eski UI-bake `orman_yolu_scene_00...06` dosyalarının foreground/ambient production runtime tarafından yüklenmediğini kod + manifest + runtime seçimi düzeyinde doğrula.
6. Tall ambient yalnız temiz source'u kullansın ve foreground içine taşarak ghosting üretmesin.
7. Live route painter kapalı, node anchor geometrisi değişmeden kalsın.
8. Tek/temiz exact-head entegrasyon commit'i üret.
9. Exact-head için Route Catalog + Android 16 ana proof + 3 ekran boyutu + AdMob doğrulamalarını çalıştır.
10. **Yalnız gerçek Android 16 emulator/build** PNG'lerini üret:
    - 720×1280
    - 1080×1920
    - 1080×2400
11. Üçünü görsel olarak kontrol et: ikinci header yok, eski node/yıldız izi yok, pusula/kitap çiftlenmiyor, rota tek katman, node'lar taş rota anchor'larıyla uyumlu, ambient eski UI taşımıyor, tall seam/transition temiz.
12. Görselleri kullanıcıya getir ve **orada dur**. Kullanıcı onayı olmadan Ready/merge yok; Orman 2 yok.

## Canonical gameplay/release korumaları

- Grid: **8×8 / 64 hücre — LOCKED**.
- 6×10 tarihsel checkpointtir; geri dönmez.
- B5 60 sn, B10 120 sn soft challenge; hard-fail değildir.
- Minimum Kelime Avı yayın stoğu: **200 hazır/doğrulanmış bölüm**.
- 200/200 release-stock gate ve runtime/fiziksel kabul tamamlanmadan yeni Kelime Avı production release'i Play'e yüklenmez.

**DEVİR SON DURUMU:** PR #198 OPEN/DRAFT/unmerged / runtime baseline `ec0b501b7c9d05af03d273000a48af88e4a4bd3c` / baked eski UI raster kök neden olarak doğrulandı / owner temiz 941×1672 environment asset'ini onayladı / taş rota + MEYDAN OKUMA temiz asset'te kalıyor / clean-asset production entegrasyonu henüz tamamlanmadı / sıradaki iş yalnız temiz asset'i foreground+ambient runtime'a bağlayıp eski baked raster'ı production zincirinden çıkarmak ve üç gerçek Android boyutunda exact-head kanıt üretmek / PR merge yok / Orman 2 yok.
