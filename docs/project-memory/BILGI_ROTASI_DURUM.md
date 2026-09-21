# Bilgi Rotası - Güncel Proje Durumu

> Teknik gerçek her zaman canlı GitHub ve ilgili canlı servislerdir. Aşağıdaki 21 Eylül 2026 Wave10A kaydı bu dosyadaki daha eski Kelime Avı 10-level-only varsayımlarını integration branch bağlamında supersede eder.

## 21 Eylül 2026 — Kelime Avı 2.0 Wave10A closure state

- Integration branch: `feat/kelime-avi-2-0-integration`
- PR #213: **OPEN / DRAFT / UNMERGED**
- Implementation green HEAD: `f6e8464540faeb78e3ff3306b0970335ecc4873a`
- Base: `release/final-closed-test-aab-1.68.8`
- Status: **WAVE10A IMPLEMENTATION + VALIDATION COMPLETE**

Başlangıç Limanı:
- available = 20
- planned = 100
- Segment1 = L1–10
- Segment2 = L11–20
- L10 = Segment1 endpoint
- L20 = Segment2 endpoint / current content frontier
- L20 true route final değildir
- L20 route reward / fake completion / false Gökyüzü unlock / L21 navigation üretmez

Progression:
- internal local 1–100
- global 1–800 numbering display-only
- persistence/progression/segment/milestone/route-final local index authority

Persistence:
- schema v3
- prefix `bilgi_rotasi_word_hunt_progress_v1_`
- old v3 progress protected
- historical Segment1/access/reward semantics frozen legacy L1–10 authority üzerinden korunur

Validation-green exact implementation evidence:
- Cumulative Validation #168 — Run ID `35646621194` — **SUCCESS**
- Content Factory #43 — Run ID `35646621195` — **SUCCESS**
- Route Catalog #264 — Run ID `35646621246` — **SUCCESS**
- Android Visual #648 — Run ID `35646621185` — **SUCCESS**
- Trilogy Runtime #157 — Run ID `35646621192` — **SUCCESS**
- Orman Content #54 — Run ID `35646621186` — **SUCCESS**
- Orman/Kadim #224 — Run ID `35646621268` — **SUCCESS**
- AdMob #1025 — Run ID `35646621209` — **SUCCESS**

No Wave10B / L21+ / other-route L11+ / artwork / release / merge action bu closure kapsamına dahil değildir.

---

> Aşağıdaki eski kayıtlar tarihsel bağlam olarak korunur.

## 31 Ağustos 2026 — V5 exact-reference asset entegrasyonu + GÖRSEL KABUL GERİ ÇEKİLDİ / RUNTIME FAIL

- Entegrasyon branch'i: `feat/kelime-avi-v5-reference-assets-integration-20260831`.
- Product integration commit: `50ab6c8da3a4d6683568c71d52f893c5dfe2e9f7` — `feat(kelime-avi): integrate approved V5 reference assets`.
- Draft PR: **#161** — OPEN / DRAFT / merged=false; base `feat/kelime-avi-8x8-content-v1-20260829` (`5362c094...`).
- Sürüm: `1.68.19+109` / değişmedi.
- Canonical gameplay grid: **8×8 / LOCKED / UNCHANGED**. 6×10 veya başka geometriye dönüş yok.
- Kullanıcı görsel QA ile kilitlenen 11 production raster asset: harbor background, idle/found cell, status panel, word plaque, bonus plaque, instruction panel, back/search/mistake/timer icon. `icon_anchor.png` ve `icon_compass.png` ayrı production overlay değildir; instruction panel içinde bake olduğu için UNUSED/REJECTED tutulur.
- Asset commit `0d73ab3bbf5217caf203876c8c02fd5673d13d9e`; 11/11 SHA-256 doğrulaması PASS.
- Entegrasyon gate run `33379341765`: SUCCESS; deterministic presentation patch, exact asset SHA, format, `dart analyze lib/word_hunt`, 138/138 focused Kelime Avı testleri, `git diff --check` ve protected-scope kontrolü PASS.
- Gerçek Android 16 B10 ilk ekranı run `33384781507` ile üretildi; exact product SHA `50ab6c8...`, API 36 / 1080×1920 / 420 dpi, artifact `9755405253`.
- Gerçek Android found-state run `33388386388` içinde `09_B10_YOL_FOUND.png` üretildi; YOL swipe sonrası sayaç `1/9`, Y-O-L hücreleri found-state'e geçti ve visual-change gate `changed_pixels=29970` PASS. Artifact `9756762383`.
- **KRİTİK DÜZELTME:** Kullanıcıya önce gösterilen ve PASS alınan “bulunmuş” ekran gerçek Android runtime screenshot değildi; gerçek Android ekranı üzerinde görsel düzenleme ile oluşturulmuş hedef/mockup idi. Bu görsel Android kanıtı olarak sunulmamalıydı. Bu yanlış sunum nedeniyle alınan PASS **GEÇERSİZ / GERİ ÇEKİLMİŞTİR**.
- Kullanıcının bağlayıcı görsel hedefi, son mesajındaki **Görsel 1**'dir. Bu görsel yalnız hedef/reference olarak kullanılabilir; runtime kanıtı değildir.
- Kullanıcının son mesajındaki **Görsel 2**, gerçek Android runtime found-state çıktısıdır ve kullanıcı tarafından açıkça **FAIL** olarak reddedilmiştir. Mevcut runtime; hedefe göre yerleşim/ölçek, üst panel oranları, hedef plakalarının ölçüleri/boşlukları, grid hücre aralıkları ve alt panel sunumu bakımından yeterince eşleşmemektedir.
- Bu nedenle önceki “CURRENT V5 EXACT-REFERENCE VISUAL PASS / RUNTIME FOUND-STATE VISUAL PASS” kaydı current değildir ve bu checkpoint tarafından **supersede** edilmiştir.
- Run `33388386388` genel sonucu ayrıca FAILURE'dır; PNG/gesture kanıtlarından sonra exact log-string `grep` assertion'ı exit 1 vermiştir. Bu run teknik SUCCESS diye yazılmaz.
- Bilgi Rotası public repo olduğundan standart GitHub-hosted Actions dakika kotası bu proje için çalışma freni sayılmaz; gereksiz run yine yapılmaz, artifact/cache storage ayrı izlenir ve paid/larger runner otomatik yetkilendirilmiş değildir.

**Kalan kapılar:** gerçek Android runtime görünümünü bağlayıcı Görsel 1 hedefiyle eşleştirmek; sonra gerçek Android initial + found-state screenshot üzerinden yeniden kullanıcı görsel kabulü almak; `ERROR_STATE_VISUAL` ve exact `REFERENCE_FONT` doğrulamaları; B5 60s + B10 120s gerçek insan süre/zorluk playtesti; PR #161/#158 Ready kararı; Levent'in ayrıca açık merge onayı; production `lib/main.dart` navigasyon entegrasyonu ayrı kapsam.

**Durum:** ASSET/FLUTTER TECHNICAL GATE PASS / CURRENT ANDROID RUNTIME VISUAL FAIL / USER VISUAL ACCEPTANCE OPEN / READY-MERGE YOK.

---

## 0T. PR #147 Başlangıç Limanı MASTER ART production merge checkpoint — TAMAMLANDI

- Levent gerçek Android 16 production görünümünü ve **MASTER ART raster + şeffaf hitbox** mimarisini açıkça kabul etti.
- PR #147 controlled squash merge ile PR #132 feature branch'ine alındı.
- Merge SHA: `d118aa98c5551cb3b4418f61047f6a730406d963`.
- Issue #109 `Photo 1.jpg` Başlangıç Limanı için tek bağlayıcı MASTER ART'tır.
- Production `WordHuntReferenceRouteScreen` MASTER ART raster görünür taban + şeffaf hitbox mimarisini kullanır.
- Node 9 normal/open'dır; 7 tamamlanınca 8 + 9 açılır; 9 gerçek callback üretir.
- Final 10, node 9 tamamlanmadan locked ve callback üretmez.
- MASTER ART görünür rota/node/plaque/kontrol sanatı ikinci kez komple Flutter katmanı olarak çizilmez; yalnız gerekli state farkı minimum override alır.

PR #147 pre-merge exact-head kanıtı:
- Production Android 16 run `32781169538`: SUCCESS; artifact `9540046796`.
- Pixel-proof run `32781169568`: SUCCESS; artifact `9540079789`.
- Focused Kelime Avı `110/110 PASS`.
- `dart analyze lib/word_hunt`: `No issues found`.
- Runtime gates PASS; app crash/ANR/FATAL/process-death: 0.

**Durum:** PR #147 MERGED / VISUAL PASS / ARCHITECTURE PASS.

---

## 0U. PR #150 Dynamic progression doğruluğu — TAMAMLANDI / MERGED

PR #132 final incelemesinde flattened MASTER ART içindeki demo progression bilgisinin runtime state ile çelişebildiği bulundu:

- MASTER ART'ta sabit `12 / 30`,
- sabit dolu/boş yıldızlar,
- raster locked/open state

gerçek `WordHuntProgressSnapshot` değiştiğinde yanlış bilgi gösterebiliyordu.

- gerçek `X / 30`,
- level 1–10 gerçek `0–3` yıldız state'i,
- gerçek locked/open state,
- node 9 open state'i.

İlk deneme ikinci yıldız satırı oluşturduğu için görsel FAIL kabul edildi. MASTER ART'ın gerçek star-slot piksel yuvaları ölçülerek düzeltildi. Bonus 8, normal 9 ve büyük final 10 generic çap hesabı kullanmaz.

Son doğrulanmış kod HEAD: `aebb384912d379fc87908e4e79b31aecdaba427b`.

- Android 16 production run `32969604847`: SUCCESS.
- Artifact `9607328059`.
- Digest `sha256:a1c01a5acb1c515b584e6cf1d24dea63ece57eaa9417f279f4b52f17e41ef776`.
- Focused progression/route test adımı: PASS.
- Node 9 callback: PASS.
- Node 10 locked/no callback: PASS.
- App process failure scan: PASS.
- MASTER ART comparison: PASS.
- Production screenshot görsel QA: eski demo star kalıntısı yok; proof progression ile görünür state tutarlı.

PR #150 merge SHA: `d64fcd4ea63f173c6653ff33926b12a6c99ef37d`.

Production asset contract da kullanıcı tarafından kabul edilen mimariye hizalandı:

`MASTER ART RASTER → TRANSPARENT INTERACTION HITBOXES → MINIMUM LOCAL STATE OVERRIDES`

**Durum:** TAMAMLANDI / PR #132 FEATURE BRANCH'İNE MERGED.

---

## 30 Ağustos 2026 — PR #158 V5 gameplay tema checkpoint'i

- Branch: `feat/kelime-avi-8x8-content-v1-20260829`.
- Base: `release/final-closed-test-aab-1.68.8` / başlangıç doğrulamasında `3a0f722a5d1acdb482d9c3ce62711617ebf79d3e`.
- Başlangıç ürün HEAD: `69efcd17606d339233e1d9ca6183d9ac37ed5b5c`.
- Sürüm: `1.68.19+109` (değişmedi).
- Production gameplay görünümü gece limanı, lacivert-altın panel/etiket, serif başlık, responsive 8×8 grid ve alt talimat plakasıyla bağlayıcı tema referansına hizalandı.
- Background-only mevcut asset kullanıldı; bütün referans ekranı raster UI olarak kullanılmadı.
- 10 bölüm, 8×8 içerik, gesture/timer/bonus/soft-time/result/progression sözleşmeleri korunur.
- Otomatik/widget ve statik kapılar PASS. QA-only head `342e246e1e47dd595c9cebb4ab52c701636f8685` için Android 16 run `33308127773` / job `99248192399` SUCCESS; artifact `9731244720` içinde yedi gameplay screenshot'ı, UI XML, logcat ve hashler bulunur.
- B1/B5/B8/B10 64/64, gerçek ANKARA + ters BAŞKENT swipe, B5 74s soft-time ve uygulama process-failure taraması PASS. Teknik görsel kanıt PASS.
- PR #158 Draft kalır; Ready/merge/auto-merge yoktur.

## 31 Ağustos 2026 — PR #158 V5 nihai görsel kullanıcı kabulü — TARİHSEL / SUPERSEDED

- Refined V5 gerçek Android 16 B10 render'ı, branch HEAD `67f7365e0dfd9689f606bc990c2351a56b77899e` için run `33331395168`, artifact `9737903231` içindeki `04_B10_INITIAL.png` dosyasından doğrudan incelendi.
- Run `33331395168` genel sonucu QA otomasyon/harness failure olduğu için teknik PASS kanıtı sayılmaz; teknik gameplay/görsel kanıtı run `33308127773` / artifact `9731244720` PASS olarak korunur.
- Bu görünüm daha sonra kullanıcı tarafından exact-reference gereksinimi nedeniyle yeterli kabul edilmedi ve yukarıdaki exact-reference çalışma hattı tarafından supersede edildi.
- Production `lib/main.dart` ana navigasyon entegrasyonu hâlâ ayrı kapsam/branch/PR işidir.

**Durum:** TARİHSEL / CURRENT VISUAL ACCEPTANCE İÇİN YUKARIDAKİ FAIL CHECKPOINT ESASTIR.

---

## 0V. PR #149 proje hafızası merge checkpoint — TAMAMLANDI

- PR #149 PR #147 sonrası yaşayan proje hafızası checkpoint'ini taşıdı.
- Hedef: PR #132 feature branch.
- Merge SHA: `adb4557a9a95dd624166b6b08a9e0ab27b1e4f80`.
- Bu merge ürün kodunu değiştirmedi.

**Durum:** MERGED.

---

## 0W. PR #132 Başlangıç Limanı final entegrasyon kapısı — AÇIK

- PR #132 başlığı güncellendi: `feat(kelime-avi): Baslangic Limani MASTER ART production pilot`.
- Durum: `OPEN / DRAFT / MERGED=false`.
- Base: `fix/kelime-avi-approved-reference-pixel-match-20260823` / `bc8a03bfefd401570e0c51cc4aab4206ea45d363`.
- Head branch: `feat/kelime-avi-baslangic-limani-asset-first-20260824`.
- PR #147, PR #150 ve PR #149 artık bu branch'e alınmıştır.
- Sürüm hâlâ `1.68.19+109`.

**Kalan final kapılar:**
1. Bütün merge/docs commit'lerini içeren yeni exact HEAD üzerinde focused test + analyze + `git diff --check`.
2. Yeni exact HEAD Android 16 production route proof.
3. Crash/ANR/FATAL/process-death taraması.
4. Final production screenshot/artifact incelemesi.
5. Levent'in ayrıca açık PR #132 merge onayı.

**Durum:** AÇIK / FINAL EXACT-HEAD DOĞRULAMA + AYRI MERGE ONAYI GEREKİYOR.

---

## 0X. Kelime Avı production ana navigasyon entegrasyonu — AYRI KAPSAM

- Production `lib/main.dart` bu pilot merge zincirinde değiştirilmedi.
- Başlangıç Limanı production route ekranının gerçek uygulama navigasyonuna bağlanması ayrı görevdir.
- Release/main, AdMob/Firebase, BoardMap/67 node/3B ve `assets/questions.json` bu entegrasyon uğruna kontrolsüz değiştirilemez.

**Durum:** AÇIK / AYRI BRANCH + TEST + PR + ONAY GEREKİYOR.

---

## Korunan diğer açık alanlar

- Soru geri bildirimleri: gerçek düzeltme merge edilmeden Sheet satırı kapanmaz; metin + 4 seçenek + doğru indeks + açıklama + kategori + zorluk birlikte doğrulanır.
- Rewarded/SSV canlı no-double, başarısız reklamda hak/retry ve farklı oyunlarda toplam kota olmaması fiziksel kabul maddeleri.
- Play/Firebase signing SHA rol eşlemesi ve canlı production/Play kabul maddeleri.
- İki cihaz Canlı Düello uçtan uca fiziksel kabulü.
- 3B tahta: BoardMap/67 node korunur; 8 konsept rozet / 6 fiziksel rozet eşlemesi çözülmeden ilerlenmez.
- Mağaza/tanıtım varlıklarının canlı Play Console durumu.
