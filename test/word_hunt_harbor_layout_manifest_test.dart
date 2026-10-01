import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import '../packages/word_hunt_flutter_feature/lib/word_hunt_harbor_layout_manifest.dart';
import '../tools/word_hunt_harbor_asset_verifier.dart';

const _segment2Asset = 'assets/word_hunt/harbor_segments/segment_02_clean.webp';
const _segment3Asset = 'assets/word_hunt/harbor_segments/segment_03_clean.webp';
Map<String, Object?> _validFixture(
  int segment, {
  double anchorOffsetScenePx = 0,
}) {
  final first = segment == 2 ? 11 : 21;
  final asset = segment == 2 ? _segment2Asset : _segment3Asset;
  return <String, Object?>{
    'schemaVersion': 2,
    'routeId': 'baslangic-limani',
    'segmentIndex': segment,
    'scene': <String, Object?>{
      'assetPath': asset,
      'coordinateSpace': 'scenePixels',
      'coordinateSize': <int>[941, 1672],
      'sha256': HarborLayoutManifest.expectedSceneAssetSha256(asset),
    },
    'minimumHitTargetLogicalDp': 48,
    'nodes': <Map<String, Object?>>[
      for (var level = first; level < first + 10; level++)
        <String, Object?>{
          'levelId': 'baslangic-$level',
          'center': <String, Object?>{
            'unit': 'scenePixels',
            'x': 70 + (level - first) * 80 - anchorOffsetScenePx,
            'y': 90 + (level - first) * 150,
          },
          'connectionAnchor': <String, Object?>{
            'unit': 'scenePixels',
            'x': 70 + (level - first) * 80,
            'y': 90 + (level - first) * 150,
          },
          'starAnchor': <String, Object?>{
            'unit': 'nodeRelativeLogicalDp',
            'x': 0,
            'y': 42.5,
          },
          if (level == first + 9)
            'challengeAnchor': <String, Object?>{
              'unit': 'nodeRelativeLogicalDp',
              'x': 0,
              'y': 71,
            },
        },
    ],
    'connections': <Map<String, Object?>>[
      for (var edge = 0; edge < 9; edge++)
        <String, Object?>{
          'fromLevelId': 'baslangic-${first + edge}',
          'toLevelId': 'baslangic-${first + edge + 1}',
          'start': <String, Object?>{
            'unit': 'scenePixels',
            'x': 70 + edge * 80,
            'y': 90 + edge * 150,
          },
          'control1': <String, Object?>{
            'unit': 'scenePixels',
            'x': 90 + edge * 80,
            'y': 120 + edge * 150,
          },
          'control2': <String, Object?>{
            'unit': 'scenePixels',
            'x': 120 + edge * 80,
            'y': 160 + edge * 150,
          },
          'end': <String, Object?>{
            'unit': 'scenePixels',
            'x': 150 + edge * 80,
            'y': 240 + edge * 150,
          },
        },
    ],
  };
}

HarborSceneAssetMetadata? _resolveAsset(String path) {
  if (path == _segment2Asset || path == _segment3Asset) {
    return HarborSceneAssetMetadata(
      assetPath: path,
      width: 941,
      height: 1672,
      sha256: HarborLayoutManifest.expectedSceneAssetSha256(path)!,
    );
  }
  return null;
}

void main() {
  group('HarborLayoutManifest', () {
    test(
      'parses valid Segment 2 fixture without importing mockup geometry',
      () {
        final manifest = HarborLayoutManifest.parseJson(
          jsonEncode(_validFixture(2)),
          resolveAsset: _resolveAsset,
        );
        expect(manifest.schemaVersion, 2);
        expect(manifest.segmentIndex, 2);
        expect(manifest.nodes.map((node) => node.levelId), <String>[
          for (var i = 11; i <= 20; i++) 'baslangic-$i',
        ]);
        expect(manifest.connections, hasLength(9));
        expect(manifest.nodes.last.challengeAnchor, isNotNull);
      },
    );

    test('accepts route endpoints attached to explicit ring anchors', () {
      final manifest = HarborLayoutManifest.parse(
        _validFixture(2, anchorOffsetScenePx: 10),
        resolveAsset: _resolveAsset,
      );
      expect(manifest.nodes.first.center.x, 60);
      expect(manifest.nodes.first.connectionAnchor.x, 70);
      expect(manifest.connections.first.start.x, 70);
    });

    test('accepts anchor at node center', () {
      final fixture = _validFixture(2);
      final node = (fixture['nodes']! as List).first as Map;
      (node['connectionAnchor'] as Map)
        ..['x'] = 70
        ..['y'] = 90;
      final edge = (fixture['connections']! as List).first as Map;
      (edge['start'] as Map)
        ..['x'] = 70
        ..['y'] = 90;
      final manifest = HarborLayoutManifest.parse(
        fixture,
        resolveAsset: _resolveAsset,
      );
      expect(manifest.nodes.first.connectionAnchor.x, 70);
      expect(manifest.nodes.first.connectionAnchor.y, 90);
    });

    test('accepts anchor on the visual ring boundary', () {
      final edgeDistance =
          HarborLayoutManifest.maximumConnectionAnchorDistanceScenePx;
      final manifest = HarborLayoutManifest.parse(
        _validFixture(2, anchorOffsetScenePx: edgeDistance),
        resolveAsset: _resolveAsset,
      );
      expect(
        (manifest.nodes.first.center.x -
                manifest.nodes.first.connectionAnchor.x)
            .abs(),
        closeTo(edgeDistance, 1e-9),
      );
    });

    test('rejects anchor outside the visual ring even inside the hitbox', () {
      final narrowScale = HarborLayoutManifest.sceneToViewportScale(
        viewportWidth: 360,
        viewportHeight: 800,
      );
      // 28 dp is outside the 27 dp visual ring, but remains inside the
      // 34 dp half-width interaction target on both reviewed viewports.
      final offset = 28 / narrowScale;
      final wideScale = HarborLayoutManifest.sceneToViewportScale(
        viewportWidth: 412,
        viewportHeight: 915,
      );
      expect(offset * wideScale, lessThan(34));
      final errors = HarborLayoutManifest.validate(
        _validFixture(2, anchorOffsetScenePx: offset),
        resolveAsset: _resolveAsset,
      );
      expect(
        errors,
        contains(contains('must remain within the 54 dp node ring')),
      );
    });

    test('rejects an in-scene anchor far from its node', () {
      final fixture = _validFixture(2);
      final node = (fixture['nodes']! as List).first as Map;
      (node['connectionAnchor'] as Map)
        ..['x'] = 900
        ..['y'] = 900;
      final edge = (fixture['connections']! as List).first as Map;
      (edge['start'] as Map)
        ..['x'] = 900
        ..['y'] = 900;
      final errors = HarborLayoutManifest.validate(
        fixture,
        resolveAsset: _resolveAsset,
      );
      expect(
        errors,
        contains(contains('must remain within the 54 dp node ring')),
      );
    });

    test(
      'anchor distance respects scene transform on both target viewports',
      () {
        final anchorDistance =
            HarborLayoutManifest.maximumConnectionAnchorDistanceScenePx;
        for (final viewport in const <(double, double)>[
          (360, 800),
          (412, 915),
        ]) {
          final scale = HarborLayoutManifest.sceneToViewportScale(
            viewportWidth: viewport.$1,
            viewportHeight: viewport.$2,
          );
          final projectedDistance = anchorDistance * scale;
          expect(projectedDistance, lessThanOrEqualTo(27.001));
          expect(projectedDistance, lessThanOrEqualTo(34));
        }
      },
    );

    test('parses valid Segment 3 fixture and its absolute identifiers', () {
      final manifest = HarborLayoutManifest.parse(
        _validFixture(3),
        resolveAsset: _resolveAsset,
      );
      expect(manifest.segmentIndex, 3);
      expect(manifest.nodes.first.levelId, 'baslangic-21');
      expect(manifest.nodes.last.levelId, 'baslangic-30');
    });

    test('rejects malformed JSON with a useful fail-closed error', () {
      expect(
        () => HarborLayoutManifest.parseJson(
          '{bad json',
          resolveAsset: _resolveAsset,
        ),
        throwsA(
          isA<HarborLayoutValidationException>().having(
            (error) => error.errors.join(' '),
            'errors',
            contains('JSON parse error'),
          ),
        ),
      );
    });

    test(
      'rejects unknown schema version and unsupported progression fields',
      () {
        final fixture = _validFixture(2)..['schemaVersion'] = 99;
        (fixture['nodes']! as List).first['earnedStars'] = 3;
        final errors = HarborLayoutManifest.validate(
          fixture,
          resolveAsset: _resolveAsset,
        );
        expect(errors, contains(contains('schemaVersion must equal 2')));
        expect(errors, contains(contains('earnedStars is not supported')));
      },
    );

    test('rejects missing fields, duplicate IDs, and wrong segment ranges', () {
      final fixture = _validFixture(2);
      fixture.remove('routeId');
      final nodes = fixture['nodes']! as List;
      (nodes[1] as Map)['levelId'] = 'baslangic-11';
      (nodes[2] as Map)['levelId'] = 'baslangic-31';
      final errors = HarborLayoutManifest.validate(
        fixture,
        resolveAsset: _resolveAsset,
      );
      expect(errors, contains(contains('routeId is required')));
      expect(errors, contains(contains('duplicate levelId')));
      expect(errors, contains(contains('levelId order')));
    });

    test('rejects missing or misordered connections', () {
      final fixture = _validFixture(3);
      final edges = fixture['connections']! as List;
      edges.removeLast();
      (edges[0] as Map)['toLevelId'] = 'baslangic-23';
      final errors = HarborLayoutManifest.validate(
        fixture,
        resolveAsset: _resolveAsset,
      );
      expect(errors, contains(contains('exactly 9 ordered connections')));
      expect(errors, contains(contains('toLevelId must be baslangic-22')));
    });

    test('rejects correctly named connection with detached endpoint', () {
      final fixture = _validFixture(2);
      final firstEdge = (fixture['connections']! as List).first as Map;
      (firstEdge['start'] as Map)['x'] = 125;
      final errors = HarborLayoutManifest.validate(
        fixture,
        resolveAsset: _resolveAsset,
      );
      expect(
        errors,
        contains(
          contains('start must match the connectionAnchor of baslangic-11'),
        ),
      );
    });

    test('rejects out-of-scene node and Bézier coordinates', () {
      final fixture = _validFixture(2);
      final firstNode = (fixture['nodes']! as List).first as Map;
      (firstNode['center'] as Map)['x'] = -1;
      final firstEdge = (fixture['connections']! as List).first as Map;
      (firstEdge['control1'] as Map)['x'] = 942;
      final errors = HarborLayoutManifest.validate(
        fixture,
        resolveAsset: _resolveAsset,
      );
      expect(errors, contains(contains('center.x must be within the scene')));
      expect(errors, contains(contains('control1.x must be within the scene')));
    });

    test(
      'checks asset identity, dimensions, and SHA-256 against resolved metadata',
      () {
        final fixture = _validFixture(2);
        final scene = fixture['scene']! as Map;
        scene['assetPath'] = _segment3Asset;
        scene['coordinateSize'] = <int>[940, 1672];
        scene['sha256'] =
            'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb';
        final errors = HarborLayoutManifest.validate(
          fixture,
          resolveAsset: _resolveAsset,
        );
        expect(errors, contains(contains('assetPath must equal')));
        expect(errors, contains(contains('dimensions do not match')));
        expect(errors, contains(contains('SHA-256 does not match')));
      },
    );

    test('rejects correct manifest when resolver metadata is forged', () {
      final fixture = _validFixture(2);
      final forgedResolver =
          (String path) => HarborSceneAssetMetadata(
            assetPath: path,
            width: 941,
            height: 1672,
            sha256: 'f' * 64,
          );
      final errors = HarborLayoutManifest.validate(
        fixture,
        resolveAsset: forgedResolver,
      );
      expect(
        errors,
        contains(contains('Resolved scene asset SHA-256 does not match')),
      );
    });

    test(
      'rejects unapproved bytes and verifies real Segment 2/3 assets',
      () async {
        expect(
          HarborSceneAssetByteVerifier.resolveBytes(
            _segment2Asset,
            utf8.encode('not the approved scene asset'),
          ),
          isNull,
        );

        final root = Directory.current.path;
        for (final entry in <(int, String)>[
          (2, _segment2Asset),
          (3, _segment3Asset),
        ]) {
          final metadata = await HarborSceneAssetByteVerifier.resolveFile(
            repositoryRoot: root,
            assetPath: entry.$2,
          );
          expect(
            metadata,
            isNotNull,
            reason: 'segment ${entry.$1} bytes verify',
          );
          expect(
            metadata!.sha256,
            HarborLayoutManifest.expectedSceneAssetSha256(entry.$2),
          );
          final manifest = HarborLayoutManifest.parse(
            _validFixture(entry.$1),
            resolveAsset: (path) => path == entry.$2 ? metadata : null,
          );
          expect(manifest.segmentIndex, entry.$1);
        }
      },
    );

    test('rejects missing and incorrectly typed nested coordinate fields', () {
      final fixture = _validFixture(3);
      final node = (fixture['nodes']! as List).first as Map;
      (node['connectionAnchor'] as Map).remove('x');
      final edge = (fixture['connections']! as List).first as Map;
      (edge['end'] as Map)['y'] = '167';
      final errors = HarborLayoutManifest.validate(
        fixture,
        resolveAsset: _resolveAsset,
      );
      expect(errors, contains(contains('connectionAnchor.x is required')));
      expect(
        errors,
        contains(contains('connectionAnchor.x must be a finite number')),
      );
      expect(errors, contains(contains('end.y must be a finite number')));
    });

    test(
      'rejects malformed hash, non-positive scene size, and undersized hitbox',
      () {
        final fixture = _validFixture(3);
        final scene = fixture['scene']! as Map;
        scene['sha256'] = 'not-a-digest';
        scene['coordinateSize'] = <int>[0, 1672];
        fixture['minimumHitTargetLogicalDp'] = 47;
        final errors = HarborLayoutManifest.validate(
          fixture,
          resolveAsset: _resolveAsset,
        );
        expect(errors, contains(contains('64 hexadecimal characters')));
        expect(errors, contains(contains('must be positive')));
        expect(errors, contains(contains('must equal [941, 1672]')));
        expect(errors, contains(contains('at least 48')));
      },
    );

    test('rejects an unsupported scene coordinate space', () {
      final fixture = _validFixture(2);
      (fixture['scene']! as Map)['coordinateSpace'] = 'normalizedViewport';
      final errors = HarborLayoutManifest.validate(
        fixture,
        resolveAsset: _resolveAsset,
      );
      expect(
        errors,
        contains(contains('coordinateSpace must equal "scenePixels"')),
      );
    });

    test(
      'accepts generated technical preview manifests through the Dart validator',
      () async {
        for (final segment in <int>[2, 3]) {
          final assetPath = segment == 2 ? _segment2Asset : _segment3Asset;
          final assetMetadata = await HarborSceneAssetByteVerifier.resolveFile(
            repositoryRoot: Directory.current.path,
            assetPath: assetPath,
          );
          expect(assetMetadata, isNotNull);
          final path =
              'test/fixtures/harbor/technical_test_manifests/'
              'segment_${segment}_legacy_technical_fixture_manifest.json';
          final manifest = HarborLayoutManifest.parseJson(
            File(path).readAsStringSync(),
            resolveAsset:
                (resolvedPath) =>
                    resolvedPath == assetPath ? assetMetadata : null,
          );
          expect(manifest.segmentIndex, segment);
          expect(manifest.nodes, hasLength(10));
          expect(manifest.connections, hasLength(9));
        }
      },
    );

    test('rejects mixed units for scene and node-relative coordinates', () {
      final fixture = _validFixture(2);
      final nodes = fixture['nodes']! as List;
      final firstNode = nodes.first as Map;
      (firstNode['starAnchor'] as Map)['unit'] = 'scenePixels';
      final firstEdge = (fixture['connections']! as List).first as Map;
      (firstEdge['control1'] as Map)['unit'] = 'nodeRelativeLogicalDp';

      final errors = HarborLayoutManifest.validate(
        fixture,
        resolveAsset: _resolveAsset,
      );
      expect(
        errors,
        contains(
          contains('starAnchor.unit must equal "nodeRelativeLogicalDp"'),
        ),
      );
      expect(
        errors,
        contains(contains('control1.unit must equal "scenePixels"')),
      );
    });

    test(
      'one manifest projects scene geometry and logical overlays at both viewports',
      () {
        final manifest = HarborLayoutManifest.parse(
          _validFixture(2),
          resolveAsset: _resolveAsset,
        );
        final node = manifest.nodes.first;
        final connection = manifest.connections.first;
        final projected = <HarborSceneViewportTransform>[];

        for (final viewport in const <(double, double)>[
          (360, 724),
          (412, 839),
        ]) {
          final transform = HarborLayoutManifest.sceneToViewportTransform(
            sceneWidth: manifest.scene.width.toDouble(),
            sceneHeight: manifest.scene.height.toDouble(),
            viewportWidth: viewport.$1,
            viewportHeight: viewport.$2,
          );
          projected.add(transform);
          final center = transform.projectScene(node.center);
          final star = transform.projectNodeOffset(
            node.center,
            node.starAnchor,
          );
          final start = transform.projectScene(connection.start);
          final control1 = transform.projectScene(connection.control1);
          expect(center.unit, HarborLayoutCoordinateUnit.logicalDp);
          expect(star.y - center.y, closeTo(42.5, 1e-9));
          expect(start.x, closeTo(center.x, 1e-9));
          expect(start.y, closeTo(center.y, 1e-9));
          expect(
            control1.x,
            closeTo(
              transform.translationX + connection.control1.x * transform.scale,
              1e-9,
            ),
          );
          expect(
            control1.y,
            closeTo(
              transform.translationY + connection.control1.y * transform.scale,
              1e-9,
            ),
          );

          final finalNode = manifest.nodes.last;
          final challenge = transform.projectNodeOffset(
            finalNode.center,
            finalNode.challengeAnchor!,
          );
          final finalCenter = transform.projectScene(finalNode.center);
          expect(challenge.y - finalCenter.y, closeTo(71, 1e-9));
        }

        expect(projected.first.scale, isNot(projected.last.scale));
        expect(
          projected.first.projectNodeOffset(node.center, node.starAnchor).y -
              projected.first.projectScene(node.center).y,
          closeTo(
            projected.last.projectNodeOffset(node.center, node.starAnchor).y -
                projected.last.projectScene(node.center).y,
            1e-9,
          ),
        );
        expect(
          projected.first.projectScene(connection.control1).x,
          isNot(projected.last.projectScene(connection.control1).x),
        );
      },
    );
  });

  test(
    'D1 Segment 2 design manifest uses approved bytes and ordered anchors',
    () async {
      final source =
          await File(
            'test/fixtures/harbor/segment_2_design_candidate_manifest.json',
          ).readAsString();
      final metadata = await HarborSceneAssetByteVerifier.resolveFile(
        repositoryRoot: Directory.current.path,
        assetPath: _segment2Asset,
      );
      expect(metadata, isNotNull);
      final manifest = HarborLayoutManifest.parseJson(
        source,
        resolveAsset: (path) => path == _segment2Asset ? metadata : null,
      );
      expect(manifest.nodes.map((node) => node.levelId), [
        for (var level = 11; level <= 20; level++) 'baslangic-$level',
      ]);
      expect(manifest.connections, hasLength(9));
      for (var index = 0; index < manifest.connections.length; index++) {
        final edge = manifest.connections[index];
        expect(edge.fromLevelId, manifest.nodes[index].levelId);
        expect(edge.toLevelId, manifest.nodes[index + 1].levelId);
        expect(edge.start.x, manifest.nodes[index].connectionAnchor.x);
        expect(edge.start.y, manifest.nodes[index].connectionAnchor.y);
        expect(edge.end.x, manifest.nodes[index + 1].connectionAnchor.x);
        expect(edge.end.y, manifest.nodes[index + 1].connectionAnchor.y);
      }
      expect(
        manifest.nodes.take(9).every((node) => node.challengeAnchor == null),
        isTrue,
      );
      expect(manifest.nodes.last.challengeAnchor, isNotNull);
    },
  );
}
