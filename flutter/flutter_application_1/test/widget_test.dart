import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/main.dart' as app;
import 'package:flutter_application_1/firebase_options.dart';

void main() {
  test('Firebase is optional without configuration', () {
    expect(DefaultFirebaseOptions.currentPlatform, isNull);
  });

  testWidgets('Menu works without cloud credentials', (tester) async {
    await tester.pumpWidget(const app.MyApp());
    expect(find.text('MobileDev — главное меню'), findsOneWidget);
    expect(find.textContaining('Подключите свои Supabase'), findsOneWidget);
    for (final label in ['Supabase', 'Firebase']) {
      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, label),
      );
      expect(button.onPressed, isNull);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('Entrypoint runs without cloud credentials', (tester) async {
    await app.main();
    await tester.pumpAndSettle();
    expect(find.text('MobileDev — главное меню'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Unconfigured backend routes show setup instead of crashing', (
    tester,
  ) async {
    await tester.pumpWidget(const app.MyApp());
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pushNamed('/supabase/auth');
    await tester.pumpAndSettle();
    expect(find.text('Настройка подключения'), findsOneWidget);
    expect(tester.takeException(), isNull);
    navigator.pop();
    await tester.pumpAndSettle();
    navigator.pushNamed('/firebase');
    await tester.pumpAndSettle();
    expect(find.text('Настройка подключения'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
