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

  late final imageKey = GlobalKey();

  ComicIssueModel get issue => context.issuesState.state[widget.issueId]!;

  @override
  Widget build(BuildContext context) {
    if (firstBuild) {
      firstBuild = false;
      lastWidth = context.width;
      lastTransform = issue.userData!.transform;
      if (lastTransform.isIdentity()) {
        final double scale = math.min(800 / context.width, 1);
        lastTransform.scaleByDouble(scale, scale, scale, 1);
      }
      controller = TransformationController(lastTransform)..addListener(() {
        lastTransform = controller.value;
        print(lastTransform);
      });
    }
    // Window resize correction.
    final up = lastTransform.getTranslation().y;
    final scale = controller.value.getScaleOnYAxis();
    final widthScale = context.width / lastWidth;
    controller.value =
        Matrix4.identity()
          ..scaleByDouble(scale, scale, scale, 1)
          ..leftTranslateByDouble(0, up * widthScale, 0, 1);

    lastWidth = context.width;
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        final imageBox =
            imageKey.currentContext!.findRenderObject() as RenderBox;
        final ratio =
            -lastTransform.getTranslation().y /
            lastTransform.getScaleOnYAxis() /
            imageBox.size.height;
        context.issuesState.setReadRatio(widget.issueId, ratio);
        context.issuesState.setTransform(widget.issueId, lastTransform);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.issuesState.state[widget.issueId]!.displayName),
        ),
        body: InteractiveViewer2(
          transformationController: controller,
          child: FutureBuilder<List<File>>(
            future: context.issuesState.state[widget.issueId]!.getImages(),
            builder:
                (context, snapshot) =>
                    snapshot.hasData
                        ? Column(
                          key: imageKey,
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
                          height: double.maxFinite,
                        ),
          ),
        ),
      ),
    );
  }
}
