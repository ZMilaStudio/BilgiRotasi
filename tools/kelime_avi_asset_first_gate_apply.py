from pathlib import Path

ROOT = Path.cwd()


def read(path):
    return (ROOT / path).read_text(encoding='utf-8')


def write(path, text):
    (ROOT / path).write_text(text, encoding='utf-8')


def replace_once(text, old, new, label):
    count = text.count(old)
    if count != 1:
        raise RuntimeError(f'{label}: expected 1 occurrence, found {count}')
    return text.replace(old, new, 1)


# ---- route stop: production assets for node/plaque/crown ----
path = 'lib/word_hunt/word_hunt_route_stop.dart'
text = read(path)
text = replace_once(text, "import 'dart:math' as math;\n\n", '', 'remove math import')
text = replace_once(
    text,
    "import 'word_hunt_models.dart';\n",
    "import 'word_hunt_models.dart';\nimport 'word_hunt_production_assets.dart';\n",
    'production asset import',
)
text = replace_once(
    text,
    "      lockedFinal: lockedFinal,\n      accent: accent,\n      theme: theme,\n      metrics: metrics,\n",
    "      lockedFinal: lockedFinal,\n      theme: theme,\n      metrics: metrics,\n",
    'stopWithStars accent removal',
)
text = replace_once(
    text,
    "                      labelOnLeft: labelOnLeft,\n                      theme: theme,\n                      metrics: metrics,\n",
    "                      labelOnLeft: labelOnLeft,\n                      metrics: metrics,\n",
    'special row theme removal',
)
text = replace_once(
    text,
    "    required this.lockedFinal,\n    required this.accent,\n    required this.theme,\n    required this.metrics,\n",
    "    required this.lockedFinal,\n    required this.theme,\n    required this.metrics,\n",
    'stop medallion constructor accent removal',
)
text = replace_once(
    text,
    "  final bool lockedFinal;\n  final Color accent;\n  final WordHuntRouteStopTheme theme;\n",
    "  final bool lockedFinal;\n  final WordHuntRouteStopTheme theme;\n",
    'stop medallion accent field removal',
)
text = replace_once(
    text,
    "          lockedFinal: lockedFinal,\n          accent: accent,\n          theme: theme,\n          diameter:\n",
    "          lockedFinal: lockedFinal,\n          theme: theme,\n          diameter:\n",
    'orb accent call removal',
)
text = replace_once(
    text,
    "    required this.labelOnLeft,\n    required this.theme,\n    required this.metrics,\n",
    "    required this.labelOnLeft,\n    required this.metrics,\n",
    'special row constructor theme removal',
)
text = replace_once(
    text,
    "  final bool labelOnLeft;\n  final WordHuntRouteStopTheme theme;\n  final WordHuntRouteStopMetrics metrics;\n",
    "  final bool labelOnLeft;\n  final WordHuntRouteStopMetrics metrics;\n",
    'special row theme field removal',
)
text = replace_once(
    text,
    "        child: _SpecialStopLabel(\n          levelIndex: level.index,\n          label: label,\n",
    "        child: _SpecialStopLabel(\n          levelIndex: level.index,\n          type: level.type,\n          label: label,\n",
    'special label type add',
)
text = replace_once(
    text,
    "          dimmed: !unlocked && !lockedFinal,\n          theme: theme,\n          emphasized: level.type == WordHuntLevelType.routeFinal,\n",
    "          dimmed: !unlocked && !lockedFinal,\n          emphasized: level.type == WordHuntLevelType.routeFinal,\n",
    'special label theme removal',
)

orb_start = text.index('class _RouteStopOrb extends StatelessWidget {')
stars_start = text.index('class _RouteStopStars extends StatelessWidget {', orb_start)
new_orb = r'''class _RouteStopOrb extends StatelessWidget {
  const _RouteStopOrb({
    required this.level,
    required this.unlocked,
    required this.lockedFinal,
    required this.theme,
    required this.diameter,
  });

  final WordHuntLevelDefinition level;
  final bool unlocked;
  final bool lockedFinal;
  final WordHuntRouteStopTheme theme;
  final double diameter;

  @override
  Widget build(BuildContext context) {
    final numberSize = switch (level.type) {
      WordHuntLevelType.normal => 30.0,
      WordHuntLevelType.challenge => 39.0,
      WordHuntLevelType.bonus => 40.0,
      WordHuntLevelType.routeFinal => 58.0,
    };
    final visuallyHighlighted = unlocked || lockedFinal;
    final assetPath = WordHuntProductionAssets.nodeFor(
      type: level.type,
      unlocked: unlocked,
    );

    return SizedBox.square(
      key: Key('word_hunt_route_stop_orb_${level.index}'),
      dimension: diameter,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          Image.asset(
            assetPath,
            key: Key('word_hunt_route_stop_asset_${level.index}'),
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
          Center(
            child: visuallyHighlighted
                ? Text(
                    '${level.index}',
                    key: Key('word_hunt_route_stop_number_${level.index}'),
                    style: TextStyle(
                      color: theme.textColor,
                      fontSize: numberSize,
                      fontWeight: FontWeight.w800,
                      height: 1,
                      shadows: const <Shadow>[
                        Shadow(
                          color: Color(0xDD000000),
                          blurRadius: 3,
                          offset: Offset(0, 1.5),
                        ),
                      ],
                    ),
                  )
                : Icon(
                    Icons.lock_rounded,
                    key: Key('word_hunt_route_stop_lock_${level.index}'),
                    color: theme.lockColor,
                    size: 34,
                    shadows: const <Shadow>[
                      Shadow(color: Color(0xCC000000), blurRadius: 3),
                    ],
                  ),
          ),
          if (level.type == WordHuntLevelType.routeFinal)
            Positioned(
              key: Key('word_hunt_route_stop_crown_${level.index}'),
              top: -42,
              left: -6,
              width: 154,
              height: 94,
              child: Image.asset(
                WordHuntProductionAssets.finalCrown,
                key: Key('word_hunt_route_stop_crown_asset_${level.index}'),
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
        ],
      ),
    );
  }
}

'''
text = text[:orb_start] + new_orb + text[stars_start:]

label_start = text.index('class _SpecialStopLabel extends StatelessWidget {')
icon_start = text.index('class _SpecialStopIcon extends StatelessWidget {', label_start)
new_label = r'''class _SpecialStopLabel extends StatelessWidget {
  const _SpecialStopLabel({
    required this.levelIndex,
    required this.type,
    required this.label,
    required this.icon,
    required this.accent,
    required this.dimmed,
    required this.emphasized,
  });

  final int levelIndex;
  final WordHuntLevelType type;
  final String label;
  final IconData icon;
  final Color accent;
  final bool dimmed;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final plaquePath = WordHuntProductionAssets.plaqueFor(type);
    assert(plaquePath != null);
    return Opacity(
      opacity: dimmed ? 0.72 : 1,
      child: SizedBox.expand(
        key: Key('word_hunt_route_stop_plaque_$levelIndex'),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              plaquePath!,
              key: Key('word_hunt_route_stop_plaque_asset_$levelIndex'),
              fit: BoxFit.fill,
              filterQuality: FilterQuality.high,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _SpecialStopIcon(
                    label: label,
                    fallback: icon,
                    color: accent,
                    size: emphasized ? 40 : 36,
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: label == 'MEYDAN OKUMA' ? 1 : 2,
                      overflow: TextOverflow.fade,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: accent,
                        fontFamily: 'serif',
                        fontSize: label == 'MEYDAN OKUMA'
                            ? 24.0
                            : emphasized
                                ? 29.0
                                : 24.0,
                        height: 1.05,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.7,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

'''
text = text[:label_start] + new_label + text[icon_start:]

fantasy = text.find('class _FantasyPlaquePainter extends CustomPainter {')
if fantasy < 0:
    raise RuntimeError('Fantasy plaque painter marker missing')
text = text[:fantasy].rstrip() + '\n'
write(path, text)

# ---- route screen: asset-backed bottom controls ----
path = 'lib/word_hunt/word_hunt_reference_route_screen.dart'
text = read(path)
text = replace_once(
    text,
    "import 'word_hunt_progress.dart';\n",
    "import 'word_hunt_progress.dart';\nimport 'word_hunt_production_assets.dart';\n",
    'screen production asset import',
)
old_control_call = '''                                icon:\n                                    index == 0\n                                        ? Icons.explore_rounded\n                                        : Icons.menu_book_rounded,\n                                semanticLabel:\n'''
new_control_call = '''                                assetPath:\n                                    index == 0\n                                        ? WordHuntProductionAssets.compassButton\n                                        : WordHuntProductionAssets.bookButton,\n                                semanticLabel:\n'''
text = replace_once(text, old_control_call, new_control_call, 'bottom control asset call')
control_start = text.index('class _ReferenceBottomControl extends StatelessWidget {')
new_control = r'''class _ReferenceBottomControl extends StatelessWidget {
  const _ReferenceBottomControl({
    super.key,
    required this.assetPath,
    required this.semanticLabel,
    this.onTap,
  });

  final String assetPath;
  final String semanticLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox.square(
            dimension: 170,
            child: Image.asset(
              assetPath,
              key: Key(
                semanticLabel == 'Pusula'
                    ? 'word_hunt_reference_compass_asset'
                    : 'word_hunt_reference_book_asset',
              ),
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
      ),
    );
  }
}
'''
text = text[:control_start] + new_control
write(path, text)

# ---- route stop tests ----
path = 'test/word_hunt_route_stop_test.dart'
text = read(path)
old = '''    expect(\n      find.byKey(const Key('word_hunt_route_stop_frame_1')),\n      findsOneWidget,\n      reason: 'Düz daire yerine dekoratif medalyon çerçevesi bulunmalı.',\n    );\n'''
new = '''    expect(\n      find.byKey(const Key('word_hunt_route_stop_asset_1')),\n      findsOneWidget,\n      reason: 'Normal durak production medalyon asset kullanmalı.',\n    );\n    final normalAsset = tester.widget<Image>(\n      find.byKey(const Key('word_hunt_route_stop_asset_1')),\n    );\n    expect(\n      (normalAsset.image as AssetImage).assetName,\n      'assets/word_hunt/baslangic_limani/node_normal.webp',\n    );\n    expect(\n      find.byKey(const Key('word_hunt_route_stop_frame_1')),\n      findsNothing,\n      reason: 'Final render procedural medalyon painter kullanmamalı.',\n    );\n'''
text = replace_once(text, old, new, 'normal asset test')

old = '''    expect(\n      find.byKey(const Key('word_hunt_route_stop_lock_9')),\n      findsOneWidget,\n    );\n'''
new = '''    expect(\n      find.byKey(const Key('word_hunt_route_stop_lock_9')),\n      findsOneWidget,\n    );\n    final lockedAsset = tester.widget<Image>(\n      find.byKey(const Key('word_hunt_route_stop_asset_9')),\n    );\n    expect(\n      (lockedAsset.image as AssetImage).assetName,\n      'assets/word_hunt/baslangic_limani/node_locked.webp',\n    );\n'''
text = replace_once(text, old, new, 'locked asset test')

old = '''      expect(\n        find.byKey(const Key('word_hunt_route_stop_crown_10')),\n        findsOneWidget,\n        reason: 'Final hedefi ayrı ve süslü taç siluetini korumalı.',\n      );\n'''
new = '''      expect(\n        find.byKey(const Key('word_hunt_route_stop_crown_10')),\n        findsOneWidget,\n        reason: 'Final hedefi ayrı ve süslü taç siluetini korumalı.',\n      );\n      final finalNode = tester.widget<Image>(\n        find.byKey(const Key('word_hunt_route_stop_asset_10')),\n      );\n      expect(\n        (finalNode.image as AssetImage).assetName,\n        'assets/word_hunt/baslangic_limani/node_final.webp',\n      );\n      final crownAsset = tester.widget<Image>(\n        find.byKey(const Key('word_hunt_route_stop_crown_asset_10')),\n      );\n      expect(\n        (crownAsset.image as AssetImage).assetName,\n        'assets/word_hunt/baslangic_limani/final_crown.webp',\n      );\n'''
text = replace_once(text, old, new, 'final assets test')

anchor = "      expect(find.text('ROTA FİNALİ'), findsOneWidget);\n"
addition = '''      expect(find.text('ROTA FİNALİ'), findsOneWidget);\n      for (final entry in <(int, String, String)>[\n        (5, 'node_challenge.webp', 'challenge_plaque.webp'),\n        (8, 'node_bonus.webp', 'bonus_plaque.webp'),\n        (10, 'node_final.webp', 'final_plaque.webp'),\n      ]) {\n        final nodeImage = tester.widget<Image>(\n          find.byKey(Key('word_hunt_route_stop_asset_${entry.$1}')),\n        );\n        expect(\n          (nodeImage.image as AssetImage).assetName,\n          'assets/word_hunt/baslangic_limani/${entry.$2}',\n        );\n        final plaqueImage = tester.widget<Image>(\n          find.byKey(Key('word_hunt_route_stop_plaque_asset_${entry.$1}')),\n        );\n        expect(\n          (plaqueImage.image as AssetImage).assetName,\n          'assets/word_hunt/baslangic_limani/${entry.$3}',\n        );\n      }\n'''
text = replace_once(text, anchor, addition, 'special asset tests')
write(path, text)

# ---- route screen test: bottom control assets ----
path = 'test/word_hunt_reference_route_screen_test.dart'
text = read(path)
marker = "  testWidgets('special plaques and final crown follow canonical bounds', (\n"
new_test = r'''  testWidgets('premium bottom controls use production assets', (tester) async {
    await pumpCanonicalReferenceRoute(tester);

    final compassImage = tester.widget<Image>(
      find.byKey(const Key('word_hunt_reference_compass_asset')),
    );
    expect(
      (compassImage.image as AssetImage).assetName,
      'assets/word_hunt/baslangic_limani/compass_button.webp',
    );
    final bookImage = tester.widget<Image>(
      find.byKey(const Key('word_hunt_reference_book_asset')),
    );
    expect(
      (bookImage.image as AssetImage).assetName,
      'assets/word_hunt/baslangic_limani/book_button.webp',
    );
  });

'''
if marker not in text:
    raise RuntimeError('screen test insertion marker missing')
text = text.replace(marker, new_test + marker, 1)
write(path, text)

Path('tools/kelime_avi_asset_first_gate_apply.py').unlink()
print('Kelime Avi asset-first candidate applied in workspace.')
