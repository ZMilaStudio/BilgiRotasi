# Bilgi Rotası — Genel Proje Özeti

**Son güncelleme:** 16 Eylül 2026

## YENİ SOHBETTE ÖNCE BUNLARI OKU

1. `docs/project-memory/GENEL_PROJE_OZETI.md`
2. `docs/project-memory/SOHBET_DEVIR_2026-09-16_CHALLENGE_FINAL_AUDIT_BASLANGIC.md`
3. `KELIME_AVI_REUSABLE_HARITA_KARARI.md`
4. Ardından canlı GitHub durumunu yeniden doğrula: target branch, exact HEAD, açık PR'lar ve ilgili Actions sonuçları.

Çelişki varsa öncelik: **canlı GitHub > proje memory/karar dosyaları > eski sohbetler**.

Repo: `ZMilaStudio/BilgiRotasi`  
Target branch: `release/final-closed-test-aab-1.68.8`  
Bu devir hazırlanırken canlı target HEAD: `84f965328eb19430b20b95e0a251c3da4f7e27a3`  
Son product merge baseline: `7d1d699623200601ad867eb6dda852feede587eb` (PR #206)

---

## KELİME AVI — AUTHORITATIVE PRODUCTION DURUMU

Production rota sırası ve unlock zinciri artık tam lineerdir:

**Başlangıç Limanı → Gökyüzü Adaları → Orman Yolu → Kadim Orman**

### Başlangıç Limanı

- unlock: `always`
- her zaman açık.

### Gökyüzü Adaları

- prerequisite: Başlangıç Limanı
- unlock rule: `routeComplete`
- gerçek şart: Başlangıç final tamamlanmış + toplam en az 18 Başlangıç yıldızı
- exact locked copy: **“Başlangıç Limanı’nı tamamla ve en az 18 yıldız kazan.”**

### Orman Yolu

- prerequisite: Gökyüzü Adaları
- unlock rule: `routeComplete`
- gerçek şart: Gökyüzü final tamamlanmış + toplam en az 18 Gökyüzü yıldızı
- exact locked copy: **“Gökyüzü Adaları’nı tamamla ve en az 18 yıldız kazan.”**

### Kadim Orman

- prerequisite: Orman Yolu
- unlock rule: `routeComplete`
- Orman Yolu `unlockStarsRequired = 0`
- gerçek şart: Orman Yolu final bölümünün tamamlanması yeterli
- ekstra 18/30 yıldız şartı yok
- exact locked copy: **“Orman Yolu’nu tamamlayarak aç.”**

### `routeComplete` semantiği

`WordHuntRouteUnlockRule.routeComplete` authoritative olarak:

`WordHuntRouteProgressEngine.isRouteComplete(prerequisiteRoute, progress)`

sonucunu kullanır.

`isRouteComplete` contract'ı:

- final level type `routeFinal` olmalı,
- final level completed olmalı,
- `totalStars >= route.unlockStarsRequired` olmalı.

Legacy/grandfather unlock istisnası yoktur. Eski downstream progress silinmez veya migrate edilmez; ancak prerequisite'i bypass ettiremez. Prerequisite sonradan sağlandığında eski downstream progress aynen korunur.

---

## PR #206 — LINEER ROTA PROGRESSION — MERGED

PR: **#206 — `feat(kelime-avi): enforce linear route progression`**

- Approved feature head: `8998e124eaf2afdffd618b0f60212ba2196172b3`
- Approved head tree: `02e263e0ade579080f7aa8791de3a33373cf1345`
- Squash merge commit: `7d1d699623200601ad867eb6dda852feede587eb`
- Merge commit tree: `02e263e0ade579080f7aa8791de3a33373cf1345`
- Tree equality: **EVET**
- Squash parent: `1ca969a952f44ee72381c4ed704a534c7924cbbd`
- Source branch: `feat/kelime-avi-linear-route-progression` — owner istemeden silinmez.

Approved exact HEAD CI:

- Kelime Avı route catalog kapısı — Run #84 / ID `35120880714` — **SUCCESS**
- Orman Yolu Android çoklu ekran kanıtı — Run #28 / ID `35120880709` — **SUCCESS**
- Kelime Avı Android 16 görsel kanıtı — Run #446 / ID `35120880717` — **SUCCESS**
- AdMob PR doğrulaması — Run #823 / ID `35120880650` — **SUCCESS**
- `flutter analyze`, repo-geneli `flutter test`, release APK, package/manifest, Android 16 cold-start — **PASS**

Regression baseline: 18 yıldız ama final yok → locked; final var ama threshold eksik → locked; gerçek route-complete → next route unlocked; Orman final 1 yıldız → Kadim unlocked; legacy downstream progress prerequisite bypass etmez ve silinmez.

---

## PR #205 — ORMAN YOLU CONTENT POLISH + DATA-DRIVEN BOOK — MERGED

PR: **#205 — `feat(kelime-avi): polish Orman Yolu content`**  
Squash merge commit: `b114bff436fb61912d380dbcb84340d1490f6f4a`

### Orman Yolu bilgi kartları

Production'da 6 özgün `Doğa` kartı vardır:

- `orman-info-agac` — L1
- `orman-info-mese` — L2
- `orman-info-mantar` — L4
- `orman-info-kozalak` — L5
- `orman-info-sincap` — L6
- `orman-info-geyik` — L7

L3 ve L8–L10 için info card yoktur. L1–L7 gameplay payload korunmuştur.

### Orman Yolu L8–L10 polish

- L8 **YAĞMURDAN SONRA** — target `YAĞMUR, ÇAMUR, DAMLA, DERE, PATİKA`; bonus `ISLAK`; yeni deterministic 8×8 grid.
- L9 **ORMANIN İZLERİ** — target `İZLER, TÜY, TOYNAK, YEMİŞ, OYUK`; bonus `KABUK`; yeni deterministic 8×8 grid.
- L10 **YOLUN SONU** — `routeFinal`; target `ORMAN, KEŞİF, YOLCULUK, CANLI, DOĞA, UYUM`; bonus `MACERA`; `timeLimitSeconds = 120`; yeni deterministic 8×8 grid; mevcut star/mistake contract korunur.

Runtime random grid generation yoktur.

### Production kitap akışı

Tüm production rotaları aynı generic/data-driven bilgi kartı sistemini kullanır:

`_activeInfoCards` + `_progress.unlockedInfoCardIds`

Bu Başlangıç Limanı, Gökyüzü, Orman Yolu ve Kadim Orman için ortaktır. Legacy forest özel book sistemi (`_showOrmanTopicBook`, `_TopicGuide`, `_ormanTopicGuides`, `theme == 'orman'` book branch) kaldırılmıştır. Cross-route card isolation testle kilitlidir.

---

## PR #204 — KADİM ORMAN ÖZGÜN CONTENT — MERGED

Squash merge commit: `755e90725d3062b74c0ce228bb1b6d7bbdfda4c0`

Kadim Orman artık Orman Yolu gameplay content'ini clone/reuse etmez.

Korunan kimlikler:

- route id: `orman-2`
- title: **Kadim Orman**
- theme: `orman`
- reward id: `reward-orman-2`
- level id'leri: `orman-2-01` … `orman-2-10`

Production'da 10 özgün statik/deterministic 8×8 grid + özgün target/bonus content + 6 özgün bilgi kartı vardır:

- `kadim-info-egrelti` — L1
- `kadim-info-sis` — L2
- `kadim-info-misel` — L4
- `kadim-info-baykus` — L5
- `kadim-info-kaynak` — L7
- `kadim-info-cinar` — L9

---

## PR #203 — KADİM ORMAN PROGRESSION — MERGED

Squash merge commit: `f312a2333cb16e9a74f500fcc80c200325634439`

Kadim Orman selector'da dördüncü rota olarak görünür; Orman Yolu route-complete olduğunda açılır. Kendi 1→10 progression identity'si Orman Yolu'ndan bağımsızdır.

---

## PR #202 — KADİM ORMAN / ORMAN 2 RUNTIME-VISUAL BASELINE — MERGED

Squash merge commit: `9aa3a2e8392a8fb42646d23c1e89ea9b67789c5a`

Korunan runtime/presentation baseline:

- technical route id `orman-2`
- visual theme id `orman-2-production`
- `referenceCanvasSize = 411×731`
- `extendTallAmbientFromArtworkEdges = true`
- `artworkOverlayMode = embeddedRouteLiveNodes`
- dekoratif rota raster içindedir; live Flutter route painter kapalıdır
- node/progression/chrome canlı Flutter katmanındadır
- Orman 1 node asset ailesi reuse edilir
- route/theme-id özel renderer `if` yoktur
- normalized stops değiştirilmemiştir

### Immutable Kadim Orman asset freeze

`assets/word_hunt/ORMAN2_FINAL_941x1672.webp`

- dimensions: **941×1672**
- bytes: **1.109.268**
- SHA-256: `aede5c6f08b6fe4cd64d17a1ef309e13256dde1c1e97fbee0c53b019f63c6c8d`
- Git blob SHA: `43233bf2b0e8f16d59a15f0fe0bcda5f5e2bb80c`

**Re-encode / recompress / resize / crop / recolor / yeniden üretme yapılmaz.**

---

## KORUNAN GENEL KELİME AVI KURALLARI

- Her 10-bölümlük rotada bölüm progression'ı `1→2→3→4→5→6→7→8→9→10`.
- Ortak motor: `WordHuntRouteProgressEngine.isLevelUnlocked`.
- Production route selector sırası: Başlangıç → Gökyüzü → Orman → Kadim.
- Grid: **8×8 / 64 hücre — LOCKED**.
- Existing challenge/final timing baseline genel olarak B5 60 sn, B10 120 sn; yeni audit bunu inceleyecek, şu an değiştirilmedi.
- Minimum Kelime Avı yayın stoğu: **200 hazır/doğrulanmış bölüm**.
- 200/200 release-stock gate ve runtime/fiziksel kabul tamamlanmadan yeni Kelime Avı production release'i Play'e yüklenmez.
- `assets/questions.json`, BoardMap/67 node, Firebase, signing, version ve Play kapsamı açık owner kararı olmadan değiştirilmez.

## SOURCE BRANCH KORUMA

Owner açıkça istemeden silinmez:

- `feat/kelime-avi-linear-route-progression`
- `feat/kelime-avi-orman-yolu-content-polish`
- `feat/kelime-avi-kadim-orman-original-content`
- `feat/kelime-avi-kadim-orman-progression`
- `feat/kelime-avi-orman2-runtime-pilot-20260916`

---

## SIRADAKİ BAŞLANGIÇ NOKTASI

### CHALLENGE / FINAL YILDIZ – ZAMAN – ÖDÜL DENGESİ AUDITİ

Henüz yeni star/time/reward kararı **VERİLMEDİ**. Yeni sohbette önce mevcut production contract audit edilecek:

- Başlangıç Limanı challenge/final star rule'ları
- Gökyüzü challenge/final star rule'ları
- Orman Yolu challenge/final star rule'ları
- Kadim Orman challenge/final star rule'ları
- `timeLimitSeconds`
- `twoStarMaxMistakes` / `threeStarMaxMistakes`
- `twoStarMaxSeconds` / `threeStarMaxSeconds`
- routeFinal bölümlerin gerçekten final hissi verip vermediği
- `routeRewardId` değerlerinin runtime'da gerçek kullanıcı ödülü üretip üretmediği
- rotalar arasında zorluk artışının tutarlı olup olmadığı

**Bu aşamada yeni değer uydurma, 5. rota tasarlama veya runtime/content değiştirme. Önce audit yap.**

## DEVİR SON DURUMU

PR #202–#206 ile Kadim Orman runtime/progression/original content, Orman Yolu content + data-driven book ve tam lineer route progression kapanmıştır. CI kapanışları yeşildir. Yeni sohbetin ilk işi yalnız **CHALLENGE / FINAL YILDIZ – ZAMAN – ÖDÜL DENGESİ AUDITİ** olmalıdır.