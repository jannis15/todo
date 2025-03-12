import 'package:flutter/material.dart';
import 'package:todo/config/config.dart';
import 'package:todo/core/utils/dart/sort_utils.dart';
import 'package:todo/core/utils/flutter/utils.dart';

class DropdownSortButton<E> extends StatefulWidget {
  final Map<E, String> options;
  final E value;
  final SortDirection sortDirection;
  final bool showBorder;
  final void Function(E value, SortDirection sortDirection) onOptionChanged;

  DropdownSortButton({
    super.key,
    required this.options,
    required this.value,
    required this.onOptionChanged,
    this.showBorder = false,
    this.sortDirection = SortDirection.descending,
  });

  @override
  DropdownSortButtonState<E> createState() => DropdownSortButtonState<E>();
}

class DropdownSortButtonState<E> extends State<DropdownSortButton<E>> {
  bool _isPopupOpen = false;
  late E _value = widget.value;
  late SortDirection _sortDirection = widget.sortDirection;

  BorderRadius borderRadius(int index, {double borderRadius = AppSizes.kComponentHeight / 2}) =>
      BorderRadius.only(
        topLeft: index == 0 ? Radius.circular(borderRadius) : Radius.zero,
        bottomLeft: index == 0 ? Radius.circular(borderRadius) : Radius.zero,
        topRight: index == 1 ? Radius.circular(borderRadius) : Radius.zero,
        bottomRight: index == 1 ? Radius.circular(borderRadius) : Radius.zero,
      );

  @override
  Widget build(BuildContext context) {
    final _foregroundColor = colorScheme.onSecondaryContainer;
    final _backgroundColor = colorScheme.secondaryContainer;

    return Ink(
      height: AppSizes.kComponentHeight,
      decoration: ShapeDecoration(
        shape: StadiumBorder(
          side: widget.showBorder ? BorderSide(color: _foregroundColor) : BorderSide.none,
        ),
        color: _backgroundColor,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: InkWell(
              borderRadius: borderRadius(0),
              onTap: () {
                setState(() {
                  _sortDirection = _sortDirection.opposite;
                });
                widget.onOptionChanged(_value, _sortDirection);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.kSmallGap),
                height: AppSizes.kComponentHeight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: AppSizes.kSmallGap,
                  children: [
                    Icon(
                      _sortDirection == SortDirection.ascending
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      size: AppSizes.kSubIconSize,
                      color: _foregroundColor,
                    ),
                    Flexible(
                      child: Text(
                        widget.options[_value]!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(
                          color: _foregroundColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: widget.showBorder ? EdgeInsets.zero : const EdgeInsets.symmetric(vertical: 4),
            child: Container(
              width: 1.0,
              color: _foregroundColor.withValues(alpha: .1),
              height: AppSizes.kComponentHeight,
            ),
          ),
          Material(
            color: _backgroundColor,
            borderRadius: borderRadius(1),
            clipBehavior: Clip.hardEdge,
            child: PopupMenuButton<E>(
              onOpened: () {
                setState(() {
                  _isPopupOpen = true;
                });
              },
              onCanceled: () {
                setState(() {
                  _isPopupOpen = false;
                });
              },
              onSelected: (E selectedValue) {
                setState(() {
                  _isPopupOpen = false;
                  _value = selectedValue;
                });
                widget.onOptionChanged(_value, _sortDirection);
              },
              itemBuilder:
                  (context) =>
                      widget.options.entries
                          .map(
                            (option) =>
                                PopupMenuItem<E>(value: option.key, child: Text(option.value)),
                          )
                          .toList(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.kSmallGap),
                height: AppSizes.kComponentHeight,
                child: Icon(
                  _isPopupOpen ? Icons.expand_less : Icons.expand_more,
                  color: _foregroundColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
