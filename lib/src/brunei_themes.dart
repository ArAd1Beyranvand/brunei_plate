import 'package:flutter/widgets.dart';
import 'package:plate_core/plate_core.dart';

import 'brunei_colors.dart';

/// Frameless plates: the border is drawn in the field colour, except the
/// diplomatic plate's thin dark rim.
abstract final class BruneiThemes {
  /// Matches KA 51 and the diplomatic plate (~4% of height).
  static const double _plateRadiusRatio = 0.04;

  static PlateTheme _field({
    required Color field,
    required Color ink,
    required Color inactive,
    Color? rim,
    double borderWidthRatio = 0.02,
  }) => PlateTheme(
    plateBackground: field,
    plateBorder: rim ?? field,
    ink: ink,
    dividerColor: ink,
    borderWidthRatio: borderWidthRatio,
    plateRadiusRatio: _plateRadiusRatio,
    activeColor: ink,
    inactiveColor: inactive,
    alertColor: const Color(0xFFD32F2F),
  );

  static final PlateTheme standard = _field(
    field: BruneiColors.black,
    ink: BruneiColors.lightInk,
    inactive: BruneiColors.inactiveOnDark,
  );

  static final PlateTheme taxi = _field(
    field: BruneiColors.taxiGreen,
    ink: BruneiColors.lightInk,
    inactive: BruneiColors.inactiveOnDark,
  );

  static final PlateTheme yellow = _field(
    field: BruneiColors.yellow,
    ink: BruneiColors.yellowInk,
    inactive: BruneiColors.inactiveOnLight,
  );

  static final PlateTheme diplomatic = _field(
    field: BruneiColors.diplomaticWhite,
    ink: BruneiColors.diplomaticInk,
    inactive: BruneiColors.inactiveOnLight,
    rim: BruneiColors.diplomaticInk,
    borderWidthRatio: 0.012,
  );
}
