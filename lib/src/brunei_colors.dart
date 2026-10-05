import 'package:flutter/widgets.dart';

/// The colours a Brunei plate is printed in, sampled from the pixels of the
/// Commons photographs (the modal colour of a region at 8-level quantisation,
/// not one pixel). The article gives colour names only.
///
/// Every value is a photograph of plastic, so none is a published standard;
/// those taken from a single small or shaded photo are marked
/// `// CALIBRATE`.
abstract final class BruneiColors {
  /// The black field. `Old license plate of Brunei.jpg` (KA 51), flat and
  /// frontal; the KN 232 photo samples a darker 0C0C0C.
  static const Color black = Color(0xFF14141C);

  /// The white characters on [black]. Same photo, the K's stem. The KN 232
  /// photo samples a shaded C4C4CC.
  static const Color lightInk = Color(0xFFDCE4EC);

  /// The taxi and bus field. The KP 4708 bus in `Seria 8 January 2023 09.jpg`
  /// — about 130×33 px of plate, so a teal-green rather than a pure green.
  static const Color taxiGreen = Color(0xFF54B49C); // CALIBRATE

  /// The `BX` series field. `Brunei "BX" car registration plates.jpg`.
  static const Color yellow = Color(0xFFECBC24);

  /// The characters on [yellow]: gloss black reflecting the yellow, sampled on
  /// the B's stem of BX 857.
  static const Color yellowInk = Color(0xFF34240C);

  /// The diplomatic field, from the lit left end of `Diplomatic car plates in
  /// Brunei.jpg`. Reflective white photographed in shade.
  static const Color diplomaticWhite = Color(0xFFD4D4CC); // CALIBRATE

  /// The characters on [diplomaticWhite], the D's stem in the same photo.
  static const Color diplomaticInk = Color(0xFF2C2C2C);

  /// Placeholder ink for an empty slot on a dark field.
  static const Color inactiveOnDark = Color(0xFF5A5A5A);

  /// Placeholder ink for an empty slot on a light field.
  static const Color inactiveOnLight = Color(0xFFB0B0B0);
}
