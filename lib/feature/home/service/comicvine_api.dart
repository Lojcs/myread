import 'dart:convert';
import 'dart:developer' as dev;

import 'package:dio/dio.dart';
import 'package:xml/xml.dart';

import '../../../core/models/comic_issue_model.dart';
import '../../../core/utils/json_parser.dart';

class ComicvineApi {
  static ComicvineApi? _comicVineApi;

  static ComicvineApi get singleton {
    _comicVineApi ??= ComicvineApi();
    return _comicVineApi!;
  }

  static Future<List<ComicIssueModel>> query(
    String query,
    String apiKey,
  ) async {
    final response = await Dio().get(
      'https://comicvine.gamespot.com/api/search/',
      queryParameters: {
        'format': 'json',
        'api_key': apiKey,
        'query': query,
        'resources': ['issue'],
        'limit': 10,
      },
    );
    return JsonParser.parseIssues(response.data);
  }

  static Future<List<ComicIssueModel>> volumeQuery(
    String query,
    String apiKey,
  ) async {
    final response = await Dio().get(
      'https://comicvine.gamespot.com/api/search/',
      queryParameters: {
        'format': 'json',
        'api_key': apiKey,
        'query': query,
        'resources': ['volume'],
        'limit': 10,
      },
    );
    return JsonParser.parseVolumes(response.data);
  }
}
