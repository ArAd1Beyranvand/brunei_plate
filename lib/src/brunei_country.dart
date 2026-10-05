import 'package:plate_core/plate_core.dart';

import 'brunei_colors.dart';

/// Brunei as a `PlateCountry`. A Brunei plate carries no flag, caption or
/// country block — it is type on a plain field — so every spec sets
/// `noPanel`; the colours here are only the required placeholders.
abstract final class BruneiCountry {
  static const PlateCountry brunei = PlateCountry(
    code: 'bn',
    captionLines: <String>[],
    panelColor: BruneiColors.black,
    panelTextColor: BruneiColors.lightInk,
  );
}
