import 'package:flutter_test/flutter_test.dart';
import 'package:word_hunt_content/word_hunt_journey_catalog.dart';
import 'package:word_hunt_flutter_feature/word_hunt_journey_geometry.dart';

void main() {
  for (final count in [1, 150, 1500, 15000]) {
    test(
      '$count published records have deterministic constant-time lookup',
      () {
        final catalog = PublishedJourneyCatalog(levelCount: count);
        expect(catalog.publishedLevelCount, count);
        expect(catalog.firstPublished!.ordinal, 1);
        expect(catalog.lastPublished!.ordinal, count);
        for (var n = 1; n <= count; n++) {
          final record = catalog.recordForOrdinal(n)!;
          expect(
            record.stableId,
            WordHuntJourneyGeometry.stableIdForOrdinal(n),
          );
          expect(catalog.recordForStableId(record.stableId)!.ordinal, n);
          expect(record.published, isTrue);
        }
        expect(catalog.recordForOrdinal(0), isNull);
        expect(catalog.recordForOrdinal(count + 1), isNull);
        expect(catalog.nextOrdinal(count), isNull);
        expect(catalog.previousOrdinal(1), isNull);
        if (count > 1) {
          expect(catalog.nextOrdinal(1), 2);
          expect(catalog.previousOrdinal(count), count - 1);
        }
      },
    );
  }
  test('published prefix excludes frontier and rejects identity aliases', () {
    final catalog = PublishedJourneyCatalog(
      levelCount: 15000,
      publishedLevelCount: 500,
      metadata: const {
        500: JourneyLevelMetadata(
          gameplayContentId: 'puzzle-x',
          challenge: true,
          milestone: true,
        ),
      },
    );
    expect(catalog.recordForOrdinal(501)!.published, isFalse);
    expect(catalog.isPublished(502), isFalse);
    expect(catalog.nextOrdinal(500), isNull);
    expect(catalog.previousOrdinal(501), isNull);
    expect(catalog.recordForStableId('level_500'), isNull);
    expect(
      catalog.recordForStableId('level_000500')!.gameplayContentId,
      'puzzle-x',
    );
    for (final id in [
      'route-1',
      'level_-00001',
      'level_000000',
      'level_+00001',
    ]) {
      expect(catalog.recordForStableId(id), isNull);
    }
    final expanded = PublishedJourneyCatalog(levelCount: 15100);
    expect(
      expanded.recordForOrdinal(500)!.stableId,
      catalog.recordForOrdinal(500)!.stableId,
    );
    expect(
      () => PublishedJourneyCatalog(levelCount: 1, publishedLevelCount: 2),
      throwsArgumentError,
    );
    expect(
      () => PublishedJourneyCatalog(
        levelCount: 1,
        metadata: const {2: JourneyLevelMetadata()},
      ),
      throwsArgumentError,
    );
  });
  test('empty published catalog is an explicit unavailable end', () {
    final catalog = PublishedJourneyCatalog(
      levelCount: 15000,
      publishedLevelCount: 0,
    );
    expect(catalog.firstPublished, isNull);
    expect(catalog.lastPublished, isNull);
    expect(catalog.isPublished(1), isFalse);
  });
}
