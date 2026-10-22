import 'dart:math';

import 'package:plate_core/plate_core.dart';

/// Generates plausible values for a `singleRow` spec. [prefix] fixes the
/// leading letters; the rest follows the issued series (B then any letter but
/// I and O, or K then A–P). Numbers have no leading zero.
abstract final class BruneiSerialGenerator {
  static const String _issued = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
  static const String _kSecond = 'ABCDEFGHJKLMNP';

  static List<String?> generate(PlateSpec spec, {Random? random, String prefix = ''}) {
    final Random rnd = random ?? Random();
    final List<String?> values = List<String?>.filled(spec.slots.length, null);
    final List<int> prefixSlots = _require(spec, 'prefix');
    final List<int> numberSlots = _require(spec, 'number');
    final bool k = prefix.isEmpty && prefixSlots.length > 1 && rnd.nextBool();
    for (int i = 0; i < prefixSlots.length; i++) {
      final String pool = k && i == 1 ? _kSecond : _issued;
      values[prefixSlots[i]] = i < prefix.length
          ? prefix[i]
          : i == 0
          ? (k ? 'K' : 'B')
          : pool[rnd.nextInt(pool.length)];
    }
    for (int i = 0; i < numberSlots.length; i++) {
      values[numberSlots[i]] = (i == 0 ? 1 + rnd.nextInt(9) : rnd.nextInt(10)).toString();
    }
    for (final int i in spec.indicesOfGroup('suffix')) {
      values[i] = _issued[rnd.nextInt(_issued.length)];
    }
    return values;
  }
}

List<int> _require(PlateSpec spec, String key) {
  final List<int> indices = spec.indicesOfGroup(key);
  if (indices.isEmpty) {
    throw ArgumentError.value(spec.id, 'spec', 'has no text group named "$key"');
  }
  return indices;
}
