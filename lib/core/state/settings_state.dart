import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path/path.dart' as path;

import '../../feature/home/service/comicvine_api.dart';

@immutable
class SettingsState {
  final String? apiKey;
  const SettingsState({this.apiKey});

  SettingsState copyWith({String? apiKey}) =>
      SettingsState(apiKey: apiKey ?? this.apiKey);
}

class SettingsCubit extends HydratedCubit<SettingsState> {
  static late String _dataPath;
  static String get dataPath => _dataPath;
  static Future<void> setDataDir(Directory dir) async {
    _dataPath = path.join(dir.path, "myread");
    HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory:
          kIsWeb
              ? HydratedStorageDirectory.web
              : HydratedStorageDirectory(dir.path),
    );
  }

  SettingsCubit() : super(SettingsState());

  /// Checks if the api key works and saves it if it does. Returns success.
  Future<bool> trySetApiKey(String apiKey) async {
    try {
      await ComicvineApi.query("Wolverine", apiKey);
      emit(state.copyWith(apiKey: apiKey));
      return true;
    } on DioException {
      return false;
    }
  }

  @override
  SettingsState? fromJson(Map<String, dynamic> json) =>
      SettingsState(apiKey: json['apiKey']);

  @override
  Map<String, dynamic>? toJson(SettingsState state) => {'apiKey': state.apiKey};
}
