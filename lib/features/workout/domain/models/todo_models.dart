import 'package:freezed_annotation/freezed_annotation.dart';

part 'todo_models.freezed.dart';

enum TodoSort {
  recency,
  categoryName;

  String get label => switch (this) {
    TodoSort.recency => 'Recency',
    TodoSort.categoryName => 'Category',
  };
}

@freezed
class Todo with _$Todo {
  String? uuid;
  final String title;
  final String content;
  final List<Category> categories;
  final DateTime? createdAt;
  final DateTime? editedAt;

  Todo({
    this.uuid,
    required this.title,
    required this.content,
    required this.categories,
    this.createdAt,
    this.editedAt,
  });
}

@freezed
class Category with _$Category {
  String? uuid;
  final String categoryName;
  final DateTime? createdAt;

  Category({this.uuid, required this.categoryName, this.createdAt});
}
