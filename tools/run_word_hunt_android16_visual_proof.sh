#!/usr/bin/env bash
set -eu

mkdir -p reports

wait_for_app_drawn() {
  local snapshot="$1"
  local label="$2"
  local drawn=0

  for attempt in $(seq 1 30); do
    adb shell dumpsys activity activities > "$snapshot"
    if grep -Fq 'com.leventua.bilgirotasi/.MainActivity' "$snapshot" \
      && grep -q 'reportedDrawn=true' "$snapshot"; then
      drawn=1
      echo "$label first frame confirmed on attempt $attempt"
      break
    fi
    sleep 1
  done

  if [ "$drawn" -ne 1 ]; then
    echo "$label never reached reportedDrawn=true" >&2
    cat "$snapshot" >&2
    return 1
  fi

  grep -Fq 'com.leventua.bilgirotasi/.MainActivity' "$snapshot"
  grep -Eq 'mResumedActivity.*com\.leventua\.bilgirotasi|topResumedActivity=.*com\.leventua\.bilgirotasi|mCurrentFocus=.*com\.leventua\.bilgirotasi' "$snapshot"
  sleep 1
}

validate_nonblack_png() {
  local png="$1"
  local metrics="$2"

  python3 - "$png" > "$metrics" <<'PY'
import struct
import sys
import zlib

path = sys.argv[1]
data = open(path, 'rb').read()
if data[:8] != b'\x89PNG\r\n\x1a\n':
    raise SystemExit('not a PNG')

pos = 8
width = height = bit_depth = color_type = interlace = None
idat = bytearray()
while pos + 12 <= len(data):
    length = struct.unpack('>I', data[pos:pos + 4])[0]
    kind = data[pos + 4:pos + 8]
    payload = data[pos + 8:pos + 8 + length]
    pos += 12 + length
    if kind == b'IHDR':
        width, height, bit_depth, color_type, _, _, interlace = struct.unpack(
            '>IIBBBBB', payload
        )
    elif kind == b'IDAT':
        idat.extend(payload)
    elif kind == b'IEND':
        break

channels_by_type = {0: 1, 2: 3, 4: 2, 6: 4}
if bit_depth != 8 or color_type not in channels_by_type or interlace != 0:
    raise SystemExit(
        f'unsupported PNG layout bit_depth={bit_depth} '
        f'color_type={color_type} interlace={interlace}'
    )

channels = channels_by_type[color_type]
stride = width * channels
raw = zlib.decompress(bytes(idat))
expected = height * (stride + 1)
if len(raw) != expected:
    raise SystemExit(f'unexpected decompressed size {len(raw)} != {expected}')

previous = bytearray(stride)
offset = 0
visible_pixels = 0
max_channel = 0


def paeth(a, b, c):
    p = a + b - c
    pa = abs(p - a)
    pb = abs(p - b)
    pc = abs(p - c)
    if pa <= pb and pa <= pc:
        return a
    if pb <= pc:
        return b
    return c


for _ in range(height):
    filter_type = raw[offset]
    offset += 1
    source = raw[offset:offset + stride]
    offset += stride
    row = bytearray(stride)

    for i, value in enumerate(source):
        left = row[i - channels] if i >= channels else 0
        up = previous[i]
        upper_left = previous[i - channels] if i >= channels else 0
        if filter_type == 0:
            decoded = value
        elif filter_type == 1:
            decoded = (value + left) & 255
        elif filter_type == 2:
            decoded = (value + up) & 255
        elif filter_type == 3:
            decoded = (value + ((left + up) // 2)) & 255
        elif filter_type == 4:
            decoded = (value + paeth(left, up, upper_left)) & 255
        else:
            raise SystemExit(f'unsupported PNG filter {filter_type}')
        row[i] = decoded

    for x in range(width):
        base = x * channels
        if color_type in (0, 4):
            r = g = b = row[base]
        else:
            r, g, b = row[base:base + 3]
        local_max = max(r, g, b)
        max_channel = max(max_channel, local_max)
        if local_max >= 16:
            visible_pixels += 1

    previous = row

total = width * height
ratio = visible_pixels / total if total else 0.0
print(f'width={width}')
print(f'height={height}')
print(f'max_channel={max_channel}')
print(f'visible_pixels_ge_16={visible_pixels}')
print(f'visible_ratio={ratio:.6f}')

if max_channel < 16 or ratio < 0.01:
    raise SystemExit(
        f'visual proof is blank/near-black: '
        f'max_channel={max_channel} visible_ratio={ratio:.6f}'
    )
PY

  cat "$metrics"
}

if adb shell pm path com.leventua.bilgirotasi 2>/dev/null | grep -q '^package:'; then
  adb uninstall com.leventua.bilgirotasi
fi

adb install reports/WORD_HUNT_REUSABLE_MAP_ANDROID16_PROOF.apk
adb logcat -c
adb shell am force-stop com.leventua.bilgirotasi
adb shell monkey -p com.leventua.bilgirotasi -c android.intent.category.LAUNCHER 1 >/dev/null
wait_for_app_drawn \
  reports/WORD_HUNT_REUSABLE_MAP_ANDROID16_ACTIVITY.txt \
  'Reusable map proof'
adb exec-out screencap -p > reports/WORD_HUNT_REUSABLE_MAP_ANDROID16.png
adb logcat -d > reports/WORD_HUNT_REUSABLE_MAP_ANDROID16_LOGCAT.txt
test -s reports/WORD_HUNT_REUSABLE_MAP_ANDROID16.png
validate_nonblack_png \
  reports/WORD_HUNT_REUSABLE_MAP_ANDROID16.png \
  reports/WORD_HUNT_REUSABLE_MAP_ANDROID16_PIXEL_CHECK.txt
if grep -E 'FATAL EXCEPTION|ANR in com\.leventua\.bilgirotasi|am_crash.*com\.leventua\.bilgirotasi|am_proc_died.*com\.leventua\.bilgirotasi' \
  reports/WORD_HUNT_REUSABLE_MAP_ANDROID16_LOGCAT.txt; then
  echo 'Reusable map Android proof process failure detected.' >&2
  exit 1
fi
adb uninstall com.leventua.bilgirotasi

adb install build/app/outputs/flutter-apk/app-debug.apk
adb logcat -c
adb shell am force-stop com.leventua.bilgirotasi
adb shell monkey -p com.leventua.bilgirotasi -c android.intent.category.LAUNCHER 1 >/dev/null
wait_for_app_drawn \
  reports/WORD_HUNT_VISUAL_PROOF_ACTIVITY.txt \
  'MASTER ART visual proof'
adb exec-out screencap -p > reports/ANDROID16_RAW.png
adb logcat -d > reports/WORD_HUNT_VISUAL_PROOF_LOGCAT.txt
awk '/WORD_HUNT_PIXEL_PROOF_ASSET_(LOADED|ERROR)/' \
  reports/WORD_HUNT_VISUAL_PROOF_LOGCAT.txt \
  > reports/WORD_HUNT_VISUAL_PROOF_ASSET_RUNTIME.txt
test -s reports/ANDROID16_RAW.png
validate_nonblack_png \
  reports/ANDROID16_RAW.png \
  reports/WORD_HUNT_VISUAL_PROOF_PIXEL_CHECK.txt
if grep -E 'FATAL EXCEPTION|ANR in com\.leventua\.bilgirotasi|am_crash.*com\.leventua\.bilgirotasi|am_proc_died.*com\.leventua\.bilgirotasi' \
  reports/WORD_HUNT_VISUAL_PROOF_LOGCAT.txt; then
  echo 'Bilgi Rotası visual-proof process failure detected.' >&2
  exit 1
fi
if grep -Fq '[WORD_HUNT_PIXEL_PROOF_ASSET_ERROR]' \
  reports/WORD_HUNT_VISUAL_PROOF_ASSET_RUNTIME.txt; then
  cat reports/WORD_HUNT_VISUAL_PROOF_ASSET_RUNTIME.txt >&2
  exit 1
fi
grep -Fq '[WORD_HUNT_PIXEL_PROOF_ASSET_LOADED]' \
  reports/WORD_HUNT_VISUAL_PROOF_ASSET_RUNTIME.txt
test "$(grep -Fc '[WORD_HUNT_PIXEL_PROOF_ASSET_LOADED]' reports/WORD_HUNT_VISUAL_PROOF_ASSET_RUNTIME.txt)" -eq 2
