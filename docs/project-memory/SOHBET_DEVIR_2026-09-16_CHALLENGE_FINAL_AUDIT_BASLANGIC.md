# SOHBET DEVİR — 16 Eylül 2026 — CHALLENGE / FINAL AUDIT BAŞLANGICI

> **SUPERSEDED / ARŞİV:** Bu dosya challenge/final auditinin başlangıç notudur. Audit ve implementasyon PR #207 ile tamamlandı. Yeni authoritative devir dosyası:
>
> `docs/project-memory/SOHBET_DEVIR_2026-09-17_CHALLENGE_FINAL_BALANCE_KAPANIS.md`

Bu dosya artık yeni sohbet için aktif başlangıç kaynağı değildir. Tarihsel başlangıç bağlamını korur; aşağıdaki kapanış bilgileri önceki "audit bekliyor" durumunu supersede eder.

## Repo / target

- Repo: `ZMilaStudio/BilgiRotasi`
- Target branch: `release/final-closed-test-aab-1.68.8`
- Challenge/final product merge: `4ffe63500363e6d976bb211f5e7d547a69859df9`
- PR #207: **MERGED**
- Approved head: `9bbc3b8c6303dc390c79a2d178c03b803830c80c`
- Approved tree / merge tree: `7876ea9455465c3c1842cd391a94af9ab8365f6b`
- Tree equality: **EVET**
- Source branch `feat/kelime-avi-progressive-challenge-final-balance` korunur; owner istemeden silinmez.

## Challenge / final audit sonucu

Artık authoritative production contract:

- Normal levels: mistake odaklı; seconds threshold yok.
- L5 Challenge: 3★ = 0 hata + rota-specific 3★ süre; 2★ = <=1 hata + rota-specific 2★ süre.
- L10 Final: 3★ = 0 hata + rota-specific 3★ süre; 2★ = <=2 hata + rota-specific 2★ süre.
- target tamamlanmadıysa 0★.
- complete fakat üst eşikler kaçtıysa 1★.
- mistake + time birlikte varsa AND.
- sınırlar inclusive (`<=`).

Exact süre matrix'i:

| Rota | L5 3★ / 2★ | L10 3★ / 2★ |
|---|---|---|
| Başlangıç Limanı | 35 / 50 | 75 / 100 |
| Gökyüzü Adaları | 35 / 50 | 75 / 100 |
| Orman Yolu | 25 / 36 | 50 / 66 |
| Kadim Orman | 24 / 35 | 48 / 64 |

L5 mistake matrix tüm rotalarda `0 / <=1`; L10 mistake matrix tüm rotalarda `0 / <=2`.

`timeLimitSeconds` 60/120 olarak korunur fakat **hard fail değildir**; timeout/failure/retry veya forced finish yoktur. Scoring engine `timeLimitSeconds` kullanmaz.

Kadim Orman artık Orman Yolu timing contract'ının birebir clone'u değildir. Orman/Kadim L5 `twoStarMaxMistakes = 2` ve L5/L10 seconds `null` eski bilgileri superseded edilmiştir.

## PR #207 CI kapanışı

Approved exact head `9bbc3b8c6303dc390c79a2d178c03b803830c80c`:

- Kelime Avı Orman Yolu içerik kapısı — Run #8 / `35150882939` — SUCCESS
- Orman Yolu Android çoklu ekran kanıtı — Run #29 / `35150882942` — SUCCESS
- Kelime Avı Android 16 görsel kanıtı — Run #447 / `35150882917` — SUCCESS
- AdMob PR doğrulaması — Run #824 / `35150882966` — SUCCESS
- analyze, focused suite, full tests, release APK, package/manifest, Android 16 cold-start — PASS

## Yeni sohbetin aktif başlangıç noktası

### ROUTE REWARD + FINAL CEREMONY / ROTA TAMAMLAMA ÖDÜLÜ AUDITİ

İlk tur yalnız audit olacak. Henüz reward sistemi uygulanmayacak, ceremony tasarlanmayacak, `routeRewardId` rename edilmeyecek ve 5. rota oluşturulmayacak.

Yeni sohbet şuradan başlamalı:

`GENEL_PROJE_OZETI.md ve SOHBET_DEVIR_2026-09-17_CHALLENGE_FINAL_BALANCE_KAPANIS.md dosyalarını oku; canlı target HEAD'i doğrula ve ROUTE REWARD + FINAL CEREMONY / ROTA TAMAMLAMA ÖDÜLÜ auditinden devam et. Şimdilik runtime değişikliği yapma.`
