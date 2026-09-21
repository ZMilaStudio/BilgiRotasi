import 'word_hunt_models.dart';

/// Player-facing Kelime Avı bölüm numarasını route-local progression
/// indeksinden türeten tek authority.
///
/// Local index hiçbir zaman persistence/progression identity'si olmaktan
/// çıkmaz. Global numara yalnız presentation için türetilir.
abstract final class WordHuntGlobalLevelNumbering {
  static const int levelsPerRoute = 100;

  static const List<String> routeOrder = <String>[
    'baslangic-limani',
    'gokyuzu-adalari',
    'orman-yolu',
    'orman-2',
    'kristal-vadisi',
    'kayip-sehir',
    'yeralti-kralligi',
    'gunes-imparatorlugu',
  ];

  static int routeDisplayOffset(String routeId) {
    final ordinal = routeOrder.indexOf(routeId);
    if (ordinal < 0) {
      throw ArgumentError.value(
        routeId,
        'routeId',
        'global display numbering authority içinde bulunamadı',
      );
    }
    return ordinal * levelsPerRoute;
  }

  static int globalDisplayNumber({
    required String routeId,
    required int localIndex,
  }) {
    if (localIndex < 1 || localIndex > levelsPerRoute) {
      throw RangeError.range(
        localIndex,
        1,
        levelsPerRoute,
        'localIndex',
      );
    }
    return routeDisplayOffset(routeId) + localIndex;
  }

  static String displayNameForLevel(WordHuntLevelDefinition level) {
    final explicitName = level.displayName?.trim();
    if (explicitName != null && explicitName.isNotEmpty) {
      return explicitName;
    }
    return 'Bölüm ${globalDisplayNumber(routeId: level.routeId, localIndex: level.index)}';
  }
}
