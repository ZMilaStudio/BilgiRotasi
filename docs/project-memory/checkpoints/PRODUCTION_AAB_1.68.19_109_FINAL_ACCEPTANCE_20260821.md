# Bilgi Rotası - Final Production AAB 1.68.19+109 Kabul Checkpoint'i

**Tarih:** 21 Ağustos 2026  
**Durum:** `DOĞRULANDI` — Play Console production yayınlama işlemi kullanıcı tarafından tamamlandı; public dağıtım/kurulum ayrıca doğrulanacak  
**Kapsam:** Production AAB artifact kabulü, provenance ve Play production yayınlama checkpoint'i. Runtime, `assets/questions.json`, BoardMap/67 node, 3B tahta, Firebase/AdMob canlı ayarı değiştirilmedi.

## 1. Kanonik kaynak kilidi

- Release branch: `release/final-closed-test-aab-1.68.8`
- Exact ürün kaynak SHA: `b0240a7a4009c41326f459a37b8bedeab080d8d8`
- Kanonik release SHA: `04228ec0ca5e8875b245b2df739549f9679e3349`
- Sürüm: `1.68.19+109`
- `assets/questions.json` blob SHA: `b19956972c05bdc58e6b9a0c010a407e6c05613f`
- Package: `com.leventua.bilgirotasi`

Kanonik release SHA'nın ürün SHA'dan sonraki farkı proje hafızası/docs kapsamındadır; artifact workflow'u exact ürün SHA'yı checkout ederek üretim girdisini kilitler.

## 2. Deterministik production runner

- Runner base: `test/production-aab-109-runner-20260821`
- Runner base SHA: `1e88c1c6cd54619ead23937cfbcf38b501e03352`
- Artifact trigger branch: `ci/production-aab-1.68.19-109-final-20260821`
- Trigger commit: `534569ccd365e40fca8065f00936681ffeb9e0c5`
- PR #94: **OPEN / DRAFT / UNMERGED / ARTIFACT ONLY / DO NOT MERGE**

Production build'in iki ayrı profil girdisi zorunludur ve final run'da ikisi de set/assert edilmiştir:

- Dart define: `ADMOB_ENVIRONMENT=production`
- Gradle: `ORG_GRADLE_PROJECT_ADMOB_ENVIRONMENT=production`
- Firebase define/profile: production

Önceki provenance'ı eksik artifact final yayın dosyası olarak kullanılmaz.

## 3. GitHub Actions kabulü

- Workflow run: `32496000951`
- Job: `96814411313`
- Sonuç: **SUCCESS**
- Artifact: `BilgiRotasi-1.68.19-109-production-aab`
- Artifact ID: `9452010891`
- Artifact ZIP digest: `sha256:1a877b9859acda9dff6500236f7dbef52a5f50912322fa7ca54e2d88ee52784f`
- Artifact süresi: GitHub metadata'sına göre 4 Eylül 2026'ya kadar geçerli

Final workflow/test raporu:

- Flutter analyze: PASS
- Flutter tests: PASS
- Production AdMob profile: PASS
- Production Firebase profile: PASS
- Functions + Firestore Rules tests: PASS
- `git diff --check`: PASS

## 4. Play'e verilecek tek AAB

Dosya:

`dist/BilgiRotasi-1.68.19-109-production.aab`

Gerçek AAB SHA-256:

`fd9f0da0539201e1be32d37097257567a498d06d6f86a406773c06665d973bd5`

Bu hash artifact içindeki `reports/AAB_SHA256.txt` ile bağımsız yeniden hesaplama sonucunda birebir eşleşmiştir.

## 5. AAB manifest / production profil doğrulaması

AAB'nin kendi manifestinden:

- package: `com.leventua.bilgirotasi`
- versionCode: `109`
- versionName: `1.68.19`
- minSdk: `24`
- targetSdk: `36`
- compileSdk: `36`
- AdMob App ID: `ca-app-pub-7452194004008791~7046504043`
- `MobileAdsInitProvider`: mevcut
- Firebase Analytics başlangıç collection: `false`
- Firebase Messaging auto-init: `false`
- Analytics Ad ID collection: `false`

Production configuration raporu:

- AdMob profile: `production`
- Banner ID: `ca-app-pub-7452194004008791/4228769011`
- Rewarded ID: `ca-app-pub-7452194004008791/4974874471`
- Firebase profile: `production`
- Firebase project: `bilgi-rotasi-f255d`

Eski/farklı rewarded ID kayıtları bu artifact için geçerli kabul edilmez; final doğrulanmış production rewarded ID `/4974874471`'dir.

## 6. İmza doğrulaması

AAB `jarsigner` doğrulaması: **PASS (`jar verified`)**.

Upload sertifikası:

- SHA-1: `00:0E:E4:3F:41:0A:BC:6B:4F:63:4C:4F:71:6D:76:EB:19:08:41:15`
- SHA-256: `3B:36:82:4E:F1:47:6B:68:89:A0:24:D0:46:7B:5C:EA:89:03:AA:7E:EE:B4:5B:46:87:C5:BA:A8:E4:60:F2:78`
- Signature algorithm: `SHA384withRSA`
- RSA: `4096-bit`

## 7. Fiziksel rewarded sözleşmesi

Aynı gün yapılan fiziksel production kabulü ayrıca PASS olarak kaydedildi:

- Aynı `gameId` ikinci +10 XP vermez — PASS.
- Yarım/başarısız reklamda XP verilmez; hak korunur ve retry mümkündür — PASS.
- Farklı tamamlanan oyunlarda günlük/oturumluk toplam kota yoktur — PASS.
- Gerçek rewarded -> SSV claim -> +10 XP — PASS.

Bu maddeler ürün kararını değiştirmez; `KARARLAR.md` bölüm 5'teki mevcut sözleşmenin canlı kabulüdür.

## 8. Play production yayınlama checkpoint'i

21 Ağustos 2026 saat 20:39 (+03:00) itibarıyla Levent, exact `1.68.19+109` production AAB'yi Google Play Console'a yüklediğini ve ardından production yayınlama işlemini tamamladığını bildirdi.

Bu kullanıcı teyidi aşağıdaki adımları kapatır:

- production AAB Play Console'a yüklendi — **KULLANICI TEYİDİ**.
- production yayınlama işlemi başlatıldı/tamamlandı — **KULLANICI TEYİDİ**.

**DOĞRULANACAK:** Google Play'in public dağıtımının tamamlanması, mağazada +109'un gerçekten kullanıcılara sunulması, temiz kurulum/güncelleme ile Play-delivered build'in kurulabilmesi ve rollout/public durumunun ekran/cihaz kanıtıyla kapanması.

Google Play durum kontrol panelinde 21 Ağustos 2026 itibarıyla genel bir Play yayınlama hizmet kesintisi görünmemesi yalnız platform-geneli bağlamdır; Bilgi Rotası'nın rollout durumunu tek başına kanıtlamaz.

## 9. Git / merge sınırı

- PR #94 artifact-only kalır ve **merge edilmez**.
- Bu checkpoint branch'i docs-only'dir.
- Kritik release/main merge Levent'in ayrıca açık onayı olmadan yapılmaz.
- `KARARLAR.md` değişmedi; yeni ürün kararı alınmadı.

## 10. Proje hafızası notu

`BILGI_ROTASI_DURUM.md`, `GOREV_HAVUZU.md` ve `ACIK_SORULAR_VE_DOGRULAMALAR.md` büyük tarihsel dosyalardır. Connector üzerinden komple replace sırasında veri kaybı riski bulunduğundan mevcut kanonik tarihçe ezilmedi. Bu checkpoint final AAB kabulünün ve Play production yayınlama kullanıcı teyidinin kayıpsız uzak kanıtıdır; kanonik dosyalardaki açık maddeler bir sonraki kontrollü docs entegrasyonunda bu checkpoint'e dayanarak güncellenmelidir.

## 11. Bu checkpoint güncellemesinin kanıt sınırı

- Play Console ekran görüntüsü bu checkpoint güncellemesinde ayrıca incelenmedi.
- Google Play Store public listing üzerinden sürüm numarası bu oturumda güvenilir biçimde okunamadı.
- Bu nedenle `rollout/public/install PASS` yazılmadı; durum bilinçli olarak `DOĞRULANACAK` bırakıldı.
