import 'package:flutter/material.dart';

import '../models/todo_item.dart';
import '../services/todo_storage.dart';

enum _TodoFilter { all, active, completed }

enum _TodoSort { created, dueDate, priority }

class TodoHomePage extends StatefulWidget {
  const TodoHomePage({super.key});

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  static const _categories = ['Personal', 'Work', 'Study', 'Health', 'Other'];

  final _storage = TodoStorage();
  final _searchController = TextEditingController();
  final List<TodoItem> _todos = [];
  _TodoFilter _filter = _TodoFilter.all;
  _TodoSort _sort = _TodoSort.created;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTodos() async {
    try {
      final savedTodos = await _storage.load();
      if (!mounted) return;
      setState(() {
        _todos
          ..clear()
          ..addAll(savedTodos);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showMessage('Your saved tasks could not be loaded.');
    }
  }

  Future<void> _persistTodos() async {
    try {
      await _storage.save(List.of(_todos));
    } catch (_) {
      if (mounted) _showMessage('Your changes could not be saved.');
    }
  }

  Future<void> _openEditor([TodoItem? existing]) async {
    final updatedTodo = await showDialog<TodoItem>(
      context: context,
      builder: (_) => _TaskEditorDialog(
        initialTask: existing,
        categories: _categories,
      ),
    );
    if (updatedTodo == null || !mounted) return;

    setState(() {
      final index = _todos.indexWhere((todo) => todo.id == updatedTodo.id);
      if (index == -1) {
        _todos.insert(0, updatedTodo);
      } else {
        _todos[index] = updatedTodo;
      }
    });
    await _persistTodos();
  }

  Future<void> _toggleTodo(TodoItem todo) async {
    setState(() {
      final index = _todos.indexWhere((item) => item.id == todo.id);
      _todos[index] = todo.copyWith(isDone: !todo.isDone);
    });
    await _persistTodos();
  }

  Future<void> _deleteTodo(TodoItem todo) async {
    final index = _todos.indexWhere((item) => item.id == todo.id);
    if (index == -1) return;
    setState(() => _todos.removeAt(index));
    await _persistTodos();
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Deleted "${todo.title}"'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              setState(() {
                _todos.insert(index.clamp(0, _todos.length).toInt(), todo);
              });
              _persistTodos();
            },
          ),
        ),
      );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  List<TodoItem> _visibleTodos() {
    final query = _searchController.text.trim().toLowerCase();
    final visible = _todos.where((todo) {
      final matchesFilter = switch (_filter) {
        _TodoFilter.all => true,
        _TodoFilter.active => !todo.isDone,
        _TodoFilter.completed => todo.isDone,
      };
      final matchesQuery = query.isEmpty ||
          todo.title.toLowerCase().contains(query) ||
          todo.category.toLowerCase().contains(query);
      return matchesFilter && matchesQuery;
    }).toList();

    visible.sort((first, second) {
      switch (_sort) {
        case _TodoSort.created:
          return second.createdAt.compareTo(first.createdAt);
        case _TodoSort.dueDate:
          if (first.dueDate == null && second.dueDate != null) return 1;
          if (first.dueDate != null && second.dueDate == null) return -1;
          final dueOrder = first.dueDate?.compareTo(second.dueDate!) ?? 0;
          return dueOrder == 0
              ? second.createdAt.compareTo(first.createdAt)
              : dueOrder;
        case _TodoSort.priority:
          final priorityOrder =
              second.priority.index.compareTo(first.priority.index);
          return priorityOrder == 0
              ? second.createdAt.compareTo(first.createdAt)
              : priorityOrder;
      }
    });
    return visible;
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _todos.where((todo) => todo.isDone).length;
    final visibleTodos = _visibleTodos();
    final progress = _todos.isEmpty ? 0.0 : completedCount / _todos.length;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                Icons.checklist_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 10),
            const Text('Daymark'),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Make room for what matters.',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$completedCount of ${_todos.length} tasks complete',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 8,
                            backgroundColor:
                                Theme.of(context).colorScheme.tertiaryContainer,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'Search tasks or categories',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchController.text.isEmpty
                                ? null
                                : IconButton(
                                    tooltip: 'Clear search',
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {});
                                    },
                                    icon: const Icon(Icons.close),
                                  ),
                            filled: true,
                            fillColor:
                                Theme.of(context).colorScheme.surfaceContainer,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        SegmentedButton<_TodoFilter>(
                          showSelectedIcon: false,
                          segments: const [
                            ButtonSegment(
                              value: _TodoFilter.all,
                              label: Text('All'),
                            ),
                            ButtonSegment(
                              value: _TodoFilter.active,
                              label: Text('Active'),
                            ),
                            ButtonSegment(
                              value: _TodoFilter.completed,
                              label: Text('Done'),
                            ),
                          ],
                          selected: {_filter},
                          onSelectionChanged: (selection) => setState(
                            () => _filter = selection.first,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: PopupMenuButton<_TodoSort>(
                            tooltip: 'Sort tasks',
                            initialValue: _sort,
                            onSelected: (sort) => setState(() => _sort = sort),
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: _TodoSort.created,
                                child: Text('Recently added'),
                              ),
                              PopupMenuItem(
                                value: _TodoSort.dueDate,
                                child: Text('Due date'),
                              ),
                              PopupMenuItem(
                                value: _TodoSort.priority,
                                child: Text('Priority'),
                              ),
                            ],
                            child: Container(
                              height: 42,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outlineVariant,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.swap_vert, size: 19),
                                  const SizedBox(width: 4),
                                  Text(_sortLabel(_sort)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: visibleTodos.isEmpty
                              ? _EmptyTasks(
                                  hasTasks: _todos.isNotEmpty,
                                  onAdd: () => _openEditor(),
                                )
                              : ListView.separated(
                                  itemCount: visibleTodos.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 8),
                                  itemBuilder: (context, index) {
                                    final todo = visibleTodos[index];
                                    return _TaskTile(
                                      todo: todo,
                                      onToggle: () => _toggleTodo(todo),
                                      onEdit: () => _openEditor(todo),
                                      onDelete: () => _deleteTodo(todo),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
      floatingActionButton: _isLoading
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _openEditor(),
              icon: const Icon(Icons.add),
              label: const Text('New task'),
            ),
    );
  }
}

String _sortLabel(_TodoSort sort) => switch (sort) {
      _TodoSort.created => 'Recent',
      _TodoSort.dueDate => 'Due date',
      _TodoSort.priority => 'Priority',
    };

class _TaskTile extends StatelessWidget {
  const _TaskTile({
    required this.todo,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final TodoItem todo;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final priorityColor = switch (todo.priority) {
      TodoPriority.low => colors.primary,
      TodoPriority.medium => const Color(0xFFDA9B27),
      TodoPriority.high => colors.secondary,
    };

    return Card(
      margin: EdgeInsets.zero,
      color: colors.surface,
      child: ListTile(
        onTap: onEdit,
        contentPadding: const EdgeInsets.only(left: 8, right: 8),
        leading: Checkbox(
          value: todo.isDone,
          onChanged: (_) => onToggle(),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
        title: Text(
          todo.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            decoration: todo.isDone ? TextDecoration.lineThrough : null,
            color: todo.isDone ? colors.onSurfaceVariant : colors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 7),
          child: Wrap(
            spacing: 8,
            runSpacing: 5,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _InfoTag(
                label: todo.category,
                color: colors.tertiary,
                background: colors.tertiaryContainer,
              ),
              _InfoTag(
                label: _priorityLabel(todo.priority),
                color: priorityColor,
                background: priorityColor.withValues(alpha: 0.12),
              ),
              if (todo.dueDate != null)
                _DueDateLabel(dueDate: todo.dueDate!, isDone: todo.isDone),
            ],
          ),
        ),
        trailing: PopupMenuButton<String>(
          tooltip: 'Task actions',
          onSelected: (action) {
            if (action == 'edit') onEdit();
            if (action == 'delete') onDelete();
          },
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit_outlined),
                title: Text('Edit'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete_outline),
                title: Text('Delete'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTag extends StatelessWidget {
  const _InfoTag({
    required this.label,
    required this.color,
    required this.background,
  });

  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}

class _DueDateLabel extends StatelessWidget {
  const _DueDateLabel({required this.dueDate, required this.isDone});

  final DateTime dueDate;
  final bool isDone;

  @override
  Widget build(BuildContext context) {
    final today = DateUtils.dateOnly(DateTime.now());
    final date = DateUtils.dateOnly(dueDate);
    final isOverdue = !isDone && date.isBefore(today);
    final color = isOverdue
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.onSurfaceVariant;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.calendar_today_outlined, size: 13, color: color),
        const SizedBox(width: 4),
        Text(
          MaterialLocalizations.of(context).formatMediumDate(dueDate),
          style: TextStyle(color: color, fontSize: 12),
        ),
      ],
    );
  }
}

class _EmptyTasks extends StatelessWidget {
  const _EmptyTasks({required this.hasTasks, required this.onAdd});

  final bool hasTasks;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasTasks ? Icons.search_off_rounded : Icons.checklist_rounded,
            size: 44,
            color: colors.primary,
          ),
          const SizedBox(height: 12),
          Text(
            hasTasks ? 'No matching tasks' : 'A clear start',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            hasTasks ? 'Try another search or filter.' : 'Add a task to begin.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (!hasTasks) ...[
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add a task'),
            ),
          ],
        ],
      ),
    );
  }
}

class _TaskEditorDialog extends StatefulWidget {
  const _TaskEditorDialog(
      {required this.initialTask, required this.categories});

  final TodoItem? initialTask;
  final List<String> categories;

  @override
  State<_TaskEditorDialog> createState() => _TaskEditorDialogState();
}

class _TaskEditorDialogState extends State<_TaskEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late String _category;
  late TodoPriority _priority;
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    final task = widget.initialTask;
    _titleController = TextEditingController(text: task?.title ?? '');
    _category = widget.categories.contains(task?.category)
        ? task!.category
        : widget.categories.first;
    _priority = task?.priority ?? TodoPriority.medium;
    _dueDate = task?.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final existing = widget.initialTask;
    Navigator.of(context).pop(
      TodoItem(
        id: existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        category: _category,
        createdAt: existing?.createdAt ?? DateTime.now(),
        dueDate: _dueDate,
        priority: _priority,
        isDone: existing?.isDone ?? false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialTask == null ? 'New task' : 'Edit task'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  autofocus: true,
                  maxLength: 100,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Task name',
                    hintText: 'What needs to get done?',
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter a task name'
                      : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: widget.categories
                      .map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _category = value);
                  },
                ),
                const SizedBox(height: 18),
                Text('Priority', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<TodoPriority>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(
                        value: TodoPriority.low,
                        label: Text('Low'),
                      ),
                      ButtonSegment(
                        value: TodoPriority.medium,
                        label: Text('Medium'),
                      ),
                      ButtonSegment(
                        value: TodoPriority.high,
                        label: Text('High'),
                      ),
                    ],
                    selected: {_priority},
                    onSelectionChanged: (selection) =>
                        setState(() => _priority = selection.first),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _dueDate == null
                            ? 'No due date'
                            : MaterialLocalizations.of(context)
                                .formatMediumDate(_dueDate!),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _pickDueDate,
                      icon: const Icon(Icons.calendar_month_outlined),
                      label: Text(_dueDate == null ? 'Add date' : 'Change'),
                    ),
                    if (_dueDate != null)
                      IconButton(
                        onPressed: () => setState(() => _dueDate = null),
                        tooltip: 'Remove due date',
                        icon: const Icon(Icons.close),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save task')),
      ],
    );
  }
}

String _priorityLabel(TodoPriority priority) => switch (priority) {
      TodoPriority.low => 'Low',
      TodoPriority.medium => 'Medium',
      TodoPriority.high => 'High',
    };
