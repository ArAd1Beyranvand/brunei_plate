FREE PALESTINE 🇮🇷🇵🇸 پاینده ایران

GO VEGAN 🌱

==================================

From the mighty people of Iran to the peaceful people of Brunei to view examples:

https://platexample.ir/#/discover/brunei

# brunei_plate

Brunei's licence plates for the `plate_core` library. Two geometries on the article's 533×152 mm: the single-row plate, whose width is the same for every registration and whose cells shrink to fit, and the diplomatic `NN·NN·DC`. Private, military, taxi/bus and the yellow `BX` series are the single row on another theme.

## Install

```yaml
dependencies:
  plate_core: ^0.12.0
  brunei_plate: ^0.1.0
```

## Use

```dart
import 'package:plate_core/plate_core.dart';
import 'package:brunei_plate/brunei_plate.dart';

PlateCanvas(
  spec: BruneiPlates.singleRow(),
  theme: BruneiThemes.standard,
  validator: const BruneiValidator(),
  autoValidate: true,
  onChooseCharacter: noCharacterChooser,
);
```

## Contains

- `BruneiCountry` — country panel: `brunei`.
- `BruneiPlates` — 2 plate specs (factories): `singleRow()`, `diplomatic()`.
- `BruneiThemes` — 4 themes: `standard`, `taxi`, `yellow`, `diplomatic`.
- `BruneiValidator` — advisory validator; flags the frame, never blocks a keystroke.
- `BruneiDiplomaticValidator` — advisory validator; flags the frame, never blocks a keystroke.
- `BruneiSerialGenerator` — random plate generator.

## Plates

Brunei's plate geometries.

* `singleRow` covers private, commercial, service, military, taxi, bus and
  `BX` plates; colour is the theme, not the spec. Text groups: `prefix`,
  `number` and, when present, `suffix`.
* `diplomatic` is `NN·NN·DC` on white. Text groups: `serial`, `mission`.

Not implemented, for want of a reference: dealer, royal and motorcycle plates.

## Part of plate

Painted by [`plate_core`](https://pub.dev/packages/plate_core); alphabets shared through [`plate_alphabet`](https://pub.dev/packages/plate_alphabet); optional character picker in [`plate_keypad`](https://pub.dev/packages/plate_keypad).

