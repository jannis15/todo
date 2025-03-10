import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:workout/features/todos/domain/models/todo_models.dart';
import 'package:workout/features/todos/domain/utils/todo_filter_sort_utils.dart';
import 'package:workout/core/utils/dart/sort_utils.dart';

part 'database.g.dart';

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'app_database.sqlite'));
    return NativeDatabase(file);
  });
}

@DataClassName('todo')
class TblTodos extends Table {
  TextColumn get uuid => text().withDefault(Constant(const Uuid().v4()))();

  TextColumn get title => text()();

  TextColumn get content => text()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get editedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {uuid};
}

@DataClassName('todo_category')
class TblTodoCategories extends Table {
  TextColumn get todoUuid => text().references(TblTodos, #uuid)();

  TextColumn get categoryUuid => text().references(TblCategories, #uuid)();

  @override
  Set<Column<Object>> get primaryKey => {todoUuid, categoryUuid};
}

@DataClassName('category')
class TblCategories extends Table {
  TextColumn get uuid => text().withDefault(Constant(const Uuid().v4()))();

  TextColumn get categoryName => text()();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {uuid};
}

@DriftDatabase(tables: [TblTodos, TblTodoCategories, TblCategories])
class AppDatabase extends _$AppDatabase {
  static AppDatabase? _instance;

  AppDatabase._(super.e);

  factory AppDatabase() => _instance ??= AppDatabase._(_openConnection());

  @override
  int get schemaVersion => 1;

  Future<void> saveTodo(Todo todo) async {
    Future<void> insertCategories({required String todoUuid}) async {
      if (todo.uuid != null) {
        final query = delete(tblTodoCategories)..where((tbl) => tbl.todoUuid.isValue(todo.uuid!));
        await query.go();
      }

      final newCategories = todo.categories.where((e) => e.uuid == null).toList();
      await batch((batch) async {
        newCategories.forEach((category) async {
          final categoryUuid = const Uuid().v4();
          await into(tblCategories).insert(
            TblCategoriesCompanion(
              uuid: Value(categoryUuid),
              categoryName: Value(category.categoryName),
            ),
          );
          category.uuid = categoryUuid;
        });
      });

      await batch((batch) async {
        todo.categories.forEach((category) async {
          await into(tblTodoCategories).insertOnConflictUpdate(
            TblTodoCategoriesCompanion(
              todoUuid: Value(todoUuid),
              categoryUuid: Value(category.uuid!),
            ),
          );
        });
      });
    }

    final todoUuid = todo.uuid ?? const Uuid().v4();
    await transaction(() async {
      await Future.wait([
        into(tblTodos).insertOnConflictUpdate(
          TblTodosCompanion(
            uuid: Value(todoUuid),
            title: Value(todo.title),
            content: Value(todo.content),
            createdAt: Value(todo.createdAt ?? DateTime.now()),
            editedAt: Value(DateTime.now()),
          ),
        ),
        insertCategories(todoUuid: todoUuid),
      ]);
    });
    todo.uuid = todoUuid;
  }

  Stream<List<Category>> watchCategories() {
    return select(
      tblCategories,
    ).map((category) => Category(uuid: category.uuid, categoryName: category.categoryName)).watch();
  }

  Stream<List<Todo>> watchTodos({required SortDirection sortDirection, required TodoSort sort}) {
    final query = select(tblTodos).join([
      leftOuterJoin(tblTodoCategories, tblTodos.uuid.equalsExp(tblTodoCategories.todoUuid)),
      leftOuterJoin(tblCategories, tblTodoCategories.categoryUuid.equalsExp(tblCategories.uuid)),
    ]);

    return query.watch().map((rows) {
      final Map<String, Todo> todosMap = {};

      for (final row in rows) {
        final todoRow = row.readTable(tblTodos);
        final categoryRow = row.readTableOrNull(tblCategories);

        if (!todosMap.containsKey(todoRow.uuid)) {
          todosMap[todoRow.uuid] = Todo(
            uuid: todoRow.uuid,
            title: todoRow.title,
            content: todoRow.content,
            categories: [],
            createdAt: todoRow.createdAt,
            editedAt: todoRow.editedAt,
          );
        }

        if (categoryRow != null) {
          final category = Category(uuid: categoryRow.uuid, categoryName: categoryRow.categoryName);
          todosMap[todoRow.uuid]!.categories.add(category);
        }
      }

      List<Todo> todosList = todosMap.values.toList();
      TodoFilterSortUtils.sortTodos(todosList, sort, sortDirection);
      return todosList;
    });
  }

  Future<void> addCategory(Category category) async {
    if (category.uuid != null) return;
    final uuid = const Uuid().v4();

    await into(tblCategories).insert(
      TblCategoriesCompanion(
        uuid: Value(uuid),
        categoryName: Value(category.categoryName),
        createdAt: Value(DateTime.now()),
      ),
    );

    category.uuid = uuid;
  }

  Future<void> deleteCategoryByUuid(String categoryUuid) async {
    await transaction(() async {
      final todoCategoriesDeleteQuery = await delete(tblTodoCategories)
        ..where((tbl) => tbl.categoryUuid.isValue(categoryUuid));
      final categoryDeleteQuery = await delete(tblCategories)
        ..where((tbl) => tbl.uuid.isValue(categoryUuid));
      await todoCategoriesDeleteQuery.go();
      await categoryDeleteQuery.go();
    });
  }

  Future<void> deleteTodoByUuid(String todoUuid) async {
    await transaction(() async {
      final deleteTodoCategoriesQuery = delete(tblTodoCategories)
        ..where((tbl) => tbl.todoUuid.isValue(todoUuid));
      await deleteTodoCategoriesQuery.go();

      final deleteTodoQuery = delete(tblTodos)..where((tbl) => tbl.uuid.isValue(todoUuid));
      await deleteTodoQuery.go();
    });
  }
}
