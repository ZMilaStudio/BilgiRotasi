# Bilgi Rotası — Sohbet Devir Notu

**Tarih:** 17 Eylül 2026  
**Konu:** Kelime Avı / Kristal Vadisi / PR #210 / owner visual review sonrası son durum

> **YENİ SOHBET İÇİN ZORUNLU DUR KURALI**
>
> Bu dosyayı ve `GENEL_PROJE_OZETI.md` dosyasını okuduktan sonra **kendiliğinden hiçbir işe devam etme**.  
> CI bekleme/takip etme, commit atma, PR değiştirme, merge etme, workflow rerun etme, kod/test/docs/asset değiştirme.  
> **Owner yeni bir prompt verene kadar yalnızca bekle.**

## Önce okunacaklar

1. `docs/project-memory/GENEL_PROJE_OZETI.md`
2. `docs/project-memory/SOHBET_DEVIR_2026-09-17_KRISTAL_VADISI_PR210_OWNER_VISUAL_REVIEW.md`
3. `docs/project-memory/SOHBET_DEVIR_2026-09-17_ROUTE_SELECTOR_GUIDED_POLISH_KAPANIS.md`
4. `docs/project-memory/SOHBET_DEVIR_2026-09-17_ROUTE_REWARD_FINAL_CEREMONY_KAPANIS.md`
5. `KELIME_AVI_REUSABLE_HARITA_KARARI.md`

Çelişki halinde öncelik: **canlı GitHub > bu devir notu > diğer project-memory docs > eski sohbetler**.

---

## Canlı repo / branch / PR baseline

Repo: `ZMilaStudio/BilgiRotasi`

Target branch:
`release/final-closed-test-aab-1.68.8`

Target HEAD, devir hazırlanırken:
`89b4d4bae4af4bda35d77e7e8c52026fce4c271c`

Feature branch:
`feat/kelime-avi-kristal-vadisi`

PR:
`#210 — feat(kelime-avi): add Kristal Vadisi route`

PR durumu devir hazırlanırken:
- state: OPEN
- draft: true
- merged: false
- mergeable: true
- base: `release/final-closed-test-aab-1.68.8`

Son runtime/feature HEAD (docs devrinden hemen önce):
`22b4995a88e0f8937bf716954edba79319d7ec99`

Bu commit bir **tree-identical CI retrigger commit**tir. Parent visual polish commit:
`3c5ff74c16d53ac5acba29ea95406ddf7d8df158`

İki commit arasında changed file yoktur; runtime tree aynıdır:
`4485b108c5b36d00af9e08897963c35cfde3dfeb`

Visual polish commit mesajı:
`feat(kelime-avi): enlarge crystal node silhouettes`

CI retrigger commit mesajı:
`ci(kelime-avi): retrigger Kristal validation`

**Önemli:** Bu devir/docs commit'i feature branch HEAD'ini yalnız docs değişikliğiyle ilerletebilir. Yeni sohbet live branch HEAD'i yeniden doğrulamalı; runtime tree ile docs-only HEAD'i birbirine karıştırmamalı.

---

## Kristal Vadisi feature contract

Kullanıcı adı: **Kristal Vadisi**  
Technical route ID: `kristal-vadisi`  
Ordinal: **Beşinci rota**  
Presentation: `themedReusable`

Rota sırası:

**Başlangıç Limanı → Gökyüzü Adaları → Orman Yolu → Kadim Orman → Kristal Vadisi**

Unlock:
Kadim Orman `routeComplete` → Kristal Vadisi

Locked copy exact:
**`Kadim Orman’ı tamamlayarak aç.`**

Kristal own completion:
`unlockStarsRequired = 0`; L10 final completion yeterlidir. 18★ gate yoktur.

Reward:
- ID: `badge-kristal-kasifi`
- display: `Kristal Kaşifi`

Progress schema **2** korunur. Schema 1 backward decode, historical backfill, storage prefix ve generic reward grant contract değiştirilmez.

Kadim artık feature branch'te terminal değildir; generic `nextCatalogEntry(Kadim)` Kristal'i döndürür. Kristal terminal route olur ve terminal copy yine:
**`Tüm mevcut rotaları tamamladın.`**

---

## Content / balance authoritative baseline

Kristal content OWNER APPROVED ve değiştirilmemelidir:
- 10 level
- 56 mandatory target
- 14 bonus
- 70 unique route-internal listed word
- 8×8 deterministic grid
- `straightEightDirections`
- listed target/bonus physical occurrence exact-one
- L5 challenge
- L10 routeFinal

L5:
- 3★: 0 mistake + <=30 sec
- 2★: <=1 mistake + <=44 sec
- soft `timeLimitSeconds` semantics mevcut pattern'i korur

L10:
- 3★: 0 mistake + <=58 sec
- 2★: <=2 mistakes + <=78 sec
- soft `timeLimitSeconds` semantics mevcut pattern'i korur

Altı info card:
- `kristal-info-mineral`
- `kristal-info-kuvars`
- `kristal-info-kristal`
- `kristal-info-obsidyen`
- `kristal-info-fay`
- `kristal-info-ametist`

---

## Approved artwork — kesinlikle değiştirme

Production path:
`assets/word_hunt/KRISTAL_VADISI_ENV_941x1672.webp`

Exact contract:
- dimensions: `941×1672`
- bytes: `2,793,116`
- SHA-256: `189dec3f731f66e72449625457d35d28500fe5cbd5a69ab1f2f04f303ca1bc20`
- Git blob: `3f96949385dba4b43b6a4062693e899c47b2f71d`

Not: owner-approved exact bytes `.webp` path altında tutulur; re-encode / resize / crop / recolor / regenerate / image edit **yasak**.

Background, broken/stepping turquoise path ve tall ambient owner tarafından **APPROVED** kabul edildi. Yeni prompt açıkça istemedikçe bunlara dokunma.

---

## Node visual review geçmişi ve son polish

Run #4 artifact owner tarafından fiilen açıldı ve node visual **reddedildi**. Ana teşhis:
- mikro painter detayları 411 px cihazda kayboluyordu,
- normal gövde çok küçüktü,
- L10 crest outline crown gibi okunuyordu,
- çözüm daha çok çizgi değil **BIGGER + SIMPLER + STRONGER SILHOUETTE** idi.

Owner'ın son somut hedefi:
- normal crystal body yaklaşık `46–48 px`
- outer shard silhouette yaklaşık `54–58 px`
- L10 filled crest yaklaşık `48–54 × 28–34 px`
- final hierarchy: **L10 > L5 > normal**
- 411×731 ana değerlendirme viewport'u
- outline crown / thin triangle strokes yasak
- L10 crest 5 adet **filled crystal prism** olmalı

Son implementation (`3c5ff74…`) bunu şu exact metriklerle uyguladı:
- `normalScale = 1.00`
- `challengeScale = 1.06`
- `finalScale = 1.11`
- normal body: `48×46`
- normal shard silhouette: `58`
- final body: `52×50`
- final shard silhouette: `62`
- final crest: `52×32`

Renderer generic `WordHuntRouteNodeVisualStyle.facetedCrystal` üzerinden çalışır. Route-id special-case eklenmedi. Canonical geometry ve hitbox değişmedi.

Normal node:
- büyük amethyst gem body
- 6 daha belirgin shard
- büyük facet planes
- turquoise/mineral ring

Locked node:
- smoky violet/obsidian gem
- silver/lavender crystalline ring/shards
- integrated crystal lock badge

L5 challenge:
- normalden %6 civarı büyük
- gold accent var ama finalden yapısal olarak daha sade

L10:
- daha büyük final medallion
- double/faceted ring
- 5 adet **filled prism** crystal crest
- locked: dormant silver/lavender
- active: amethyst + gold edge + turquoise accent
- Material crown / emoji crown / raster crown yok

---

## Son gerçek Android visual proof

Visual polish tree `3c5ff74…` üzerinde Android proof başarıyla tamamlandı:

Run ID:
`35267683267`

Job:
Android proof — SUCCESS

Artifact:
- ID: `10518395359`
- name: `Kristal-Android-Proof-3c5ff74`
- size: `13,688,635 bytes`

Artifact'taki 5 PNG:
- `KRISTAL_LOCKED_411x731.png`
- `KRISTAL_LOCKED_720x1280.png`
- `KRISTAL_LOCKED_1080x1920.png`
- `KRISTAL_LOCKED_1080x2400.png`
- `KRISTAL_ACTIVE_FINAL_1080x1920.png`

Son asistan incelemesinde:
- 411 px'de normal medallion silhouette belirginleşti,
- L6–L9 dormant crystal/obsidian seal olarak daha iyi okundu,
- L10 crest outline-crown yerine dolu 5-prism crystal formation oldu,
- active L10 map'in en prestijli treatment'i olarak okundu,
- background/path/tall ambient korunmuş görünüyordu.

**Fakat owner bu yeni artifact için henüz açık final görsel onay vermedi.** Bu nedenle PR merge-ready sayılmaz. Yeni sohbet owner prompt'u olmadan burada hiçbir karar/işlem yapmayacak.

---

## CI snapshot — yalnız referans, live recheck zorunlu

Tree-identical final runtime HEAD `22b4995…` üzerinde standart PR workflow'ları yeniden tetiklendi.

Devir hazırlanırken:
- Kelime Avı route catalog kapısı — Run #96 / ID `35268797339` — **SUCCESS**
- Kelime Avı Android 16 görsel kanıtı — Run #459 / ID `35268797332` — **IN PROGRESS**
- Orman Yolu Android çoklu ekran kanıtı — Run #41 / ID `35268797356` — **IN PROGRESS**
- AdMob PR doğrulaması — Run #836 / ID `35268797543` — **IN PROGRESS**

Ayrıca exact runtime head'i proof harness'ta yeniden doğrulamak için CI validation branch üzerinde:
- Run ID: `35268889739`
- Job ID: `105362896300`
- son snapshot: APK build tamamlandı/ilerledi, Android capture henüz tamamlanmamıştı.

Bu durumlar hızla değişebilir. **Yeni sohbet prompt verilmedikçe bunları takip etmeyecek.** Prompt geldiğinde önce canlı GitHub'dan yeniden doğrulanacak.

---

## PR #210 scope guard

Dokunulmaması gerekenler:
- artwork bytes / SHA
- background
- path direction/geometry
- tall ambient (owner açıkça istemezse)
- canonical node centers
- hitbox
- content/grids
- scoring
- progression
- route catalog semantics
- rewards / persistence / schema
- selector product contract
- historical reveal semantics
- dependencies

PR #210 Draft kalmalı; owner açık onay vermeden **MERGE YOK**.

---

## Yeni sohbetin davranışı

Yeni sohbet bu dosyayı okuyunca kullanıcıya en fazla kısa bir şekilde **devir bağlamını aldığını ve komut beklediğini** söyleyebilir.

**YAPMAYACAK:**
- CI monitor etmeye başlamak
- görsel proof indirmek
- yeni screenshot incelemek
- commit atmak
- docs güncellemek
- PR body değiştirmek
- merge etmek
- branch silmek
- release/tag oluşturmak
- bir sonraki işi tahmin edip başlatmak

**Owner prompt verene kadar DUR.**
