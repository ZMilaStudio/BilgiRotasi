# SOHBET DEVİR — 17 Eylül 2026 — ROUTE SELECTOR GUIDED POLISH KAPANIŞI

Bu dosya BilgiRotasi / Kelime Avı için PR #209 ile tamamlanan guided progression route selector polish çalışmasının authoritative kapanış ve sıradaki audit başlangıç notudur.

## Yeni sohbette okuma sırası

1. `docs/project-memory/GENEL_PROJE_OZETI.md`
2. Bu dosya: `docs/project-memory/SOHBET_DEVIR_2026-09-17_ROUTE_SELECTOR_GUIDED_POLISH_KAPANIS.md`
3. `KELIME_AVI_REUSABLE_HARITA_KARARI.md`
4. Canlı GitHub target HEAD / ilgili PR / Actions durumunu yeniden doğrula.

Çelişki varsa öncelik: **canlı GitHub > proje memory/karar dosyaları > eski sohbetler**.

---

## REPO / MERGE BASELINE

- Repo: `ZMilaStudio/BilgiRotasi`
- Target: `release/final-closed-test-aab-1.68.8`
- PR: **#209 — `feat(kelime-avi): guide route selector progression`**
- PR state: **MERGED**
- Approved exact PR head: `5da106f4c52d7e8533d91878c8482b835a8b9dca`
- Approved head tree: `a71691ecfe04ff2850aa67fa0b6f08aafaa667bf`
- Squash merge commit: `92135e01a2c22f37441a4d7192265f3d9902ebc0`
- Squash merge tree: `a71691ecfe04ff2850aa67fa0b6f08aafaa667bf`
- Tree equality: **EVET**
- Squash parent: `8c810d46f4d2fb12616e97bfba310c2a2e2716a4`
- Source branch: `feat/kelime-avi-route-selector-guided-polish`
- Source branch exact SHA at merge close: `5da106f4c52d7e8533d91878c8482b835a8b9dca`
- Source branch owner istemeden silinmez.

Bu docs kapanış commit'i target HEAD'i `92135e01…` sonrasından ayrıca ilerletecektir; yeni sohbette exact HEAD canlı doğrulanmalıdır.

---

## AUTHORITATIVE GUIDED PROGRESSION SELECTOR CONTRACT

Mevcut dört production rota:

1. Başlangıç Limanı
2. Gökyüzü Adaları
3. Orman Yolu
4. Kadim Orman

Route order ve progression değişmedi.

Selector presentation için state'ler data-driven türetilir:

- `unlocked`
- `routeComplete`
- `rewardEarned`
- `recommended`
- `hasProgress`
- locked requirement progress

`routeComplete`:

`WordHuntRouteProgressEngine.isRouteComplete(route, progress)`

ile hesaplanır.

`rewardEarned`:

`progress.unlockedRouteRewardIds.contains(route.routeRewardId)`

ile hesaplanır.

Completion ve reward ownership ayrı kavramlardır.

---

## RECOMMENDED ROUTE

Selector'daki tek recommended rota catalog sırasındaki ilk:

`entry.isUnlocked(progress) == true`

ve

`WordHuntRouteProgressEngine.isRouteComplete(entry.route, progress) == false`

entry'dir.

Route-id hardcode yoktur.

Recommended rota hiç başlanmamışsa visible state:

**`Sıradaki`**

Recommended rota üzerinde toplam yıldız progress'i `> 0` ise:

**`Devam Et`**

Bütün production rotalar complete ise recommended rota **YOK**.

---

## COMPLETED / REWARD PRESENTATION

`routeComplete == true` artık first-class selector presentation state'idir.

Visible completion copy:

**`Tamamlandı`**

Reward ownership varsa aynı compact status alanında:

**`Rozet kazanıldı`**

gösterilir.

Sighted selector UI tam reward display name'i zorunlu olarak göstermez; authoritative reward display name accessibility semantics içinde korunur.

Reward state:
- unlock üretmez,
- progression üretmez,
- recommended hesabına girmez,
- inconsistent reward-earned + locked state'te unlock bypass ettirmez.

Recommended kart daha belirgin border/accent ve kontrollü shadow/glow ile vurgulanır. Completed kart daha sakin treatment kullanır.

---

## PROGRESS PRESENTATION

Unlocked rota progress'i exact semantik olarak:

**`X / Y yıldız`**

gösterilir.

Maximum hard-code edilmez; `route.maximumStars` üzerinden türetilir.

Completion/reward status progress'ten ayrı hierarchy'de tutulur.

---

## LOCKED REQUIREMENT PROGRESS

Locked kart, prerequisite'in o anda gerçekten eksik olan şartını gösterir.

### A — prerequisite final henüz tamamlanmadı

**`X / Y bölüm`**

Örnek:

`8 / 10 bölüm`

### B — prerequisite final tamamlandı, yıldız gate eksik

Prerequisite:
- `unlockStarsRequired > 0`
- `currentStars < unlockStarsRequired`

ise:

**`X / required yıldız`**

Örnek:

`17 / 18 yıldız`

Bu davranış özellikle:
- Başlangıç → Gökyüzü
- Gökyüzü → Orman

için authoritative'dir.

### C — zero-star threshold prerequisite

`unlockStarsRequired == 0` ise bölüm/final progress korunur.

Orman → Kadim için yapay 18★ threshold yoktur.

`WordHuntRouteUnlockKind.routeStars` generic `current / required yıldız` semantiğini korur.

---

## 17★ KRİTİK UX

Başlangıç final complete + toplam 17★:

### Başlangıç
- unlocked
- `routeComplete=false`
- recommended
- **`Devam Et`**
- **`17 / 30 yıldız`**

### Gökyüzü
- locked
- authoritative locked copy:
  **`Başlangıç Limanı’nı tamamla ve en az 18 yıldız kazan.`**
- unmet requirement:
  **`17 / 18 yıldız`**

Bu durumda eski:

`10 / 10 bölüm`

presentation'ı superseded'dır.

Aynı semantic:

Gökyüzü final complete +17★ → Orman locked → **`17 / 18 yıldız`**.

---

## AUTHORITATIVE LOCKED COPY

Gökyüzü:

**`Başlangıç Limanı’nı tamamla ve en az 18 yıldız kazan.`**

Orman:

**`Gökyüzü Adaları’nı tamamla ve en az 18 yıldız kazan.`**

Kadim:

**`Orman Yolu’nu tamamlayarak aç.`**

Requirement progress bu copy'leri tamamlar; yerine geçmez.

---

## LOCKED INTERACTION / IDENTITY

Locked card tap:
- route açmaz,
- `onRouteTap(entry)` çağırmaz,
- unlock bypass etmez,
- authoritative locked reason SnackBar ile tekrar gösterilir.

Feedback source:
- `entry.lockedMessage`
- null ise data-driven fallback.

Locked card leading icon generic büyük lock'a dönüşmez. Route identity korunur:

- Başlangıç → anchor
- Gökyüzü → cloud
- Orman → park
- Kadim → forest

Lock ayrı treatment ile anlatılır. Çift büyük lock presentation superseded'dır.

---

## ORDINAL

Ordinal bütün selector state'lerinde görünür:

- **İlk rota**
- **İkinci rota**
- **Üçüncü rota**
- **Dördüncü rota**

Locked kartta ordinal'in kaybolduğu eski davranış superseded'dır.

Ordinal secondary meta'dır; route title dominant kalır.

---

## ALL ROUTES COMPLETE

Dört mevcut production rota complete ise selector header exact:

**`Tüm mevcut rotaları tamamladın.`**

Bu state'te:
- recommended rota yok
- `Sıradaki` yok
- `Devam Et` yok
- 5. rota tease yok.

Bu terminal state catalog'daki mevcut tüm entry'lerin `routeComplete` olmasından data-driven türetilir.

---

## KADİM ORMAN SELECTOR TREATMENT

Kadim için route-id özel büyük redesign yapılmadı.

Mevcut:
- dark-green palette
- forest identity

korundu.

Locked halde forest identity kaybolmaz.

Kadim recommended olduğunda aynı guided progression recommended hierarchy uygulanır.

Selector copy'sine:
- Son rota
- Final rota
- Yakında yeni rota

eklenmedi.

Bu yaklaşım gelecekte catalog genişlemesine izin verir.

---

## RESPONSIVE CONTRACT

Focused selector regressions:

- **320×640 — PASS**
- **360×800 — PASS**
- **411×731 — PASS**
- **480 px reachability — PASS**
- **320 px + 1.5 text scale — PASS**

Locked copy truncate edilmez. Fixed card height kullanılmaz. Kart gerektiğinde dikey büyür ve scroll reachability korunur.

### Status chip fix

İlk implementation turunda 320 px + 1.5 text scale üzerinde gerçek status-chip overflow yakalandı.

Test gevşetilmedi.

Production status layout `Wrap` tabanlı hale getirildi.

Final approved exact HEAD'de regression PASS.

---

## ACCESSIBILITY / SEMANTICS

Kart seviyesinde tek authoritative semantic label kullanılır.

State'e göre bilgi:

Recommended:
- `Sıradaki` veya `Devam Et`

Complete:
- `Tamamlandı`

Reward:
- `Rozet kazanıldı`
- gerçek reward display name

Locked:
- `Kilitli`
- reason
- current unmet requirement

Nested visual/status children semantics'ten dışlanır; duplicate reward announce temizlenmiştir.

Focused semantics regression PASS.

Test harness `SemanticsHandle` teardown eksikliği de fixlenmiştir.

---

## TEST BASELINE — TESTLE KİLİTLİ

- STATE A: fresh user → Başlangıç **Sıradaki**
- STATE B: Başlangıç final +17★ → Başlangıç **Devam Et**, Gökyüzü locked
- STATE C: Başlangıç complete → Gökyüzü **Sıradaki**
- STATE D: Gökyüzü complete → Orman **Sıradaki**
- STATE E: Orman complete → Kadim **Sıradaki**
- STATE F: bütün rotalar complete → recommended yok + **`Tüm mevcut rotaları tamamladın.`**
- partial recommended → **`Devam Et`**
- final incomplete prerequisite → **`X / Y bölüm`**
- final complete + star gate eksik → **`X / required yıldız`**
- Orman→Kadim zero-star threshold → level/final progress
- locked tap route açmaz
- locked ordinal görünür
- route identity locked halde korunur
- complete ve reward ayrı state'tir
- reward-earned locked state unlock bypass etmez
- 320/360/411 responsive PASS
- 480 reachability PASS
- 1.5 text scale PASS
- semantics PASS

---

## CI KAPANIŞI

Approved exact head:

`5da106f4c52d7e8533d91878c8482b835a8b9dca`

SUCCESS:

- Kelime Avı route catalog kapısı — Run #92 / ID `35217743668`
- Orman Yolu Android çoklu ekran kanıtı — Run #37 / ID `35217743501`
- Kelime Avı Android 16 görsel kanıtı — Run #455 / ID `35217743468`
- AdMob PR doğrulaması — Run #832 / ID `35217743499`

AdMob #832:
- Analiz ve tüm testler — SUCCESS
- release APK — SUCCESS
- package + merged manifest — SUCCESS
- Android 16 cold-start deneme 1 — SUCCESS
- final application gate — SUCCESS

İkinci cold-start gerekmediği için skipped.

Kelime Avı Orman Yolu içerik kapısı selector-only path filter nedeniyle bu exact HEAD'de yeni run üretmedi.

---

## KORUNAN CONTRACT'LAR

PR #209 kapsamında değişmedi:

- route progression
- unlock rules
- reward IDs
- reward grant
- reward persistence
- schema 2
- schema 1 backward compatibility
- historical reward backfill
- completion ceremony
- scoring engine
- challenge/final balance
- timeLimit semantics
- grids
- targetWords
- bonusWords
- infoCards
- route IDs
- route titles
- route order
- map geometry
- renderer
- NodeSkin
- visual assets
- dependencies

5. rota eklenmedi.

---

## SUPERSEDED SELECTOR BİLGİLERİ

Aşağıdakiler artık authoritative değildir:

- selector'da recommended/current/next rota yok
- bütün unlocked kartlar eşit ağırlıkta
- completed first-class state değil
- tamamlanma yalnız `Kazanıldı` üzerinden anlaşılır
- reward visible copy yalnız `Kazanıldı`
- locked route identity generic lock'a dönüşür
- locked ordinal görünmez
- final+17★ locked progress `10 / 10 bölüm` gösterir
- locked card tap hiçbir feedback vermez
- all-routes-complete selector state yok
- responsive selector regression yok
- large-text selector regression yok
- semantics regression yok
- selector polish hâlâ bekliyor
- PR #209 open/draft

---

## SIRADAKİ AUTHORITATIVE AUDIT

# KELİME AVI — 5. ROTA READINESS / ÜRÜN + TEKNİK AUDIT

İlk tur **yalnız audit** olacak.

Owner kararı verilmeden:
- route oluşturma
- content yazma
- asset üretme
- branch/PR açma

YAPILMAYACAK.

Audit özellikle:

1. Mevcut dört rota progression zinciri.
2. Catalog'un 5. entry eklemeye hazır olup olmadığı.
3. Selector recommended algoritmasının 5. rotayı otomatik kapsayıp kapsamadığı.
4. `Tüm mevcut rotaları tamamladın.` state'inin 5. rota eklenince data-driven biçimde taşınıp taşınmadığı.
5. Kadim Orman terminal ceremony logic'inin 5. rota eklenince otomatik next-route ceremony'ye dönüşüp dönüşmediği.
6. `WordHuntRouteRewardEngine.nextCatalogEntry()` davranışı.
7. Kadim→5. rota unlock prerequisite contract'ı.
8. 5. rota `routeRewardId` naming contract'ı ve reward metadata ihtiyacı.
9. Progress schema değişikliği gerekip gerekmediği.
10. Historical users / unlock / backfill etkisi.
11. Reusable themed renderer / map architecture'ın 5. rotaya uygunluğu.
12. Asset yaklaşımı.
13. Content difficulty curve.
14. L5 challenge / L10 final balance contract'ı.
15. Info-card contract.
16. Rota adı / tema / atmosfer alternatifleri.
17. Dört mevcut rota ile görsel ve içerik ayrışması.
18. Kadim'in artık terminal olmaması halinde copy/test değişiklikleri.
19. All-routes-complete terminal state'in 5. rotaya taşınması.
20. Test / CI kapsamı.

## DEVİR CÜMLESİ

Yeni sohbet şu prompt ile başlayabilir:

`GENEL_PROJE_OZETI.md ve SOHBET_DEVIR_2026-09-17_ROUTE_SELECTOR_GUIDED_POLISH_KAPANIS.md dosyalarını oku; canlı target HEAD'i doğrula ve KELİME AVI — 5. ROTA READINESS / ÜRÜN + TEKNİK AUDIT'ten devam et. İlk tur yalnız audit; kod değiştirme.`
