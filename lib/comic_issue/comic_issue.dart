import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

const String comicVineNamespace = "68d81497-b579-47a1-baf7-4331f0c7172b";

class ComicIssue extends Equatable {
  /// Internal uuid.
  final String id;

  /// Issue title.
  final String title;

  /// Seies name.
  final String name;

  /// Number in series. Not int since issue numbers can get weird.
  final double number;

  num get indexNumber => number.floor() == number ? number.floor() : number;

  /// Date published.
  final DateTime pubDate;

  /// Description / summary / synopsis.
  final String description;

  /// Cover image url.
  final String imageUrl;

  /// User read mark
  final bool read;

  /// User rating. 0-1.
  final double? userRating;

  /// Local file
  final File? file;

  /// Id in ComicVine
  final int? comicVineId;
  const ComicIssue({
    required this.id,
    required this.title,
    required this.name,
    required this.number,
    required this.pubDate,
    required this.description,
    required this.imageUrl,
    required this.read,
    required this.userRating,
    this.file,
    this.comicVineId,
  });
  ComicIssue.comicVine({
    required this.comicVineId,
    this.title = "",
    required this.name,
    required this.number,
    required this.pubDate,
    required this.description,
    required this.imageUrl,
    this.file,
    this.read = false,
    this.userRating,
  }) : id = Uuid().v5(comicVineNamespace, comicVineId.toString());

  String get fullName => "$name - $indexNumber (${pubDate.year})";

  @override
  List<Object?> get props => [id];

  ComicIssue copyWith({
    String? id,
    String? title,
    String? name,
    double? number,
    DateTime? pubDate,
    String? description,
    String? imageUrl,
    bool? read,
    double? userRating,
    File? file,
    int? comicVineId,
  }) {
    return ComicIssue(
      id: id ?? this.id,
      title: title ?? this.title,
      name: name ?? this.name,
      number: number ?? this.number,
      pubDate: pubDate ?? this.pubDate,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      read: read ?? this.read,
      userRating: userRating ?? this.userRating,
      file: file ?? this.file,
      comicVineId: comicVineId ?? this.comicVineId,
    );
  }
}
