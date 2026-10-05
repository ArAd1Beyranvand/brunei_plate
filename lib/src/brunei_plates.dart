import 'dart:math' as math;

import 'package:plate_core/plate_core.dart';

import 'brunei_alphabets.dart';
import 'brunei_country.dart';

/// Where the ink sits on a Brunei plate, in millimetres.
///
/// The canvas is the 533×152 the article gives (21×6 in). Reference plates
/// were cropped to their rectangle and the ink projected onto each axis,
/// normalising to that canvas:
///
/// * `KA 51` (`Old license plate of Brunei.jpg`, plate 1112×362 px, ar 3.07):
///   ink y 27.3..134.8 (71% of the height), glyphs ~87 wide at a pitch of 105
///   — letters and digits evenly pitched, no visible word gap. Scaled by the
///   plate's own height rather than stretched to 533 wide, the pitch is 92.
/// * `KN 232` (`Brunei car plate (cropped).JPG`, ar 1.97): letter pitch 90,
///   digit pitch 92, 116 from the second letter to the first digit — a word
///   gap of ~26 on a 300 px plate, 13 mm on 152.
/// * `03·26·DC` (`Diplomatic car plates in Brunei.jpg`, plate 1184×326 px,
///   ar 3.63): ink y 22.4..125.4 (68%); `03` 49.5..163.9, dot 173..182, `26`
///   189.1..312.4, dot 322..331, `DC` 339..470; digits ~55 wide at pitch ~62,
///   letters ~61 wide at pitch ~71.
/// * `BX 857` (`Brunei "BX" car registration plates.jpg`, ar 5.1) and the
///   photographed plates on cars were used for colour and for the shape of
///   the series only: their aspect ratios (3.0–5.1) disagree with each other
///   and with the article's 3.51, so none of them fixes a coordinate.
///
/// **Under-height ink, accepted.** 107 mm of ink on KA 51 would need a ~200 mm
/// slot on a 152 mm plate (`glyphStyle` sets 0.72 of the slot, and a bold cap
/// is ~0.73 of that). Slots here are as tall as the plate allows, so ink is
/// ~72% of the reference; `plate_core` is unchanged.
abstract final class _Layout {
  static const double width = 533;
  static const double height = 152;

  // Single row.
  static const double slotHeight = 148;
  static const double maxPitch = 92;

  /// The empty margin either side that a long registration is squeezed into.
  static const double minMargin = 40;

  /// Extra air between prefix and number, from KN 232.
  static const double wordGap = 13;

  /// A cell's width over its slot height. The widest bold capital, M, is
  /// ~0.61 of the slot wide; a narrower pitch makes the engine shrink that one
  /// glyph below its neighbours (MOD at eight cells did), so the slot is
  /// shortened to keep every glyph at full size.
  static const double glyphWidthRatio = 0.62;

  // Diplomatic NN·NN·DC.
  static const double dipSlotHeight = 148;
  static const double dipPitch = 62;
  static const double dipDotCell = 21;
  static const double dipCodeWidth = 140;

  /// DC's ink is 131 wide (339..470) on the reference. DejaVu's D and C at
  /// 135 printed 145 and touched the dot; this prints ~131.
  static const double dipCodeGlyph = 122;

  /// The dot is a label and a label is not shrunk to its box. U+00B7 prints
  /// ~0.125 of the glyph height wide, and the reference dot is ~9.5 mm.
  static const double dipDotGlyph = 76;

  /// The reference dot's centre is at y 70, the glyph's prints at 76.5.
  static const double dipDotLift = 6;
}

/// One registration's shape: 1–3 prefix letters, 1–4 digits, and whether a
/// military branch letter follows (`MOD 1925 A`).
typedef BruneiFormat = ({int prefix, int digits, bool suffix});

/// Brunei's plate geometries.
///
/// * [singleRow] — every private, commercial, service and military vehicle,
///   taxi and bus, and the yellow `BX` series. Colour is the theme, not the
///   spec: `BruneiThemes.standard`, `taxi` and `yellow`.
/// * [diplomatic] — `NN·NN·DC` on white: sequential number, the mission's
///   number, then the fixed `DC`.
///
/// Not implemented, for want of a reference to measure: dealer plates (white
/// with red characters), the royal family's red and script plates, and the
/// smaller motorcycle plates.
///
/// [singleRow] has the text groups `prefix`, `number` and, when present,
/// `suffix`; [diplomatic] has `serial` and `mission`.
abstract final class BruneiPlates {
  static const List<int> prefixLengths = <int>[1, 2, 3];
  static const List<int> digitLengths = <int>[1, 2, 3, 4];
  static const List<int> diplomaticDigitLengths = <int>[1, 2];

  static final Map<BruneiFormat, PlateSpec> _single =
      <BruneiFormat, PlateSpec>{};
  static final Map<(int, int), PlateSpec> _diplomatic = <(int, int), PlateSpec>{};

  /// The single-row plate for [prefix] letters, [digits] digits and an
  /// optional branch-letter suffix. Built once per format.
  static PlateSpec singleRow({
    int prefix = 2,
    int digits = 4,
    bool suffix = false,
  }) {
    if (!prefixLengths.contains(prefix) || !digitLengths.contains(digits)) {
      throw ArgumentError(
        'A Brunei registration is 1–3 letters and 1–4 digits '
        '(got $prefix and $digits).',
      );
    }
    final BruneiFormat f = (prefix: prefix, digits: digits, suffix: suffix);
    return _single[f] ??= _singleRowSpec(f);
  }

  /// The diplomatic plate with [serialDigits] and [missionDigits] digits in
  /// its two numbers (`03·26·DC`, `01·2·DC`). Built once per shape.
  static PlateSpec diplomatic({int serialDigits = 2, int missionDigits = 2}) {
    if (!diplomaticDigitLengths.contains(serialDigits) ||
        !diplomaticDigitLengths.contains(missionDigits)) {
      throw ArgumentError(
        'Each diplomatic number is 1–2 digits '
        '(got $serialDigits and $missionDigits).',
      );
    }
    return _diplomatic[(serialDigits, missionDigits)] ??= _diplomaticSpec(
      serialDigits,
      missionDigits,
    );
  }

  static String _id(String form, BruneiFormat f) =>
      'bn.$form.${f.prefix}${f.digits}${f.suffix ? 's' : ''}';

  static PlateSpec _singleRowSpec(BruneiFormat f) {
    final int cells = f.prefix + f.digits + (f.suffix ? 1 : 0);
    final double gaps = _Layout.wordGap * (f.suffix ? 2 : 1);
    final double pitch = math.min(
      _Layout.maxPitch,
      (_Layout.width - 2 * _Layout.minMargin - gaps) / cells,
    );
    final double slotHeight = math.min(
      _Layout.slotHeight,
      pitch / _Layout.glyphWidthRatio,
    );
    final double top = (_Layout.height - slotHeight) / 2;
    final double content = cells * pitch + gaps;
    final double left = (_Layout.width - content) / 2;
    final double numberLeft = left + f.prefix * pitch + _Layout.wordGap;
    final double suffixLeft =
        numberLeft + f.digits * pitch + _Layout.wordGap;
    return PlateSpec(
      id: _id('single', f),
      country: BruneiCountry.brunei,
      canvasWidth: _Layout.width,
      canvasHeight: _Layout.height,
      noPanel: true,
      panel: const PlatePanel(box: PlateBox(0, 0, 0, _Layout.height)),
      slots: <PlateSlot>[
        ...plateRegister(
          alphabet: BruneiAlphabets.letters,
          count: f.prefix,
          left: left,
          top: top,
          width: pitch,
          height: slotHeight,
        ),
        ...plateRegister(
          alphabet: BruneiAlphabets.digits,
          count: f.digits,
          left: numberLeft,
          top: top,
          width: pitch,
          height: slotHeight,
        ),
        if (f.suffix)
          PlateSlot(
            alphabet: BruneiAlphabets.letters,
            box: PlateBox(suffixLeft, top, pitch, slotHeight),
          ),
      ],
      textGroups: <PlateTextGroup>[
        PlateTextGroup(<int>[
          for (int i = 0; i < f.prefix; i++) i,
        ], key: 'prefix'),
        PlateTextGroup(<int>[
          for (int i = f.prefix; i < f.prefix + f.digits; i++) i,
        ], key: 'number'),
        if (f.suffix) PlateTextGroup(<int>[cells - 1], key: 'suffix'),
      ],
    );
  }

  /// `NN·NN·DC`. The article gives `XX-NN-DC`: a sequential number, the
  /// mission's number (the United States is 9) and `DC`, "diplomat's car".
  /// The code never varies, so it is a label and not a slot. Content is
  /// centred; the measured plate sits 6 mm left of centre, which is its rim
  /// and not the lettering.
  static PlateSpec _diplomaticSpec(int serialDigits, int missionDigits) {
    final double serialWidth = serialDigits * _Layout.dipPitch;
    final double missionWidth = missionDigits * _Layout.dipPitch;
    final double content =
        serialWidth +
        missionWidth +
        2 * _Layout.dipDotCell +
        _Layout.dipCodeWidth;
    final double left = (_Layout.width - content) / 2;
    final double top = (_Layout.height - _Layout.dipSlotHeight) / 2;
    final double dot1 = left + serialWidth;
    final double missionLeft = dot1 + _Layout.dipDotCell;
    final double dot2 = missionLeft + missionWidth;
    final double codeLeft = dot2 + _Layout.dipDotCell;
    return PlateSpec(
      id: 'bn.diplomatic.$serialDigits$missionDigits',
      country: BruneiCountry.brunei,
      canvasWidth: _Layout.width,
      canvasHeight: _Layout.height,
      noPanel: true,
      panel: const PlatePanel(box: PlateBox(0, 0, 0, _Layout.height)),
      slots: <PlateSlot>[
        ...plateRegister(
          alphabet: BruneiAlphabets.digits,
          count: serialDigits,
          left: left,
          top: top,
          width: _Layout.dipPitch,
          height: _Layout.dipSlotHeight,
        ),
        ...plateRegister(
          alphabet: BruneiAlphabets.digits,
          count: missionDigits,
          left: missionLeft,
          top: top,
          width: _Layout.dipPitch,
          height: _Layout.dipSlotHeight,
        ),
      ],
      labels: <PlateLabel>[
        for (final double x in <double>[dot1, dot2])
          PlateLabel(
            text: '·',
            box: PlateBox(
              x,
              top - _Layout.dipDotLift,
              _Layout.dipDotCell,
              _Layout.dipSlotHeight,
            ),
            glyphHeight: _Layout.dipDotGlyph,
          ),
        PlateLabel(
          text: 'DC',
          box: PlateBox(
            codeLeft,
            top,
            _Layout.dipCodeWidth,
            _Layout.dipSlotHeight,
          ),
          glyphHeight: _Layout.dipCodeGlyph,
        ),
      ],
      textGroups: <PlateTextGroup>[
        PlateTextGroup(<int>[
          for (int i = 0; i < serialDigits; i++) i,
        ], key: 'serial'),
        PlateTextGroup(<int>[
          for (int i = serialDigits; i < serialDigits + missionDigits; i++) i,
        ], key: 'mission'),
      ],
    );
  }
}
