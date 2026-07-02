import 'package:flutter_test/flutter_test.dart';

import 'package:crm/main.dart';

void main() {
  testWidgets('CTRL F login renders', (WidgetTester tester) async {
    await tester.pumpWidget(const CrmApp());

    await tester.pump();
    expect(find.text('CTRL F'), findsWidgets);
  });
}
