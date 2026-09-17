# Kelime Avı — Kayıp Şehir Üçlemesi / AŞAMA 8 FINAL ARTWORK CONTRACT + PROMPT PACK

**Tarih:** 18 Eylül 2026  
**Durum:** FINAL / LOCKED  
**Kapsam:** Environment artwork production contract + asset prompt pack  
**Sonraki aşama:** AŞAMA 9 — Controlled Concept Generation + Owner Visual Selection

> AŞAMA 1–7 FINAL / LOCKED. Bu dosya yalnız artwork üretim contract’ını ve prompt pack’i kilitler. Image generation, asset üretimi, production implementation, test değişikliği, branch/PR veya merge bu aşamanın parçası değildir.

---

# 1. PRODUCTION ASSET AUDIT

Canlı production source audit’inde doğrulanan temel contract:

- Kristal Vadisi environment asset path:
  `assets/word_hunt/KRISTAL_VADISI_ENV_941x1672.webp`
- Kristal production artwork dimensions:
  `941×1672`
- Kristal production artwork bytes:
  `2,793,116`
- Reference canvas:
  `411×731`
- Background fit:
  `BoxFit.cover`
- Background alignment:
  `Alignment.center`
- Artwork filter quality:
  high
- Tall ambient extension:
  enabled
- Canonical live node geometry:
  generic / route-independent
- Node hitbox:
  generic / artwork-independent
- Progression state:
  live renderer authoritative
- Artwork:
  environment layer
- Alpha:
  environment asset için zorunlu değil
- Animation:
  yok / single-frame contract

Production Word Hunt asset klasöründe tarihsel olarak farklı formatlar birlikte bulunur:

- JPEG environment/background assetleri
- gerçek WebP assetleri
- base64-embedded artwork
- Kristal Vadisi historical anomaly: dosya adı `.webp` olmasına rağmen payload ile extension geçmişte mismatch yaşamıştır

Yeni üç asset için bu anomaly owner-approved değildir.

## Codec/extension equality

Yeni üç artwork için:

> `.webp` extension kullanılıyorsa gerçek encoded payload da WebP olacaktır.

PNG bytes + `.webp` filename YOK.

## Loader / codec compatibility

Current Flutter path direct `Image.asset(...)` üzerinden decode eder ve encoded image bytes’ını Flutter codec ile açar.

Bu nedenle historical mismatch runtime’da açılabilmiş olsa bile yeni production contract bunu kabul etmez.

## Reference-canvas / tall-screen behavior

Current themed production renderer:

- `referenceCanvasSize = 411×731`
- reference canvas’ı available screen içine `BoxFit.contain` ile yerleştirir
- artwork reference canvas içinde kendi `BoxFit.cover` contract’ıyla render edilir
- tall screen’de üst ve alt extra alan kalırsa artwork kenarlarından ambient band üretir

Tall ambient extension current behavior:

- artwork edge kullanımı
- vertical mirror/flip
- yaklaşık `1.08×` scale
- blur yaklaşık `sigma 10`
- theme background tint
- feather overlap yaklaşık 8 px

Bu nedenle tanımlanabilir mimari objelerin artwork’ün extreme top/bottom edge bölgelerinde bulunması risklidir.

## Chrome footprint

Reference-canvas production chrome genel olarak:

- top-left: back
- top-right: info
- bottom-left: compass
- bottom-right: book
- inner map header/title: üst bantta

Chrome global sistem olarak korunur; artwork içine faux chrome bake edilmez.

---

# 2. ASSET FILE CONTRACT — FINAL

## Kayıp Şehir

`assets/word_hunt/KAYIP_SEHIR_ENV_941x1672.webp`

## Yeraltı Krallığı

`assets/word_hunt/YERALTI_KRALLIGI_ENV_941x1672.webp`

## Güneş İmparatorluğu

`assets/word_hunt/GUNES_IMPARATORLUGU_ENV_941x1672.webp`

## Final production asset properties

- exact final canvas: `941×1672`
- portrait
- static WebP
- real WebP payload
- single frame
- opaque RGB
- sRGB
- no EXIF orientation dependency
- no animation
- no unexpected metadata
- filename extension = actual codec

### Preferred byte size

`0.8–1.8 MB / asset`

### Recommended soft maximum

`2.5 MB / asset`

Bu hard rejection değildir.

2.5 MB altına inmek için görünür kalite kaybı oluşuyorsa otomatik agresif compression yapılmaz; owner comparison gerekir.

---

# 3. FINAL OWNER KARARI — GENERATION SIZE ≠ FINAL EXPORT SIZE

`941×1672` **FINAL PRODUCTION ASSET CANVAS** contract’ıdır.

Image-generation modelinin ilk candidate çıktısından pixel-perfect `941×1672` üretmesi zorunlu değildir.

Candidate:

- portrait
- approximately 9:16
- contract composition’ına uygun

olabilir.

Owner candidate seçildikten ve gerekiyorsa refinement yapıldıktan sonra final preparation aşamasında:

1. composition korunur
2. controlled crop/resize yapılır
3. exact canvas = `941×1672`
4. canonical node-safe overlay tekrar kontrol edilir
5. L5/L10 composition tekrar kontrol edilir
6. top/bottom tall-safe strips tekrar kontrol edilir

Crop/resize:

- landmark kesmez
- node-safe alanı bozmaz
- L10 climax’i kaydırmaz
- chrome readability’yi bozmaz

Eğer exact canvas preparation composition’ı bozuyorsa asset otomatik kabul edilmez; owner visual review’e geri döner.

---

# 4. CANONICAL NODE-SAFE COMPOSITION

Source-authoritative canonical normalized node centers:

| LEVEL | X | Y |
|---|---:|---:|
| L1 | 0.18 | 0.10 |
| L2 | 0.48 | 0.17 |
| L3 | 0.75 | 0.27 |
| L4 | 0.66 | 0.38 |
| L5 | 0.28 | 0.47 |
| L6 | 0.18 | 0.60 |
| L7 | 0.48 | 0.67 |
| L8 | 0.78 | 0.74 |
| L9 | 0.32 | 0.82 |
| L10 | 0.60 | 0.91 |

Bu koordinatlar DEĞİŞMEYECEK.

Existing reference composition/header geometry’nin artwork-space audit karşılığı yaklaşık:

| LEVEL | 411×731 APPROX | 941×1672 APPROX |
|---|---|---|
| L1 | 77,166 | 175,380 |
| L2 | 197,210 | 452,480 |
| L3 | 306,272 | 701,623 |
| L4 | 270,341 | 618,779 |
| L5 | 117,397 | 267,908 |
| L6 | 77,478 | 175,1093 |
| L7 | 197,521 | 452,1193 |
| L8 | 318,565 | 729,1292 |
| L9 | 133,615 | 305,1406 |
| L10 | 246,671 | 563,1535 |

> Bu tablo yeni node koordinatı üretmez. Yalnız mevcut canonical live geometry’nin environment artwork composition audit’inde kullanılacak approximate safe-zone rehberidir.

## Design safe-zone direction

Normal L1–L4 ve L6–L9 için:

- yaklaşık `96×92 px` @ 411 reference
- yaklaşık `220×210 px` @ 941 asset

L5 ve L10 için:

- yaklaşık `112×106 px` @ 411 reference
- yaklaşık `256×242 px` @ 941 asset

Bu alanlar literal boş daire olarak çizilmez.

Tercihen şu öğeler node merkezinden uzak tutulur:

- yüksek kontrastlı ince edge
- küçük obje kalabalığı
- çok parlak local light source
- yüz
- okunabilir text
- yoğun glyph cluster
- ince mimari detay
- kritik landmark junction

Node renderer artwork üstünde rahat okunmalıdır.

---

# 5. TALL-SCREEN SAFE-ZONE CONTRACT

Artwork baştan `1080×2400` proof düşünülerek hazırlanır.

941×1672 final artwork’ün yaklaşık top ve bottom `200–220 px` bölgeleri nötr/extendable ambient karakterde olmalıdır.

Tanımlanabilir mimariyi blur/mirror extension’a bağımlı bırakma.

## Yasak / riskli

- yarım sütun tepesini extreme edge’e koymak
- tapınağı tam edge’de kesmek
- meşaleyi mirror bölgesine koymak
- simetrik kapıyı blur extension’a bırakmak
- heykel/yüz/mimariyi stretch/mirror alanına koymak
- L10 ana landmark’ını extreme bottom strip’e koymak

## Kayıp Şehir

Top:
- açık sky
- haze
- hafif uzak kum

Bottom:
- kum
- sakin stone forecourt
- küçük broken stone
- düşük-kontrast physical path continuation

## Yeraltı Krallığı

Top:
- dark vaulted atmosphere
- haze
- belirsiz stone mass

Bottom:
- dark stone
- subtle water reflection
- küçük copper/mineral traces

## Güneş İmparatorluğu

Top:
- open sky
- sunlight haze
- atmospheric depth

Bottom:
- pale stone terrace
- soft long shadow
- restrained floor inlay

## L10 rule

L10 canonical center artwork’ün alt bölümündedir.

Final landmark mümkün olduğunca:

- live L10 center’ın ABOVE/AROUND bölgesinde yükselir
- live L10 center’da calm forecourt/dais bırakır
- extreme bottom edge’e dayanmaz

---

# 6. ARTWORK vs LIVE-LAYER OWNERSHIP — FINAL

## Artwork taşıyabilir

- physical road trace
- stone paving
- sand road
- stepping stones
- platform
- bridge
- ceremonial road
- architectural framing
- environment storytelling
- atmospheric lighting
- route-specific landmarks
- physical L5/L10 environmental buildup

## Artwork taşımayacak

- numbered nodes
- node circles
- live node silhouettes
- stars
- locks
- active/completed/locked node state
- active/completed/locked path state
- gameplay glow path
- live progression line
- back button
- info button
- book button
- compass button
- route title
- title text
- UI frame
- faux chrome
- legible signage/text

## Authoritative ownership

- physical environment path = artwork context
- progression state = live renderer
- gameplay node = live renderer
- stars/locks = live renderer
- chrome = live renderer

Artwork physical path ile live progression path üst üste ikinci yol / ghosting oluşturmamalıdır.

---

# 7. SHARED TRILOGY ART DIRECTION — FINAL

Style:

- premium mobile game environment art
- semi-realistic
- cinematic
- high-detail but gameplay-readable
- not cartoon
- not photorealistic stock photography
- not painterly concept-art smear
- not generic AI fantasy wallpaper

Materyaller gerçek fiziksel ağırlık hissi taşımalıdır.

Üç route aynı uygarlığın devamı gibi görünmelidir.

## Shared DNA

- circular carved geometry
- glyph vocabulary
- carving logic
- turquoise signature
- aged-gold language
- solar/star glyph family
- astronomical motif evolution
- material aging logic

## Color/material weight

### Kayıp Şehir
- turquoise: LOW
- old gold: LOW
- weathering: HIGH
- sandstone / terracotta dominant

### Yeraltı Krallığı
- turquoise: MEDIUM
- copper: HIGH
- old gold: LOW / special
- dark stone dominant

### Güneş İmparatorluğu
- turquoise: LOW–CONTROLLED
- aged gold: HIGH
- refined pale stone: HIGH
- royal navy + restrained crimson secondary

## Prestige progression

KALINTI  
→ MEKANİZMA  
→ UYGARLIĞIN ZİRVESİ

---

# 8. STYLE CONTINUITY RULE — FINAL

Continuity:

- aynı sahneyi recolor etmek DEĞİL
- aynı mimariyi kopyalamak DEĞİL
- aynı layout’u tekrar etmek DEĞİL

Paylaşılan DNA:

- glyph vocabulary
- carving logic
- circular geometry family
- material aging logic
- turquoise signature
- old-gold language
- astronomical motif evolution

Route identity ayrı kalmalıdır:

### Kayıp Şehir
eroded archaeological sandstone world

### Yeraltı Krallığı
stone + copper engineered subterranean world

### Güneş İmparatorluğu
refined pale stone + aged gold astronomical world

---

# 9. KAYIP ŞEHİR — FINAL GENERATION PROMPT

~~~text
Create one premium mobile-game environment background intended for a final production crop of exactly 941 × 1672 pixels, portrait orientation, approximately 9:16. The initial generated candidate does not need to be pixel-perfect 941×1672, but it must preserve a portrait approximately-9:16 composition that can later be controlled-cropped/resized without damaging the design.

ROUTE IDENTITY:
An ancient lost city slowly emerging from beneath the desert.
The emotional tone is archaeological discovery, warmth, adventure and rediscovery — not danger, horror or fantasy spectacle.

ART DIRECTION:
Premium semi-realistic cinematic mobile game environment art.
High-detail physical materials but gameplay-readable.
Not cartoon.
Not photorealistic stock photography.
Not loose painterly concept art.
Not generic AI fantasy wallpaper.

ENVIRONMENT:
A vast open desert containing a long-lost ancient city gradually becoming more visible as the composition descends.
Weathered sandstone and pale limestone architecture, half-buried arches and columns, broken courtyard walls, eroded façades, terracotta architectural details, aged plaster, small faded turquoise stone or ceramic inlays and extremely restrained aged-gold or weathered bronze accents.

The upper area should feel more like open desert and scattered ruins.
Moving downward through the image, the lost city should become increasingly monumental and architecturally significant.

PATH / ENVIRONMENT RELATIONSHIP:
Include a believable physical ruined stepping route through the environment: old paving stones and broken stone road fragments emerging naturally from sand, sometimes partly buried.
This is environmental context only.
Do NOT make it a continuous bright line, neon trail, glowing game route, locked/unlocked route, or UI progression path.

LIGHTING:
Late-afternoon warm natural daylight with clear readability.
Soft golden-hour quality is acceptable, but no heavy orange filter, no yellow wash and no excessive bloom.
Natural atmospheric dust and depth.

MATERIAL PRIORITY:
weathered sandstone,
warm pale limestone,
terracotta,
aged plaster,
weathered bronze / very restrained old gold,
faded turquoise stone or ceramic.

TRILOGY DNA:
Use subtle circular carved geometry, restrained solar/star glyph language and a few faded turquoise and old-gold traces implying one ancient civilization.
These symbols should feel archaeological and partially forgotten, not dominant.

CANONICAL LIVE-NODE SAFE COMPOSITION:
The live game will render 10 nodes over the artwork.
Do not draw any visible circles or empty discs, but keep visually calmer, lower-detail breathing room around these approximate 941×1672 artwork coordinates:
L1 (175,380)
L2 (452,480)
L3 (701,623)
L4 (618,779)
L5 (267,908)
L6 (175,1093)
L7 (452,1193)
L8 (729,1292)
L9 (305,1406)
L10 (563,1535).

Avoid putting faces, tiny object clutter, high-contrast thin architectural edges or intense local light directly through those centers.
Give L5 and L10 slightly more breathing room than normal nodes.

L5 ENVIRONMENTAL MILESTONE:
Around the fifth node region, increase environmental evidence of wind and sand movement: swept dunes, wind-carved sand, drifting dust shapes and exposed road fragments.
This should imply “Fırtına Geçidi” without drawing the game challenge node and without creating a dangerous disaster scene.

L10 ENVIRONMENTAL CLIMAX:
Build toward a monumental ancient precinct above and around the final node region.
Suggest a giant circular carved stone-seal architecture and a dark descending subterranean entrance, stair or architectural void hinting at the world below.
The environment may contain large concentric carved stone geometry, but it MUST NOT look like the actual live UI node.
Place the major monument mainly ABOVE the live L10 center, leaving a calm stone/sand forecourt beneath it.

TALL-SCREEN SAFE ZONES:
Design the top roughly 200–220 pixels of the final crop as extendable sky/haze/desert atmosphere without identifiable architecture.
Design the lowest roughly 200–220 pixels of the final crop mainly as neutral sand, low-detail stone forecourt and subtle paving so vertical mirror/blur extension will not duplicate a recognizable monument.
Do not place cropped columns, gates, statues or strong symmetrical structures on the extreme top or bottom edge.

CHROME READABILITY:
Keep the upper corners and upper central header region reasonably calm.
Do not place the brightest sun, strongest edge contrast or critical landmark directly behind the top-left, top-right or title areas.

EXCLUSIONS:
No text, letters, numbers, signs, logos or watermark.
No UI or HUD.
No game buttons.
No route title.
No numbered markers.
No circular game nodes.
No rating stars.
No lock icons.
No arrows.
No active/completed/locked path state.
No glowing progression route.
No neon.
No people, faces or crowds.
No pyramids or obvious Egyptian clichés.
No giant fantasy statues.
No floating architecture.
No sci-fi technology.
No cyberpunk.
No steampunk.
No cartoon or childish fantasy.
No duplicated or mirrored buildings.
No malformed columns or impossible arches.
No excessive bloom.
No oversaturated orange.
No flat wallpaper composition.
~~~

---

# 10. YERALTI KRALLIĞI — FINAL GENERATION PROMPT

~~~text
Create one premium mobile-game environment background intended for a final production crop of exactly 941 × 1672 pixels, portrait orientation, approximately 9:16. The initial generated candidate does not need to be pixel-perfect 941×1672, but it must preserve a portrait approximately-9:16 composition that can later be controlled-cropped/resized without damaging the design.

ROUTE IDENTITY:
A forgotten subterranean system that is ancient, monumental and mysterious, yet appears engineered and still partly functional.
The emotional tone is discovery, depth, silence and ancient engineering.
Absolutely not horror.

ART DIRECTION:
Premium semi-realistic cinematic mobile game environment art.
High-detail physical materials but gameplay-readable.
Not cartoon.
Not photorealistic stock photography.
Not painterly concept-art smear.
Not generic dark fantasy wallpaper.

ENVIRONMENT:
Monumental underground halls carved from dark stone.
Ancient cistern architecture, vaulted spaces, stone bridges and platforms, channels, reservoirs and carefully integrated engineering systems.
Oxidized copper rings, mechanisms and connecting architectural elements embedded into stone.
Subtle turquoise mineral deposits and water traces.
Occasional warm amber illumination from believable ancient local light sources.

This should feel like an advanced ancient hydraulic and mechanical civilization, not a dungeon and not a factory.

LIGHTING:
Deep navy and smoky ambient darkness with readable gameplay areas.
Localized warm amber pools of light.
Controlled turquoise reflections from water or mineral traces.
Premium contrast, deep shadows but no crushed black gameplay areas.

MATERIAL PRIORITY:
dark carved stone,
smoky mineral rock,
aged oxidized copper,
wet mineral surfaces,
subtle turquoise,
very restrained old gold.

TRILOGY DNA:
Continue the same civilization’s circular carved geometry and glyph family from the approved Kayıp Şehir style anchor, but reinterpret it as functional engineering.
The glyph vocabulary, carving logic, turquoise character and aged-metal language must clearly feel related to the approved Kayıp Şehir artwork without copying its layout or architecture.
Turquoise is MEDIUM here, used as water/mineral/mechanical indicator.
Gold is rare and special.
Copper is the dominant metallic language.

PATH / ENVIRONMENT RELATIONSHIP:
Create believable physical movement through stone platforms, short bridges, mechanical crossing surfaces and architectural walkways.
Copper connections and occasional turquoise guidance marks can exist physically in the environment.
Do NOT create a glowing cable, neon path or UI route.
The environment path is physical context only; live progression will be rendered separately.

CANONICAL LIVE-NODE SAFE COMPOSITION:
The live game will render 10 nodes over the artwork.
Do not draw visible placeholder circles.
Keep calmer, lower-frequency visual breathing room around:
L1 (175,380)
L2 (452,480)
L3 (701,623)
L4 (618,779)
L5 (267,908)
L6 (175,1093)
L7 (452,1193)
L8 (729,1292)
L9 (305,1406)
L10 (563,1535).

Avoid putting tiny gears, bright lamps, sharp bridge edges, detailed glyph clusters or high-contrast copper lines directly through those centers.
Give the L5 and L10 regions slightly more breathing room.

L5 ENVIRONMENTAL MILESTONE:
Around the fifth-node region, establish a more sophisticated mechanical chamber.
Use larger concentric architectural rings, stone-and-copper locking geometry and aligned carved mechanisms.
This is environmental “Halka Kilidi” context only.
Do NOT draw a circular game node, lock icon or obvious UI device.

L10 ENVIRONMENTAL CLIMAX:
Above and around the final-node region, transition toward a grand astronomical/mechanical chamber.
Combine stone, aged copper and subtle celestial alignment geometry.
Include restrained star-map motifs, tiny turquoise/gold constellation-like points embedded architecturally and a suggestion of vertical escape or light from above.
This is the first strong bridge toward the Güneş İmparatorluğu visual language.
Do NOT create a giant golden sun, solar crown or full solar throne.

Keep the live L10 center itself on a calm stone platform/forecourt while the larger astronomical architecture rises mainly above and around it.

TALL-SCREEN SAFE ZONES:
The top roughly 200–220 pixels of the final crop should be dark vaulted atmosphere, shadow and haze without a distinctive torch, gate, statue or arch centered on the crop boundary.
The lowest roughly 200–220 pixels should be mostly low-detail stone, subtle water reflection and minor mechanical traces.
Do not rely on recognizable architecture in these edge strips because the production renderer may mirror and blur artwork edges on tall screens.

CHROME READABILITY:
Keep top corners and upper central title band readable.
No very bright torch or turquoise hotspot directly behind chrome.

EXCLUSIONS:
No text, letters, numbers, signs, logo or watermark.
No UI, HUD or game buttons.
No numbered nodes.
No rating stars.
No padlock icons.
No live route markers or arrows.
No active/completed/locked progression path.
No glowing neon cable.
No horror.
No skulls, bones, corpses, monsters or threatening silhouettes.
No dungeon cages.
No medieval torture-room aesthetic.
No steampunk.
No Victorian machinery.
No pipe-filled industrial factory.
No modern industrial equipment.
No sci-fi machinery.
No cyberpunk.
No lava cavern.
No giant golden sun.
No floating structures.
No people, faces or crowds.
No cartoon style.
No excessive bloom.
No duplicated or mirrored architecture.
No malformed rings, bridges, columns or impossible perspective.
No flat wallpaper composition.
~~~

---

# 11. GÜNEŞ İMPARATORLUĞU — FINAL GENERATION PROMPT

~~~text
Create one premium mobile-game environment background intended for a final production crop of exactly 941 × 1672 pixels, portrait orientation, approximately 9:16. The initial generated candidate does not need to be pixel-perfect 941×1672, but it must preserve a portrait approximately-9:16 composition that can later be controlled-cropped/resized without damaging the design.

ROUTE IDENTITY:
The summit of the lost civilization — not ruins being discovered, but the civilization’s monumental sacred and astronomical center.
The emotional tone is culmination, openness, precision, prestige and awe.

ART DIRECTION:
Premium semi-realistic cinematic mobile-game environment art.
High-detail physical materials while remaining extremely gameplay-readable.
Not cartoon.
Not photorealistic stock photography.
Not painterly concept-art smear.
Not generic heavenly-fantasy wallpaper.

ENVIRONMENT:
An open-sky monumental ceremonial complex made from warm pale limestone and refined carved stone.
Large but believable columns, broad terraces, astronomical alignment platforms, solar observatory architecture, formal ceremonial roads and carefully engineered ancient mechanisms.
Aged gold inlays and mechanical details.
Royal navy stone or enamel-like accents.
Restrained crimson ceremonial details.
Only tiny controlled turquoise continuity accents.

The architectural language should feel like:
ancient ceremonial observatory + imperial sacred architecture.

It must NOT feel like a fantasy palace.

LIGHTING:
Strong natural directional sunlight.
Architectural shadows that reveal scale and geometry.
Subtle volumetric sun rays.
Controlled halo.
High readability.
No blown-out whites and no excessive bloom.

MATERIAL PRIORITY:
warm pale limestone,
refined carved stone,
aged gold,
royal navy stone/inlay,
restrained crimson,
very limited turquoise.

TRILOGY DNA:
Use the approved Kayıp Şehir and approved Yeraltı Krallığı artworks as style anchors.
Evolve their glyph vocabulary, carving logic, circular geometry, turquoise signature, aged-metal language and astronomical motif family into the civilization’s most refined and monumental form.
Do not copy their layouts or architecture.
Old gold is now the main prestige material.
Turquoise remains LOW and controlled — only enough to connect this world visually to the first two routes.

PATH / ENVIRONMENT RELATIONSHIP:
Create a formal physical ceremonial alignment road using pale stone paving, restrained aged-gold inlays and astronomical alignment marks integrated into the floor.
The environment path becomes increasingly formal toward the final precinct.
Do NOT turn it into a glowing game route, neon trail or progression line.

CANONICAL LIVE-NODE SAFE COMPOSITION:
The live game will render 10 nodes over the artwork.
Do not draw visible placeholder circles.
Keep controlled, lower-detail breathing zones around:
L1 (175,380)
L2 (452,480)
L3 (701,623)
L4 (618,779)
L5 (267,908)
L6 (175,1093)
L7 (452,1193)
L8 (729,1292)
L9 (305,1406)
L10 (563,1535).

Avoid placing narrow high-contrast gold lines, column edges, sun hotspots or dense glyph clusters directly through the node centers.
Give L5 and especially L10 extra visual breathing room.

L5 ENVIRONMENTAL MILESTONE:
Around the fifth-node region, create an architectural equinox/alignment precinct.
Use split solar geometry in the surrounding architecture, opposing light directions, aligned stone surfaces or controlled light-and-shadow relationships that visually converge.
This is environmental context for “Ekinoks Kapısı”.
Do NOT draw the actual challenge node, a game portal or a glowing circular UI ring.

L10 ENVIRONMENTAL CLIMAX:
Create the trilogy’s most prestigious environmental destination.
Above and around the final node region, build a monumental solar sanctum and elevated ceremonial precinct.
Architectural and astronomical geometry should visually converge toward the climax.
Use refined aged gold, royal navy depth and controlled solar symbolism.
The final destination should feel complete and definitive.

The live game will render the Güneş Tahtı node separately.
Do NOT draw the actual throne UI node, circular level medallion or game crest.
Instead create a calm final dais / forecourt at the live-node center, with monumental solar architecture rising mainly ABOVE and around it.

TALL-SCREEN SAFE ZONES:
The top roughly 200–220 pixels of the final crop should be open sky, subtle sunlight haze and atmospheric depth, without a cropped temple, statue or recognizable symmetrical monument on the extreme edge.
The lowest roughly 200–220 pixels should remain mostly pale stone terrace, soft architectural shadow and restrained floor inlay.
Do not place the main sanctum in the extreme bottom strip because production may mirror/blur the edge on tall screens.

CHROME READABILITY:
Keep the top-left, top-right and upper-center title area visually calm.
The strongest sun disk or highlight must not sit directly behind the header/chrome.

EXCLUSIONS:
No text, letters, numbers, signage, logo or watermark.
No UI or HUD.
No game buttons.
No numbered nodes.
No rating-star UI.
No padlock icons.
No route markers or arrows.
No live progression glow.
No neon.
No actual Güneş Tahtı game node.
No fantasy castle.
No generic heavenly temple.
No floating golden palace.
No cloud kingdom.
No angelic imagery.
No giant magical portal.
No sci-fi observatory.
No holograms.
No futuristic technology.
No cyberpunk.
No steampunk.
No giant human-faced sun.
No people, faces or crowds.
No cartoon or childish fantasy.
No excessive bloom.
No oversaturated gold.
No pure-white blown highlights.
No duplicated columns or mirrored buildings.
No malformed architecture.
No flat wallpaper composition.
~~~

---

# 12. GLOBAL NEGATIVE PROMPT — FINAL

~~~text
GLOBAL NEGATIVE CONSTRAINTS:

No text, letters, numbers, words, signage, logos, watermark or signatures.
No UI, HUD, menus, game buttons or interface frames.
No route title.
No numbered level markers.
No circular game-node placeholders.
No star-rating icons.
No padlock icons.
No arrows or selection markers.
No active, completed or locked progression state.
No glowing neon progression path.
No artificial game trail.

No duplicated buildings.
No mirrored architecture.
No repeated identical columns.
No malformed columns.
No impossible arches.
No broken perspective.
No accidental floating structures.
No obvious AI geometry errors.

No close-up humans.
No faces.
No crowds.
Prefer no people at all.

No cartoon.
No childish fantasy.
No generic mobile-game castle.
No generic AI fantasy wallpaper.
No photorealistic stock-photo aesthetic.
No loose painterly concept-art smear.

No steampunk.
No cyberpunk.
No sci-fi technology.
No modern machinery unless explicitly ancient in design.
No excessive glow or bloom.
No oversaturated colors.
No crushed unreadable shadows.
No flat background composition.

Do not place identifiable architecture on the extreme top or bottom edge where tall-screen ambient extension may mirror or blur it.
~~~

---

# 13. ROUTE-SPECIFIC NEGATIVES — FINAL

## Kayıp Şehir

- no pyramids
- no pharaoh imagery
- no stereotypical Egypt
- no oasis postcard aesthetic
- no giant fantasy statues
- no heavy orange desert filter
- no magical glowing runes

## Yeraltı Krallığı

- no horror dungeon
- no skulls/bones
- no monsters
- no prison bars
- no gore
- no steampunk pipe maze
- no Victorian factory
- no industrial turbine room
- no lava cave

## Güneş İmparatorluğu

- no floating heaven palace
- no angelic clouds
- no generic Greek/Roman white fantasy temple
- no giant magical portal
- no sci-fi holograms
- no massive sun-face icon
- no full gold wash
- no overexposed holy glow

---

# 14. FINAL OWNER KARARI — SEQUENTIAL VARIANT PRODUCTION

Total concept candidate count remains:

- 3 / route
- 9 total

Ancak 9 görsel bağımsız ve aynı anda üretilmeyecek.

## A) KAYIP ŞEHİR

İlk tur:

- 3 candidate

Owner:

- 1 candidate seçer
- gerekirse 1 refinement pass

Approved Kayıp Şehir artwork:

> STYLE ANCHOR 1

olur.

Bu anchor yalnız palette değil, civilization DNA için referans olur:

- glyph vocabulary
- carving logic
- circular geometry family
- turquoise character
- aged-metal language
- material aging logic

## B) YERALTI KRALLIĞI

Kayıp Şehir owner-approved olmadan Yeraltı candidate generation’a geçilmez.

Yeraltı için:

- 3 candidate
- kendi Mechanical / Underground kimliği korunur
- approved Kayıp Şehir STYLE ANCHOR 1 referans alınır

Continuity özellikle:

- glyph family
- carved circular geometry
- turquoise character
- aged-metal language

üzerinden kurulur.

Yeraltı tamamen farklı bir uygarlığa dönüşmez.

Owner:

- 1 candidate seçer
- gerekirse 1 refinement pass

Approved Yeraltı artwork:

> STYLE ANCHOR 2

olur.

## C) GÜNEŞ İMPARATORLUĞU

Kayıp + Yeraltı owner-approved olmadan Güneş candidate generation’a geçilmez.

Güneş için:

- 3 candidate
- STYLE ANCHOR 1: approved Kayıp Şehir
- STYLE ANCHOR 2: approved Yeraltı Krallığı

referans kabul edilir.

Güneş kendi:

- Solar
- Monumental
- Astronomical
- Imperial

kimliğini güçlü biçimde taşır.

Amaç:

> aynı uygarlığın üçüncü ve en rafine katmanı

Owner:

- 1 candidate seçer
- gerekirse 1 refinement pass

---

# 15. FINAL EXPORT WORKFLOW

Owner candidate seçimi ve olası refinement sonrasında:

1. owner-approved visual direction dondurulur
2. composition korunur
3. controlled crop/resize hazırlanır
4. exact canvas = `941×1672`
5. canonical node-safe overlay yeniden uygulanır
6. 10 node safe-zone review yapılır
7. L5 environmental milestone review yapılır
8. L10 environmental climax review yapılır
9. top/bottom tall-safe strip review yapılır
10. chrome readability review yapılır
11. image opaque 8-bit sRGB RGB’ye hazırlanır
12. static WebP encode edilir
13. magic-byte / codec doğrulanır:
   `RIFF ... WEBP`
14. dimensions doğrulanır:
   `941×1672`
15. frame count = 1 doğrulanır
16. alpha absent doğrulanır
17. EXIF/XMP/orientation dependency ve metadata surprise kontrol edilir
18. byte size kontrol edilir
19. production screenshot proof yapılır
20. owner final visual approval alınır
21. ancak bundan sonra SHA-256 kaydedilir
22. ancak bundan sonra asset immutable/final adayı sayılır

Eğer controlled crop/resize composition’ı bozarsa export otomatik kabul edilmez; owner visual review’e geri dönülür.

---

# 16. HASH / IMMUTABILITY CONTRACT — FINAL

Candidate aşamasında hash/immutable contract YOK.

Refinement aşamasında hash/immutable contract YOK.

SHA-256 yalnız şu koşullar tamamlandığında authoritative olarak kaydedilir:

- owner visual approval
- exact 941×1672 canvas
- final WebP encode
- actual codec doğrulaması
- dimension doğrulaması
- frame count kontrolü
- alpha kontrolü
- metadata kontrolü
- production screenshot proof

Bu noktaya kadar asset:

> mutable working candidate

olarak kabul edilir.

---

# 17. ASSET ACCEPTANCE CHECKLIST — FINAL

Her route için:

- [ ] owner-approved visual direction
- [ ] final exact 941×1672
- [ ] portrait
- [ ] .webp extension
- [ ] actual WebP payload
- [ ] static / single frame
- [ ] opaque RGB
- [ ] sRGB
- [ ] no EXIF orientation dependency
- [ ] no unexpected metadata
- [ ] preferred 0.8–1.8 MB
- [ ] recommended soft max 2.5 MB or explicit owner quality exception
- [ ] no text
- [ ] no legible signage
- [ ] no UI
- [ ] no faux chrome
- [ ] no baked numbered nodes
- [ ] no baked node circles
- [ ] no stars
- [ ] no locks
- [ ] no baked live progression state
- [ ] no active/completed/locked path state
- [ ] no ghost second route/path
- [ ] physical environment path only
- [ ] canonical node-safe areas readable
- [ ] L5 environmental milestone recognizable
- [ ] L10 environmental climax recognizable
- [ ] L10 actual live UI node absent from artwork
- [ ] top extension-safe
- [ ] bottom extension-safe
- [ ] no recognizable architecture in mirror-risk strips
- [ ] no mirrored architecture artifact
- [ ] chrome top/bottom readability
- [ ] route identity recognizable with title hidden
- [ ] trilogy continuity present
- [ ] previous/next route material separation clear
- [ ] Kayıp ≠ Yeraltı ≠ Güneş at first glance
- [ ] Güneş overall prestige highest
- [ ] no obvious AI geometry error
- [ ] production screenshot proof complete
- [ ] final codec/dimension/frame/alpha/metadata validation complete
- [ ] SHA-256 recorded only after approval

---

# 18. VISUAL REVIEW ORDER — FINAL

Asset üretildikten sonra review sırası:

1. composition
2. route identity
3. node-safe areas
4. L5/L10 hierarchy
5. tall-screen behavior
6. chrome harmony
7. trilogy side-by-side differentiation
8. technical codec/dimension/hash

Owner visual approval olmadan asset immutable/final ilan edilmez.

---

# 19. RISKS / BLOCKERS

## Current blocker

AŞAMA 8 contract’ını bloke eden bir sorun yok.

## Risk 1 — Tall-screen mirror extension

Current renderer artwork edge’lerinden vertical mirror + blur ambient üretebilir.

Bu yüzden neutral top/bottom safe strips gerçek production constraint’tir.

## Risk 2 — AI composition precision

Image-generation modelinin canonical node koordinatlarını pixel-perfect koruması garanti değildir.

Bu nedenle:

- candidate üzerinde safe-zone overlay
- refinement sonrası safe-zone overlay
- final crop sonrası safe-zone overlay

tekrar kontrol edilir.

Node geometry değiştirilmez.

## Risk 3 — Codec mismatch

Kristal historical anomaly yeni assetlerde kabul edilmez.

Commit/production acceptance öncesi:

- extension
- magic bytes
- decode
- dimensions
- frame count

doğrulanır.

## Risk 4 — Aggressive compression

2.5 MB soft maximum kaliteyi görünür biçimde bozuyorsa yalnız byte hedefi için kalite düşürülmez.

Owner comparison gerekir.

## Risk 5 — Style drift between sequential routes

Yeraltı ve Güneş candidate’ları approved anchor artwork’leri referans almadan bağımsız üretilirse trilogy başka uygarlıklar gibi görünebilir.

Bu nedenle sequential owner approval zorunludur.

---

# 20. AŞAMA 8 DURUMU

**FINAL / LOCKED**

Authoritative final decisions:

- 941×1672 = FINAL export canvas, generation candidate size olmak zorunda değil
- exact final file family locked
- real static WebP locked
- opaque sRGB locked
- codec/extension equality locked
- artwork/live ownership locked
- canonical node-safe strategy locked
- tall-screen safe-zone strategy locked
- shared trilogy art direction locked
- three generation prompts locked
- global + route-specific negatives locked
- sequential 3+3+3 generation locked
- Kayıp → STYLE ANCHOR 1
- Yeraltı → STYLE ANCHOR 2
- Güneş → both anchors
- final crop/resize requires re-validation
- SHA-256 only after final owner-approved production proof

## Sonraki owner aşaması

**AŞAMA 9 — CONTROLLED CONCEPT GENERATION + OWNER VISUAL SELECTION**

Üretim sırası:

1. Kayıp Şehir — 3 candidate
2. owner selection/refinement
3. Yeraltı Krallığı — 3 candidate
4. owner selection/refinement
5. Güneş İmparatorluğu — 3 candidate
6. owner selection/refinement

Her rota ayrı owner onayından geçmeden sonraki route artwork’e geçilmez.
