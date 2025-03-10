import 'package:flutter/material.dart';
import 'package:workout/features/workout/data/sources/drift/database.dart';
import 'package:workout/features/workout/domain/models/todo_models.dart';
import 'package:workout/features/workout/presentation/components/chip.dart';
import 'package:workout/utils/flutter/alert_dialog.dart';
import 'package:workout/utils/flutter/utils.dart';

class TodoDetailScreen extends StatefulWidget {
  final Todo? todo;

  const TodoDetailScreen({super.key, this.todo});

  @override
  State<TodoDetailScreen> createState() => _TodoDetailScreenState();
}

class _TodoDetailScreenState extends State<TodoDetailScreen> {
  bool isExpanded = false;
  bool _isEditingTitle = false;
  bool _isEditingNewCategory = false;
  final List<Category> _selectedCategories = [];
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _categoryNameFocusNode = FocusNode();
  final FocusNode _contentFocusNode = FocusNode();
  final TextEditingController _titleTextController = TextEditingController();
  final TextEditingController _categoryNameTextController = TextEditingController();
  final TextEditingController _contentTextController = TextEditingController();
  final Stream<List<Category>> _categoriesStream = AppDatabase().watchCategories();

  @override
  void initState() {
    if (widget.todo != null) {
      _selectedCategories.addAll(widget.todo!.categories);
      _titleTextController.text = widget.todo!.title;
      _contentTextController.text = widget.todo!.content;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AppBar buildTodoAppBar() => AppBar(
      toolbarHeight: 40,
      actionsPadding: EdgeInsets.zero,
      titleSpacing: 0,
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child:
                _isEditingTitle
                    ? TextField(
                      focusNode: _titleFocusNode,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        hintText: 'Title',
                      ),
                      style: textTheme.titleLarge,
                      controller: _titleTextController,
                    )
                    : GestureDetector(
                      onTap: () {
                        _isEditingTitle = true;
                        setState(() {});
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _titleFocusNode.requestFocus();
                        });
                      },
                      child: Text(
                        _titleTextController.text.isEmpty ? 'Title' : _titleTextController.text,
                      ),
                    ),
          ),
          if (!_isEditingTitle)
            IconButton(
              onPressed: () {
                _isEditingTitle = true;
                setState(() {});
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _titleFocusNode.requestFocus();
                });
              },
              icon: const Icon(Icons.edit),
            )
          else
            IconButton(
              onPressed: () async {
                _titleFocusNode.unfocus();
                _isEditingTitle = false;
                setState(() {});
              },
              icon: const Icon(Icons.check),
            ),
        ],
      ),
    );

    Widget buildNewCategoryRow() => AnimatedContainer(
      height: _isEditingNewCategory ? 40 : 0,
      clipBehavior: Clip.hardEdge,
      alignment: Alignment.topLeft,
      decoration: const BoxDecoration(),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeIn,
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
        child: Row(
          spacing: 6,
          children: [
            Expanded(
              child: SizedBox(
                height: 32,
                child: TextField(
                  controller: _categoryNameTextController,
                  style: const TextStyle(height: 24 / 16, fontSize: 16),
                  maxLines: 1,
                  focusNode: _categoryNameFocusNode,
                  decoration: const InputDecoration(
                    isDense: true,
                    filled: true,
                    contentPadding: EdgeInsets.all(4),
                    hintText: 'Category name',
                    border: OutlineInputBorder(
                      gapPadding: 0,
                      borderSide: BorderSide(width: 0, color: Colors.transparent),
                    ),
                    focusedBorder: OutlineInputBorder(
                      gapPadding: 0,
                      borderSide: BorderSide(width: 0, color: Colors.transparent),
                    ),
                    enabledBorder: OutlineInputBorder(
                      gapPadding: 0,
                      borderSide: BorderSide(width: 0, color: Colors.transparent),
                    ),
                  ),
                ),
              ),
            ),
            FilledButton.tonal(
              onPressed: () async {
                final category = Category(categoryName: _categoryNameTextController.text.trim());
                await AppDatabase().addCategory(category);
                _selectedCategories.add(category);

                _isEditingNewCategory = false;
                _categoryNameTextController.clear();
                if (mounted) setState(() {});
              },
              style: const ButtonStyle(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: WidgetStatePropertyAll(EdgeInsets.all(12)),
              ),
              child: const Icon(Icons.check),
            ),
            FilledButton.tonal(
              onPressed: () {
                _isEditingNewCategory = false;
                _categoryNameTextController.clear();
                setState(() {});
                _categoryNameFocusNode.unfocus();
              },
              style: const ButtonStyle(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: WidgetStatePropertyAll(EdgeInsets.all(12)),
              ),
              child: const Icon(Icons.close),
            ),
          ],
        ),
      ),
    );

    Widget buildContentTextField() => TextField(
      expands: true,
      textAlignVertical: TextAlignVertical.top,
      maxLines: null,
      focusNode: _contentFocusNode,
      controller: _contentTextController,
      decoration: const InputDecoration(
        hintText: 'Write something here...',
        border: OutlineInputBorder(
          gapPadding: 0,
          borderSide: BorderSide(width: 0, color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          gapPadding: 0,
          borderSide: BorderSide(width: 0, color: Colors.transparent),
        ),
        enabledBorder: OutlineInputBorder(
          gapPadding: 0,
          borderSide: BorderSide(width: 0, color: Colors.transparent),
        ),
        isDense: true,
        contentPadding: EdgeInsets.zero,
      ),
    );

    Widget buildNewCategoryButton() => FilledButton.tonal(
      onPressed: () {
        _isEditingNewCategory = true;
        _contentFocusNode.unfocus();
        setState(() {});

        WidgetsBinding.instance.addPostFrameCallback((_) => _categoryNameFocusNode.requestFocus());
      },
      style: const ButtonStyle(
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: WidgetStatePropertyAll(EdgeInsets.all(12)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(Icons.add), SizedBox(width: 4), Text('New')],
      ),
    );

    Widget buildCategoryChip(Category category) => TChip(
      onLongPress: () async {
        final alertResult = await showAlertDialog(
          context,
          title: 'Delete ' + category.categoryName + '?',
          content:
              'You are about to delete this category. All associated todos will no longer be linked to it.',
          optionData: [AlertOptionData.yes(), AlertOptionData.cancel()],
        );
        if (alertResult == AlertOption.yes) {
          await AppDatabase().deleteCategoryByUuid(category.uuid!);
        }
      },
      text: category.categoryName,
      onPressed: () {
        if (_selectedCategories.contains(category)) {
          _selectedCategories.remove(category);
        } else {
          _selectedCategories.add(category);
        }
        setState(() {});
      },
      isSelected: _selectedCategories.contains(category),
    );

    Widget buildCategoriesRow() => AnimatedContainer(
      height:
          _isEditingNewCategory
              ? 0
              : isExpanded
              ? null
              : 40,
      clipBehavior: Clip.hardEdge,
      alignment: Alignment.topLeft,
      decoration: const BoxDecoration(),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeIn,
      child: StreamBuilder(
        stream: _categoriesStream,
        builder:
            (context, snapshot) => Padding(
              padding: const EdgeInsets.only(left: 8, top: 8, right: 8),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (isExpanded) {
                    return Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6.0,
                      runSpacing: 6.0,
                      children: [
                        buildNewCategoryButton(),
                        if (snapshot.data != null) ...snapshot.data!.map(buildCategoryChip),
                        FilledButton.tonal(
                          onPressed: () {
                            setState(() {
                              isExpanded = false;
                            });
                          },
                          style: const ButtonStyle(
                            visualDensity: VisualDensity.compact,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            padding: WidgetStatePropertyAll(EdgeInsets.all(12)),
                          ),
                          child: const Text('Collapse'),
                        ),
                      ],
                    );
                  } else {
                    return Row(
                      spacing: 6,
                      children: [
                        buildNewCategoryButton(),
                        Expanded(
                          child:
                              snapshot.data != null
                                  ? SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      spacing: 6,
                                      children: snapshot.data!.map(buildCategoryChip).toList(),
                                    ),
                                  )
                                  : const SizedBox(),
                        ),

                        FilledButton.tonal(
                          onPressed: () {
                            setState(() {
                              isExpanded = true;
                            });
                          },
                          style: const ButtonStyle(
                            visualDensity: VisualDensity.compact,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            padding: WidgetStatePropertyAll(EdgeInsets.all(12)),
                          ),
                          child: const Text('Expand'),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
      ),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final todo = Todo(
            uuid: widget.todo?.uuid,
            title: _titleTextController.text.trim(),
            content: _contentTextController.text.trim(),
            categories: _selectedCategories,
          );
          if (_titleTextController.text.isNotEmpty || _contentTextController.text.isNotEmpty) {
            await AppDatabase().saveTodo(todo);
          }
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: buildTodoAppBar(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildNewCategoryRow(),
            buildCategoriesRow(),
            const SizedBox(height: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                child: buildContentTextField(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
