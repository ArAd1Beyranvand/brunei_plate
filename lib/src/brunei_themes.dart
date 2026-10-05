import 'package:flutter/widgets.dart';
import 'package:plate_core/plate_core.dart';

import 'brunei_colors.dart';

/// The Brunei liveries. Every one is one ink on one field, so they are one
/// helper and four calls.
///
/// A Brunei plate is frameless — the border is drawn in the field colour and
/// disappears — except the diplomatic plate, which has a thin dark rim.
abstract final class BruneiThemes {
  /// Corners of KA 51 and the diplomatic plate fall ~4% of the height; only
  /// the short KN 232 plate is rounder (~14%), and it is not a spec here.
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

  /// White on black: every private, commercial and service vehicle, and the
  /// military `MOD` series.
  static final PlateTheme standard = _field(
    field: BruneiColors.black,
    ink: BruneiColors.lightInk,
    inactive: BruneiColors.inactiveOnDark,
  );

  /// White on green: taxis and buses.
  static final PlateTheme taxi = _field(
    field: BruneiColors.taxiGreen,
    ink: BruneiColors.lightInk,
    inactive: BruneiColors.inactiveOnDark,
  );

  /// Black on yellow: the `BX` series.
  static final PlateTheme yellow = _field(
    field: BruneiColors.yellow,
    ink: BruneiColors.yellowInk,
    inactive: BruneiColors.inactiveOnLight,
  );

  /// Black on white with a thin black rim: the diplomatic plate. The rim is
  /// ~1 mm on the 326 px plate of the photograph.
  static final PlateTheme diplomatic = _field(
    field: BruneiColors.diplomaticWhite,
    ink: BruneiColors.diplomaticInk,
    inactive: BruneiColors.inactiveOnLight,
    rim: BruneiColors.diplomaticInk,
    borderWidthRatio: 0.012,
  );
}
