import 'package:flutter_todo_sample/models/todo_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('serializes and restores all task fields', () {
    final task = TodoItem(
      id: 'task-1',
      title: 'Prepare release',
      category: 'Work',
      createdAt: DateTime(2026, 10, 12, 9),
      dueDate: DateTime(2026, 10, 20),
      priority: TodoPriority.high,
      isDone: true,
    );

    final restored = TodoItem.fromJson(task.toJson());

    expect(restored.toJson(), task.toJson());
  });

  test('uses defaults for optional fields in older saved tasks', () {
    final task = TodoItem.fromJson({
      'id': 'legacy-task',
      'title': 'Review notes',
      'createdAt': '2026-10-12T09:00:00.000',
    });

    expect(task.category, 'Personal');
    expect(task.priority, TodoPriority.medium);
    expect(task.isDone, isFalse);
    expect(task.dueDate, isNull);
  });
}
