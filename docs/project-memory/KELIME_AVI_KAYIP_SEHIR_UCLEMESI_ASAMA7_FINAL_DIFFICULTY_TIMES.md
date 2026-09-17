# Kelime Avı — Kayıp Şehir Üçlemesi / AŞAMA 7 FINAL DIFFICULTY + TIMING CONTRACT

**Tarih:** 18 Eylül 2026  
**Durum:** FINAL / LOCKED  
**Kapsam:** Grid difficulty audit + L5/L10 exact star-time thresholds  
**Authoritative grid source:** `docs/project-memory/KELIME_AVI_KAYIP_SEHIR_UCLEMESI_ASAMA6_FINAL_GRIDS.md`

> AŞAMA 6’daki 30 literal grid AUTHORITATIVE DATASET’tir. Bu aşama grid, kelime, filler veya placement değiştirmez. Yalnız final difficulty/timing contract’ını kilitler.

---

## KİLİTLİ ÖNCEKİ AŞAMALAR

- AŞAMA 1 FINAL: 30 bölüm adı + sahne omurgası
- AŞAMA 2 FINAL: 168 target + 42 bonus
- AŞAMA 3 FINAL: 18 info card
- AŞAMA 4 FINAL: route/unlock/reward/scoring/terminal contract
- AŞAMA 5 FINAL: görsel kimlik + harita + node dili
- AŞAMA 6 FINAL: 30 authoritative deterministic 8×8 grid + exact-one validation
- AŞAMA 7 FINAL: exact L5/L10 star-time thresholds + difficulty audit

---

# PRODUCTION BASELINE AUDIT

Canlı production source doğrulaması:

## L5 challenge baseline

| ROTA | 3★ | 2★ | timeLimitSeconds |
|---|---:|---:|---:|
| Başlangıç Limanı | 35 | 50 | 60 |
| Gökyüzü Adaları | 35 | 50 | 60 |
| Orman Yolu | 25 | 36 | 60 |
| Kadim Orman | 24 | 35 | 60 |
| Kristal Vadisi | 30 | 44 | 60 |

## L10 routeFinal baseline

| ROTA | 3★ | 2★ | timeLimitSeconds |
|---|---:|---:|---:|
| Başlangıç Limanı | 75 | 100 | 120 |
| Gökyüzü Adaları | 75 | 100 | 120 |
| Orman Yolu | 50 | 66 | 120 |
| Kadim Orman | 48 | 64 | 120 |
| Kristal Vadisi | 58 | 78 | 120 |

Production scoring davranışı:

- threshold boundary: inclusive `<=`
- mistake + time: AND
- `timeLimitSeconds`: soft metadata
- scoring engine `timeLimitSeconds` alanını yıldız hesabında kullanmaz
- hard timeout yok
- completed fakat üst tier kaçtıysa 1★
- incomplete ise 0★

---

# SCORING CONTRACT — FINAL / DEĞİŞMEZ

## L5 challenge

### 3★
- 0 hata
- AND
- elapsed <= 3★ threshold

### 2★
- <=1 hata
- AND
- elapsed <= 2★ threshold

### Fallback
- completed fakat üst tier kaçtı: 1★
- incomplete: 0★

## L10 routeFinal

### 3★
- 0 hata
- AND
- elapsed <= 3★ threshold

### 2★
- <=2 hata
- AND
- elapsed <= 2★ threshold

### Fallback
- completed fakat üst tier kaçtı: 1★
- incomplete: 0★

## Ortak
- boundary: inclusive <=
- mistake + time: AND
- `timeLimitSeconds`: soft metadata
- HARD TIMEOUT: YOK

---

# 6. KAYIP ŞEHİR

## L5 — Fırtına Geçidi ⚡

### Difficulty metric özeti

- TARGET count: 6
- BONUS count: 2
- TARGET toplam harf: 36
- TARGET ortalama uzunluk: 6.00
- en uzun TARGET: FIRTINA / SIĞINAK — 7
- 3–4 harfli kısa TARGET: 0
- horizontal TARGET: 1
- vertical TARGET: 2
- diagonal TARGET: 3
- reverse-direction TARGET: 2
- listed-word shared-cell overlap: 6
- target-target shared cells: 3
- target overlap density: yaklaşık %9
- nested TARGET: yok
- visual scan complexity: orta-yüksek
- bonus distractor: TOZ kısa; HORTUM uzun/dikey. Target alanıyla sınırlı kesişim var.

### Locked rationale

36 TARGET harfi + 3 diagonal TARGET. Kristal L5’ten ölçülü daha geniş pencere gerektirir.

### FINAL TIME CONTRACT

- 3★: **<= 35 sec**
- 2★: **<= 50 sec**
- `timeLimitSeconds`: **60**

---

## L10 — Yeraltı Mührü 👑

### Difficulty metric özeti

- TARGET count: 7
- BONUS count: 2
- TARGET toplam harf: 40
- TARGET ortalama uzunluk: 5.71
- en uzun TARGET: MERDİVEN — 8
- 3–4 harfli kısa TARGET: 1 — SIR
- horizontal TARGET: 2
- vertical TARGET: 4
- diagonal TARGET: 1
- reverse-direction TARGET: 4
- listed-word shared-cell overlap: 7
- target-target shared cells: 5
- target overlap density: yaklaşık %14
- nested TARGET: yok
- visual scan complexity: orta-yüksek
- bonus distractor: ANAHTAR uzun/dikey, İNİŞ NW diagonal; kontrollü distractor etkisi.

### Locked rationale

40 TARGET harfi + MERDİVEN 8 harf. Kristal L10’a yakın fakat biraz daha yüksek çözüm yükü.

### FINAL TIME CONTRACT

- 3★: **<= 60 sec**
- 2★: **<= 80 sec**
- `timeLimitSeconds`: **120**

---

# 7. YERALTI KRALLIĞI

## L5 — Halka Kilidi ⚡

### Difficulty metric özeti

- TARGET count: 6
- BONUS count: 2
- TARGET toplam harf: 31
- TARGET ortalama uzunluk: 5.17
- en uzun TARGET: DÜZENEK — 7
- 3–4 harfli kısa TARGET: 1 — SIRA
- horizontal TARGET: 4
- vertical TARGET: 2
- diagonal TARGET: 0
- reverse-direction TARGET: 3
- listed-word shared-cell overlap: 8
- target-target shared cells: 5
- target overlap density: yaklaşık %19
- nested TARGET: yok
- visual scan complexity: orta
- bonus distractor: ÇENTİK yatay, PİM kısa diagonal; kesişim var fakat ana TARGET seti axis-aligned.

### Locked rationale

31 TARGET harfi, diagonal TARGET yok, axis-aligned yapı. 30/45 yeterli.

### FINAL TIME CONTRACT

- 3★: **<= 30 sec**
- 2★: **<= 45 sec**
- `timeLimitSeconds`: **60**

---

## L10 — Göksel Mühür 👑

### Difficulty metric özeti

- TARGET count: 7
- BONUS count: 2
- TARGET toplam harf: 35
- TARGET ortalama uzunluk: 5.00
- en uzun TARGET: GÖKSEL / YILDIZ — 6
- 3–4 harfli kısa TARGET: 2 — DOĞU, BURÇ
- horizontal TARGET: 3
- vertical TARGET: 2
- diagonal TARGET: 2
- reverse-direction TARGET: 4
- listed-word shared-cell overlap: 5
- target-target shared cells: 3
- target overlap density: yaklaşık %9
- nested TARGET: yok
- visual scan complexity: orta
- bonus distractor: İPUCU yatay, KADRAN uzun NW diagonal; kontrollü distractor etkisi.

### Locked rationale

35 TARGET harfi, maksimum TARGET 6 harf. Kristal’den biraz daha düşük solve yükü.

### FINAL TIME CONTRACT

- 3★: **<= 55 sec**
- 2★: **<= 75 sec**
- `timeLimitSeconds`: **120**

---

# 8. GÜNEŞ İMPARATORLUĞU

## L5 — Ekinoks Kapısı ⚡

### Difficulty metric özeti

- TARGET count: 6
- BONUS count: 2
- TARGET toplam harf: 30
- TARGET ortalama uzunluk: 5.00
- en uzun TARGET: EKİNOKS / YANSIMA — 7
- 3–4 harfli kısa TARGET: 3 — AYNA, AÇI, ODAK
- horizontal TARGET: 2
- vertical TARGET: 2
- diagonal TARGET: 2
- reverse-direction TARGET: 1
- listed-word shared-cell overlap: 6
- target-target shared cells: 3
- target overlap density: yaklaşık %11
- nested TARGET: yok
- visual scan complexity: orta
- bonus distractor: PLAKA NE ve KIRILMA uzun SW diagonal; kısa TARGET’larla birlikte gerçek fakat kontrollü distractor etkisi yaratır.

### Locked rationale

30 TARGET harfi ancak kısa TARGET’lar ve diagonal bonus distractor etkisi var. Yeraltı L5 ile aynı süre bandı uygundur.

### FINAL TIME CONTRACT

- 3★: **<= 30 sec**
- 2★: **<= 45 sec**
- `timeLimitSeconds`: **60**

---

## L10 — Güneş Tahtı 👑

### Difficulty metric özeti

- TARGET count: 7
- BONUS count: 2
- TARGET toplam harf: 40
- TARGET ortalama uzunluk: 5.71
- en uzun TARGET: UYGARLIK — 8
- 3–4 harfli kısa TARGET: 1 — TAHT
- horizontal TARGET: 3
- vertical TARGET: 1
- diagonal TARGET: 3
- reverse-direction TARGET: 4
- listed-word shared-cell overlap: 5
- target-target shared cells: 3
- target overlap density: yaklaşık %8
- nested TARGET: yok
- visual scan complexity: yüksek
- bonus distractor: IŞILTI dikey, ALTIN yatay; asıl difficulty TARGET geometrisinden gelir.

### Locked rationale

40 TARGET harfi + 3 diagonal TARGET + UYGARLIK 8 hücre + düşük target overlap. Üç yeni L10 içinde daha geniş süreyi gerçek grid geometrisi gerekçelendirir.

Süre artışı rota numarasından kaynaklanmaz.

### FINAL TIME CONTRACT

- 3★: **<= 65 sec**
- 2★: **<= 85 sec**
- `timeLimitSeconds`: **120**

---

# FINAL THREE-ROUTE TIMING TABLE

| ROUTE | LEVEL | 3★ | 2★ | SOFT LIMIT |
|---|---|---:|---:|---:|
| Kayıp Şehir | L5 — Fırtına Geçidi ⚡ | 35 | 50 | 60 |
| Kayıp Şehir | L10 — Yeraltı Mührü 👑 | 60 | 80 | 120 |
| Yeraltı Krallığı | L5 — Halka Kilidi ⚡ | 30 | 45 | 60 |
| Yeraltı Krallığı | L10 — Göksel Mühür 👑 | 55 | 75 | 120 |
| Güneş İmparatorluğu | L5 — Ekinoks Kapısı ⚡ | 30 | 45 | 60 |
| Güneş İmparatorluğu | L10 — Güneş Tahtı 👑 | 65 | 85 | 120 |

---

# PRODUCTION COMPARISON — FINAL RECORD

## L5

| ROTA | 3★ | 2★ | SOFT LIMIT |
|---|---:|---:|---:|
| Başlangıç Limanı | 35 | 50 | 60 |
| Gökyüzü Adaları | 35 | 50 | 60 |
| Orman Yolu | 25 | 36 | 60 |
| Kadim Orman | 24 | 35 | 60 |
| Kristal Vadisi | 30 | 44 | 60 |
| Kayıp Şehir | 35 | 50 | 60 |
| Yeraltı Krallığı | 30 | 45 | 60 |
| Güneş İmparatorluğu | 30 | 45 | 60 |

## L10

| ROTA | 3★ | 2★ | SOFT LIMIT |
|---|---:|---:|---:|
| Başlangıç Limanı | 75 | 100 | 120 |
| Gökyüzü Adaları | 75 | 100 | 120 |
| Orman Yolu | 50 | 66 | 120 |
| Kadim Orman | 48 | 64 | 120 |
| Kristal Vadisi | 58 | 78 | 120 |
| Kayıp Şehir | 60 | 80 | 120 |
| Yeraltı Krallığı | 55 | 75 | 120 |
| Güneş İmparatorluğu | 65 | 85 | 120 |

---

# SANITY CHECK — FINAL

- bütün 6 level için 3★ < 2★ < soft limit
- bütün L10 threshold’ları kendi L5 threshold’larından anlamlı biçimde yüksek
- L5 soft limit production convention’ıyla 60
- L10 soft limit production convention’ıyla 120
- hard timeout yok
- scoring mistake contract değişmedi
- 1–2 saniyelik yapay hassasiyet yerine temiz tam saniyeler kullanıldı
- ileriki rota olduğu için otomatik süre kısaltması yapılmadı
- grid difficulty farkları threshold farklarına yansıtıldı

PASS.

---

# POST-IMPLEMENTATION OWNER PLAYTEST CONTRACT

Bu AŞAMA 7 değerleri **FINAL DESIGN BALANCE contract**’tır.

Üçleme tamamen implementation’a alındıktan ve gerçek APK üretildikten sonra owner/device playtest sırasında bir threshold:

- bariz şekilde aşırı kolay
veya
- bariz şekilde aşırı cezalandırıcı

görülürse yalnız **balance tuning** konusu owner kararıyla yeniden açılabilir.

Bu olası tuning:

- grid değiştirmez
- kelime değiştirmez
- filler değiştirmez
- placement değiştirmez
- AŞAMA 1–6 content contract’ını açmaz
- ayrı bir post-implementation balance kararı olarak ele alınır
- owner onayı olmadan threshold değiştirilmez

---

# AŞAMA 7 DURUMU

**FINAL / LOCKED**

Bir sonraki owner aşaması:

**AŞAMA 8 — ENVIRONMENT ARTWORK PRODUCTION CONTRACT + ASSET PROMPT PACK**

AŞAMA 8’de önce üç haritanın exact asset teknik şartları ve üretim promptları hazırlanacaktır. Henüz implementation başlamaz.
