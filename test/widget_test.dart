import 'package:flutter_test/flutter_test.dart';

import 'package:myapp/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the dashboard is displayed
    expect(find.text('Good evening, Alex'), findsOneWidget);
    expect(find.text('Recent Documents'), findsOneWidget);
  });
}
