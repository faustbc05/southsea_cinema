import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/views/settings_view.dart';

void main() {
  testWidgets(
      'Settings page displays profile fields, newsletter switch and save button',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: SettingsView(),
    ));

    expect(find.text("User Profile"), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(3));
    expect(find.byType(SwitchListTile), findsOneWidget);
    expect(find.text("Save Settings"), findsOneWidget);
  });

  testWidgets('Saving profile displays confirmation with trimmed name',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: SettingsView(),
    ));
    final nameField = find.widgetWithText(TextField, 'Full name');
    final emailField = find.widgetWithText(TextField, 'Email');
    final addressField = find.widgetWithText(TextField, 'Address');

    await tester.enterText(nameField, '  Alex Smith  ');
    await tester.enterText(emailField, '  alex.smith@outlook.com  ');
    await tester.enterText(addressField, '  65 Landport Terrace  ');
    await tester.ensureVisible(find.text("Save Settings"));
    await tester.tap(find.text("Save Settings"));
    await tester.pump();

    expect(
        find.text('Alex Smith, your settings have been saved'), findsOneWidget);
  });

  testWidgets('Tapping newsletter preference enables the switch',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: SettingsView(),
    ));
    final switchListTile = find.byType(SwitchListTile);
    expect(tester.widget<SwitchListTile>(switchListTile).value, isFalse);

    await tester.tap(switchListTile);
    await tester.pumpAndSettle();

    expect(tester.widget<SwitchListTile>(switchListTile).value, isTrue);
  });
}
