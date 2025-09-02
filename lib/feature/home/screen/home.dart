import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/models/comic_issue_model.dart';
import '../../../core/helpers/comic_parser.dart';
import '../cubit/issues_cubit.dart';
import '../../../core/helpers/extensions.dart';
import '../service/comicvine_api.dart';
import '../../../core/state/settings_state.dart';
import 'issue_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final searchScrollController = ScrollController();
    if (BlocProvider.of<Settings>(context, listen: false).state.apiKey ==
        null) {
      Future.microtask(() {
        if (context.mounted) {
          showDialog(context: context, builder: (context) => ApiKeyDialog());
        }
      });
    }
    return Scaffold(
      body: Padding(
        padding: EdgeInsetsGeometry.all(8),
        child: Column(
          children: [
            Center(), // This fixes alignment
            Card(
              color: context.colorScheme.surfaceContainerHigh,
              child: Padding(
                padding: EdgeInsetsGeometry.symmetric(
                  horizontal: 30,
                  vertical: 8,
                ),
                child: Text(
                  "MyRead",
                  style: GoogleFonts.fugazOne(
                    textStyle: context.textTheme.displayMedium!,
                  ),
                ),
              ),
            ),
            Card(
              color: context.colorScheme.surfaceContainer,
              child: BlocBuilder<
                ComicIssuesCubit,
                Map<String, ComicIssueModel>
              >(
                builder: (context, issues) {
                  final issueIds = issues.keys.toList();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsetsGeometry.only(
                          left: 12,
                          right: 12,
                          top: 12,
                          bottom: issueIds.isEmpty ? 12 : 0,
                        ),
                        child: SearchBar(
                          backgroundColor: WidgetStateProperty.all(
                            context.colorScheme.surfaceContainerHigh,
                          ),
                          hintText: "Search ComicVine",
                          onSubmitted: (value) async {
                            final issues = BlocProvider.of<ComicIssuesCubit>(
                              context,
                              listen: false,
                            );
                            final apiKey =
                                BlocProvider.of<Settings>(
                                  context,
                                  listen: false,
                                ).state.apiKey!;
                            final results = await ComicvineApi.query(
                              value,
                              apiKey,
                            );
                            results.forEach(issues.addIssue);
                            if (searchScrollController.hasClients &&
                                context.mounted) {
                              searchScrollController.animateTo(
                                searchScrollController
                                        .position
                                        .maxScrollExtent +
                                    context.width / 2,
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                              );
                            }
                          },
                          trailing: [Icon(Icons.search, color: Colors.grey)],
                        ),
                      ),
                      if (issueIds.isNotEmpty)
                        Padding(
                          padding: EdgeInsetsGeometry.all(8),
                          child: SizedBox(
                            height: 260,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              controller: searchScrollController,
                              itemExtent: 210,
                              itemCount: issueIds.length,
                              itemBuilder:
                                  (context, index) =>
                                      index < issueIds.length
                                          ? IssueCard(issueIds[index])
                                          : null,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            Card(
              clipBehavior: Clip.antiAlias,
              child: TextButton(
                style: ButtonStyle(
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                onPressed: () async {
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ["cbz", "cbr"],
                  );
                  if (result != null) {
                    final issues = BlocProvider.of<ComicIssuesCubit>(
                      context,
                      listen: false,
                    );
                    final apiKey =
                        BlocProvider.of<Settings>(
                          context,
                          listen: false,
                        ).state.apiKey!;
                    final localComic = ComicParser(result.xFiles.first);
                    final comicIssue = await localComic.getMetadata(apiKey);
                    if (comicIssue != null) {
                      issues.addIssue(comicIssue);
                    }
                  }
                },
                child: SizedBox(
                  height: 64,
                  width: 144,
                  child: Center(child: Text("Add comic file")),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ApiKeyDialog extends StatefulWidget {
  const ApiKeyDialog({super.key});

  @override
  State<StatefulWidget> createState() => _ApiKeyDialogState();
}

class _ApiKeyDialogState extends State<ApiKeyDialog> {
  String apiKey = "";
  bool keyInvalid = false;
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text("Comicvine API key is needed"),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          decoration: InputDecoration(
            filled: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 10),
            hintText: "ComicVine API key",
            hintStyle: TextStyle(fontSize: 18),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: context.colorScheme.primary),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent),
            ),
          ),
          onChanged: (value) => setState(() => apiKey = value),
        ),
      ],
    ),
    actions: [
      if (keyInvalid)
        Text(
          "⚠️Key is invalid⚠️",
          style: context.textTheme.bodyMedium!.copyWith(color: Colors.red),
        ),
      TextButton(
        onPressed:
            apiKey == ""
                ? null
                : () async {
                  setState(() => keyInvalid = false);
                  final success = await BlocProvider.of<Settings>(
                    context,
                    listen: false,
                  ).trySetApiKey(apiKey);
                  if (success) {
                    if (context.mounted) {
                      context.navigator.pop();
                    }
                  } else {
                    setState(() => keyInvalid = true);
                  }
                },
        child: Text("Save"),
      ),
    ],
  );
}
