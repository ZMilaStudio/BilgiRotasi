# Bilgi Rotası — Genel Proje Özeti

**Son güncelleme:** 13 Eylül 2026 — Kelime Avı reusable rota haritası / Orman Yolu Android runtime kanıt hattı güçlendirildi. Canlı çalışma PR'ı #198 `feat/kelime-avi-scenic-theme-depth-20260912` branch'inde OPEN/DRAFT durumda. Kanonik release branch `release/final-closed-test-aab-1.68.8` olarak korunuyor. Bölüm progression kararı kesin olarak **yalnız Bölüm 1 açık başlar; 2–10 kilitli; her bölüm yalnız kendinden önceki tamamlanınca açılır (`1→2→3→4→5→6→7→8→9→10`)** şeklindedir. Eski “7 bitince 8 ve 9 birlikte açılır” kararı geçersizdir. Orman Yolu production skin `WordHuntRouteVisualThemes.ormanYolu` ile gerçek artwork tabanı + canlı path/node/lock/progression katmanı ayrıdır. Android visual proof artık kırılgan `reportedDrawn` sinyaline tek başına güvenmez; proof binary'leri gerçek Flutter frame/artwork-ready marker üretir ve workflow emulator altyapı hatasında en fazla bir temiz retry yapar. Orman Yolu production catalog'a henüz eklenmedi; rota-katalog unlock kararı ayrı tutuluyor. PR Ready/merge için Levent/owner açık onayı zorunludur.

> Teknik doğrulukta tek kanonik kaynak canlı `ZMilaStudio/BilgiRotasi` deposu ve ilgili canlı servislerdir. Bu dosya canlı branch/PR/CI/pubspec doğrulamasının yerine geçmez. Ayrıntılı eski üretim günlükleri Git geçmişinde ve `docs/project-memory/archive/` altında korunur.

## Kalıcı Çalışma Kuralı

- Her görev başında canlı hedef branch, `pubspec.yaml`, son commit, PR ve CI yeniden doğrulanır.
- `main` güncel/yayın kaynağı varsayılmaz.
- Sıra: branch → test → commit → push → PR → inceleme → merge.
- Kritik merge/release yalnız Levent'in açık onayıyla yapılır.
- Build PASS tek başına kanıt değildir; diff, test, workflow, log, Git geçmişi ve gerçek runtime kanıtı birlikte değerlendirilir.
- Görsel kabul yalnız gerçek/raw Android runtime üzerinden verilir; ImageGen/mockup/QA selector kabul kanıtı değildir.
- `assets/questions.json` kontrolsüz değiştirilmez; ilgisiz değişiklikler silinmez.
- Codex yalnız mevcut araçlarla yapılamayan zorunlu yerel kod/test işi olduğunda kullanılır; gereksiz Codex kredisi harcanmaz.
- Kullanıcı açıkça dur dediğinde üretim/merge/release adımı başlatılmaz; durum özeti ve sohbet devri hazırlanır.

## Canlı Release Hattı

- Repo: `ZMilaStudio/BilgiRotasi`.
- Canonical release branch: `release/final-closed-test-aab-1.68.8`.
- Bu dosyadaki eski release HEAD kayıtları yalnız tarihsel checkpointtir; güncel HEAD her görevde canlı GitHub'dan yeniden doğrulanır.
- Son production sürümü: **1.68.20+110**.
- Paket: `com.leventua.bilgirotasi`.
- **Play Console'a yükleme/yayınlama yapılmadı.** Kelime Avı içeren production AAB, minimum yayın stoğu ve ayrı owner kararı olmadan Play'e yüklenmeyecek.

## Kelime Avı — Kanonik progression

- Bütün 10-bölümlük rotalarda yeni/boş progress durumunda yalnız Bölüm 1 açık/current başlar.
- Bölüm 2–10 locked başlar ve callback üretmez.
- Açılma sırası kesin olarak `1→2→3→4→5→6→7→8→9→10`.
- Bölüm 8 normal bölümdür ve Bölüm 9 için zorunlu kapıdır.
- Eski Başlangıç Limanı “7 tamamlanınca 8 ve 9 birlikte açılır” davranışı **SUPERSEDED / GEÇERSİZ**.
- `WordHuntRouteProgressEngine.isLevelUnlocked` bu sözleşmenin tek ortak motorudur; rota teması veya artwork kuralı değiştiremez.

## PR #198 — Reusable rota görsel sistemi

- PR: **#198 — `feat(kelime-avi): add generic scenic depth to reusable map`**.
- Branch: `feat/kelime-avi-scenic-theme-depth-20260912`.
- Base: `release/final-closed-test-aab-1.68.8`.
- Durum: **OPEN / DRAFT / mergeable**.
- Ortak `WordHuntRouteMapGeometry.normalizedStops`, 10 node ve 86×82 hitbox korunur.
- Orman / gökyüzü / liman tema verileri aynı generic renderer üzerinden çalışır; route-id özel painter/widget/koordinat dalı eklenmez.
- Orman production skin'i proof presetinden ayrıldı: `WordHuntRouteVisualThemes.ormanYolu`.
- Android proof boş progress ile 1 açık / 2–10 locked state'ini production Orman skin'iyle render eder.
- Raster artwork desteği generic tema verisindedir: asset + fit + alignment + blur + overlay + scale.
- Raster artwork aktifken procedural decoration ve procedural atmosfer varsayılan olarak kapatılır; canlı path/node/lock/progression katmanı korunur.
- Production Orman widget artifact'i ayrıca üretilir; raster artwork ile canlı sıralı kilit state'inin birlikte render edildiği test kapısı vardır.
- Android runtime proof binary'si Orman artwork bundle'ını decode eder, boyutunu loglar ve sonraki Flutter frame tamamlanınca `[WORD_HUNT_REUSABLE_MAP_PROOF_FRAME_READY]` marker üretir.
- Legacy MASTER ART proof de asset'ler precache edildikten ve bir frame daha tamamlandıktan sonra `[WORD_HUNT_VISUAL_PROOF_FRAME_READY]` marker üretir.
- Android proof workflow gerçek app crash/ANR/process-death bulursa fail verir; yalnız emulator/render altyapı hatasında tek temiz retry yapabilir.
- Final raster Orman artwork'ü production catalog/unlock kararıyla karıştırılmaz; görsel kalite kabulü raw Android üzerinden yapılır.

## Production Ana Navigasyon — CANONICAL

- Bilgi Rotası production **Oyna** menüsünde `Kelime Avı` kartı vardır.
- Mevcut production catalog Başlangıç Limanı + Gökyüzü Adaları durumunu korur.
- Orman Yolu doğrulanmış içerik ve production skin taşısa da ayrı rota-katalog unlock kararı verilmeden görünür production catalog'a eklenmez.
- İlerleme Firebase UID / guest scope'una göre cihazda saklanır; bozuk/eski veri oyunun açılmasını engellemez.

## Canonical Gameplay Sözleşmesi

- Grid: **8×8 / 64 hücre — LOCKED**.
- Önceki 6×10 yalnız tarihsel checkpointtir; ürüne geri dönmez.
- Target+bonus içerikleri exactly-one fiziksel occurrence, düz 8 yön ve ters gesture eşitliği kapılarından geçer.
- B5 60 sn ve B10 120 sn soft challenge; hard-fail değildir.
- Engine/path/scoring/timer/progression sözleşmesi görsel tema uğruna değiştirilmez.

## 200 bölüm yayın eşiği

- Kelime Avı için minimum yayın stoğu **200 hazır/doğrulanmış bölüm** olarak korunur.
- Mevcut 20 + 180 yeni bölüm hedefi tarihsel V9 üretim hattından devam eder.
- 200/200 release-stock gate ve gerekli runtime/fiziksel kabul kapıları tamamlanmadan yeni Kelime Avı production release'i Play'e yüklenmez.

## Korunan Alanlar

- `assets/questions.json` kontrolsüz değiştirilmez.
- BoardMap / 67 node değiştirilmez.
- Canonical 8×8 / 64 hücre sözleşmesi korunur.
- Firebase / AdMob / release signing / package-version / Play değişiklikleri ayrı scope gerektirir.
- PR #198 görsel/harita kapsamı dışında production release kararı üretmez.

## Aktif devam sırası

1. PR #198 exact HEAD CI ve Android 16 raw runtime kanıtını tamamla; proof marker + screenshot + nonblack pixel gate'i birlikte doğrula.
2. Başarılı Android artifact'ındaki production Orman ekranını içeride incele; mevcut düşük kalite artwork final kabul edilmez.
3. Orman Yolu için final kalite raster artwork'i yalnız generic artwork katmanından bağla; procedural proof dekorunu final art üzerine bindirme.
4. Fresh state'in 1 açık / 2–10 locked olduğunu raw Android proof ile tekrar doğrula.
5. Kullanıcı görsel kalite PASS vermeden PR Ready/merge yapma.
6. Orman Yolu production catalog/unlock kararını görsel kabulden ayrı ele al; kendiliğinden unlock kuralı icat etme.
7. `assets/questions.json`, 67-node BoardMap, Firebase, production AdMob, signing, version veya Play'e dokunma.

**SON DURUM:** PR #198 OPEN/DRAFT / Orman production skin ayrıldı / sıralı 1→10 kilit kuralı kanonik / raster artwork temiz katman sözleşmesi aktif / Android proof gerçek Flutter frame marker + tek infra retry ile güçlendirildi / raw Android exact-head kanıtı zorunlu / mevcut Orman artwork final kalite kabul edilmedi / Orman production catalog henüz kapalı / merge ve Play yok.
