import 'dart:io';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path/path.dart' as path;

import '../../home/service/comicvine_api.dart';

@immutable
class SettingsState extends Equatable {
  final String? apiKey;
  final bool autoSync;
  const SettingsState({this.apiKey, this.autoSync = false});

  SettingsState copyWith({String? apiKey, bool? autoSync}) => SettingsState(
    apiKey: apiKey ?? this.apiKey,
    autoSync: autoSync ?? this.autoSync,
  );

  @override
  List<Object?> get props => [apiKey, autoSync];
}

class SettingsCubit extends HydratedCubit<SettingsState> {
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

  void setAutoSync(bool value) => emit(state.copyWith(autoSync: value));

  @override
  SettingsState? fromJson(Map<String, dynamic> json) =>
      SettingsState(apiKey: json['apiKey']);

  @override
  Map<String, dynamic>? toJson(SettingsState state) => {'apiKey': state.apiKey};
}
