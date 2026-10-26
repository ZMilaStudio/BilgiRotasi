# ZMila Studio Görsel Oyun Üretim Standardı — Kelime Avı

Bu dosya **Kelime Avı için bağlayıcı görsel üretim kuralıdır**. Yeni bir sohbet, Codex görevi veya geliştirici çalışması başlamadan önce bu dosya okunmalıdır.

## Ana kural

**REFERENCE → PRODUCTION-READY LAYERED ASSETS → THIN INTERACTION CODE**

Onaylı referans görsel kodla yeniden çizilmeye çalışılmayacak.

> **Motor resmi yapmayacak; resmi oynatacak.**

Referans görsel, açıkça aksi söylenmedikçe yalnızca ilham/konsept değildir; bağlayıcı görsel kalite hedefidir.

## Nihai görselde yapılmayacaklar

- `CustomPainter`, Dart Canvas veya benzeri procedural çizimlerle taç, sandık, madalyon, tabela, süslü çerçeve, ikon, dekor, premium UI vb. yeniden üretmeye çalışma.
- Onaylı referansı kodla yaklaşık olarak taklit edip teknik testleri görsel kabul yerine koyma.
- Sadece koordinat/geometri testleri geçti diye ekranı görsel olarak tamamlanmış sayma.
- Placeholder veya düşük kaliteli geçici çizimleri final art olarak bırakma.
- Çalışan oyun/progression altyapısını yalnız görsel sorun var diye sıfırdan yazma.

## Kullanılacak üretim yaklaşımı

Onaylı görsel, mümkün olduğunca gerçek production asset'lerine dönüştürülür:

- Ana sahne / çevre / atmosfer: yüksek kaliteli `WebP` veya `PNG`.
- Node varyantları: normal, kilitli, challenge, bonus, final vb. gerekiyorsa ayrı şeffaf asset.
- Taç, sandık, tabela/plaque, pusula, kitap, özel ikonlar, çerçeveler vb.: gerçek şeffaf asset.
- Rota statikse sahneye bake edilebilir; state'e göre değişmesi gerekiyorsa az sayıda kaliteli rota/segment overlay asset'i kullanılabilir.
- Dinamik bölüm numarası, yıldız sayısı, progression, gerçek kullanıcı verisi ve değişken metin kod tarafından yönetilir.

Kodun görevi:

- doğru asset'i doğru canonical koordinata yerleştirmek,
- state'e göre doğru varyantı göstermek,
- tıklama/gesture davranışını yönetmek,
- progression ve oyun mantığını yürütmek,
- animasyon ve geçişleri yönetmek,
- cihazlara doğru ölçeklemek.

## Kelime Avı için korunacak teknik kazanımlar

- Flutter + Dart mevcut mimarisi.
- 1080×1920 canonical coordinate-space yaklaşımı.
- Tek ortak scene transform / ölçekleme yaklaşımı.
- Mevcut progression ve bölüm mantığı.
- Çalışan interaction mantığı.
- Davranışsal ve regresyon testleri.
- Bilgi Rotası ana uygulamasının çalışan release yapısı.

Bunlar yalnızca görsel katman sorunlu diye çöpe atılmayacak.

## Başlangıç Limanı özel kuralı

Başlangıç Limanı için kullanıcı tarafından onaylanan referans **MASTER ART** kabul edilir.

Öncelikli production asset adayları:

- `baslangic_limani_scene.webp`
- `node_normal.webp`
- `node_locked.webp`
- `node_challenge.webp`
- `node_bonus.webp`
- `node_final.webp`
- `challenge_plaque.webp`
- `bonus_plaque.webp`
- `final_plaque.webp`
- `final_crown.webp`
- `compass_button.webp`
- `book_button.webp`
- gerekiyorsa route/route-glow state asset'leri

Dosya adları uygulama yapısına göre değişebilir; **asset-first yaklaşımı değişmez**.

## Görsel kabul kriterleri

Bir ekran ancak aşağıdakiler sağlandığında görsel olarak tamamlanmış sayılabilir:

1. Onaylı referansla ilk bakışta aynı görsel aile ve kalite düzeyinde olması.
2. Premium görünen ana öğelerin procedural taklit değil gerçek production asset olması.
3. Android gerçek cihaz screenshot'ının referansla yan yana incelenebilmesi.
4. Gameplay/progression davranışının bozulmaması.
5. Gerekli teknik testler ve CI'ın PASS olması.
6. **Son görsel kabulün kullanıcı tarafından verilmesi.** Teknik PASS tek başına görsel PASS değildir.

## PR / çalışma disiplini

- Mevcut branch ve açık PR'lar önce incelenir.
- Mevcut çalışma kaybedilmez.
- `main` dalına doğrudan yazılmaz.
- Değişiklik branch + Draft PR üzerinden yürütülür.
- CI/testler geçmeden merge edilmez.
- Kullanıcının açık onayı olmadan merge yapılmaz.

## Mevcut procedural çalışmalara yaklaşım

PR #110 ve benzeri çalışmalarda bulunan canonical transform, progression, geometry ve test kazanımları korunabilir. Ancak procedural olarak çizilen premium final-art katmanı **nihai görsel çözüm kabul edilmez**.

Örnek olarak `_FinalCrownPainter`, `_TreasureChestPainter`, `_FantasyPlaquePainter` gibi yapılar final görsel üretim yöntemi yerine production asset kullanımıyla değiştirilmelidir.

## İlk uygulanacak pilot

Tüm Kelime Avı'nı aynı anda dönüştürmeye çalışma.

Önce yalnızca **Başlangıç Limanı** ekranı bu asset-first yöntemle production-quality vertical slice olarak tamamlanır. Kullanıcı gerçek cihaz sonucunu onayladıktan sonra aynı sistem diğer paket ve ekranlara yayılır.

## Yeni sohbet / Codex başlangıç talimatı

Kelime Avı üzerinde çalışmaya başlamadan önce:

1. Repo kökündeki **`görsel oyun üretimstandartı.md`** dosyasını oku.
2. Mevcut proje özeti/karar dosyalarını ve açık PR/branch durumunu incele.
3. Bu dosyayla çelişen eski procedural-art yaklaşımını final çözüm olarak uygulama.
4. Görsel işi **reference → production asset → thin interaction code** sırasıyla yürüt.
