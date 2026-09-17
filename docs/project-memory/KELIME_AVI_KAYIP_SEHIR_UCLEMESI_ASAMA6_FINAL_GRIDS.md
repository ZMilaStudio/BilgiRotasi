# Kelime Avı — Kayıp Şehir Üçlemesi / AŞAMA 6 FINAL GRIDS

**Tarih:** 18 Eylül 2026  
**Durum:** FINAL / LOCKED  
**Kapsam:** 30 deterministic 8×8 grid + placement tabloları + exact-one physical occurrence validation

> Bu dosyadaki 30 literal grid AUTHORITATIVE DATASET’tir. Bundan sonra regenerate edilmez, başka seed ile yeniden üretilmez, filler/placement/kelime değiştirilmez. Implementation sırasında bu literal gridler birebir kullanılacaktır.

---

## KİLİTLİ ÖNCEKİ AŞAMALAR

- AŞAMA 1 FINAL: 30 bölüm adı + sahne omurgası
- AŞAMA 2 FINAL: 168 target + 42 bonus
- AŞAMA 3 FINAL: 18 info card
- AŞAMA 4 FINAL: route/unlock/reward/scoring/terminal contract
- AŞAMA 5 FINAL: görsel kimlik + harita + node dili
- AŞAMA 6 FINAL: deterministic grid dataset + exact-one validation

---

## FINAL VALIDATION CONTRACT

- 30/30 grid PASS
- 168/168 TARGET represented
- 42/42 BONUS represented
- 210/210 listed word usage represented
- 210/210 exact-one physical occurrence PASS
- Accidental second listed-word occurrence: 0
- Unresolved placement: 0
- Unresolved blocker: 0

### Unicode contract

Allowed uppercase characters:

A B C Ç D E F G Ğ H I İ J K L M N O Ö P R S Ş T U Ü V Y Z Â

- Â precomposed U+00C2 olarak kullanılır.
- A + combining circumflex kullanılmaz.
- Her grid hücresi exactly one Unicode code point/rune taşır.
- A != Â.
- Canonical normalization Â karakterini A’ya düşürmez.
- Â random filler olarak kullanılmaz.
- Final dataset içinde Â yalnız RÜZGÂR ve TEZGÂH intended placement path’lerinde bulunur.

### Nested/shared-path contract

Kayıp Şehir L2’de KUM, KUMUL path’inin ilk üç hücresini paylaşır.

- KUM occurrence count = 1
- KUMUL occurrence count = 1

Bu davranış production gameplay engine ile uyumludur.

---

# 6. KAYIP ŞEHİR

## L1 — Kervan İzi

LEVEL ID: kayip-sehir-01

GRID:

~~~text
YÜKSRKSS
SÜVESOMU
TİCARETN
NÇAENVFA
AUIZDKAM
JLİZLERN
LLCLERJN
BUARİĞIJ
~~~

| WORD | TYPE | START | END | DIR | OCCURRENCE COUNT |
|---|---|---|---|---|---:|
| KERVAN | TARGET | R1C3 | R6C8 | SE | 1 |
| İZLER | TARGET | R6C3 | R6C7 | E | 1 |
| ROTA | TARGET | R1C5 | R4C8 | SE | 1 |
| YÜK | TARGET | R1C1 | R1C3 | E | 1 |
| MENZİL | TARGET | R2C7 | R7C2 | SW | 1 |
| TİCARET | BONUS | R3C1 | R3C7 | E | 1 |

- target count: 5
- bonus count: 1
- grid size: 8×8
- overlap count: 5
- direction distribution: E:3, SE:2, SW:1
- nested/shared path: yok
- exact-one: PASS

## L2 — Sessiz Kumlar

LEVEL ID: kayip-sehir-02

GRID:

~~~text
TŞÖYEZÜY
MYRURNÜA
BBUÜOÜİJ
KÜÖNZYKŞ
IUBCYGHT
ZAMYOFÂO
ĞRKUNÜFR
DÜOGLTUS
~~~

| WORD | TYPE | START | END | DIR | OCCURRENCE COUNT |
|---|---|---|---|---|---:|
| KUM | TARGET | R4C1 | R6C3 | SE | 1 |
| KUMUL | TARGET | R4C1 | R8C5 | SE | 1 |
| RÜZGÂR | TARGET | R2C3 | R7C8 | SE | 1 |
| OYMA | TARGET | R6C5 | R6C2 | W | 1 |
| YÜZEY | TARGET | R1C8 | R1C4 | W | 1 |
| EROZYON | BONUS | R1C5 | R7C5 | S | 1 |

- target count: 5
- bonus count: 1
- grid size: 8×8
- overlap count: 6
- direction distribution: SE:3, S:1, W:2
- nested/shared path: KUM = KUMUL path’inin ilk 3 hücresi; ayrı KUM placement yok
- RÜZGÂR içindeki Â = U+00C2
- exact-one: PASS

## L3 — Gömülü Cephe

LEVEL ID: kayip-sehir-03

GRID:

~~~text
EHPECÜLJ
OGİDIKAU
AINUTÜSS
LGÇVNZBP
MPDAICŞĞ
IGÇRLÜTÇ
FÜİRAMİM
REMEKZĞU
~~~

| WORD | TYPE | START | END | DIR | OCCURRENCE COUNT |
|---|---|---|---|---|---:|
| CEPHE | TARGET | R1C5 | R1C1 | W | 1 |
| SÜTUN | TARGET | R3C7 | R3C3 | W | 1 |
| KEMER | TARGET | R8C5 | R8C1 | W | 1 |
| DUVAR | TARGET | R2C4 | R6C4 | S | 1 |
| KALINTI | TARGET | R8C5 | R2C5 | N | 1 |
| MİMARİ | BONUS | R7C8 | R7C3 | W | 1 |

- target count: 5
- bonus count: 1
- grid size: 8×8
- overlap count: 4
- direction distribution: N:1, S:1, W:4
- exact-one: PASS

## L4 — Eski Kapı

LEVEL ID: kayip-sehir-04

GRID:

~~~text
KTİÇEGOS
AHVELİUÖ
PYTLŞRİS
IĞIUEİFÜ
PAŞKBŞKH
FMAÇPNMH
ÜPLLĞGÇÇ
JCUDEÜFO
~~~

| WORD | TYPE | START | END | DIR | OCCURRENCE COUNT |
|---|---|---|---|---|---:|
| KAPI | TARGET | R1C1 | R4C1 | S | 1 |
| EŞİK | TARGET | R2C4 | R5C7 | SE | 1 |
| SUR | TARGET | R1C8 | R3C6 | SW | 1 |
| LEVHA | TARGET | R2C5 | R2C1 | W | 1 |
| KULE | TARGET | R5C4 | R2C4 | N | 1 |
| GEÇİT | BONUS | R1C6 | R1C2 | W | 1 |
| GİRİŞ | BONUS | R1C6 | R5C6 | S | 1 |

- target count: 5
- bonus count: 2
- grid size: 8×8
- overlap count: 5
- direction distribution: N:1, SE:1, S:2, SW:1, W:2
- exact-one: PASS

## L5 — Fırtına Geçidi ⚡

LEVEL ID: kayip-sehir-05

GRID:

~~~text
HÜŞFLISD
EFIRTINA
DTOIĞMLŞ
EEJICURŞ
FRNİSTÜK
HAPURRTG
KŞPHÖOUR
OİEGZHIJ
~~~

| WORD | TYPE | START | END | DIR | OCCURRENCE COUNT |
|---|---|---|---|---|---:|
| FIRTINA | TARGET | R2C2 | R2C8 | E | 1 |
| PUSULA | TARGET | R7C3 | R2C8 | NE | 1 |
| GÖRÜŞ | TARGET | R8C4 | R4C8 | NE | 1 |
| HEDEF | TARGET | R1C1 | R5C1 | S | 1 |
| SIĞINAK | TARGET | R1C7 | R7C1 | SW | 1 |
| İŞARET | TARGET | R8C2 | R3C2 | N | 1 |
| TOZ | BONUS | R6C7 | R8C5 | SW | 1 |
| HORTUM | BONUS | R8C6 | R3C6 | N | 1 |

- target count: 6
- bonus count: 2
- grid size: 8×8
- overlap count: 6
- direction distribution: N:2, NE:2, E:1, S:1, SW:2
- exact-one: PASS

## L6 — Unutulmuş Çarşı

LEVEL ID: kayip-sehir-06

GRID:

~~~text
MZŞĞÜPMD
ŞIHHNSTL
İŞIAMEÜR
BRONZRCS
CAEGFACN
EÇÂKUMAŞ
LHHYPİRV
PADYNKZM
~~~

| WORD | TYPE | START | END | DIR | OCCURRENCE COUNT |
|---|---|---|---|---|---:|
| ÇARŞI | TARGET | R6C2 | R2C2 | N | 1 |
| TEZGÂH | TARGET | R2C7 | R7C2 | SW | 1 |
| TÜCCAR | TARGET | R2C7 | R7C7 | S | 1 |
| BRONZ | TARGET | R4C1 | R4C5 | E | 1 |
| KUMAŞ | TARGET | R6C4 | R6C8 | E | 1 |
| SERAMİK | BONUS | R2C6 | R8C6 | S | 1 |

- target count: 5
- bonus count: 1
- grid size: 8×8
- overlap count: 6
- direction distribution: N:1, E:2, S:2, SW:1
- TEZGÂH içindeki Â = U+00C2
- exact-one: PASS

## L7 — Sütunlu Avlu

LEVEL ID: kayip-sehir-07

GRID:

~~~text
İJAUNSTO
ŞJZAKAZÜ
LAUKEÇYU
EUJKRAAU
MOZAİKLF
EOŞVDVDH
LKZEACID
ICMRCIZS
~~~

| WORD | TYPE | START | END | DIR | OCCURRENCE COUNT |
|---|---|---|---|---|---:|
| AVLU | TARGET | R7C5 | R4C8 | NE | 1 |
| REVAK | TARGET | R8C4 | R4C4 | N | 1 |
| DİREK | TARGET | R6C5 | R2C5 | N | 1 |
| SAÇAK | TARGET | R1C6 | R5C6 | S | 1 |
| İŞLEME | TARGET | R1C1 | R6C1 | S | 1 |
| MOZAİK | TARGET | R5C1 | R5C6 | E | 1 |
| YALDIZ | BONUS | R3C7 | R8C7 | S | 1 |

- target count: 6
- bonus count: 1
- grid size: 8×8
- overlap count: 5
- direction distribution: N:2, NE:1, E:1, S:3
- exact-one: PASS

## L8 — Kurumuş Sarnıç

LEVEL ID: kayip-sehir-08

GRID:

~~~text
ÜVMBZRAE
ÜTSKULOĞ
ZPOAUBNG
ÇĞÇRRYDS
ZAAUTNUĞ
DRRKAUIG
KMFLIÇVÇ
RNNHLŞİÇ
~~~

| WORD | TYPE | START | END | DIR | OCCURRENCE COUNT |
|---|---|---|---|---|---:|
| SARNIÇ | TARGET | R2C3 | R7C8 | SE | 1 |
| ARK | TARGET | R5C3 | R7C1 | SW | 1 |
| AKIŞ | TARGET | R5C3 | R8C6 | SE | 1 |
| KUYU | TARGET | R2C4 | R5C7 | SE | 1 |
| OLUK | TARGET | R2C7 | R2C4 | W | 1 |
| TORTU | TARGET | R2C2 | R6C6 | SE | 1 |
| KURAK | BONUS | R6C4 | R2C4 | N | 1 |

- target count: 6
- bonus count: 1
- grid size: 8×8
- overlap count: 5
- direction distribution: N:1, SE:4, SW:1, W:1
- exact-one: PASS

## L9 — Kırık Saray

LEVEL ID: kayip-sehir-09

GRID:

~~~text
JRFRESKG
BYUTEBAM
RPMYFLBİ
ADOAETAN
EATRRMRŞ
ÇMİAMBTT
DGFSAMMŞ
PAİBNVAO
~~~

| WORD | TYPE | START | END | DIR | OCCURRENCE COUNT |
|---|---|---|---|---|---:|
| SARAY | TARGET | R7C4 | R3C4 | N | 1 |
| MOTİF | TARGET | R3C3 | R7C3 | S | 1 |
| KABARTMA | TARGET | R1C7 | R8C7 | S | 1 |
| DAMGA | TARGET | R4C2 | R8C2 | S | 1 |
| GALERİ | TARGET | R1C8 | R6C3 | SW | 1 |
| MABET | TARGET | R2C8 | R2C4 | W | 1 |
| FRESK | BONUS | R1C3 | R1C7 | E | 1 |
| FERMAN | BONUS | R3C5 | R8C5 | S | 1 |

- target count: 6
- bonus count: 2
- grid size: 8×8
- overlap count: 5
- direction distribution: N:1, E:1, S:4, SW:1, W:1
- exact-one: PASS

## L10 — Yeraltı Mührü 👑

LEVEL ID: kayip-sehir-10

GRID:

~~~text
ÇŞDCNJTY
IŞİYESIR
ÇTDNVLCA
ESLNİODT
MÜÇADBUH
BRKFRMLA
EGAEEEHN
RÜHÜMSYA
~~~

| WORD | TYPE | START | END | DIR | OCCURRENCE COUNT |
|---|---|---|---|---|---:|
| MÜHÜR | TARGET | R8C5 | R8C1 | W | 1 |
| SEMBOL | TARGET | R8C6 | R3C6 | N | 1 |
| SÜRGÜ | TARGET | R4C2 | R8C2 | S | 1 |
| ÇEMBER | TARGET | R3C1 | R8C1 | S | 1 |
| MERDİVEN | TARGET | R8C5 | R1C5 | N | 1 |
| YERALTI | TARGET | R8C7 | R2C1 | NW | 1 |
| SIR | TARGET | R2C6 | R2C8 | E | 1 |
| ANAHTAR | BONUS | R8C8 | R2C8 | N | 1 |
| İNİŞ | BONUS | R4C5 | R1C2 | NW | 1 |

- target count: 7
- bonus count: 2
- grid size: 8×8
- overlap count: 7
- direction distribution: N:3, E:1, S:2, W:1, NW:2
- exact-one: PASS

## Kayıp Şehir route validation

- 10/10 grid generated
- 56/56 target represented
- 14/14 bonus represented
- exact-one validator: 70/70 PASS
- accidental listed-word second occurrence: 0
- shared-cell overlap total: 54
- short-word audit: ARK = 1
- 8-letter audit:
  - KABARTMA — R1C7→R8C7 S — 1
  - MERDİVEN — R8C5→R1C5 N — 1
- Â audit:
  - RÜZGÂR exact canonical U+00C2 — 1
  - TEZGÂH exact canonical U+00C2 — 1
  - filler Â = 0

---

# 7. YERALTI KRALLIĞI

## L1 — Gizli İniş

LEVEL ID: yeralti-kralligi-01

GRID:

~~~text
GJZİNİŞU
YMFİRÜAJ
TKRULOME
UEUEBHLM
DBGLGAEE
CAFFŞMFD
VĞEEÇOEA
VSMAĞFLK
~~~

| WORD | TYPE | START | END | DIR | OCCURRENCE COUNT |
|---|---|---|---|---|---:|
| İNİŞ | TARGET | R1C4 | R1C7 | E | 1 |
| DEHLİZ | TARGET | R6C8 | R1C3 | NW | 1 |
| DERİN | TARGET | R5C1 | R1C5 | NE | 1 |
| MEŞALE | TARGET | R8C3 | R3C8 | NE | 1 |
| KADEME | TARGET | R8C8 | R3C8 | N | 1 |
| LOŞLUK | BONUS | R8C7 | R3C2 | NW | 1 |

- target count: 5
- bonus count: 1
- grid size: 8×8
- overlap count: 5
- direction distribution: N:1, NE:2, E:1, NW:2
- exact-one: PASS

## L2 — Taş Damarlar

LEVEL ID: yeralti-kralligi-02

GRID:

~~~text
YPÖRCİRÜ
KNĞNCBÖÇ
DÖSYPCŞZ
ZAKTÜNEL
AHMUİBBJ
CLKAYAEK
RODİROKK
DHİTMDEK
~~~

| WORD | TYPE | START | END | DIR | OCCURRENCE COUNT |
|---|---|---|---|---|---:|
| TÜNEL | TARGET | R4C4 | R4C8 | E | 1 |
| ŞEBEKE | TARGET | R3C7 | R8C7 | S | 1 |
| OYUK | TARGET | R7C6 | R4C3 | NW | 1 |
| KAYA | TARGET | R6C3 | R6C6 | E | 1 |
| DAMAR | TARGET | R3C1 | R7C5 | SE | 1 |
| KORİDOR | BONUS | R7C7 | R7C1 | W | 1 |

- target count: 5
- bonus count: 1
- grid size: 8×8
- overlap count: 6
- direction distribution: E:2, SE:1, S:1, W:1, NW:1
- exact-one: PASS

## L3 — Derin Sarnıç

LEVEL ID: yeralti-kralligi-03

GRID:

~~~text
TBOĞAEOJ
UZAZSBÇT
HAÇOİACİ
AKINTIGL
ZANOJBHI
NVRTİPFZ
EAAPAYEO
CSSSSZOF
~~~

| WORD | TYPE | START | END | DIR | OCCURRENCE COUNT |
|---|---|---|---|---|---:|
| SARNIÇ | TARGET | R8C3 | R3C3 | N | 1 |
| AKINTI | TARGET | R4C1 | R4C6 | E | 1 |
| TONOZ | TARGET | R6C4 | R2C4 | N | 1 |
| PAYE | TARGET | R7C4 | R7C7 | E | 1 |
| HAZNE | TARGET | R3C1 | R7C1 | S | 1 |
| SAVAK | BONUS | R8C2 | R4C2 | N | 1 |

- target count: 5
- bonus count: 1
- grid size: 8×8
- overlap count: 4
- direction distribution: N:3, E:2, S:1
- exact-one: PASS

## L4 — Bakır Kanallar

LEVEL ID: yeralti-kralligi-04

GRID:

~~~text
IDŞÖACBK
LPPMĞNZK
DAJİBUAM
AÖCTUNUV
DSÖEAEKU
MDBLCHRD
ĞYGİOOUV
RIKABZTR
~~~

| WORD | TYPE | START | END | DIR | OCCURRENCE COUNT |
|---|---|---|---|---|---:|
| BAKIR | TARGET | R8C5 | R8C1 | W | 1 |
| KANAL | TARGET | R2C8 | R6C4 | SW | 1 |
| HAT | TARGET | R6C6 | R4C4 | NW | 1 |
| VANA | TARGET | R4C8 | R1C5 | NW | 1 |
| BORU | TARGET | R8C5 | R5C8 | NE | 1 |
| İLETİM | BONUS | R7C4 | R2C4 | N | 1 |
| TURKUAZ | BONUS | R8C7 | R2C7 | N | 1 |

- target count: 5
- bonus count: 2
- grid size: 8×8
- overlap count: 6
- direction distribution: N:2, NE:1, SW:1, W:1, NW:2
- exact-one: PASS

## L5 — Halka Kilidi ⚡

LEVEL ID: yeralti-kralligi-05

GRID:

~~~text
SIRAKLAH
YÖKYEKİİ
NKİTNEÇH
ŞİFREÖUH
PLHIZĞMO
ĞİIŞÜNÖD
ITMPDBDZ
IÜEHKBUU
~~~

| WORD | TYPE | START | END | DIR | OCCURRENCE COUNT |
|---|---|---|---|---|---:|
| HALKA | TARGET | R1C8 | R1C4 | W | 1 |
| KİLİT | TARGET | R3C2 | R7C2 | S | 1 |
| DÜZENEK | TARGET | R7C5 | R1C5 | N | 1 |
| ŞİFRE | TARGET | R4C1 | R4C5 | E | 1 |
| DÖNÜŞ | TARGET | R6C8 | R6C4 | W | 1 |
| SIRA | TARGET | R1C1 | R1C4 | E | 1 |
| ÇENTİK | BONUS | R3C7 | R3C2 | W | 1 |
| PİM | BONUS | R5C1 | R7C3 | SE | 1 |

- target count: 6
- bonus count: 2
- grid size: 8×8
- overlap count: 8
- direction distribution: N:1, E:2, SE:1, S:1, W:3
- exact-one: PASS

## L6 — Taş Mekanizma

LEVEL ID: yeralti-kralligi-06

GRID:

~~~text
VOKĞRÇOC
SSOAFCVJ
LMLĞNHAR
ĞİZIDSBD
MHARAKAM
VVBLŞĞYK
JEJIŞRCD
MRİKMEUÇ
~~~

| WORD | TYPE | START | END | DIR | OCCURRENCE COUNT |
|---|---|---|---|---|---:|
| KASNAK | TARGET | R6C8 | R1C3 | NW | 1 |
| MİL | TARGET | R5C1 | R3C3 | NE | 1 |
| KOL | TARGET | R1C3 | R3C3 | S | 1 |
| AĞIRLIK | TARGET | R2C4 | R8C4 | S | 1 |
| MİHVER | TARGET | R3C2 | R8C2 | S | 1 |
| MAKARA | BONUS | R5C8 | R5C3 | W | 1 |

- target count: 5
- bonus count: 1
- grid size: 8×8
- overlap count: 6
- direction distribution: NE:1, S:3, W:1, NW:1
- exact-one: PASS

## L7 — Gömülü Salon

LEVEL ID: yeralti-kralligi-07

GRID:

~~~text
YİVZHĞÇİ
FÇĞEMNSM
RLYACMİA
IEKÜRSÜZ
TAEKABUL
MTZRCJÇA
ŞMELBMAO
LMİUTGİR
~~~

| WORD | TYPE | START | END | DIR | OCCURRENCE COUNT |
|---|---|---|---|---|---:|
| KABUL | TARGET | R5C4 | R5C8 | E | 1 |
| MERASİM | TARGET | R8C2 | R2C8 | NE | 1 |
| AMBLEM | TARGET | R7C7 | R7C2 | W | 1 |
| MAKAM | TARGET | R2C5 | R6C1 | SW | 1 |
| KÜRSÜ | TARGET | R4C3 | R4C7 | E | 1 |
| HEYET | TARGET | R1C5 | R5C1 | SW | 1 |
| ELÇİ | BONUS | R4C2 | R1C2 | N | 1 |

- target count: 6
- bonus count: 1
- grid size: 8×8
- overlap count: 5
- direction distribution: N:1, NE:1, E:2, SW:2, W:1
- exact-one: PASS

## L8 — Anıt Odası

LEVEL ID: yeralti-kralligi-08

GRID:

~~~text
BCĞHLBYT
KOTKMŞEİ
PİBTARİH
SUTNOYPT
TIZAYCIG
EGLEBNÖT
ÜAYŞAEAV
MEYİÜŞÜB
~~~

| WORD | TYPE | START | END | DIR | OCCURRENCE COUNT |
|---|---|---|---|---|---:|
| ANIT | TARGET | R7C5 | R4C8 | NE | 1 |
| KİTABE | TARGET | R2C1 | R7C6 | SE | 1 |
| YAZIT | TARGET | R5C5 | R5C1 | W | 1 |
| YONTU | TARGET | R4C6 | R4C2 | W | 1 |
| TARİH | TARGET | R3C4 | R3C8 | E | 1 |
| BELGE | TARGET | R6C5 | R6C1 | W | 1 |
| KAYIT | BONUS | R2C4 | R6C8 | SE | 1 |

- target count: 6
- bonus count: 1
- grid size: 8×8
- overlap count: 6
- direction distribution: NE:1, E:1, SE:2, W:3
- exact-one: PASS

## L9 — Kraliyet Hazinesi

LEVEL ID: yeralti-kralligi-09

GRID:

~~~text
GYBİLGİZ
ÜKIDNASL
KEÇLÖAPT
HAZİNEEZ
USTURLAP
ORGGBJIP
ŞĞEAÇBUI
ALTINJEO
~~~

| WORD | TYPE | START | END | DIR | OCCURRENCE COUNT |
|---|---|---|---|---|---:|
| HAZİNE | TARGET | R4C1 | R4C6 | E | 1 |
| ALTIN | TARGET | R8C1 | R8C5 | E | 1 |
| TABLET | TARGET | R8C3 | R3C8 | NE | 1 |
| PERGEL | TARGET | R3C7 | R8C2 | SW | 1 |
| USTURLAP | TARGET | R5C1 | R5C8 | E | 1 |
| ÖLÇEK | TARGET | R3C5 | R3C1 | W | 1 |
| BİLGİ | BONUS | R1C3 | R1C7 | E | 1 |
| SANDIK | BONUS | R2C7 | R2C2 | W | 1 |

- target count: 6
- bonus count: 2
- grid size: 8×8
- overlap count: 5
- direction distribution: NE:1, E:4, SW:1, W:2
- exact-one: PASS

## L10 — Göksel Mühür 👑

LEVEL ID: yeralti-kralligi-10

GRID:

~~~text
GÖVŞGKPM
ÜÖUĞODÜU
NNKZTHAN
EBASÜTEO
ŞÇVREUŞK
ÖUZIDLIY
MBURÇAPF
BİPUCUKĞ
~~~

| WORD | TYPE | START | END | DIR | OCCURRENCE COUNT |
|---|---|---|---|---|---:|
| GÖKSEL | TARGET | R1C1 | R6C6 | SE | 1 |
| MÜHÜR | TARGET | R1C8 | R5C4 | SW | 1 |
| GÜNEŞ | TARGET | R1C1 | R5C1 | S | 1 |
| DOĞU | TARGET | R2C6 | R2C3 | W | 1 |
| BURÇ | TARGET | R7C2 | R7C5 | E | 1 |
| KONUM | TARGET | R5C8 | R1C8 | N | 1 |
| YILDIZ | TARGET | R6C8 | R6C3 | W | 1 |
| İPUCU | BONUS | R8C2 | R8C6 | E | 1 |
| KADRAN | BONUS | R8C7 | R3C2 | NW | 1 |

- target count: 7
- bonus count: 2
- grid size: 8×8
- overlap count: 5
- direction distribution: N:1, E:2, SE:1, S:1, SW:1, W:2, NW:1
- exact-one: PASS

## Yeraltı Krallığı route validation

- 10/10 grid generated
- 56/56 target represented
- 14/14 bonus represented
- exact-one validator: 70/70 PASS
- accidental listed-word second occurrence: 0
- shared-cell overlap total: 56
- short-word audit:
  - HAT = 1
  - PİM = 1
  - MİL = 1
  - KOL = 1
- 8-letter audit:
  - USTURLAP — R5C1→R5C8 E — 1

---

# 8. GÜNEŞ İMPARATORLUĞU

## L1 — Işık Yolu

LEVEL ID: gunes-imparatorlugu-01

GRID:

~~~text
DHMKHÖNK
LKEYDMEU
IÖUGFÖUL
ŞATSĞKGF
AUJUBJZY
FUFĞİÖIO
AURZLKGL
KIŞINUGF
~~~

| WORD | TYPE | START | END | DIR | OCCURRENCE COUNT |
|---|---|---|---|---|---:|
| IŞIK | TARGET | R8C4 | R8C1 | W | 1 |
| YOL | TARGET | R5C8 | R7C8 | S | 1 |
| ŞAFAK | TARGET | R4C1 | R8C1 | S | 1 |
| UFUK | TARGET | R5C4 | R8C1 | SW | 1 |
| TAŞ | TARGET | R4C3 | R4C1 | W | 1 |
| IŞIN | BONUS | R8C2 | R8C5 | E | 1 |

- target count: 5
- bonus count: 1
- grid size: 8×8
- overlap count: 5
- direction distribution: E:1, S:2, SW:1, W:2
- exact-one: PASS

## L2 — Güneş Sütunları

LEVEL ID: gunes-imparatorlugu-02

GRID:

~~~text
ABOMGSCJ
RJBZVÜZI
YGSAATTH
FÖSZDUÖC
TLNMONAR
DGMÜAZKE
KERBİHMH
ÜLYHÇÇCF
~~~

| WORD | TYPE | START | END | DIR | OCCURRENCE COUNT |
|---|---|---|---|---|---:|
| SÜTUN | TARGET | R1C6 | R5C6 | S | 1 |
| GÖLGE | TARGET | R3C2 | R7C2 | S | 1 |
| YÖN | TARGET | R3C1 | R5C3 | SE | 1 |
| HİZA | TARGET | R8C4 | R5C7 | NE | 1 |
| SAAT | TARGET | R3C3 | R3C6 | E | 1 |
| İBRE | BONUS | R7C5 | R7C2 | W | 1 |

- target count: 5
- bonus count: 1
- grid size: 8×8
- overlap count: 4
- direction distribution: NE:1, E:1, SE:1, S:2, W:1
- exact-one: PASS

## L3 — Gökyüzü Avlusu

LEVEL ID: gunes-imparatorlugu-03

GRID:

~~~text
HŞZGJDÜU
İHYEOOÜZ
İNHZYHZI
KASENUÜD
ÖDİGMIYL
PYMEUPKI
ŞEGNÜRÖY
GMEJZGGB
~~~

| WORD | TYPE | START | END | DIR | OCCURRENCE COUNT |
|---|---|---|---|---|---:|
| GÖKYÜZÜ | TARGET | R8C7 | R2C7 | N | 1 |
| YILDIZ | TARGET | R7C8 | R2C8 | N | 1 |
| GEZEGEN | TARGET | R1C4 | R7C4 | S | 1 |
| MEYDAN | TARGET | R8C2 | R3C2 | N | 1 |
| YÖRÜNGE | TARGET | R7C8 | R7C2 | W | 1 |
| SİMGE | BONUS | R4C3 | R8C3 | S | 1 |

- target count: 5
- bonus count: 1
- grid size: 8×8
- overlap count: 5
- direction distribution: N:3, S:2, W:1
- exact-one: PASS

## L4 — Yıldız Haritası

LEVEL ID: gunes-imparatorlugu-04

GRID:

~~~text
ÖPUTUKLH
RNRGİÜAM
TRGKJRZŞ
AÖNÖİEFI
KVKTZMİT
ILATFLÇU
MERİDYEN
GGAFHIÇM
~~~

| WORD | TYPE | START | END | DIR | OCCURRENCE COUNT |
|---|---|---|---|---|---:|
| HARİTA | TARGET | R1C8 | R6C3 | SW | 1 |
| TAKIM | TARGET | R3C1 | R7C1 | S | 1 |
| KUTUP | TARGET | R1C6 | R1C2 | W | 1 |
| GÖZLEM | TARGET | R3C3 | R8C8 | SE | 1 |
| GÖK | TARGET | R3C3 | R5C1 | SW | 1 |
| KÜRE | BONUS | R1C6 | R4C6 | S | 1 |
| MERİDYEN | BONUS | R7C1 | R7C8 | E | 1 |

- target count: 5
- bonus count: 2
- grid size: 8×8
- overlap count: 6
- direction distribution: E:1, SE:1, S:2, SW:2, W:1
- exact-one: PASS

## L5 — Ekinoks Kapısı ⚡

LEVEL ID: gunes-imparatorlugu-05

GRID:

~~~text
INÇNYTDE
TAYNAEEK
ODAKNFIİ
JÖAGSRİN
ŞLEIIRIO
PZNLMÇCK
NJMGAZLS
TARGTKUA
~~~

| WORD | TYPE | START | END | DIR | OCCURRENCE COUNT |
|---|---|---|---|---|---:|
| EKİNOKS | TARGET | R1C8 | R7C8 | S | 1 |
| AYNA | TARGET | R2C2 | R2C5 | E | 1 |
| YANSIMA | TARGET | R1C5 | R7C5 | S | 1 |
| AÇI | TARGET | R7C5 | R5C7 | NE | 1 |
| DENGE | TARGET | R1C7 | R5C3 | SW | 1 |
| ODAK | TARGET | R3C1 | R3C4 | E | 1 |
| PLAKA | BONUS | R6C1 | R2C5 | NE | 1 |
| KIRILMA | BONUS | R2C8 | R8C2 | SW | 1 |

- target count: 6
- bonus count: 2
- grid size: 8×8
- overlap count: 6
- direction distribution: NE:2, E:2, S:2, SW:2
- exact-one: PASS

## L6 — Tören Yolu

LEVEL ID: gunes-imparatorlugu-06

GRID:

~~~text
ŞLYZAÜJÜ
ÇBVLEOVÖ
MKACNASÜ
SYOEAHSJ
OÇRÜŞDTZ
TÖBTİÇIT
TLIÜNHBM
ĞYKIZILB
~~~

| WORD | TYPE | START | END | DIR | OCCURRENCE COUNT |
|---|---|---|---|---|---:|
| TÖREN | TARGET | R7C1 | R3C5 | NE | 1 |
| ALAY | TARGET | R1C5 | R4C2 | SW | 1 |
| KIZIL | TARGET | R8C3 | R8C7 | E | 1 |
| SANCAK | TARGET | R3C7 | R3C2 | W | 1 |
| ADIM | TARGET | R4C5 | R7C8 | SE | 1 |
| NİŞAN | BONUS | R7C5 | R3C5 | N | 1 |

- target count: 5
- bonus count: 1
- grid size: 8×8
- overlap count: 3
- direction distribution: N:1, NE:1, E:1, SE:1, SW:1, W:1
- exact-one: PASS

## L7 — Büyük Tapınak

LEVEL ID: gunes-imparatorlugu-07

GRID:

~~~text
TULRŞSBP
AGVAAAPO
PEMKSZMR
IDVAETKT
NİMNİRUİ
AAKUKBBK
KKRSMMBÖ
NIYAİVEV
~~~

| WORD | TYPE | START | END | DIR | OCCURRENCE COUNT |
|---|---|---|---|---|---:|
| TAPINAK | TARGET | R1C1 | R7C1 | S | 1 |
| SUNAK | TARGET | R7C4 | R3C4 | N | 1 |
| BASAMAK | TARGET | R1C7 | R7C1 | SW | 1 |
| KUBBE | TARGET | R4C7 | R8C7 | S | 1 |
| KUTSAL | TARGET | R6C8 | R1C3 | NW | 1 |
| PORTİK | TARGET | R1C8 | R6C8 | S | 1 |
| KAİDE | BONUS | R7C2 | R3C2 | N | 1 |

- target count: 6
- bonus count: 1
- grid size: 8×8
- overlap count: 6
- direction distribution: N:2, S:3, SW:1, NW:1
- exact-one: PASS

## L8 — Altın Çarklar

LEVEL ID: gunes-imparatorlugu-08

GRID:

~~~text
VBİHIİPJ
YÜKRFÜYM
ÇGPRRLIİ
ÇNAMAZİS
IÖEEİÇLV
YDJSKYŞE
ĞBTAKVİM
PŞJEIEDĞ
~~~

| WORD | TYPE | START | END | DIR | OCCURRENCE COUNT |
|---|---|---|---|---|---:|
| ÇARK | TARGET | R5C6 | R2C3 | NW | 1 |
| TAKVİM | TARGET | R7C3 | R7C8 | E | 1 |
| DİŞLİ | TARGET | R8C7 | R4C7 | N | 1 |
| EKSEN | TARGET | R8C6 | R4C2 | NW | 1 |
| DÖNGÜ | TARGET | R6C2 | R2C2 | N | 1 |
| MEVSİM | TARGET | R7C8 | R2C8 | N | 1 |
| ZAMAN | BONUS | R4C6 | R4C2 | W | 1 |

- target count: 6
- bonus count: 1
- grid size: 8×8
- overlap count: 5
- direction distribution: N:3, E:1, W:1, NW:2
- exact-one: PASS

## L9 — Kraliyet Salonu

LEVEL ID: gunes-imparatorlugu-09

GRID:

~~~text
TBNHZNTS
EGAÜLTAÇ
YÖDKLRNÜ
İKEÜİNAL
LTNMPOTS
AİADÜLLP
RLHAZAAÜ
KAMRASSA
~~~

| WORD | TYPE | START | END | DIR | OCCURRENCE COUNT |
|---|---|---|---|---|---:|
| KRALİYET | TARGET | R8C1 | R1C1 | N | 1 |
| ARMA | TARGET | R8C5 | R8C2 | W | 1 |
| SALTANAT | TARGET | R8C7 | R1C7 | N | 1 |
| MİRAS | TARGET | R5C4 | R1C8 | NE | 1 |
| HÜKÜMDAR | TARGET | R1C4 | R8C4 | S | 1 |
| SALON | TARGET | R8C6 | R4C6 | N | 1 |
| HANEDAN | BONUS | R7C3 | R1C3 | N | 1 |
| TAÇ | BONUS | R2C6 | R2C8 | E | 1 |

- target count: 6
- bonus count: 2
- grid size: 8×8
- overlap count: 3
- direction distribution: N:4, NE:1, E:1, S:1, W:1
- exact-one: PASS

## L10 — Güneş Tahtı 👑

LEVEL ID: gunes-imparatorlugu-10

GRID:

~~~text
HFTAHTÇU
MLÇFÜGYI
KEŞĞÜGÇT
ÖLKNAÖUL
KMERKEZI
EŞLYÖSMŞ
NITLAGDI
KİLRİBIF
~~~

| WORD | TYPE | START | END | DIR | OCCURRENCE COUNT |
|---|---|---|---|---|---:|
| GÜNEŞ | TARGET | R2C6 | R6C2 | SW | 1 |
| TAHT | TARGET | R1C3 | R1C6 | E | 1 |
| UYGARLIK | TARGET | R1C8 | R8C1 | SW | 1 |
| BİRLİK | TARGET | R8C6 | R8C1 | W | 1 |
| MERKEZ | TARGET | R5C2 | R5C7 | E | 1 |
| GÖRKEM | TARGET | R7C6 | R2C1 | NW | 1 |
| KÖKEN | TARGET | R3C1 | R7C1 | S | 1 |
| IŞILTI | BONUS | R7C8 | R2C8 | N | 1 |
| ALTIN | BONUS | R7C5 | R7C1 | W | 1 |

- target count: 7
- bonus count: 2
- grid size: 8×8
- overlap count: 5
- direction distribution: N:1, E:2, S:1, SW:2, W:2, NW:1
- exact-one: PASS

## Güneş İmparatorluğu route validation

- 10/10 grid generated
- 56/56 target represented
- 14/14 bonus represented
- exact-one validator: 70/70 PASS
- accidental listed-word second occurrence: 0
- shared-cell overlap total: 48
- short-word audit:
  - YOL = 1
  - TAŞ = 1
  - GÖK = 1
  - TAÇ = 1
- 8-letter audit:
  - MERİDYEN — R7C1→R7C8 E — 1
  - KRALİYET — R8C1→R1C1 N — 1
  - SALTANAT — R8C7→R1C7 N — 1
  - HÜKÜMDAR — R1C4→R8C4 S — 1
  - UYGARLIK — R1C8→R8C1 SW — 1

---

# TRILOGY FINAL VALIDATION

## Totals

- grids: 30/30
- target represented: 168/168
- bonus represented: 42/42
- listed usages represented: 210/210
- exact-one physical occurrence: 210/210 PASS
- unresolved placement: 0
- accidental second listed-word occurrence: 0
- unresolved blocker: 0

## Special mandatory validation

| WORD | LEVEL | RESULT |
|---|---|---|
| RÜZGÂR | kayip-sehir-02 | exact canonical Â U+00C2, OCC=1 |
| TEZGÂH | kayip-sehir-06 | exact canonical Â U+00C2, OCC=1 |
| KUM | kayip-sehir-02 | OCC=1 |
| KUMUL | kayip-sehir-02 | OCC=1 |

Gridlerin tamamı NFC/precomposed Unicode contract’ına uygundur. Her hücre exactly one Unicode code point/rune taşır. Â filler kullanımı 0’dır.

## Short-word audit

Özel audit edilen kelimelerin tamamında occurrence count = 1:

- ARK
- HAT
- MİL
- KOL
- PİM
- YOL
- TAŞ
- GÖK
- TAÇ

## 8-letter audit

| WORD | LEVEL | PATH | OCC |
|---|---|---|---:|
| KABARTMA | kayip-sehir-09 | R1C7→R8C7 S | 1 |
| MERDİVEN | kayip-sehir-10 | R8C5→R1C5 N | 1 |
| USTURLAP | yeralti-kralligi-09 | R5C1→R5C8 E | 1 |
| MERİDYEN | gunes-imparatorlugu-04 | R7C1→R7C8 E | 1 |
| KRALİYET | gunes-imparatorlugu-09 | R8C1→R1C1 N | 1 |
| SALTANAT | gunes-imparatorlugu-09 | R8C7→R1C7 N | 1 |
| HÜKÜMDAR | gunes-imparatorlugu-09 | R1C4→R8C4 S | 1 |
| UYGARLIK | gunes-imparatorlugu-10 | R1C8→R8C1 SW | 1 |

## Nested / shared-path

Tek full nested listed-word vakası:

KUM ⊂ KUMUL

- KUM: R4C1→R6C3 SE
- KUMUL: R4C1→R8C5 SE

Başka listed word tamamen başka bir listed word path’inin alt kümesi değildir.

## Overlap totals

Shared-cell tanımı: iki veya daha fazla listed word tarafından kullanılan benzersiz grid hücresi.

- Kayıp Şehir: 54
- Yeraltı Krallığı: 56
- Güneş İmparatorluğu: 48
- Trilogy total: 158
- farklı-harf collision: 0

## Direction totals

| DIR | COUNT |
|---|---:|
| N | 35 |
| NE | 15 |
| E | 35 |
| SE | 18 |
| S | 38 |
| SW | 21 |
| W | 35 |
| NW | 13 |
| TOTAL | 210 |

Route bazında:

- Kayıp Şehir: N12 · NE3 · E9 · SE10 · S16 · SW7 · W11 · NW2
- Yeraltı Krallığı: N9 · NE7 · E16 · SE5 · S7 · SW5 · W14 · NW7
- Güneş İmparatorluğu: N14 · NE5 · E10 · SE3 · S15 · SW9 · W10 · NW4

---

# DETERMINISTIC SEED PROVENANCE

Solver seed contract:

seed =
first_64_bits_big_endian(
SHA256("kelime-avi-a6-v1|" + LEVEL_ID)
)

Filler stream:

fillerSeed =
seed XOR 0x9E3779B97F4A7C15

Bu seed bilgisi yalnız provenance/reproducibility içindir.

**Production runtime grid generation yapmayacaktır.**  
Authoritative production veri bu dosyadaki literal 8×8 grid datasetidir.

---

# EXACT-ONE SCANNER CONTRACT

AŞAMA 6 bağımsız scanner intended placement tablosunu authoritative arama girdisi olarak kullanmaz.

Her listed TARGET + BONUS için:

1. 64 başlangıç hücresinin tamamı taranır.
2. Her başlangıçtan 8 straight direction denenir.
3. Kelime uzunluğunca grid dışına çıkmayan tüm straight paths okunur.
4. Word ve reverse selection support uygulanır.
5. Aynı fiziksel hücre dizisinin ileri/geri representation’ı tek canonical physical-path key’e normalize edilir.
6. Beklenen unique physical path count = 1.

Mevcut production WordHuntContentValidator yalnız >=1 occurrence doğrular. Bu nedenle üçleme implementation acceptance test’inde ayrıca **EXACT-ONE PHYSICAL OCCURRENCE TEST** bulunmalıdır.

Bu acceptance test şu anda implementation görevi değildir; gelecekteki zorunlu acceptance requirement’tır.

---

# BASIC CONTENT QC

Final 30 grid üzerinde ek basic inappropriate-content scan yapılmıştır.

Taranan:
- tüm satırlar
- tüm sütunlar
- iki diagonal ailesindeki doğrusal diziler
- ters yönler
- belirgin uygunsuz/küfür kısa token listesi

Sonuç:

**hit = 0**

Bu scan exact-one validator’ın yerine geçmez; ek kalite kontrolüdür.

---

# AŞAMA 6 DURUMU

**FINAL / LOCKED**

Bu dosyadaki 30 literal grid + placement tabloları authoritative dataset’tir.

Bundan sonra:
- regenerate yok
- başka seed yok
- filler değişikliği yok
- placement değişikliği yok
- kelime değişikliği yok

Bir sonraki owner aşaması:

**AŞAMA 7 — GRID DIFFICULTY AUDIT + EXACT L5/L10 STAR-TIME THRESHOLDS**

AŞAMA 7’de grid değiştirilmeyecek; yalnız bu final dataset analiz edilecektir.
