// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

// CORRECTED: The import path now uses the correct package name 'gearhead_wizard'
// as defined in your pubspec.yaml file.
import 'package:gearhead_wizard/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const GearheadWizardApp());

    // Verify that the home page title is present.
    expect(find.text('Gearhead Wizard'), findsOneWidget);

    // Verify one of the tool cards is present.
    expect(find.text('Turbo'), findsOneWidget);
  });
}