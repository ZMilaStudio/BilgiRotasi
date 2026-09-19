import 'package:flutter/material.dart';

import 'word_hunt_production_assets.dart';

enum WordHuntChromeControlKind { icon, asset }

enum WordHuntChromeMaterialFamily {
  legacyGlass,
  carvedStone,
  engineeredMetal,
  ceremonialStone,
}

@immutable
class WordHuntChromeControlSpec {
  const WordHuntChromeControlSpec.icon({
    required this.icon,
  }) : kind = WordHuntChromeControlKind.icon,
       assetPath = null;

  const WordHuntChromeControlSpec.asset({
    required this.assetPath,
  }) : kind = WordHuntChromeControlKind.asset,
       icon = null;

  final WordHuntChromeControlKind kind;
  final IconData? icon;
  final String? assetPath;
}

@immutable
class WordHuntRouteChromeTheme {
  const WordHuntRouteChromeTheme({
    required this.id,
    required this.headerTint,
    required this.surfaceTint,
    required this.materialFamily,
    required this.back,
    required this.info,
    required this.compass,
    required this.codex,
  });

  final String id;
  final Color headerTint;
  final Color surfaceTint;
  final WordHuntChromeMaterialFamily materialFamily;
  final WordHuntChromeControlSpec back;
  final WordHuntChromeControlSpec info;
  final WordHuntChromeControlSpec compass;
  final WordHuntChromeControlSpec codex;

  /// Optional compatibility preset. Existing routes keep their current null
  /// config path, so adding this abstraction does not silently reskin them.
  static const WordHuntRouteChromeTheme harborCompatibility =
      WordHuntRouteChromeTheme(
        id: 'harbor-compatibility',
        headerTint: Color(0xFF1C2E20),
        surfaceTint: Color(0xFF08120C),
        materialFamily: WordHuntChromeMaterialFamily.legacyGlass,
        back: WordHuntChromeControlSpec.icon(
          icon: Icons.arrow_back_rounded,
        ),
        info: WordHuntChromeControlSpec.icon(
          icon: Icons.info_outline_rounded,
        ),
        compass: WordHuntChromeControlSpec.asset(
          assetPath: WordHuntProductionAssets.compassButton,
        ),
        codex: WordHuntChromeControlSpec.asset(
          assetPath: WordHuntProductionAssets.bookButton,
        ),
      );

  /// Asset-free generic proof/config preset. Trilogy route themes can provide
  /// their own tokens later without introducing route-id branching.
  static const WordHuntRouteChromeTheme iconFoundation =
      WordHuntRouteChromeTheme(
        id: 'icon-foundation',
        headerTint: Color(0xFF26212A),
        surfaceTint: Color(0xFF11141D),
        materialFamily: WordHuntChromeMaterialFamily.ceremonialStone,
        back: WordHuntChromeControlSpec.icon(
          icon: Icons.arrow_back_rounded,
        ),
        info: WordHuntChromeControlSpec.icon(
          icon: Icons.info_outline_rounded,
        ),
        compass: WordHuntChromeControlSpec.icon(
          icon: Icons.explore_rounded,
        ),
        codex: WordHuntChromeControlSpec.icon(
          icon: Icons.menu_book_rounded,
        ),
      );
}
