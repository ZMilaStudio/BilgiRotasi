import 'package:flutter/widgets.dart';

/// Rota ekranındaki geçici UX vurgularını progression verisinden ayırır.
///
/// Compass gibi kontroller yalnız görsel işaret üretir; node sırası, unlock
/// mantığı veya hitbox geometrisi bu scope üzerinden değiştirilmez.
class WordHuntRouteUxScope extends InheritedWidget {
  const WordHuntRouteUxScope({
    super.key,
    required this.highlightedLevelIndex,
    required this.highlightEpoch,
    required super.child,
  });

  final int? highlightedLevelIndex;
  final int highlightEpoch;

  static WordHuntRouteUxScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<WordHuntRouteUxScope>();
  }

  @override
  bool updateShouldNotify(WordHuntRouteUxScope oldWidget) {
    return highlightedLevelIndex != oldWidget.highlightedLevelIndex ||
        highlightEpoch != oldWidget.highlightEpoch;
  }
}
