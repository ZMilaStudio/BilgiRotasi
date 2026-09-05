<!-- GOKYUZU_R7_ANDROID16_START -->
## GOKYUZU_R7_HUMAN_VISUAL — AÇIK
- Current ürün: PR #175 / `f35082c44e637cb7e6e3815c7d54d38a58b776df`.
- Android16 teknik kapı PASS: run `33972011069`, job `101322071661`; analyzer temiz; 39/39 regression PASS.
- Raw screenshot exact `1080×1920`; SHA256 `79edc57a575d2bdf59407260fe272993e69400a23d520687ac71680d58228637`; artifact `9971319096`.
- **DOĞRULANACAK:** Levent current R7 raw Android görünümünü görsel olarak kabul ediyor mu?
- Görsel PASS sonrası **DOĞRULANACAK:** gerçek cihaz APK fiziksel kabulü.
- **AÇIK:** PR #175 Ready/merge; ayrıca açık Levent onayı gerekir.
- **AÇIK:** Play yükleme/yayınlama; ayrıca açık Levent onayı gerekir.
- Exact `REFERENCE_FONT` kaynağı ayrı konu olarak **DOĞRULANACAK / DEFERRED** kalır.
<!-- GOKYUZU_R7_ANDROID16_END -->

<!-- GOKYUZU_R6_ANDROID16_START -->
## GOKYUZU_R6_HUMAN_VISUAL — AÇIK
- Current ürün: PR #175 / `560d76bd828e0b4d813218f1000b895da9d0c7fa`.
- Android16 teknik kapı PASS: run `33967506643`, job `101310099566` SUCCESS; 39/39 regression PASS.
- Raw screenshot exact `1080×1920`; SHA256 `2c4da0a1a22f443b65b5656d71d4ccfef983f0600ba6effcd3bc9e27dbe18e44`; artifact `9970009097`.
- **DOĞRULANACAK:** Levent current R6 full-width raw Android görünümünü görsel olarak kabul ediyor mu?
- PASS sonrası sıradaki kapı gerçek cihaz APK kabulüdür.
- PR Ready/merge ve Play görsel PASS ile otomatik yetkilendirilmez; ayrıca açık onay gerekir.
- Önceki `GOKYUZU_TALL_VIEWPORT_R3/R4` sorusu current R6 teknik çözümüyle supersede edilmiştir; tarihsel kayıt silinmez.
<!-- GOKYUZU_R6_ANDROID16_END -->

# Bilgi Rotası - Açık Sorular ve Canlı Doğrulamalar

> 29 Ağustos 2026 aktif kesimidir. Eski tam kayıtlar Git geçmişi ve `docs/project-memory/archive/` altında korunur.

## Kelime Avı Başlangıç Limanı 8×8 — TEKNİK PASS / CURRENT ANDROID GÖRSEL FAIL / KULLANICI KABULÜ AÇIK

29 Ağustos 2026 kullanıcı kararıyla starter-content grid standardı **8×8** oldu; önceki 6×10 geometrisi yeni ürün hattı için superseded edildi.

Current exact-reference çalışma:
- Branch: `feat/kelime-avi-v5-reference-assets-integration-20260831`.
- Product integration commit: `50ab6c8da3a4d6683568c71d52f893c5dfe2e9f7`.
- Draft PR **#161** — OPEN / DRAFT / merged=false; base `feat/kelime-avi-8x8-content-v1-20260829` / `5362c094...`.
- Parent Draft PR **#158** — OPEN / DRAFT / merged=false / mergeable=true; release base `release/final-closed-test-aab-1.68.8` / `3a0f722a...`.
- Sürüm `1.68.19+109`.

Current exact-reference doğrulamaları:
- [x] 11 production raster asset kullanıcı görsel QA ile LOCKED/PASS ve exact SHA-256 ile branch'e alındı.
- [x] `icon_anchor.png` / `icon_compass.png` ayrı production overlay olarak kullanılmıyor.
- [x] Canonical gameplay grid **8×8 / LOCKED / UNCHANGED**; assetlerde grid bake değil.
- [x] Integration run `33379341765` SUCCESS: asset SHA, deterministic presentation patch, format, analyze, 138/138 focused test, diff/protected-scope gate PASS.
- [x] Exact product SHA `50ab6c8...` için gerçek Android 16 B10 initial runtime screenshot üretildi: run `33384781507`, artifact `9755405253`, API36 / 1080×1920 / 420 dpi.
- [x] Gerçek Android found-state kanıtı artifact `9756762383`: `09_B10_YOL_FOUND.png` içinde `1/9`, Y-O-L found state ve gesture visual-change `changed_pixels=29970` PASS.
- [ ] **GERÇEK ANDROID GÖRSEL KABUL:** mevcut runtime kullanıcı tarafından FAIL edildi.

**KRİTİK KANIT DÜZELTMESİ:** Daha önce kullanıcıya “bulunmuş Android görseli” diye gösterilen ve PASS alınan Görsel 1 gerçek Android runtime screenshot değildi; gerçek Android ekranı üzerinde görsel düzenleme ile oluşturulmuş hedef/mockup idi. Bu yüzden o PASS geçersizdir ve runtime visual acceptance olarak kullanılamaz. Kullanıcının son mesajındaki Görsel 1 yalnız **bağlayıcı hedef/reference**, Görsel 2 ise **gerçek Android runtime ve FAIL** olarak sınıflandırılır.

**ÖNEMLİ RUN SINIRI:** run `33388386388` genel sonucu FAILURE'dır; screenshot ve real-gesture visual-change PASS sonrasında exact log-string `grep` assertion'ı exit 1 vermiştir. Bu run workflow SUCCESS diye yazılmayacak. Ayrıca runtime davranışı teknik olarak çalışsa bile görsel kullanıcı kabulü ayrı kapıdır ve şu an FAIL'dir.

8×8 temel teknik sözleşme korunur:
- 10 adet 8×8 grid ve 80 toplam target+bonus.
- Her canonical kelime exactly-one physical straight-line occurrence.
- Intended/opposite canonical yol eşleşmeleri.
- B5/B10 yatay+dikey+çapraz yön aileleri.
- B8 `HIZ`+`SKOR`, B9 `ROKET` ve `AY` yok, B10 `YOL`+`HAZİNE` ve `ROTA` yok.
- Önceki final teknik run `33251736068`: SUCCESS; 37/37 focused + 442/442 full suite + Android 16 B1/B5/B8/B10 64/64 + B5 soft-time + ANKARA/ters BAŞKENT swipe PASS.

**DOĞRULANACAK — KALANLAR:**
1. Gerçek Android runtime ekranı, kullanıcının bağlayıcı Görsel 1 hedefiyle yerleşim/ölçek/panel-plaque ölçüleri/grid aralıkları/found-state/alt panel bakımından nasıl exact-reference seviyesine getirilecek?
2. Düzeltmeden sonra raw Android initial ve raw Android found-state screenshot'ları kullanıcı PASS alıyor mu?
3. `ERROR_STATE_VISUAL`: referansta ayrı hata-state asset'i yok; kullanıcı/karar doğrulaması olmadan yeni stil üretilmez.
4. `REFERENCE_FONT`: exact font kaynağı bağımsız doğrulanmadı; hedefe yaklaşmak için ayrıca doğrulanacak.
5. B5 60 saniye ve B10 120 saniye challenge süreleri gerçek insan playtestinde dengeli mi?
6. PR #161 ve parent PR #158 ne zaman Ready yapılacak? Görsel PASS'ten sonra ayrı açık karar gerekir.
7. Merge için Levent ayrıca açık onay verecek mi? Görsel PASS merge izni değildir.
8. Production `lib/main.dart` ana navigasyon entegrasyonu için ayrı kapsam/onay verilecek mi?
9. Eski PR #156 ne zaman/kim tarafından kapatılacak? Otomatik kapatılmayacak.

### Tarihsel 30–31 Ağustos V5 tema kanıtları

- Run `33308127773`, artifact `9731244720`: eski layered/refined temada Android 16 teknik gameplay kanıtı PASS.
- Artifact `9737903231` / `67f7365...`: bir ara refined görünüm kabul edilmişti; daha sonra exact-reference talebiyle supersede edildi.
- 31 Ağustos'ta image-edit/mockup üzerinden alınan sonraki PASS de **geçersiz**; current görsel durum gerçek runtime Görsel 2 için FAIL'dir.

---

## Issue #109 / MASTER ART production — KAPANDI

- Issue #109 `Photo 1.jpg` tek bağlayıcı MASTER ART.
- Görsel ve `MASTER ART raster + şeffaf hitbox` mimari kabulü PASS.
- PR #147 merge SHA `d118aa98c5551cb3b4418f61047f6a730406d963`.

---

## Dynamic progression state — KAPANDI

- Gerçek `X / 30`, yıldız, locked/open state doğrulandı.
- Android 16 run `32969604847`: SUCCESS.
- PR #150 merge SHA `d64fcd4ea63f173c6653ff33926b12a6c99ef37d`.

---

## Kelime Avı production ana navigasyon entegrasyonu — AÇIK / AYRI KAPSAM

- `lib/main.dart` 8×8 starter-content / V5 exact-reference asset dönüşümünde değiştirilmedi.
- Gerçek uygulama girişine bağlama ayrı branch/PR ve açık onay ister.

---

## 1.68.19+109 release / Play / rewarded canlı kabul — AÇIK

- Aynı `gameId` ikinci +10 XP vermez — fiziksel canlı kabul.
- Yarım/başarısız rewarded reklamda XP yok; hak korunur ve yeniden denenebilir.
- Farklı tamamlanan oyunlarda toplam kota olmaması fiziksel kabul.
- Production +109 package/version/signing/AdMob/Firebase/Play doğrulamaları.

---

## Canlı Düello fiziksel kabulü — AÇIK

İki güncel Play cihazı ve iki ayrı hesapla eşleştirme, soru sırası, skor, sonuç, BR/lig, leaderboard ve kopma davranışı uçtan uca doğrulanacak.

---

## Soru geri bildirimleri — AÇIK

- Her soru metin + 4 seçenek + doğru indeks + açıklama + kategori + zorluk birlikte kontrol edilir.
- `assets/questions.json` kontrolsüz değiştirilmez.
- Gerçek düzeltme merge edilmeden Sheet satırı kapatılmaz.

---

## 3B tahta — DURDURULDU / KARAR BEKLİYOR

- BoardMap / 67 node düzenine dokunulmaz.
- Önce numaralı deterministik geometri.
- 8 konsept rozet / 6 fiziksel rozet eşlemesi çözülmeden ilerlenmez.

---

## Mağaza ve tanıtım — AÇIK

Telefon, tablet, Chromebook, PC ve XR varlıklarının Play Console durumu canlı ekrandan doğrulanacak.
