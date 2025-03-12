import 'package:todo/features/todos/domain/models/todo_models.dart';
import 'package:todo/core/utils/dart/sort_utils.dart';

abstract class TodoFilterSortUtils {
  static List<Todo> filterTodosByCategories(
    List<Todo> todos,
    Iterable<Category> selectedCategories,
  ) {
    if (selectedCategories.isEmpty) {
      return List.of(todos);
    }
    return todos
        .where((todo) => selectedCategories.every((category) => todo.categories.contains(category)))
        .toList();
  }

  static void sortTodos(List<Todo> todos, TodoSort sort, SortDirection sortDirection) {
    todos.sort((a, b) {
      int comparison = 0;

      if (sort == TodoSort.recency) {
        final aEditedAt = a.editedAt ?? DateTime(0);
        final bEditedAt = b.editedAt ?? DateTime(0);
        comparison = aEditedAt.compareTo(bEditedAt);
      } else if (sort == TodoSort.creationDate) {
        final aCreatedAt = a.createdAt ?? DateTime(0);
        final bCreatedAt = b.createdAt ?? DateTime(0);
        comparison = aCreatedAt.compareTo(bCreatedAt);
      } else if (sort == TodoSort.categoryName) {
        comparison =
            a.categories.isEmpty
                ? 1
                : b.categories.isEmpty
                ? -1
                : a.categories
                    .map((category) => category.categoryName.toLowerCase())
                    .join()
                    .compareTo(
                      b.categories.map((category) => category.categoryName.toLowerCase()).join(),
                    );
      } else {
        throw UnimplementedError();
      }

      return sortDirection == SortDirection.ascending ? comparison : -comparison;
    });
  }

  static List<Todo> searchTodos(List<Todo> todos, String query) {
    if (query.isEmpty) return todos;
    final lowerQuery = query.toLowerCase();
    return todos.where((todo) {
      final titleMatch = todo.title.toLowerCase().contains(lowerQuery);
      final contentMatch = todo.content.toLowerCase().contains(lowerQuery);
      return titleMatch || contentMatch;
    }).toList();
  }
}
