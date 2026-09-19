import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const lockedAssets = <_LockedAsset>[
    _LockedAsset(
      path: 'assets/word_hunt/KAYIP_SEHIR_ENV_941x1672.webp',
      byteCount: 2092556,
      sha256Hex:
          '0f22a3c56060ce19febaef552458657630751cb4ab016d0884a21d37178eb314',
    ),
    _LockedAsset(
      path: 'assets/word_hunt/YERALTI_KRALLIGI_ENV_941x1672.webp',
      byteCount: 2238174,
      sha256Hex:
          '9d99111c7a949519745e44d4386fd0cdab774e10e74bc30e34fee9e410ca3fb5',
    ),
    _LockedAsset(
      path: 'assets/word_hunt/GUNES_IMPARATORLUGU_ENV_941x1672.webp',
      byteCount: 1774348,
      sha256Hex:
          '4515ece9196cbb0699366b37cb46ca28f3d4f453b489c3983dc69c5261d48bf9',
    ),
  ];

  for (final asset in lockedAssets) {
    test('${asset.path} keeps exact immutable WebP identity', () {
      final file = File(asset.path);
      expect(file.existsSync(), isTrue, reason: asset.path);

      final bytes = file.readAsBytesSync();
      expect(bytes.length, asset.byteCount);
      expect(_ascii(bytes, 0, 4), 'RIFF');
      expect(_ascii(bytes, 8, 4), 'WEBP');

      final chunks = _webpChunks(bytes);
      expect(chunks, isNotEmpty);
      expect(chunks.first.name, 'VP8L');
      expect(chunks.where((chunk) => chunk.name == 'VP8L'), hasLength(1));
      expect(chunks.any((chunk) => chunk.name == 'ANIM'), isFalse);
      expect(chunks.any((chunk) => chunk.name == 'ANMF'), isFalse);

      final dimensions = _vp8lDimensions(bytes, chunks.first.payloadOffset);
      expect(dimensions.width, 941);
      expect(dimensions.height, 1672);

      expect(sha256.convert(bytes).toString(), asset.sha256Hex);
    });
  }
}

class _LockedAsset {
  const _LockedAsset({
    required this.path,
    required this.byteCount,
    required this.sha256Hex,
  });

  final String path;
  final int byteCount;
  final String sha256Hex;
}

class _WebpChunk {
  const _WebpChunk({
    required this.name,
    required this.payloadOffset,
    required this.payloadSize,
  });

  final String name;
  final int payloadOffset;
  final int payloadSize;
}

List<_WebpChunk> _webpChunks(Uint8List bytes) {
  final chunks = <_WebpChunk>[];
  var offset = 12;

  while (offset + 8 <= bytes.length) {
    final name = _ascii(bytes, offset, 4);
    final size = ByteData.sublistView(
      bytes,
      offset + 4,
      offset + 8,
    ).getUint32(0, Endian.little);
    final payloadOffset = offset + 8;
    expect(
      payloadOffset + size,
      lessThanOrEqualTo(bytes.length),
      reason: 'Invalid WebP chunk size for $name',
    );
    chunks.add(
      _WebpChunk(
        name: name,
        payloadOffset: payloadOffset,
        payloadSize: size,
      ),
    );
    offset = payloadOffset + size + (size.isOdd ? 1 : 0);
  }

  return chunks;
}

({int width, int height}) _vp8lDimensions(
  Uint8List bytes,
  int payloadOffset,
) {
  expect(bytes[payloadOffset], 0x2F, reason: 'VP8L signature byte');
  final b1 = bytes[payloadOffset + 1];
  final b2 = bytes[payloadOffset + 2];
  final b3 = bytes[payloadOffset + 3];
  final b4 = bytes[payloadOffset + 4];

  final width = 1 + (b1 | ((b2 & 0x3F) << 8));
  final height =
      1 + ((b2 >> 6) | (b3 << 2) | ((b4 & 0x0F) << 10));
  return (width: width, height: height);
}

String _ascii(Uint8List bytes, int offset, int length) {
  return ascii.decode(bytes.sublist(offset, offset + length));
}
