import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_todo_sample/models/todo_item.dart';
import 'package:flutter_todo_sample/screens/todo_home_page.dart';
import 'package:flutter_todo_sample/services/todo_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('creates, completes, searches, and persists a task',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: TodoHomePage()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('New task'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Prepare release');

    await tester.tap(find.text('Personal'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Work').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('High'));
    await tester.tap(find.text('Save task'));
    await tester.pumpAndSettle();

    expect(find.text('Prepare release'), findsOneWidget);
    expect(find.text('Work'), findsOneWidget);
    expect(find.text('High'), findsOneWidget);

    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Active'));
    await tester.pumpAndSettle();
    expect(find.text('Prepare release'), findsNothing);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Prepare release'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'not a task');
    await tester.pumpAndSettle();
    expect(find.text('No matching tasks'), findsOneWidget);

    final restored = await TodoStorage().load();
    expect(restored, hasLength(1));
    expect(restored.single.category, 'Work');
    expect(restored.single.priority, TodoPriority.high);
    expect(restored.single.isDone, isTrue);
  });

  testWidgets('edits, sorts, and restores a deleted task', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: TodoHomePage()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('New task'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Draft plan');
    await tester.tap(find.text('Save task'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Draft plan'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Final plan');
    await tester.tap(find.text('Save task'));
    await tester.pumpAndSettle();
    expect(find.text('Final plan'), findsOneWidget);

    await tester.tap(find.text('Recent'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Priority'));
    await tester.pumpAndSettle();
    expect(find.text('Final plan'), findsOneWidget);

    await tester.tap(find.byTooltip('Task actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Final plan'), findsNothing);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text('Final plan'), findsOneWidget);
    expect((await TodoStorage().load()).single.title, 'Final plan');
  });
}
