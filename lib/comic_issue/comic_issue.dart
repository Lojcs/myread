import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

const String comicVineNamespace = "68d81497-b579-47a1-baf7-4331f0c7172b";

class ComicIssue extends Equatable {
  final String id;
  final String name;
  final int number;
  final DateTime pubDate;
  final String description;
  final String imageUrl;

  final bool read;
  final int? userRating;
  final File? file;

  final int? comicVineId;
  const ComicIssue({
    required this.id,
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
    required this.name,
    required this.number,
    required this.pubDate,
    required this.description,
    required this.imageUrl,
    this.file,
    this.read = false,
    this.userRating,
  }) : id = Uuid().v5(comicVineNamespace, comicVineId.toString());

  String get fullName => "$name - $number (${pubDate.year})";

  @override
  List<Object?> get props => [id];

  ComicIssue copyWith({
    String? id,
    String? name,
    int? number,
    DateTime? pubDate,
    String? description,
    String? imageUrl,
    bool? read,
    int? userRating,
    File? file,
    int? comicVineId,
  }) {
    return ComicIssue(
      id: id ?? this.id,
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
