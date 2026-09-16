# Bilgi Rotası — Genel Proje Özeti

**Son güncelleme:** 16 Eylül 2026

## YENİ SOHBET DEVİR NOTU — ÖNCE BUNU OKU

Yeni sohbette işe başlamadan önce şu sırayı uygula:

1. Bu dosyanın tamamını oku: `docs/project-memory/GENEL_PROJE_OZETI.md`.
2. Son authoritative sohbet devrini oku: `docs/project-memory/SOHBET_DEVIR_2026-09-16_ORMAN_YOLU_CONTENT_POLISH_KAPANIS.md`.
3. İlgili mimari karar için `KELIME_AVI_REUSABLE_HARITA_KARARI.md` dosyasını oku.
4. Sonra canlı GitHub durumunu kendin doğrula: repo, target branch, exact HEAD, açık PR'lar ve ilgili GitHub Actions sonuçları.
5. Çelişki varsa öncelik: **canlı GitHub > proje bellek dosyaları > eski sohbetler**.

Repo: `ZMilaStudio/BilgiRotasi`  
Target branch: `release/final-closed-test-aab-1.68.8`  
PR #205 squash merge baseline / product HEAD: `b114bff436fb61912d380dbcb84340d1490f6f4a`

## 16 Eylül 2026 — Orman Yolu content polish + data-driven kitap TAMAMLANDI / MERGED

PR #205 ile Orman Yolu'nun content kalite-polisajı tamamlandı ve merge öncesi bulunan legacy forest-book blocker kapatıldı.

- PR: **#205 — `feat(kelime-avi): polish Orman Yolu content`**
- Approved feature head: `c7ac3cc2644cb45b7f1da004ed1de0533ed5d025`
- Approved head tree: `43d41a9f3048c0849ab659489f8cfa1661e1745f`
- Squash merge commit: `b114bff436fb61912d380dbcb84340d1490f6f4a`
- Merge commit tree: `43d41a9f3048c0849ab659489f8cfa1661e1745f`
- Squash parent: `933361681345a0d62da10f158d90f658ce63a898`
- Approved head tree ile squash merge tree **birebir aynıdır**.
- Source branch `feat/kelime-avi-orman-yolu-content-polish` bilerek silinmedi.

### Orman Yolu bilgi kartları

`WordHuntOrmanContent.infoCards` artık boş değildir. Production'da 6 özgün **Doğa** kartı vardır:

- `orman-info-agac` — **Ağaç** — L1
- `orman-info-mese` — **Meşe** — L2
- `orman-info-mantar` — **Mantar** — L4
- `orman-info-kozalak` — **Kozalak** — L5
- `orman-info-sincap` — **Sincap** — L6
- `orman-info-geyik` — **Geyik** — L7

L3 ve L8–L10 için `infoCardIds` boş kalır. L1–L7 gameplay payload'ı (grid / target / bonus / type / timing / starRules) korunmuştur; yalnız onaylı bilgi kartı bağlantıları eklenmiştir.

### Orman Yolu L8–L10 content polish

L8–L10 eski tekrar ağırlıklı içerikten çıkarılıp yeni statik/deterministic 8×8 grid ve exact target/bonus sözleşmesine geçirilmiştir:

- **L8 — YAĞMURDAN SONRA**
  - target: `YAĞMUR`, `ÇAMUR`, `DAMLA`, `DERE`, `PATİKA`
  - bonus: `ISLAK`
- **L9 — ORMANIN İZLERİ**
  - target: `İZLER`, `TÜY`, `TOYNAK`, `YEMİŞ`, `OYUK`
  - bonus: `KABUK`
- **L10 — YOLUN SONU**
  - type: `routeFinal`
  - target: `ORMAN`, `KEŞİF`, `YOLCULUK`, `CANLI`, `DOĞA`, `UYUM`
  - bonus: `MACERA`
  - `timeLimitSeconds = 120`
  - mevcut star/mistake contract korunur.

Runtime random grid generation eklenmemiştir.

### Production kitap akışı — DATA-DRIVEN

PR #205 içinde bulunan pre-merge blocker da kapatıldı. Artık **tüm production rotaları aynı generic/data-driven kitap akışını kullanır**:

`_activeInfoCards` + `_progress.unlockedInfoCardIds`

Bu sözleşme şu rotaların tamamı için geçerlidir:

- Başlangıç Limanı
- Gökyüzü
- Orman Yolu
- Kadim Orman

Legacy forest özel kitap sistemi kaldırılmıştır:

- `_showOrmanTopicBook()` yok,
- `_TopicGuide` yok,
- `_ormanTopicGuides` yok,
- `route.theme == 'orman'` book special-case yok,
- Orman Yolu / Kadim Orman route-id özel book branch yok.

Kitap yalnız aktif rotanın kendi `_activeInfoCards` listesindeki ve progress'te unlock edilmiş kartları gösterir. Başka rotanın unlocked card ID'si aynı snapshot içinde bulunsa bile görünmez. **Cross-route card isolation** testle kilitlidir.

Info-card unlock/persistence contract'ı değişmedi:

gameplay → `level.infoCardIds` → eşleşen kelime → `unlockedInfoCardIds` → persisted progress.

Bu nedenle PR #204 ile eklenen Kadim Orman bilgi kartları da artık production kitap akışında gerçek kullanıcı içeriği olarak gösterilebilir.

### PR #205 kalite / CI kapanışı — PASS

Exact approved HEAD: `c7ac3cc2644cb45b7f1da004ed1de0533ed5d025`

- `WordHuntDefinitionValidator`: **PASS**
- `WordHuntContentValidator`: **PASS**
- L1–L7 gameplay unchanged regression: **PASS**
- info-card exact copy / mapping: **PASS**
- L8/L9/L10 content contract: **PASS**
- target/bonus grid validity: **PASS**
- fresh Orman book empty-state: **PASS**
- Orman info-card display: **PASS**
- Kadim Orman info-card display: **PASS**
- cross-route card isolation: **PASS**
- Başlangıç/Gökyüzü generic book regression: **PASS**
- selector/unlock regression: **PASS**
- Kelime Avı Orman Yolu içerik kapısı — Run **#7**, ID `35114163037`: **SUCCESS**
- Kelime Avı route catalog kapısı — Run **#83**, ID `35114162746`: **SUCCESS**
- Orman Yolu Android çoklu ekran kanıtı — Run **#27**, ID `35114162859`: **SUCCESS**
- Kelime Avı Android 16 görsel kanıtı — Run **#445**, ID `35114162774`: **SUCCESS**
- AdMob PR doğrulaması — Run **#822**, ID `35114162768`: **SUCCESS**
- repo-geneli analyze/tests, release APK, package/manifest ve Android 16 cold-start: **SUCCESS**

## Kadim Orman özgün content baseline — KORUNUYOR

PR #204 ile Kadim Orman'ın Orman Yolu gameplay clone/reuse borcu kapatıldı. Kadim Orman production'da kendi statik/deterministic 8×8 grid, targetWords, bonusWords ve 6 özgün bilgi kartını kullanır.

Korunan teknik kimlikler:

- route id: `orman-2`
- user-facing title: **Kadim Orman**
- theme: `orman`
- reward id: `reward-orman-2`
- level id'leri: `orman-2-01` … `orman-2-10`
- level indexleri: `1..10`

Kadim Orman bilgi kartları:

- `kadim-info-egrelti` — L1
- `kadim-info-sis` — L2
- `kadim-info-misel` — L4
- `kadim-info-baykus` — L5
- `kadim-info-kaynak` — L7
- `kadim-info-cinar` — L9

PR #205 Kadim Orman gameplay content'ini değiştirmedi; yalnız generic kitap akışı sayesinde bu kartların production book içinde görünmesini sağladı.

## Kadim Orman selector / progression baseline — KORUNUYOR

- selector sırası: **Başlangıç Limanı → Gökyüzü → Orman Yolu → Kadim Orman**,
- Kadim Orman selector'da en baştan görünür,
- fresh progress durumunda kilitlidir,
- exact locked copy: **“Orman Yolu’nu tamamlayarak aç.”**,
- Orman Yolu level 9 tamamken kilitli kalır,
- Orman Yolu level 10 tamamlanınca açılır,
- 30/30 veya toplam yıldız unlock şartı yoktur,
- kendi içinde 1→10 progression kullanır,
- Orman Yolu ve Kadim Orman progression identity'leri ayrıdır,
- generic `WordHuntRouteUnlockRule.routeComplete` ve data-driven `lockedMessage` korunur.

## Orman 2 / Kadim Orman immutable asset freeze

Production asset:

`assets/word_hunt/ORMAN2_FINAL_941x1672.webp`

- dimensions: **941×1672**
- bytes: **1.109.268**
- SHA-256: `aede5c6f08b6fe4cd64d17a1ef309e13256dde1c1e97fbee0c53b019f63c6c8d`
- Git blob SHA: `43233bf2b0e8f16d59a15f0fe0bcda5f5e2bb80c`

Bu asset immutable'dır. **Re-encode / recompress / resize / crop / recolor / yeniden üretme yapılmaz.**

## Kadim Orman runtime baseline — KORUNUYOR

PR #202 ile merge edilen runtime/presentation baseline'ı korunur:

- technical route id `orman-2`,
- visual theme id `orman-2-production`,
- `referenceCanvasSize = 411×731`,
- `extendTallAmbientFromArtworkEdges = true`,
- `artworkOverlayMode = embeddedRouteLiveNodes`,
- dekoratif rota raster içindedir; live Flutter route painter kapalıdır,
- node/progression/chrome canlı Flutter katmanındadır,
- Orman 1 node asset ailesi reuse edilir,
- NodeSkin refactor yoktur,
- route/theme-id özel renderer `if` yoktur,
- normalized stops değiştirilmemiştir.

## Source branch durumu

Owner ayrıca istemeden aşağıdaki source branch'ler silinmez:

- PR #205: `feat/kelime-avi-orman-yolu-content-polish` — tutuluyor.
- PR #204: `feat/kelime-avi-kadim-orman-original-content` — tutuluyor.
- PR #203: `feat/kelime-avi-kadim-orman-progression` — tutuluyor.
- PR #202: `feat/kelime-avi-orman2-runtime-pilot-20260916` — tutuluyor.

## SIRADAKİ AUDIT — Rota açılma sırası / tutarlılık

Henüz ürün kararı verilmemiştir. Bir sonraki kalite incelemesi yalnızca mevcut unlock sırasının UI ile tutarlılığını audit edecektir.

İncelenecek mevcut davranış:

- Gökyüzü, Başlangıç Limanı'nda **18 yıldızla** açılıyor.
- Orman Yolu, Başlangıç Limanı **final bölümünün tamamlanmasıyla** açılıyor.
- Bu nedenle teorik olarak kullanıcı Başlangıç Limanı'nı 18 yıldızdan az puanla tamamlayıp Orman Yolu'nu açabilirken Gökyüzü kilitli kalabilir.
- Selector UI sırası ise **Başlangıç Limanı → Gökyüzü → Orman Yolu → Kadim Orman** şeklinde lineer bir yol izlenimi veriyor.

Bu kayıt çözüm veya yeni unlock kuralı belirlemez; yalnız sıradaki **ROTA AÇILMA SIRASI / TUTARLILIK AUDITİ** başlangıç noktasını sabitler.

## Kelime Avı — korunan kanonik progression ve release kuralları

- Her 10-bölümlük rotada bölüm progression'ı `1→2→3→4→5→6→7→8→9→10` şeklindedir.
- Ortak motor `WordHuntRouteProgressEngine.isLevelUnlocked`; tema/artwork progression mantığını değiştiremez.
- Gökyüzü kapısı: Başlangıç Limanı'ndan 18 yıldız.
- Orman Yolu kapısı: Başlangıç Limanı Bölüm 10 completion.
- Kadim Orman kapısı: Orman Yolu Bölüm 10 completion; yıldız toplamı şartı yoktur.
- Grid: **8×8 / 64 hücre — LOCKED**.
- B5 60 sn, B10 120 sn soft challenge; hard-fail değildir.
- Minimum Kelime Avı yayın stoğu: **200 hazır/doğrulanmış bölüm**.
- 200/200 release-stock gate ve runtime/fiziksel kabul tamamlanmadan yeni Kelime Avı production release'i Play'e yüklenmez.
- `assets/questions.json`, BoardMap/67 node, Firebase, signing, version ve Play kapsamı açık owner kararı olmadan değiştirilmez.

**DEVİR SON DURUMU:** PR #205 MERGED / product merge baseline `b114bff436fb61912d380dbcb84340d1490f6f4a` / approved head `c7ac3cc...` / approved ve merge tree `43d41a9f...` birebir aynı / Orman Yolu 6 özgün bilgi kartı + L8–L10 content polish production'da / tüm production rotaları generic data-driven kitap akışında / legacy forest-book borcu kapalı / Kadim Orman kartları production kitapta kullanılabilir / test ve CI kapanışı PASS / source branch tutuluyor / sıradaki konu rota açılma sırası-tutarlılık auditi.