import 'dart:io';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

import '../helpers/extensions.dart';
import '../state/settings_state.dart';

const String comicVineIssueNamespace = "68d81497-b579-47a1-baf7-4331f0c7172b";
const String comicVineVolumeNamespace = "d072db0d-5410-4e1a-9f1a-b2a1b0c38800";
const String issueDisplayNameNamespace = "82c04374-117b-4372-b27d-8761d059ec73";

class ComicIssueModel extends Equatable {
  /// Internal uuid.
  late final String id;

  /// Issue title.
  final String? title;

  /// Seies name.
  final String name;

  /// Series volume.
  final int? volume;

  String get volumeString => volume != null ? " v$volume" : "";

  /// Number in volume. Not int since issue numbers can get weird.
  final double? number;

  num? get numberClean => number?.floor() == number ? number?.floor() : number;

  String get numberString => numberClean != null ? " - $numberClean" : "";

  /// Number in series.
  final int? legacyNumber;

  /// Date published.
  final DateTime pubDate;

  /// Description / summary / synopsis.
  final String description;

  /// Cover image file path.
  final String? imagePath;

  /// Cover image url.
  final String? imageUrl;

  ImageProvider get imageProvider =>
      imagePath != null ? FileImage(File(imagePath!)) : NetworkImage(imageUrl!);

  /// User read mark
  final bool read;

  /// User rating. 0-1.
  final double? userRating;

  /// Local file
  final File? file;

  String get dataPath => path.join(SettingsCubit.dataPath, id);

  Future<List<File>> getImages() async {
    final images =
        await Directory(path.join(dataPath, "images")).list().toList();
    return images
        .map((e) => e.isImage ? e as File : null)
        .nonNulls
        .sortedByCompare((e) => e.name, compareNatural);
  }

  /// Id in ComicVine
  final int? comicVineId;

  ComicIssueModel({
    required this.id,
    required this.title,
    required this.name,
    required this.volume,
    required this.number,
    required this.legacyNumber,
    required this.pubDate,
    required this.description,
    required this.imagePath,
    required this.imageUrl,
    required this.read,
    required this.userRating,
    this.file,
    this.comicVineId,
  });

  ComicIssueModel.comicVine({
    required this.comicVineId,
    this.title,
    required this.name,
    this.volume,
    required this.number,
    this.legacyNumber,
    required this.pubDate,
    required this.description,
    this.imagePath,
    required this.imageUrl,
    this.file,
    this.read = false,
    this.userRating,
  }) : id = Uuid().v5(comicVineIssueNamespace, comicVineId.toString());

  ComicIssueModel.fromFile({
    required this.name,
    required String? volume,
    required String? number,
    required String year,
    required this.file,
    this.title,
    this.legacyNumber,
    this.description = "",
    this.imagePath,
    this.imageUrl,
    this.read = false,
    this.userRating,
    this.comicVineId,
  }) : volume = volume?.toInt(),
       number = number?.toDouble(),
       pubDate = DateTime(int.parse(year)) {
    id = Uuid().v5(issueDisplayNameNamespace, displayName);
  }
  String get volumeName => "$name$volumeString (${pubDate.year})";

  String get displayName => "$volumeName$numberString";

  @override
  List<Object?> get props => [id];

  ComicIssueModel copyWith({
    String? id,
    String? title,
    String? name,
    int? volume,
    double? number,
    int? legacyNumber,
    DateTime? pubDate,
    String? description,
    String? imagePath,
    String? imageUrl,
    bool? read,
    double? userRating,
    File? file,
    int? comicVineId,
  }) {
    return ComicIssueModel(
      id: id ?? this.id,
      title: title ?? this.title,
      name: name ?? this.name,
      volume: volume ?? this.volume,
      number: number ?? this.number,
      legacyNumber: legacyNumber ?? this.legacyNumber,
      pubDate: pubDate ?? this.pubDate,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      imageUrl: imageUrl ?? this.imageUrl,
      read: read ?? this.read,
      userRating: userRating ?? this.userRating,
      file: file ?? this.file,
      comicVineId: comicVineId ?? this.comicVineId,
    );
  }
}

class ComicVolume extends Equatable {
  final String id;
  final String name;
  final int number;
  final DateTime date;
  final int? comicVineId;

  ComicVolume({
    required this.id,
    required this.name,
    required this.number,
    required this.date,
    this.comicVineId,
  });

  ComicVolume.comicVine({
    required this.comicVineId,
    required this.name,
    required this.number,
    required this.date,
  }) : id = Uuid().v5(comicVineVolumeNamespace, comicVineId.toString());

  @override
  List<Object?> get props => [id];
}
