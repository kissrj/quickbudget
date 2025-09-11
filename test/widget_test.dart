// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:quickbudged/main.dart';
import 'package:quickbudged/models/transaction.dart';

void main() {
  setUp(() async {
    // Initialize Hive for testing
    await Hive.initFlutter();
    Hive.registerAdapter(TransactionAdapter());
  });

  testWidgets('App launches and shows main UI elements', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Wait for initialization
    await tester.pumpAndSettle();

    // Verify that the app title is present
    expect(find.text('Voice to Text'), findsOneWidget);

    // Verify that the microphone icon is present
    expect(find.byIcon(Icons.mic), findsOneWidget);

    // Verify that the initial text is shown
    expect(
      find.text('Press the microphone button to start speaking...'),
      findsOneWidget,
    );
  });

  testWidgets('Microphone button is present and tappable', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Wait for initialization
    await tester.pumpAndSettle();

    // Find the microphone button (FloatingActionButton)
    final micButton = find.byType(FloatingActionButton);

    // Verify the button exists
    expect(micButton, findsOneWidget);

    // Verify the button contains a mic icon
    expect(
      find.descendant(of: micButton, matching: find.byIcon(Icons.mic)),
      findsOneWidget,
    );
  });
}
