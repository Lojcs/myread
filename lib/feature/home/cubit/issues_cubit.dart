import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../../core/models/comic_issue_model.dart';

typedef IssuesMap = Map<String, ComicIssueModel>;

class ComicIssuesCubit extends HydratedCubit<IssuesMap> {
  ComicIssuesCubit() : super(const {});
  void addIssue(ComicIssueModel issue) =>
      emit({...state, issue.id: issue.mergeUserData(state[issue.id])});

  void removeIssue(String issueId) =>
      emit({...state..removeWhere((key, _) => key == issueId)});

  void setReadRatio(String issueId, double ratio) => emit({
    ...state,
    issueId: state[issueId]!.copyWithUserData(
      readRatio: ratio,
      lastAccessed: DateTime.now(),
    ),
  });

  void setTransform(String issueId, Matrix4 transform) => emit({
    ...state,
    issueId: state[issueId]!.copyWithUserData(
      transform: transform,
      lastAccessed: DateTime.now(),
    ),
  });

  void setRating(String issueId, {double? rating, bool clearRating = false}) =>
      emit({
        ...state,
        issueId: state[issueId]!.copyWithUserData(
          userRating: rating,
          clearRating: clearRating,
        ),
      });

  void setNote(String issueId, String note) => emit({
    ...state,
    issueId: state[issueId]!.copyWithUserData(userNote: note),
  });

  @override
  IssuesMap? fromJson(Map<String, dynamic> json) => {
    for (var issue in (json['userData'] as List).map(
      (element) => ComicIssueModel.fromUserData(
        userData: IssueUserData.fromJson(element),
      ),
    ))
      issue.id: issue,
  };

  @override
  Map<String, dynamic>? toJson(IssuesMap state) => {
    'userData': state.values.map((e) => e.userData?.toJson()).nonNulls.toList(),
  };
}
