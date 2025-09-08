import 'dart:io';

import 'package:archive/archive.dart';
import 'package:collection/collection.dart';
import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:xml/xml.dart';

import '../models/comic_issue_model.dart';
import 'extensions.dart';

class ComicParser {
  static List<String> supportedImageExtensions = [
    "jpg",
    "jpeg",
    "png",
    "webp",
    "jxl",
  ];

  /// Matches 1: Comic name, 2: Volume number, 3: Issue number, 4: Year.
  static const String rComicFileName =
      r"^(?:[\d. ]*)([\w- ]*?)(?: v(\d))?(?: ([\d-.]+))?(?: \((\d{4})\)).*\.cb([rz])$";
  final File file;
  final XFile xFile;
  ComicParser(PlatformFile comicFile)
    : file = File(comicFile.path!),
      xFile = comicFile.xFile;

  ComicIssueModel? _metadata;

  Future<ComicIssueModel?> getMetadata() async {
    if (_metadata == null) {
      final match = RegExp(rComicFileName).firstMatch(xFile.name);
      if (match != null) {
        final [name!, vol, num, year!, type!] = match.groups([1, 2, 3, 4, 5]);
        if (type == "r") return _metadata;
        var issue = ComicIssueModel.fromFile(
          name: name,
          volume: vol,
          number: num,
          year: year,
          file: file,
        );
        var archivePath = path.join(issue.dataPath, "archive");
        var imagesPath = path.join(issue.dataPath, "images");
        _extract(type, archivePath);
        var (cover, xml) = _flatten(archivePath, imagesPath);
        if (xml != null) {
          final newIssue = _metadataFromXml(xml, year);
          try {
            Directory(newIssue.dataPath).deleteSync(recursive: true);
          } on PathNotFoundException catch (_) {}
          Directory(issue.dataPath).rename(newIssue.dataPath);
          cover = File(path.join(newIssue.dataPath, "images", cover.name));
          issue = newIssue;
        }
        _metadata = issue.copyWith(imagePath: cover.path);
      }
    }
    return _metadata;
  }

  void _extract(String type, String destination) {
    try {
      Directory(destination).deleteSync(recursive: true);
    } on PathNotFoundException catch (_) {}
    switch (type) {
      case "r":
      // UnrarFile.extract_rar(file, destination);
      case "z":
        final archive = ZipDecoder().decodeBytes(file.readAsBytesSync());
        for (final file in archive) {
          switch (file) {
            case ArchiveFile(isFile: false, name: var name):
              Directory(
                path.join(destination, name),
              ).createSync(recursive: true);
            case ArchiveFile(isFile: true, name: var name, content: var data):
              File(path.join(destination, name))
                ..createSync(recursive: true)
                ..writeAsBytesSync(data);
          }
        }
    }
  }

  (File, File?) _flatten(String source, String destination) {
    try {
      Directory(destination).deleteSync(recursive: true);
    } on PathNotFoundException catch (_) {}
    Directory(destination).createSync(recursive: true);
    final entities = PriorityQueue<FileSystemEntity>(_entitySorter);
    entities.addAll(Directory(source).listSync());
    File? cover;
    File? xml;
    while (entities.isNotEmpty) {
      final entity = entities.removeFirst();
      switch (entity) {
        case Directory dir:
          entities.addAll(dir.listSync());
        case File(isImage: true):
          final moved = entity.move(destination);
          cover ??= moved;
        case File(extension: "xml"):
          final moved = entity.move(destination);
          xml ??= moved;
        case FileSystemEntity(hidden: true):
          return (cover!, xml);
      }
    }
    return (cover!, xml);
  }

  int _entitySorter(
    FileSystemEntity entity1,
    FileSystemEntity entity2,
  ) => switch ((entity1, entity2)) {
    (Directory(hidden: false), _) || (_, FileSystemEntity(hidden: true)) => -1,
    (_, Directory(hidden: false)) || (FileSystemEntity(hidden: true), _) => 1,
    (File(name: var name1), File(name: var name2)) => compareNatural(
      name1,
      name2,
    ),
    _ => 0,
  };

  ComicIssueModel _metadataFromXml(File xml, String year) {
    final info =
        XmlDocument.parse(xml.readAsStringSync()).getElement("ComicInfo")!;
    return ComicIssueModel.fromFile(
      name: info.getElement("Series")!.innerText,
      volume: info.getElement("Volume")!.innerText,
      number: info.getElement("Number")!.innerText,
      year: year,
      file: file,
      description: info.getElement("Summary")!.innerText,
    );
  }

  // Directory getDirectory() async {}
}
