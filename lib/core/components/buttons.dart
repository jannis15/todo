import 'package:flutter/material.dart';
import 'package:workout/config/config.dart';

enum TButtonType { filled, outlined, transparent }

enum HighlightType { primary, secondary }

class TButton extends StatelessWidget {
  final bool loading;
  final IconData? iconData;
  final String? text;
  final void Function()? onPressed;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final TextDecoration? textDecoration;
  final HighlightType highlightType;

  final TButtonType type;

  TButton({
    super.key,
    this.iconData,
    this.text,
    this.onPressed,
    this.loading = false,
    required this.type,
    this.foregroundColor,
    this.backgroundColor,
    this.textDecoration,
    this.highlightType = HighlightType.primary,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final baseBackgroundColor =
        backgroundColor ??
        (highlightType == HighlightType.primary
            ? colorScheme.primaryContainer
            : colorScheme.secondaryContainer);

    Color getBackgroundColor() =>
        type == TButtonType.filled
            ? onPressed == null
                ? Color.alphaBlend(colorScheme.surface.withValues(alpha: .5), baseBackgroundColor)
                : baseBackgroundColor
            : Colors.transparent;
    Color getForegroundColor() {
      final calcForegroundColor =
          foregroundColor != null
              ? foregroundColor!
              : type == TButtonType.filled
              ? (highlightType == HighlightType.primary
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSecondaryContainer)
              : colorScheme.onSurface;
      return onPressed == null
          ? Color.alphaBlend(colorScheme.surface.withValues(alpha: .5), calcForegroundColor)
          : calcForegroundColor;
    }

    Color getBorderColor() =>
        onPressed == null
            ? Color.alphaBlend(colorScheme.surface.withValues(alpha: .5), colorScheme.outline)
            : colorScheme.outline;

    return IgnorePointer(
      ignoring: loading,
      child: SizedBox(
        height: AppSizes.kComponentHeight,
        child: FilledButton(
          onPressed: loading ? null : onPressed,
          style: ButtonStyle(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            side:
                type == TButtonType.outlined
                    ? WidgetStatePropertyAll(BorderSide(width: 1, color: getBorderColor()))
                    : null,
            overlayColor:
                type != TButtonType.filled
                    ? WidgetStatePropertyAll(getForegroundColor().withValues(alpha: .5))
                    : null,
            foregroundColor: WidgetStatePropertyAll(getForegroundColor()),
            backgroundColor: WidgetStatePropertyAll(getBackgroundColor()),
            padding: WidgetStatePropertyAll(
              EdgeInsets.fromLTRB(
                AppSizes.kGap,
                0,
                iconData != null && text != null ? AppSizes.kMediumBigGap : AppSizes.kGap,
                0,
              ),
            ),
          ),
          child: Row(
            spacing: AppSizes.kSmallGap,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (loading)
                SizedBox(
                  height: AppSizes.kSubIconSize / 2,
                  width: AppSizes.kSubIconSize / 2,
                  child: CircularProgressIndicator(strokeWidth: 1, color: getForegroundColor()),
                )
              else if (iconData != null)
                SizedBox(
                  width: AppSizes.kSubIconSize,
                  child: Icon(iconData, size: AppSizes.kSubIconSize, color: getForegroundColor()),
                ),
              if (text != null)
                Text(
                  text!,
                  style: textTheme.labelLarge?.copyWith(
                    color: getForegroundColor(),
                    decoration: textDecoration,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class TTransparentButton extends TButton {
  TTransparentButton({
    super.key,
    super.iconData,
    super.foregroundColor,
    super.text,
    super.onPressed,
    super.textDecoration,
    super.loading,
    super.highlightType,
  }) : super(type: TButtonType.transparent);
}

class TOutlinedButton extends TButton {
  TOutlinedButton({
    super.key,
    super.iconData,
    super.text,
    super.onPressed,
    super.textDecoration,
    super.loading,
    super.highlightType,
  }) : super(type: TButtonType.outlined);
}

class TFilledButton extends TButton {
  TFilledButton({
    super.key,
    super.iconData,
    super.text,
    super.onPressed,
    super.textDecoration,
    super.loading,
    super.highlightType,
  }) : super(type: TButtonType.filled);
}
