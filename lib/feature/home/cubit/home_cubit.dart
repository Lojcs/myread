import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/helpers/comic_parser.dart';
import '../../settings/cubit/settings_cubit.dart';
import '../service/comicvine_api.dart';
import 'issues_cubit.dart';

class HomeState extends Equatable {
  final List<String> searchIssueIds;
  final List<String> localIssueIds;

  const HomeState({
    this.searchIssueIds = const [],
    this.localIssueIds = const [],
  });

  HomeState copyWith({
    List<String>? searchIssueIds,
    List<String>? localIssueIds,
  }) => HomeState(
    searchIssueIds: searchIssueIds ?? this.searchIssueIds,
    localIssueIds: localIssueIds ?? this.localIssueIds,
  );

  @override
  List<Object?> get props => [searchIssueIds, localIssueIds];
}

class HomeCubit extends Cubit<HomeState> {
  final ComicIssuesCubit issuesCubit;
  final SettingsCubit settingsCubit;
  HomeCubit(BuildContext context)
    : issuesCubit = BlocProvider.of<ComicIssuesCubit>(context, listen: false),
      settingsCubit = BlocProvider.of<SettingsCubit>(context, listen: false),
      super(HomeState());

  void onSearch(String query) async {
    final apiKey = settingsCubit.state.apiKey!;
    final results = await ComicvineApi.query(query, apiKey);
    results.forEach(issuesCubit.addIssue);
    emit(
      state.copyWith(
        searchIssueIds:
            {...state.searchIssueIds, ...results.map((e) => e.id)}.toList(),
      ),
    );
  }

  void onAddFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ["cbz", "cbr"],
    );
    if (result != null) {
      final localComic = ComicParser(result.files.first);
      final comicIssue = await localComic.getMetadata();
      if (comicIssue != null) {
        issuesCubit.addIssue(comicIssue);
        emit(
          state.copyWith(
            localIssueIds: {...state.localIssueIds, comicIssue.id}.toList(),
          ),
        );
      }
    }
  }
}
