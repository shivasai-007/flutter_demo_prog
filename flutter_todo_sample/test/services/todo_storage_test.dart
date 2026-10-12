import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_todo_sample/models/todo_item.dart';
import 'package:flutter_todo_sample/services/todo_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('saves and restores tasks from local preferences', () async {
    final storage = TodoStorage();
    final task = TodoItem(
      id: 'task-1',
      title: 'Prepare release',
      category: 'Work',
      createdAt: DateTime(2026, 10, 12),
      dueDate: DateTime(2026, 10, 20),
      priority: TodoPriority.high,
    );

    await storage.save([task]);
    final restored = await storage.load();

    expect(restored, hasLength(1));
    expect(restored.single.toJson(), task.toJson());
  });

  test('returns an empty list when saved JSON is malformed', () async {
    SharedPreferences.setMockInitialValues({'todo_items_v1': '{broken'});

    expect(await TodoStorage().load(), isEmpty);
  });
}
