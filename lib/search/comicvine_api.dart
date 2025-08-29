import 'dart:developer' as dev;

import 'package:dio/dio.dart';
import 'package:xml/xml.dart';

import '../comic_issue/comic_issue.dart';

class ComicvineApi {
  static Future<List<ComicIssue>> query(String query, String apiKey) async {
    final response = await Dio().get(
      'https://comicvine.gamespot.com/api/search/',
      queryParameters: {
        'api_key': apiKey,
        'query': query,
        'resources': ['issue'],
        'limit': 10,
      },
    );
    return parse(response.data);
  }

  static Future<List<ComicIssue>> parse(String response) async {
    List<ComicIssue> issues = [];
    try {
      final parsed = XmlDocument.parse(response);
      final results = parsed
          .getElement('response')!
          .getElement('results')!
          .findElements('issue');
      for (var result in results) {
        final id = int.parse(result.getElement('id')!.innerText);
        print(result.toString());
        var name = result.getElement('name')!.innerText;
        if (name == "") {
          name = result.getElement('volume')!.getElement('name')!.innerText;
        }
        final number = int.parse(result.getElement('issue_number')!.innerText);
        final date = DateTime.parse(result.getElement('cover_date')!.innerText);
        final description = result.getElement('description')!.innerText;
        final image =
            result.getElement('image')!.getElement('medium_url')!.innerText;
        issues.add(
          ComicIssue.comicVine(
            comicVineId: id,
            name: name,
            number: number,
            pubDate: date,
            description: description,
            imageUrl: image,
          ),
        );
      }
    } catch (e) {
      dev.log("An error occurred while parsing comicvine response.", error: e);
    }
    return issues;
  }
}
