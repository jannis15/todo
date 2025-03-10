import 'package:flutter/material.dart';
import 'package:workout/config/config.dart';
import 'package:workout/utils/flutter/utils.dart';

class TChip extends StatefulWidget {
  final IconData? iconData;
  final String? text;
  final bool isTrailingIcon;
  final void Function()? onPressed;
  final void Function()? onLongPress;
  final bool? isSelected;

  const TChip({
    super.key,
    this.iconData,
    this.text,
    this.onPressed,
    this.onLongPress,
    this.isTrailingIcon = false,
    this.isSelected,
  });

  @override
  State<TChip> createState() => _TChipState();
}

class _TChipState extends State<TChip> {
  @override
  Widget build(BuildContext context) {
    List<Widget> getChildren() => [
      if (widget.iconData != null)
        Icon(
          widget.iconData,
          size: AppSizes.kSubIconSize,
          color:
              widget.isSelected == true
                  ? colorScheme.onSecondary
                  : widget.isTrailingIcon
                  ? null
                  : colorScheme.secondary,
        ),
      if (widget.text != null)
        Text(
          widget.text!,
          style: textTheme.labelLarge?.copyWith(
            color:
                widget.isSelected == true ? colorScheme.onSecondary : colorScheme.onSurfaceVariant,
          ),
        ),
    ];

    return GestureDetector(
      onLongPress: widget.onLongPress,
      child: ActionChip(
        color: widget.isSelected == true ? WidgetStatePropertyAll(colorScheme.secondary) : null,
        padding: EdgeInsets.fromLTRB(
          !widget.isTrailingIcon && widget.iconData != null
              ? AppSizes.kSmallGap
              : widget.text == null
              ? AppSizes.kSmallGap
              : AppSizes.kGap,
          0,
          widget.isTrailingIcon && widget.iconData != null
              ? AppSizes.kSmallGap
              : widget.text == null
              ? AppSizes.kSmallGap
              : AppSizes.kGap,
          0,
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        labelPadding: EdgeInsets.zero,
        onPressed: widget.onPressed,
        side: BorderSide(
          color: widget.isSelected == true ? Colors.transparent : colorScheme.outline,
        ),
        label: SizedBox(
          height: AppSizes.kComponentHeight,
          child: Row(
            spacing: AppSizes.kGap,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: widget.isTrailingIcon ? getChildren().reversed.toList() : getChildren(),
          ),
        ),
      ),
    );
  }
}
