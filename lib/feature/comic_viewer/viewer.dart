import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:interactive_viewer_2/interactive_dev.dart';
import 'package:interactive_viewer_2/interactive_viewer_2.dart';
import 'package:matrix4_transform/matrix4_transform.dart';

import '../../core/helpers/extensions.dart';
import '../../core/models/comic_issue_model.dart';
import '../home/cubit/issues_cubit.dart';

class ComicViewer extends StatefulWidget {
  final String issueId;

  const ComicViewer({super.key, required this.issueId});
  @override
  State<StatefulWidget> createState() => _ComicViewerState();
}

class _ComicViewerState extends State<ComicViewer> {
  bool firstBuild = true;
  late TransformationController controller;
  late Matrix4 lastTransform;
  late double lastWidth;

  @override
  Widget build(BuildContext context) {
    if (firstBuild) {
      firstBuild = false;
      lastWidth = context.width;
      lastTransform =
          Matrix4Transform().scale(math.min(800 / context.width, 1)).matrix4;
      controller = TransformationController(lastTransform)..addListener(() {
        lastTransform = controller.value;
      });
    }
    // Window resize correction.
    final up = lastTransform.toScene(Offset.zero).dy;
    final scale = controller.value.getScaleOnYAxis();
    final scaledUp = up * scale;
    final widthScale = context.width / lastWidth;
    controller.value =
        Matrix4Transform().scale(scale).up(scaledUp * widthScale).matrix4;

    lastWidth = context.width;
    return BlocSelector<
      ComicIssuesCubit,
      Map<String, ComicIssueModel>,
      ComicIssueModel
    >(
      selector: (issues) => issues[widget.issueId]!,
      builder: (context, issue) {
        return Scaffold(
          appBar: AppBar(title: Text(issue.displayName)),
          body: InteractiveViewer2(
            transformationController: controller,
            child: FutureBuilder<List<File>>(
              future: issue.getImages(),
              builder:
                  (context, snapshot) =>
                      snapshot.hasData
                          ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:
                                snapshot.data!
                                    .map(
                                      (file) => Image(
                                        width: context.width,
                                        image: FileImage(file),
                                      ),
                                    )
                                    .toList(),
                          )
                          : SizedBox(
                            width: context.width,
                            height: context.height * 2,
                          ),
            ),
          ),
        );
      },
    );
  }
}
