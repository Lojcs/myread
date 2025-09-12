import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../../core/models/comic_issue_model.dart';
import '../../settings/cubit/settings_cubit.dart';
import '../../settings/service/firebase_service.dart';

class ComicIssuesData extends Equatable {
  final Map<String, ComicIssueModel> _issues;
  final DateTime updateTime;
  final DateTime syncTime;

  const ComicIssuesData({
    required Map<String, ComicIssueModel> issues,
    required this.updateTime,
    required this.syncTime,
  }) : _issues = issues;
  ComicIssuesData.blank()
    : _issues = const {},
      updateTime = DateTime.now(),
      syncTime = DateTime(0);

  ComicIssuesData.fromJson(Map<String, dynamic> json)
    : _issues = {
        for (var issue in (json['userData'] as List).map(
          (element) => ComicIssueModel.fromUserData(
            userData: IssueUserData.fromJson(element),
          ),
        ))
          issue.id: issue,
      },
      updateTime = DateTime.fromMillisecondsSinceEpoch(json['updateTime']),
      syncTime = DateTime.fromMillisecondsSinceEpoch(json['syncTime']);

  Map<String, dynamic>? toJson() => {
    'userData':
        _issues.values.map((e) => e.userData?.toJson()).nonNulls.toList(),
    'updateTime': updateTime.millisecondsSinceEpoch,
    'syncTime': syncTime.millisecondsSinceEpoch,
  };

  ComicIssueModel? getUnsynced(String id) => _issues[id];

  ComicIssuesData setIssue(ComicIssueModel issue) => ComicIssuesData(
    issues: {..._issues, issue.id: issue.merge(_issues[issue.id])},
    updateTime: DateTime.now(),
    syncTime: syncTime,
  );

  ComicIssuesData removeIssue(String issueId) => ComicIssuesData(
    issues: {..._issues..removeWhere((key, _) => key == issueId)},
    updateTime: DateTime.now(),
    syncTime: syncTime,
  );

  ComicIssuesData merge(covariant ComicIssuesData other) {
    if (syncTime.compareTo(other.updateTime) < 0) {
      final newIssues = <ComicIssueModel>[];
      for (var issueId in other._issues.keys) {
        final otherIssue = other._issues[issueId]!;
        final localIssue = _issues[issueId];
        final mergedIssue = otherIssue.merge(localIssue);
        newIssues.add(mergedIssue);
      }
      return ComicIssuesData(
        issues: {..._issues, for (var issue in newIssues) issue.id: issue},
        updateTime: other.updateTime,
        syncTime: DateTime.now(),
      );
    }
    return this;
  }

  @override
  List<Object?> get props => [updateTime];
}

class ComicIssuesCubit extends HydratedCubit<ComicIssuesData> {
  late final firebase = FirebaseService.instance;
  final SettingsCubit settingsCubit;
  ComicIssuesCubit(this.settingsCubit) : super(ComicIssuesData.blank());
  void addIssue(ComicIssueModel issue) => emit(state.setIssue(issue));
  void removeIssue(String issueId) => emit(state.removeIssue(issueId));

  Future<ComicIssueModel?> getSynced(String id) async {
    await fetchData();
    return state.getUnsynced(id);
  }

  void setReadRatio(String issueId, double ratio) => emit(
    state.setIssue(
      state._issues[issueId]!.copyWithUserData(
        readRatio: ratio,
        modifiedTime: DateTime.now(),
      ),
    ),
  );
  void setTransform(String issueId, Matrix4 transform) => emit(
    state.setIssue(
      state._issues[issueId]!.copyWithUserData(
        transform: transform,
        modifiedTime: DateTime.now(),
      ),
    ),
  );
  void setRating(String issueId, {double? rating, bool clearRating = false}) =>
      emit(
        state.setIssue(
          state._issues[issueId]!.copyWithUserData(
            userRating: rating,
            clearRating: clearRating,
            modifiedTime: DateTime.now(),
          ),
        ),
      );
  void setNote(String issueId, String note) => emit(
    state.setIssue(state._issues[issueId]!.copyWithUserData(userNote: note)),
  );

  Future<void> fetchData() async {
    if (firebase.loggedIn) {
      final remoteString = await firebase.getData();
      if (remoteString == null) {
        await saveData();
      } else {
        final remoteData = ComicIssuesData.fromJson(json.decode(remoteString));
        emit(state.merge(remoteData));
      }
    }
  }

  Future<void> saveData() async {
    if (firebase.loggedIn) {
      firebase.setData(json.encode(state.toJson()));
    }
  }

  Future<void> autoFetchData() async {
    if (settingsCubit.state.autoSync) return fetchData();
  }

  Future<void> autoSaveData() async {
    if (settingsCubit.state.autoSync) return saveData();
  }

  @override
  ComicIssuesData? fromJson(Map<String, dynamic> json) =>
      ComicIssuesData.fromJson(json);

  @override
  Map<String, dynamic>? toJson(ComicIssuesData state) => state.toJson();
}
