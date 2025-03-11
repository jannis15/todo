import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago_flutter/timeago_flutter.dart';
import 'package:workout/features/todos/data/sources/drift/database.dart';
import 'package:workout/features/todos/domain/models/todo_models.dart';
import 'package:workout/core/components/buttons.dart';
import 'package:workout/core/components/dropdown_sort_button.dart';
import 'package:workout/features/todos/presentation/providers/todo_cubit.dart';
import 'package:workout/features/todos/presentation/screens/todo_categories_bottom_sheet.dart';
import 'package:workout/features/todos/presentation/screens/todo_detail_screen.dart';
import 'package:workout/features/settings/presentation/screens/login_screen.dart';
import 'package:workout/features/settings/presentation/screens/account_screen.dart';
import 'package:workout/features/todos/presentation/states/todo_state.dart';
import 'package:workout/core/utils/flutter/alert_dialog.dart';
import 'package:workout/core/utils/flutter/utils.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final ScrollController _listViewScrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchTextController = TextEditingController();

  @override
  void initState() {
    _searchTextController.addListener(_refreshView);
    super.initState();
  }

  @override
  void dispose() {
    _searchTextController.removeListener(_refreshView);
    super.dispose();
  }

  void _refreshView() => setState(() {});

  @override
  Widget build(BuildContext context) {
    Widget buildSearchBar(BuildContext context, TodoLoadedState todoState) => Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 40,
        child: SearchBar(
          focusNode: _searchFocusNode,
          hintText: 'Search',
          controller: _searchTextController,
          padding: const WidgetStatePropertyAll(EdgeInsets.zero),
          leading: IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          onSubmitted: (query) {
            context.read<TodoCubit>().searchTodos(query);
          },
          trailing: [
            if (_searchTextController.value.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  context.read<TodoCubit>().searchTodos('');
                  _searchTextController.clear();
                },
              ),
          ],
          onTapOutside: (event) {
            _searchFocusNode.unfocus();
          },
          elevation: const WidgetStatePropertyAll(0),
        ),
      ),
    );

    Widget buildLoadedBody(BuildContext context, TodoLoadedState todoState) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        buildSearchBar(context, todoState),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 6,
              children: [
                SizedBox(
                  height: 32,
                  child: FilledButton.tonalIcon(
                    onPressed: () {
                      final cubit = context.read<TodoCubit>();
                      showModalBottomSheet(
                        showDragHandle: true,
                        context: context,
                        backgroundColor: colorScheme.surface,
                        builder:
                            (context) => BlocProvider.value(
                              value: cubit,
                              child: const TodoCategoriesBottomSheet(),
                            ),
                      );
                    },
                    icon: const Icon(Icons.filter_list),
                    label: Text(todoState.filteredCategories.isNotEmpty ? 'Custom' : 'All'),
                  ),
                ),
                DropdownSortButton<TodoSort>(
                  options: {for (var sort in TodoSort.values) sort: sort.label},
                  value: todoState.sort,
                  sortDirection: todoState.sortDirection,
                  onOptionChanged: (value, sortDirection) {
                    context.read<TodoCubit>().sortTodos(sortDirection: sortDirection, sort: value);
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        todoState.filteredTodos.isEmpty
            ? const Padding(
              padding: EdgeInsets.only(right: 8.0, bottom: 8.0, left: 8.0),
              child: Text('No todos available.'),
            )
            : Expanded(
              child: ListView.builder(
                controller: _listViewScrollController,
                padding: const EdgeInsets.only(right: 8.0, bottom: 8.0, left: 8.0),
                itemCount: todoState.filteredTodos.length,
                itemBuilder: (context, index) {
                  final todo = todoState.filteredTodos[index];
                  return Padding(
                    padding: EdgeInsets.only(bottom: index < 200 ? 4.0 : 0.0),
                    child: Material(
                      color: colorScheme.surfaceContainer,
                      clipBehavior: Clip.hardEdge,
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      type: MaterialType.card,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(
                            context,
                          ).push(MaterialPageRoute(builder: (_) => TodoDetailScreen(todo: todo)));
                        },
                        child: Dismissible(
                          direction: DismissDirection.endToStart,
                          key: UniqueKey(),
                          background: Container(
                            color: Colors.redAccent,
                            padding: const EdgeInsets.all(8),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [Icon(Icons.delete, color: Colors.white)],
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            final alertResult = await showAlertDialog(
                              context,
                              title:
                                  "Delete ${todo.title.trim().isNotEmpty ? '${todo.title}' : 'Todo'}?",
                              content:
                                  'You are about to delete this todo. This action cannot be undone.',
                              optionData: [AlertOptionData.yes(), AlertOptionData.cancel()],
                            );
                            if (alertResult == AlertOption.yes) {
                              await AppDatabase().deleteTodoByUuid(todo.uuid!);
                              return true;
                            } else {
                              return false;
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (todo.title.trim().isNotEmpty)
                                  Text(todo.title, style: textTheme.titleMedium),
                                if (todo.content.trim().isNotEmpty)
                                  Text(
                                    todo.content,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.outline,
                                    ),
                                  ),
                                Row(
                                  spacing: 6,
                                  children: [
                                    Timeago(
                                      builder:
                                          (context, value) => Text(
                                            value,
                                            style: textTheme.labelSmall?.copyWith(
                                              color: colorScheme.outline,
                                            ),
                                          ),
                                      date: todo.editedAt!,
                                    ),
                                    if (todo.categories.isNotEmpty)
                                      Text(
                                        '•',
                                        style: textTheme.labelSmall?.copyWith(
                                          color: colorScheme.outline,
                                        ),
                                      ),
                                    Flexible(
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: [
                                            Text(
                                              todo.categories.map((e) => e.categoryName).join(', '),
                                              style: textTheme.labelSmall?.copyWith(
                                                color: colorScheme.outline,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
      ],
    );

    Widget buildFloatingActionButton() => FloatingActionButton.extended(
      icon: const Icon(Icons.add),
      label: const Text('Add'),
      onPressed: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TodoDetailScreen()));
      },
    );

    bool isSignedIn() => !(Supabase.instance.client.auth.currentSession?.isExpired ?? true);

    return BlocProvider(
      create: (_) => TodoCubit(),
      child: BlocBuilder<TodoCubit, TodoState>(
        builder:
            (context, todoState) => Scaffold(
              appBar: AppBar(
                actionsPadding: const EdgeInsets.only(right: 8),
                toolbarHeight: 40,
                title: const Text('Todos'),
                actions: [
                  if (isSignedIn())
                    TOutlinedButton(
                      iconData: Icons.person,
                      text: Supabase.instance.client.auth.currentUser?.email,
                      onPressed: () => context.go('/account'),
                    )
                  else
                    TOutlinedButton(
                      iconData: null,
                      text: 'Login',
                      onPressed: () => context.go('/login'),
                    ),
                ],
              ),
              floatingActionButton: buildFloatingActionButton(),
              body:
                  todoState is TodoLoadedState
                      ? buildLoadedBody(context, todoState)
                      : const Center(child: CircularProgressIndicator()),
            ),
      ),
    );
  }
}
