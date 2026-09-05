<!-- GOKYUZU_R7_ANDROID16_START -->
## AKTİF — Gökyüzü R7 human visual acceptance
**Görev:** Exact ürün HEAD `f35082c44e637cb7e6e3815c7d54d38a58b776df` için üretilen raw Android16 `1080×1920` ekranını Levent'in görsel olarak inceleyip PASS/FAIL vermesi.

**Mevcut teknik kanıt:** test-before-commit `33971902782` / `101321780327` SUCCESS; Android16 `33972011069` / `101322071661` SUCCESS; analyzer temiz; **39/39 PASS**; APK SHA256 `a972bf07bf68f0c2cab1908c85b6e0a98e8f0821a78b5e53175317f6e0a2f8f2`; screenshot SHA256 `79edc57a575d2bdf59407260fe272993e69400a23d520687ac71680d58228637`; artifact `9971319096`.

**Bitti ölçütü:**
1. Levent exact raw R7 Android ekranını açıkça görsel PASS eder.
2. PASS sonrası gerçek cihaz APK kabulü tamamlanır.
3. PR #175 Ready/merge yalnız ayrıca açık Levent onayıyla yapılır.
4. Play yükleme/yayınlama ayrıca açık onay gerektirir.

**Durum:** `AÇIK / LEVENT GÖRSEL KARARI BEKLİYOR`.
<!-- GOKYUZU_R7_ANDROID16_END -->

<!-- GOKYUZU_R6_ANDROID16_START -->
## AKTİF — Gökyüzü R6 human visual acceptance
**Görev:** Exact ürün HEAD `560d76bd828e0b4d813218f1000b895da9d0c7fa` için üretilen raw Android16 `1080×1920` ekranını Levent'in görsel olarak inceleyip PASS/FAIL vermesi.

**Mevcut kanıt:** run `33967506643` / job `101310099566` **SUCCESS**; 39/39 regression PASS; screenshot SHA256 `2c4da0a1a22f443b65b5656d71d4ccfef983f0600ba6effcd3bc9e27dbe18e44`; artifact `9970009097`.

**Bitti ölçütü:**
1. Levent exact raw R6 Android ekranını açıkça görsel PASS eder.
2. PASS sonrası gerçek cihaz APK kabulü tamamlanır.
3. PR #175 Ready/merge yalnız ayrıca açık Levent onayıyla yapılır.
4. Play yükleme/yayınlama ayrıca açık onay gerektirir.

**Durum:** `AÇIK / LEVENT GÖRSEL KARARI BEKLİYOR`.
**Not:** Önceki R3/R4 tall-viewport kapıları current R6 teknik aday tarafından supersede edilmiştir; tarihsel kayıt olarak aşağıda korunur.
<!-- GOKYUZU_R6_ANDROID16_END -->

<!-- GOKYUZU_R4_STATIC_PROOF_START -->
## AKTİF — Gökyüzü tall-device R4 statik viewport kabulü
**Görev:** Approved V2 MASTER ART merkezini değiştirmeden 9:16 dış alanı görsel olarak doğal tamamlamak.

**R4 aday:** `gokyuzu_tall_viewport_static_proof_r4e.png`, 1080×1920, SHA256 `96cef05fdf9f5f59ed37ad4829cef1e225858905d1fb01d20b826f8e402ae8bf`.

**Bitti ölçütü:**
1. Levent statik R4 görünümünü açıkça PASS eder.
2. PASS sonrası aynı çözüm #175 ürün branch'ine uygulanır.
3. Analyzer + focused/regression + raw Android16 tekrar PASS olur.
4. Son raw Android ekranı Levent'e gösterilir ve ayrı human visual PASS alınır.
5. Ready/merge/Play ayrı açık onay gerektirir.

**Durum:** `AÇIK / R4 STATİK GÖRSEL KARAR BEKLİYOR`.
<!-- GOKYUZU_R4_STATIC_PROOF_END -->

# Bilgi Rotası — Görev Havuzu

<!-- GOKYUZU_VIEWPORT_R3_START -->
## AKTİF — Gökyüzü V2 tall-device viewport görsel kapısı
**Görev:** Onaylı Gökyüzü Adaları V2 MASTER ART çekirdeğini değiştirmeden 9:16 ve daha uzun telefon ekranlarında doğal, tekrar etmeyen tam ekran sunum üretmek.

**Mevcut kanıt:** QA-only R3 run `33952294411` / job `101269226635` teknik PASS; 39/39 regression PASS; raw 1080×1920 screenshot SHA256 `fcf7b065fc58453fe343bb7fedb9feb1641ae06df8348cec4debfd77bef65aa7`, artifact `9965315644`.

**Bitti ölçütü:**
1. Approved V2 ana kompozisyon/landmark/node/kontrol sanatı bozulmayacak, gerilmeyecek ve kritik kenarlar crop edilmeyecek.
2. Üst/alt tall-device alanı duplicated MASTER ART veya düz/rahatsız edici letterbox görünümü taşımayacak.
3. Önce statik tam-ekran visual proof Levent tarafından açıkça PASS edilecek.
4. Yalnız bu PASS sonrası çözüm #175 ürün branch'ine uygulanacak; analyzer + focused/regression + raw Android16 kanıtı yeniden alınacak.
5. Ready/merge ve Play ayrı açık Levent onayı olmadan yapılmayacak.

**Durum:** `AÇIK / GÖRSEL KARAR BEKLİYOR`. R3 teknik PASS, human visual PASS değil.
<!-- GOKYUZU_VIEWPORT_R3_END -->


**Son güncelleme:** 5 Eylül 2026 — Gökyüzü exact V2 referans kaynağı yeniden bulundu ve renderer sapma audit'i tamamlandı. Aktif kapı: mevcut 48 production assetle hazırlanan statik V2 kompozisyon proof'un Levent görsel incelemesi. PASS olmadan Flutter/#173 düzeltmesi veya gerçek-cihaz APK yok. #173 DRAFT/blokeli; merge/Play yok.

> Root dosya güncel Kelime Avı çalışma checkpointini taşır. Eski ayrıntılı görev geçmişi `docs/project-memory/GOREV_HAVUZU.md` ve Git geçmişinde korunur.

## Aktif görev — Gökyüzü Adaları production asset export

**Durum:** 8×8 LOCKED / BAŞLANGIÇ LİMANI RELEASE PASS / GÖKYÜZÜ ADALARI TEMA+KONSEPT+ROTA+MODÜLER MİMARİ LOCKED / ROTA MOCK V2 STATİK GÖRSEL PASS / PRODUCTION SHEET A–E AKTİF / FLUTTER-APK ÜRETİMİ BAŞLAMADI / CANONICAL RELEASE HEAD `3557a7e4...` / PLAY YAYINI YOK

**Canonical release:** `release/final-closed-test-aab-1.68.8` @ `3557a7e4f2f2917d61ba61866c6d4c8561994667`

**Sürüm:** `1.68.19+109`

### Tamamlanan kapılar

1. Canonical 8×8 / 64 hücre — **PASS**.
2. 10 bölüm / 30 yıldız / 80 target+bonus contract — **PASS**.
3. V5 approved reference asset integration — **PASS**; run `33379341765`.
4. Found-state raw Android kullanıcı kabulü — **PASS**; run `33486609120`.
5. Error-state raw Android kullanıcı kabulü — **PASS**; run `33524578623`.
6. Compact completion popup — **PASS**; run `33655562508`.
7. B5 60 sn tuning — **PASS**; insan sonucu **32 sn**; Android16 `33670657723`.
8. Swipe false-positive dar tolerans — **PASS**; fast `33724552713`, Android16 `33724549202`.
9. PR #167 Ready + merge — **PASS**; `c5d57e98866e244fdf36d5e7b6ad4684c5f935f4`.
10. PR #163 final review + Ready + merge — **PASS**; `806c4bfc01f2ab9211a2684bff36f76a82e4ac8d`.
11. PR #162 final review + Ready + merge — **PASS**; `929bb13177e03a0962464e21f6c174d4b3439349`.
12. PR #161 final review + Ready + merge — **PASS**; `4aa490e7c2d5e7547dc95f9463dbbb9adeb85e5a`.
13. PR #158 cleanup/final review/exact release-context — **PASS**.
14. PR #158 → canonical release merge — **PASS**; merge commit `189864c92a605e7bb960460300714049c730ea39`.
15. Production ana navigasyon branch’i — **PASS**; `feat/kelime-avi-production-navigation-20260903`.
16. PR #169 final minimum ürün diff’i — **PASS**; yalnız 4 dosya, 259 ekleme / 0 silme; protected scope temiz.
17. PR #169 focused production validation — **PASS**; run `33754274810`, 62 test.
18. PR #169 minimum-diff yeniden doğrulaması — **PASS**; run `33754621892`.
19. PR #169 full-suite + release APK + Android16 cold-start/AdMob — **PASS**; run `33754851284`, job `100646698982`.
20. PR #169 Kelime Avı Android16 görsel/MASTER ART — **PASS**; run `33754851205`, job `100646698474`; 126 test; artifact `9893332600`.
21. PR #169 Ready for Review — **PASS**; exact Ready HEAD `ffa1454ba8fb47da21ca6caa50b0a5495e0149c1`.
22. PR #169 → canonical release merge — **PASS**; merge commit `0c84aefd8a5ef591aaaab9eaa30bed2e044190cf`.
23. PR #169 merge sonrası canonical release HEAD doğrulaması — **PASS**; `0c84aefd...`.
24. PR #168 docs-only final diff — **PASS**; yalnız dört checkpoint belgesi.
25. PR #168 review/comment kontrolü — **PASS**; blocker yok.
26. PR #168 → canonical release merge — **PASS**; Levent’in `Devam et` onayıyla; merge commit `3557a7e4f2f2917d61ba61866c6d4c8561994667`.
27. PR #168 merge sonrası canonical release HEAD doğrulaması — **PASS**; `3557a7e4...`.
28. PR #168 merge commitinde otomatik PR workflow’u — **0 run / DOĞRULANDI**.
29. Paket 2 tema adı — **PASS / LOCKED**: `Gökyüzü Adaları`.
30. Paket 2 görsel yön — **PASS / LOCKED**: `C — Neşeli & Parlak`.
31. Gökyüzü Adaları 10 bölüm adı + rota sırası — **PASS / LOCKED**.
32. Gökyüzü Adaları görsel teknik mimarisi — **PASS / LOCKED**: modüler asset yaklaşımı.
33. V1 asset üretim sözleşmesi — **PASS / HAZIR**: 48 atomik asset / 5 sprite sheet.
34. Sheet A–E konsept üretimi — **PASS / ÜRETİLDİ**; yalnız stil/kompozisyon referansı.
35. Rota mock V1 — **ÜRETİLDİ / alt genel menü nedeniyle superseded**.
36. Rota mock V2 — **PASS / LEVENT GÖRSEL ONAYI**.
37. Rota kabuğu kararı — **PASS / LOCKED**: alt genel menü yok; Başlangıç Limanı gibi rota içi köşe kontrolleri.
38. Bölüm görsel ayrımı — **PASS / LOCKED**: aynı UI/progression kabuğu, her bölümde farklı landmark/ada kimliği.

### Gökyüzü Adaları — kilitli rota

1. Rüzgâr Kapısı
2. Bulut Bahçesi
3. Kuş Geçidi
4. Gökkuşağı Köprüsü
5. Fırtına Kulesi
6. Hava Gemisi Limanı
7. Ay İskelesi
8. Gizli Ada — bonus
9. Yıldız Gözlemevi
10. Güneş Sarayı

- 7 sonrası bonus 8 ve normal 9 birlikte erişilebilir; 8, 9 için gate değildir.
- 10, node 9 tamamlanmadan locked kalır.

### Gökyüzü Adaları — production asset aşaması

- Referans tuval: 1080×1920 dikey.
- 48 atomik asset: 8 atmosfer + 7 ada + 6 yol + 10 landmark + 9 node/progression UI + 8 dekor.
- Konsept poster/sheet görselleri doğrudan production asset değildir.
- Şimdi 5 gerçek production sheet üretilecek: şeffaf arka plan, yazı/etiket yok, parçalar birbirine değmez, crop için güvenli boşluk bırakılır.
- Dinamik numara, yıldız, lock/progression ve metin asset içine bake edilmez.

### Açık işler

1. **Production Sheet A–E şeffaf export** — **AKTİF / SIRADAKİ ÜRETİM**.
2. Sheet'leri gerçek 48 atomik production asset'e ayırma + toplu şeffaflık/kenar/ölçek QA — **BEKLİYOR**.
3. Flutter rota entegrasyonu — **BEKLİYOR / atomik QA bitmeden başlanmaz**.
4. Gökyüzü Adaları 80 target+bonus içerik iskeleti ve 8×8 grid üretimi — **BEKLİYOR**.
5. `REFERENCE_FONT` exact kaynak — **DOĞRULANACAK / DEFERRED**.
6. PR #166 tarihsel geliştirme/QA hattıdır — **MERGE YOK**.
7. Play yükleme/yayınlama — **AÇIK / ayrıca Levent’in açık onayı gerekli**.

**Sıradaki çalışma: onaylı V2 görsel dilini gerçek şeffaf Sheet A–E production export’una dönüştür; sonra 48 atomik asset + toplu QA.**

## Kelime Avı V9 — Gökyüzü Adaları Asset Intake Checkpoint — 5 Eylül 2026

- Canonical release: `release/final-closed-test-aab-1.68.8` @ `3557a7e4f2f2917d61ba61866c6d4c8561994667`; sürüm `1.68.19+109`.
- Başlangıç Limanı release/gameplay/görsel/navigasyon PASS; yeni belirti yok, yeniden açılmadı.
- İçerik PR #171: OPEN / DRAFT; exact HEAD `4ec33de7438fcbd15ed63b1ae2adda127da3be8c`; Ready/merge yapılmadı.
- Firestorage file id `01a06e6342ff774994dd33280571724e`: 42 chunk index `0..41`, 42/42 expected Git blob SHA ve strict base64 decode PASS.
- Rebuilt ZIP: 557120 bayt PASS; SHA256 `d219c6233fa27f5e3e04687ec5fd15dab1f24500584e78d6a7c80036ee68f5ca` PASS; ZIP integrity PASS.
- Runtime asset QA: 48/48 WebP PASS; 41 core + 7 optional island variant PASS; 48/48 decode/alpha PASS. Bu raw Android görsel PASS değildir.
- Materialization run `33923955868`, job `101188228034`: SUCCESS.
- Asset branch `feat/kelime-avi-gokyuzu-runtime-assets`; tek temiz commit `8508e6bfe03d0772cf2bd371d9d3ea4b4177b7fb` (`feat(kelime-avi): add gokyuzu runtime assets`); parent exact canonical `3557a7e4f2f2917d61ba61866c6d4c8561994667`.
- Exact compare: ahead_by=1, behind_by=0, total_commits=1; yalnız `assets/word_hunt/gokyuzu_adalari/*.webp`; 48 changed file. Final ürün tree'sinde transfer XLSX/ZIP/workflow/chunk kalıntısı yok.
- Asset PR #172: OPEN / DRAFT; base `3557a7e4...`, head `8508e6bf...`, 1 commit / 48 file; Ready/merge yapılmadı.
- Bu checkpoint sırasında #172 otomatik kontrolleri sürüyor; ASSET_PR_PASS henüz verilmedi.
- Flutter rota entegrasyonu #172 gerçek PASS sonrası ayrı branch/PR olarak BEKLİYOR.
- Android 16 raw screenshot + crash/ANR/log ve Levent gerçek cihaz görsel kabulü BEKLİYOR.
- `assets/questions.json`, BoardMap/67 node, Firebase, AdMob, signing, package/version ve Play release'e dokunulmadı. Play yalnız Levent'in ayrı açık onayıyla.

## Kelime Avı V9 — Gökyüzü Rota Entegrasyonu + Android16 Teknik Kanıtı — 5 Eylül 2026

- Canonical release değişmedi: `release/final-closed-test-aab-1.68.8` @ `3557a7e4f2f2917d61ba61866c6d4c8561994667`; sürüm `1.68.19+109`.
- Başlangıç Limanı release/gameplay/görsel/navigasyon PASS durumu korunuyor; yeniden açılmadı.
- İçerik PR #171: **OPEN / DRAFT / mergeable=true**; exact HEAD `4ec33de7438fcbd15ed63b1ae2adda127da3be8c`; Ready/merge yok.
- Asset PR #172: **OPEN / DRAFT / mergeable=true / ASSET_PR_PASS**; exact HEAD `8508e6bfe03d0772cf2bd371d9d3ea4b4177b7fb`; 48 WebP; otomatik kontroller SUCCESS; Ready/merge yok.
- Flutter rota entegrasyonu ayrı ürün branch'inde tamamlandı: `feat/kelime-avi-gokyuzu-route-integration-20260905`.
- Entegrasyon commit'i: `3abe69ac329fba76ecfeb780ecdf3bfc68da578e` — `feat(kelime-avi): integrate gokyuzu route`; parent exact asset HEAD `8508e6bf...`.
- Exact integration diff: ahead 1 / behind 0 / 1 commit; yalnız 6 dosya: Gökyüzü route screen, production entry dar route seçimi, progression bonus-bypass genellemesi, `pubspec.yaml` asset kaydı ve 2 focused test dosyası.
- Pre-commit integration gate run `33925674228`, job `101193533261`: SUCCESS; focused regresyon **39/39 PASS**; yeni analyzer error yok; `assets/questions.json`, `android/`, package/version korunuyor.
- DRAFT entegrasyon PR #173: **OPEN / DRAFT / mergeable=true**; base `feat/kelime-avi-gokyuzu-runtime-assets`, exact head `3abe69ac...`; Ready/merge yok.
- Gökyüzü progression LOCKED davranışı testle korunuyor: node 7 sonrası bonus 8 + normal 9 birlikte açılır; node 10, 9 tamamlanmadan locked kalır; Başlangıç Limanı regresyonu PASS.
- Android16 source capture run `33928436133`, job `101201894979`: exact integration HEAD `3abe69ac...` + exact runner-only content HEAD `4ec33de...`; analyzer **No issues found**; Gökyüzü focused **6/6 PASS**; isolated debug APK build PASS; APK SHA256 `cbcb0daa63a3b96727a9e4af827c2a03ded6242b27a0021b912dcbc166a8efbb`.
- Aynı run Android API 36 emulatoru boot etti, APK'yı kurup açtı ve raw screenshot aldı. Screenshot **1080×1920**; `[GOKYUZU_ANDROID16_RUNTIME_READY]` marker mevcut; `MainActivity` resumed/focused; UI dump başlık + 10 bölüm + Pusula + Bilgi Kitabı taşıyor.
- Source capture step sonucu, kanıt dosyaları üretildikten sonra `android-emulator-runner` çok satırlı `grep \\` ifadesini ayrı `/bin/sh` çağrılarına böldüğü için false-negative `failure` oldu. Bu uygulama/runtime hatası değildir. Source artifact: `9957851560`.
- Raw artifact bağımsız validator run `33929151047`, job `101204015094`: **SUCCESS**. Exact SHA'lar, 1080×1920 PNG, resumed/focused activity, runtime marker, 10 node semantics ve `FATAL EXCEPTION` / package ANR-crash-proc-died / `A RenderFlex overflowed` / `FlutterError` yokluğu tekrar doğrulandı. Validated artifact: `9957897368`.
- Sonuç: `GOKYUZU_ANDROID16_TECHNICAL_RUNTIME` — **PASS / KAPANDI**.
- `GOKYUZU_REAL_DEVICE_VISUAL_ACCEPTANCE` — **AÇIK / LEVENT GERÇEK CİHAZ-NİHAİ GÖRSEL KABULÜ GEREKLİ**. Emulator teknik PASS, insan/fiziksel cihaz kabulünün yerine geçmez.
- #171, #172, #173 DRAFT kalır. Ready/merge/Play işlemi yapılmadı; Play yalnız Levent'in ayrı açık onayıyla.
- `assets/questions.json`, BoardMap/67 node, Firebase, AdMob, signing, package/version ve Play release korunmuştur.
- Bu blokta yeni ürün kararı alınmadı; `KARARLAR.md` değişmedi.

## Kelime Avı V9 — Gökyüzü raw runtime görsel reddi — 5 Eylül 2026

- Levent raw Android16 Gökyüzü rota ekranını açıkça **GÖRSEL FAIL / REJECTED** olarak değerlendirdi: gösterilen runtime, daha önce onaylanan Gökyüzü Adaları **Rota mock V2** hedefi değildir.
- Android16 teknik/runtime kanıtı geçerlidir ancak yalnız teknik kanıttır; görsel ürün kabulü değildir.
- PR #173 entegrasyonu **görsel olarak blokeli** kalır; Ready/merge yapılmaz.
- Bağlayıcı görsel hedef değişmedi: `C — Neşeli & Parlak`, Rota mock V2 statik kabulü ve aynı rota kabuğu/landmark kompozisyon dili korunur.
- Mevcut raw runtime; büyük beyaz üst panel, boş/cyan ağırlıklı sahne, küçültülmüş ada/landmarklar, basit şerit rota ve dağınık dekor kompozisyonu nedeniyle V2 hedefini taşımıyor; bu görünüm yeni ürün yönü olarak kabul edilmez.
- Görev sırası düzeltilmiştir: önce onaylı V2 görsel hedefiyle gerçek production kompozisyon/export eşleşmesi yeniden kurulacak; görsel karşılaştırma PASS olmadan yeni gerçek-cihaz kabul APK'sına geçilmeyecek.
- `qa/gokyuzu-real-device-apk-20260905` run `33929590990`: split APK build/test adımı PASS, Android16 isolated launch adımı FAIL; artifact upload SKIPPED. Kullanıcı görsel reddi nedeniyle bu hat ürün kabul kanıtı olarak kullanılmayacak ve QA branch canonical release'e resetlendi.
- Exact V2 mock raster dosyasının repo/File Library içinde yeniden erişilebilir kaynak yolu **DOĞRULANACAK**; belge kayıtlarındaki V2 görsel sözleşmesi korunur, tahminle yeni kompozisyon uydurulmaz.
- `assets/questions.json`, BoardMap/67 node, Firebase, AdMob, signing, package/version, canonical release ve Play korunmuştur.
- Yeni ürün kararı yok; `KARARLAR.md` değişmedi.

## Kelime Avı V9 — Gökyüzü V2 kaynak/audit checkpointi — 5 Eylül 2026

- File Library içinde onay kaydıyla eşleşen V2 referans yeniden bulundu: **`Gökyüzü Adaları: Büyülü Seviye Haritası.png`**, File Library id `file_00000000fe7c81f4aec58eee1d5c702d`, oluşturma zamanı `2026-09-03T18:47:34Z`.
- Dosya tanımı kayıtlı V2 sözleşmesiyle örtüşüyor: koyu lacivert/mor + altın üst kabuk, `KELİME AVI`, büyük `GÖKYÜZÜ ADALARI` paneli, `0 / 30`, `Bölüm: 1`, zengin yüzen ada/landmark kompozisyonu, kıvrımlı ışıklı rota, 8 bonus dalı, alt köşe pusula/kitap ve genel alt menü yok.
- Companion kaynaklar da yeniden bulundu: `Gökyüzü Adaları Rota Konseptleri.png` (C — Neşeli & Parlak) ve `Gökyüzü Adaları Renkli Asset Sheet.png`.
- #173 renderer kök görsel sapması koddan doğrulandı: beyaz/yarı saydam 218 px top chrome, beyaz Material butonları, düz gradient taban, küçük `178–205 px` scene assetleri, ayrı ada+scene üst üste bindirme, beyaz label kapsülleri ve CustomPainter ile basit 18/10 px stroked route. Bunlar V2'nin koyu süslü kabuğu, büyük landmark ölçeği ve cloud/glow rota dilini taşımıyor.
- Mevcut 48 runtime WebP teknik olarak kullanılabilir; görsel FAIL'in önemli bölümü asset bozukluğundan değil **kompozisyon/ölçek/chrome renderer kararından** kaynaklanıyor. Asset stil uygunluğu yine V2'ye karşı gözle doğrulanacak.
- Flutter'a yeni düzeltme yazılmadan önce mevcut 48 runtime assetle deterministik statik production kompozisyon proof üretildi. Lokal proof SHA256: `9b40fa2d0898c62ae26f565f0fd2f8f7acb892b3420a65aefaccaf6c2dbc6edd`. Bu dosya Android/runtime kanıtı değildir ve Levent görsel incelemesi **BEKLİYOR**.
- Önceki raw Android FAIL screenshot SHA256 `743771f97b4c60126fe624f9d4c4aec54bc4ce83b8046551c28741f83e977415` olarak korunur.
- `GOKYUZU_EXACT_V2_REFERENCE_SOURCE` artık **DOĞRULANDI**; `GOKYUZU_STATIC_PRODUCTION_COMPOSITION_ACCEPTANCE` **AÇIK / BEKLİYOR**.
- #173 DRAFT/görsel blokeli kalır. Ready/merge/Play yok. `assets/questions.json`, BoardMap/67 node, Firebase, AdMob, signing, package/version ve canonical release korunur.
- Yeni ürün kararı yok; `KARARLAR.md` değişmedi.
