import 'dart:io';

import 'comic_issue.dart';

class ComicParser {
  final File comicFile;
  const ComicParser(this.comicFile);
  Future<ComicIssue> getMetadata() async {
    final stats = comicFile.();
    stats.
  }
}
