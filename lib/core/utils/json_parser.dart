import 'dart:developer' as dev;

import '../models/comic_issue_model.dart';

class JsonParser {
  static Future<List<ComicIssueModel>> parseIssues(
    Map<String, dynamic> response,
  ) async {
    List<ComicIssueModel> issues = [];
    try {
      final results = response['results'];
      for (var result in results) {
        issues.add(
          ComicIssueModel.comicVine(
            comicVineId: result['id'] as int,
            name: result['volume']['name'] as String,
            title: result['name'] as String?,
            number: double.parse(result['issue_number'] as String),
            pubDate: DateTime.parse(result['cover_date'] as String),
            description: result['description'] as String,
            imageUrl: result['image']['medium_url'] as String,
          ),
        );
      }
    } catch (e) {
      dev.log("An error occurred while parsing comicvine response.", error: e);
    }
    return issues;
  }

  static Future<List<ComicIssueModel>> parseVolumes(
    Map<String, dynamic> response,
  ) async {
    List<ComicIssueModel> issues = [];
    try {
      final results = response['results'];
      for (var result in results) {
        issues.add(
          ComicIssueModel.comicVine(
            comicVineId: result['id'] as int,
            name: result['volume']['name'] as String,
            title: result['name'] as String?,
            number: double.parse(result['issue_number'] as String),
            pubDate: DateTime.parse(result['cover_date'] as String),
            description: result['description'] as String,
            imageUrl: result['image']['medium_url'] as String,
          ),
        );
      }
    } catch (e) {
      dev.log("An error occurred while parsing comicvine response.", error: e);
    }
    return issues;
  }
}
