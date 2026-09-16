# SOHBET DEVİR — 16 Eylül 2026 — CHALLENGE / FINAL AUDIT BAŞLANGICI

Bu dosya yeni sohbette BilgiRotasi / Kelime Avı çalışmasını devralmak için authoritative başlangıç notudur.

## Yeni sohbette okuma sırası

1. `docs/project-memory/GENEL_PROJE_OZETI.md`
2. Bu dosya: `docs/project-memory/SOHBET_DEVIR_2026-09-16_CHALLENGE_FINAL_AUDIT_BASLANGIC.md`
3. `KELIME_AVI_REUSABLE_HARITA_KARARI.md`
4. Sonra canlı GitHub durumunu doğrula: target branch exact HEAD, açık PR'lar ve ilgili Actions sonuçları.

Çelişki varsa öncelik: **canlı GitHub > proje memory/karar dosyaları > eski sohbetler**.

## Repo / target

- Repo: `ZMilaStudio/BilgiRotasi`
- Target branch: `release/final-closed-test-aab-1.68.8`
- Bu devir hazırlanırken canlı target HEAD: `84f965328eb19430b20b95e0a251c3da4f7e27a3`
- Son product merge baseline: `7d1d699623200601ad867eb6dda852feede587eb`
- Product baseline PR: #206 — `feat(kelime-avi): enforce linear route progression`

Bu devir commit'i target HEAD'i ilerleteceği için yeni sohbet exact HEAD'i mutlaka canlı yeniden doğrulamalıdır.

## Kapanmış işler — yeniden açma

### PR #202 — Kadim Orman runtime/visual baseline

- MERGED
- squash merge: `9aa3a2e8392a8fb42646d23c1e89ea9b67789c5a`
- Kadim Orman technical route id: `orman-2`
- production visual theme: `orman-2-production`
- immutable asset: `assets/word_hunt/ORMAN2_FINAL_941x1672.webp`
- asset SHA-256: `aede5c6f08b6fe4cd64d17a1ef309e13256dde1c1e97fbee0c53b019f63c6c8d`
- asset yeniden encode/resize/crop/recolor/rebuild edilmez.

### PR #203 — Kadim Orman progression

- MERGED
- squash merge: `f312a2333cb16e9a74f500fcc80c200325634439`
- Kadim Orman selector'da dördüncü rotadır.
- Kendi 1→10 progression identity'si vardır.

### PR #204 — Kadim Orman özgün content

- MERGED
- squash merge: `755e90725d3062b74c0ce228bb1b6d7bbdfda4c0`
- Orman Yolu gameplay clone/reuse yoktur.
- 10 özgün deterministic 8×8 grid + özgün target/bonus content + 6 özgün info card production'dadır.

### PR #205 — Orman Yolu content polish + data-driven book

- MERGED
- squash merge: `b114bff436fb61912d380dbcb84340d1490f6f4a`
- Orman Yolu 6 özgün Doğa info card kullanır.
- L8/L9/L10 content polish tamamlandı.
- Tüm production rotaları generic/data-driven book akışını kullanır:
  `_activeInfoCards + _progress.unlockedInfoCardIds`
- legacy forest özel book sistemi kaldırıldı.

### PR #206 — Tam lineer route progression

- MERGED
- approved head: `8998e124eaf2afdffd618b0f60212ba2196172b3`
- approved tree: `02e263e0ade579080f7aa8791de3a33373cf1345`
- squash merge: `7d1d699623200601ad867eb6dda852feede587eb`
- merge tree: `02e263e0ade579080f7aa8791de3a33373cf1345`
- tree equality: EVET

Production unlock zinciri artık kesin olarak:

**Başlangıç Limanı → Gökyüzü Adaları → Orman Yolu → Kadim Orman**

- Başlangıç: always unlocked.
- Gökyüzü: Başlangıç `routeComplete` = final complete + en az 18 yıldız.
- Orman: Gökyüzü `routeComplete` = final complete + en az 18 yıldız.
- Kadim: Orman `routeComplete`; Orman `unlockStarsRequired = 0`, yani final completion yeterli; ekstra star gate yok.

Exact locked copy:

- Gökyüzü: “Başlangıç Limanı’nı tamamla ve en az 18 yıldız kazan.”
- Orman: “Gökyüzü Adaları’nı tamamla ve en az 18 yıldız kazan.”
- Kadim: “Orman Yolu’nu tamamlayarak aç.”

`routeComplete` authoritative olarak:

`WordHuntRouteProgressEngine.isRouteComplete(prerequisiteRoute, progress)`

kullanır. Legacy downstream progress silinmez, migrate edilmez ve prerequisite bypass ettiremez.

PR #206 approved exact HEAD CI:

- route catalog #84 / `35120880714` — SUCCESS
- Orman multi-size #28 / `35120880709` — SUCCESS
- Kelime Avı Android 16 #446 / `35120880717` — SUCCESS
- AdMob #823 / `35120880650` — SUCCESS
- flutter analyze / repo-geneli flutter test / release APK / package-manifest / Android 16 cold-start — PASS

## Source branch koruma

Owner açıkça istemeden silme:

- `feat/kelime-avi-linear-route-progression`
- `feat/kelime-avi-orman-yolu-content-polish`
- `feat/kelime-avi-kadim-orman-original-content`
- `feat/kelime-avi-kadim-orman-progression`
- `feat/kelime-avi-orman2-runtime-pilot-20260916`

## YENİ SOHBETİN İLK İŞİ

### CHALLENGE / FINAL YILDIZ – ZAMAN – ÖDÜL DENGESİ AUDITİ

Bu konuda henüz ürün çözümü veya yeni değer kararı yoktur. Yeni sohbet önce mevcut kodu ve testleri inceleyerek yalnız audit çıkaracaktır.

İncelenecekler:

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

### İlk turda YAPMA

- yeni star/time/reward değeri uydurma
- runtime/content kodunu değiştirme
- selector/progression değiştirme
- asset değiştirme
- 5. rota oluşturma veya tasarlama
- source branch silme
- release/tag oluşturma

Önce mevcut production contract'ı teknik olarak audit et, bulguları ve seçenekleri owner'a getir; ürün kararı owner'dan sonra uygulanır.

## DEVİR CÜMLESİ

Yeni sohbet şu prompt ile başlayabilir:

`GENEL_PROJE_OZETI.md ve SOHBET_DEVIR_2026-09-16_CHALLENGE_FINAL_AUDIT_BASLANGIC.md dosyalarını oku; canlı target HEAD'i doğrula ve CHALLENGE / FINAL YILDIZ – ZAMAN – ÖDÜL DENGESİ auditinden devam et. Şimdilik kod değişikliği yapma.`