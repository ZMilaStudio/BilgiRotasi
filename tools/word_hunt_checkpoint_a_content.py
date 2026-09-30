"""Deterministic, read-only candidate compiler for the owner device findings.

Prints JSON, never writes production files. Retains compliant L3/L4/L6 grids.
Uses the existing compiler with opt-in readability; legacy defaults are intact.
"""
import json
import re
import sys

import word_hunt_batch_generator as gen

ADDITIONS = {
    1: ['SİLGİ'], 2: ['KÜREK'],
    11: ['KAPI', 'DUVAR', 'ÇATI'], 12: ['NOTA', 'ŞARKI', 'SES'],
    13: ['ÇİMEN', 'ÇİLEK'], 14: ['ERİK', 'ÜZÜM'], 15: ['KIYI', 'HAVUZ'],
    16: ['RESİM', 'BOYA'], 17: ['MUZ', 'KASE'], 18: ['KESTANE', 'BADEM'],
    19: ['ODUN', 'TAHTA'], 20: ['SÜT', 'CAM', 'KÖY'],
    21: ['LAMBA', 'ÇARŞAF', 'YATAK', 'MİNDER'],
    22: ['LAVABO', 'MUSLUK', 'DUŞ', 'KİLİM'], 23: ['TREN', 'TRAMVAY', 'METRO'],
    24: ['SİMİT', 'POĞAÇA', 'TEREYAĞI'], 25: ['ÜRÜN', 'İNDİRİM', 'MÜŞTERİ'],
    26: ['YAĞMUR', 'SİS', 'FIRTINA'], 27: ['AYAK', 'DAMAR', 'BOYUN'],
    28: ['KURT', 'ASLAN', 'TAVŞAN'], 29: ['TABLET', 'FARE', 'İNTERNET'],
    30: ['CADDE', 'APARTMAN', 'OTEL'],
}
REMOVALS = {5: ['KALE'], 7: ['NEKTAR'], 9: ['KRATER', 'YÖRÜNGE'], 10: ['PARKUR', 'NİŞAN']}


def compile_candidates(source):
    levels = []
    blocks = source.split('      WordHuntLevelDefinition(')[1:]
    for index, block in enumerate(blocks, 1):
        print(f'Compiling L{index}', file=sys.stderr, flush=True)
        def words(key):
            return re.findall(r"'([^']+)'", re.search(key + r': <String>\[(.*?)\]', block, re.S).group(1))
        old = words('targetWords')
        bonus = words('bonusWords')
        targets = [word for word in old if word not in REMOVALS.get(index, [])] + ADDITIONS.get(index, [])
        if index == 26:
            targets = [{'GÖKKUŞAK': 'RÜZGAR', 'ÇİSENTİ': 'ŞİMŞEK'}.get(w, w) for w in targets]
        if any(a in b for a in targets + bonus for b in targets + bonus if a != b):
            raise gen.FactoryError(f'L{index}: substring would create ambiguous overlap')
        grid = words('grid')
        seed = None
        if index not in (3, 4, 6):
            directions = ((0, 1), (1, 0)) if index <= 5 else ((0, 1), (1, 0), (1, 1)) if index <= 10 else gen.DIRECTIONS
            for attempt in range(80):
                seed = f'checkpoint-a-device-v1/L{index}/{attempt}'
                rng = gen.StableRng(seed)
                try:
                    partial, _ = gen.place_all(targets + bonus, rng, readable=True, directions=directions, minimum_diagonals=0 if index <= 5 else 1 if index <= 20 else 2)
                    grid = gen.finalize_grid(partial, targets + bonus, rng)
                    break
                except gen.FactoryError:
                    continue
            else:
                raise gen.FactoryError(f'L{index}: no readable placement')
        paths = []
        for word in targets + bonus:
            matches = []
            physical = set()
            for row in range(8):
                for col in range(8):
                    for dr, dc in gen.DIRECTIONS:
                        cells = gen.cells_for(word, row, col, dr, dc)
                        if cells and ''.join(grid[r][c] for r, c in cells) == word and gen.canonical_physical_path(cells) not in physical:
                            physical.add(gen.canonical_physical_path(cells))
                            matches.append(dict(word=word, row=row, col=col, dr=dr, dc=dc))
            if len(matches) != 1:
                raise gen.FactoryError(f'L{index}: {word} has {len(matches)} paths')
            paths.extend(matches)
        levels.append(dict(index=index, grid=grid, targets=targets, bonus=bonus, paths=paths, seed=seed,
                           before=len(old), removed=[w for w in old if w not in targets], added=[w for w in targets if w not in old]))
    all_words = [w for level in levels for w in level['targets'] + level['bonus']]
    if len(all_words) != len(set(all_words)):
        raise gen.FactoryError('Route word duplicates')
    return levels


if __name__ == '__main__':
    # Run against the parent source, including after production integration.
    import subprocess
    source = subprocess.check_output(['git', 'show', '9691abb52c7e3ae9c4ed82a1f699a6fa63f5862f:packages/word_hunt_content/lib/word_hunt_starter_content.dart']).decode('utf-8')
    print(json.dumps(compile_candidates(source), ensure_ascii=False))
