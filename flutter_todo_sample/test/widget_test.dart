import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_todo_sample/main.dart';

void main() {
  testWidgets('opens the Daymark task manager', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const TodoApp());
    await tester.pumpAndSettle();

    expect(find.text('Daymark'), findsOneWidget);
    expect(find.text('A clear start'), findsOneWidget);
  });
}
