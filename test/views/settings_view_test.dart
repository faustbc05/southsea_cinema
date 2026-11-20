import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/main.dart';
import 'package:southsea_cinema/views/settings_view.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });
  testWidgets(
      'Settings page displays profile fields, newsletter switch and save button',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: SettingsView(),
    ));
    await tester.pumpAndSettle();

    expect(find.text("User Profile"), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(3));
    expect(find.byType(SwitchListTile), findsNWidgets(2));
    expect(find.text("Save Settings"), findsOneWidget);
  });

  testWidgets('Theme switch applies immediately and persists selection',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const SouthseaCinemaApp(initialRoute: '/settings'),
    );
    await tester.pumpAndSettle();

    final themeSwitch = find.byType(SwitchListTile).at(1);
    expect(tester.widget<SwitchListTile>(themeSwitch).value, isTrue);
    expect(
      Theme.of(tester.element(find.byType(Scaffold))).brightness,
      Brightness.dark,
    );

    await tester.tap(themeSwitch);
    await tester.pumpAndSettle();

    expect(tester.widget<SwitchListTile>(themeSwitch).value, isFalse);
    expect(
      Theme.of(tester.element(find.byType(Scaffold))).brightness,
      Brightness.light,
    );
    expect(await SharedPreferencesAsync().getString(prefThemeMode), 'light');
  });

  testWidgets('App restores saved theme mode after recreation',
      (WidgetTester tester) async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.withData(<String, Object>{
      prefThemeMode: 'light',
    });

    await tester.pumpWidget(
      const SouthseaCinemaApp(initialRoute: '/settings'),
    );
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.byType(Scaffold))).brightness,
      Brightness.light,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(
      const SouthseaCinemaApp(initialRoute: '/settings'),
    );
    await tester.pumpAndSettle();

    expect(
      Theme.of(tester.element(find.byType(Scaffold))).brightness,
      Brightness.light,
    );
    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile).at(1)).value,
      isFalse,
    );
  });

  testWidgets(
      'Saving profile persists trimmed values and restores them on reopen',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: SettingsView(),
    ));
    await tester.pumpAndSettle();
    final nameField = find.widgetWithText(TextField, 'Full name');
    final emailField = find.widgetWithText(TextField, 'Email');
    final addressField = find.widgetWithText(TextField, 'Address');

    await tester.enterText(nameField, '  Alex Smith  ');
    await tester.enterText(emailField, '  alex.smith@outlook.com  ');
    await tester.enterText(addressField, '  65 Landport Terrace  ');
    final switchListTile = find.byType(SwitchListTile).at(0);

    await tester.tap(switchListTile);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text("Save Settings"));
    await tester.tap(find.text("Save Settings"));
    await tester.pumpAndSettle();

    expect(
        find.text('Alex Smith, your settings have been saved'), findsOneWidget);
    final prefs = SharedPreferencesAsync();
    expect(await prefs.getString(prefName), 'Alex Smith');
    expect(await prefs.getString(prefEmail), 'alex.smith@outlook.com');
    expect(await prefs.getString(prefAddress), '65 Landport Terrace');
    expect(await prefs.getBool(prefNewsletter), isTrue);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(MaterialApp(home: SettingsView()));
    await tester.pumpAndSettle();
    expect(find.text('Alex Smith'), findsOneWidget);
    expect(find.text('alex.smith@outlook.com'), findsOneWidget);
    expect(find.text('65 Landport Terrace'), findsOneWidget);
    expect(
        tester.widget<SwitchListTile>(find.byType(SwitchListTile).at(0)).value,
        isTrue);
  });

  testWidgets('Tapping newsletter preference enables the switch',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: SettingsView(),
    ));
    await tester.pumpAndSettle();
    final switchListTile = find.byType(SwitchListTile).at(0);
    expect(tester.widget<SwitchListTile>(switchListTile).value, isFalse);

    await tester.tap(switchListTile);
    await tester.pumpAndSettle();

    expect(tester.widget<SwitchListTile>(switchListTile).value, isTrue);
  });

  testWidgets('Settings page load previously saved profile on open',
      (WidgetTester tester) async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.withData(<String, Object>{
      prefName: 'Jordan Taylor',
      prefEmail: 'jordan.taylor@example.com',
      prefAddress: '65 Landport Terrace',
      prefNewsletter: true,
    });

    await tester.pumpWidget(MaterialApp(
      home: SettingsView(),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Jordan Taylor'), findsOneWidget);
    expect(find.text('jordan.taylor@example.com'), findsOneWidget);
    expect(find.text('65 Landport Terrace'), findsOneWidget);
    expect(
        tester.widget<SwitchListTile>(find.byType(SwitchListTile).at(0)).value,
        isTrue);
  });
}
