import 'dart:io';
import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

import '../../feature/settings/service/storage_service.dart';
import '../helpers/extensions.dart';
import '../../feature/settings/cubit/settings_cubit.dart';

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

  /// User data about the issue. In practice this is not null.
  final IssueUserData? userData;

  /// Local file
  final File? file;

  String get dataPath => path.join(StorageService.instance.dataPath, id);

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
    required this.userData,
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
    this.userData,
    this.file,
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
    this.userData,
    this.comicVineId,
  }) : volume = volume?.toInt(),
       number = number?.toDouble(),
       pubDate = DateTime(int.parse(year)) {
    id = Uuid().v5(issueDisplayNameNamespace, displayName);
  }

  ComicIssueModel.fromUserData({
    required IssueUserData this.userData,
    this.title,
    this.name = "",
    this.volume,
    this.number,
    this.legacyNumber,
    int? year,
    this.description = "",
    this.imagePath,
    this.imageUrl,
    this.file,
    this.comicVineId,
  }) : id = userData.issueId,
       pubDate = year != null ? DateTime(year) : DateTime.now();

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
    IssueUserData? userData,
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
      userData: userData ?? this.userData?.copyWith(issueId: id ?? this.id),
      file: file ?? this.file,
      comicVineId: comicVineId ?? this.comicVineId,
    );
  }

  ComicIssueModel copyWithUserData({
    double? readRatio,
    DateTime? modifiedTime,
    double? userRating,
    Matrix4? transform,
    bool clearRating = false,
    String? userNote,
  }) => copyWith(
    userData: (userData ?? IssueUserData.blank(issueId: id)).copyWith(
      readRatio: readRatio,
      transform: transform,
      modifiedTime: modifiedTime,
      userRating: userRating,
      clearRating: clearRating,
      userNote: userNote,
    ),
  );

  ComicIssueModel merge(covariant ComicIssueModel? other) => copyWith(
    title: other?.title,
    name: (other?.name ?? "") != "" ? other?.name : null,
    volume: other?.volume,
    number: other?.number,
    legacyNumber: other?.legacyNumber,
    pubDate:
        (other?.pubDate ?? DateTime(0)) != DateTime(0) ? other?.pubDate : null,
    description: (other?.description ?? "") != "" ? other?.description : null,
    imagePath: other?.imagePath,
    imageUrl: other?.imageUrl,
    userData: switch ((userData, other?.userData)) {
      (null, null) => IssueUserData.blank(issueId: id),
      (null, IssueUserData data) => data,
      (IssueUserData data, null) => data,
      (var data1!, var data2!) => data1.merge(data2),
    },
    file: file ?? other?.file,
    comicVineId: comicVineId ?? other?.comicVineId,
  );
}

class IssueUserData extends Equatable {
  /// Issue uuid.
  final String issueId;

  /// User read ratio. 0-1
  final double readRatio;

  /// Last transform applied to the concatanated images of the issue.
  final Matrix4 transform;

  /// When data was last modified
  final DateTime modifiedTime;

  /// User rating. 0-1.
  final double? userRating;

  /// User notes.
  final String userNote;

  const IssueUserData({
    required this.issueId,
    required this.readRatio,
    required this.transform,
    required this.modifiedTime,
    required this.userRating,
    required this.userNote,
  });

  IssueUserData.blank({required this.issueId})
    : readRatio = 0,
      transform = Matrix4.identity(),
      modifiedTime = DateTime.now(),
      userRating = null,
      userNote = "";

  IssueUserData.fromJson(Map<String, dynamic> json)
    : issueId = json['id'],
      readRatio = json['readRatio'],
      transform = Matrix4.fromList(
        (json['transform'] as List).map((e) => e as double).toList(),
      ),
      modifiedTime = DateTime.fromMillisecondsSinceEpoch(json['mTime']),
      userRating = json['rating'],
      userNote = json['note'];

  Map<String, dynamic> toJson() => {
    'id': issueId,
    'readRatio': readRatio,
    'transform': transform.storage,
    'mTime': modifiedTime.millisecondsSinceEpoch,
    'rating': userRating,
    'note': userNote,
  };

  IssueUserData copyWith({
    String? issueId,
    double? readRatio,
    Matrix4? transform,
    DateTime? modifiedTime,
    double? userRating,
    bool clearRating = false,
    String? userNote,
  }) => IssueUserData(
    issueId: issueId ?? this.issueId,
    readRatio: readRatio ?? this.readRatio,
    transform: transform ?? this.transform,
    modifiedTime: modifiedTime ?? this.modifiedTime,
    userRating: clearRating ? null : (userRating ?? this.userRating),
    userNote: userNote ?? this.userNote,
  );

  IssueUserData merge(covariant IssueUserData other) =>
      modifiedTime.compareTo(other.modifiedTime) < 0 ? other : this;

  @override
  List<Object?> get props => [
    issueId,
    readRatio,
    transform,
    modifiedTime,
    userRating,
    userNote,
  ];
}

class ComicVolume extends Equatable {
  final String id;
  final String name;
  final int number;
  final DateTime date;
  final int? comicVineId;

  const ComicVolume({
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
