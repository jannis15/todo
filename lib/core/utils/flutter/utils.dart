import 'package:flutter/material.dart';
import 'package:todo/config/config.dart';

extension StateExtension on State {
  bool get useDesktopLayout => MediaQuery.of(context).size.width >= AppSizes.kDesktopWidth;

  TextTheme get textTheme => Theme.of(context).textTheme;

  ColorScheme get colorScheme => Theme.of(context).colorScheme;
}
