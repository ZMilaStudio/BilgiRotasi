import 'dart:convert';
import 'word_hunt_harbor_segment_registry.dart';

/// Metadata resolved by a build/test tool for a Harbor scene asset.
///
/// This deliberately contains no Flutter or filesystem dependency. The caller
/// supplies metadata obtained from its trusted asset inventory.
class HarborSceneAssetMetadata {
  const HarborSceneAssetMetadata({
    required this.assetPath,
    required this.width,
    required this.height,
    required this.sha256,
  });

  final String assetPath;
  final int width;
  final int height;
  final String sha256;
}

typedef HarborSceneAssetResolver =
    HarborSceneAssetMetadata? Function(String assetPath);

class HarborLayoutValidationException implements Exception {
  const HarborLayoutValidationException(this.errors);

  final List<String> errors;

  @override
  String toString() =>
      'Harbor layout manifest is invalid:\n'
      '${errors.map((error) => '- $error').join('\n')}';
}

enum HarborLayoutCoordinateUnit {
  scenePixels,
  nodeRelativeLogicalDp,
  logicalDp,
}

/// A point whose [unit] is part of its runtime type contract and JSON record.
class HarborLayoutPoint {
  const HarborLayoutPoint(this.x, this.y, this.unit);

  final double x;
  final double y;
  final HarborLayoutCoordinateUnit unit;
}

/// The single cover transform shared by manifest geometry and renderers.
/// Scene points are scaled and translated; node-relative offsets are logical
/// dp and are added after projecting their node center.
class HarborSceneViewportTransform {
  const HarborSceneViewportTransform({
    required this.scale,
    required this.translationX,
    required this.translationY,
  });

  final double scale;
  final double translationX;
  final double translationY;

  HarborLayoutPoint projectScene(HarborLayoutPoint point) {
    if (point.unit != HarborLayoutCoordinateUnit.scenePixels) {
      throw ArgumentError.value(
        point.unit,
        'point.unit',
        'Expected scenePixels',
      );
    }
    return HarborLayoutPoint(
      translationX + point.x * scale,
      translationY + point.y * scale,
      HarborLayoutCoordinateUnit.logicalDp,
    );
  }

  HarborLayoutPoint projectNodeOffset(
    HarborLayoutPoint nodeCenter,
    HarborLayoutPoint offset,
  ) {
    if (offset.unit != HarborLayoutCoordinateUnit.nodeRelativeLogicalDp) {
      throw ArgumentError.value(
        offset.unit,
        'offset.unit',
        'Expected nodeRelativeLogicalDp',
      );
    }
    final center = projectScene(nodeCenter);
    return HarborLayoutPoint(
      center.x + offset.x,
      center.y + offset.y,
      HarborLayoutCoordinateUnit.logicalDp,
    );
  }
}

class HarborLayoutNode {
  const HarborLayoutNode({
    required this.levelId,
    required this.center,
    required this.connectionAnchor,
    required this.starAnchor,
    this.challengeAnchor,
  });

  final String levelId;

  /// Absolute point in the segment's canonical scene coordinate space.
  final HarborLayoutPoint center;

  /// Explicit route attachment point. It may be on the node ring rather than
  /// at its center. Adjacent connection endpoints must match within
  /// [HarborLayoutManifest.connectionAnchorToleranceScenePx].
  final HarborLayoutPoint connectionAnchor;

  /// Node-relative logical-dp offset. It is added after scene projection;
  /// it must not be scaled as if it were a scene-pixel point.
  final HarborLayoutPoint starAnchor;

  /// Optional visual anchor only. It does not declare that this level is a
  /// challenge; that type remains owned by production content.
  final HarborLayoutPoint? challengeAnchor;
}

class HarborLayoutConnection {
  const HarborLayoutConnection({
    required this.fromLevelId,
    required this.toLevelId,
    required this.start,
    required this.control1,
    required this.control2,
    required this.end,
  });

  final String fromLevelId;
  final String toLevelId;
  final HarborLayoutPoint start;
  final HarborLayoutPoint control1;
  final HarborLayoutPoint control2;
  final HarborLayoutPoint end;
}

class HarborLayoutScene {
  const HarborLayoutScene({
    required this.assetPath,
    required this.coordinateSpace,
    required this.width,
    required this.height,
    required this.sha256,
  });

  final String assetPath;
  final String coordinateSpace;
  final int width;
  final int height;
  final String sha256;
}

/// A strictly parsed, validated Harbor segment geometry document.
///
/// The manifest is intentionally limited to scene/layout data. It cannot
/// define unlocks, challenge types, earned stars, content, or persistence.
class HarborLayoutManifest {
  const HarborLayoutManifest._({
    required this.schemaVersion,
    required this.routeId,
    required this.segmentIndex,
    required this.scene,
    required this.nodes,
    required this.connections,
    required this.minimumHitTargetLogicalDp,
  });

  static const int currentSchemaVersion = 2;
  static const String harborRouteId = 'baslangic-limani';
  static const int harborSceneWidth = 941;
  static const int harborSceneHeight = 1672;
  static const double connectionAnchorToleranceScenePx = 0.01;
  static const double nodeRingSizeLogicalDp = 54;
  static const double nodeHitboxSizeLogicalDp = 68;
  static const double connectionAnchorRadiusToleranceLogicalDp = 0.001;
  static const double narrowReviewViewportWidth = 360;
  static const double narrowReviewViewportHeight = 800;
  static const double wideReviewViewportWidth = 412;
  static const double wideReviewViewportHeight = 915;
  static const String segment2SceneSha256 =
      'cd115f2eb3866beb4e1375ad545e31c23dce60b02d23d960f9b46b9c5828b566';
  static const String segment3SceneSha256 =
      '230ea2158d8173029123dfb6b68593c2b015d4f278ad524b94221c8de9ae231c';

  static String? expectedSceneAssetSha256(String assetPath) {
    if (assetPath == 'assets/word_hunt/harbor_segments/segment_02_clean.webp') {
      return segment2SceneSha256;
    }
    if (assetPath == 'assets/word_hunt/harbor_segments/segment_03_clean.webp') {
      return segment3SceneSha256;
    }
    for (final descriptor in WordHuntHarborSegmentRegistry.premiumSegments.values) {
      if (descriptor.sceneAsset == assetPath) return descriptor.sceneSha256;
    }
    return null;
  }

  /// Matches the production scene's cover transform: the larger of the width
  /// and height ratios is used, then the scene is centered and clipped.
  static double sceneToViewportScale({
    required double viewportWidth,
    required double viewportHeight,
  }) {
    final widthScale = viewportWidth / harborSceneWidth;
    final heightScale = viewportHeight / harborSceneHeight;
    return widthScale > heightScale ? widthScale : heightScale;
  }

  static HarborSceneViewportTransform sceneToViewportTransform({
    required double sceneWidth,
    required double sceneHeight,
    required double viewportWidth,
    required double viewportHeight,
  }) {
    final widthScale = viewportWidth / sceneWidth;
    final heightScale = viewportHeight / sceneHeight;
    final scale = widthScale > heightScale ? widthScale : heightScale;
    return HarborSceneViewportTransform(
      scale: scale,
      translationX: (viewportWidth - sceneWidth * scale) / 2,
      translationY: (viewportHeight - sceneHeight * scale) / 2,
    );
  }

  /// Conservative ring-boundary distance in scene pixels. The largest target
  /// viewport scale sets the strictest scene-space offset limit.
  static double get maximumConnectionAnchorDistanceScenePx {
    final narrowScale = sceneToViewportScale(
      viewportWidth: narrowReviewViewportWidth,
      viewportHeight: narrowReviewViewportHeight,
    );
    final wideScale = sceneToViewportScale(
      viewportWidth: wideReviewViewportWidth,
      viewportHeight: wideReviewViewportHeight,
    );
    final worstScale = narrowScale > wideScale ? narrowScale : wideScale;
    return (nodeRingSizeLogicalDp / 2) / worstScale;
  }

  static bool isConnectionAnchorInsideNode({
    required HarborLayoutPoint center,
    required HarborLayoutPoint anchor,
  }) {
    final dx = anchor.x - center.x;
    final dy = anchor.y - center.y;
    final distanceScenePxSquared = dx * dx + dy * dy;
    for (final viewport in const <(double, double)>[
      (narrowReviewViewportWidth, narrowReviewViewportHeight),
      (wideReviewViewportWidth, wideReviewViewportHeight),
    ]) {
      final scale = sceneToViewportScale(
        viewportWidth: viewport.$1,
        viewportHeight: viewport.$2,
      );
      final distanceLogicalDp = distanceScenePxSquared * scale * scale;
      final visualRadius = nodeRingSizeLogicalDp / 2;
      final hitboxRadius = nodeHitboxSizeLogicalDp / 2;
      final allowedRadius =
          visualRadius + connectionAnchorRadiusToleranceLogicalDp;
      if (distanceLogicalDp > allowedRadius * allowedRadius ||
          distanceLogicalDp > hitboxRadius * hitboxRadius) {
        return false;
      }
    }
    return true;
  }

  final int schemaVersion;
  final String routeId;
  final int segmentIndex;
  final HarborLayoutScene scene;
  final List<HarborLayoutNode> nodes;
  final List<HarborLayoutConnection> connections;
  final double minimumHitTargetLogicalDp;

  static HarborLayoutManifest parseJson(
    String source, {
    required HarborSceneAssetResolver resolveAsset,
  }) {
    Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException catch (error) {
      throw HarborLayoutValidationException(<String>[
        'JSON parse error: ${error.message}',
      ]);
    }
    return parse(decoded, resolveAsset: resolveAsset);
  }

  static HarborLayoutManifest parse(
    Object? value, {
    required HarborSceneAssetResolver resolveAsset,
  }) {
    final errors = validate(value, resolveAsset: resolveAsset);
    if (errors.isNotEmpty) {
      throw HarborLayoutValidationException(List<String>.unmodifiable(errors));
    }

    final root = value! as Map<String, Object?>;
    final sceneJson = root['scene']! as Map<String, Object?>;
    final canvas = sceneJson['coordinateSize']! as List<Object?>;
    final segment = root['segmentIndex']! as int;
    final scene = HarborLayoutScene(
      assetPath: sceneJson['assetPath']! as String,
      coordinateSpace: sceneJson['coordinateSpace']! as String,
      width: canvas[0]! as int,
      height: canvas[1]! as int,
      sha256: sceneJson['sha256']! as String,
    );
    final nodes = (root['nodes']! as List<Object?>)
        .map((entry) {
          final node = entry! as Map<String, Object?>;
          return HarborLayoutNode(
            levelId: node['levelId']! as String,
            center: _point(node['center']),
            connectionAnchor: _point(node['connectionAnchor']),
            starAnchor: _point(node['starAnchor']),
            challengeAnchor:
                node['challengeAnchor'] == null
                    ? null
                    : _point(node['challengeAnchor']),
          );
        })
        .toList(growable: false);
    final connections = (root['connections']! as List<Object?>)
        .map((entry) {
          final connection = entry! as Map<String, Object?>;
          return HarborLayoutConnection(
            fromLevelId: connection['fromLevelId']! as String,
            toLevelId: connection['toLevelId']! as String,
            start: _point(connection['start']),
            control1: _point(connection['control1']),
            control2: _point(connection['control2']),
            end: _point(connection['end']),
          );
        })
        .toList(growable: false);

    return HarborLayoutManifest._(
      schemaVersion: root['schemaVersion']! as int,
      routeId: root['routeId']! as String,
      segmentIndex: segment,
      scene: scene,
      nodes: List<HarborLayoutNode>.unmodifiable(nodes),
      connections: List<HarborLayoutConnection>.unmodifiable(connections),
      minimumHitTargetLogicalDp:
          (root['minimumHitTargetLogicalDp']! as num).toDouble(),
    );
  }

  /// Returns all structural/semantic errors; any error makes [parse] fail
  /// closed. Asset bytes are not loaded here: the resolver must return trusted
  /// path, dimensions, and SHA-256 metadata for the exact asset.
  static List<String> validate(
    Object? value, {
    required HarborSceneAssetResolver resolveAsset,
  }) {
    final errors = <String>[];
    final root = _object(value, r'$', errors);
    if (root == null) return errors;
    _checkKeys(
      root,
      const <String>{
        'schemaVersion',
        'routeId',
        'segmentIndex',
        'scene',
        'minimumHitTargetLogicalDp',
        'nodes',
        'connections',
      },
      r'$',
      errors,
    );

    final schemaVersion = _integer(
      root['schemaVersion'],
      r'$.schemaVersion',
      errors,
    );
    if (schemaVersion != null && schemaVersion != currentSchemaVersion) {
      errors.add('\$.schemaVersion must equal $currentSchemaVersion.');
    }
    final routeId = _string(root['routeId'], r'$.routeId', errors);
    if (routeId != null && routeId != harborRouteId) {
      errors.add('\$.routeId must equal "$harborRouteId".');
    }
    final segment = _integer(root['segmentIndex'], r'$.segmentIndex', errors);
    if (segment != null && segment != 2 && segment != 3 &&
        WordHuntHarborSegmentRegistry.forSegment(segment) == null) {
      errors.add('\$.segmentIndex must resolve to a registered Harbor segment.');
    }
    final minimumHitTarget = _number(
      root['minimumHitTargetLogicalDp'],
      r'$.minimumHitTargetLogicalDp',
      errors,
    );
    if (minimumHitTarget != null && minimumHitTarget < 48) {
      errors.add(r'$.minimumHitTargetLogicalDp must be at least 48.');
    }

    final scene = _object(root['scene'], r'$.scene', errors);
    var width = 0;
    var height = 0;
    if (scene != null) {
      _checkKeys(
        scene,
        const <String>{
          'assetPath',
          'coordinateSpace',
          'coordinateSize',
          'sha256',
        },
        r'$.scene',
        errors,
      );
      final path = _string(scene['assetPath'], r'$.scene.assetPath', errors);
      final coordinateSpace = _string(
        scene['coordinateSpace'],
        r'$.scene.coordinateSpace',
        errors,
      );
      if (coordinateSpace != null && coordinateSpace != 'scenePixels') {
        errors.add(r'$.scene.coordinateSpace must equal "scenePixels".');
      }
      final sha = _string(scene['sha256'], r'$.scene.sha256', errors);
      final size = _array(
        scene['coordinateSize'],
        r'$.scene.coordinateSize',
        errors,
      );
      if (size != null) {
        if (size.length != 2) {
          errors.add(r'$.scene.coordinateSize must contain [width, height].');
        } else {
          width = _integer(size[0], r'$.scene.coordinateSize[0]', errors) ?? 0;
          height = _integer(size[1], r'$.scene.coordinateSize[1]', errors) ?? 0;
          if (width <= 0 || height <= 0) {
            errors.add(r'$.scene.coordinateSize values must be positive.');
          }
          if (width != harborSceneWidth || height != harborSceneHeight) {
            errors.add(
              r'$.scene.coordinateSize must equal [941, 1672] for Harbor art.',
            );
          }
        }
      }
      if (sha != null && !RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(sha)) {
        errors.add(
          r'$.scene.sha256 must be exactly 64 hexadecimal characters.',
        );
      }
      if (path != null && sha != null) {
        final expectedSha = expectedSceneAssetSha256(path);
        if (expectedSha != null && sha.toLowerCase() != expectedSha) {
          errors.add(
            '\$.scene.sha256 must match the approved bytes for "$path".',
          );
        }
      }
      if (path != null && segment != null &&
          (segment == 2 || segment == 3 ||
           WordHuntHarborSegmentRegistry.forSegment(segment) != null)) {
        final expectedPath =
            WordHuntHarborSegmentRegistry.forSegment(segment)?.sceneAsset ??
            'assets/word_hunt/harbor_segments/segment_0${segment}_clean.webp';
        if (path != expectedPath) {
          errors.add('\$.scene.assetPath must equal "$expectedPath".');
        }
        final metadata = resolveAsset(path);
        if (metadata == null) {
          errors.add(
            '\$.scene.assetPath does not resolve to a known scene asset.',
          );
        } else {
          if (metadata.assetPath != path) {
            errors.add(
              'Resolved scene asset identity does not match \$.scene.assetPath.',
            );
          }
          if (metadata.width != width || metadata.height != height) {
            errors.add(
              'Resolved scene asset dimensions do not match \$.scene.coordinateSize.',
            );
          }
          if (sha != null &&
              metadata.sha256.toLowerCase() != sha.toLowerCase()) {
            errors.add(
              'Resolved scene asset SHA-256 does not match \$.scene.sha256.',
            );
          }
        }
      }
    }

    final expectedStart = ((segment ?? 0) - 1) * 10 + 1;
    final expectedIds = <String>[
      for (var level = expectedStart; level < expectedStart + 10; level++)
        'baslangic-$level',
    ];
    final nodes = _array(root['nodes'], r'$.nodes', errors);
    final nodeIds = <String>[];
    final connectionAnchors = <String, HarborLayoutPoint>{};
    if (nodes != null) {
      if (nodes.length != 10)
        errors.add(r'$.nodes must contain exactly 10 nodes.');
      for (var index = 0; index < nodes.length; index++) {
        final path = r'$.nodes[' + '$index]';
        final node = _object(nodes[index], path, errors);
        if (node == null) continue;
        _checkKeys(
          node,
          const <String>{
            'levelId',
            'center',
            'connectionAnchor',
            'starAnchor',
            'challengeAnchor',
          },
          path,
          errors,
          required: const <String>{
            'levelId',
            'center',
            'connectionAnchor',
            'starAnchor',
          },
        );
        final id = _string(node['levelId'], '$path.levelId', errors);
        if (id != null) nodeIds.add(id);
        _checkPoint(
          node['center'],
          '$path.center',
          width,
          height,
          errors,
          expectedUnit: HarborLayoutCoordinateUnit.scenePixels,
        );
        _checkPoint(
          node['connectionAnchor'],
          '$path.connectionAnchor',
          width,
          height,
          errors,
          expectedUnit: HarborLayoutCoordinateUnit.scenePixels,
        );
        final connectionAnchor = _pointIfValid(node['connectionAnchor']);
        final center = _pointIfValid(node['center']);
        if (center != null &&
            connectionAnchor != null &&
            !isConnectionAnchorInsideNode(
              center: center,
              anchor: connectionAnchor,
            )) {
          errors.add(
            '$path.connectionAnchor must remain within the ${nodeRingSizeLogicalDp.toInt()} '
            'dp node ring and ${nodeHitboxSizeLogicalDp.toInt()} dp hitbox '
            'on ${narrowReviewViewportWidth.toInt()}x${narrowReviewViewportHeight.toInt()} '
            'and ${wideReviewViewportWidth.toInt()}x${wideReviewViewportHeight.toInt()} viewports.',
          );
        }
        if (id != null && connectionAnchor != null) {
          connectionAnchors[id] = connectionAnchor;
        }
        _checkPoint(
          node['starAnchor'],
          '$path.starAnchor',
          width,
          height,
          errors,
          expectedUnit: HarborLayoutCoordinateUnit.nodeRelativeLogicalDp,
        );
        if (node.containsKey('challengeAnchor') &&
            node['challengeAnchor'] != null) {
          _checkPoint(
            node['challengeAnchor'],
            '$path.challengeAnchor',
            width,
            height,
            errors,
            expectedUnit: HarborLayoutCoordinateUnit.nodeRelativeLogicalDp,
          );
        }
      }
      if (nodeIds.toSet().length != nodeIds.length)
        errors.add(r'$.nodes contains duplicate levelId values.');
      if (nodeIds.length == 10 && !_listEquals(nodeIds, expectedIds)) {
        errors.add(
          '\$.nodes levelId order must be ${expectedIds.join(', ')} for segment $segment.',
        );
      }
    }

    final connections = _array(root['connections'], r'$.connections', errors);
    if (connections != null) {
      if (connections.length != 9) {
        errors.add(
          r'$.connections must contain exactly 9 ordered connections.',
        );
      }
      for (var index = 0; index < connections.length; index++) {
        final path = r'$.connections[' + '$index]';
        final connection = _object(connections[index], path, errors);
        if (connection == null) continue;
        _checkKeys(
          connection,
          const <String>{
            'fromLevelId',
            'toLevelId',
            'start',
            'control1',
            'control2',
            'end',
          },
          path,
          errors,
        );
        final expectedFrom = expectedStart + index;
        final expectedTo = expectedFrom + 1;
        final from = _string(
          connection['fromLevelId'],
          '$path.fromLevelId',
          errors,
        );
        final to = _string(connection['toLevelId'], '$path.toLevelId', errors);
        if (from != null && from != 'baslangic-$expectedFrom') {
          errors.add('$path.fromLevelId must be baslangic-$expectedFrom.');
        }
        if (to != null && to != 'baslangic-$expectedTo') {
          errors.add('$path.toLevelId must be baslangic-$expectedTo.');
        }
        for (final pointName in const <String>[
          'start',
          'control1',
          'control2',
          'end',
        ]) {
          _checkPoint(
            connection[pointName],
            '$path.$pointName',
            width,
            height,
            errors,
            expectedUnit: HarborLayoutCoordinateUnit.scenePixels,
          );
        }
        final start = _pointIfValid(connection['start']);
        final end = _pointIfValid(connection['end']);
        final fromAnchor = from == null ? null : connectionAnchors[from];
        final toAnchor = to == null ? null : connectionAnchors[to];
        if (start != null &&
            fromAnchor != null &&
            !_pointsMatch(start, fromAnchor)) {
          errors.add(
            '$path.start must match the connectionAnchor of $from '
            '(tolerance ${connectionAnchorToleranceScenePx} scene px).',
          );
        }
        if (end != null && toAnchor != null && !_pointsMatch(end, toAnchor)) {
          errors.add(
            '$path.end must match the connectionAnchor of $to '
            '(tolerance ${connectionAnchorToleranceScenePx} scene px).',
          );
        }
      }
    }

    return List<String>.unmodifiable(errors);
  }

  static HarborLayoutPoint _point(Object? value) {
    final point = value! as Map<String, Object?>;
    return HarborLayoutPoint(
      (point['x']! as num).toDouble(),
      (point['y']! as num).toDouble(),
      _coordinateUnit(point['unit']! as String),
    );
  }

  static HarborLayoutPoint? _pointIfValid(Object? value) {
    if (value is! Map<String, Object?>) return null;
    final x = value['x'];
    final y = value['y'];
    final unit = value['unit'];
    if (x is! num ||
        y is! num ||
        !x.isFinite ||
        !y.isFinite ||
        unit is! String ||
        !_knownCoordinateUnit(unit)) {
      return null;
    }
    return HarborLayoutPoint(x.toDouble(), y.toDouble(), _coordinateUnit(unit));
  }

  static HarborLayoutCoordinateUnit _coordinateUnit(
    String value,
  ) => switch (value) {
    'scenePixels' => HarborLayoutCoordinateUnit.scenePixels,
    'nodeRelativeLogicalDp' => HarborLayoutCoordinateUnit.nodeRelativeLogicalDp,
    _ =>
      throw ArgumentError.value(
        value,
        'unit',
        'Unsupported Harbor coordinate unit',
      ),
  };

  static bool _knownCoordinateUnit(String value) =>
      value == 'scenePixels' || value == 'nodeRelativeLogicalDp';

  static bool _pointsMatch(HarborLayoutPoint first, HarborLayoutPoint second) =>
      (first.x - second.x).abs() <= connectionAnchorToleranceScenePx &&
      (first.y - second.y).abs() <= connectionAnchorToleranceScenePx;

  static Map<String, Object?>? _object(
    Object? value,
    String path,
    List<String> errors,
  ) {
    if (value is Map<String, Object?>) return value;
    errors.add('$path must be a JSON object.');
    return null;
  }

  static List<Object?>? _array(
    Object? value,
    String path,
    List<String> errors,
  ) {
    if (value is List<Object?>) return value;
    errors.add('$path must be a JSON array.');
    return null;
  }

  static void _checkKeys(
    Map<String, Object?> value,
    Set<String> allowed,
    String path,
    List<String> errors, {
    Set<String>? required,
  }) {
    final mustExist = required ?? allowed;
    for (final key in mustExist) {
      if (!value.containsKey(key)) errors.add('$path.$key is required.');
    }
    for (final key in value.keys) {
      if (!allowed.contains(key)) errors.add('$path.$key is not supported.');
    }
  }

  static String? _string(Object? value, String path, List<String> errors) {
    if (value is String && value.trim().isNotEmpty) return value;
    errors.add('$path must be a non-empty string.');
    return null;
  }

  static int? _integer(Object? value, String path, List<String> errors) {
    if (value is int) return value;
    errors.add('$path must be an integer.');
    return null;
  }

  static double? _number(Object? value, String path, List<String> errors) {
    if (value is num && value.isFinite) return value.toDouble();
    errors.add('$path must be a finite number.');
    return null;
  }

  static void _checkPoint(
    Object? value,
    String path,
    int width,
    int height,
    List<String> errors, {
    required HarborLayoutCoordinateUnit expectedUnit,
  }) {
    final point = _object(value, path, errors);
    if (point == null) return;
    _checkKeys(point, const <String>{'unit', 'x', 'y'}, path, errors);
    final unit = _string(point['unit'], '$path.unit', errors);
    final expectedName = switch (expectedUnit) {
      HarborLayoutCoordinateUnit.scenePixels => 'scenePixels',
      HarborLayoutCoordinateUnit.nodeRelativeLogicalDp =>
        'nodeRelativeLogicalDp',
      HarborLayoutCoordinateUnit.logicalDp => 'logicalDp',
    };
    if (unit != null && unit != expectedName) {
      errors.add('$path.unit must equal "$expectedName".');
    }
    final x = _number(point['x'], '$path.x', errors);
    final y = _number(point['y'], '$path.y', errors);
    if (expectedUnit == HarborLayoutCoordinateUnit.scenePixels &&
        x != null &&
        (x < 0 || x > width)) {
      errors.add('$path.x must be within the scene (0..$width).');
    }
    if (expectedUnit == HarborLayoutCoordinateUnit.scenePixels &&
        y != null &&
        (y < 0 || y > height)) {
      errors.add('$path.y must be within the scene (0..$height).');
    }
  }

  static bool _listEquals(List<String> first, List<String> second) {
    if (first.length != second.length) return false;
    for (var index = 0; index < first.length; index++) {
      if (first[index] != second[index]) return false;
    }
    return true;
  }
}
