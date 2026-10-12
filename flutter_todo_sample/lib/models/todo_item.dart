enum TodoPriority { low, medium, high }

class TodoItem {
  const TodoItem({
    required this.id,
    required this.title,
    required this.category,
    required this.createdAt,
    this.dueDate,
    this.priority = TodoPriority.medium,
    this.isDone = false,
  });

  final String id;
  final String title;
  final String category;
  final DateTime createdAt;
  final DateTime? dueDate;
  final TodoPriority priority;
  final bool isDone;

  TodoItem copyWith({
    String? title,
    String? category,
    DateTime? dueDate,
    bool clearDueDate = false,
    TodoPriority? priority,
    bool? isDone,
  }) {
    return TodoItem(
      id: id,
      title: title ?? this.title,
      category: category ?? this.category,
      createdAt: createdAt,
      dueDate: clearDueDate ? null : dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isDone: isDone ?? this.isDone,
    );
  }

  Map<String, Object?> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'createdAt': createdAt.toIso8601String(),
        'dueDate': dueDate?.toIso8601String(),
        'priority': priority.name,
        'isDone': isDone,
      };

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    final priorityName = json['priority'] as String?;

    return TodoItem(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String? ?? 'Personal',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      dueDate: DateTime.tryParse(json['dueDate'] as String? ?? ''),
      priority: TodoPriority.values.firstWhere(
        (priority) => priority.name == priorityName,
        orElse: () => TodoPriority.medium,
      ),
      isDone: json['isDone'] as bool? ?? false,
    );
  }
}
