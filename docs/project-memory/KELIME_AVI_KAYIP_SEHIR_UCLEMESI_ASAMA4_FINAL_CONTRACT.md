# Kelime Avı — Kayıp Şehir Üçlemesi / AŞAMA 4 FINAL CONTRACT

**Tarih:** 18 Eylül 2026  
**Durum:** FINAL / LOCKED  
**Kapsam:** Route contract + unlock + reward + challenge/final + terminal + historical user davranışı

> Bu doküman yalnız ürün/teknik contract kararıdır. Kod, grid, exact süre, asset, branch/PR veya implementation içermez.

---

## KİLİTLİ AŞAMALAR

- **AŞAMA 1 FINAL:** 30 bölüm adı + sahne omurgası kilitli.
- **AŞAMA 2 FINAL:** 168 target + 42 bonus kelime kilitli.
- **AŞAMA 3 FINAL:** 18 info card kilitli.
- **AŞAMA 4 FINAL:** route/unlock/reward/scoring/terminal contract kilitli.

AŞAMA 1–3 içeriğine bu contract kapsamında dokunulmaz.

---

## HEDEF PRODUCTION ROTA SIRASI

1. Başlangıç Limanı
2. Gökyüzü Adaları
3. Orman Yolu
4. Kadim Orman
5. Kristal Vadisi
6. Kayıp Şehir
7. Yeraltı Krallığı
8. Güneş İmparatorluğu

---

# 6. KAYIP ŞEHİR

- technical route ID: `kayip-sehir`
- ordinal: **Altıncı rota**
- unlock prerequisite: **Kristal Vadisi `routeComplete`**
- `unlockStarsRequired`: **0**
- locked copy: **`Kristal Vadisi’ni tamamlayarak aç.`**
- reward ID: `badge-kayip-sehir-kasifi`
- reward display: **Kayıp Şehir Kaşifi**
- reward icon direction: `Icons.account_balance_rounded`
  - implementation sırasında mevcut Flutter SDK ile compile doğrulaması yapılacak.

### L5

**Fırtına Geçidi ⚡**  
`WordHuntLevelType.challenge`

### L10

**Yeraltı Mührü 👑**  
`WordHuntLevelType.routeFinal`

---

# 7. YERALTI KRALLIĞI

- technical route ID: `yeralti-kralligi`
- ordinal: **Yedinci rota**
- unlock prerequisite: **Kayıp Şehir `routeComplete`**
- `unlockStarsRequired`: **0**
- locked copy: **`Kayıp Şehir’i tamamlayarak aç.`**
- reward ID: `badge-yeralti-kasifi`
- reward display: **Yeraltı Kaşifi**
- reward icon direction: `Icons.vpn_key_rounded`
  - implementation sırasında mevcut Flutter SDK ile compile doğrulaması yapılacak.

### L5

**Halka Kilidi ⚡**  
`WordHuntLevelType.challenge`

### L10

**Göksel Mühür 👑**  
`WordHuntLevelType.routeFinal`

> Exact isim kilidi: **Göksel Mühür 👑**. `Göksel Mührü` değildir.

---

# 8. GÜNEŞ İMPARATORLUĞU

- technical route ID: `gunes-imparatorlugu`
- ordinal: **Sekizinci rota**
- unlock prerequisite: **Yeraltı Krallığı `routeComplete`**
- `unlockStarsRequired`: **0**
- locked copy: **`Yeraltı Krallığı’nı tamamlayarak aç.`**
- reward ID: `badge-gunes-kasifi`
- reward display: **Güneş Kaşifi**
- reward icon direction: `Icons.wb_sunny_rounded`
  - implementation sırasında mevcut Flutter SDK ile compile doğrulaması yapılacak.

### L5

**Ekinoks Kapısı ⚡**  
`WordHuntLevelType.challenge`

### L10

**Güneş Tahtı 👑**  
`WordHuntLevelType.routeFinal`

---

# UNLOCK / COMPLETION CONTRACT

Yeni üç rota için ekstra yıldız kapısı yoktur.

Zincir:

**Kristal Vadisi `routeComplete`**
→ **Kayıp Şehir unlocked**
→ Kayıp Şehir `routeComplete`
→ **Yeraltı Krallığı unlocked**
→ Yeraltı Krallığı `routeComplete`
→ **Güneş İmparatorluğu unlocked**

Üç yeni rotada `unlockStarsRequired = 0` kullanılır.

Authoritative completion contract korunur:

`WordHuntRouteProgressEngine.isRouteComplete(...)`

Final bölümünün completion'ı rota completion için yeterlidir; ekstra yıldız threshold eklenmez.

Legacy/grandfather bypass eklenmez.

---

# SCORING — FINAL PRINCIPLE

## L5 challenge

3★:
- 0 hata
- **AND** `elapsedSeconds <= 3★ süre eşiği`

2★:
- `mistakes <= 1`
- **AND** `elapsedSeconds <= 2★ süre eşiği`

Target tamamlandı ama üst tier koşulları kaçtı:
- **1★**

Target tamamlanmadı:
- **0★**

## L10 routeFinal

3★:
- 0 hata
- **AND** `elapsedSeconds <= 3★ süre eşiği`

2★:
- `mistakes <= 2`
- **AND** `elapsedSeconds <= 2★ süre eşiği`

Target tamamlandı ama üst tier koşulları kaçtı:
- **1★**

Target tamamlanmadı:
- **0★**

## Ortak scoring contract

- mistake + time ilişkisi: **AND**
- boundary: **inclusive `<=`**
- `timeLimitSeconds`: **soft metadata**
- **HARD TIMEOUT YOK**

Exact saniyeler bu aşamada belirlenmez.

Aşağıdaki değerler deterministic grid üretimi ve difficulty audit sonrasında ayrı aşamada belirlenecek:
- L5 3★ seconds
- L5 2★ seconds
- L10 3★ seconds
- L10 2★ seconds

---

# REWARD CONTRACT

Her üç rota ayrı persistent reward taşır.

Mevcut reward sistemi korunur:

`routeComplete false → true`

transition'ı üzerinden reward grant edilir.

Yeni raster badge asset üretilmez. Material icon yaklaşımı kullanılır.

Schema değiştirilmez.

---

# TERMINAL CONTRACT

Güneş İmparatorluğu hedef production catalog'da 8. ve terminal rotadır.

Beklenen generic davranış:

`nextCatalogEntry(gunes-imparatorlugu) == null`

Bu durumda terminal copy exact:

**`Tüm mevcut rotaları tamamladın.`**

Kristal veya Güneş'e özel terminal branch eklenmez.

Catalog-driven generic next-route / terminal mimarisi korunur.

---

# HISTORICAL 5-ROUTE-COMPLETE USER CONTRACT

Mevcut beş production rotayı tamamlamış kullanıcı için Kayıp Şehir catalog'a eklendiğinde generic progression sonucu:

- **unlocked**
- **recommended**

olmalıdır.

Bunun için:
- özel migration yok,
- grandfather bypass yok,
- schema bump yok.

Progress schema:

**2**

olarak korunur.

## Historical “Yeni rota açıldı” reveal yönü

Implementation aşamasında historical reveal gerekiyorsa Kristal'e özel ikinci bir hard-code eklenmez.

Mevcut Kristal-specific reveal pattern'i **route-aware generic reveal** sistemine dönüştürme yönü kullanılır.

Requirements:
- route-aware
- one-time seen marker
- progress schema'dan ayrı
- normal completion ceremony ile duplicate mesaj yok
- mevcut kullanıcı progress'ini bozmaz
- schema 2 değişmez

Bu karar şu anda implementation görevi değildir; yalnız teknik contract'tır.

---

# EXISTING GENERIC ARCHITECTURE CONTRACT

Yeni üç rota mevcut generic architecture ile ilerlemelidir:

- catalog-driven route order
- `routeComplete` prerequisite unlock
- generic `WordHuntRouteProgressEngine.isRouteComplete(...)`
- catalog sırasına göre recommended rota
- persistent reward ID + reward catalog
- generic `nextCatalogEntry(...)`
- catalog-driven terminal behavior
- schema 2 progress payload

Route ID'ye özel progression/terminal hack eklenmez.

---

# AŞAMA 4 FINAL DURMA NOKTASI

AŞAMA 4 **FINAL / LOCKED**.

Henüz yapılmayacak:
- kod yazma
- grid üretme
- exact saniye belirleme
- asset üretme
- branch/PR açma
- implementation yapma

Bir sonraki owner aşaması:

**AŞAMA 5 — üç rotanın görsel kimliği + harita/node dili.**

Owner yeni prompt vermeden hiçbir sonraki aşamaya geçilmez.
