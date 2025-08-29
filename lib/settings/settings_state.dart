import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../search/comicvine_api.dart';

@immutable
class SettingsState {
  final String? apiKey;
  const SettingsState({this.apiKey});

  SettingsState copyWith({String? apiKey}) =>
      SettingsState(apiKey: apiKey ?? this.apiKey);
}

class Settings extends HydratedCubit<SettingsState> {
  Settings() : super(SettingsState());

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
