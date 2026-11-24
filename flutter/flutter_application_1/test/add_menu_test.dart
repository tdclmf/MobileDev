import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/AdditionalComponents/add_menu.dart';

void main() {
  testWidgets('Failed insert preserves input; successful insert clears it', (
    tester,
  ) async {
    var saved = false;
    final submitted = <String?>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AddMenu(
            insert: (username, password) async {
              submitted.addAll([username, password]);
              return saved;
            },
          ),
        ),
      ),
    );
    final inputs = find.byType(TextFormField);
    await tester.enterText(inputs.at(0), 'Alice');
    await tester.enterText(inputs.at(1), 'demo-password');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Добавить'));
    await tester.pump();
    expect(submitted, ['Alice', 'demo-password']);
    expect(
      tester.widget<TextFormField>(inputs.at(0)).controller!.text,
      'Alice',
    );
    expect(
      tester.widget<TextFormField>(inputs.at(1)).controller!.text,
      'demo-password',
    );
    saved = true;
    await tester.tap(find.widgetWithText(ElevatedButton, 'Добавить'));
    await tester.pump();
    expect(
      tester.widget<TextFormField>(inputs.at(0)).controller!.text,
      isEmpty,
    );
    expect(
      tester.widget<TextFormField>(inputs.at(1)).controller!.text,
      isEmpty,
    );
  });
}
