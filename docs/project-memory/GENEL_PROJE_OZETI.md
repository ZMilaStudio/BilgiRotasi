# Bilgi Rotası — Genel Proje Özeti

**Son güncelleme:** 13 Eylül 2026 — Kelime Avı reusable rota haritası / Orman Yolu production entegrasyonu PR #198 `feat/kelime-avi-scenic-theme-depth-20260912` branch'inde OPEN/DRAFT durumda. Kanonik release branch `release/final-closed-test-aab-1.68.8` olarak korunuyor. Bölüm progression kararı kesin olarak **yalnız Bölüm 1 açık başlar; 2–10 kilitli; her bölüm yalnız kendinden önceki tamamlanınca açılır (`1→2→3→4→5→6→7→8→9→10`)** şeklindedir. Eski “7 bitince 8 ve 9 birlikte açılır” kararı geçersizdir. Orman Yolu production skin `WordHuntRouteVisualThemes.ormanYolu` ile gerçek artwork tabanı + canlı path/node/lock/progression katmanı ayrıdır. Android proof altyapısındaki blocking launch sorunu `9b23363d7a0c4a28652fa717802e97c4bced1cfa` ile çözüldü; aynı exact-head'de Android 16 görsel proof ve AdMob PR doğrulaması SUCCESS oldu. 13 Eylül owner kararıyla **Orman Yolu production catalog'a üçüncü rota olarak eklendi ve yalnız Başlangıç Limanı 10. bölüm tamamlandığında açılır**; Gökyüzü Adaları'nın 18 Başlangıç Limanı yıldızı kapısı değişmez. Orman açıldığında kendi içinde yine yalnız Bölüm 1 açık/current, Bölüm 2–10 locked başlar. Dedicated route catalog gate entegrasyon commitinde SUCCESS geçti; güncel exact-head CI çalışıyor. Mevcut 200×400 Orman artwork final yüksek çözünürlük kalite hedefi olarak kabul edilmez. PR Ready/merge için Levent/owner ayrıca açık onay vermelidir.

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
- `9b23363...` exact-head'de blocking `am start -W` kaldırılıp asynchronous activity launch + ayrı Flutter frame polling kullanıldı; Android 16 görsel proof ilk denemede SUCCESS oldu ve raw screenshot/artifact üretildi.
- Aynı exact-head'de AdMob PR doğrulaması da SUCCESS oldu; release APK + Android 16 cold-start kapısı geçti.
- Android proof workflow gerçek app crash/ANR/process-death bulursa fail vermeye devam eder; emulator/ADB altyapı hatası yalnız sınırlı recovery/retry ile ele alınır. Frame marker, screenshot ve nonblack-pixel kapıları kaldırılmaz.
- Final raster Orman artwork'ü production catalog/unlock kararından ayrı kalite borcudur; görsel kalite kabulü raw Android üzerinden yapılır.
- Mevcut Orman rasterının gerçek decode boyutu 200×400 olduğundan final yüksek çözünürlük artwork olarak kabul edilmez.

## Production Ana Navigasyon — CANONICAL

- Bilgi Rotası production **Oyna** menüsünde `Kelime Avı` kartı vardır.
- Production catalog sırası: **Başlangıç Limanı → Gökyüzü Adaları → Orman Yolu**.
- Başlangıç Limanı her zaman açıktır.
- Gökyüzü Adaları mevcut kuralıyla 18 Başlangıç Limanı yıldızında açılır.
- **Orman Yolu yalnız Başlangıç Limanı 10. bölüm tamamlandığında açılır**; toplam yıldız sayısı tek başına Orman'ı açmaz ve Gökyüzü tamamlanma şartı yoktur.
- Orman Yolu generic `themedReusable` renderer + `WordHuntRouteVisualThemes.ormanYolu` production skinini kullanır.
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

1. Orman production catalog entegrasyonunun exact-head route catalog, AdMob ve Android 16 CI kapılarını tamamla.
2. Orman kartının fresh progress'te kilitli, Başlangıç Limanı 10 tamamlandıktan sonra açık olduğunu testlerle koru.
3. Orman açıldığında kendi rotasında 1 açık / 2–10 locked state'ini koru.
4. Başarılı Android artifact'ındaki production Orman ekranını içeride incele; mevcut 200×400 artwork final yüksek çözünürlük kabul edilmez.
5. Orman Yolu için final kalite raster artwork yalnız onaylı kaynak bulunduğunda generic artwork katmanından bağlanır; procedural proof dekoru final art üzerine bindirilmez.
6. Kullanıcı ayrıca açıkça onay vermeden PR Ready/merge yapma.
7. `assets/questions.json`, 67-node BoardMap, Firebase, production AdMob, signing, version veya Play'e dokunma.

**SON DURUM:** PR #198 OPEN/DRAFT / Orman production skin + generic themed renderer aktif / sıralı 1→10 kilit kuralı kanonik / Android 16 raw runtime proof ve AdMob gate `9b23363...` üzerinde SUCCESS / owner kararıyla Orman production catalog'a üçüncü rota olarak eklendi ve Başlangıç Limanı Bölüm 10 completion kapısına bağlandı / Gökyüzü 18-star kapısı değişmedi / route catalog dedicated gate entegrasyon commitinde PASS / exact-head CI çalışıyor / mevcut artwork 200×400 ve final yüksek çözünürlük değil / merge ve Play yok.
