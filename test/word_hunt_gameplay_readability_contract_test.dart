import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:word_hunt_flutter_feature/word_hunt_gameplay_readability_contract.dart';

void main() {
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
