import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:workout/features/todos/domain/models/todo_models.dart';
import 'package:workout/core/utils/dart/sort_utils.dart';

part 'todo_state.freezed.dart';

@freezed
class TodoState with _$TodoState {
  factory TodoState.loading() = TodoLoadingState;

  factory TodoState.loaded({
    required List<Todo> todos,
    required List<Todo> filteredTodos,
    required SortDirection sortDirection,
    required TodoSort sort,
    @Default('') String query,
    @Default(const {}) Set<Category> filteredCategories,
  }) = TodoLoadedState;

  factory TodoState.error(String message) = TodoErrorState;
}
