import 'package:flutter/material.dart';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Todo List',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const TodoHomePage(),
    );
  }
}

class TodoItem {
  TodoItem({required this.title, this.isDone = false});

  final String title;
  bool isDone;
}

class TodoHomePage extends StatefulWidget {
  const TodoHomePage({super.key});

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  final TextEditingController _controller = TextEditingController();
  final List<TodoItem> _todos = [
    TodoItem(title: 'Learn Flutter basics'),
    TodoItem(title: 'Build my first app'),
    TodoItem(title: 'Install the APK on my phone'),
  ];

  void _addTodo() {
    final title = _controller.text.trim();
    if (title.isEmpty) return;

    setState(() {
      _todos.insert(0, TodoItem(title: title));
      _controller.clear();
    });
    FocusScope.of(context).unfocus();
  }

  void _toggleTodo(int index, bool? checked) {
    setState(() {
      _todos[index].isDone = checked ?? false;
    });
  }

  void _deleteTodo(int index) {
    final removed = _todos[index].title;
    setState(() => _todos.removeAt(index));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleted: $removed'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final completed = _todos.where((todo) => todo.isDone).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Todo List'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Small steps, big progress.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text('$completed of ${_todos.length} tasks completed'),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: _todos.isEmpty ? 0 : completed / _todos.length,
                minHeight: 6,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _addTodo(),
                      decoration: const InputDecoration(
                        hintText: 'Add a task...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _addTodo,
                    tooltip: 'Add task',
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _todos.isEmpty
                    ? const Center(
                        child: Text('No tasks yet. Add your first task!'),
                      )
                    : ListView.separated(
                        itemCount: _todos.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 4),
                        itemBuilder: (context, index) {
                          final todo = _todos[index];
                          return Card(
                            child: CheckboxListTile(
                              value: todo.isDone,
                              onChanged: (checked) =>
                                  _toggleTodo(index, checked),
                              controlAffinity:
                                  ListTileControlAffinity.leading,
                              title: Text(
                                todo.title,
                                style: TextStyle(
                                  decoration: todo.isDone
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                  color: todo.isDone
                                      ? Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant
                                      : null,
                                ),
                              ),
                              secondary: IconButton(
                                tooltip: 'Delete task',
                                onPressed: () => _deleteTodo(index),
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
