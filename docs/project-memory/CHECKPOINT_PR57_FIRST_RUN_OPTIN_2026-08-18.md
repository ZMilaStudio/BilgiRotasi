# PR #57 First-run opt-in merge checkpoint

**Tarih:** 18 Ağustos 2026
**Kanonik release branch:** `release/final-closed-test-aab-1.68.8`

## Doğrulanan merge

- PR #57: `feat: replace first-run Analytics prompt with notification opt-in`
- Levent açık merge onayı verdi.
- Final PR head: `8045b3808ab09ba2304604f20641f987506afc27`.
- Final PR-head `AdMob PR doğrulaması` run #243 / `32081710074`: `SUCCESS`.
- PR #57 Draft'tan çıkarıldı ve `squash` yöntemiyle release dalına merge edildi.
- Merge commit / canlı release HEAD: `9e51728889e67efd60dc96c4ea9a2f8cd627c289`.
- Commit adı: `feat: replace first-run Analytics prompt with notification opt-in (#57)`.
- Merge sonrası `pubspec.yaml` sürümü değişmedi: `1.68.16+106`.

## Merge edilen davranış

- İlk açılışta otomatik Analytics izin popup'ı gösterilmez.
- Analytics varsayılan kapalı kalır; yalnız `Ayarlar > Kullanım Analizi` üzerinden açık kullanıcı opt-in'i ile etkinleştirilir.
- Kullanıcı hesap modu seçildikten sonra, yalnız Android + gerçek uzak FCM profilinde, daha önce gösterilmediyse ve bildirim zaten açık değilse tek seferlik bildirim çağrısı gösterilebilir.
- `Şimdi Değil` Android sistem bildirim izin penceresini açmaz.
- `Bildirimleri Aç` mevcut `PushNotificationService.setEnabled(true)` yolunu kullanır.
- Test/CI profillerinde uzak FCM kapalıysa çağrı gösterilmez.
- `assets/questions.json`, Canlı Düello, BoardMap/67 node, 3B tahta, Firebase backend, AdMob backend, signing ve sürüm değiştirilmedi.

## Değişen dosyalar

- `docs/project-memory/KARARLAR.md`
- `lib/about_privacy.dart`
- `lib/analytics_telemetry.dart`
- `test/analytics_telemetry_test.dart`

## Açık kabul

- Bu merge yeni bir Play/AAB yayını yapmaz. Güncel fiziksel Play kurulumunda yeni first-run UX ancak bu kodu içeren sonraki dağıtım kurulduğunda doğrulanabilir.
- Fiziksel kabulte en az şu maddeler doğrulanacak: Analytics popup'ının otomatik çıkmaması; bildirim çağrısının doğru zamanda tek kez görünmesi; `Şimdi Değil` sonrası sistem izin penceresinin açılmaması; `Bildirimleri Aç` sonrası Android izin akışının çalışması; Ayarlar'daki Analytics ve bildirim anahtarlarının korunması.
- `BILGI_ROTASI_DURUM.md` ve `GOREV_HAVUZU.md` içindeki tarihsel büyük kayıtlar connector üzerinden güvenli satır-ekleme işlemi olmadan komple replace edilmemelidir. Bu checkpoint, veri kaybı riski oluşturmadan merge kanıtını uzakta sabitler; kanonik iki dosyaya entegrasyon ayrı docs adımında yapılacaktır.
