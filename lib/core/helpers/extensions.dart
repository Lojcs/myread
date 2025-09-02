import 'package:flutter/material.dart';

extension ContextExtension on BuildContext {
  double get width => MediaQuery.of(this).size.width;
  double get height => MediaQuery.of(this).size.height;
  ColorScheme get colorScheme => ColorScheme.of(this);
  TextTheme get textTheme => TextTheme.of(this);
  NavigatorState get navigator => Navigator.of(this);
}

extension TweenExtension<T> on Tween<T> {
  T tryEvaluate(Animation<double>? animation) =>
      animation != null ? evaluate(animation) : begin!;
}

extension StringExtension on String {
  int toInt() => int.parse(this);
  double toDouble() => double.parse(this);
}
