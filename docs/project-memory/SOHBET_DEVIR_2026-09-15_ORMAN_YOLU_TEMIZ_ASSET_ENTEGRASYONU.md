# Sohbet Devri — Orman Yolu Temiz Asset Entegrasyonu

**Tarih:** 15 Eylül 2026  
**Repo:** `ZMilaStudio/BilgiRotasi`  
**PR:** #198  
**Branch:** `feat/kelime-avi-scenic-theme-depth-20260912`  
**Base:** `release/final-closed-test-aab-1.68.8`

## Yeni sohbet için tek cümlelik görev

Owner tarafından onaylanan **temiz 941×1672 Orman environment asset'ini** production runtime'a bağla; eski UI-bake Orman composite'ini foreground ve ambient zincirinden tamamen çıkar; node geometrisini değiştirmeden exact-head CI ve üç gerçek Android 16 ekran kanıtını üret; kullanıcı görselleri onaylayana kadar PR'ı merge etme ve Orman 2'ye başlama.

## Canlı GitHub'ı önce doğrula

Bu dosya oluşturulurken:

- PR #198: **OPEN / Draft / unmerged**.
- Ürün/runtime kodunun son kesin baseline'ı: `ec0b501b7c9d05af03d273000a48af88e4a4bd3c`.
- Bu devir ve proje özeti için bunun üzerine docs-only commit eklenebilir; yeni sohbette canlı PR HEAD'i fetch et ve docs-only HEAD'i ürün baseline'ı sanma.
- Öncelik: **canlı GitHub > bu devir dosyası > eski sohbet**.

## Neden bu noktadayız?

Orman ekranında uzun süre ghosting/double-image görüldü. Tall ambient, header, node/yıldız ve alt kontroller tekrar tekrar düzenlendi; sonunda source raster doğrudan açılıp incelendi.

Kök neden kesin olarak bulundu: production'da kullanılan `orman_yolu_scene_00.b64 ... orman_yolu_scene_06.b64` birleşimi temiz background değil, eski UI'nin piksele bake edildiği **941×1672 tam ekran composite** idi.

Raster içinde eski olarak bulunanlar:

- back/info,
- büyük header + `KELİME AVI` + `Orman Yolu` + yapraklar + yıldız + `21/30`,
- node 1–10,
- kilitler ve level numaraları,
- final taç/10,
- bütün eski yıldız sıraları,
- eski pusula ve kitap.

Raster içinde environment olarak ayrıca **taş 1→10 rota** ve **MEYDAN OKUMA** tabelası bulunuyordu.

Flutter üstüne yeni canlı UI çizdiği için eski raster UI + yeni Flutter UI üst üste geliyordu. Tall ambient da aynı raster'ı blur ederek eski UI'yi başka yerde tekrar taşıyordu.

## Owner onaylı temiz source

Kullanıcı şu ham temiz environment'ı görsel olarak onayladı:

- `ORMAN_ENVIRONMENT_CLEAN_ROUTE_941x1672.png` — **941×1672**
- `ORMAN_ENVIRONMENT_CLEAN_ROUTE_941x1672.webp` — **941×1672**

Doğrulama yardımcıları:

- `ORMAN_ROUTE_ANCHOR_DEBUG_941x1672.png` — production'a eklenmeyecek debug overlay
- `ORMAN_ENVIRONMENT_DIMENSION_PROOF.txt`
- `ORMAN_ENVIRONMENT_941x1672_PACKAGE.zip`

Clean asset korunmuş içerik:

- orman, ağaçlar, şelale/su, kayalar, bitki örtüsü, ışık,
- köprü ve sahne dekorları,
- **taş 1→10 rota/patika**,
- **MEYDAN OKUMA** tabelası.

Clean asset'ten çıkarılanlar:

- tüm eski header/back/info,
- tüm eski node/lock/number/star/final UI,
- eski compass/book,
- eski UI halo/gölge/çerçeveleri.

Node anchor'ları debug olarak clean asset üstüne bindirilip kontrol edildi. Mevcut live anchor akışı taş rotayla korunuyor. Bu overlay final asset değildir.

## Entegrasyon için değişmez kurallar

### Foreground

- Yalnız yeni temiz **941×1672** environment kullanılacak.
- Stretch/crop ile geometri değiştirilmeyecek.

### Flutter live UI

Aşağıdakiler yalnız Flutter tarafından bir kez çizilecek:

- header,
- back/info,
- node 1–10,
- kilitler,
- level numaraları,
- yıldızlar,
- final node,
- pusula,
- kitap.

### Rota

- Taş rota clean environment'ta zaten var.
- Orman live route painter **kapalı kalacak**.
- `WordHuntRouteMapGeometry.normalizedStops` / node anchor'ları / 1 üstte → 10 altta yönü **değiştirilmeyecek**.

### Tall ambient

- Eski UI-bake raster kesinlikle kullanılmayacak.
- Gerekirse yalnız clean environment kaynak olacak.
- Ambient foreground map içine taşarak ghosting/double-image üretmeyecek.

### Eski asset

- Eski `orman_yolu_scene_00...06` production runtime selection'ından çıkarılacak.
- Asset dosyaları tarihsel/test için tutulsa bile foreground/ambient production path'inden erişilemez olmalı.
- Kod, asset manifesti ve runtime selection düzeyinde bunu doğrula.

## Orman UX — değiştirme

- Bölüm 1 üstte, Bölüm 10 altta.
- Zig-zag geometri aynı.
- Node görsel boyutu owner onaylı küçültülmüş durumda; hitbox geniş kalır.
- Final locked/unlocked/completed davranışı mevcut karara göre korunur.
- Pusula yalnız next playable node'u kısa vurgular; scroll/kamera yok.
- Kitap konu bilgisi; `i` genel harita rehberi.
- MEYDAN OKUMA dekoratif, interaktif değil.
- SafeArea ve alt touch overlap korunur.
- Açılış fade/depth <1 sn, bounce yok.

## Önceki CI durumu ne anlama geliyor?

`ec0b501...` üzerinde eski baked raster ile:

- Route Catalog: SUCCESS
- Android 16 ana proof: SUCCESS
- 3 ekran boyutu proof: SUCCESS
- AdMob exact-head: SUCCESS

Bu teknik PASS'ler clean-asset entegrasyonunu kanıtlamaz ve görsel final değildir. Yeni clean-asset exact HEAD için hepsi tekrar koşmalı.

## Yeni sohbette uygulanacak sıra

1. `GENEL_PROJE_OZETI.md`, bu dosya, `KARARLAR.md`, `KARAR_2026-09-14_ORMAN_YOLU_UX.md` dosyalarını oku.
2. PR #198 ve canlı HEAD'i doğrula.
3. Runtime baseline `ec0b501...` ile docs-only handoff commit'ini ayır.
4. Owner onaylı clean 941×1672 asset'i repo asset zincirine ekle.
5. `WordHuntRouteVisualThemes.ormanYolu` / ilgili runtime asset seçimini clean source'a geçir.
6. Eski baked raster production foreground ve ambient yolundan tamamen çıkar.
7. Tall ambient'i yalnız clean source ile kur; mevcut contain/reference geometry ve node anchor'larına dokunma.
8. Live route painter kapalı kalsın.
9. Tek temiz exact-head integration commit'i oluştur.
10. Exact-head Route Catalog, Android 16 main proof, 3-size proof ve AdMob doğrulamasını çalıştır.
11. Gerçek emulator/build PNG'leri al:
    - 720×1280
    - 1080×1920
    - 1080×2400
12. Kendin görsel incele:
    - ikinci header izi yok,
    - eski node izi yok,
    - eski yıldız izi yok,
    - pusula/kitap çiftlenmiyor,
    - rota tek katman,
    - node'lar taş rota anchor'larıyla eşleşiyor,
    - ambient eski UI taşımıyor,
    - tall birleşim/seam temiz.
13. Üç gerçek görüntü + exact-head sonuçlarını kullanıcıya getir ve **DUR**.
14. Kullanıcı “Orman 1 tamam” demeden Ready/merge yok, Orman 2 yok.

## Yapılmaması gerekenler

- ImageGen/mockup'ı final Android kanıtı gibi sunma.
- Yeni forest artwork redesign yapma.
- Node anchor'larını/rota yönünü değiştirme.
- Baked eski raster'ı blur/ambient ile yeniden kullanma.
- Geçici/test progress verisine bakıp gameplay progression değiştirme.
- PR #198'i owner onayı olmadan merge/Ready yapma.
- Orman 2'yi başlatma.

## Devir özeti

**Şu anda yapılacak tek iş clean-asset production entegrasyonudur.** Clean 941×1672 source owner-approved; geometri owner-approved; baked eski raster kök neden olarak doğrulanmış; entegrasyon henüz tamamlanmamış; sonraki kabul kriteri üç gerçek Android 16 ekranında tek katmanlı, ghostsuz Orman 1 görünümüdür.
