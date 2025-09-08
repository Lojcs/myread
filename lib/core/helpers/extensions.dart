import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as pathlib;

import 'comic_parser.dart';

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

extension FileSystemEntityExtension<T extends FileSystemEntity> on T {
  String get name => path.split(Platform.pathSeparator).last;
  String get extension => name.split(".").last;
  bool get isImage =>
      this is File && ComicParser.supportedImageExtensions.contains(extension);

  bool get hidden => name.startsWith(".");
  T move(String dir) => renameSync(pathlib.join(dir, name)) as T;
}
