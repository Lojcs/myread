import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:line_icons/line_icons.dart';

import '../../../core/helpers/extensions.dart';
import '../cubit/issues_cubit.dart';

class IssueInfoBar extends StatelessWidget {
  final String issueId;
  const IssueInfoBar(this.issueId, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.all(8),
      child: Column(
        spacing: 4,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 4,
            children: [ReadButton(issueId), NoteButton(issueId)],
          ),
          RatingBar(issueId),
        ],
      ),
    );
  }
}

class ReadButton extends StatelessWidget {
  final String issueId;
  const ReadButton(this.issueId, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: BlocSelector<ComicIssuesCubit, IssuesMap, bool>(
        selector: (state) => (state[issueId]!.userData?.readRatio ?? 0) > 0.9,
        builder:
            (context, read) => IconButton.filledTonal(
              visualDensity: VisualDensity(vertical: -2),
              onPressed:
                  () => context.issuesState.setReadRatio(issueId, read ? 0 : 1),
              icon:
                  read
                      ? Row(
                        spacing: 4,
                        children: [Icon(LineIcons.book), Text("Read")],
                      )
                      : Row(
                        spacing: 4,
                        children: [Icon(LineIcons.bookOpen), Text("Reading")],
                      ),
            ),
      ),
    );
  }
}

class RatingBar extends StatelessWidget {
  final String issueId;
  const RatingBar(this.issueId, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: Card(
        color: context.colorScheme.secondaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(20),
        ),
        margin: EdgeInsets.zero,
        child: Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 4),
          child: BlocSelector<ComicIssuesCubit, IssuesMap, double?>(
            selector: (state) => state[issueId]!.userData?.userRating,
            builder:
                (context, rating) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children:
                      [0.2, 0.4, 0.6, 0.8, 1.0, null]
                          .map(
                            (buttonRating) => SizedBox(
                              width: 32,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                onPressed:
                                    () => context.issuesState.setRating(
                                      issueId,
                                      rating: buttonRating,
                                      clearRating: buttonRating == null,
                                    ),
                                icon:
                                    buttonRating == null
                                        ? Icon(Icons.close, size: 20)
                                        : Icon(
                                          (rating ?? 0) >= buttonRating
                                              ? Icons.star
                                              : Icons.star_border,
                                        ),
                              ),
                            ),
                          )
                          .toList(),
                ),
          ),
        ),
      ),
    );
  }
}

class NoteButton extends StatelessWidget {
  final String issueId;
  const NoteButton(this.issueId, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: BlocSelector<ComicIssuesCubit, IssuesMap, String>(
        selector: (state) => state[issueId]!.userData!.userNote,
        builder:
            (context, note) => IconButton.filledTonal(
              visualDensity: VisualDensity(vertical: -2),
              onPressed:
                  () => showDialog(
                    context: context,
                    builder: (context) => NoteEditDialog(issueId, note: note),
                  ),
              icon: Row(
                children: [
                  Icon(LineIcons.pen),
                  SizedBox(width: 4),
                  note == "" ? Text("Add note") : Text("Edit note"),
                ],
              ),
            ),
      ),
    );
  }
}

class NoteEditDialog extends StatefulWidget {
  final String issueId;
  final String note;
  const NoteEditDialog(this.issueId, {super.key, required this.note});

  @override
  State<StatefulWidget> createState() => _NoteEditDialogState();
}

class _NoteEditDialogState extends State<NoteEditDialog> {
  late String note = widget.note;
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text("Edit note"),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          initialValue: widget.note,
          decoration: InputDecoration(
            filled: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 10),
            hintText: "I think...",
            hintStyle: TextStyle(fontSize: 18),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: context.colorScheme.primary),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent),
            ),
          ),
          onChanged: (value) => setState(() => note = value),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () {
          context.issuesState.setNote(widget.issueId, note);
          context.navigator.pop();
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [Icon(Icons.save), Text("Save")],
        ),
      ),
    ],
  );
}
