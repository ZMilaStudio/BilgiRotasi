# Kelime Avı V9 — Sohbet Devir Belgesi

**Tarih:** 7 Eylül 2026
**Repo:** `ZMilaStudio/BilgiRotasi`
**Canonical release branch:** `release/final-closed-test-aab-1.68.8`
**Canonical release HEAD:** `a43d85eae86eac335c7e09a832152667ba608c53`
**Son sürüm:** `1.68.20+110`

## 1. Bu sohbetin durduğu yer

Kelime Avı V9 üzerinde üretimi durdurduk. Amaç, mevcut 20 bölümü yayınlamak değil; içerik stoğunu minimum **200 hazır/doğrulanmış bölüm** seviyesine çıkarmak.

Kullanıcı kararı kesindir:

- 20 bölüm yayın için yetersiz.
- Kelime Avı **minimum 200 hazır/doğrulanmış bölüm olmadan Play'e çıkarılmayacak**.
- 1.68.20+110 production AAB Kelime Avı içerdiği için **Play Console'a yüklenmeyecek**.
- Yeni Kelime Avı AAB'si 200 bölüm ve gerekli runtime/fiziksel kabul kapıları tamamlanmadan üretim adayı olmayacak.

## 2. Mevcut production AAB durumu

`1.68.20+110` production workflow run `34050183031` SUCCESS ile tamamlandı ve GitHub Release oluşturuldu.

- AAB SHA256: `2bfac3fb5642ba10c57d5f58acb158fdb2eede9210b9a8777d786f884d9cb66d`
- Universal APK SHA256: `710e3c1025a41c6ca2a2c930dede4794ac9ef77ef7cf6e25fea6313b1323c8e3`
- Play Console yüklemesi: **YOK**
- Play yayınlaması: **YOK**

## 3. Gökyüzü Adaları durumu

- Paket adı: **Gökyüzü Adaları**
- Görsel yön: **C — Neşeli & Parlak**
- 10 bölüm rota
- Modüler asset mimarisi ve rota mock V2: **LOCKED/PASS**
- Kullanıcı görsel kabulü: **PASS**
- Arka plan yalnız tema ile uyumlu boş/tematik scenic background olacak; gameplay/UI pikselleri arka plana gömülmeyecek.
- Telefon ekranına göre kompozisyon; üst/alt gereksiz boşluk yok, yalnız banner reklam için gereken alt alan bırakılacak.
- Runtime asset sözleşmesi: **41 core + 7 opsiyonel = 48 WebP**
- ZIP: **557.120 bayt**
- SHA256: `d219c6233fa27f5e3e04687ec5fd15dab1f24500584e78d6a7c80036ee68f5ca`
- Alpha/file QA: **PASS**
- Raw Android runtime görsel PASS: **HENÜZ YOK**
- Flutter entegrasyonu sonrası Android16 raw screenshot + crash/ANR/log kanıtı ve gerçek cihaz görsel kabulü alınacak.
- PR #171 (`feat(kelime-avi): add Gokyuzu 8x8 content pack`) OPEN/DRAFT; Ready/merge yok. Exact HEAD `4ec33de7438fcbd15ed63b1ae2adda127da3be8c`.
- PR #175 tarihsel runtime asset/görsel kabul checkpoint'idir; raw Android fiziksel kapı ayrı.

## 4. Kelime Avı canonical gameplay

- Grid: **8×8 / 64 hücre — LOCKED**.
- Target+bonus eğrisi: B1 5+1, B2 5+1, B3 6+1, B4 6+1, B5 7+1, B6 7+1, B7 8+1, B8 7+2, B9 9+1, B10 9+1.
- Toplam ilk rota içeriği: **80 target+bonus**.
- Exactly-one physical occurrence zorunlu.
- Reverse gesture canonical kelimeye çözülür.
- B5 60 sn ve B10 120 sn soft challenge.
- Engine/path/scoring/timer/progression değişmez.

Başlangıç Limanı gameplay/görsel kabulleri yeni belirti yoksa yeniden açılmayacak.

## 5. 200 bölüm üretim kararı

Mevcut stok: **20 bölüm**.

Hedef:

- 18 yeni rota
- Her rota 10 bölüm
- 180 yeni bölüm
- Mevcut 20 + yeni 180 = **200 minimum**

Üretim yöntemi artık bölüm bölüm elle yapılmayacak. 10 bölümlük paket/rota temel üretim birimi.

Her bölüm için otomatik kapılar:

- 8×8 grid
- target/bonus sayısı
- exactly-one physical occurrence
- yatay/dikey/çapraz yönler
- reverse gesture
- timer/yıldız kuralları
- render/manifest doğrulaması
- duplicate/çakışma/bozuk içerik reddi

İnsan denge örneklemesi varsayılan B1 + B5 + B10; yalnız otomatik outlier varsa ek bölüm oynanır.

## 6. PR #180

**PR:** #180 — `feat(kelime-avi): add 200-level content production pipeline`

**Durum:** OPEN / DRAFT / mergeable=true / merged=false

**Base:** `release/final-closed-test-aab-1.68.8` @ `a43d85eae86eac335c7e09a832152667ba608c53`

**Current HEAD:** `618404e281bca91cdd2e9eb03761f47784690353`

Amaç: deterministik toplu içerik üretimi + otomatik doğrulama.

Eklenen kapsam:

- `tools/word_hunt_batch_generator.py`
- `tools/word_hunt_content_factory.sample.json`
- `.github/workflows/word-hunt-content-factory.yml`
- `docs/project-memory/KELIME_AVI_200_BOLUM_URETIM_HATTI_2026-09-06.md`

PR #180:

- Play yüklemez.
- Runtime katalog eklemez.
- Production sürüm değiştirmez.
- `assets/questions.json`, BoardMap/67 node, Firebase, AdMob, signing ve Play release korunur.

İlk altyapı CI turu yeşil kabul edildi. Sohbet durdurulurken exact HEAD CI durumu ayrıca canlı doğrulanmalı; önceki konuşmada yeni üretim bloğu için takipteydi.

## 7. Üretim taslağındaki 18 rota

1. Orman Yolu
2. Deniz Koyu
3. Dağ Geçidi
4. Çöl Vahası
5. Kış Ülkesi
6. Bahar Bahçesi
7. Gece Şehri
8. Uzay Üssü
9. Antik Kent
10. Gizemli Laboratuvar
11. Müzik Adası
12. Spor Vadisi
13. Mutfak Sokağı
14. Masal Ormanı
15. Teknoloji Kenti
16. Tarih Yolu
17. Bilim Koyu
18. Hazine Adası

Bu rota/kelime havuzları üretim taslağıdır; **canonical runtime içeriğine merge edilmiş kabul edilmez**.

## 8. Yeni sohbette ilk yapılacaklar

1. Canlı GitHub'dan `release/final-closed-test-aab-1.68.8` HEAD'i doğrula.
2. `pubspec.yaml` sürümünü doğrula.
3. Açık PR'ları kontrol et; özellikle #180, #171 ve tarihsel #175/#168 durumlarını ayır.
4. PR #180 current HEAD `618404e...` ve tüm CI sonuçlarını exact HEAD üzerinden doğrula.
5. PR #180'u Ready/merge etmeden önce diff'i incele; üretim hattının protected scope'a dokunmadığını doğrula.
6. 180 yeni bölümü toplu üret; 200/200 release-stock gate PASS olmadan runtime katalog/release entegrasyonuna geçme.
7. Yeni bölümler için otomatik QA tamamlanınca gerekli görsel/runtime entegrasyonunu büyük mantıklı bloklar halinde yap.
8. Kullanıcı açıkça istemeden APK/AAB hazırlama; özellikle **Kelime Avı içeren 1.68.20+110 AAB Play'e yüklenmeyecek**.
9. Gökyüzü Adaları runtime entegrasyonunda önce görsel kabul, sonra Android16 raw runtime, sonra gerçek cihaz kabulü.
10. Play yükleme/yayınlama yalnız Levent'in ayrıca açık onayıyla yapılır.

## 9. Kalıcı çalışma kuralları

- WORK V2 aktif: mikro adım + bekleme yok; büyük mantıklı bloklar halinde ilerle.
- Kullanıcı test/dosya taşıma operatörü yapılmayacak.
- Gereksiz Codex kredisi harcanmayacak.
- Build PASS tek başına yeterli kanıt değildir.
- Görsel kabul mockup/ImageGen ile değil, gerçek/raw Android runtime ile verilir.
- `assets/questions.json` kontrolsüz değiştirilmez.
- BoardMap/67 node değiştirilmez.
- Firebase, AdMob, signing, package/version ve Play release ayrı korunan kapsamdır.
- Kritik Ready/merge/release kararlarında Levent'in açık onayı gerekir.

**DEVRİN KESİLDİĞİ NOKTA:** PR #180 üzerinde 200 bölümlük ölçeklenebilir üretim hattı hazırlanmış durumda; sonraki sohbetin ilk işi exact HEAD/CI doğrulaması ve ardından 180 yeni bölümün güvenilir toplu üretimidir. **200 doğrulanmış bölüm olmadan Kelime Avı Play'e çıkmayacak.**