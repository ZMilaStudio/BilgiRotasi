import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'word_hunt_journey_geometry.dart';
import 'word_hunt_journey_theme.dart';

/// Presentation only. The base is a vertically seamless, low-frequency tile.
class JourneyArtKit {
  JourneyArtKit({
    required this.themeId,
    required this.baseAtmosphere,
    List<JourneyArtAsset> leftEnvironment = const [],
    List<JourneyArtAsset> rightEnvironment = const [],
    this.atmosphereOverlay,
    Map<int, JourneyArtAsset> landmarkAssets = const {},
    this.transitionPartner,
    this.environmentWidthFraction = .32,
    this.corridorWidth = 104,
    this.corridorOpacity = .28,
  }) : leftEnvironment = List.unmodifiable(leftEnvironment),
       rightEnvironment = List.unmodifiable(rightEnvironment),
       landmarkAssets = Map.unmodifiable(landmarkAssets) {
    if (themeId.isEmpty ||
        !environmentWidthFraction.isFinite ||
        environmentWidthFraction <= 0 ||
        environmentWidthFraction > .45 ||
        !corridorWidth.isFinite ||
        corridorWidth < 68 ||
        corridorWidth > 160 ||
        !corridorOpacity.isFinite ||
        corridorOpacity < 0 ||
        corridorOpacity > .45 ||
        landmarkAssets.keys.any((n) => n < 1)) {
      throw ArgumentError('Invalid Journey art kit policy.');
    }
  }
  final String themeId;
  final JourneyArtAsset baseAtmosphere;
  final List<JourneyArtAsset> leftEnvironment, rightEnvironment;
  final JourneyArtAsset? atmosphereOverlay;
  final Map<int, JourneyArtAsset> landmarkAssets;
  final String? transitionPartner;
  final double environmentWidthFraction, corridorWidth, corridorOpacity;
  Iterable<JourneyArtAsset> get assets sync* {
    yield baseAtmosphere;
    yield* leftEnvironment;
    yield* rightEnvironment;
    if (atmosphereOverlay != null) yield atmosphereOverlay!;
    yield* landmarkAssets.values;
  }

  JourneyArtAsset? variant(List<JourneyArtAsset> list, int ordinal) =>
      list.isEmpty ? null : list[((ordinal - 1) ~/ 4) % list.length];
}

class JourneyArtRegistry {
  JourneyArtRegistry(Iterable<JourneyArtKit> kits) {
    final paths = <String>{}, owners = <int>{};
    for (final kit in kits) {
      if (_kits.containsKey(kit.themeId)) {
        throw ArgumentError('Duplicate theme.');
      }
      for (final asset in kit.assets) {
        if (!paths.add(asset.path)) {
          throw ArgumentError('Duplicate asset path.');
        }
      }
      for (final n in kit.landmarkAssets.keys) {
        if (!owners.add(n)) {
          throw ArgumentError('Duplicate landmark ownership.');
        }
      }
      _kits[kit.themeId] = kit;
    }
    for (final kit in _kits.values) {
      if (kit.transitionPartner != null &&
          !_kits.containsKey(kit.transitionPartner)) {
        throw ArgumentError('Missing transition partner.');
      }
    }
  }
  final _kits = <String, JourneyArtKit>{};
  JourneyArtKit? operator [](String id) => _kits[id];

  void validateForSchedule(JourneyThemeSchedule schedule) {
    final themeIds = {
      ...schedule.themes.map((t) => t.id),
      ...schedule.bands.map((b) => b.theme.id),
    };
    for (final kit in _kits.values) {
      if (!themeIds.contains(kit.themeId)) {
        throw ArgumentError(
          'Art theme is absent from the presentation schedule.',
        );
      }
      for (final ordinal in kit.landmarkAssets.keys) {
        if (schedule.landmarkForOrdinal(ordinal) == null ||
            schedule.themeForOrdinal(ordinal).id != kit.themeId) {
          throw ArgumentError('Landmark must belong to its scheduled theme.');
        }
      }
    }
  }

  /// Export outside the repo in an installation test, alongside the actual
  /// target Flutter AssetManifest.listAssets(); validated by Python tooling.
  Map<String, Object> installationManifest() => {
    'kits': [
      for (final kit in _kits.values)
        {
          'themeId': kit.themeId,
          'transitionPartner': kit.transitionPartner,
          'landmarks': kit.landmarkAssets.keys.toList(),
          'assets': [
            for (final asset in kit.assets)
              {
                'path': asset.path,
                'sha256': asset.sha256,
                'intrinsicSize': [
                  asset.intrinsicSize.width,
                  asset.intrinsicSize.height,
                ],
                'focalPoint': [asset.focalPoint.x, asset.focalPoint.y],
              },
          ],
        },
    ],
  };

  /// No owner-approved raster assets installed. Never claim raster activation.
  static final production = JourneyArtRegistry(const []);
}

typedef JourneyArtProvider = ImageProvider Function(JourneyArtAsset asset);

/// Only visible/one-row-near resources; Flutter owns its normal image cache.
/// A large/unsupported viewport falls back rather than decoding unbounded art.
class JourneyRasterBackground extends StatefulWidget {
  const JourneyRasterBackground({
    super.key,
    required this.registry,
    required this.schedule,
    required this.geometry,
    required this.chunk,
    required this.count,
    required this.width,
    required this.visible,
    this.provider,
  });
  final JourneyArtRegistry registry;
  final JourneyThemeSchedule schedule;
  final WordHuntJourneyGeometry geometry;
  final int chunk, count;
  final double width;
  final Rect visible;
  final JourneyArtProvider? provider;
  static const maxBaseResources = 2, maxResources = 16;
  @override
  State<JourneyRasterBackground> createState() => _RasterState();
}

class _RasterState extends State<JourneyRasterBackground> {
  final _streams = <String, (ImageStream, ImageStreamListener)>{};
  final _images = <String, ui.Image>{};
  final _failed = <String>{};
  bool _overflow = false;
  Set<int> get _rows {
    final first = widget.chunk * widget.geometry.levelsPerChunk + 1;
    final last = math.min(
      widget.count,
      first + widget.geometry.levelsPerChunk - 1,
    );
    return {
      for (var n = first; n <= last; n++)
        if (Rect.fromLTWH(
          0,
          (n - 1) * widget.geometry.rowPitch,
          widget.width,
          widget.geometry.rowPitch,
        ).overlaps(widget.visible.inflate(widget.geometry.rowPitch)))
          n,
    };
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(covariant JourneyRasterBackground old) {
    super.didUpdateWidget(old);
    if (old.provider != widget.provider || old.registry != widget.registry)
      _clear();
    _sync();
  }

  void _clear() {
    for (final pair in _streams.values) {
      pair.$1.removeListener(pair.$2);
    }
    _streams.clear();
    for (final image in _images.values) {
      image.dispose();
    }
    _images.clear();
    _failed.clear();
  }

  void _sync() {
    widget.registry.validateForSchedule(widget.schedule);
    final wanted = <String, JourneyArtAsset>{}, bases = <String>{};
    for (final n in _rows) {
      final frame = widget.schedule.transitionForOrdinal(n);
      for (final id in {frame.from.id, frame.to.id}) {
        final kit = widget.registry[id];
        if (kit == null) continue;
        void add(JourneyArtAsset? asset) {
          if (asset != null) wanted[asset.path] = asset;
        }

        bases.add(kit.baseAtmosphere.path);
        add(kit.baseAtmosphere);
        add(kit.variant(kit.leftEnvironment, n));
        add(kit.variant(kit.rightEnvironment, n));
        add(kit.atmosphereOverlay);
        // Exactly one ordinal owns a landmark, never both transition themes.
        if (id == widget.schedule.themeForOrdinal(n).id)
          add(kit.landmarkAssets[n]);
      }
    }
    _overflow =
        bases.length > JourneyRasterBackground.maxBaseResources ||
        wanted.length > JourneyRasterBackground.maxResources;
    if (_overflow) wanted.clear();
    for (final key in _streams.keys.toList()) {
      if (!wanted.containsKey(key)) {
        final pair = _streams.remove(key)!;
        pair.$1.removeListener(pair.$2);
        _images.remove(key)?.dispose();
        _failed.remove(key);
      }
    }
    for (final asset in wanted.values) {
      if (_streams.containsKey(asset.path)) continue;
      final provider = widget.provider?.call(asset) ?? AssetImage(asset.path);
      final stream = ResizeImage(
        provider,
        width: 768,
        height: 1024,
        policy: ResizeImagePolicy.fit,
        allowUpscaling: false,
      ).resolve(createLocalImageConfiguration(context));
      final listener = ImageStreamListener(
        (info, synchronous) {
          _images.remove(asset.path)?.dispose();
          _images[asset.path] = info.image.clone();
          info.dispose();
          if (!synchronous && mounted) setState(() {});
        },
        onError: (Object error, StackTrace? stack) {
          _failed.add(asset.path);
          if (mounted) setState(() {});
        },
      );
      _streams[asset.path] = (stream, listener);
      stream.addListener(listener);
    }
  }

  @override
  void dispose() {
    _clear();
    super.dispose();
  }

  bool get _hasBase => _rows.any((n) {
    final frame = widget.schedule.transitionForOrdinal(n);
    return {frame.from.id, frame.to.id}.any((id) {
      final kit = widget.registry[id];
      return kit != null && _images.containsKey(kit.baseAtmosphere.path);
    });
  });

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: ExcludeSemantics(
      child: CustomPaint(
        key: ValueKey(
          _overflow
              ? 'journey_art_resource_fallback'
              : _failed.isNotEmpty
              ? 'journey_art_missing_fallback'
              : !_hasBase
              ? 'journey_art_procedural_fallback'
              : 'journey_art_raster_active',
        ),
        painter: JourneyRasterPainter(
          registry: widget.registry,
          schedule: widget.schedule,
          geometry: widget.geometry,
          chunk: widget.chunk,
          count: widget.count,
          width: widget.width,
          rows: _rows,
          images: Map.of(_images),
        ),
      ),
    ),
  );
}

class JourneyRasterPainter extends CustomPainter {
  JourneyRasterPainter({
    required this.registry,
    required this.schedule,
    required this.geometry,
    required this.chunk,
    required this.count,
    required this.width,
    required this.rows,
    required this.images,
  });
  final JourneyArtRegistry registry;
  final JourneyThemeSchedule schedule;
  final WordHuntJourneyGeometry geometry;
  final int chunk, count;
  final double width;
  final Set<int> rows;
  final Map<String, ui.Image> images;
  @override
  void paint(Canvas canvas, Size size) {
    final first = chunk * geometry.levelsPerChunk + 1;
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    for (final n in rows) {
      final t = schedule.transitionForOrdinal(n);
      final prior = schedule.transitionForOrdinal(math.max(1, n - 1));
      final rect = Rect.fromLTWH(
        0,
        (n - first) * geometry.rowPitch,
        width,
        geometry.rowPitch,
      );
      for (final id in {t.from.id, t.to.id}) {
        final kit = registry[id];
        if (kit == null || !images.containsKey(kit.baseAtmosphere.path))
          continue;
        double weight(JourneyThemeTransition f) =>
            f.from.id == f.to.id
                ? (id == f.to.id ? 1 : 0)
                : id == f.to.id
                ? f.mix
                : id == f.from.id
                ? 1 - f.mix
                : 0;
        canvas.save();
        canvas.clipRect(rect);
        canvas.saveLayer(rect, Paint());
        void tile(JourneyArtAsset asset) {
          final image = images[asset.path];
          if (image == null) return;
          final height = width * image.height / image.width;
          final phase = ((n - 1) * geometry.rowPitch) % height;
          paintImage(
            canvas: canvas,
            rect: Rect.fromLTWH(
              0,
              rect.top - phase,
              width,
              height + geometry.rowPitch,
            ),
            image: image,
            fit: BoxFit.fitWidth,
            alignment: Alignment.topCenter,
            repeat: ImageRepeat.repeatY,
            filterQuality: FilterQuality.low,
          );
        }

        tile(kit.baseAtmosphere);
        void side(JourneyArtAsset? asset, bool right) {
          final image = asset == null ? null : images[asset.path];
          if (image == null) return;
          final w = width * kit.environmentWidthFraction;
          final group = (n - 1) ~/ 4 * 4 + 1;
          paintImage(
            canvas: canvas,
            rect: Rect.fromLTWH(
              right ? width - w : 0,
              (group - first) * geometry.rowPitch,
              w,
              4 * geometry.rowPitch,
            ),
            image: image,
            fit: asset!.fit,
            alignment: asset.focalPoint,
          );
        }

        side(kit.variant(kit.leftEnvironment, n), false);
        side(kit.variant(kit.rightEnvironment, n), true);
        if (kit.atmosphereOverlay != null) tile(kit.atmosphereOverlay!);
        final landmark = kit.landmarkAssets[n];
        if (id == schedule.themeForOrdinal(n).id && landmark != null) {
          final image = images[landmark.path];
          if (image != null)
            paintImage(
              canvas: canvas,
              rect: Rect.fromLTWH(
                n.isEven ? width * .65 : 0,
                rect.top,
                width * .35,
                geometry.rowPitch,
              ),
              image: image,
              fit: landmark.fit,
              alignment: landmark.focalPoint,
            );
        }
        canvas.drawRect(
          rect,
          Paint()
            ..blendMode = BlendMode.dstIn
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: weight(prior)),
                Colors.white.withValues(alpha: weight(t)),
              ],
            ).createShader(rect),
        );
        canvas.restore();
        canvas.restore();
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant JourneyRasterPainter old) => true;
}

/// Soft route-following veil, below the existing outlined route and opaque nodes.
class JourneyReadabilityCorridor extends CustomPainter {
  JourneyReadabilityCorridor({
    required this.geometry,
    required this.chunk,
    required this.count,
    required this.width,
    required this.schedule,
    required this.registry,
  });
  final WordHuntJourneyGeometry geometry;
  final int chunk, count;
  final double width;
  final JourneyThemeSchedule schedule;
  final JourneyArtRegistry registry;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    final first = math.max(1, chunk * geometry.levelsPerChunk);
    final last = math.min(count - 1, (chunk + 1) * geometry.levelsPerChunk);
    // Full boundary curves supply blur support outside the clip; no veil seam.
    for (var ordinal = first; ordinal <= last; ordinal++) {
      final curve = geometry
          .curveForEdge(ordinal, width)
          .shift(Offset(0, -chunk * geometry.chunkExtent));
      final kit = registry[schedule.themeForOrdinal(math.max(1, ordinal)).id];
      final path =
          Path()
            ..moveTo(curve.start.dx, curve.start.dy)
            ..cubicTo(
              curve.control1.dx,
              curve.control1.dy,
              curve.control2.dx,
              curve.control2.dy,
              curve.end.dx,
              curve.end.dy,
            );
      canvas.drawPath(
        path,
        Paint()
          ..color = const Color(
            0xFF08121D,
          ).withValues(alpha: kit?.corridorOpacity ?? .28)
          ..style = PaintingStyle.stroke
          ..strokeWidth = kit?.corridorWidth ?? 104
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant JourneyReadabilityCorridor old) => true;
}
