<!-- GOKYUZU_R4_STATIC_PROOF_START -->
## Gökyüzü R4 viewport açık doğrulaması — 5 Eylül 2026
- `GOKYUZU_MASTER_ART_VIEWPORT_R3_TECHNICAL = PASS`.
- `GOKYUZU_TALL_VIEWPORT_R4_STATIC_ACCEPTANCE = AÇIK / BEKLİYOR`.
- R4 statik aday Android/runtime kanıtı değildir.
- PASS olmadan #175'e viewport uzatma commit edilmeyecek.
<!-- GOKYUZU_R4_STATIC_PROOF_END -->

# Bilgi Rotası — Açık Sorular ve Doğrulamalar

<!-- GOKYUZU_VIEWPORT_R3_START -->
## GOKYUZU_TALL_VIEWPORT_VISUAL — AÇIK
- Approved Gökyüzü V2 MASTER ART exact kaynak üretimde mevcut; replacement PR #175 exact product HEAD `4145f0fe8d716d6951e1ee53215812b56150c73c`.
- R2'de darkened `BoxFit.cover` duplicate background görsel olarak uygun değildi.
- R3 QA-only gradient-fill denemesi teknik olarak PASS: run `33952294411`, job `101269226635`, artifact `9965315644`, raw screenshot SHA256 `fcf7b065fc58453fe343bb7fedb9feb1641ae06df8348cec4debfd77bef65aa7`.
- Ancak approved MASTER ART 1085×1536 olduğu için 1080×1920 ve daha uzun ekranlarda `contain` yaklaşımı üst/alt letterbox alanı bırakıyor.
- **DOĞRULANACAK:** accepted V2 çekirdeği sabit kalırken üst/alt alanın doğal gökyüzü/dünya devamıyla nasıl tamamlanacağı ve Levent'in bu tam-ekran statik proof'u görsel olarak kabul edip etmeyeceği.
- Human visual PASS gelmeden #175 Ready/merge yok; Play yok.
<!-- GOKYUZU_VIEWPORT_R3_END -->


**Son güncelleme:** 5 Eylül 2026 — `GOKYUZU_EXACT_V2_REFERENCE_SOURCE` DOĞRULANDI: `Gökyüzü Adaları: Büyülü Seviye Haritası.png` / File Library `file_00000000fe7c81f4aec58eee1d5c702d`. `GOKYUZU_STATIC_PRODUCTION_COMPOSITION_ACCEPTANCE` AÇIK/BEKLİYOR. #173 DRAFT/görsel blokeli; merge/Play yok.

## Kelime Avı

### Kapanan kabul/doğrulama kapıları

- `USER_VISUAL_ACCEPTANCE_INITIAL` — **PASS / KAPANDI**.
- `USER_VISUAL_ACCEPTANCE_FOUND` — **PASS / KAPANDI**; Android16 `33486609120`.
- `ERROR_STATE_VISUAL` — **PASS / KAPANDI**; Android16 `33524578623`.
- `COMPLETION_AUTO_REPLAY` — **PASS / KAPANDI**.
- `COMPLETION_POPUP_COMPACT_VISUAL` — **PASS / KAPANDI**; Android16 `33655562508`.
- `B5_60S_BALANCE_DECISION` — tuning sonrası 32 sn: **PASS / KAPANDI**.
- `SWIPE_FALSE_POSITIVE_MISTAKES` — Fast `33724552713` + Android16 `33724549202`: **PASS / KAPANDI**.
- `PR_167_READY_MERGE` — **PASS / KAPANDI**; merge `c5d57e98866e244fdf36d5e7b6ad4684c5f935f4`.
- `PR_163_READY_MERGE` — **PASS / KAPANDI**; merge `806c4bfc01f2ab9211a2684bff36f76a82e4ac8d`.
- `PR_162_READY_MERGE` — **PASS / KAPANDI**; merge `929bb13177e03a0962464e21f6c174d4b3439349`.
- `PR_161_FINAL_REVIEW` — **PASS / KAPANDI**.
- `PR_161_READY_DECISION` — **PASS / KAPANDI**.
- `PR_161_MERGE_DECISION` — **PASS / KAPANDI**; merge `4aa490e7c2d5e7547dc95f9463dbbb9adeb85e5a`.
- `PR_158_RELEASE_QA_CLEANUP` — **PASS / KAPANDI**; commit `2ae95df70b452f735a8db9c5bd0d88827a2ec40a`.
- `PR_158_FINAL_DIFF_REVIEW` — 37 dosya; protected scope temiz; review/thread yok: **PASS / KAPANDI**.
- `PR_158_ANDROID16_RELEASE_CONTEXT` — run `33745646184`, job `100617364648`: **SUCCESS / KAPANDI**; artifact `9887953917`.
- `PR_158_RELEASE_APK_ADMOB_CONTEXT` — run `33745646210`, job `100617365147`: **SUCCESS / KAPANDI**; artifact `9889920696`.
- `PR_158_READY_DECISION` — **PASS / KAPANDI**.
- `PR_158_RELEASE_MERGE_DECISION` — **PASS / KAPANDI**; merge `189864c92a605e7bb960460300714049c730ea39`.
- `PRODUCTION_MAIN_NAVIGATION` — **PASS / KAPANDI**; PR #169 merge `0c84aefd8a5ef591aaaab9eaa30bed2e044190cf`.
- `PR_169_FULL_SUITE_RELEASE_ANDROID16` — run `33754851284`: **SUCCESS / KAPANDI**.
- `PR_169_VISUAL_MASTER_ART_ANDROID16` — run `33754851205`: **SUCCESS / KAPANDI**; 126 test; artifact `9893332600`.
- `PR_169_READY_DECISION` — **PASS / KAPANDI**.
- `PR_169_RELEASE_MERGE_DECISION` — **PASS / KAPANDI**; merge `0c84aefd8a5ef591aaaab9eaa30bed2e044190cf`.
- `PR_169_RELEASE_HEAD_VERIFY` — **PASS / KAPANDI**.
- `PR_168_MERGEABILITY_RECHECK` — **PASS / KAPANDI**.
- `PR_168_DOCS_MERGE_DECISION` — **PASS / KAPANDI**; merge `3557a7e4f2f2917d61ba61866c6d4c8561994667`.
- `PR_168_RELEASE_HEAD_VERIFY` — **PASS / KAPANDI**.
- `NEXT_ROUTE_THEME_NAME` — **Gökyüzü Adaları / PASS / LOCKED / KAPANDI**.
- `NEXT_ROUTE_VISUAL_DIRECTION` — **C — Neşeli & Parlak / PASS / LOCKED / KAPANDI**.
- `GOKYUZU_ADALARI_ROUTE_STRUCTURE` — 10 bölüm adı + sıra **PASS / LOCKED / KAPANDI**.
- `GOKYUZU_ADALARI_VISUAL_TECH_ARCHITECTURE` — **modüler asset yaklaşımı / PASS / LOCKED / KAPANDI**.
- `GOKYUZU_ADALARI_ASSET_CONTRACT` — **48 atomik asset / 5 sprite sheet / PASS / PLAN HAZIR**.
- `GOKYUZU_ADALARI_ROUTE_MOCK_V2_VISUAL` — alt genel menüsüz düzeltilmiş rota mock V2: **PASS / LEVENT ONAYI / KAPANDI**.
- `GOKYUZU_ADALARI_ROUTE_SHELL` — Başlangıç Limanı ile tutarlı rota kabuğu, rota içi köşe kontrolleri, alt genel menü yok: **PASS / LOCKED / KAPANDI**.
- `GOKYUZU_ADALARI_LEVEL_VISUAL_VARIATION` — aynı UI/progression kabuğu + bölüm başına farklı landmark/ada kimliği: **PASS / LOCKED / KAPANDI**.

### Gökyüzü Adaları kilitli rota

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

### Açık kalanlar

- `GOKYUZU_ADALARI_PRODUCTION_SPRITE_SHEETS` — yazısız/etiketsiz, şeffaf arka planlı Sheet A–E production export: **AKTİF / SIRADAKİ ÜRETİM**.
- `GOKYUZU_ADALARI_ATOMIC_ASSET_QA` — production sheet'leri 48 atomik asset'e ayırma, transparanlık/kenar/ışık/stil/ölçek kontrolü: **BEKLİYOR**.
- `GOKYUZU_ADALARI_FLUTTER_ROUTE` — modüler rota Flutter entegrasyonu: **BEKLİYOR / atomik QA sonrası**.
- `GOKYUZU_ADALARI_CONTENT_PACKAGE` — 80 target+bonus içerik ve 8×8 grid paketi: **BEKLİYOR**.
- `PACKAGE_BASED_QA_IMPLEMENTATION` — 10 bölümlük tek branch, B1/B5/B10 insan örneklemesi ve tek paket QA APK: **KARAR VERİLDİ / UYGULANACAK**.
- `REFERENCE_FONT` — **DOĞRULANACAK / DEFERRED**.
- `PLAY_RELEASE` — **AÇIK / ayrı Levent onayı gerekli**.

## Merge güvenliği

- PR #158 canonical release'e merge edildi: `189864c92a605e7bb960460300714049c730ea39`.
- PR #169 canonical release'e merge edildi: `0c84aefd8a5ef591aaaab9eaa30bed2e044190cf`.
- PR #168 docs-only merge edildi: `3557a7e4f2f2917d61ba61866c6d4c8561994667`.
- Gökyüzü Adaları karar/asset planı docs-only PR #170 branch'inde tutulur; ürün kodu/Play işlemi henüz yapılmaz.
- PR #170 ayrı açık onay olmadan merge edilmez.
- Play yayını yapılmamıştır.

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
