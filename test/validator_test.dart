import 'dart:math';

import 'package:brunei_plate/brunei_plate.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plate_core/plate_core.dart';

void main() {
  PlateValidation single(String prefix, String number, [String suffix = '']) =>
      BruneiValidator.validateFields(prefix: prefix, number: number, suffix: suffix);

  test('accepts the article and reference examples', () {
    for (final (String, String, String) p in <(String, String, String)>[
      ('KA', '51', ''),
      ('KN', '232', ''),
      ('KP', '4708', ''),
      ('BX', '9096', ''),
      ('BAA', '1234', ''),
      ('B', '1', ''),
      ('MOD', '1925', ''),
      ('MOD', '1925', 'A'),
    ]) {
      expect(single(p.$1, p.$2, p.$3).isValid, isTrue, reason: '$p');
    }
  });

  test('rejects what the article says is never issued', () {
    expect(single('K', '1').isValid, isFalse, reason: 'lone K');
    expect(single('KQ', '1').isValid, isFalse, reason: 'K series ends at KP');
    expect(single('BI', '1').isValid, isFalse, reason: 'no I');
    expect(single('BO', '1').isValid, isFalse, reason: 'no O');
    expect(single('AB', '1').isValid, isFalse, reason: 'B or K only');
    expect(single('BA', '0123').isValid, isFalse, reason: 'leading zero');
    expect(single('BA', '12345').isValid, isFalse, reason: 'five digits');
    expect(single('BA', '1', 'A').isValid, isFalse, reason: 'suffix off MOD');
  });

  test('the diplomatic numbers are one or two digits', () {
    PlateValidation dip(String value) => const BruneiDiplomaticValidator().validate(
      PlateEntry(spec: BruneiPlates.diplomatic(), values: value.split('')),
    );
    expect(dip('0326').isValid, isTrue);
    expect(
      const BruneiDiplomaticValidator()
          .validate(
            PlateEntry(spec: BruneiPlates.diplomatic(missionDigits: 1), values: '012'.split('')),
          )
          .isValid,
      isTrue,
    );
  });

  test('specs are cached and sized by their parameters', () {
    expect(identical(BruneiPlates.singleRow(), BruneiPlates.singleRow()), isTrue);
    expect(BruneiPlates.singleRow(prefix: 3, digits: 4).slotCount, 7);
    expect(BruneiPlates.singleRow(prefix: 3, digits: 4, suffix: true).slotCount, 8);
    expect(BruneiPlates.diplomatic().slotCount, 4);
    expect(BruneiPlates.diplomatic(serialDigits: 1).slotCount, 3);
    expect(() => BruneiPlates.singleRow(prefix: 4), throwsArgumentError);
    expect(() => BruneiPlates.diplomatic(serialDigits: 3), throwsArgumentError);
  });

  test('generated plates validate', () {
    final Random rnd = Random(7);
    for (int i = 0; i < 200; i++) {
      final PlateSpec spec = BruneiPlates.singleRow(
        prefix: 1 + rnd.nextInt(3),
        digits: 1 + rnd.nextInt(4),
      );
      final List<String?> values = BruneiSerialGenerator.generate(spec, random: rnd);
      expect(
        const BruneiValidator().validate(PlateEntry(spec: spec, values: values)).isValid,
        isTrue,
        reason: '$values',
      );
    }
  });
}
