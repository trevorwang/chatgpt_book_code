// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:chatgpt/widgets/chat_gpt_model_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openai_api/openai_api.dart';

void main() {
  testWidgets('GptModel Dropdown', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    const dropdown = GptModelWidget(
      active: null,
    );
    await tester.pumpWidget(const MaterialApp(
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Scaffold(
        body: SizedBox(
          height: 32,
          child: dropdown,
        ),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('GPT-3.5'), findsOneWidget);
    expect(find.byType(DropdownMenuItem<String>), findsWidgets);
  });

  testWidgets('GptModel value', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    const dropdown = GptModelWidget(
      active: Models.gpt4,
    );
    await tester.pumpWidget(const MaterialApp(
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Scaffold(
        body: SizedBox(
          height: 32,
          child: dropdown,
        ),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('GPT-3.5'), findsNothing);
    expect(find.byType(DropdownMenuItem<String>), findsNothing);
    expect(find.text('GPT-4'), findsOneWidget);
  });
}
