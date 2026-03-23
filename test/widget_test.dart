import 'package:flutter_test/flutter_test.dart';
import 'package:bachat_karo/main.dart';

void main() {
  testWidgets('BachatKaro app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BachatKaroApp());
    expect(find.byType(BachatKaroApp), findsOneWidget);
  });
}
