# Bilgi Rotası – Güncel Proje Durumu

**Son güncelleme:** 12 Eylül 2026

## 1. Kritik gerçek durum

- Repo: `ZMilaStudio/BilgiRotasi`
- Default branch: `main`
- **Önemli:** `main` güncel ürün tabanı olarak varsayılmayacak. Canlı ürün/release zinciri `release/final-closed-test-aab-1.68.8` ve ondan türeyen branch/PR'ler üzerinden ilerliyor.
- `main` HEAD (bu docs checkpoint branch'i açılırken): `a5494b6f9c93b9d07ae04c45dc8360208ca5acf7`.
- Canonical release branch: `release/final-closed-test-aab-1.68.8`.
- Canonical release HEAD: `d72b034a30bf32893b8a807ba4791d637880d989`.
- Release `pubspec.yaml`: **1.68.20+110**.
- Play yükleme/yayınlama bu çalışma kapsamında yapılmadı.

## 2. PR #180 — 200 bölüm içerik üretim hattı

PR #180: `feat(kelime-avi): add 200-level content production pipeline`

- Durum: **OPEN / DRAFT / mergeable / merged=false**.
- Branch: `feat/kelime-avi-200-level-content-pipeline-20260906`.
- Exact HEAD: `dd99b25ccb7d437ba6d05ea5dea26356a8d99032`.
- Base: `release/final-closed-test-aab-1.68.8`.
- Sürüm: **1.68.20+110**.
- `Kelime Avı Content Factory` run `34610110468`: **SUCCESS**.
- `AdMob PR doğrulaması` run `34610110384`: **SUCCESS**.
- Content Factory kanıtı: 18 rota / 180 yeni bölüm üretildi; mevcut 20 ile **200/200 release-stock gate PASS**.
- Exact-one fiziksel occurrence doğrulaması PASS; palindrome `KÖK` için aynı fiziksel hücre yolu ileri/geri iki occurrence sayılmayacak şekilde düzeltildi.
- Bu 200 bölüm **release branch'e veya runtime kataloğuna merge edilmiş değildir**; yalnız PR #180 draft hattında doğrulanmış stoktur.
- Ready/merge için açık Levent onayı gerekir.

## 3. PR #184 — reusable 10-bölümlük rota haritası

PR #184: `feat(kelime-avi): introduce reusable 10-level route map engine`

- Durum: **OPEN / DRAFT / mergeable / merged=false**.
- Branch: `feat/kelime-avi-reusable-route-map-engine-20260911`.
- Base: `release/final-closed-test-aab-1.68.8` @ `d72b034a30bf32893b8a807ba4791d637880d989`.
- Exact HEAD: `b34bfddff5183692e62ac7c9bd49ad15140dae31`.
- Amaç: her yeni rota için ayrı master-art + piksel koordinat + route-id özel layout üretme döngüsünü bitirmek.

Mimari sözleşme:
- Tek normalize edilmiş 10 düğümlük geometri.
- Ortak topoloji: `1→2→3→4→5→6→7→8→9→10`.
- Önerilen modelde **8 normal bölümdür; bonus node değildir**.
- Progression route-id özel istisna kullanmaz; her bölüm yalnız kendinden önceki bölüm tamamlandıysa açılır.
- Tema renk/veri taşır; koordinat/layout taşımaz.
- Liman / Gökyüzü / Orman proof temaları aynı widget/painter/geometriyi kullanır.
- Yeni rota eklemek için özel Widget/Painter/koordinat listesi gerekirse mimari başarısız sayılır.

Exact HEAD canlı kanıtları:
- `Kelime Avı Android 16 görsel kanıtı` run `34636992893`: **SUCCESS**.
- `AdMob PR doğrulaması` run `34636992854`: **SUCCESS**.
- Focused Kelime Avı suite: PASS.
- Analyzer + tüm testler: PASS.
- Reusable Orman Yolu proof APK build: PASS.
- Gerçek Android 16 reusable ekran yakalama: PASS.
- Release APK / signing / package / manifest: PASS.
- Android 16 cold-start ilk deneme: PASS; ikinci deneme gerekmedi.
- Final AdMob app gate: PASS.

Artifact'ler:
- `BilgiRotasi-KelimeAvi-ReusableMap-b34bfddff5183692e62ac7c9bd49ad15140dae31` — ID `10278822820`.
- `BilgiRotasi-KelimeAvi-ReusableMap-Android16-b34bfddff5183692e62ac7c9bd49ad15140dae31` — ID `10278274442`.
- `BilgiRotasi-KelimeAvi-PixelProof-b34bfddff5183692e62ac7c9bd49ad15140dae31` — ID `10278559423`.

Gerçek Android Orman Yolu proof incelemesi:
- başlık/yıldız sayacı okunaklı,
- ortak 1–10 geometri taşmasız,
- proof state'te 1–7 tamamlanmış, 8 açık, 9–10 kilitli,
- route-id özel layout/painter/koordinat yok,
- ekran yalnız mimari iskelet kanıtıdır; nihai Orman Yolu dekor/sanat tasarımı değildir,
- proof target production `main.dart` / production navigasyona bağlı değildir.

**Kabul kapısı:** PR #184 owner tarafından kabul edilmeden Ready/merge yapılmaz ve yeni 180 bölüm runtime kataloğuna bağlanmaz.

## 4. Release branch'teki mevcut progression ile PR #184 önerisini karıştırma

Canonical release HEAD `d72b034...` üzerinde mevcut kod hâlâ iki rota için özel istisna taşır:

- `baslangic-limani` ve `gokyuzu-adalari` için 7 tamamlanınca 9 da açılır.
- 8 mevcut release modelinde bonus geçiş noktasıdır ve 9 için gate değildir.
- 10, 9 tamamlanınca açılır.

PR #184 ise bunu **önerilen yeni canonical sıralı model** olarak değiştirir:

- `7→8→9→10`,
- 8 normal bölüm,
- route-id özel progression yok.

PR #184 merge edilmeden yeni modeli "canlı release davranışı" diye yazma veya varsayma.

## 5. Kelime Avı kilitli ürün kuralları

Release'e göre hâlen geçerli/korunanlar:
- Canonical gameplay grid: **8×8 / 64 hücre**.
- Başlangıç Limanı: 10 bölüm / 30 yıldız / 80 target+bonus.
- Gökyüzü Adaları: 10 bölüm / 30 yıldız / 80 target+bonus.
- Her canonical kelimede exactly-one fiziksel occurrence gate.
- Reverse gesture aynı canonical kelimeyi üretir.
- Nearest-word/autocomplete yok.
- B5 ve B10 süreleri soft challenge.
- Kullanıcı kabulü olmadan görsel yön değişmez.
- Gökyüzü Adaları scenic gameplay yönü kullanıcı tarafından kabul edilmiştir.

## 6. Korunan alanlar

Ayrı açık karar olmadan değiştirilmez:
- `assets/questions.json`
- BoardMap / 67 node
- mevcut ana oyun oynanışı
- Firebase
- AdMob production ayarları
- signing
- package/version
- Play release/yayın

## 7. AdMob / Android doğrulama standardı

- Gerçek Android `adb logcat` / `AndroidRuntime` kanıtı olmadan crash nedeni kesin ilan edilmez.
- Full workflow + YAML + script + dosya yolları + shell davranışı birlikte incelenir.
- Build PASS tek başına ürün kabulü değildir.
- Cold-start, app/process/activity gate ve artifact birlikte değerlendirilir.
- Test App ID ile production App ID karıştırılmaz.
- PR #184 exact HEAD'de AdMob validation `34636992854` SUCCESS ve ilk Android16 cold-start denemesi PASS'tır.

## 8. Soru bankası

- Önceki kanonik kayıt: **6.710 soru**.
- Türkiye özel 2.000 kolay soru paketi hazırlanmış durumda.
- Paketin canlı `assets/questions.json` içine gerçekten merge edilip edilmediği ve güncel toplam soru sayısı bu dosyada doğrulanmış değildir: **DOĞRULANACAK**.
- `assets/questions.json` kontrolsüz değiştirilmez.

## 9. Çalışma protokolü

Her teknik işte sıra:

**Canlı durum → kararlar → görev/bitti ölçütü → branch → değişiklik → test → commit → push → PR → inceleme → açık onay → merge**

- `main`/release'e doğrudan yazma.
- Ayrı branch kullan.
- Levent açıkça onaylamadan kritik Ready/merge/release/Play yapma.
- Doğrulanmamış bilgiyi **DOĞRULANACAK** diye işaretle.
- Kullanıcının ilgisiz değişikliklerini silme.
- `git reset --hard` rutin çözüm değildir.

## 10. Şu anki gerçek kapılar

1. **PR #184 mimari owner kabulü** — teknik CI + Android16 kanıtı PASS; hâlâ DRAFT.
2. PR #184 kabul edilirse sonraki production entegrasyon planı ayrıca branch/PR ile yapılacak; bu PR 180 bölümü runtime'a bağlamaz.
3. **PR #180 merge/Ready kararı** — 200/200 release-stock gate PASS; hâlâ DRAFT.
4. `assets/questions.json` güncel toplamı ve Türkiye 2.000 paketinin merge durumu — **DOĞRULANACAK**.
5. Play Console mevcut production/candidate sürümü ile GitHub exact HEAD eşleşmesi — **DOĞRULANACAK**; bu çalışmada Play aksiyonu yok.

## 11. Devir notu

Daha kapsamlı çalışma kuralları `DEVRALMA_1_AYLIK_GPT.md` dosyasındadır.

**Kuralın özü:** canlı GitHub > bu durum dosyası > diğer karar/görev kayıtları > eski sohbetler.
