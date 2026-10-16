import 'dart:math' as math;

import 'package:plate_core/plate_core.dart';

import 'brunei_alphabets.dart';
import 'brunei_country.dart';

/// Ink placement in millimetres on the article's 533×152 canvas (21×6 in),
/// measured by projecting ink onto each axis of cropped reference plates:
///
/// * `KA 51` (ar 3.07): ink spans 71% of the height; glyphs ~87 wide at pitch
///   105 with no word gap, 92 once scaled by plate height instead of
///   stretched to 533 wide.
/// * `KN 232` (ar 1.97): letter pitch 90, digit pitch 92, word gap 13 mm on 152.
/// * `03·26·DC` (ar 3.63): ink spans 68%; digits ~55 wide at pitch ~62,
///   letters ~61 wide at pitch ~71.
/// * `BX 857` and street photographs inform colour and series shape only; their
///   aspect ratios (3.0–5.1) disagree with each other and with 3.51.
///
/// **Under-height ink, accepted.** Matching KA 51's 107 mm of ink needs a ~200 mm
/// slot on a 152 mm plate (`glyphStyle` sets 0.72 of the slot, a bold cap ~0.73
/// of that). Slots are as tall as the plate allows, so ink is ~72% of the
/// reference.
abstract final class _Layout {
  static const double width = 533;
  static const double height = 152;

  // Single row.
  static const double slotHeight = 148;
  static const double maxPitch = 92;

  static const double minMargin = 40;

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

Iterable<int> _range(int from, int to) =>
    Iterable<int>.generate(to - from, (int i) => from + i);

/// One registration's shape: 1–3 prefix letters, 1–4 digits, and whether a
/// military branch letter follows (`MOD 1925 A`).
typedef BruneiFormat = ({int prefix, int digits, bool suffix});

/// Brunei's plate geometries.
///
/// * [singleRow] covers private, commercial, service, military, taxi, bus and
///   `BX` plates; colour is the theme, not the spec. Text groups: `prefix`,
///   `number` and, when present, `suffix`.
/// * [diplomatic] is `NN·NN·DC` on white. Text groups: `serial`, `mission`.
///
/// Not implemented, for want of a reference: dealer, royal and motorcycle plates.
abstract final class BruneiPlates {
  static const List<int> prefixLengths = <int>[1, 2, 3];
  static const List<int> digitLengths = <int>[1, 2, 3, 4];
  static const List<int> diplomaticDigitLengths = <int>[1, 2];

  static final Map<BruneiFormat, PlateSpec> _single =
      <BruneiFormat, PlateSpec>{};
  static final Map<(int, int), PlateSpec> _diplomatic =
      <(int, int), PlateSpec>{};

  /// Cached per format.
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

  /// Cached per shape.
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
    final double suffixLeft = numberLeft + f.digits * pitch + _Layout.wordGap;
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
        PlateTextGroup(<int>[..._range(0, f.prefix)], key: 'prefix'),
        PlateTextGroup(<int>[
          ..._range(f.prefix, f.prefix + f.digits),
        ], key: 'number'),
        if (f.suffix) PlateTextGroup(<int>[cells - 1], key: 'suffix'),
      ],
    );
  }

  /// `DC` never varies, so it is a label, not a slot. Content is centred; the
  /// measured plate sits 6 mm left of centre because of its rim, not its
  /// lettering.
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
        PlateTextGroup(<int>[..._range(0, serialDigits)], key: 'serial'),
        PlateTextGroup(<int>[
          ..._range(serialDigits, serialDigits + missionDigits),
        ], key: 'mission'),
      ],
    );
  }
}
