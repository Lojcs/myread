import 'package:flutter_bloc/flutter_bloc.dart';

import 'comic_issue.dart';

class ComicIssues extends Cubit<Map<String, ComicIssue>> {
  ComicIssues() : super(const {});
  void addIssue(ComicIssue issue) => emit({...state, issue.id: issue});

  void removeIssue(String issueId) =>
      emit({...state..removeWhere((key, _) => key != issueId)});
}
