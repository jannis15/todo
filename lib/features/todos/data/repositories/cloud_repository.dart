import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:workout/features/todos/data/sources/drift/database.dart';
import 'package:workout/features/todos/domain/models/todo_models.dart';

class CloudRepository {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<void> syncAllTodos() async {
    final String? userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final List<Todo> todos = await AppDatabase().watchTodos().first;
    final uniqueCategories = todos.expand((todo) => todo.categories).toSet().toList();

    await Future.wait([
      _deleteMissingTodos(todos, userId),
      _deleteMissingCategories(uniqueCategories, userId),
    ]);

    await Future.wait([
      _insertTodosBulk(todos, userId),
      _insertCategoriesBulk(uniqueCategories, userId),
    ]);

    await _insertTodoCategoryLinksBulk(todos);
  }

  Future<void> _insertTodosBulk(List<Todo> todos, String userId) async {
    await supabase
        .from('tbl_todos')
        .upsert(
          todos
              .map(
                (todo) => {
                  'uuid': todo.uuid,
                  'title': todo.title,
                  'content': todo.content,
                  'user_id': userId,
                  'created_at':
                      todo.createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
                  'edited_at': todo.editedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
                },
              )
              .toList(),
        );
  }

  Future<void> _insertCategoriesBulk(List<Category> categories, String userId) async {
    if (categories.isEmpty) return;

    await supabase
        .from('tbl_categories')
        .upsert(
          categories
              .map(
                (category) => {
                  'uuid': category.uuid,
                  'category_name': category.categoryName,
                  'user_id': userId,
                  'created_at':
                      category.createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
                },
              )
              .toList(),
        );
  }

  Future<void> _insertTodoCategoryLinksBulk(List<Todo> todos) async {
    final List<Map<String, dynamic>> links = [];

    for (final todo in todos) {
      for (final category in todo.categories) {
        links.add({'todo_uuid': todo.uuid, 'category_uuid': category.uuid});
      }
    }

    if (links.isNotEmpty) {
      await supabase.from('tbl_todo_categories').upsert(links);
    }
  }

  Future<void> _deleteMissingTodos(List<Todo> localTodos, String userId) async {
    final localUuids = localTodos.map((todo) => todo.uuid).toList();
    await supabase
        .from('tbl_todos')
        .delete()
        .eq('user_id', userId)
        .filter('uuid', 'not.in', localUuids);
  }

  Future<void> _deleteMissingCategories(List<Category> localCategories, String userId) async {
    final localUuids = localCategories.map((category) => category.uuid).toList();
    await supabase
        .from('tbl_categories')
        .delete()
        .eq('user_id', userId)
        .filter('uuid', 'not.in', localUuids);
  }
}
