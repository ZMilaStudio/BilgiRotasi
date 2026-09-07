# Bilgi Rotası — Genel Proje Özeti

**Son güncelleme:** 7 Eylül 2026 — Kelime Avı V9 devir noktası. V8/V9 gameplay ve görsel kabul zinciri korunuyor. Gökyüzü Adaları görsel yönü Levent tarafından PASS kabul edildi; runtime entegrasyonu sonrası Android16 raw screenshot/crash/ANR ve gerçek cihaz görsel kabulü zorunlu. 1.68.20+110 production AAB üretildi ancak **Kelime Avı içerdiği için Play Console'a yüklenmeyecek**. Kelime Avı için yeni yayın eşiği **minimum 200 hazır/doğrulanmış bölüm** olarak kilitlendi. PR #180, 20 bölümden minimum 200 bölüme ölçeklenebilir içerik üretim hattını eklemek üzere OPEN/DRAFT durumda. WORK V2 aktif.

> Teknik doğrulukta tek kanonik kaynak canlı `ZMilaStudio/BilgiRotasi` deposu ve ilgili canlı servislerdir. Bu dosya canlı branch/PR/CI/pubspec doğrulamasının yerine geçmez. Ayrıntılı eski üretim günlükleri Git geçmişinde ve `docs/project-memory/archive/` altında korunur.

## Kalıcı Çalışma Kuralı

- Her görev başında canlı hedef branch, `pubspec.yaml`, son commit, PR ve CI yeniden doğrulanır.
- `main` güncel/yayın kaynağı varsayılmaz.
- Sıra: branch → test → commit → push → PR → inceleme → merge.
- Kritik merge/release yalnız Levent'in açık onayıyla yapılır.
- Build PASS tek başına kanıt değildir; diff, test, workflow, log, Git geçmişi ve gerçek runtime kanıtı birlikte değerlendirilir.
- Görsel kabul yalnız gerçek/raw Android runtime üzerinden verilir; ImageGen/mockup/QA selector kabul kanıtı değildir.
- `assets/questions.json` kontrolsüz değiştirilmez; ilgisiz değişiklikler silinmez.
- Codex yalnız mevcut araçlarla yapılamayan zorunlu yerel kod/test işi olduğunda kullanılır; gereksiz Codex kredisi harcanmaz.
- Kullanıcı açıkça dur dediğinde üretim/merge/release adımı başlatılmaz; durum özeti ve sohbet devri hazırlanır.

## Canlı Release Hattı

- Repo: `ZMilaStudio/BilgiRotasi`.
- Canonical release branch: `release/final-closed-test-aab-1.68.8`.
- Son doğrulanmış canonical release HEAD: **`a43d85eae86eac335c7e09a832152667ba608c53`**.
- Son production sürümü: **1.68.20+110**.
- Paket: `com.leventua.bilgirotasi`.
- PR #179 sürüm/AppBuildInfo senkronizasyonunu canonical release'e taşıdı.
- Production workflow run `34050183031`: **SUCCESS**; gerçek production AAB + universal APK üretildi ve GitHub Release `v1.68.20+110` oluşturuldu.
- AAB SHA256: `2bfac3fb5642ba10c57d5f58acb158fdb2eede9210b9a8777d786f884d9cb66d`.
- APK SHA256: `710e3c1025a41c6ca2a2c930dede4794ac9ef77ef7cf6e25fea6313b1323c8e3`.
- **Play Console'a yükleme/yayınlama yapılmadı.** Kullanıcı kararı: Kelime Avı içeren bu AAB kesinlikle Play'e yüklenmeyecek.

## Başlangıç Limanı — Bağlayıcı Mimari

- İlk rota/paket: **Başlangıç Limanı**.
- Rota hedefi: 10 bölüm / 30 yıldız.
- Issue #109 `Photo 1.jpg` rota ekranı için bağlayıcı görsel kaynaktır.
- Production rota tabanı: MASTER ART raster + şeffaf hitbox + minimum lokal runtime-state override.
- Level 7 tamamlanınca bonus 8 ve normal 9 birlikte açılır; bonus 8, 9 için gate değildir; 10, node 9 tamamlanmadan locked/no-callback.
- BoardMap / 67 node sözleşmesi kontrolsüz değiştirilmez.

## Canonical Gameplay Sözleşmesi

- Grid: **8×8 / 64 hücre — LOCKED**.
- Önceki 6×10 yalnız tarihsel checkpointtir; ürüne geri dönmez.
- Target+bonus eğrisi: B1 5+1, B2 5+1, B3 6+1, B4 6+1, B5 7+1, B6 7+1, B7 8+1, B8 7+2, B9 9+1, B10 9+1; toplam **80**.
- Her target/bonus 8 düz yönde exactly-one fiziksel occurrence taşır; ters gesture aynı canonical kelimeye çözülür.
- B8 bonusları `HIZ` + `SKOR`; B9 bonus `ROKET`; B10 hedef `YOL`, bonus `HAZİNE`.
- B5 60 sn ve B10 120 sn soft challenge; hard-fail değildir.
- Engine/path/scoring/timer/progression sözleşmesi görsel tema uğruna değiştirilmez.

## V5 / V6 Ürün Kabulü — PASS

- V5 approved raster + dinamik Flutter text/state + canonical 8×8 engine mimarisi korunur.
- Found-state Android16: **PASS**.
- Error-state Android16: **PASS**.
- Completion/result davranışı: **PASS**.
- B5 tuning sonrası insan testi: **32 sn**, süre PASS.
- Swipe false-positive toleransı Android16: gerçek `ANKARA + 1 trailing hücre` → `1/7`, hata `0`, PASS.

## Release Merge Zinciri — TAMAMLANDI

- PR #167 — MERGED → `c5d57e98866e244fdf36d5e7b6ad4684c5f935f4`.
- PR #163 — MERGED → `806c4bfc01f2ab9211a2684bff36f76a82e4ac8d`.
- PR #162 — MERGED → `929bb13177e03a0962464e21f6c174d4b3439349`.
- PR #161 — MERGED → `4aa490e7c2d5e7547dc95f9463dbbb9adeb85e5a`.
- PR #158 — MERGED → `189864c92a605e7bb960460300714049c730ea39`.
- PR #169 — MERGED → `0c84aefd8a5ef591aaaab9eaa30bed2e044190cf`.
- PR #179 — MERGED → `a43d85eae86eac335c7e09a832152667ba608c53`.
- PR #166 tarihsel geliştirme/QA hattıdır; merge edilmeyecektir.

## Production Ana Navigasyon — CANONICAL

- Bilgi Rotası production **Oyna** menüsüne `Kelime Avı` kartı eklendi.
- Kart `WordHuntProductionEntryScreen` üzerinden `WordHuntReferenceRouteScreen` production rotasına açılır.
- Açık rota node'u `WordHuntLevelProductionScreen` gameplay ekranını açar.
- İlerleme `WordHuntProgressCodec` ile Firebase UID / guest scope'una göre `SharedPreferencesAsync` üzerinde cihazda saklanır.
- Başka hesap scope'una ait veri fail-closed reddedilir; bozuk/eski veri oyunun açılmasını engellemez.
- Bölüm sonucu mevcut `WordHuntProgressSnapshot` sözleşmesiyle best yıldız ve açılan bilgi kartlarını kaydeder.
- Geri / bilgi / pusula / kitap callbackleri production davranışına bağlıdır.

## Gökyüzü Adaları — V9 GÖRSEL YÖNÜ LOCKED/PASS

- Paket adı: **Gökyüzü Adaları**.
- Görsel yön: **C — Neşeli & Parlak**.
- Rota: 10 bölüm.
- Modüler asset mimarisi ve rota mock V2 statik görsel yönü: **LOCKED/PASS**.
- Levent'in son görsel kabulü: adacıklar için yalnız tema ile uyumlu boş/tematik arka plan kullanılacak; arka plan gameplay/UI yerine geçmeyecek.
- Telefon ekranına göre kompozisyon yapılacak; üst/alt gereksiz boşluk bırakılmayacak, yalnız altta banner reklam için gereken alan bırakılacak.
- Rota ekranında 8–9–10 arasında kullanıcı tarafından fark edilen gereksiz kilit + 3 yıldız işareti kaldırıldı; son kabul bu düzeltmeyi içeriyor.
- **Raw Android runtime görsel PASS henüz yok.** Flutter entegrasyonu sonrası Android16 raw screenshot + crash/ANR/log kanıtı ve gerçek cihaz görsel kabulü zorunlu.

## Gökyüzü Adaları Runtime Asset Paketi

- Runtime sözleşmesi: **41 core + 7 opsiyonel island variant = 48 WebP**.
- ZIP boyutu: **557.120 bayt**.
- Zorunlu SHA256: `d219c6233fa27f5e3e04687ec5fd15dab1f24500584e78d6a7c80036ee68f5ca`.
- Alpha/file QA: **PASS**.
- Bu QA, raw Android görsel PASS değildir.
- Firestorage aktarım dosyası: `gokyuzu_transfer_chunks18_native`.
- Firestorage public/share bilgileri tarihsel aktarım kanıtıdır; retention süreli olduğundan final ürün kaynağı değildir.
- Eski `.transfer`, raw8, v5 ve eski materialize yöntemleri final ürün geçmişi olarak kullanılmayacak.

## Gökyüzü Adaları İçerik Paketi

- 10 bölüm / toplam 80 target+bonus canonical 8×8 içerik hazır.
- PR #171 `feat(kelime-avi): add Gokyuzu 8x8 content pack` **OPEN/DRAFT** olarak tarihsel içerik paketi hattıdır; merge/Ready yapılmayacak.
- Exact içerik HEAD: `4ec33de7438fcbd15ed63b1ae2adda127da3be8c`.
- Bu paket mevcut 20 bölümlük yayın stoğunun parçasıdır; yeni 200-bölüm üretim hattıyla karıştırılmamalıdır.

## Kelime Avı V9 — 200 BÖLÜM YAYIN EŞİĞİ

### Kalıcı karar

- Mevcut Kelime Avı stoğu: **20 bölüm**.
- Kullanıcı kararı: 20 bölüm yayın için yetersiz; kullanıcıların bir günde bitirmesi olası.
- **Minimum yayın stoğu: 200 hazır/doğrulanmış bölüm.**
- Tercih edilen güvenli yayın stoğu: 200–300 bölüm.
- Kelime Avı, bu 200 bölüm eşiği oluşmadan Play'e çıkarılmayacak.
- 1.68.20+110 AAB Kelime Avı içerdiği için Play'e yüklenmeyecek.

### PR #180 — ölçeklenebilir üretim hattı

- PR: **#180 — `feat(kelime-avi): add 200-level content production pipeline`**.
- Durum: **OPEN / DRAFT / mergeable=true / merged=false**.
- Base: `release/final-closed-test-aab-1.68.8` @ `a43d85eae86eac335c7e09a832152667ba608c53`.
- Current PR HEAD: **`618404e281bca91cdd2e9eb03761f47784690353`**.
- PR merge edilmedi.
- Amaç: bölüm-bölüm el işçiliğini bırakıp deterministik toplu üretim + otomatik doğrulama hattına geçmek.

### PR #180 kapsamı

- `tools/word_hunt_batch_generator.py`
  - canonical 8×8 grid,
  - yatay/dikey/çapraz + ters yön,
  - deterministic seed,
  - target/bonus validation,
  - exact-one physical occurrence gate,
  - 200 bölüm release-stock gate.
- `tools/word_hunt_content_factory.sample.json`.
- `.github/workflows/word-hunt-content-factory.yml`.
- `docs/project-memory/KELIME_AVI_200_BOLUM_URETIM_HATTI_2026-09-06.md`.
- Protected scope: `assets/questions.json`, BoardMap/67 node, Firebase, AdMob, signing, package/version, Play release.
- PR #180 Play yüklemez, runtime katalog eklemez ve production sürüm değiştirmez.

### 200 bölüm üretim hedefi

- Mevcut: **20 bölüm**.
- Yeni hedef: **18 yeni rota × 10 bölüm = 180 bölüm**.
- Toplam hedef: **200 bölüm minimum**.
- Üretim birimi: 10 bölümlük rota/paket.
- Bölüm başına ayrı branch/Android Action/APK/insan testi yapılmayacak.
- Her bölüm otomatik 8×8, kelime sayısı, exactly-one occurrence, yön, reverse gesture, timer/yıldız ve render kapılarından geçecek.
- İnsan denge örneklemesi varsayılan B1 + B5 + B10; otomatik outlier varsa yalnız ilgili ek bölüm oynanacak.
- Android16 tam runtime paket tamamlanınca, engine/ortak UI değişiminde ve release entegrasyonu öncesinde çalışacak.

### Üretim hattında son durum

- PR #180'un ilk altyapı CI turu yeşil kabul edildi ve 180 yeni bölüm için toplu manifest üretimi hazırlığına geçildi.
- Son çalışma HEAD'i `618404e281bca91cdd2e9eb03761f47784690353`.
- Exact HEAD için CI durumları sohbet durdurulduğu anda takip ediliyordu; **yeni sohbette canlı GitHub'dan yeniden doğrulanmalı**.
- Üretim manifestinde 18 temalı rota için 10'ar bölüm hedeflendi: Orman Yolu, Deniz Koyu, Dağ Geçidi, Çöl Vahası, Kış Ülkesi, Bahar Bahçesi, Gece Şehri, Uzay Üssü, Antik Kent, Gizemli Laboratuvar, Müzik Adası, Spor Vadisi, Mutfak Sokağı, Masal Ormanı, Teknoloji Kenti, Tarih Yolu, Bilim Koyu, Hazine Adası.
- Bu isimler/kelime havuzları üretim taslağıdır; **oyuna veya canonical içerik dosyasına merge edilmiş değillerdir**.
- Yeni sohbette önce PR #180 exact HEAD, CI ve değişen dosyalar doğrulanmalı; yeşil olmayan/eksik kapı varsa üretim commit'i veya merge yapılmamalı.

## Docs-only / eski checkpoint PR'ları

- PR #168 tarihsel docs-only checkpoint olarak kalmıştır; eski release-context bilgileri yeni V9 durumuyla karşılaştırılmadan kanonik kabul edilmez.
- PR #171 Gökyüzü Adaları 8×8 içerik paketi: OPEN/DRAFT; Ready/merge yok.
- PR #175 Gökyüzü Adaları runtime asset hattının tarihsel görsel kabul checkpoint'idir; raw Android fiziksel kabul kapısı ayrı kalır.

## Ölçeklenebilir Üretim/Test — KALICI KARAR

- Temel üretim birimi 10 bölümlük rota/pakettir.
- Bölüm başına ayrı branch/Android Action/APK/insan testi yapılmaz.
- Her bölüm otomatik 8×8, kelime sayısı, exactly-one occurrence, yön, reverse gesture, timer/yıldız ve render kapılarından geçer.
- İnsan denge örneklemesi varsayılan B1 + B5 + B10; otomatik outlier varsa yalnız ilgili ek bölüm oynanır.
- Android16 tam runtime paket tamamlanınca, engine/ortak UI değişiminde ve release entegrasyonu öncesinde çalışır.
- Amaç, 10 bölüm/hafta gibi ölçeklenmeyen manuel üretim yerine tek üretim bloğunda çoklu rota/bölüm üretip makinece doğrulamaktır.

## WORK V2 — AKTİF

- Mikro değişiklik → tam test → rapor → bekleme döngüsü kullanılmaz.
- İlişkili işler mümkün olan en büyük mantıklı üretim bloğunda tamamlanır.
- Çözülebilen hata/fixture/test sorunları kullanıcıyı test operatörü yapmadan giderilir ve yeniden doğrulanır.
- Kullanıcı ürün yönü, gerçek görsel/fiziksel kabul ve Ready/merge/release kararlarında devreye girer.

## Reference Font

- Runtime `fontFamily: 'serif'` kullanır.
- Repo içinde exact custom font kaynağı yoktur.
- `REFERENCE_FONT = DOĞRULANACAK / DEFERRED`; spekülatif font değişikliği yapılmaz.

## Korunan Alanlar

- `assets/questions.json` kontrolsüz değiştirilmez.
- BoardMap / 67 node değiştirilmez.
- Canonical 8×8 / 64 hücre sözleşmesi korunur.
- Firebase / AdMob / release signing değişiklikleri ayrı scope gerektirir.
- Package name korunur.
- Play yükleme/yayınlama, Kelime Avı yayın stoğu ve kullanıcı onayı olmadan yapılmaz.

## Kalan Aktif Sıra — V9 BURADAN DEVAM ETSİN

1. Yeni sohbette canlı GitHub'dan canonical release branch, HEAD, `pubspec.yaml`, açık PR'lar ve CI yeniden doğrula.
2. PR #180 exact HEAD `618404e...` ve CI durumunu kontrol et.
3. PR #180'un 200-bölüm üretim hattını güvenli biçimde tamamla; mevcut 20 bölümü koru.
4. 18 yeni rota × 10 bölüm = 180 yeni bölümü deterministik üretim + otomatik QA ile hazırla.
5. 200/200 release-stock gate PASS olmadan Kelime Avı runtime katalog/release entegrasyonuna geçme.
6. Yeni içeriklerin görsel/runtime entegrasyonu gerekiyorsa önce ürün içi görsel kabul, sonra Android16 raw runtime, sonra gerçek cihaz kabulü yap.
7. Gökyüzü Adaları runtime asset entegrasyonu için 48 WebP gate'lerini ve exact SHA'yı koru; raw Android görsel PASS'i ayrıca al.
8. Kelime Avı içeren `1.68.20+110` AAB **Play'e yüklenmeyecek**.
9. Yeni Kelime Avı production AAB ancak minimum 200 doğrulanmış bölüm ve gerekli runtime/fiziksel kabul kapıları tamamlandıktan sonra üretilecek.
10. Play Console yükleme/yayınlama için ayrıca Levent'in açık onayı gerekecek.

**SON DURUM:** Başlangıç Limanı 8×8 LOCKED / V5-V6 gameplay PASS / Gökyüzü Adaları görsel yönü PASS + raw Android DEFERRED / production navigasyon canonical / `1.68.20+110` AAB üretildi ama Kelime Avı nedeniyle Play'e YÜKLENMEYECEK / minimum yayın stoğu 200 bölüm / PR #180 OPEN+DRAFT / current PR HEAD `618404e281bca91cdd2e9eb03761f47784690353` / 20 mevcut + 180 yeni hedef / WORK V2 AKTİF / Play YAYINI YOK.