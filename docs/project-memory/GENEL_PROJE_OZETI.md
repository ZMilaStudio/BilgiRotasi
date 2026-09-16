# Bilgi Rotası — Genel Proje Özeti

**Son güncelleme:** 16 Eylül 2026

## YENİ SOHBET DEVİR NOTU — ÖNCE BUNU OKU

Yeni sohbette işe başlamadan önce şu sırayı uygula:

1. Bu dosyanın tamamını oku: `docs/project-memory/GENEL_PROJE_OZETI.md`.
2. Son authoritative sohbet devrini oku: `docs/project-memory/SOHBET_DEVIR_2026-09-16_KADIM_ORMAN_ORIGINAL_CONTENT_KAPANIS.md`.
3. İlgili mimari karar için `KELIME_AVI_REUSABLE_HARITA_KARARI.md` dosyasını oku.
4. Sonra canlı GitHub durumunu kendin doğrula: repo, target branch, exact HEAD, açık PR'lar ve ilgili GitHub Actions sonuçları.
5. Çelişki varsa öncelik: **canlı GitHub > proje bellek dosyaları > eski sohbetler**.

Repo: `ZMilaStudio/BilgiRotasi`  
Target branch: `release/final-closed-test-aab-1.68.8`  
PR #204 merge sonrası target HEAD: `755e90725d3062b74c0ce228bb1b6d7bbdfda4c0`

## 16 Eylül 2026 — Kadim Orman özgün content TAMAMLANDI / MERGED

Kadim Orman'ın Orman Yolu gameplay içeriğini clone/reuse ettiği pilot borcu PR #204 ile kapatıldı. Kadim Orman artık production'da kendi statik ve deterministic gameplay içeriğine sahiptir.

- PR: **#204 — `feat(kelime-avi): give Kadim Orman original content`**
- Approved PR head: `a17cdcd4dab03dad567852db7421b3ce139f0213`
- Approved head tree: `a98c7cb23621276d36cd84f0d9055e535328d1cb`
- Squash merge commit / yeni target HEAD: `755e90725d3062b74c0ce228bb1b6d7bbdfda4c0`
- Merge commit tree: `a98c7cb23621276d36cd84f0d9055e535328d1cb`
- Squash commit parent: `47855a96e51567782318f32990c76703813b9341`
- Approved PR head tree ile squash merge tree **birebir aynıdır**.
- Source branch `feat/kelime-avi-kadim-orman-original-content` bilerek henüz silinmedi.

### Korunan teknik kimlikler

- route id: `orman-2`
- user-facing title: **Kadim Orman**
- theme: `orman`
- reward id: `reward-orman-2`
- level id'leri: `orman-2-01` … `orman-2-10`
- level indexleri: `1..10`
- type sırası: normal, normal, normal, normal, challenge, normal, normal, normal, normal, routeFinal

### Kadim Orman production content

10 bölümün tamamı artık özgün **statik 8×8 grid + targetWords + bonusWords** kullanır:

1. Köklerin Kapısı
2. Sis Koridoru
3. Eski Köprü
4. Mantar Çemberi
5. Gece Gözleri — challenge / 60 sn
6. Unutulmuş Harabe
7. Gizli Kaynak
8. Kadim İşaretler
9. Ormanın Hafızası
10. Ormanın Kalbi — routeFinal / 120 sn

Artık geçersiz pilot borcu:

- `WordHuntOrmanContent` gameplay import/reuse yok,
- `WordHuntOrmanContent.infoCards` reuse yok,
- `WordHuntOrmanContent.ormanYolu.levels` clone/map yok,
- `_clonePilotLevels()` yok,
- “Kadim Orman gameplay verisini Orman Yolu'ndan reuse eder” bilgisi **SUPERSEDED / GEÇERSİZ**.

Kadim Orman'ın kendi 6 bilgi kartı vardır:

- `kadim-info-egrelti` — L1
- `kadim-info-sis` — L2
- `kadim-info-misel` — L4
- `kadim-info-baykus` — L5
- `kadim-info-kaynak` — L7
- `kadim-info-cinar` — L9

### Kalite / CI kapanışı — PASS

Exact approved HEAD: `a17cdcd4dab03dad567852db7421b3ce139f0213`

- 10/10 Kadim Orman grid'i kendi içinde unique: **PASS**
- Orman Yolu gridleriyle birebir eşleşme yok: **PASS**
- corresponding targetWords listeleri birebir aynı değil: **PASS**
- target/bonus overlap yok: **PASS**
- target ve bonus kelimeler production yön kurallarına göre gridde geçerli: **PASS**
- `WordHuntDefinitionValidator`: **PASS**
- `WordHuntContentValidator`: **PASS**
- info-card ID uniqueness + approved level mapping: **PASS**
- source-level clone/reuse regression: **PASS**
- Orman Yolu/Kadim Orman progression isolation: **PASS**
- fresh selector → Kadim Orman locked: **PASS**
- Orman Yolu level 10 complete → Kadim Orman unlocked: **PASS**
- immutable Orman 2 asset / visual theme / normalized stops regression: **PASS**
- Orman Yolu Android çoklu ekran kanıtı — Run **#22**, ID `35102022425`: **SUCCESS**
- Kelime Avı Android 16 görsel kanıtı — Run **#440**, ID `35102022388`: **SUCCESS**
- AdMob PR doğrulaması — Run **#817**, ID `35102022445`: **SUCCESS**
- Repo-geneli “Analiz ve tüm testler”: **SUCCESS**
- release APK / package-manifest / Android 16 cold-start: **SUCCESS**

## Kadim Orman selector / progression baseline — KORUNUYOR

PR #203 ile merge edilen progression kararı PR #204 tarafından değiştirilmedi:

- selector sırası: **Başlangıç Limanı → Gökyüzü → Orman Yolu → Kadim Orman**,
- Kadim Orman selector'da en baştan görünür,
- fresh progress durumunda kilitlidir,
- exact locked copy: **“Orman Yolu’nu tamamlayarak aç.”**,
- Orman Yolu level 9 tamamken kilitli kalır,
- Orman Yolu level 10 tamamlanınca açılır,
- 30/30 veya toplam yıldız unlock şartı yoktur,
- kendi içinde 1→10 progression kullanır,
- Orman Yolu ve Kadim Orman progression identity'leri ayrıdır,
- generic `WordHuntRouteUnlockRule.routeComplete` ve data-driven `lockedMessage` korunur.

## Orman 2 / Kadim Orman immutable asset freeze

Production asset:

`assets/word_hunt/ORMAN2_FINAL_941x1672.webp`

- dimensions: **941×1672**
- bytes: **1.109.268**
- SHA-256: `aede5c6f08b6fe4cd64d17a1ef309e13256dde1c1e97fbee0c53b019f63c6c8d`
- Git blob SHA: `43233bf2b0e8f16d59a15f0fe0bcda5f5e2bb80c`

Bu asset immutable'dır. **Re-encode / recompress / resize / crop / recolor / yeniden üretme yapılmaz.**

## Kadim Orman runtime baseline — KORUNUYOR

PR #202 ile merge edilen runtime/presentation baseline'ı PR #204 tarafından değiştirilmedi:

- technical route id `orman-2`,
- visual theme id `orman-2-production`,
- `referenceCanvasSize = 411×731`,
- `extendTallAmbientFromArtworkEdges = true`,
- `artworkOverlayMode = embeddedRouteLiveNodes`,
- dekoratif rota raster içindedir; live Flutter route painter kapalıdır,
- node/progression/chrome canlı Flutter katmanındadır,
- Orman 1 node asset ailesi reuse edilir,
- NodeSkin refactor yoktur,
- route/theme-id özel renderer `if` yoktur,
- normalized stops değiştirilmemiştir.

## Source branch durumu

Aşağıdaki branch'ler owner ayrıca istemeden silinmez:

- PR #204: `feat/kelime-avi-kadim-orman-original-content` — tutuluyor.
- PR #203: `feat/kelime-avi-kadim-orman-progression` — tutuluyor.
- PR #202: `feat/kelime-avi-orman2-runtime-pilot-20260916` — tutuluyor.

## Sıradaki inceleme konusu — Orman Yolu content / bilgi kartı polish

Yeni rota üretmeden önce mevcut rota içerik kalitesi/polish turu devam etmeli. Bir sonraki inceleme konusu:

- Orman Yolu `infoCards` şu anda boş; kitap butonuna gerçek içerik kazandırılması değerlendirilecek.
- Orman Yolu target kelime havuzundaki tekrarlar kalite açısından incelenecek.
- Bu devir notu henüz ürün çözümü belirlemez; yalnız sıradaki kalite/polish konusunu sabitler.

## Kelime Avı — korunan kanonik progression ve release kuralları

- Her 10-bölümlük rotada bölüm progression'ı `1→2→3→4→5→6→7→8→9→10` şeklindedir.
- Ortak motor `WordHuntRouteProgressEngine.isLevelUnlocked`; tema/artwork progression mantığını değiştiremez.
- Gökyüzü kapısı: Başlangıç Limanı'ndan 18 yıldız.
- Orman Yolu kapısı: Başlangıç Limanı Bölüm 10 completion.
- Kadim Orman kapısı: Orman Yolu Bölüm 10 completion; yıldız toplamı şartı yoktur.
- Grid: **8×8 / 64 hücre — LOCKED**.
- B5 60 sn, B10 120 sn soft challenge; hard-fail değildir.
- Minimum Kelime Avı yayın stoğu: **200 hazır/doğrulanmış bölüm**.
- 200/200 release-stock gate ve runtime/fiziksel kabul tamamlanmadan yeni Kelime Avı production release'i Play'e yüklenmez.
- `assets/questions.json`, BoardMap/67 node, Firebase, signing, version ve Play kapsamı açık owner kararı olmadan değiştirilmez.

**DEVİR SON DURUMU:** PR #204 MERGED / target `755e90725d3062b74c0ce228bb1b6d7bbdfda4c0` / approved head `a17cdcd4...` / approved ve merge tree `a98c7cb...` birebir aynı / Kadim Orman artık Orman Yolu gameplay clone/reuse kullanmıyor / 10 özgün statik 8×8 bölüm ve 6 özgün bilgi kartı production'da / teknik route-level-progression identity korunuyor / selector-unlock-map-theme-asset değişmedi / ilgili test ve CI SUCCESS / source branch tutuluyor / sıradaki inceleme Orman Yolu content ve bilgi kartı polish.