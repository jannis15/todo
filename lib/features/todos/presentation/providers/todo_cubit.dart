import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/features/todos/data/sources/drift/database.dart';
import 'package:todo/features/todos/domain/models/todo_models.dart';
import 'package:todo/features/todos/domain/utils/todo_filter_sort_utils.dart';
import 'package:todo/features/todos/presentation/states/todo_state.dart';
import 'package:todo/core/utils/dart/sort_utils.dart';

class TodoCubit extends Cubit<TodoState> {
  late final StreamSubscription<List<Todo>> _todosSub;

  TodoCubit() : super(TodoLoadingState()) {
    _initialize();
  }

  @override
  Future<void> close() async {
    super.close();
    _todosSub.cancel();
  }

  List<Todo> _refreshTodoList(List<Todo> newTodoList) {
    if (state is! TodoLoadedState) return newTodoList;
    final currentState = state as TodoLoadedState;

    List<Todo> todoList = TodoFilterSortUtils.filterTodosByCategories(
      newTodoList,
      currentState.filteredCategories,
    );
    todoList = TodoFilterSortUtils.searchTodos(todoList, currentState.query);
    TodoFilterSortUtils.sortTodos(todoList, currentState.sort, currentState.sortDirection);

    return todoList;
  }

  void _initialize() {
    final sortDirection = SortDirection.descending;
    final todoSort = TodoSort.recency;
    final stream = AppDatabase().watchTodos(sortDirection: sortDirection, sort: todoSort);

    _todosSub = stream.listen((todos) {
      if (state is TodoLoadedState) {
        final filterSortTodos = _refreshTodoList(todos);
        emit((state as TodoLoadedState).copyWith(todos: todos, filteredTodos: filterSortTodos));
      } else {
        emit(
          TodoState.loaded(
            todos: todos,
            filteredTodos: todos,
            sortDirection: sortDirection,
            sort: todoSort,
            filteredCategories: const {},
            query: '',
          ),
        );
      }
    });
  }

  void sortTodos({SortDirection? sortDirection, TodoSort? sort}) {
    if (state is! TodoLoadedState) return;
    if (sortDirection == null && sort == null) {
      emit(TodoState.error('SortDirection or TodoSort must be provided'));
      return;
    }
    final currentState = state as TodoLoadedState;

    SortDirection finalSortDirection =
        sortDirection ??
        (sort == currentState.sort
            ? currentState.sortDirection.opposite
            : SortDirection.descending);
    TodoSort finalTodoSort = sort ?? currentState.sort;

    final todos = List.of(currentState.filteredTodos);
    TodoFilterSortUtils.sortTodos(todos, finalTodoSort, finalSortDirection);

    emit(
      currentState.copyWith(
        filteredTodos: todos,
        sort: finalTodoSort,
        sortDirection: finalSortDirection,
      ),
    );
  }

  void toggleCategory(Category category) {
    if (state is! TodoLoadedState) return;

    final currentState = (state as TodoLoadedState);
    final categories = Set.of(currentState.filteredCategories);
    if (categories.contains(category)) {
      categories.remove(category);
    } else {
      categories.add(category);
    }
    List<Todo> todos = List.of(currentState.todos);
    todos = TodoFilterSortUtils.filterTodosByCategories(todos, categories);
    todos = TodoFilterSortUtils.searchTodos(todos, currentState.query);
    TodoFilterSortUtils.sortTodos(todos, currentState.sort, currentState.sortDirection);

    emit(currentState.copyWith(filteredTodos: todos, filteredCategories: categories));
  }

  void clearCategories() {
    if (state is! TodoLoadedState) return;
    final currentState = (state as TodoLoadedState);

    List<Todo> todos = List.of(currentState.todos);
    todos = TodoFilterSortUtils.searchTodos(todos, currentState.query);
    TodoFilterSortUtils.sortTodos(todos, currentState.sort, currentState.sortDirection);

    emit(currentState.copyWith(filteredTodos: todos, filteredCategories: {}));
  }

  void searchTodos(String query) {
    if (state is! TodoLoadedState) return;
    final currentState = (state as TodoLoadedState);

    List<Todo> todos = List.of(currentState.todos);
    todos = TodoFilterSortUtils.searchTodos(currentState.todos, query);
    todos = TodoFilterSortUtils.filterTodosByCategories(todos, currentState.filteredCategories);
    TodoFilterSortUtils.sortTodos(todos, currentState.sort, currentState.sortDirection);

    emit(currentState.copyWith(filteredTodos: todos, query: query));
  }
}
