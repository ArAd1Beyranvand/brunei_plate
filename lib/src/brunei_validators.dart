import 'package:plate_core/plate_core.dart';

/// Judges a Brunei registration on a `BruneiPlates.singleRow` spec. Reports,
/// never bars a keystroke.
///
/// Checks what the article states: the series run `B 1`–`BZZ 9999` and `KA 1`–
/// `KP 9999`, so a prefix starts with B or K, a lone K is never issued and a K
/// series' second letter is A–P; I and O are never issued; the number is 1–9999
/// with no leading zero. A military plate is `MOD` plus a number and a branch
/// letter, and is exempt from the letter rules (it has an O). Does not check
/// which prefixes the Land Transport Department has actually released, nor
/// royal vanity plates.
class BruneiValidator extends GatedPlateValidator {
  const BruneiValidator();

  @override
  String get gateGroup => 'number';

  static const String military = 'MOD';

  static const String reasonPrefixMissing = 'A plate starts with letters.';
  static const String reasonSeries = 'A plate starts with B or K, or is MOD.';
  static const String reasonLoneK = 'There is no plate with the single letter K.';
  static const String reasonKSeries = 'A K series runs from KA to KP.';
  static const String reasonNoIO = 'I and O are not issued on Brunei plates.';
  static const String reasonNumber = 'The number is 1 to 9999.';
  static const String reasonLeadingZero = 'The number has no leading zero.';
  static const String reasonSuffix = 'Only a MOD plate has a branch letter.';

  @override
  PlateValidation judge(PlateEntry entry) => validateFields(
    prefix: entry.group('prefix'),
    number: entry.group('number'),
    suffix: entry.group('suffix'),
  );

  static PlateValidation validateFields({
    required String prefix,
    required String number,
    String suffix = '',
  }) {
    if (prefix.isEmpty) {
      return const PlateValidation.invalid(reasonPrefixMissing);
    }
    final bool mod = prefix == military;
    if (!mod) {
      if (prefix[0] != 'B' && prefix[0] != 'K') {
        return const PlateValidation.invalid(reasonSeries);
      }
      if (RegExp('[IO]').hasMatch(prefix + suffix)) {
        return const PlateValidation.invalid(reasonNoIO);
      }
      if (prefix[0] == 'K') {
        if (prefix.length == 1) {
          return const PlateValidation.invalid(reasonLoneK);
        }
        if (prefix.codeUnitAt(1) > 'P'.codeUnitAt(0)) {
          return const PlateValidation.invalid(reasonKSeries);
        }
      }
      if (suffix.isNotEmpty) {
        return const PlateValidation.invalid(reasonSuffix);
      }
    }
    if (number.isEmpty || number.length > 4 || !isDigits(number)) {
      return const PlateValidation.invalid(reasonNumber);
    }
    if (number.startsWith('0')) {
      return const PlateValidation.invalid(reasonLeadingZero);
    }
    return const PlateValidation.valid();
  }
}

/// Judges a `BruneiPlates.diplomatic` value: a sequential number and the
/// mission's number, each one or two digits. The article documents no ranges
/// and lists no missions, so there is nothing further to check.
class BruneiDiplomaticValidator extends GatedPlateValidator {
  const BruneiDiplomaticValidator();

  @override
  String get gateGroup => 'mission';

  static const String reasonDigits = 'Each number is one or two digits.';

  @override
  PlateValidation judge(PlateEntry entry) {
    for (final String part in <String>[
      entry.group('serial'),
      entry.group('mission'),
    ]) {
      if (part.isEmpty || part.length > 2 || !isDigits(part)) {
        return const PlateValidation.invalid(reasonDigits);
      }
    }
    return const PlateValidation.valid();
  }
}
