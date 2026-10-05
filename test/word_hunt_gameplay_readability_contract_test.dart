import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:word_hunt_flutter_feature/word_hunt_gameplay_readability_contract.dart';

void main() {
  test(
    'Firtina Gecidi / Kayip Sehir similar-color letters fail without protection',
    () {
      const unsafe = WordHuntGameplayReadabilityContract(
        textMode: WordHuntTextMode.light,
        scrimColor: Colors.black,
        scrimOpacity: 0,
      );
      expect(unsafe.passes(Colors.white), isFalse);
      expect(unsafe.contrastRatioAgainst(Colors.white), 1);
      const samples = [Colors.white, Color(0xFFFFD54F), Color(0xFFBBBBBB)];
      final fixed = unsafe.correctedFor(samples);
      expect(fixed.scrimOpacity, greaterThan(0));
      expect(fixed.passesAll(samples), isTrue);
      expect(fixed.correctedFor(samples), same(fixed));
      expect(fixed.scrimOpacity, unsafe.correctedFor(samples).scrimOpacity);
      for (final sample in samples) {
        for (final state in WordHuntReadableState.values) {
          expect(
            fixed.contrastRatioAgainst(sample, state: state),
            greaterThanOrEqualTo(4.5),
          );
        }
      }
    },
  );
  test(
    'known contrast, state surfaces and uncorrectable palettes fail closed',
    () {
      const whiteOnBlack = WordHuntGameplayReadabilityContract(
        textMode: WordHuntTextMode.light,
        scrimColor: Colors.black,
        scrimOpacity: 0,
      );
      expect(
        whiteOnBlack.contrastRatioAgainst(Colors.black),
        closeTo(21, 1e-10),
      );
      const badSelected = WordHuntGameplayReadabilityContract(
        textMode: WordHuntTextMode.light,
        scrimColor: Colors.black,
        scrimOpacity: .56,
        stateSurfaces: {WordHuntReadableState.selected: Colors.white},
      );
      expect(badSelected.passes(Colors.black), isFalse);
      expect(() => badSelected.correctedFor([Colors.black]), throwsStateError);
      expect(() => whiteOnBlack.correctedFor([]), throwsArgumentError);
      expect(
        () => whiteOnBlack.passes(const Color(0x88FFFFFF)),
        throwsArgumentError,
      );
      const protectedStates = WordHuntGameplayReadabilityContract(
        textMode: WordHuntTextMode.light,
        scrimColor: Colors.black,
        scrimOpacity: .56,
        stateSurfaces: {
          WordHuntReadableState.found: Color(0x80226040),
          WordHuntReadableState.selected: Color(0x80405060),
          WordHuntReadableState.hint: Color(0x80504020),
        },
      );
      expect(
        protectedStates.correctedFor([Colors.white]).passesAll([Colors.white]),
        isTrue,
      );
    },
  );
  testWidgets(
    'future gameplay layer applies resolved scrim and exposes palette',
    (tester) async {
      WordHuntGameplayReadabilityContract? received;
      await tester.pumpWidget(
        MaterialApp(
          home: WordHuntGameplayReadabilitySurface(
            contract: const WordHuntGameplayReadabilityContract(
              textMode: WordHuntTextMode.light,
              scrimColor: Colors.black,
              scrimOpacity: 0,
            ),
            samples: const [Colors.white],
            background: const ColoredBox(color: Colors.white),
            builder: (context, palette) {
              received = palette;
              return Center(
                child: Text(
                  'HARF',
                  style: TextStyle(
                    color: palette.foregroundFor(WordHuntReadableState.hint),
                  ),
                ),
              );
            },
          ),
        ),
      );
      expect(received!.passesAll([Colors.white]), isTrue);
      expect(find.byType(IgnorePointer), findsWidgets);
      final overlays = tester.widgetList<ColoredBox>(find.byType(ColoredBox));
      expect(overlays.any((w) => w.color.a > 0 && w.color.a < 1), isTrue);
      expect(tester.takeException(), isNull);
    },
  );
  test('dark scrim keeps light text readable over bright backgrounds', () {
    const contract = WordHuntGameplayReadabilityPresets.lightOnDark;
    expect(contract.passes(Colors.white), isTrue);
    expect(contract.passes(const Color(0xFFFFD54F)), isTrue);
  });

  test('light scrim keeps dark text readable over dark backgrounds', () {
    const contract = WordHuntGameplayReadabilityPresets.darkOnLight;
    expect(contract.passes(Colors.black), isTrue);
    expect(contract.passes(const Color(0xFF263238)), isTrue);
  });

  test('contract uses WCAG-style 4.5 default threshold', () {
    const contract = WordHuntGameplayReadabilityPresets.lightOnDark;
    expect(contract.minimumContrastRatio, 4.5);
  });
}
