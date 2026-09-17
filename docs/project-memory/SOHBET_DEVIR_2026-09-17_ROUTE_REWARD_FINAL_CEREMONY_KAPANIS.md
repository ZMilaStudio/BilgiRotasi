# SOHBET DEVİR — 17 Eylül 2026 — ROUTE REWARD + FINAL CEREMONY KAPANIŞI

Bu dosya BilgiRotasi / Kelime Avı için PR #208 ile tamamlanan route reward + final ceremony çalışmasının historical authoritative kapanış notudur.

**Güncel selector / sonraki çalışma için bu dosya artık tek başına başlangıç noktası değildir.**
Selector polish PR #209 ile tamamlanmış ve aşağıdaki yeni authoritative dosya tarafından supersede edilmiştir:

`docs/project-memory/SOHBET_DEVIR_2026-09-17_ROUTE_SELECTOR_GUIDED_POLISH_KAPANIS.md`

Yeni sohbette öncelik:

1. `docs/project-memory/GENEL_PROJE_OZETI.md`
2. `docs/project-memory/SOHBET_DEVIR_2026-09-17_ROUTE_SELECTOR_GUIDED_POLISH_KAPANIS.md`
3. `KELIME_AVI_REUSABLE_HARITA_KARARI.md`
4. Canlı GitHub target HEAD / ilgili PR / Actions durumunu yeniden doğrula.

Çelişki varsa öncelik: **canlı GitHub > proje memory/karar dosyaları > eski sohbetler**.

---

## PR #208 REPO / MERGE BASELINE

- Repo: `ZMilaStudio/BilgiRotasi`
- Target: `release/final-closed-test-aab-1.68.8`
- PR: **#208 — `feat(kelime-avi): add route rewards and completion ceremony`**
- PR state: **MERGED**
- Approved exact PR head: `0d724e7544811cf74c85b9058800cee8396fea67`
- Approved head tree: `93c2858d3a37903564ec0cf4993d100c5442e9aa`
- Squash merge commit: `c880550ef41841608d8aa664f6c24c54f3dd067d`
- Merge tree: `93c2858d3a37903564ec0cf4993d100c5442e9aa`
- Tree equality: **EVET**
- Squash parent: `62969dfe17d660beae58aafca95168eaa64f057c`
- Source branch: `feat/kelime-avi-route-reward-ceremony`
- Source branch owner istemeden silinmez.

---

## AUTHORITATIVE ROUTE REWARD CONTRACT

| Rota | Technical route id | routeRewardId | Kullanıcıya görünen rozet |
|---|---|---|---|
| Başlangıç Limanı | `baslangic-limani` | `badge-kelime-yolcusu` | Kelime Yolcusu |
| Gökyüzü Adaları | `gokyuzu-adalari` | `badge-gokyuzu-kasifi` | Gökyüzü Kaşifi |
| Orman Yolu | `orman-yolu` | `badge-orman-kasifi` | Orman Kaşifi |
| Kadim Orman | `orman-2` | `badge-kadim-orman-kasifi` | Kadim Orman Kaşifi |

Reward grant yalnız gerçek `routeComplete false → routeComplete true` transition'ında olur ve `WordHuntRouteProgressEngine.isRouteComplete(route, progress)` kullanılır. L10 completion tek başına reward sebebi değildir.

Grant idempotent'tır. Reward unlock rule değildir; routeComplete milestone'unun persisted kullanıcı kazanımıdır.

---

## PERSISTENCE / SCHEMA / MIGRATION

`WordHuntProgressSnapshot` en az:

- `bestStarsByLevelId`
- `unlockedInfoCardIds`
- `unlockedRouteRewardIds`

taşır.

Payload schema **2**. Decoder:
- schema 1 → desteklenir
- schema 2 → desteklenir
- unknown future schema → fail-closed

Storage prefix değişmedi:

`bilgi_rotasi_word_hunt_progress_v1_`

Schema-v1 save stars/infoCards kaybetmeden açılır. Historical routeComplete reward backfill sessiz, sadece-ekleme ve idempotent'tır; retroaktif ceremony göstermez.

---

## FINAL / CEREMONY UX

Normal level:

**`Bölüm Tamamlandı`**

Route final complete fakat routeComplete=false:

**`Final Tamamlandı`**

**`Rotayı tamamlamak için X yıldız daha kazan.`**

Gerçek false→true routeComplete:

**`Rota Tamamlandı!`**

Gösterilenler:
- route adı
- **`Rozet Kazandın`**
- reward display name
- toplam/max yıldız
- varsa **`<Gelecek rota adı> açıldı.`**

CTA:
- **`Yeni Rotayı Gör`**
- **`Rotaya Dön`**

Kadim terminal copy:

**`Tüm mevcut rotaları tamamladın.`**

`WordHuntLevelProductionScreen.deferCompletionDialog` route-final first completion double-dialog'unu önler; exit confirmation korunur.

---

## SELECTOR BİLGİSİ — PR #209 İLE SUPERSEDED

Bu dosyanın eski sürümündeki aşağıdaki selector bilgileri artık authoritative değildir:

- selector yalnız küçük `Kazanıldı` satırıyla completed/reward state anlatır,
- selector'da recommended/current/next rota yoktur,
- bütün unlocked kartlar eşit ağırlıktadır,
- completed first-class presentation state değildir,
- locked route identity generic leading lock'a dönüşür,
- locked ordinal görünmez,
- final+17★ locked requirement `10 / 10 bölüm` gösterir,
- locked tap feedback yoktur,
- all-routes-complete selector state yoktur,
- selector responsive / large-text / semantics regression yoktur,
- selector polish audit/implementasyon bekliyor.

Bunların güncel authoritative karşılığı:

`docs/project-memory/SOHBET_DEVIR_2026-09-17_ROUTE_SELECTOR_GUIDED_POLISH_KAPANIS.md`

PR #209 ile selector artık guided progression presentation kullanır.

---

## PR #208 CI KAPANIŞI

Approved exact head: `0d724e7544811cf74c85b9058800cee8396fea67`

- Kelime Avı Orman Yolu içerik kapısı — Run #13 / ID `35207375685` — **SUCCESS**
- Kelime Avı route catalog kapısı — Run #89 / ID `35207375718` — **SUCCESS**
- Orman Yolu Android çoklu ekran kanıtı — Run #34 / ID `35207375778` — **SUCCESS**
- Kelime Avı Android 16 görsel kanıtı — Run #452 / ID `35207375795` — **SUCCESS**
- AdMob PR doğrulaması — Run #829 / ID `35207375767` — **SUCCESS**

---

## SIRADAKİ AUTHORITATIVE BAŞLANGIÇ

Selector polish artık tamamlanmıştır.

Yeni authoritative başlangıç:

# KELİME AVI — 5. ROTA READINESS / ÜRÜN + TEKNİK AUDIT

İlk tur yalnız audit olacak. Owner kararı verilmeden route/content/asset/branch/PR oluşturulmayacaktır.

Detaylı audit scope'u yeni selector kapanış dosyasındadır.

## DEVİR CÜMLESİ

Yeni sohbet şu prompt ile başlayabilir:

`GENEL_PROJE_OZETI.md ve SOHBET_DEVIR_2026-09-17_ROUTE_SELECTOR_GUIDED_POLISH_KAPANIS.md dosyalarını oku; canlı target HEAD'i doğrula ve KELİME AVI — 5. ROTA READINESS / ÜRÜN + TEKNİK AUDIT'ten devam et. İlk tur yalnız audit; kod değiştirme.`
