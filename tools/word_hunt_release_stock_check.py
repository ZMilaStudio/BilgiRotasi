#!/usr/bin/env python3
"""Kelime Avı toplam yayın stoğu kapısı.

Yeni üretilen ve exact-one doğrulamasından geçmiş bölüm sayısını, daha önce
kullanıcı tarafından fiziksel/teknik kabulü tamamlanmış mevcut bölüm sayısıyla
toplar. Amaç Play release adayı için minimum 200 hazır bölüm şartını makinece
zorunlu kılmaktır.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--generated", required=True, type=Path)
    parser.add_argument("--approved-existing", required=True, type=int)
    parser.add_argument("--required-total", required=True, type=int)
    args = parser.parse_args()

    if args.approved_existing < 0 or args.required_total <= 0:
        print("RELEASE_STOCK_FAIL: sayılar pozitif olmalı", file=sys.stderr)
        return 2

    data = json.loads(args.generated.read_text(encoding="utf-8"))
    generated = int(data.get("totalLevels", -1))
    routes = data.get("routes", [])
    if generated < 0:
        print("RELEASE_STOCK_FAIL: totalLevels eksik", file=sys.stderr)
        return 2

    actual_generated = sum(len(route.get("levels", [])) for route in routes)
    if generated != actual_generated:
        print(
            f"RELEASE_STOCK_FAIL: totalLevels tutarsız {generated} != {actual_generated}",
            file=sys.stderr,
        )
        return 2

    # Bu ilk ölçekleme dalgasında sözleşme 18 rota x 10 bölüm = 180 yeni bölüm.
    if len(routes) != 18 or any(len(route.get("levels", [])) != 10 for route in routes):
        print("RELEASE_STOCK_FAIL: yeni stok 18 rota x 10 bölüm olmalı", file=sys.stderr)
        return 2

    total = args.approved_existing + generated
    print("KELİME AVI RELEASE STOCK")
    print(f"Onaylı mevcut bölüm: {args.approved_existing}")
    print(f"Yeni doğrulanmış bölüm: {generated}")
    print(f"Toplam hazır bölüm: {total}")
    print(f"Minimum yayın eşiği: {args.required_total}")

    if total < args.required_total:
        print(
            f"RELEASE_STOCK_FAIL: {total} < {args.required_total}",
            file=sys.stderr,
        )
        return 2

    print("RELEASE_STOCK_READY: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
