import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/comic_issue_model.dart';

class ComicIssuesCubit extends Cubit<Map<String, ComicIssueModel>> {
  ComicIssuesCubit() : super(const {});
  void addIssue(ComicIssueModel issue) => emit({...state, issue.id: issue});

  void removeIssue(String issueId) =>
      emit({...state..removeWhere((key, _) => key == issueId)});
}
