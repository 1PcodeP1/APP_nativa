import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grand_stakes/screens/roulette_screen.dart';
import 'package:grand_stakes/theme.dart';

void main() {
  test('Roulette colors calculated correctly', () {
    // Test Zero (Green)
    expect(getRouletteColor(0), AppColors.tertiary, reason: 'Number 0 should be Casino Green');

    // Test Red Numbers
    const redNumbers = [1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36];
    for (int num in redNumbers) {
      expect(getRouletteColor(num), AppColors.secondaryContainer, reason: 'Number \$num should be Red');
    }

    // Test Black Numbers
    const blackNumbers = [2, 4, 6, 8, 10, 11, 13, 15, 17, 20, 22, 24, 26, 28, 29, 31, 33, 35];
    for (int num in blackNumbers) {
      expect(getRouletteColor(num), Colors.black, reason: 'Number \$num should be Black');
    }
  });
}
