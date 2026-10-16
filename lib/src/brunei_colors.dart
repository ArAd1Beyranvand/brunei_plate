import 'package:flutter/widgets.dart';

/// Plate colours sampled from photographs (modal colour of a region at 8-level
/// quantisation). None is a published standard; values from a single small or
/// shaded photo are marked `// CALIBRATE`.
abstract final class BruneiColors {
  /// `Old license plate of Brunei.jpg` (KA 51); the KN 232 photo samples a
  /// darker 0C0C0C.
  static const Color black = Color(0xFF14141C);

  /// Characters on [black], from the K's stem; KN 232 samples a shaded C4C4CC.
  static const Color lightInk = Color(0xFFDCE4EC);

  /// Taxi and bus field, from a ~130×33 px plate (`Seria 8 January 2023 09.jpg`),
  /// hence teal-green.
  static const Color taxiGreen = Color(0xFF54B49C); // CALIBRATE

  static const Color yellow = Color(0xFFECBC24);

  /// Characters on [yellow]: gloss black reflecting the yellow (B's stem, BX 857).
  static const Color yellowInk = Color(0xFF34240C);

  /// Reflective white photographed in shade; lit left end of
  /// `Diplomatic car plates in Brunei.jpg`.
  static const Color diplomaticWhite = Color(0xFFD4D4CC); // CALIBRATE

  static const Color diplomaticInk = Color(0xFF2C2C2C);

  static const Color inactiveOnDark = Color(0xFF5A5A5A);

  static const Color inactiveOnLight = Color(0xFFB0B0B0);
}
