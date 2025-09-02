import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../feature/home/service/comicvine_api.dart';
import '../state/settings_state.dart';
import '../models/comic_issue_model.dart';

class ComicParser {
  /// Matches 1: Comic name, 2: Volume number, 3: Issue number, 4: Year.
  static const String rComicFileName =
      r"^(?:[\d. ]*)([\w- ]*?)(?: v(\d))?(?: ([\d-.]+))?(?: \((\d{4})\)).*$";
  final XFile comicFile;
  const ComicParser(this.comicFile);
  Future<ComicIssueModel?> getMetadata(String apiKey) async {
    final match = RegExp(rComicFileName).firstMatch(comicFile.name);
    if (match != null) {
      final [name!, volume, number, year!] = match.groups([1, 2, 3, 4]);
      var issue = ComicIssueModel.fromFile(
        name: name,
        volume: volume,
        number: number,
        year: year,
        file: comicFile,
      );
      final query = issue.displayName;
      final results = await ComicvineApi.query(issue.volumeName, apiKey);
      if (results.isNotEmpty) {
        final result = results.first.displayName;
        if (result == query) issue = results.first;
      } else {}
      return issue;
    }
    return null;
  }
}
