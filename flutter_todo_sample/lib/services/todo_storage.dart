import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/todo_item.dart';

class TodoStorage {
  static const _storageKey = 'todo_items_v1';

  Future<List<TodoItem>> load() async {
    final preferences = await SharedPreferences.getInstance();
    final savedItems = preferences.getString(_storageKey);
    if (savedItems == null) return [];

    try {
      final decoded = jsonDecode(savedItems);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map>()
          .map(
            (item) => TodoItem.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    } on FormatException {
      return [];
    } on TypeError {
      return [];
    }
  }

  Future<void> save(List<TodoItem> items) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _storageKey,
      jsonEncode(items.map((item) => item.toJson()).toList()),
    );
  }
}
