# SOHBET DEVİR — 17 Eylül 2026 — ROUTE REWARD + FINAL CEREMONY KAPANIŞI

Bu dosya BilgiRotasi / Kelime Avı için PR #208 ile tamamlanan route reward + final ceremony çalışmasının authoritative kapanış ve sonraki audit başlangıç notudur.

## Yeni sohbette okuma sırası

1. `docs/project-memory/GENEL_PROJE_OZETI.md`
2. Bu dosya: `docs/project-memory/SOHBET_DEVIR_2026-09-17_ROUTE_REWARD_FINAL_CEREMONY_KAPANIS.md`
3. `KELIME_AVI_REUSABLE_HARITA_KARARI.md`
4. Canlı GitHub target HEAD / ilgili PR / Actions durumunu yeniden doğrula.

Çelişki varsa öncelik: **canlı GitHub > proje memory/karar dosyaları > eski sohbetler**.

---

## REPO / MERGE BASELINE

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

Bu kapanış dokümantasyon commit'i target HEAD'i `c880550e…` sonrasından ayrıca ilerletecektir; yeni sohbette exact HEAD mutlaka canlı doğrulanmalıdır.

---

## AUTHORITATIVE ROUTE REWARD CONTRACT

| Rota | Technical route id | routeRewardId | Kullanıcıya görünen rozet |
|---|---|---|---|
| Başlangıç Limanı | `baslangic-limani` | `badge-kelime-yolcusu` | Kelime Yolcusu |
| Gökyüzü Adaları | `gokyuzu-adalari` | `badge-gokyuzu-kasifi` | Gökyüzü Kaşifi |
| Orman Yolu | `orman-yolu` | `badge-orman-kasifi` | Orman Kaşifi |
| Kadim Orman | `orman-2` | `badge-kadim-orman-kasifi` | Kadim Orman Kaşifi |

Eski `reward-orman-yolu` ve `reward-orman-2` identity'leri superseded'dır.

Reward display metadata route-id `if/switch` zincirlerine dağıtılmamıştır; `routeRewardId → reward metadata` data-driven catalog üzerinden çözülür.

Yeni raster/png/webp badge asset eklenmemiştir. Mevcut Flutter/Material iconography ve route palette kullanılır.

---

## REWARD GRANT SEMANTİĞİ

Reward grant yalnız gerçek:

`routeComplete false → routeComplete true`

transition'ında olur.

Authoritative route-complete hesabı:

`WordHuntRouteProgressEngine.isRouteComplete(route, progress)`

L10 tamamlandı diye doğrudan reward verilmez.

Başlangıç Limanı / Gökyüzü Adaları için:

- final daha önce tamamlanmış olabilir,
- toplam route stars 18'in altındaysa `routeComplete=false`,
- reward YOK,
- daha sonra normal bir level replay'i toplamı 18'e çıkarırsa false→true transition o anda oluşur,
- reward grant + persistence + route completion ceremony o anda çalışır.

Orman Yolu / Kadim Orman için `unlockStarsRequired=0`; final completion gerçek routeComplete transition'ını oluşturduğu anda reward grant edilir.

Grant idempotent'tır:

- reward set semantics kullanır,
- duplicate reward ownership oluşmaz,
- already-earned replay duplicate reward reveal açmaz.

Reward unlock rule değildir; routeComplete milestone'unun kalıcı kullanıcı kazanımıdır.

---

## PERSISTENCE / SCHEMA / MIGRATION

`WordHuntProgressSnapshot` artık en az şunları taşır:

- `bestStarsByLevelId`
- `unlockedInfoCardIds`
- `unlockedRouteRewardIds`

Reward ownership gerçek persisted achievement state'tir. Future route-condition değişimlerinde otomatik silinmez.

Payload schema:

**2**

Decoder contract:

- schema 1 → desteklenir
- schema 2 → desteklenir
- unknown future schema → fail-closed

Storage key/prefix değiştirilmemiştir:

`bilgi_rotasi_word_hunt_progress_v1_`

### V1 backward compatibility

Eski schema-v1 save:

- reset olmaz,
- stars kaybetmez,
- infoCards kaybetmez,
- decode fail olmaz.

V1 decode sonrası production route catalog üzerinden historical reward backfill çalışır.

Backfill:

- yalnız reward EKLER,
- stars değiştirmez,
- infoCards değiştirmez,
- progression değiştirmez,
- idempotent'tır.

Historical backfill sessizdir; eski kullanıcıya açılışta retroaktif ceremony spam'i gösterilmez.

---

## FINAL / CEREMONY UX

### Normal level

Mevcut generic completion korunur:

**`Bölüm Tamamlandı`**

### Route final tamamlandı, rota henüz complete değil

Yalnız first-time incomplete route-final flow'da parent-owned surface gösterilir:

Başlık:

**`Final Tamamlandı`**

Copy:

**`Rotayı tamamlamak için X yıldız daha kazan.`**

Reward grant yoktur.

### Gerçek routeComplete false→true

Başlık:

**`Rota Tamamlandı!`**

Gösterilenler:

- route adı
- **`Rozet Kazandın`**
- reward display name
- toplam rota yıldızı / max yıldız (`route.levels.length * 3`)
- varsa next-route mesajı

Next-route copy:

**`<Gelecek rota adı> açıldı.`**

Primary CTA:

**`Yeni Rotayı Gör`**

Secondary CTA:

**`Rotaya Dön`**

Next route production catalog sırasından data-driven türetilir; route-id özel navigation chain yoktur.

---

## KADİM ORMAN TERMINAL UX

Kadim Orman mevcut son production rotadır.

Kadim routeComplete ceremony:

- başlık: **`Rota Tamamlandı!`**
- reward: **Kadim Orman Kaşifi**
- terminal copy: **`Tüm mevcut rotaları tamamladın.`**
- next-route CTA YOK
- 5. rota / yakında / devamı geliyor tease YOK
- CTA: **`Rotaya Dön`**

---

## DOUBLE-DIALOG FIX

Route-final first-completion flow'da generic:

`Bölüm Tamamlandı`

ile parent-owned:

`Final Tamamlandı` / `Rota Tamamlandı!`

artık üst üste gösterilmez.

Authoritative presentation contract:

`WordHuntLevelProductionScreen.deferCompletionDialog`

- default: `false`
- normal production level davranışı değişmez
- deferred route-final success generic result dialog'u açmaz
- scoring/timer/mistake/bonus/info-card hesaplaması değişmez
- aynı `WordHuntLevelPlayResult` parent orchestration'a döner
- exit confirmation **`Bölümden çıkılsın mı?`** korunur.

Eski nested Navigator observer / completion-dialog auto-pop interception yaklaşımı superseded'dır.

Non-final replay routeComplete threshold'unu false→true geçirirse normal generic level result ardından route milestone ceremony gösterilebilir; bu kabul edilen contract'tır.

---

## SELECTOR REWARD STATE

Persisted reward ownership varsa route selector kartında:

- küçük reward icon
- **`Kazanıldı`**

indicator görünür.

Bu indicator:

- unlock logic'i değiştirmez,
- card tap logic'i değiştirmez,
- locked route'u açmaz,
- progression yerine geçmez,
- yalnız kalıcı reward ownership'i gösterir.

---

## PROGRESSION / SCORING / CONTENT KORUMASI

Route progression değişmedi:

**Başlangıç Limanı → Gökyüzü Adaları → Orman Yolu → Kadim Orman**

- Başlangıç/Gökyüzü routeComplete = final complete + >=18★
- Orman/Kadim `unlockStarsRequired=0`; final completion yeterli.

PR #207 challenge/final star-time matrix aynen korunur:

| Rota | L5 3★/2★ sec | L10 3★/2★ sec |
|---|---|---|
| Başlangıç Limanı | 35 / 50 | 75 / 100 |
| Gökyüzü Adaları | 35 / 50 | 75 / 100 |
| Orman Yolu | 25 / 36 | 50 / 66 |
| Kadim Orman | 24 / 35 | 48 / 64 |

L5 mistakes: 3★ 0, 2★ <=1.  
L10 mistakes: 3★ 0, 2★ <=2.  
`timeLimitSeconds` 60/120 soft metadata'dır; hard fail değildir.

PR #208 kapsamında değişmeyenler:

- scoring engine
- grids
- targetWords
- bonusWords
- infoCards
- route order / route titles
- star/time balance
- timeLimit semantics
- map geometry
- renderer / NodeSkin
- environment assets
- immutable Kadim visual
- dependencies

Yeni badge raster asset eklenmedi.

---

## CI KAPANIŞI

Approved exact head: `0d724e7544811cf74c85b9058800cee8396fea67`

- Kelime Avı Orman Yolu içerik kapısı — Run #13 / ID `35207375685` — **SUCCESS**
- Kelime Avı route catalog kapısı — Run #89 / ID `35207375718` — **SUCCESS**
- Orman Yolu Android çoklu ekran kanıtı — Run #34 / ID `35207375778` — **SUCCESS**
- Kelime Avı Android 16 görsel kanıtı — Run #452 / ID `35207375795` — **SUCCESS**
- AdMob PR doğrulaması — Run #829 / ID `35207375767` — **SUCCESS**

AdMob #829 içinde:

- Analiz ve tüm testler — PASS
- test reklam kimlikli release APK — PASS
- package / merged manifest — PASS
- Android 16 cold-start deneme 1 — PASS
- AdMob Android 16 uygulama kapısı — PASS

---

## REGRESSION BASELINE — TESTLE KİLİTLİ

- schema v1 save korunur
- schema v2 reward roundtrip çalışır
- duplicate reward yok
- historical backfill idempotent
- reward set `recordLevelResult()` sırasında kaybolmaz
- Başlangıç final +17★ → reward yok
- daha sonraki replay ile 18★ → reward grant
- Orman final → route reward
- Kadim final → route reward + terminal copy
- already-earned replay → duplicate reward reveal yok
- route-final generic double-dialog yok
- deferred final exit confirmation korunur
- selector earned indicator unlock logic'i değiştirmez

---

## SUPERSEDED BİLGİLER

Aşağıdakiler artık authoritative değildir:

- `routeRewardId` metadata-only
- production reward consumer yok
- reward persistence yok
- badge/reward state yok
- reward grant yok
- routeFinal normal completion ile tamamen aynı
- next-route unlock kullanıcıya hiç gösterilmiyor
- final ceremony yok
- progress codec yalnız schema-v1 destekliyor
- Orman reward ID = `reward-orman-yolu`
- Kadim reward ID = `reward-orman-2`
- PR #208 draft / audit / implementasyon bekliyor

---

## SIRADAKİ AUTHORITATIVE AUDIT

# KELİME AVI — ROUTE SELECTOR POLISH AUDIT

İlk tur **yalnız audit** olacak. Henüz selector redesign veya runtime değişikliği yapılmayacak.

İncelenecekler:

1. Dört rota kartının hierarchy'si.
2. Locked / unlocked / completed / reward-earned state'leri.
3. Ordinal kullanımı.
4. Route title ağırlığı.
5. Progress / stars gösterimi.
6. `Kazanıldı` indicator'ın kartı kalabalıklaştırıp kalabalıklaştırmadığı.
7. Locked copy okunabilirliği.
8. Current / next route vurgusu.
9. Kartların birbirinden görsel ayrımı.
10. Kadim Orman premium / final-route hissi.
11. Küçük ekran / büyük ekran davranışı.
12. Accessibility / semantics.
13. Tap target'lar.
14. Route state'lerinin kullanıcı tarafından hızlı anlaşılması.

### Bu auditin ilk turunda YAPMA

- selector redesign / runtime change
- progression/scoring/content change
- reward/schema change
- asset change
- 5. rota oluşturma veya tasarlama

## 5. ROTA

5. rota henüz açılmaz. Önce selector polish konusu kapanır.

## DEVİR CÜMLESİ

Yeni sohbet şu prompt ile başlayabilir:

`GENEL_PROJE_OZETI.md ve SOHBET_DEVIR_2026-09-17_ROUTE_REWARD_FINAL_CEREMONY_KAPANIS.md dosyalarını oku; canlı target HEAD'i doğrula ve KELİME AVI — ROUTE SELECTOR POLISH AUDIT'ten devam et. İlk tur yalnız audit; kod değiştirme.`
