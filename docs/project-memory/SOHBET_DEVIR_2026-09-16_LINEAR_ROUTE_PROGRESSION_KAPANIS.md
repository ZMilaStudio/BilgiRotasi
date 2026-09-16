# SOHBET DEVİR — 16 Eylül 2026 — LINEER ROTA PROGRESSION KAPANIŞI

Bu dosya, Kelime Avı production rota progression kararının PR #206 ile kapanışını authoritative olarak taşır. Yeni sohbette önce `docs/project-memory/GENEL_PROJE_OZETI.md`, sonra bu dosya, ardından `KELIME_AVI_REUSABLE_HARITA_KARARI.md` okunmalıdır. Canlı GitHub durumu her zaman yeniden doğrulanır.

## Repo / target

- Repo: `ZMilaStudio/BilgiRotasi`
- Target branch: `release/final-closed-test-aab-1.68.8`
- PR #206 merge baseline: `7d1d699623200601ad867eb6dda852feede587eb`

## PR #206 kapanış kimliği

- PR: **#206 — `feat(kelime-avi): enforce linear route progression`**
- Approved feature head: `8998e124eaf2afdffd618b0f60212ba2196172b3`
- Approved head tree: `02e263e0ade579080f7aa8791de3a33373cf1345`
- Squash merge commit: `7d1d699623200601ad867eb6dda852feede587eb`
- Merge commit tree: `02e263e0ade579080f7aa8791de3a33373cf1345`
- Approved head tree == merge tree: **EVET**
- Squash parent: `1ca969a952f44ee72381c4ed704a534c7924cbbd`
- Source branch: `feat/kelime-avi-linear-route-progression`
- Source branch bilerek silinmedi ve owner açıkça istemeden silinmemelidir.

## AUTHORITATIVE PRODUCT CONTRACT — TAM LINEER ROTA ZİNCİRİ

Production selector/order:

1. Başlangıç Limanı
2. Gökyüzü Adaları
3. Orman Yolu
4. Kadim Orman

Unlock zinciri de aynı sırayı izler:

**Başlangıç Limanı → Gökyüzü Adaları → Orman Yolu → Kadim Orman**

### Başlangıç Limanı

- unlock rule: `always`
- her zaman açık.

### Gökyüzü Adaları

- prerequisite: Başlangıç Limanı
- rule: `routeComplete`
- gerçek şart:
  - Başlangıç final tamamlanmış olmalı,
  - Başlangıç `totalStars >= 18` olmalı.
- exact locked copy: **“Başlangıç Limanı’nı tamamla ve en az 18 yıldız kazan.”**

### Orman Yolu

- prerequisite: Gökyüzü Adaları
- rule: `routeComplete`
- gerçek şart:
  - Gökyüzü final tamamlanmış olmalı,
  - Gökyüzü `totalStars >= 18` olmalı.
- exact locked copy: **“Gökyüzü Adaları’nı tamamla ve en az 18 yıldız kazan.”**

### Kadim Orman

- prerequisite: Orman Yolu
- rule: `routeComplete`
- Orman Yolu `unlockStarsRequired = 0`.
- gerçek şart: Orman Yolu final bölümünün tamamlanması yeterlidir.
- ek 18/30 yıldız şartı yoktur.
- exact locked copy: **“Orman Yolu’nu tamamlayarak aç.”**

## `routeComplete` semantiği

PR #206 ile `WordHuntRouteUnlockRule.routeComplete` kök semantiği düzeltildi.

Artık yalnız `prerequisite.levels.last` completion kontrolü yapılmaz. Authoritative çağrı:

`WordHuntRouteProgressEngine.isRouteComplete(prerequisiteRoute, progress)`

`WordHuntRouteProgressEngine.isRouteComplete()` sözleşmesi değiştirilmedi:

- final level type `routeFinal` olmalı,
- final level completed olmalı,
- `totalStars >= route.unlockStarsRequired` olmalı.

Böylece `routeComplete`, prerequisite rotanın gerçek completion contract'ını temsil eder.

## Legacy / grandfather progress kararı

Grandfather unlock istisnası **yoktur**.

Eski kayıtlı downstream progress:

- silinmez,
- migrate edilmez,
- prerequisite bypass ettirmez.

Örnek authoritative davranış:

- Başlangıç complete ve eski Orman progress'i mevcut olabilir.
- Gökyüzü route-complete değilse Orman Yolu selector'da locked kalır.
- Gökyüzü daha sonra route-complete olduğunda Orman tekrar açılır.
- Daha önce kaydedilmiş Orman progress'i aynen korunur.

## Korunan alanlar

PR #206 şunları değiştirmedi:

- route sırası,
- route id'leri,
- ordinal labels,
- content/grid/targetWords/bonusWords,
- infoCards,
- data-driven book sistemi,
- gameplay/scoring,
- yıldız hesaplama motoru,
- persistence formatı,
- asset,
- visual theme,
- map geometry,
- normalized stops,
- renderer,
- NodeSkin.

Yeni rota oluşturulmadı.

## Test / CI kapanışı

Approved exact HEAD: `8998e124eaf2afdffd618b0f60212ba2196172b3`

Regression contract:

- fresh: yalnız Başlangıç açık; diğerleri locked — **PASS**
- 18 Başlangıç yıldızı ama final yok → Gökyüzü locked — **PASS**
- Başlangıç final var ama <18 → Gökyüzü locked — **PASS**
- Başlangıç route-complete → Gökyüzü unlocked — **PASS**
- Gökyüzü incomplete → Orman locked — **PASS**
- Gökyüzü final + <18 → Orman locked — **PASS**
- Gökyüzü route-complete → Orman unlocked — **PASS**
- Orman final 1 yıldız → Kadim unlocked — **PASS**
- Orman yüksek yıldız ama final yok → Kadim locked — **PASS**
- legacy Orman progress + incomplete Gökyüzü → Orman locked — **PASS**
- prerequisite sonradan tamamlanınca downstream progress korunur — **PASS**
- `routeComplete` final/threshold/zero-threshold semantic regression — **PASS**

CI:

- Kelime Avı route catalog kapısı — Run #84 / ID `35120880714` — **SUCCESS**
- Orman Yolu Android çoklu ekran kanıtı — Run #28 / ID `35120880709` — **SUCCESS**
- Kelime Avı Android 16 görsel kanıtı — Run #446 / ID `35120880717` — **SUCCESS**
- AdMob PR doğrulaması — Run #823 / ID `35120880650` — **SUCCESS**
- `flutter analyze` — **PASS**
- repo-geneli `flutter test` — **PASS**
- release APK — **PASS**
- package/manifest — **PASS**
- Android 16 cold-start — **PASS**

## SIRADAKİ AUDIT BAŞLANGIÇ NOKTASI

### CHALLENGE / FINAL YILDIZ – ZAMAN – ÖDÜL DENGESİ AUDITİ

Henüz yeni star/time/reward kararı **VERİLMEDİ**. Bir sonraki inceleme konusu yalnız aşağıdakileri değerlendirmektir:

- Başlangıç Limanı challenge/final star rule'ları,
- Gökyüzü challenge/final star rule'ları,
- Orman Yolu challenge/final star rule'ları,
- Kadim Orman challenge/final star rule'ları,
- `timeLimitSeconds` değerleri,
- `twoStarMaxMistakes` / `threeStarMaxMistakes`,
- `twoStarMaxSeconds` / `threeStarMaxSeconds` kullanımı,
- routeFinal bölümlerin gerçekten final hissi verip vermediği,
- `routeRewardId` değerlerinin runtime'da gerçek kullanıcı ödülü üretip üretmediği,
- rotalar arasında zorluk artışının tutarlı olup olmadığı.

Bu devir notu yeni denge çözümü, yeni star/time/reward değeri veya 5. rota tasarımı belirlemez. Sıradaki iş yalnız audit ile başlar.

## DEVİR SON DURUMU

PR #206 **MERGED**. Production route progression tam lineer. `routeComplete` gerçek `isRouteComplete` semantiğinde. Legacy downstream progress korunuyor fakat prerequisite bypass etmiyor. PR #206 test/CI kapanışı yeşil. Source branch korunuyor. Sıradaki konu: **CHALLENGE / FINAL YILDIZ – ZAMAN – ÖDÜL DENGESİ AUDITİ**.