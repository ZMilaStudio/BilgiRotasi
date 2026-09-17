# SOHBET DEVİR — 17 Eylül 2026 — CHALLENGE / FINAL BALANCE KAPANIŞI

Bu dosya PR #207 challenge/final star-time balance çalışmasının historical kapanış notudur.

**Bu dosyanın sonraki çalışma başlangıcı artık superseded'dır.**  
Güncel authoritative devir dosyası:

`docs/project-memory/SOHBET_DEVIR_2026-09-17_ROUTE_REWARD_FINAL_CEREMONY_KAPANIS.md`

Yeni sohbette önce:

1. `docs/project-memory/GENEL_PROJE_OZETI.md`
2. `docs/project-memory/SOHBET_DEVIR_2026-09-17_ROUTE_REWARD_FINAL_CEREMONY_KAPANIS.md`
3. `KELIME_AVI_REUSABLE_HARITA_KARARI.md`
4. canlı GitHub target HEAD / PR / Actions durumunu doğrula.

Çelişki varsa öncelik: **canlı GitHub > proje memory/karar dosyaları > eski sohbetler**.

---

## PR #207 KAPANIŞ BASELINE

- PR #207: `feat(kelime-avi): balance challenge and final stars`
- state: **MERGED**
- approved head: `9bbc3b8c6303dc390c79a2d178c03b803830c80c`
- approved head tree: `7876ea9455465c3c1842cd391a94af9ab8365f6b`
- squash merge commit: `4ffe63500363e6d976bb211f5e7d547a69859df9`
- merge tree: `7876ea9455465c3c1842cd391a94af9ab8365f6b`
- tree equality: **EVET**
- squash parent: `d81b6777065e88d3a1eba8716364e12bac071975`

### Authoritative star/time matrix

| Rota | L5 3★ | L5 2★ | L10 3★ | L10 2★ |
|---|---:|---:|---:|---:|
| Başlangıç Limanı | 35 sn / 0 hata | 50 sn / <=1 hata | 75 sn / 0 hata | 100 sn / <=2 hata |
| Gökyüzü Adaları | 35 sn / 0 hata | 50 sn / <=1 hata | 75 sn / 0 hata | 100 sn / <=2 hata |
| Orman Yolu | 25 sn / 0 hata | 36 sn / <=1 hata | 50 sn / 0 hata | 66 sn / <=2 hata |
| Kadim Orman | 24 sn / 0 hata | 35 sn / <=1 hata | 48 sn / 0 hata | 64 sn / <=2 hata |

Normal levels mistake odaklıdır; seconds threshold yoktur. Target tamamlanmadıysa 0★; mistake+time AND; boundary inclusive (`<=`). `timeLimitSeconds` 60/120 soft metadata'dır ve hard fail değildir.

---

## BU DOSYADAKİ SONRAKİ-AUDIT BİLGİSİ SUPERSEDED

Bu kapanıştan sonra ROUTE REWARD + FINAL CEREMONY audit ve implementasyonu tamamlanmış, PR #208 merge edilmiştir.

Artık authoritative gerçek:

- `routeRewardId` metadata-only **değildir**.
- production reward consumer **vardır**.
- reward persistence **vardır**.
- persisted reward state: `unlockedRouteRewardIds`.
- payload schema **2**'dir; decoder schema 1 ve 2 destekler.
- storage prefix `bilgi_rotasi_word_hunt_progress_v1_` korunur.
- historical route reward backfill vardır ve sessiz/idempotent çalışır.
- reward grant gerçek `routeComplete false → true` transition'ında olur.
- route-final first completion için final/route ceremony vardır.
- selector kazanılmış reward'ı `Kazanıldı` indicator ile gösterir.
- next-route unlock gerçek route completion ceremony içinde kullanıcıya gösterilebilir.
- final double-dialog problemi explicit `deferCompletionDialog` presentation contract'ı ile çözülmüştür.

Authoritative reward IDs:

- Başlangıç Limanı: `badge-kelime-yolcusu`
- Gökyüzü Adaları: `badge-gokyuzu-kasifi`
- Orman Yolu: `badge-orman-kasifi`
- Kadim Orman: `badge-kadim-orman-kasifi`

Eski `reward-orman-yolu` ve `reward-orman-2` superseded'dır.

PR #208 merge:

- approved head: `0d724e7544811cf74c85b9058800cee8396fea67`
- approved tree: `93c2858d3a37903564ec0cf4993d100c5442e9aa`
- squash merge commit: `c880550ef41841608d8aa664f6c24c54f3dd067d`
- merge tree: `93c2858d3a37903564ec0cf4993d100c5442e9aa`
- tree equality: **EVET**

PR #208 exact-head CI tamamen yeşildir; detay ve regression baseline yeni authoritative kapanış dosyasında tutulur.

---

## SIRADAKİ AUTHORITATIVE KONU

**KELİME AVI — ROUTE SELECTOR POLISH AUDIT**

İlk tur yalnız audit olacaktır. Selector kodu/redesign yapılmayacak. 5. rota henüz açılmayacaktır.
