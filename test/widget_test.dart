import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_app/main.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SigmaCardsApp());

    // Verify that the app loads with SigmaCards title
    expect(find.text('SigmaCards'), findsOneWidget);
  });
}
