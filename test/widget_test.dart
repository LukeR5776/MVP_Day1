// Basic widget test for Day1 app

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:day1/app.dart';

void main() {
  testWidgets('App loads and shows Today screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: Day1App(),
      ),
    );

    // Verify that the app loads
    await tester.pumpAndSettle();

    // Verify that we see the empty state or home screen
    expect(find.text('Every journey starts'), findsOneWidget);
  });
}
