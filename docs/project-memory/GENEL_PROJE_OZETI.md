# Bilgi Rotası — Genel Proje Özeti

**Son güncelleme:** 13 Eylül 2026 — Kelime Avı reusable rota haritası / Orman Yolu production entegrasyonu PR #198 `feat/kelime-avi-scenic-theme-depth-20260912` branch'inde OPEN/DRAFT olarak sürüyor. Kanonik release branch `release/final-closed-test-aab-1.68.8`. Bölüm progression kararı kesin olarak **yalnız Bölüm 1 açık başlar; 2–10 kilitli; her bölüm yalnız kendinden önceki tamamlanınca açılır (`1→2→3→4→5→6→7→8→9→10`)** şeklindedir. 13 Eylül owner kararıyla **Orman Yolu production rota kataloğunda üçüncü rota olarak yer alır ve yalnız Başlangıç Limanı 10. bölüm tamamlandığında açılır**; Gökyüzü Adaları'nın 18 Başlangıç Limanı yıldızı kapısı değişmez. Orman Yolu açıldığında kendi içinde yine yalnız Bölüm 1 açık/current, Bölüm 2–10 locked başlar. Production presentation generic `themedReusable` renderer + `WordHuntRouteVisualThemes.ormanYolu` skinidir. Android 16 görsel proof ve AdMob doğrulaması önceki exact-head `9b23363d7a0c4a28652fa717802e97c4bced1cfa` üzerinde SUCCESS oldu; route catalog entegrasyonu için `6c311fce92bcdb928f47f123cf0692f28584f4a9` üzerinde dedicated route catalog gate SUCCESS geçti. Güncel HEAD karar kaydıyla `f1c1770eed32af5b81ef82180f4a65281c951df2`; exact-head CI çalışıyor. Mevcut Orman raster kaynağı yaklaşık 200×400 olduğu için final yüksek çözünürlüklü artwork kalite borcu açık kalır. PR Ready/merge için owner ayrıca açık onay vermelidir.

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
- Bölüm 2–10 kilitlidir.
- Her bölüm yalnız kendinden önceki bölüm tamamlanınca açılır: `1→2→3→4→5→6→7→8→9→10`.
- Bölüm 8 normal bölümdür; Bölüm 9 için zorunlu kapıdır.
- Bir bölümün tamamlanması yalnız bir sonraki bölümü açar; iki ileri bölüm aynı anda açılamaz.

## Kelime Avı — Production rota kataloğu

- `Başlangıç Limanı`: her zaman açık; reference renderer.
- `Gökyüzü Adaları`: 18 Başlangıç Limanı yıldızında açılır; mevcut MASTER ART renderer.
- `Orman Yolu`: **Başlangıç Limanı 10. bölüm tamamlandığında** açılır; yıldız toplamından bağımsızdır ve Gökyüzü tamamlanma şartı yoktur.
- `Orman Yolu` generic `themedReusable` production renderer ve `WordHuntRouteVisualThemes.ormanYolu` skinini kullanır.
- Orman'ın rota içi ilk açılışı ayrıca değişmez: yalnız Bölüm 1 açık, Bölüm 2–10 locked.

## Orman Yolu — Görsel durum

- Raster artwork arka plan; path/node/lock/progression canlı Flutter katmanıdır.
- Android 16 raw screenshot kanıtı `9b23363...` exact-head'de SUCCESS üretti.
- Mevcut source artwork yaklaşık 200×400'dür; telefon çözünürlüğüne büyütüldüğü için final yüksek çözünürlük kalite hedefi açık borçtur.
- Kullanıcı açıkça istemediği sürece yeni konsept/image generation yapılmaz; çalışma doğrudan oyuna uygulanır.

## PR #198 owner gate

- PR OPEN/DRAFT kalır.
- Exact-head CI/Android PASS, Ready veya merge izni değildir.
- Ready/merge/release/Play için owner ayrıca açık onay vermelidir.
