import 'dart:io';

import 'package:plate_core/plate_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brunei_plate/brunei_plate.dart';

/// One golden per category, drawn with a real bold face so the ink can be
/// measured against the references (see `_Layout` in `brunei_plates.dart`).
///
/// Regenerate with `flutter test --update-goldens` after a deliberate change.
void main() {
  setUpAll(() async {
    final FontLoader loader = FontLoader('Roboto');
    final File face = File(
      '/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf',
    );
    if (face.existsSync()) {
      loader.addFont(face.readAsBytes().then((b) => ByteData.view(b.buffer)));
    }
    await loader.load();
  });

  Future<void> render(
    WidgetTester tester, {
    required PlateSpec spec,
    required PlateTheme theme,
    required String values,
    required String name,
  }) async {
    final PlateController controller = PlateController.fromValues(
      spec,
      values.split(' '),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 533,
              height: 152,
              child: PlateThemeScope(
                theme: theme,
                child: PlateView(
                  controller: controller,
                  theme: theme,
                  country: BruneiCountry.brunei,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(PlateView),
      matchesGoldenFile('goldens/$name.png'),
    );
    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
  }

  testWidgets('private, KA 51', (tester) async {
    await render(
      tester,
      spec: BruneiPlates.singleRow(prefix: 2, digits: 2),
      theme: BruneiThemes.standard,
      values: 'K A 5 1',
      name: 'bn_standard_ka51',
    );
  });

  testWidgets('private, BAA 1234 (the longest)', (tester) async {
    await render(
      tester,
      spec: BruneiPlates.singleRow(prefix: 3, digits: 4),
      theme: BruneiThemes.standard,
      values: 'B A A 1 2 3 4',
      name: 'bn_standard_baa1234',
    );
  });

  testWidgets('military, MOD 1925 A', (tester) async {
    await render(
      tester,
      spec: BruneiPlates.singleRow(prefix: 3, digits: 4, suffix: true),
      theme: BruneiThemes.standard,
      values: 'M O D 1 9 2 5 A',
      name: 'bn_military_mod1925a',
    );
  });

  testWidgets('bus, KP 4708', (tester) async {
    await render(
      tester,
      spec: BruneiPlates.singleRow(prefix: 2, digits: 4),
      theme: BruneiThemes.taxi,
      values: 'K P 4 7 0 8',
      name: 'bn_taxi_kp4708',
    );
  });

  testWidgets('yellow, BX 9096', (tester) async {
    await render(
      tester,
      spec: BruneiPlates.singleRow(prefix: 2, digits: 4),
      theme: BruneiThemes.yellow,
      values: 'B X 9 0 9 6',
      name: 'bn_yellow_bx9096',
    );
  });

  testWidgets('diplomatic, 03·26·DC', (tester) async {
    await render(
      tester,
      spec: BruneiPlates.diplomatic(),
      theme: BruneiThemes.diplomatic,
      values: '0 3 2 6',
      name: 'bn_diplomatic_0326',
    );
  });

  testWidgets('diplomatic, 01·2·DC', (tester) async {
    await render(
      tester,
      spec: BruneiPlates.diplomatic(missionDigits: 1),
      theme: BruneiThemes.diplomatic,
      values: '0 1 2',
      name: 'bn_diplomatic_012',
    );
  });
}
