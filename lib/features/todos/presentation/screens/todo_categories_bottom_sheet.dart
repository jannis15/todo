import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:workout/features/todos/data/sources/drift/database.dart';
import 'package:workout/features/todos/domain/models/todo_models.dart';
import 'package:workout/core/components/chip.dart';
import 'package:workout/features/todos/presentation/providers/todo_cubit.dart';
import 'package:workout/features/todos/presentation/states/todo_state.dart';
import 'package:workout/core/utils/flutter/alert_dialog.dart';
import 'package:workout/core/utils/flutter/utils.dart';

class TodoCategoriesBottomSheet extends StatefulWidget {
  const TodoCategoriesBottomSheet({super.key});

  @override
  State<TodoCategoriesBottomSheet> createState() => _TodoCategoriesBottomSheetState();
}

class _TodoCategoriesBottomSheetState extends State<TodoCategoriesBottomSheet> {
  final Stream<List<Category>> _categoriesStream = AppDatabase().watchCategories();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
        child: StreamBuilder(
          stream: _categoriesStream,
          builder:
              (context, snapshot) => BlocBuilder<TodoCubit, TodoState>(
                builder:
                    (context, todoState) =>
                        todoState is TodoLoadedState && snapshot.data != null
                            ? Column(
                              spacing: 8,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text('Categories', style: textTheme.titleMedium),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    TChip(
                                      text: 'All',
                                      isSelected: todoState.filteredCategories.isEmpty,
                                      onPressed: () {
                                        context.read<TodoCubit>().clearCategories();
                                      },
                                    ),
                                    ...snapshot.data!.map(
                                      (category) => TChip(
                                        text: category.categoryName,
                                        isSelected: todoState.filteredCategories.contains(category),
                                        onPressed: () {
                                          context.read<TodoCubit>().toggleCategory(category);
                                        },
                                        onLongPress: () async {
                                          final alertResult = await showAlertDialog(
                                            context,
                                            title: 'Delete ' + category.categoryName + '?',
                                            content:
                                                'You are about to delete this category. All associated todos will no longer be linked to it.',
                                            optionData: [
                                              AlertOptionData.yes(),
                                              AlertOptionData.cancel(),
                                            ],
                                          );
                                          if (alertResult == AlertOption.yes) {
                                            await AppDatabase().deleteCategoryByUuid(
                                              category.uuid!,
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                            : const SizedBox(),
              ),
        ),
      ),
    );
  }
}
