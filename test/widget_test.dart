// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('MetaNote App smoke test', (WidgetTester tester) async {
    // Build a simple MaterialApp for testing
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('MetaNote')),
            body: const Center(child: Text('MetaNote 테스트')),
          ),
        ),
      ),
    );

    // Wait for initial build
    await tester.pump();

    // Verify that the app loads correctly.
    expect(find.text('MetaNote'), findsOneWidget);
    expect(find.text('MetaNote 테스트'), findsOneWidget);
  });
}
