import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../cubit/home_cubit.dart';
import '../../../core/helpers/extensions.dart';
import '../../../core/state/settings_state.dart';
import 'api_key_dialog.dart';
import 'issue_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final cubit = HomeCubit(context);
  double previousSearchListMaxExtent = 0;
  final searchScrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
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
              child: BlocSelector<HomeCubit, HomeState, List<String>>(
                bloc: cubit,
                selector: (state) => state.searchIssueIds,
                builder: (context, issueIds) {
                  if (searchScrollController.hasClients && context.mounted) {
                    searchScrollController.animateTo(
                      previousSearchListMaxExtent + context.width / 2,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                    previousSearchListMaxExtent =
                        searchScrollController.position.maxScrollExtent;
                  }
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
                          onSubmitted: cubit.onSearch,
                          onTap: () {
                            if (BlocProvider.of<SettingsCubit>(
                                  context,
                                  listen: false,
                                ).state.apiKey ==
                                null) {
                              Future.microtask(() {
                                if (context.mounted) {
                                  showDialog(
                                    context: context,
                                    builder: (context) => ApiKeyDialog(),
                                  );
                                }
                              });
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
                              shrinkWrap: true,
                              controller: searchScrollController,
                              itemExtent: 210,
                              itemCount: issueIds.length,
                              itemBuilder:
                                  (context, index) =>
                                      IssueCard(issueIds[index]),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            Card(
              color: context.colorScheme.surfaceContainer,
              child: BlocSelector<HomeCubit, HomeState, List<String>>(
                bloc: cubit,
                selector: (state) => state.localIssueIds,
                builder: (context, issueIds) {
                  if (searchScrollController.hasClients && context.mounted) {
                    searchScrollController.animateTo(
                      previousSearchListMaxExtent + context.width / 2,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                    previousSearchListMaxExtent =
                        searchScrollController.position.maxScrollExtent;
                  }
                  return Padding(
                    padding: EdgeInsetsGeometry.all(8),
                    child: SizedBox(
                      height: 260,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        controller: searchScrollController,
                        itemExtent: 210,
                        itemCount: issueIds.length + 1,
                        itemBuilder:
                            (context, index) =>
                                index < issueIds.length
                                    ? IssueCard(issueIds[index])
                                    : Container(
                                      margin: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: TextButton(
                                        style: ButtonStyle(
                                          shape: WidgetStatePropertyAll(
                                            RoundedRectangleBorder(
                                              borderRadius: BorderRadius.zero,
                                            ),
                                          ),
                                        ),
                                        onPressed: cubit.onAddFile,
                                        child: Center(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text("Add comic file"),
                                              Icon(Icons.add),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
