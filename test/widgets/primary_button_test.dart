import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:southsea_cinema/widgets/primary_button.dart';

void main() {
  testWidgets(
      'PrimaryButton successfully presents label and onPressed attribute works',
      (WidgetTester tester) async {
    bool wasPressed = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: PrimaryButton(
            label: 'Test button',
            onPressed: () {
              wasPressed = true;
            }),
      ),
    ));

    expect(find.text('Test button'), findsOneWidget);
    expect(wasPressed, isFalse);

    await tester.tap(find.byType(PrimaryButton));

    expect(wasPressed, isTrue);
  });
}
