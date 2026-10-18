import 'package:flutter_test/flutter_test.dart';
import 'package:lapakpindah/main.dart';

void main() {
  testWidgets('App launches without error', (WidgetTester tester) async {
    await tester.pumpWidget(const LapakPindahApp());
    // Verify the app renders (login screen should show)
    expect(find.byType(LapakPindahApp), findsOneWidget);
  });
}
