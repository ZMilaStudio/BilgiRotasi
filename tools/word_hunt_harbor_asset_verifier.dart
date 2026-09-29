import 'dart:io';

import 'package:crypto/crypto.dart';

import '../packages/word_hunt_flutter_feature/lib/word_hunt_harbor_layout_manifest.dart';

/// Repository/tool-layer verifier for the approved Harbor scene asset bytes.
///
/// The manifest model stays filesystem- and Flutter-independent. This adapter
/// reads the actual asset bytes, hashes them, and returns trusted metadata only
/// when the digest matches the reviewed per-segment pin.
class HarborSceneAssetByteVerifier {
  const HarborSceneAssetByteVerifier._();

  static HarborSceneAssetMetadata? resolveBytes(
    String assetPath,
    List<int> bytes,
  ) {
    final expectedSha256 = HarborLayoutManifest.expectedSceneAssetSha256(
      assetPath,
    );
    if (expectedSha256 == null || bytes.isEmpty) return null;

    final actualSha256 = sha256.convert(bytes).toString();
    if (actualSha256 != expectedSha256) return null;

    // These dimensions are bound to the reviewed asset by the pinned digest.
    return HarborSceneAssetMetadata(
      assetPath: assetPath,
      width: HarborLayoutManifest.harborSceneWidth,
      height: HarborLayoutManifest.harborSceneHeight,
      sha256: actualSha256,
    );
  }

  static Future<HarborSceneAssetMetadata?> resolveFile({
    required String repositoryRoot,
    required String assetPath,
  }) async {
    if (HarborLayoutManifest.expectedSceneAssetSha256(assetPath) == null) {
      return null;
    }
    final relativePath = assetPath.split('/').join(Platform.pathSeparator);
    final file = File('$repositoryRoot${Platform.pathSeparator}$relativePath');
    if (!await file.exists()) return null;
    return resolveBytes(assetPath, await file.readAsBytes());
  }
}
