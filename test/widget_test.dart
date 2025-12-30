import 'package:flutter_test/flutter_test.dart';
import 'package:smart_food_scanner/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SmartFoodScannerApp());

    // Verify that our counter starts at 0.
    expect(find.text('Smart Food Scanner'), findsOneWidget);

    // Verify that we can find the splash screen
    expect(find.text('Scan. Analyze. Choose Wisely.'), findsOneWidget);
  });
}
