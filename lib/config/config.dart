import 'package:flutter/material.dart';

abstract class AppSizes {
  static const double kDesktopWidth = 920.0;

  static const double kComponentHeight = 32.0;

  static const double kMediumBigGap = 24.0;
  static const double kGap = 16.0;
  static const double kSmallGap = 8.0;

  static const double kIconSize = 24.0;
  static const double kMainIconSize = 20.0;
  static const double kSubIconSize = 18.0;

  static const double kIconButtonSize = 32.0;

  static const double kBorderRadius = 10.0;

  static const double kMinInputGap = 4.0;
  static final EdgeInsetsGeometry inputPadding = const EdgeInsets.fromLTRB(
    kGap,
    kMinInputGap,
    kMinInputGap,
    kMinInputGap,
  );
}
