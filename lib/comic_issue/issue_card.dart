import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';

import '../helpers/extensions.dart';
import 'comic_issue.dart';
import 'issue_state.dart';

class IssueCard extends StatefulWidget {
  final String issueId;
  final bool large;
  final double width;
  final double height;
  const IssueCard(
    this.issueId, {
    super.key,
    this.large = false,
    required this.width,
    required this.height,
  });

  @override
  State<StatefulWidget> createState() => _IssueCardState();
}

class _IssueCardState extends State<IssueCard> {
  final GlobalKey cardKey = GlobalKey();
  bool hideCard = false;

  @override
  Widget build(BuildContext context) {
    double height = widget.height - 10;
    print(height);
    if (hideCard) return Center();
    return Padding(
      key: cardKey,
      padding: EdgeInsets.all(height / 25),
      child: Card(
        margin: EdgeInsets.all(0),
        color: context.colorScheme.surfaceContainerHigh,
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(5),
              child: BlocSelector<
                ComicIssues,
                Map<String, ComicIssue>,
                ComicIssue
              >(
                selector: (issues) => issues[widget.issueId]!,
                builder:
                    (context, issue) => Stack(
                      alignment: AlignmentGeometry.bottomCenter,
                      children: [
                        SizedBox(
                          // These need to be anything for it to work
                          width: double.infinity,
                          height: double.infinity,
                          child: Material(
                            borderRadius: BorderRadius.circular(8),
                            clipBehavior: Clip.antiAlias,
                            child: Image(
                              loadingBuilder:
                                  (
                                    context,
                                    child,
                                    loadingProgress,
                                  ) => switch (loadingProgress) {
                                    ImageChunkEvent(
                                      cumulativeBytesLoaded: int loaded,
                                      expectedTotalBytes: int expected,
                                    ) =>
                                      Stack(
                                        alignment: AlignmentGeometry.center,
                                        children: [
                                          SizedBox(
                                            height: 100,
                                            width: 100,
                                            child: CircularProgressIndicator(
                                              value: loaded / expected,
                                            ),
                                          ),
                                        ],
                                      ),
                                    _ => child,
                                  },
                              alignment: AlignmentGeometry.topCenter,
                              fit: BoxFit.cover,
                              image: NetworkImage(issue.imageUrl),
                            ),
                          ),
                        ),
                        if (widget.large) _tapOverlay(context),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: (height - 200) / 10,
                          ),
                          child: SizedBox(
                            height: 3 * (height - 150) / 10,
                            width: context.width - 160,
                            child: Container(
                              alignment: AlignmentGeometry.topCenter,
                              padding: EdgeInsetsGeometry.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: ColorScheme.of(
                                  context,
                                ).surfaceContainerHigh.withAlpha(72),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 2),
                                child: SingleChildScrollView(
                                  padding: EdgeInsets.all(0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        issue.fullName,
                                        textAlign: TextAlign.center,
                                        textScaler: TextScaler.linear(
                                          (height + 150) / 400,
                                        ),
                                        style: GoogleFonts.ibmPlexSans(
                                          textStyle:
                                              context.textTheme.bodyMedium,
                                        ),
                                      ),
                                      Html(data: issue.description),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
              ),
            ),
            if (!widget.large) _tapOverlay(context),
          ],
        ),
      ),
    );
  }

  Widget _tapOverlay(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap:
          () =>
              widget.large
                  ? context.navigator.pop()
                  : context.navigator.push(
                    IssueCardDetailRoute(
                      context,
                      widget.issueId,
                      cardKey: cardKey,
                      showCard: () {
                        setState(() => hideCard = false);
                      },
                      hideCard: () {
                        setState(() => hideCard = true);
                      },
                    ),
                  ),
    ),
  );
}

class IssueCardDetailRoute extends ModalRoute {
  final String issueId;
  final GlobalKey cardKey;

  final VoidCallback showCard;
  final VoidCallback hideCard;
  final VoidCallback? onDispose;

  final RenderBox cardBox;

  late final Offset initialHeroOffset;
  final Offset finalHeroOffset;

  late final Tween<Size> sizeTween;
  late final Tween<Offset> offsetTween;

  IssueCardDetailRoute(
    BuildContext context,
    this.issueId, {
    required this.cardKey,
    required this.showCard,
    required this.hideCard,
    this.onDispose,
  }) : cardBox = cardKey.currentContext!.findRenderObject() as RenderBox,
       finalHeroOffset = Offset(10, 10) {
    sizeTween = Tween(
      begin: cardBox.size,
      end: Size(context.width, context.height),
    );
    final cardOffset = cardBox.localToGlobal(Offset.zero);
    offsetTween = Tween(begin: cardOffset, end: Offset.zero);
  }

  @override
  void dispose() {
    showCard();
    if (onDispose != null) onDispose!();
    super.dispose();
  }

  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => false;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    Future.microtask(hideCard);
    final sizeAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOutCirc,
    );
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final size = sizeTween.evaluate(sizeAnimation);
        return Stack(
          children: [
            animation.isCompleted
                ? PopScope(
                  onPopInvokedWithResult: (didPop, result) {
                    if (didPop) {
                      Future.delayed(Duration(milliseconds: 400), showCard);
                    }
                  },
                  child: IssueCard(
                    issueId,
                    large: true,
                    width: context.width,
                    height: context.height,
                  ),
                )
                : Transform.translate(
                  offset: offsetTween.evaluate(sizeAnimation),
                  child: Container(
                    // clipBehavior: Clip.hardEdge,
                    height: size.height,
                    width: size.width,
                    child: SizedBox(
                      height: size.height,
                      width: size.width,
                      child: PopScope(
                        onPopInvokedWithResult: (didPop, result) {
                          if (didPop) {
                            Future.delayed(
                              Duration(milliseconds: 400),
                              showCard,
                            );
                          }
                        },
                        child: IssueCard(
                          issueId,
                          large: true,
                          width: size.width,
                          height: size.height,
                        ),
                      ),
                    ),
                  ),
                ),
          ],
        );
      },
    );
  }

  @override
  bool get maintainState => false;

  @override
  bool get opaque => false;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 400);
}
