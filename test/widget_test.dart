import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pdf_organizer/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app with ProviderScope and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    // Wait for localizations to load
    await tester.pumpAndSettle();

    // Verify that the app launches without error
    expect(find.byType(MyApp), findsOneWidget);
  });
}
