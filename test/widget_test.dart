import 'package:flutter_test/flutter_test.dart';
import 'package:user_app/app/app.dart';

void main() {
  testWidgets('GemgalaApp basic smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const GemgalaApp());
    expect(find.byType(GemgalaApp), findsOneWidget);
  });
}
