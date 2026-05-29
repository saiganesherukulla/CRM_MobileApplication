import 'package:flutter_test/flutter_test.dart';

import 'package:crm/main.dart';

void main() {
  testWidgets('crm login renders', (WidgetTester tester) async {
    await tester.pumpWidget(const CrmApp());

    await tester.pump();
    expect(find.text('crm'), findsWidgets);
  });
}
