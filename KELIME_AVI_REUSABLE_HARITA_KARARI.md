# Kelime Avı — Reusable Harita Mimari Kararı

**Karar tarihi:** 12 Eylül 2026  
**Son durum güncellemesi:** 17 Eylül 2026

Bu belge, Kelime Avı'nın reusable 10-bölümlük rota mimarisi ile production kararlarını authoritative olarak kaydeder.

## Kilitli reusable harita sözleşmesi

- Her rota 10 bölümden oluşur.
- Canonical sıra **1 → 2 → 3 → 4 → 5 → 6 → 7 → 8 → 9 → 10**.
- **8. bölüm bonus değildir; normal bölümdür.**
- 10 node'un geometri/hitbox kaynağı tek reusable motordur; rota bazında ayrı node koordinat listesi yazılmaz.
- Yol geometrisi ortak motor tarafından deterministik üretilir.
- Yeni rota için ayrı ekran/widget yazılmaz; generic ekran route + visualTheme verisiyle çalışır.
- Görsel skin verisi `WordHuntRouteVisualTheme` içinde tutulur; progression/hitbox mantığını taşımaz.
- Embedded-route artwork modunda dekoratif rota raster içindedir; live Flutter route painter ikinci kez çizilmez.
- Rota-id özel Widget/Painter/koordinat listesi reusable mimariyle uyumsuz kabul edilir.

## Production route baseline

Sıra:

**Başlangıç Limanı → Gökyüzü Adaları → Orman Yolu → Kadim Orman**

Unlock contract:

- Başlangıç Limanı: `always`.
- Gökyüzü Adaları: Başlangıç `routeComplete`; final complete + en az 18 yıldız.
- Orman Yolu: Gökyüzü `routeComplete`; final complete + en az 18 yıldız.
- Kadim Orman: Orman Yolu `routeComplete`; `unlockStarsRequired = 0`, final completion yeterli.

`WordHuntRouteUnlockRule.routeComplete`, `WordHuntRouteProgressEngine.isRouteComplete(prerequisiteRoute, progress)` kullanır. Legacy downstream progress prerequisite'i bypass ettiremez; ancak silinmez ve prerequisite sağlanınca korunur.

## Kadim Orman runtime/content baseline

- technical route id: `orman-2`
- user-facing title: **Kadim Orman**
- visual theme id: `orman-2-production`
- route reward id: `badge-kadim-orman-kasifi`
- reward display: **Kadim Orman Kaşifi**
- özgün level id'leri: `orman-2-01` … `orman-2-10`
- 10 özgün deterministic 8×8 grid + özgün target/bonus content + 6 özgün info card
- Orman Yolu gameplay clone/reuse yoktur.

Immutable asset:

`assets/word_hunt/ORMAN2_FINAL_941x1672.webp`

- dimensions: 941×1672
- bytes: 1.109.268
- SHA-256: `aede5c6f08b6fe4cd64d17a1ef309e13256dde1c1e97fbee0c53b019f63c6c8d`
- Git blob SHA: `43233bf2b0e8f16d59a15f0fe0bcda5f5e2bb80c`
- re-encode / recompress / resize / crop / recolor yapılmaz.

## Generic/data-driven production book

Tüm production rotaları aynı bilgi kartı contract'ını kullanır:

`_activeInfoCards + _progress.unlockedInfoCardIds`

Legacy forest özel book branch'leri kaldırılmıştır. Kitap yalnız aktif rotanın unlock edilmiş kartlarını gösterir. Cross-route card isolation korunur.

---

## Challenge / final progressive star-time balance — TAMAMLANDI / MERGED

PR #207 — `feat(kelime-avi): balance challenge and final stars`

- approved head: `9bbc3b8c6303dc390c79a2d178c03b803830c80c`
- approved head tree: `7876ea9455465c3c1842cd391a94af9ab8365f6b`
- squash merge commit: `4ffe63500363e6d976bb211f5e7d547a69859df9`
- merge tree: `7876ea9455465c3c1842cd391a94af9ab8365f6b`
- tree equality: **EVET**

Normal levels (`L1-L4`, `L6-L9`) mistake odaklıdır ve seconds threshold yoktur.

L5 Challenge: 3★ = 0 hata + rota-specific 3★ süre; 2★ = <=1 hata + rota-specific 2★ süre.  
L10 Final: 3★ = 0 hata + rota-specific 3★ süre; 2★ = <=2 hata + rota-specific 2★ süre.  
Target tamamlanmadıysa 0★; mistake+time birlikte varsa AND; boundary inclusive (`<=`).

| Rota | L5 3★ sec | L5 2★ sec | L10 3★ sec | L10 2★ sec |
|---|---:|---:|---:|---:|
| Başlangıç Limanı | 35 | 50 | 75 | 100 |
| Gökyüzü Adaları | 35 | 50 | 75 | 100 |
| Orman Yolu | 25 | 36 | 50 | 66 |
| Kadim Orman | 24 | 35 | 48 | 64 |

`timeLimitSeconds` 60/120 soft metadata'dır; hard fail değildir ve scoring engine tarafından kullanılmaz.

---

## Route reward + final ceremony — TAMAMLANDI / MERGED

PR #208 — `feat(kelime-avi): add route rewards and completion ceremony`

- approved head: `0d724e7544811cf74c85b9058800cee8396fea67`
- approved head tree: `93c2858d3a37903564ec0cf4993d100c5442e9aa`
- squash merge commit: `c880550ef41841608d8aa664f6c24c54f3dd067d`
- merge tree: `93c2858d3a37903564ec0cf4993d100c5442e9aa`
- tree equality: **EVET**
- squash parent: `62969dfe17d660beae58aafca95168eaa64f057c`
- source branch: `feat/kelime-avi-route-reward-ceremony` — owner istemeden silinmez.

### Authoritative reward catalog

| Rota | routeRewardId | Display |
|---|---|---|
| Başlangıç Limanı | `badge-kelime-yolcusu` | Kelime Yolcusu |
| Gökyüzü Adaları | `badge-gokyuzu-kasifi` | Gökyüzü Kaşifi |
| Orman Yolu | `badge-orman-kasifi` | Orman Kaşifi |
| Kadim Orman | `badge-kadim-orman-kasifi` | Kadim Orman Kaşifi |

Eski `reward-orman-yolu` ve `reward-orman-2` superseded'dır. Reward display metadata data-driven catalog üzerinden `routeRewardId` ile çözülür.

### Reward grant / persistence contract

Reward grant yalnız gerçek `routeComplete false → true` transition'ında olur. Trigger `WordHuntRouteProgressEngine.isRouteComplete(route, progress)` kullanır; L10 completion tek başına reward sebebi değildir.

`WordHuntProgressSnapshot` kalıcı olarak `bestStarsByLevelId`, `unlockedInfoCardIds` ve `unlockedRouteRewardIds` taşır. Reward ownership persisted achievement state'tir ve idempotent'tır.

Payload schema **2**'dir. Decoder schema **1 ve 2**'yi destekler; future unknown schema fail-closed kalır. Storage prefix korunur: `bilgi_rotasi_word_hunt_progress_v1_`.

Schema-v1 progress stars/infoCards kaybetmeden açılır; historical routeComplete state'lerinden eksik reward'lar sessiz, sadece-ekleme ve idempotent backfill ile tamamlanır. Backfill ceremony göstermez.

### Route-final presentation contract

- Normal level: generic **`Bölüm Tamamlandı`** korunur.
- Route final complete fakat routeComplete=false: **`Final Tamamlandı`** + `Rotayı tamamlamak için X yıldız daha kazan.`; reward yok.
- Gerçek false→true routeComplete: **`Rota Tamamlandı!`**, rota adı, `Rozet Kazandın`, reward display name, toplam/max yıldız, varsa `<Gelecek rota adı> açıldı.`
- Primary CTA: **`Yeni Rotayı Gör`**
- Secondary CTA: **`Rotaya Dön`**
- Kadim terminal copy: **`Tüm mevcut rotaları tamamladın.`**; next-route CTA yok.

`WordHuntLevelProductionScreen.deferCompletionDialog` default `false` presentation contract'ıdır. Deferred first-route-final success generic completion dialog'u suppress eder ve aynı gameplay result parent orchestration'a döner. Exit confirmation korunur. Eski nested Navigator observer/auto-pop interception yaklaşımı superseded'dır.

Selector kartında persisted reward varsa icon + **`Kazanıldı`** görünür; bu state unlock/tap/progression mantığını değiştirmez.

### PR #208 CI baseline

Approved exact head `0d724e7544811cf74c85b9058800cee8396fea67`:

- Kelime Avı Orman Yolu içerik kapısı — Run #13 / ID `35207375685` — SUCCESS
- Kelime Avı route catalog kapısı — Run #89 / ID `35207375718` — SUCCESS
- Orman Yolu Android çoklu ekran kanıtı — Run #34 / ID `35207375778` — SUCCESS
- Kelime Avı Android 16 görsel kanıtı — Run #452 / ID `35207375795` — SUCCESS
- AdMob PR doğrulaması — Run #829 / ID `35207375767` — SUCCESS
- analyze/full tests, release APK, package/merged manifest, Android 16 cold-start deneme 1 ve final AdMob uygulama kapısı — PASS

Regression test baseline: v1 save preserved; v2 reward roundtrip; duplicate reward yok; historical backfill idempotent; reward set level result sırasında kaybolmaz; Başlangıç final+17★ reward vermez; later replay 18★ reward verir; Orman/Kadim final reward verir; already-earned replay duplicate reveal yapmaz; route-final double-dialog yok; deferred exit confirmation korunur; selector indicator unlock logic'i değiştirmez.

---

## Sıradaki audit — KELİME AVI / ROUTE SELECTOR POLISH

İlk tur yalnız audit olacak. Henüz selector redesign veya runtime değişikliği yapılmaz.

İncelenecekler:

1. Dört rota kartının hierarchy'si.
2. Locked / unlocked / completed / reward-earned state'leri.
3. Ordinal ve route title ağırlığı.
4. Progress / stars gösterimi.
5. `Kazanıldı` indicator'ın kart kalabalığına etkisi.
6. Locked copy okunabilirliği.
7. Current/next route vurgusu.
8. Kartların birbirinden görsel ayrımı.
9. Kadim Orman premium/final-route hissi.
10. Küçük/büyük ekran davranışı.
11. Accessibility / semantics ve tap target'lar.
12. Route state'lerinin kullanıcı tarafından hızlı anlaşılması.

**5. rota selector polish konusu kapanmadan açılmaz veya tasarlanmaz.**

## Source branch koruma

Owner açıkça istemeden silinmez:

- `feat/kelime-avi-route-reward-ceremony`
- `feat/kelime-avi-progressive-challenge-final-balance`
- `feat/kelime-avi-linear-route-progression`
- `feat/kelime-avi-orman-yolu-content-polish`
- `feat/kelime-avi-kadim-orman-original-content`
- `feat/kelime-avi-kadim-orman-progression`
- `feat/kelime-avi-orman2-runtime-pilot-20260916`

**Durum:** REUSABLE 10-LEVEL MAP ARCHITECTURE — MERGED. KADİM ORMAN RUNTIME/CONTENT — MERGED. LINEER ROUTE PROGRESSION — MERGED. CHALLENGE/FINAL BALANCE — MERGED. ROUTE REWARD + FINAL CEREMONY — MERGED / CI GREEN. SIRADAKİ KONU — ROUTE SELECTOR POLISH AUDIT.
