import 'package:flutter_test/flutter_test.dart';
import 'package:exematching/main.dart';

void main() {
  testWidgets('App skeleton smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const EXEMatchingApp());
    expect(find.text('EXEMatching'), findsOneWidget);
  });
}
