# Bilgi Rotası — Genel Proje Özeti

**Son güncelleme:** 16 Eylül 2026

## YENİ SOHBET DEVİR NOTU — ÖNCE BUNU OKU

Yeni sohbette işe başlamadan önce şu sırayı uygula:

1. Bu dosyanın tamamını oku: `docs/project-memory/GENEL_PROJE_OZETI.md`.
2. Son authoritative sohbet devrini oku: `docs/project-memory/SOHBET_DEVIR_2026-09-16_LINEAR_ROUTE_PROGRESSION_KAPANIS.md`.
3. İlgili mimari karar için `KELIME_AVI_REUSABLE_HARITA_KARARI.md` dosyasını oku.
4. Sonra canlı GitHub durumunu kendin doğrula: repo, target branch, exact HEAD, açık PR'lar ve ilgili GitHub Actions sonuçları.
5. Çelişki varsa öncelik: **canlı GitHub > proje bellek dosyaları > eski sohbetler**.

Repo: `ZMilaStudio/BilgiRotasi`  
Target branch: `release/final-closed-test-aab-1.68.8`  
PR #206 squash merge baseline / product HEAD: `7d1d699623200601ad867eb6dda852feede587eb`

## 16 Eylül 2026 — LINEER ROTA PROGRESSION TAMAMLANDI / MERGED

PR #206 ile Kelime Avı production rota açılma zinciri selector sırasıyla tam lineer hale getirildi.

- PR: **#206 — `feat(kelime-avi): enforce linear route progression`**
- Approved feature head: `8998e124eaf2afdffd618b0f60212ba2196172b3`
- Approved head tree: `02e263e0ade579080f7aa8791de3a33373cf1345`
- Squash merge commit: `7d1d699623200601ad867eb6dda852feede587eb`
- Merge commit tree: `02e263e0ade579080f7aa8791de3a33373cf1345`
- Squash parent: `1ca969a952f44ee72381c4ed704a534c7924cbbd`
- Approved head tree ile squash merge tree **birebir aynıdır**.
- Source branch `feat/kelime-avi-linear-route-progression` bilerek silinmedi.

### Authoritative production unlock zinciri

Production sıra artık kesin olarak:

**Başlangıç Limanı → Gökyüzü Adaları → Orman Yolu → Kadim Orman**

- **Başlangıç Limanı:** her zaman açık.
- **Gökyüzü Adaları:** prerequisite `Başlangıç Limanı`; rule `routeComplete`; Başlangıç final tamamlanmış + toplam en az 18 Başlangıç yıldızı gerekir.
  - exact locked copy: **“Başlangıç Limanı’nı tamamla ve en az 18 yıldız kazan.”**
- **Orman Yolu:** prerequisite `Gökyüzü Adaları`; rule `routeComplete`; Gökyüzü final tamamlanmış + toplam en az 18 Gökyüzü yıldızı gerekir.
  - exact locked copy: **“Gökyüzü Adaları’nı tamamla ve en az 18 yıldız kazan.”**
- **Kadim Orman:** prerequisite `Orman Yolu`; rule `routeComplete`; Orman Yolu `unlockStarsRequired = 0` olduğu için final bölümünün tamamlanması yeterlidir; ekstra 18/30 yıldız kapısı yoktur.
  - exact locked copy: **“Orman Yolu’nu tamamlayarak aç.”**

### `routeComplete` authoritative semantiği

`WordHuntRouteUnlockRule.routeComplete` artık yalnız prerequisite rotanın son level completion durumuna bakmaz. Authoritative davranış:

`WordHuntRouteProgressEngine.isRouteComplete(prerequisiteRoute, progress)`

`isRouteComplete` contract'ı korunur:

- final level type `routeFinal` olmalı,
- final level completed olmalı,
- `totalStars >= route.unlockStarsRequired` olmalı.

Bu nedenle `routeComplete` gerçekten prerequisite rotanın kendi completion contract'ını temsil eder.

### Legacy progress kararı

Grandfather / legacy unlock istisnası **yoktur**.

- eski downstream progress silinmez,
- migrate edilmez,
- prerequisite'i bypass ettirmez,
- eski Orman progress'i varken Gökyüzü route-complete değilse Orman Yolu locked kalır,
- Gökyüzü sonradan tamamlandığında Orman yeniden açılır ve mevcut Orman progress'i aynen korunur.

### PR #206 test / CI kapanışı — PASS

Exact approved HEAD: `8998e124eaf2afdffd618b0f60212ba2196172b3`

- 18 yıldız ama Başlangıç final yok → Gökyüzü locked: **PASS**
- Başlangıç final var ama <18 yıldız → Gökyüzü locked: **PASS**
- Başlangıç route-complete → Gökyüzü unlocked: **PASS**
- Gökyüzü incomplete → Orman locked: **PASS**
- Gökyüzü final + <18 yıldız → Orman locked: **PASS**
- Gökyüzü route-complete → Orman unlocked: **PASS**
- Orman final 1 yıldız → Kadim unlocked: **PASS**
- Orman yıldızı yüksek ama final yok → Kadim locked: **PASS**
- legacy Orman progress + incomplete Gökyüzü → locked: **PASS**
- prerequisite sonradan tamamlanınca downstream progress korunur: **PASS**
- `routeComplete` threshold/final/zero-threshold semantic regression: **PASS**
- Kelime Avı route catalog kapısı — Run **#84**, ID `35120880714`: **SUCCESS**
- Orman Yolu Android çoklu ekran kanıtı — Run **#28**, ID `35120880709`: **SUCCESS**
- Kelime Avı Android 16 görsel kanıtı — Run **#446**, ID `35120880717`: **SUCCESS**
- AdMob PR doğrulaması — Run **#823**, ID `35120880650`: **SUCCESS**
- `flutter analyze`, repo-geneli `flutter test`, release APK, package/manifest ve Android 16 cold-start: **SUCCESS**

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

- **L8 — YAĞMURDAN SONRA** — target `YAĞMUR`, `ÇAMUR`, `DAMLA`, `DERE`, `PATİKA`; bonus `ISLAK`; yeni deterministic 8×8 grid.
- **L9 — ORMANIN İZLERİ** — target `İZLER`, `TÜY`, `TOYNAK`, `YEMİŞ`, `OYUK`; bonus `KABUK`; yeni deterministic 8×8 grid.
- **L10 — YOLUN SONU** — `routeFinal`; target `ORMAN`, `KEŞİF`, `YOLCULUK`, `CANLI`, `DOĞA`, `UYUM`; bonus `MACERA`; `timeLimitSeconds = 120`; mevcut star/mistake contract korunur; yeni deterministic 8×8 grid.

Runtime random grid generation eklenmemiştir.

### Production kitap akışı — DATA-DRIVEN

Artık **tüm production rotaları aynı generic/data-driven kitap akışını kullanır**:

`_activeInfoCards` + `_progress.unlockedInfoCardIds`

Bu sözleşme Başlangıç Limanı, Gökyüzü, Orman Yolu ve Kadim Orman için geçerlidir. Legacy forest özel kitap sistemi (`_showOrmanTopicBook`, `_TopicGuide`, `_ormanTopicGuides`, `route.theme == 'orman'` book branch) kaldırılmıştır. Kitap yalnız aktif rotanın kendi `_activeInfoCards` listesindeki ve progress'te unlock edilmiş kartları gösterir; cross-route card isolation testle kilitlidir.

Info-card unlock/persistence contract'ı değişmedi:

gameplay → `level.infoCardIds` → eşleşen kelime → `unlockedInfoCardIds` → persisted progress.

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

## Kadim Orman selector / progression baseline — KORUNUYOR

- selector sırası: **Başlangıç Limanı → Gökyüzü → Orman Yolu → Kadim Orman**,
- Kadim Orman selector'da en baştan görünür,
- fresh progress durumunda kilitlidir,
- exact locked copy: **“Orman Yolu’nu tamamlayarak aç.”**,
- Orman Yolu `routeComplete` olduğunda açılır,
- Orman Yolu `unlockStarsRequired = 0` olduğu için final completion yeterlidir,
- 30/30 veya ek toplam yıldız unlock şartı yoktur,
- kendi içinde 1→10 progression kullanır,
- Orman Yolu ve Kadim Orman progression identity'leri ayrıdır,
- data-driven `lockedMessage` ve generic `WordHuntRouteUnlockRule.routeComplete` kullanılır.

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

- PR #206: `feat/kelime-avi-linear-route-progression` — tutuluyor.
- PR #205: `feat/kelime-avi-orman-yolu-content-polish` — tutuluyor.
- PR #204: `feat/kelime-avi-kadim-orman-original-content` — tutuluyor.
- PR #203: `feat/kelime-avi-kadim-orman-progression` — tutuluyor.
- PR #202: `feat/kelime-avi-orman2-runtime-pilot-20260916` — tutuluyor.

## SIRADAKİ AUDIT — Challenge / final yıldız – zaman – ödül dengesi

Henüz yeni star/time/reward kararı verilmemiştir. Bir sonraki kalite incelemesi yalnız aşağıdaki mevcut sözleşmeleri audit edecektir:

- Başlangıç Limanı challenge/final star rule'ları,
- Gökyüzü challenge/final star rule'ları,
- Orman Yolu challenge/final star rule'ları,
- Kadim Orman challenge/final star rule'ları,
- `timeLimitSeconds` değerleri,
- `twoStarMaxMistakes` / `threeStarMaxMistakes`,
- `twoStarMaxSeconds` / `threeStarMaxSeconds` kullanımı,
- `routeFinal` bölümlerin gerçekten final hissi verip vermediği,
- `routeRewardId` değerlerinin runtime'da gerçek kullanıcı ödülü üretip üretmediği,
- rotalar arasında zorluk artışının tutarlı olup olmadığı.

Bu kayıt yeni denge çözümü belirlemez ve 5. rota tasarlamaz; yalnız sıradaki **CHALLENGE / FINAL YILDIZ – ZAMAN – ÖDÜL DENGESİ AUDITİ** başlangıç noktasını sabitler.

## Kelime Avı — korunan kanonik progression ve release kuralları

- Her 10-bölümlük rotada bölüm progression'ı `1→2→3→4→5→6→7→8→9→10` şeklindedir.
- Ortak motor `WordHuntRouteProgressEngine.isLevelUnlocked`; tema/artwork progression mantığını değiştiremez.
- Production rota sırası ve unlock zinciri lineerdir: **Başlangıç Limanı → Gökyüzü Adaları → Orman Yolu → Kadim Orman**.
- Gökyüzü kapısı: Başlangıç Limanı `routeComplete` = final complete + en az 18 yıldız.
- Orman Yolu kapısı: Gökyüzü Adaları `routeComplete` = final complete + en az 18 yıldız.
- Kadim Orman kapısı: Orman Yolu `routeComplete`; Orman Yolu `unlockStarsRequired = 0`, dolayısıyla final completion yeterlidir.
- Legacy downstream progress saklanır fakat prerequisite bypass ettirmez.
- Grid: **8×8 / 64 hücre — LOCKED**.
- B5 60 sn, B10 120 sn soft challenge; hard-fail değildir.
- Minimum Kelime Avı yayın stoğu: **200 hazır/doğrulanmış bölüm**.
- 200/200 release-stock gate ve runtime/fiziksel kabul tamamlanmadan yeni Kelime Avı production release'i Play'e yüklenmez.
- `assets/questions.json`, BoardMap/67 node, Firebase, signing, version ve Play kapsamı açık owner kararı olmadan değiştirilmez.

**DEVİR SON DURUMU:** PR #206 MERGED / product merge baseline `7d1d699623200601ad867eb6dda852feede587eb` / approved head `8998e124...` / approved ve merge tree `02e263e0...` birebir aynı / production rota zinciri tam lineer / `routeComplete` gerçek `isRouteComplete` semantiğinde / legacy downstream progress korunuyor fakat prerequisite bypass etmiyor / PR #206 CI kapanışı PASS / source branch tutuluyor / sıradaki konu challenge-final yıldız-zaman-ödül dengesi auditi.