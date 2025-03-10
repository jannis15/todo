import 'package:flutter/material.dart';

extension StateExtension on State {
  TextTheme get textTheme => Theme.of(context).textTheme;

  ColorScheme get colorScheme => Theme.of(context).colorScheme;
}
