import 'package:freezed_annotation/freezed_annotation.dart';

part 'todo_models.freezed.dart';

part 'todo_models.g.dart';

enum TodoSort {
  recency,
  creationDate,
  categoryName;

  String get label => switch (this) {
    TodoSort.recency => 'Recency',
    TodoSort.creationDate => 'Creation',
    TodoSort.categoryName => 'Category',
  };
}

@freezed
@JsonSerializable()
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

  factory Todo.fromJson(Map<String, Object?> json) => _$TodoFromJson(json);

  Map<String, Object?> toJson() => _$TodoToJson(this);
}

@freezed
@JsonSerializable()
class Category with _$Category {
  String? uuid;
  final String categoryName;
  final DateTime? createdAt;

  Category({this.uuid, required this.categoryName, this.createdAt});

  factory Category.fromJson(Map<String, Object?> json) => _$CategoryFromJson(json);

  Map<String, Object?> toJson() => _$CategoryToJson(this);
}
