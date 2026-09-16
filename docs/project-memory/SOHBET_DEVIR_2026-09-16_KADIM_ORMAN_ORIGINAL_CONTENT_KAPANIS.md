# Sohbet Devri — Kadim Orman Özgün Content Kapanışı

**Tarih:** 16 Eylül 2026  
**Repo:** `ZMilaStudio/BilgiRotasi`  
**Target branch:** `release/final-closed-test-aab-1.68.8`

## Nihai durum

**Kadim Orman özgün gameplay/content işi tamamlandı, tüm ilgili test/CI kapıları geçti ve PR #204 ile squash merge edildi.**

Kadim Orman artık Orman Yolu'nun gameplay içeriğini clone/reuse etmez. Production'da kendi statik ve deterministic 8×8 grid, targetWords, bonusWords ve bilgi kartı içeriğine sahiptir.

## PR #204 kapanış kaydı

- PR: **#204 — `feat(kelime-avi): give Kadim Orman original content`**
- Approved PR head: `a17cdcd4dab03dad567852db7421b3ce139f0213`
- Approved head tree: `a98c7cb23621276d36cd84f0d9055e535328d1cb`
- Squash merge commit: `755e90725d3062b74c0ce228bb1b6d7bbdfda4c0`
- Merge commit tree: `a98c7cb23621276d36cd84f0d9055e535328d1cb`
- Squash commit parent: `47855a96e51567782318f32990c76703813b9341`
- Tree equality: **EVET — approved PR head tree ile squash merge tree birebir aynı.**
- PR #204 merge sonrası target HEAD: `755e90725d3062b74c0ce228bb1b6d7bbdfda4c0`.
- Source branch: `feat/kelime-avi-kadim-orman-original-content` — bilerek henüz silinmedi.

## Korunan teknik kimlikler

- route id: `orman-2`
- user-facing title: **Kadim Orman**
- theme: `orman`
- reward id: `reward-orman-2`
- level id'leri: `orman-2-01` … `orman-2-10`
- level indexleri: `1..10`
- type sırası:
  1. normal
  2. normal
  3. normal
  4. normal
  5. challenge
  6. normal
  7. normal
  8. normal
  9. normal
  10. routeFinal

Progression/storage identity değiştirilmedi; migration gerektiren yeni route veya level id oluşturulmadı.

## Kadim Orman production content — özgün ve statik

10 bölümün tamamı kendi statik/deterministic 8×8 gridini, targetWords ve bonusWords listesini kullanır:

1. **Köklerin Kapısı**
2. **Sis Koridoru**
3. **Eski Köprü**
4. **Mantar Çemberi**
5. **Gece Gözleri** — challenge / 60 sn
6. **Unutulmuş Harabe**
7. **Gizli Kaynak**
8. **Kadim İşaretler**
9. **Ormanın Hafızası**
10. **Ormanın Kalbi** — routeFinal / 120 sn

Runtime'da random grid generation eklenmedi. Production sonucu canonical ve tekrarlanabilirdir.

## Kapatılan pilot borcu

Aşağıdaki pilot/reuse yapıları artık production'da yoktur:

- `word_hunt_orman2_content.dart` içindeki clone/reuse amaçlı `word_hunt_orman_content.dart` import'u,
- `WordHuntOrmanContent.infoCards` reuse,
- `WordHuntOrmanContent.ormanYolu.levels` clone/map,
- `_clonePilotLevels()`,
- “Kadim Orman gameplay verisini Orman Yolu'ndan reuse eder” durumu.

Bu bilgi **SUPERSEDED / GEÇERSİZ** kabul edilir.

## 6 özgün bilgi kartı

Kadim Orman kendi 6 bilgi kartına sahiptir:

- `kadim-info-egrelti` — **Eğrelti** — L1
- `kadim-info-sis` — **Sis** — L2
- `kadim-info-misel` — **Misel** — L4
- `kadim-info-baykus` — **Baykuş** — L5
- `kadim-info-kaynak` — **Kaynak** — L7
- `kadim-info-cinar` — **Çınar** — L9

L3, L6, L8 ve L10 için infoCardIds boş kalır.

## Kalite / test kapanışı

Doğrulanan content contract'ları:

- 10/10 Kadim Orman grid'i kendi içinde unique: **PASS**
- Orman Yolu gridleriyle birebir eşleşen Kadim Orman grid'i yok: **PASS**
- corresponding targetWords listeleri Orman Yolu ile birebir aynı değil: **PASS**
- target/bonus overlap yok: **PASS**
- target ve bonus kelimeler production straight-eight-direction kurallarına göre gridde geçerli: **PASS**
- `WordHuntDefinitionValidator`: **PASS**
- `WordHuntContentValidator`: **PASS**
- info-card ID uniqueness: **PASS**
- approved level→info-card mapping: **PASS**
- source-level clone/reuse regression: **PASS**
- Orman Yolu/Kadim Orman progression identity isolation: **PASS**
- fresh selector → Kadim Orman locked: **PASS**
- Orman Yolu level 10 complete → Kadim Orman unlocked: **PASS**
- immutable Orman2 asset regression: **PASS**
- visual theme regression: **PASS**
- normalized stops regression: **PASS**

## CI kapanışı

Exact approved HEAD:

`a17cdcd4dab03dad567852db7421b3ce139f0213`

- Orman Yolu Android çoklu ekran kanıtı — Run **#22**, ID `35102022425`: **SUCCESS**
- Kelime Avı Android 16 görsel kanıtı — Run **#440**, ID `35102022388`: **SUCCESS**
- AdMob PR doğrulaması — Run **#817**, ID `35102022445`: **SUCCESS**
- Repo-geneli **“Analiz ve tüm testler”**: **SUCCESS**
- release APK: **SUCCESS**
- package / manifest: **SUCCESS**
- Android 16 cold-start: **SUCCESS**

Yeni screenshot/debug harness eklenmedi; bu content-only değişiklik için mevcut gerçek Android regression altyapısı yeterli kabul edildi.

## Korunan selector / unlock / runtime baseline

PR #204 aşağıdakileri değiştirmedi:

- selector sırası: Başlangıç Limanı → Gökyüzü → Orman Yolu → Kadim Orman,
- Kadim Orman fresh progress'te locked,
- exact locked copy: **“Orman Yolu’nu tamamlayarak aç.”**,
- Orman Yolu level 10 completion ile unlock,
- toplam yıldız şartı yok,
- generic `WordHuntRouteUnlockRule.routeComplete`,
- map geometry / normalized stops,
- `WordHuntOrman2VisualTheme`,
- immutable `ORMAN2_FINAL_941x1672.webp`,
- renderer / NodeSkin / presentation architecture.

## Source branch

`feat/kelime-avi-kadim-orman-original-content`

Branch merge sonrasında bilerek **henüz silinmedi**. Owner ayrıca istemeden silinmez.

Önceki PR #203 progression ve PR #202 runtime source branch'leri de owner ayrıca istemeden silinmez.

## SIRADAKİ KONU — Orman Yolu content / bilgi kartı kalitesi

Yeni rota üretmeden önce mevcut rota içerik kalitesi/polish turu devam etmeli. Bir sonraki inceleme konusu yalnızca şudur:

- Orman Yolu `infoCards` şu anda boş.
- Kitap butonuna gerçek içerik kazandırılması incelenecek.
- Orman Yolu target kelime havuzundaki tekrarlar kalite açısından değerlendirilecek.
- Yeni rota üretmeden önce mevcut rota content kalitesi/polish turu sürdürülecek.

**Bu devir notu henüz ürün çözümü belirlemez.** Yalnız sıradaki inceleme başlığını sabitler.

## Yeni sohbet başlangıç kuralı

1. `docs/project-memory/GENEL_PROJE_OZETI.md` dosyasını oku.
2. Bu dosyayı oku: `docs/project-memory/SOHBET_DEVIR_2026-09-16_KADIM_ORMAN_ORIGINAL_CONTENT_KAPANIS.md`.
3. `KELIME_AVI_REUSABLE_HARITA_KARARI.md` dosyasını oku.
4. Canlı target HEAD ve source branch durumunu GitHub'dan doğrula.
5. Kadim Orman original-content kararını yeniden açma; PR #204 ile kapanmıştır.
6. Sonraki işe Orman Yolu content / bilgi kartı kalite incelemesinden başlanmalıdır.

**DEVİR SON DURUMU:** PR #204 MERGED / target `755e90725d3062b74c0ce228bb1b6d7bbdfda4c0` / approved head `a17cdcd4...` / approved ve merge tree `a98c7cb...` birebir aynı / Kadim Orman artık Orman Yolu gameplay clone/reuse kullanmıyor / 10 özgün statik 8×8 bölüm + target/bonus content production'da / 6 özgün bilgi kartı production'da / teknik route-level-progression identity korunuyor / selector-unlock-map-theme-asset değişmedi / test ve CI kapanışı PASS / source branch tutuluyor / sıradaki inceleme Orman Yolu content ve bilgi kartı polish.