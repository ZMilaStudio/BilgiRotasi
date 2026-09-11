#!/usr/bin/env python3
"""Kelime Avı için 18 rota x 10 bölüm = 180 yeni bölüm manifesti üretir."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

ROUTES = [
    ("orman-yolu", "Orman Yolu", "orman", ["AĞAÇ","YAPRAK","DAL","KÖK","ORMAN","ÇAM","MEŞE","KUŞ","YUVA","TOPRAK","GÖLGE","MANTAR","KOZALAK","DERE","PATİKA","ÇİÇEK","OTLAR","KAYA","SİNCAP","GEYİK"]),
    ("deniz-koyu", "Deniz Koyu", "deniz", ["DENİZ","DALGA","KUM","KIYI","BALIK","MERCAN","ADA","YELKEN","LİMAN","KÖPÜK","MAVİ","KABUK","YENGEÇ","FENER","KANO","YOSUN","İNCİ","KÖRFEZ","SAHİL","TEKNE"]),
    ("dag-gecidi", "Dağ Geçidi", "dağ", ["DAĞ","ZİRVE","KAYA","VADİ","YAMAÇ","KAR","BUZ","ÇAM","KARTAL","PATİKA","DORUK","KAMP","ATEŞ","ÇADIR","RÜZGAR","BULUT","TAŞ","KEÇİ","GÖL","PINAR"]),
    ("col-vahasi", "Çöl Vahası", "çöl", ["ÇÖL","KUM","VAHA","PALMİYE","GÜNEŞ","SERAP","DEVE","SICAK","RÜZGAR","KAYA","KUMUL","GECE","YILDIZ","GÖLGE","ÇADIR","YOLCU","KERVAN","FENER","UFUK","KUMTAŞI"]),
    ("kis-ulkesi", "Kış Ülkesi", "kış", ["KIŞ","KAR","BUZ","DON","KIZAK","KARDAN","SOĞUK","FIRTINA","ÇAM","BACA","ATEŞ","KAZAK","ELDİVEN","BERE","BOT","GECE","AYDIN","TIPI","BUZUL","GÖL"]),
    ("bahar-bahcesi", "Bahar Bahçesi", "bahar", ["BAHAR","ÇİÇEK","LALE","GÜL","PAPATYA","ARILAR","KELEBEK","ÇİMEN","YAĞMUR","GÖKKUŞAK","DAL","YAPRAK","FİDAN","TOPRAK","TOHUM","BAHÇE","KOKU","RÜZGAR","GÜNEŞ","KUŞ"]),
    ("gece-sehri", "Gece Şehri", "şehir", ["GECE","ŞEHİR","SOKAK","LAMBA","NEON","KÖPRÜ","KULE","METRO","TAKSİ","CADDE","VİTRİN","SAAT","YAĞMUR","ÇATI","MEYDAN","PARK","TREN","OTEL","SİS","IŞIK"]),
    ("uzay-ussu", "Uzay Üssü", "uzay", ["UZAY","ROKET","GEZEGEN","YILDIZ","MARS","UYDU","KOMET","ASTRONOT","KASK","KABİN","RADAR","LAZER","YÖRÜNGE","KRATER","GÖKTAŞI","NEBULA","DÜNYA","GÜNEŞ","MODÜL","İSTASYON"]),
    ("antik-kent", "Antik Kent", "antik", ["ANTİK","KENT","SÜTUN","TAPINAK","TAŞ","KEMER","MOZAİK","HEYKEL","MEYDAN","SARAY","KAPI","DUVAR","YOL","ÇEŞME","ARENA","KULE","PARA","YAZIT","TAHT","MEŞALE"]),
    ("gizemli-lab", "Gizemli Laboratuvar", "laboratuvar", ["DENEY","TÜP","ATOM","MOLEKÜL","LAZER","ROBOT","KOD","ENERJİ","MİKRO","HÜCRE","FORMÜL","CAM","IŞIK","SENSÖR","MOTOR","KABLO","PİL","MADDE","GAZ","METAL"]),
    ("muzik-adasi", "Müzik Adası", "müzik", ["MÜZİK","NOTA","RİTİM","SES","ŞARKI","DAVUL","GİTAR","FLÜT","PİYANO","KEMAN","SAHNE","KORO","MELODİ","TEMPO","ZİL","TELLER","MİKROFON","BAS","SOLO","DANS"]),
    ("spor-vadisi", "Spor Vadisi", "spor", ["SPOR","TOP","GOL","KOŞU","TENİS","BASKET","VOLEY","YÜZME","KAYAK","BİSİKLET","FORMA","TAKIM","MAÇ","SKOR","KALE","POTA","RAKET","PİST","MADALYA","ANTRENÖR"]),
    ("mutfak-sokagi", "Mutfak Sokağı", "mutfak", ["MUTFAK","TABAK","KAŞIK","ÇATAL","BIÇAK","TENCERE","TAVA","FIRIN","ÇORBA","EKMEK","PEYNİR","DOMATES","BİBER","ELMA","KEK","PİLAV","SALATA","ÇAY","KAHVE","BAL"]),
    ("masal-ormani", "Masal Ormanı", "masal", ["MASAL","PERİ","EJDERHA","KALE","TAÇ","KRAL","KRALİÇE","BÜYÜ","ASA","KILIÇ","ORMAN","DEV","CÜCE","ATLI","KÖPRÜ","HAZİNE","HARİTA","AYNA","KULE","ANAHTAR"]),
    ("teknoloji-kenti", "Teknoloji Kenti", "teknoloji", ["TEKNO","ROBOT","KOD","EKRAN","PİKSEL","ÇİP","AĞLAR","VERİ","DOSYA","KAMERA","DRON","SENSÖR","MOTOR","KABLO","PİL","LAZER","SUNUCU","KLAVYE","FARE","TABLET"]),
    ("tarih-yolu", "Tarih Yolu", "tarih", ["TARİH","ÇAĞ","KİTAP","YAZI","KALEM","PARA","MÜZE","SARAY","KÖPRÜ","KALE","HARİTA","KERVAN","GEMİ","TAHT","SAVAŞ","BARIŞ","KRAL","DEVLET","KAPI","YOL"]),
    ("bilim-koyu", "Bilim Koyu", "bilim", ["BİLİM","ATOM","HÜCRE","GEN","DENEY","FORMÜL","MADDE","ENERJİ","IŞIK","SES","UZAY","DÜNYA","CANLI","BİTKİ","HAVA","METAL","CAM","GÜÇ","ÖLÇÜM","DENEYİM"]),
    ("hazine-adasi", "Hazine Adası", "macera", ["HAZİNE","ADA","HARİTA","PUSULA","GEMİ","KAPTAN","KUM","PALMİYE","SANDIK","ALTIN","İNCİ","MAĞARA","FENER","KILIÇ","LİMAN","DALGA","YELKEN","KORSAN","ANAHTAR","UFUK"]),
]


def build_manifest() -> dict:
    out = {"schemaVersion": 1, "seed": 20260906, "minimumReleaseLevels": 200, "routes": []}
    for route_index, (route_id, title, theme, pool) in enumerate(ROUTES):
        levels = []
        for index in range(1, 11):
            start = ((index - 1) * 3) % len(pool)
            words = [pool[(start + offset) % len(pool)] for offset in range(5)]
            level_type = "normal"
            if index == 5:
                level_type = "challenge"
            if index == 10:
                level_type = "routeFinal"
            level = {
                "id": f"{route_id}-{index:02d}",
                "index": index,
                "type": level_type,
                "targetWords": words if index not in (3, 6, 8) else words[:4],
                "bonusWords": [] if index not in (3, 6, 8) else [words[4]],
                "starRules": {"twoStarMaxMistakes": 2, "threeStarMaxMistakes": 0},
                "seed": 20260906 + route_index * 1000 + index,
            }
            if index == 5:
                level["timeLimitSeconds"] = 60
            if index == 10:
                level["timeLimitSeconds"] = 120
            levels.append(level)
        out["routes"].append({
            "id": route_id,
            "title": title,
            "theme": theme,
            "unlockStarsRequired": 0,
            "routeRewardId": f"reward-{route_id}",
            "levels": levels,
        })
    return out


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()
    data = build_manifest()
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"RELEASE_STOCK_MANIFEST: {len(data['routes'])} rota / {sum(len(r['levels']) for r in data['routes'])} bölüm")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
