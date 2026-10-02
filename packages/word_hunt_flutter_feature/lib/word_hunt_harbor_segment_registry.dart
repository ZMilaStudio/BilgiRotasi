/// Approved scene identities. Registering art never grants player access.
class WordHuntHarborSegmentDescriptor {
  const WordHuntHarborSegmentDescriptor({
    required this.segmentIndex,
    required this.title,
    required this.sceneAsset,
    required this.manifestAsset,
    required this.sceneSha256,
  });
  final int segmentIndex;
  final String title;
  final String sceneAsset;
  final String manifestAsset;
  final String sceneSha256;
  int get firstLevel => (segmentIndex - 1) * 10 + 1;
  int get lastLevel => firstLevel + 9;
}

abstract final class WordHuntHarborSegmentRegistry {
  static const fenerBurnu = WordHuntHarborSegmentDescriptor(
    segmentIndex: 4,
    title: 'FENER BURNU',
    sceneAsset: 'assets/word_hunt/harbor_segments/segment_04_clean.webp',
    manifestAsset:
        'assets/word_hunt/harbor_segments/segment_04_layout_schema_v2.json',
    sceneSha256:
        '7a184ded2911a6747451d62d08b41d787bfbcd4c2aa48a0e9fe4e1648dd2fbe0',
  );
  static const premiumSegments = <int, WordHuntHarborSegmentDescriptor>{
    4: fenerBurnu,
  };
  static WordHuntHarborSegmentDescriptor? forSegment(int index) =>
      premiumSegments[index];
}
