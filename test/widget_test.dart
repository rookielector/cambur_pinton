import 'package:flutter_test/flutter_test.dart';
import 'package:cambur_pinton/main.dart';

void main() {
  testWidgets('CamburPintonApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CamburPintonApp());
    expect(find.byType(CamburPintonApp), findsOneWidget);
  });
}
