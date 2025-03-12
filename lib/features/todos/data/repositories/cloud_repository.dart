import 'dart:convert';
import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo/features/todos/data/sources/drift/database.dart';
import 'package:todo/features/todos/domain/models/todo_models.dart';

class CloudRepository {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<void> syncAllTodos() async {
    final String? userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final List<Todo> todos = await AppDatabase().watchTodos().first;
    final todosJson = todos.map((todo) => todo.toJson()).toList();
    for (final todoJson in todosJson) {
      try {
        await Supabase.instance.client.rpc(
          'upsert_todo_with_categories',
          params: {'todo_data': todoJson, 'user_id': userId},
        );
      } catch (e) {
        log(e.toString());
      }
    }
  }

  Future<void> restoreTodos() async {
    final String? userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final todosJson = await Supabase.instance.client.rpc<List<dynamic>>(
        'get_todos_with_categories',
        params: {'current_user_id': userId},
      );
      final todos = todosJson.map((todoJson) => Todo.fromJson(todoJson)).toList();
      for (final todo in todos) {
        await AppDatabase().saveTodo(todo);
      }
    } catch (e) {
      log(e.toString());
    }
  }
}
