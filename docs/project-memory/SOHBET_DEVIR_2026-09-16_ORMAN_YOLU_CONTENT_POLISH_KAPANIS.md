# Sohbet Devri — Orman Yolu Content Polish Kapanışı

**Tarih:** 16 Eylül 2026  
**Repo:** `ZMilaStudio/BilgiRotasi`  
**Target branch:** `release/final-closed-test-aab-1.68.8`

## Nihai durum

**Orman Yolu content kalite-polisajı ve data-driven production kitap düzeltmesi tamamlandı, final exact HEAD üzerindeki ilgili test/CI kapıları geçti ve PR #205 ile squash merge edildi.**

Bu devir notu, önceki `SOHBET_DEVIR_2026-09-16_KADIM_ORMAN_ORIGINAL_CONTENT_KAPANIS.md` dosyasındaki “Orman Yolu infoCards boş / kitap içeriği sıradaki iş” başlangıç noktasını supersede eder.

## PR #205 kapanış kaydı

- PR: **#205 — `feat(kelime-avi): polish Orman Yolu content`**
- Approved feature head: `c7ac3cc2644cb45b7f1da004ed1de0533ed5d025`
- Approved head tree: `43d41a9f3048c0849ab659489f8cfa1661e1745f`
- Squash merge commit: `b114bff436fb61912d380dbcb84340d1490f6f4a`
- Merge commit tree: `43d41a9f3048c0849ab659489f8cfa1661e1745f`
- Squash parent: `933361681345a0d62da10f158d90f658ce63a898`
- Tree equality: **EVET — approved PR head tree ile squash merge tree birebir aynı.**
- PR #205 merge baseline / product HEAD: `b114bff436fb61912d380dbcb84340d1490f6f4a`.
- Source branch: `feat/kelime-avi-orman-yolu-content-polish` — bilerek silinmedi; owner ayrıca istemeden silinmez.

## Orman Yolu bilgi kartı kapanışı

`WordHuntOrmanContent.infoCards` artık production'da 6 özgün **Doğa** kartı taşır:

1. `orman-info-agac` — **AĞAÇ / Ağaç** — L1
2. `orman-info-mese` — **MEŞE / Meşe** — L2
3. `orman-info-mantar` — **MANTAR / Mantar** — L4
4. `orman-info-kozalak` — **KOZALAK / Kozalak** — L5
5. `orman-info-sincap` — **SİNCAP / Sincap** — L6
6. `orman-info-geyik` — **GEYİK / Geyik** — L7

L3 ve L8–L10 için `infoCardIds` boş kalır.

L1–L7 gameplay payload'ı korunmuştur:

- grid,
- targetWords,
- bonusWords,
- level type,
- timing,
- starRules.

Yalnız onaylanan bilgi kartı bağlantıları eklenmiştir.

## Orman Yolu L8–L10 content polish

### L8 — YAĞMURDAN SONRA

- level id: `orman-yolu-08`
- type: normal
- targetWords: `YAĞMUR`, `ÇAMUR`, `DAMLA`, `DERE`, `PATİKA`
- bonusWords: `ISLAK`
- yeni statik/deterministic 8×8 grid kullanır.

### L9 — ORMANIN İZLERİ

- level id: `orman-yolu-09`
- type: normal
- targetWords: `İZLER`, `TÜY`, `TOYNAK`, `YEMİŞ`, `OYUK`
- bonusWords: `KABUK`
- yeni statik/deterministic 8×8 grid kullanır.

### L10 — YOLUN SONU

- level id: `orman-yolu-10`
- type: `routeFinal`
- targetWords: `ORMAN`, `KEŞİF`, `YOLCULUK`, `CANLI`, `DOĞA`, `UYUM`
- bonusWords: `MACERA`
- `timeLimitSeconds = 120`
- mevcut star/mistake difficulty contract korunur.
- yeni statik/deterministic 8×8 grid kullanır.

Runtime random grid generation eklenmedi.

## Data-driven production kitap kararı

PR #205 merge öncesi blocker incelemesinde forest-theme özel book yolunun gerçek route infoCards içeriğini bypass ettiği doğrulandı. Bu borç aynı PR içinde kapatıldı.

Artık tüm production rotaları aynı generic/data-driven kitap akışını kullanır:

`_activeInfoCards` + `_progress.unlockedInfoCardIds`

Bu ortak sözleşme:

- Başlangıç Limanı,
- Gökyüzü,
- Orman Yolu,
- Kadim Orman

için aynıdır.

Legacy forest book yapıları kaldırılmıştır:

- `_showOrmanTopicBook()` yok,
- `_TopicGuide` yok,
- `_ormanTopicGuides` yok,
- `route.theme == 'orman'` book special-case yok,
- Orman Yolu / Kadim Orman route-id özel book branch yok.

### Book davranışı

- Aktif rotada henüz unlock edilmiş bilgi kartı yoksa: **“Henüz bilgi kartı açılmadı.”**
- Unlock edilmiş kart varsa mevcut generic bottom sheet açılır.
- Kartta mevcut presentation üzerinden title, shortFact, category ve word/leading bilgisi gösterilir.
- Kitap yalnız aktif rotanın kendi `_activeInfoCards` listesini sınır olarak kullanır.
- Progress snapshot içinde başka rotaya ait unlocked card ID'leri bulunsa bile görünmez.
- Cross-route card isolation testle kilitlidir.

### Unlock semantiği değişmedi

Info-card unlock/persistence zinciri aynen korunur:

`WordHuntLevelProductionScreen` → `level.infoCardIds` → eşleşen kelime → `unlockedInfoCardIds` → persisted progress.

Kartlar henüz gameplay içinde kazanılmadan kitapta gösterilmez.

Bu düzeltme sayesinde PR #204 ile eklenen Kadim Orman kartları da production kitap akışında kullanılabilir durumdadır.

## Test / kalite kapanışı

Approved exact HEAD:

`c7ac3cc2644cb45b7f1da004ed1de0533ed5d025`

Doğrulanan contract'lar:

- `WordHuntDefinitionValidator`: **PASS**
- `WordHuntContentValidator`: **PASS**
- L1–L7 gameplay unchanged: **PASS**
- info-card exact copy / mapping: **PASS**
- L8/L9/L10 exact content contract: **PASS**
- yeni L8/L9/L10 grid independence: **PASS**
- target/bonus overlap yok: **PASS**
- target ve bonus kelimeler production yön kurallarına göre gridde geçerli: **PASS**
- fresh Orman book empty-state: **PASS**
- Orman info-card display: **PASS**
- Kadim Orman info-card display: **PASS**
- cross-route card isolation: **PASS**
- Başlangıç Limanı generic book regression: **PASS**
- Gökyüzü generic book regression: **PASS**
- selector/unlock regression: **PASS**
- Kadim Orman unlock prerequisite regression: **PASS**

## CI kapanışı

Exact approved HEAD `c7ac3cc2644cb45b7f1da004ed1de0533ed5d025`:

- Kelime Avı Orman Yolu içerik kapısı — Run **#7**, ID `35114163037`: **SUCCESS**
- Kelime Avı route catalog kapısı — Run **#83**, ID `35114162746`: **SUCCESS**
- Orman Yolu Android çoklu ekran kanıtı — Run **#27**, ID `35114162859`: **SUCCESS**
- Kelime Avı Android 16 görsel kanıtı — Run **#445**, ID `35114162774`: **SUCCESS**
- AdMob PR doğrulaması — Run **#822**, ID `35114162768`: **SUCCESS**
- repo-geneli **Analiz ve tüm testler**: **SUCCESS**
- release APK: **SUCCESS**
- package/manifest: **SUCCESS**
- Android 16 cold-start: **SUCCESS**

Intermediate HEAD'lerdeki eski/stale test expectation failure'ları authoritative değildir; final merge kararı yalnız `c7ac3cc...` exact HEAD üzerindeki SUCCESS sonuçlarına dayanır.

## Korunan ürün/mimari baseline

PR #205 aşağıdakileri değiştirmedi:

- route id / reward id,
- selector sırası,
- route unlock kuralları,
- locked copy,
- progression engine,
- map geometry / normalized stops,
- visual theme / assets,
- Kadim Orman gameplay content,
- Gökyüzü gameplay content,
- Başlangıç Limanı gameplay content,
- NodeSkin,
- renderer / route-map presentation architecture.

## Source branch

`feat/kelime-avi-orman-yolu-content-polish`

Branch merge sonrasında bilerek **silinmedi**. Owner ayrıca istemeden silinmez.

PR #204, #203 ve #202 source branch'leri de owner ayrıca istemeden silinmez.

## SIRADAKİ KONU — ROTA AÇILMA SIRASI / TUTARLILIK AUDITİ

Henüz ürün çözümü veya yeni unlock kuralı belirlenmemiştir. Bir sonraki inceleme yalnız mevcut progression/selector tutarlılığını audit edecektir.

Audit başlangıç noktası:

- Gökyüzü, Başlangıç Limanı'nda **18 yıldızla** açılıyor.
- Orman Yolu, Başlangıç Limanı **final bölümünün tamamlanmasıyla** açılıyor.
- Bu nedenle teorik olarak kullanıcı Başlangıç Limanı'nı 18 yıldızdan az puanla tamamlayıp Orman Yolu'nu açabilirken Gökyüzü kilitli kalabilir.
- UI sırası ise **Başlangıç Limanı → Gökyüzü → Orman Yolu → Kadim Orman** şeklinde lineer bir yol izlenimi veriyor.

Bu dosya bu tutarsızlığa çözüm seçmez; yalnız sıradaki audit konusunu sabitler.

## Yeni sohbet başlangıç kuralı

1. `docs/project-memory/GENEL_PROJE_OZETI.md` dosyasını oku.
2. Bu dosyayı oku: `docs/project-memory/SOHBET_DEVIR_2026-09-16_ORMAN_YOLU_CONTENT_POLISH_KAPANIS.md`.
3. `KELIME_AVI_REUSABLE_HARITA_KARARI.md` dosyasını oku.
4. Canlı target HEAD ve ilgili source branch durumunu GitHub'dan doğrula.
5. PR #205 content/book kararını yeniden açma; merge ile kapanmıştır.
6. Sonraki işe **ROTA AÇILMA SIRASI / TUTARLILIK AUDITİ** ile başlanmalıdır.

**DEVİR SON DURUMU:** PR #205 MERGED / product merge baseline `b114bff436fb61912d380dbcb84340d1490f6f4a` / approved head `c7ac3cc...` / approved ve merge tree `43d41a9f...` birebir aynı / Orman Yolu 6 özgün bilgi kartı production'da / L8 Yağmurdan Sonra + L9 Ormanın İzleri + L10 Yolun Sonu production'da / tüm production rotaları generic data-driven kitap kullanıyor / cross-route isolation PASS / Kadim Orman kartları production kitapta kullanılabilir / final-head CI GREEN / source branch tutuluyor / sıradaki audit rota açılma sırası-tutarlılık.