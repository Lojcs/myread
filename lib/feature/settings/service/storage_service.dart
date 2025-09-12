import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class StorageService {
  static StorageService? _storageService;

  static Future<void> init() async {
    final dir = await getTemporaryDirectory();
    final dataPath = path.join(dir.path, "myread");
    HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory:
          kIsWeb
              ? HydratedStorageDirectory.web
              : HydratedStorageDirectory(dataPath),
    );
    _storageService = StorageService(dataPath: dataPath);
  }

  static StorageService get instance {
    return _storageService!;
  }

  final String dataPath;

  StorageService({required this.dataPath});
}
