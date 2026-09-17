# Bilgi Rotası — Genel Proje Özeti

**Son güncelleme:** 17 Eylül 2026

## YENİ SOHBETTE ÖNCE BUNLARI OKU

1. `docs/project-memory/GENEL_PROJE_OZETI.md`
2. `docs/project-memory/SOHBET_DEVIR_2026-09-17_ROUTE_REWARD_FINAL_CEREMONY_KAPANIS.md`
3. `KELIME_AVI_REUSABLE_HARITA_KARARI.md`
4. Ardından canlı GitHub durumunu yeniden doğrula: target branch exact HEAD, ilgili PR'lar ve Actions sonuçları.

Çelişki varsa öncelik: **canlı GitHub > proje memory/karar dosyaları > eski sohbetler**.

Repo: `ZMilaStudio/BilgiRotasi`  
Target branch: `release/final-closed-test-aab-1.68.8`  
PR #207 challenge/final balance merge: `4ffe63500363e6d976bb211f5e7d547a69859df9`  
PR #208 route reward/final ceremony merge: `c880550ef41841608d8aa664f6c24c54f3dd067d`  
Bu dosyayı güncelleyen docs commit target HEAD'i ayrıca ilerletecektir; yeni sohbette exact HEAD mutlaka canlı doğrulanmalıdır.

---

## KELİME AVI — AUTHORITATIVE PRODUCTION DURUMU

Production rota sırası ve unlock zinciri:

**Başlangıç Limanı → Gökyüzü Adaları → Orman Yolu → Kadim Orman**

- Başlangıç Limanı: `always`.
- Gökyüzü Adaları: Başlangıç `routeComplete`; final complete + en az 18 yıldız.
- Orman Yolu: Gökyüzü `routeComplete`; final complete + en az 18 yıldız.
- Kadim Orman: Orman Yolu `routeComplete`; Orman Yolu `unlockStarsRequired = 0`, dolayısıyla final completion yeterli.

`routeComplete` authoritative olarak `WordHuntRouteProgressEngine.isRouteComplete(route, progress)` ile hesaplanır. Final type `routeFinal` olmalı, final tamamlanmış olmalı ve rota yıldız eşiği sağlanmalıdır.

Legacy/grandfather unlock istisnası yoktur. Eski downstream progress silinmez veya migrate edilmez; prerequisite'i bypass ettiremez.

---

## PR #207 — CHALLENGE / FINAL PROGRESSIVE STAR-TIME BALANCE — MERGED

PR: **#207 — `feat(kelime-avi): balance challenge and final stars`**

- Approved feature head: `9bbc3b8c6303dc390c79a2d178c03b803830c80c`
- Approved head tree: `7876ea9455465c3c1842cd391a94af9ab8365f6b`
- Squash merge commit: `4ffe63500363e6d976bb211f5e7d547a69859df9`
- Merge commit tree: `7876ea9455465c3c1842cd391a94af9ab8365f6b`
- Tree equality: **EVET**

### Authoritative star/time contract

Normal bölümler (`L1-L4`, `L6-L9`) mistake odaklıdır; seconds threshold yoktur.

L5 Challenge:
- 3★ = `0 hata` + rota-specific 3★ süre
- 2★ = `<=1 hata` + rota-specific 2★ süre
- targetWords tamamlandı fakat üst eşikler kaçtıysa 1★

L10 Final:
- 3★ = `0 hata` + rota-specific 3★ süre
- 2★ = `<=2 hata` + rota-specific 2★ süre
- targetWords tamamlandı fakat üst eşikler kaçtıysa 1★

Target tamamlanmadıysa 0★. Mistake + time birlikte varsa **AND** uygulanır. Sınırlar inclusive (`<=`).

| Rota | L5 3★ | L5 2★ | L5 timeLimit | L10 3★ | L10 2★ | L10 timeLimit |
|---|---:|---:|---:|---:|---:|---:|
| Başlangıç Limanı | 35 sn / 0 hata | 50 sn / <=1 hata | 60 | 75 sn / 0 hata | 100 sn / <=2 hata | 120 |
| Gökyüzü Adaları | 35 sn / 0 hata | 50 sn / <=1 hata | 60 | 75 sn / 0 hata | 100 sn / <=2 hata | 120 |
| Orman Yolu | 25 sn / 0 hata | 36 sn / <=1 hata | 60 | 50 sn / 0 hata | 66 sn / <=2 hata | 120 |
| Kadim Orman | 24 sn / 0 hata | 35 sn / <=1 hata | 60 | 48 sn / 0 hata | 64 sn / <=2 hata | 120 |

`timeLimitSeconds` hard fail değildir; süre dolunca oyun bitmez, input kapanmaz ve scoring engine bu alanı kullanmaz.

---

## PR #208 — ROUTE REWARD + FINAL CEREMONY — MERGED

PR: **#208 — `feat(kelime-avi): add route rewards and completion ceremony`**

- Approved exact head: `0d724e7544811cf74c85b9058800cee8396fea67`
- Approved head tree: `93c2858d3a37903564ec0cf4993d100c5442e9aa`
- Squash merge commit: `c880550ef41841608d8aa664f6c24c54f3dd067d`
- Merge tree: `93c2858d3a37903564ec0cf4993d100c5442e9aa`
- Tree equality: **EVET**
- Squash parent: `62969dfe17d660beae58aafca95168eaa64f057c`
- Source branch: `feat/kelime-avi-route-reward-ceremony` — owner istemeden silinmez.

### Authoritative reward IDs

| Rota | routeRewardId | Display |
|---|---|---|
| Başlangıç Limanı | `badge-kelime-yolcusu` | Kelime Yolcusu |
| Gökyüzü Adaları | `badge-gokyuzu-kasifi` | Gökyüzü Kaşifi |
| Orman Yolu | `badge-orman-kasifi` | Orman Kaşifi |
| Kadim Orman (`orman-2`) | `badge-kadim-orman-kasifi` | Kadim Orman Kaşifi |

Eski `reward-orman-yolu` ve `reward-orman-2` kimlikleri superseded'dır.

### Reward grant semantiği

Reward, L10 tamamlandı diye verilmez. Authoritative trigger gerçek:

`routeComplete false → routeComplete true`

transition'ıdır ve `WordHuntRouteProgressEngine.isRouteComplete(route, progress)` kullanılır.

Başlangıç/Gökyüzü'nde final tamamlanmış olsa bile toplam yıldız 18'in altındaysa reward yoktur. Daha sonra normal bir level replay'i toplamı 18'e çıkarırsa reward grant + persistence + route completion ceremony o anda çalışır.

Reward set semantics ile idempotent'tır; duplicate grant ve duplicate reward reveal yoktur.

### Persistence / migration

`WordHuntProgressSnapshot` artık en az şunları taşır:

- `bestStarsByLevelId`
- `unlockedInfoCardIds`
- `unlockedRouteRewardIds`

Payload schema: **2**. Decoder schema **1 ve 2** destekler; unknown future schema fail-closed kalır.

Storage key/prefix değişmedi:

`bilgi_rotasi_word_hunt_progress_v1_`

Schema-v1 save stars/infoCards kaybetmeden açılır; historical `routeComplete` durumlarından eksik reward'lar sessiz ve idempotent biçimde backfill edilir. Backfill stars/infoCards/progression değiştirmez ve retroaktif ceremony göstermez.

### Completion UX

Normal level: mevcut generic **`Bölüm Tamamlandı`** korunur.

İlk kez oynanan route final tamamlandı fakat rota complete olmadıysa:
- başlık: **`Final Tamamlandı`**
- copy: **`Rotayı tamamlamak için X yıldız daha kazan.`**
- reward yoktur.

Gerçek false→true routeComplete olduğunda:
- başlık: **`Rota Tamamlandı!`**
- rota adı
- **`Rozet Kazandın`**
- reward display name
- toplam rota yıldızı / max yıldız
- varsa **`<Gelecek rota adı> açıldı.`**
- primary CTA: **`Yeni Rotayı Gör`**
- secondary CTA: **`Rotaya Dön`**

Kadim Orman terminal copy:

**`Tüm mevcut rotaları tamamladın.`**

Kadim'de next-route CTA ve 5. rota tease yoktur.

### Double-dialog contract

Route-final first-completion akışında generic `Bölüm Tamamlandı` ile parent ceremony üst üste gösterilmez. `WordHuntLevelProductionScreen.deferCompletionDialog` default `false`; deferred route-final success'te generic dialog açılmadan aynı gameplay result parent orchestration'a döner. Exit confirmation korunur. Eski nested Navigator observer / auto-pop yaklaşımı superseded'dır.

### Selector reward state

Persisted reward kazanılmışsa selector kartında küçük rozet + **`Kazanıldı`** indicator görünür. Bu state unlock/tap/progression mantığını değiştirmez ve locked route'u açmaz.

### PR #208 exact-head CI

Approved exact head `0d724e7544811cf74c85b9058800cee8396fea67`:

- Kelime Avı Orman Yolu içerik kapısı — Run #13 / ID `35207375685` — **SUCCESS**
- Kelime Avı route catalog kapısı — Run #89 / ID `35207375718` — **SUCCESS**
- Orman Yolu Android çoklu ekran kanıtı — Run #34 / ID `35207375778` — **SUCCESS**
- Kelime Avı Android 16 görsel kanıtı — Run #452 / ID `35207375795` — **SUCCESS**
- AdMob PR doğrulaması — Run #829 / ID `35207375767` — **SUCCESS**
- AdMob: analyze+full tests, release APK, package/merged manifest, Android 16 cold-start deneme 1 ve final uygulama kapısı — **PASS**

Regression baseline testle kilitlidir: v1 save korunur; v2 reward roundtrip; duplicate reward yok; historical backfill idempotent; reward set `recordLevelResult` sırasında kaybolmaz; Başlangıç final+17★ reward vermez; later replay 18★ reward verir; Orman/Kadim final reward verir; already-earned replay duplicate reveal yapmaz; route-final double-dialog yok; deferred exit confirmation korunur; selector indicator unlock logic'i değiştirmez.

---

## KORUNAN GENEL KELİME AVI KURALLARI

- Her rota 10 bölüm; canonical progression `1→2→3→4→5→6→7→8→9→10`.
- Grid: **8×8 / 64 hücre — LOCKED**.
- Production selector sırası: Başlangıç → Gökyüzü → Orman → Kadim.
- Tüm production rotaları generic/data-driven bilgi kartı sistemini kullanır: `_activeInfoCards + _progress.unlockedInfoCardIds`.
- Kadim Orman özgün deterministic content kullanır; Orman Yolu gameplay clone'u değildir.
- `assets/questions.json`, BoardMap/67 node, Firebase, signing, version ve Play kapsamı açık owner kararı olmadan değiştirilmez.
- Minimum Kelime Avı yayın stoğu: **200 hazır/doğrulanmış bölüm**.

## SOURCE BRANCH KORUMA

Owner açıkça istemeden silinmez:

- `feat/kelime-avi-route-reward-ceremony`
- `feat/kelime-avi-progressive-challenge-final-balance`
- `feat/kelime-avi-linear-route-progression`
- `feat/kelime-avi-orman-yolu-content-polish`
- `feat/kelime-avi-kadim-orman-original-content`
- `feat/kelime-avi-kadim-orman-progression`
- `feat/kelime-avi-orman2-runtime-pilot-20260916`

---

## SIRADAKİ BAŞLANGIÇ NOKTASI

### KELİME AVI — ROUTE SELECTOR POLISH AUDIT

İlk tur **yalnız audit** olacak; selector redesign veya runtime değişikliği yapılmayacak.

İncelenecekler:

- dört rota kartının visual hierarchy'si,
- locked / unlocked / completed / reward-earned state'leri,
- ordinal kullanımı ve route title ağırlığı,
- progress / stars gösterimi,
- `Kazanıldı` indicator'ın kart kalabalığına etkisi,
- locked copy okunabilirliği,
- current/next route vurgusu,
- kartların birbirinden görsel ayrımı,
- Kadim Orman premium/final-route hissi,
- küçük/büyük ekran davranışı,
- accessibility / semantics,
- tap target'lar,
- route state'lerinin hızlı anlaşılması.

**5. rota henüz açılmaz. Önce selector polish konusu kapanır.**
