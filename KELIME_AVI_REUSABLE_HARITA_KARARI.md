# Kelime Avı — Reusable Harita Mimari Kararı

**Karar tarihi:** 12 Eylül 2026  
**Son durum güncellemesi:** 16 Eylül 2026

Bu belge, Kelime Avı'nın reusable 10-bölümlük rota mimarisi ile buna bağlı production kararlarını authoritative olarak kaydeder.

## Kilitli reusable harita sözleşmesi

- Her rota 10 bölümden oluşur.
- Canonical sıra **1 → 2 → 3 → 4 → 5 → 6 → 7 → 8 → 9 → 10** şeklindedir.
- **8. bölüm bonus değildir; normal bölümdür.**
- Progression sıralıdır: 7 tamamlanınca 8, 8 tamamlanınca 9, 9 tamamlanınca 10 açılır.
- 10 node'un geometri/hitbox kaynağı tek reusable motordur; rota bazında ayrı node koordinat listesi yazılmaz.
- Yol geometrisi rota bazında elle Bézier koordinatı taşımaz; ortak motor deterministik üretir.
- Yeni rota için ayrı ekran/widget yazılmaz. Generic ekran sözleşmesi route + visualTheme verisiyle çalışır.
- Görsel skin verisi `WordHuntRouteVisualTheme` içinde tutulur; progression/hitbox mantığını taşımaz.
- Dekorlar node-safe bölgelere giremez ve `IgnorePointer` altında kalır.
- Embedded-route artwork modunda dekoratif rota raster içindedir; live Flutter route painter ikinci kez çizilmez.
- Rota-id özel Widget/Painter/koordinat listesi gerektiren yaklaşım reusable mimariyle uyumsuz kabul edilir.

## Reusable mimari merge zinciri

- PR #184 — `feat(kelime-avi): introduce reusable 10-level route map engine`
  - exact HEAD: `b34bfddff5183692e62ac7c9bd49ad15140dae31`
  - merge commit: `1cf71e959177cbe05c01590091a4b69b7e3583cf`
  - exact-head Kelime Avı Android 16 ve AdMob/full validation: **SUCCESS**
- PR #186 — `feat(kelime-avi): add deterministic route decoration layout`
  - exact HEAD: `6a3097b6d00738eb1d0f6ba7dd14aefe735eea76`
  - merge commit: `accc3cb861ab50c287ecf3b6461e00882ff1f2be`
  - approved/tested tree: `73663864e1fd02deb511beac7014351ff010b000`
  - focused suite, analyze/tüm testler, release APK, manifest ve Android 16 cold-start: **PASS**

## Bilerek yapılmayanlar

Reusable mimari tek başına:

- yeni 180 bölümü runtime kataloğuna bağlamaz,
- 200 bölümün playable olduğunu iddia etmez,
- yeni rotaları navigasyonda otomatik açmaz,
- `assets/questions.json` dosyasını değiştirmez,
- BoardMap / 67 node'u değiştirmez,
- Firebase'i değiştirmez,
- production AdMob/signing/package-version/Play kapsamını değiştirmez.

## Orman 2 genericization — TAMAMLANDI

PR #201 ile Orman 2 asset-reuse pilotundan önce gereken config-driven presentation zemini tamamlandı.

- approved/tested HEAD: `834ba8458a5493c336d5ac06e1735062100e9a4c`
- squash merge commit: `19dd5ffa3a5d4b9d2588ef5030b99459fd04d37e`
- tree equality: `73946e2d2b00f21f2e3dc09040ee3330f0696d1f`
- reference canvas + tall ambient config-driven,
- embedded decorative route + live nodes `artworkOverlayMode` ile config-driven,
- NodeSkin refactor yapılmadı.

## Orman 2 runtime pilotu — TAMAMLANDI / MERGED

PR #202 ile genericization zemini gerçek Orman 2 runtime pilotunda kullanıldı.

- approved head: `62d33d9a332a281b2d703432472e3d802668c17c`
- approved head tree: `a4742ad244ec90a9ae41bf2b55ad48d7ceed14e5`
- squash merge commit: `9aa3a2e8392a8fb42646d23c1e89ea9b67789c5a`
- merge tree: `a4742ad244ec90a9ae41bf2b55ad48d7ceed14e5`
- tree equality: **EVET**

Runtime sözleşmesi:

- technical route id `orman-2`,
- `referenceCanvasSize = 411×731`,
- `extendTallAmbientFromArtworkEdges = true`,
- `artworkOverlayMode = embeddedRouteLiveNodes`,
- dekoratif rota raster içindedir; live Flutter route painter kapalıdır,
- node/progression/chrome live Flutter katmanındadır,
- Orman 1 node asset ailesi reuse edilir,
- route/theme-id özel renderer `if` yoktur,
- canonical normalized stops değiştirilmemiştir.

Immutable asset:

`assets/word_hunt/ORMAN2_FINAL_941x1672.webp`

- 941×1672
- 1.109.268 byte
- SHA-256: `aede5c6f08b6fe4cd64d17a1ef309e13256dde1c1e97fbee0c53b019f63c6c8d`
- Git blob SHA: `43233bf2b0e8f16d59a15f0fe0bcda5f5e2bb80c`
- re-encode / recompress / resize / crop / recolor yapılmaz.

PR #202 zamanındaki gameplay reuse durumu **PR #204 ile superseded edilmiştir**; runtime/presentation baseline'ı korunur.

## Kadim Orman progression — TAMAMLANDI / MERGED

PR #203 ile teknik route identity `orman-2` korunurken user-facing ad **Kadim Orman** oldu.

- approved head: `c89926b270d89f52ca895b82a875c9b732fdb609`
- approved head tree: `3e00a2d246f93eb3792a1d63748b2923fe30a13d`
- squash merge commit: `f312a2333cb16e9a74f500fcc80c200325634439`
- tree equality: **EVET**

Selector/progression sözleşmesi:

- sıra: **Başlangıç Limanı → Gökyüzü → Orman Yolu → Kadim Orman**,
- Kadim Orman selector'da en baştan görünür,
- fresh progress'te locked,
- exact copy: **“Orman Yolu’nu tamamlayarak aç.”**,
- prerequisite Orman Yolu'dur,
- Kadim Orman kendi içinde 1→10,
- Orman Yolu ve Kadim Orman progression identity ayrıdır,
- generic `WordHuntRouteUnlockRule.routeComplete` kullanılır,
- route-id özel selector/renderer `if` yoktur,
- locked copy catalog entry üzerinden data-driven taşınır.

PR #206 sonrasında `routeComplete`, prerequisite rotanın gerçek `WordHuntRouteProgressEngine.isRouteComplete(...)` contract'ını kullanır. Orman Yolu `unlockStarsRequired = 0` olduğu için Kadim Orman kapısında final completion yeterlidir; ek yıldız şartı yoktur.

## Kadim Orman özgün gameplay/content — TAMAMLANDI / MERGED

PR #204 ile pilot dönemi Orman Yolu gameplay clone/reuse borcu kapatıldı.

- approved head: `a17cdcd4dab03dad567852db7421b3ce139f0213`
- approved head tree: `a98c7cb23621276d36cd84f0d9055e535328d1cb`
- squash merge commit: `755e90725d3062b74c0ce228bb1b6d7bbdfda4c0`
- merge tree: `a98c7cb23621276d36cd84f0d9055e535328d1cb`
- tree equality: **EVET**

Production content sözleşmesi:

- route id `orman-2`, title **Kadim Orman**, theme `orman`, reward `reward-orman-2` korunur,
- level id'leri `orman-2-01` … `orman-2-10` ve index 1..10 korunur,
- 10 bölümün tamamı özgün statik/deterministic 8×8 grid kullanır,
- targetWords / bonusWords Kadim Orman'a özgüdür,
- runtime random grid generation yoktur,
- `WordHuntOrmanContent.infoCards` reuse yok,
- `WordHuntOrmanContent.ormanYolu.levels` clone/map yok,
- `_clonePilotLevels()` yok.

Kadim Orman'ın 6 özgün info card'ı:

- `kadim-info-egrelti` — L1
- `kadim-info-sis` — L2
- `kadim-info-misel` — L4
- `kadim-info-baykus` — L5
- `kadim-info-kaynak` — L7
- `kadim-info-cinar` — L9

PR #204 test/CI kapanışı: validators, grid uniqueness/independence, progression isolation, selector/unlock, immutable asset/theme/stops ve Android/full-suite kapıları **PASS / SUCCESS**.

## Orman Yolu content polish + generic book — TAMAMLANDI / MERGED

PR #205 ile Orman Yolu içerik kalitesi ve production kitap akışı kapatıldı.

- PR: **#205 — `feat(kelime-avi): polish Orman Yolu content`**
- approved head: `c7ac3cc2644cb45b7f1da004ed1de0533ed5d025`
- approved head tree: `43d41a9f3048c0849ab659489f8cfa1661e1745f`
- squash merge commit: `b114bff436fb61912d380dbcb84340d1490f6f4a`
- merge tree: `43d41a9f3048c0849ab659489f8cfa1661e1745f`
- squash parent: `933361681345a0d62da10f158d90f658ce63a898`
- tree equality: **EVET**

### Orman Yolu content kararı

Orman Yolu artık 6 özgün `Doğa` info card kullanır:

- `orman-info-agac` — L1
- `orman-info-mese` — L2
- `orman-info-mantar` — L4
- `orman-info-kozalak` — L5
- `orman-info-sincap` — L6
- `orman-info-geyik` — L7

L1–L7 gameplay payload korunur; yalnız onaylı infoCardIds bağlantıları eklenmiştir.

L8–L10 polish:

- **L8 YAĞMURDAN SONRA** — target `YAĞMUR, ÇAMUR, DAMLA, DERE, PATİKA`; bonus `ISLAK`; yeni deterministic 8×8 grid.
- **L9 ORMANIN İZLERİ** — target `İZLER, TÜY, TOYNAK, YEMİŞ, OYUK`; bonus `KABUK`; yeni deterministic 8×8 grid.
- **L10 YOLUN SONU** — `routeFinal`; target `ORMAN, KEŞİF, YOLCULUK, CANLI, DOĞA, UYUM`; bonus `MACERA`; 120 sn; mevcut star/mistake contract korunur; yeni deterministic 8×8 grid.

### Generic/data-driven production book kararı

Artık **tüm production rotaları** aynı kitap contract'ını kullanır:

`_activeInfoCards` + `_progress.unlockedInfoCardIds`

Geçerli rotalar:

- Başlangıç Limanı
- Gökyüzü
- Orman Yolu
- Kadim Orman

Legacy forest özel book borcu kaldırılmıştır:

- `_showOrmanTopicBook()` yok,
- `_TopicGuide` yok,
- `_ormanTopicGuides` yok,
- `route.theme == 'orman'` book special-case yok,
- Orman/Kadim route-id özel book branch yok.

Kitap yalnız aktif rotanın `_activeInfoCards` listesindeki unlock edilmiş kartları gösterir. Başka rotanın unlocked ID'si aynı progress snapshot'ta bulunsa bile gösterilmez. Cross-route isolation testle kilitlidir.

Info-card unlock semantiği değiştirilmemiştir: gameplay'de eşleşen kelime bulunur → `level.infoCardIds` üzerinden kart unlock olur → `unlockedInfoCardIds` persisted progress'e yazılır.

## Lineer production route progression — TAMAMLANDI / MERGED

PR #206 ile daha önce audit konusu olan rota açılma sırası çözüldü ve selector sırasıyla tam lineer hale getirildi.

- PR: **#206 — `feat(kelime-avi): enforce linear route progression`**
- approved head: `8998e124eaf2afdffd618b0f60212ba2196172b3`
- approved head tree: `02e263e0ade579080f7aa8791de3a33373cf1345`
- squash merge commit: `7d1d699623200601ad867eb6dda852feede587eb`
- merge tree: `02e263e0ade579080f7aa8791de3a33373cf1345`
- squash parent: `1ca969a952f44ee72381c4ed704a534c7924cbbd`
- tree equality: **EVET**
- source branch `feat/kelime-avi-linear-route-progression` bilerek tutulmaktadır.

### Authoritative unlock zinciri

Production order ve unlock zinciri:

**Başlangıç Limanı → Gökyüzü Adaları → Orman Yolu → Kadim Orman**

- **Başlangıç Limanı:** `always`.
- **Gökyüzü Adaları:** `routeComplete(prerequisiteRoute: Başlangıç Limanı)`; Başlangıç final complete + `totalStars >= 18`.
  - exact locked copy: **“Başlangıç Limanı’nı tamamla ve en az 18 yıldız kazan.”**
- **Orman Yolu:** `routeComplete(prerequisiteRoute: Gökyüzü Adaları)`; Gökyüzü final complete + `totalStars >= 18`.
  - exact locked copy: **“Gökyüzü Adaları’nı tamamla ve en az 18 yıldız kazan.”**
- **Kadim Orman:** `routeComplete(prerequisiteRoute: Orman Yolu)`; Orman Yolu `unlockStarsRequired = 0`, bu nedenle final completion yeterli.
  - exact locked copy: **“Orman Yolu’nu tamamlayarak aç.”**

`WordHuntRouteUnlockRule.routeComplete` authoritative olarak `WordHuntRouteProgressEngine.isRouteComplete(prerequisiteRoute, progress)` kullanır. `isRouteComplete` final type `routeFinal` + final completed + `totalStars >= route.unlockStarsRequired` sözleşmesini taşır.

### Legacy progress kararı

Grandfather istisnası yoktur. Eski downstream progress silinmez veya migrate edilmez; ancak yeni prerequisite'i bypass ettiremez. Prerequisite sonradan sağlanırsa rota yeniden açılır ve kayıtlı downstream progress aynen korunur.

### PR #206 test / CI kapanışı

Exact approved HEAD `8998e124eaf2afdffd618b0f60212ba2196172b3`:

- Route catalog gate Run #84 / ID `35120880714`: **SUCCESS**
- Orman multi-size Run #28 / ID `35120880709`: **SUCCESS**
- Kelime Avı Android 16 Run #446 / ID `35120880717`: **SUCCESS**
- AdMob PR validation Run #823 / ID `35120880650`: **SUCCESS**
- threshold/final/zero-threshold routeComplete semantics: **PASS**
- legacy downstream-progress prerequisite isolation + preservation: **PASS**
- selector order / ids / ordinal labels / locked copy: **PASS**
- repo-geneli analyze/tests + release APK + package/manifest + Android 16 cold-start: **SUCCESS**

## SIRADAKİ AUDIT — Challenge / final yıldız – zaman – ödül dengesi

Henüz yeni star/time/reward kararı verilmemiştir. Bir sonraki inceleme aşağıdaki mevcut sözleşmeleri audit edecektir:

- Başlangıç Limanı challenge/final star rule'ları,
- Gökyüzü challenge/final star rule'ları,
- Orman Yolu challenge/final star rule'ları,
- Kadim Orman challenge/final star rule'ları,
- `timeLimitSeconds`,
- `twoStarMaxMistakes` / `threeStarMaxMistakes`,
- `twoStarMaxSeconds` / `threeStarMaxSeconds`,
- `routeFinal` bölümlerin final hissi,
- `routeRewardId` değerlerinin runtime'da gerçek kullanıcı ödülü üretip üretmediği,
- rotalar arasında zorluk artışının tutarlılığı.

Bu belge henüz yeni denge kararı vermez ve 5. rota tasarlamaz; yalnız sıradaki **CHALLENGE / FINAL YILDIZ – ZAMAN – ÖDÜL DENGESİ AUDITİ** başlangıç noktasını kaydeder.

**Durum:** REUSABLE 10-LEVEL MAP ARCHITECTURE — OWNER APPROVED / MERGED / CI GREEN. ORMAN 2 RUNTIME — MERGED. KADİM ORMAN PROGRESSION — MERGED. KADİM ORMAN ORIGINAL CONTENT — MERGED. ORMAN YOLU CONTENT POLISH + GENERIC DATA-DRIVEN BOOK — MERGED / CI GREEN. LINEER ROUTE PROGRESSION — MERGED / CI GREEN. SIRADAKİ KONU — CHALLENGE / FINAL YILDIZ – ZAMAN – ÖDÜL DENGESİ AUDITİ.