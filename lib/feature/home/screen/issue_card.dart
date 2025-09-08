import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/helpers/extensions.dart';
import '../../../core/models/comic_issue_model.dart';
import '../../comic_viewer/viewer.dart';
import '../cubit/issues_cubit.dart';

class IssueCard extends StatefulWidget {
  final String issueId;
  final bool large;
  final bool hideInfoCard;
  final Animation<double>? animation;
  const IssueCard(
    this.issueId, {
    super.key,
    this.large = false,
    this.hideInfoCard = false,
    this.animation,
  });

  @override
  State<StatefulWidget> createState() => _IssueCardState();
}

class _IssueCardState extends State<IssueCard> {
  final GlobalKey cardKey = GlobalKey();
  final GlobalKey infoKey = GlobalKey();
  bool hideCard = false;

  final EdgeInsetsTween marginTween = EdgeInsetsTween(
    begin: EdgeInsets.all(10),
    end: EdgeInsets.all(30),
  );

  @override
  Widget build(BuildContext context) {
    if (hideCard) return Center();
    return Stack(
      alignment: AlignmentGeometry.center,
      children: [
        BlocSelector<
          ComicIssuesCubit,
          Map<String, ComicIssueModel>,
          ComicIssueModel
        >(
          selector: (issues) => issues[widget.issueId]!,
          builder: (context, issue) {
            if (widget.animation != null) {
              return AnimatedBuilder(
                animation: widget.animation!,
                child: infoCard(),
                builder: (context, child) => getBody(context, issue, child!),
              );
            } else {
              return getBody(context, issue, infoCard());
            }
          },
        ),
      ],
    );
  }

  Widget infoCard() =>
      widget.large
          ? Center()
          : IssueInfoCard(
            widget.issueId,
            animation: widget.animation,
            key: infoKey,
          );

  Widget getBody(
    BuildContext context,
    ComicIssueModel issue,
    Widget infoCard,
  ) => Card(
    key: cardKey,
    margin: marginTween.tryEvaluate(widget.animation),
    color: context.colorScheme.surfaceContainerHigh,
    clipBehavior: Clip.antiAlias,
    child: Stack(
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
                  (context, child, loadingProgress) =>
                      switch (loadingProgress) {
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
              image: issue.imageProvider,
            ),
          ),
        ),
        if (widget.large) _tapOverlay(context, issue),
        infoCard,
        if (!widget.large) _tapOverlay(context, issue),
      ],
    ),
  );

  Widget _tapOverlay(BuildContext context, ComicIssueModel issue) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap:
          () =>
              widget.large
                  ? issue.file != null
                      ? context.navigator.push(
                        MaterialPageRoute(
                          builder:
                              (context) => ComicViewer(issueId: widget.issueId),
                        ),
                      )
                      : context.navigator.pop()
                  : context.navigator.push(
                    IssueCardDetailRoute(
                      context,
                      widget.issueId,
                      cardKey: cardKey,
                      infoKey: infoKey,
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

class IssueInfoCard extends StatefulWidget {
  final String issueId;
  final Animation<double>? animation;
  final bool largeInfo;
  const IssueInfoCard(
    this.issueId, {
    super.key,
    this.animation,
    this.largeInfo = false,
  });

  @override
  State<StatefulWidget> createState() => _IssueInfoCardState();
}

class _IssueInfoCardState extends State<IssueInfoCard>
    with SingleTickerProviderStateMixin {
  final Tween<double> textScaleTween = Tween(begin: 1, end: 2);
  final Tween<double> blurScaleTween = Tween(begin: 1, end: 8);
  final Tween<double> smallHeightTween = Tween(begin: 30, end: 120);
  final Tween<double> largeHeightTween = Tween(begin: 30, end: 350);
  final Tween<double> heightTransitionTween = Tween(begin: 120, end: 350);
  final Tween<double> enlargeButtonHeightTween = Tween(begin: 0, end: 20);
  Tween<double> get heightTween =>
      _sizeAnimationController.value == 1 ? largeHeightTween : smallHeightTween;
  final EdgeInsetsTween marginTween = EdgeInsetsTween(
    begin: EdgeInsets.symmetric(horizontal: 8, vertical: 20),
    end: EdgeInsets.symmetric(horizontal: 50, vertical: 100),
  );

  late final AnimationController _sizeAnimationController;
  late final Animation<double> _sizeAnimation;
  bool sizeAnimationRunning = false;

  @override
  void initState() {
    super.initState();
    widget.animation?.addListener(() => sizeAnimationRunning = false);
    _sizeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(() => setState(() => sizeAnimationRunning = true));
    _sizeAnimation = CurvedAnimation(
      parent: _sizeAnimationController,
      curve: Curves.easeInOutCirc,
    );
    if (widget.largeInfo) {
      _sizeAnimationController.value = 1;
      sizeAnimationRunning = false;
    }
  }

  @override
  void didUpdateWidget(covariant IssueInfoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.largeInfo && !oldWidget.largeInfo) {
      _sizeAnimationController.reset();
      _sizeAnimationController.forward();
    } else if (!widget.largeInfo && oldWidget.largeInfo) {
      _sizeAnimationController.value = 1;
      _sizeAnimationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      ComicIssuesCubit,
      Map<String, ComicIssueModel>,
      ComicIssueModel
    >(
      selector: (issues) => issues[widget.issueId]!,
      builder: (context, issue) {
        if (widget.animation != null) {
          return AnimatedBuilder(
            animation: widget.animation!,
            builder: (context, child) {
              return getBody(context, issue);
            },
          );
        } else {
          return getBody(context, issue);
        }
      },
    );
  }

  Widget getBody(BuildContext context, ComicIssueModel issue) {
    final value = blurScaleTween.tryEvaluate(widget.animation);
    return Container(
      height:
          sizeAnimationRunning
              ? heightTransitionTween.tryEvaluate(_sizeAnimation)
              : heightTween.tryEvaluate(widget.animation),
      // width: context.width - 160,
      alignment: AlignmentGeometry.topCenter,
      margin: marginTween.tryEvaluate(widget.animation),
      padding: EdgeInsetsGeometry.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: ColorScheme.of(context).surfaceContainerHigh.withAlpha(48),
      ),
      clipBehavior: Clip.antiAlias,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6 * value, sigmaY: 2 * value),
        child: Stack(
          alignment: AlignmentGeometry.topCenter,
          children: [
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    height: enlargeButtonHeightTween.tryEvaluate(
                      widget.animation,
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        if (_sizeAnimationController.value == 0) {
                          _sizeAnimationController.forward();
                        } else {
                          _sizeAnimationController.reverse();
                        }
                      },
                      icon: Icon(
                        _sizeAnimationController.value == 0
                            ? Icons.arrow_drop_up
                            : Icons.arrow_drop_down,
                      ),
                    ),
                  ),
                  Text(
                    issue.displayName,
                    textAlign: TextAlign.center,
                    textScaler: TextScaler.linear(
                      textScaleTween.tryEvaluate(widget.animation),
                    ),
                    style: GoogleFonts.ibmPlexSans(
                      textStyle: context.textTheme.bodyMedium,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (issue.title != null)
                    Text(
                      issue.title!,
                      textAlign: TextAlign.center,
                      textScaler: TextScaler.linear(
                        textScaleTween.tryEvaluate(widget.animation),
                      ),
                      style: GoogleFonts.ibmPlexSans(
                        textStyle: context.textTheme.bodyMedium,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  Html(
                    data: issue.description,
                    style: {
                      "*": Style(
                        textAlign: TextAlign.center,
                        // fontWeight: FontWeight.bold,
                      ),
                    },
                  ),
                  Card(
                    clipBehavior: Clip.antiAlias,
                    child: TextButton(
                      style: ButtonStyle(
                        shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                      ),
                      onPressed: () {},
                      child: SizedBox(
                        height: 48,
                        width: 72,
                        child: Center(child: Text("Add file")),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class IssueCardDetailRoute extends ModalRoute {
  final String issueId;
  final GlobalKey cardKey;
  final GlobalKey infoKey;

  final VoidCallback showCard;
  final VoidCallback hideCard;
  final VoidCallback? onDispose;

  final RenderBox cardBox;
  final RenderBox infoBox;

  late final Size cardSize;
  late final Size infoSize;

  late final Offset rawCardOffset;
  late final Offset rawInfoOffset;

  Offset getCardOffset(BuildContext context) =>
      rawCardOffset -
      Offset(
        (context.width - cardSize.width) / 2,
        (context.height - cardSize.height) / 2,
      );
  Offset getInfoOffset(BuildContext context) =>
      rawInfoOffset -
      Offset(
        (context.width - infoSize.width) / 2,
        (context.height - infoSize.height) / 2,
      );

  late final Tween<Size> sizeTween;
  late final Tween<Size> infoSizeTween;

  late Tween<Offset> offsetTween;
  late Tween<Offset> infoOffsetTween;

  IssueCardDetailRoute(
    BuildContext context,
    this.issueId, {
    required this.cardKey,
    required this.infoKey,
    required this.showCard,
    required this.hideCard,
    this.onDispose,
  }) : cardBox = cardKey.currentContext!.findRenderObject() as RenderBox,
       infoBox = infoKey.currentContext!.findRenderObject() as RenderBox {
    sizeTween = Tween(
      begin: cardBox.size,
      end: Size(500, math.min(context.height, 750)),
    );
    cardSize = cardBox.size;
    rawCardOffset = cardBox.localToGlobal(Offset.zero);
    infoSizeTween = Tween(begin: infoBox.size, end: Size(500, 400));
    infoSize = infoBox.size;
    rawInfoOffset = infoBox.localToGlobal(Offset.zero);
  }

  static const nestedCardOffset = Offset(0, 0);
  static const sideCardOffset = Offset(-250, 0);
  static const nestedInfoOffset = Offset(0, 150);
  static const sideInfoOffset = Offset(250, 0);

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

  bool primaryAnimation = true;
  bool? sideBySide;

  bool newSideBySide(BuildContext context) => context.width >= 1000;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    if (sideBySide == null) {
      sideBySide = newSideBySide(context);
      offsetTween = Tween(
        begin: getCardOffset(context),
        end: sideBySide! ? sideCardOffset : nestedCardOffset,
      );
      infoOffsetTween = Tween(
        begin: getInfoOffset(context),
        end: sideBySide! ? sideInfoOffset : nestedInfoOffset,
      );
    } else if (sideBySide != newSideBySide(context)) {
      primaryAnimation = false;
      sideBySide = newSideBySide(context);
      offsetTween = Tween(
        begin: sideBySide! ? nestedCardOffset : sideCardOffset,
        end: sideBySide! ? sideCardOffset : nestedCardOffset,
      );
      infoOffsetTween = Tween(
        begin: sideBySide! ? nestedInfoOffset : sideInfoOffset,
        end: sideBySide! ? sideInfoOffset : nestedInfoOffset,
      );
    }
    Future.microtask(hideCard);
    final sizeAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOutCirc,
    );
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.navigator.pop(),
      child: AnimatedBuilder(
        animation: animation,
        child: IssueCard(
          issueId,
          large: true,
          hideInfoCard: true,
          animation: sizeAnimation,
        ),
        builder: (context, child) {
          if (animation.status == AnimationStatus.reverse) {
            primaryAnimation = true;
            offsetTween = Tween(
              begin: getCardOffset(context),
              end: sideBySide! ? sideCardOffset : nestedCardOffset,
            );
            infoOffsetTween = Tween(
              begin: getInfoOffset(context),
              end: sideBySide! ? sideInfoOffset : nestedInfoOffset,
            );
          }
          final cardSize = sizeTween.evaluate(sizeAnimation);
          final infoSize = infoSizeTween.evaluate(sizeAnimation);
          return Stack(
            alignment: AlignmentGeometry.center,
            children: [
              _ChildRelocator(
                offset: offsetTween.evaluate(sizeAnimation),
                offsetTween: offsetTween,
                useTween: !primaryAnimation,
                child: SizedBox(
                  height: cardSize.height,
                  width: cardSize.width,
                  child: PopScope(
                    onPopInvokedWithResult: (didPop, result) {
                      if (didPop) {
                        Future.delayed(Duration(milliseconds: 400), showCard);
                      }
                    },
                    child: child!,
                  ),
                ),
              ),
              _ChildRelocator(
                offset: infoOffsetTween.evaluate(sizeAnimation),
                offsetTween: infoOffsetTween,
                useTween: !primaryAnimation,
                child: SizedBox(
                  width: infoSize.width,
                  child: PopScope(
                    onPopInvokedWithResult: (didPop, result) {
                      if (didPop) {
                        Future.delayed(Duration(milliseconds: 400), showCard);
                      }
                    },
                    child: Material(
                      type: MaterialType.transparency,
                      child: IssueInfoCard(
                        issueId,
                        animation: sizeAnimation,
                        largeInfo: sideBySide!,
                        // key: infoKey,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  bool get maintainState => false;

  @override
  bool get opaque => false;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 400);
}

/// This ugly thing lets me add another animation to the route.
/// Certainly the wrong way to architect this overall.
class _ChildRelocator extends StatefulWidget {
  final Offset offset;
  final Tween<Offset> offsetTween;
  final bool useTween;
  final Widget child;

  const _ChildRelocator({
    required this.offset,
    required this.offsetTween,
    required this.useTween,
    required this.child,
  });
  @override
  State<StatefulWidget> createState() => _ChildRelocatorState();
}

class _ChildRelocatorState extends State<_ChildRelocator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..addListener(() => setState(() {}));
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCirc,
    );
  }

  @override
  void didUpdateWidget(covariant _ChildRelocator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.useTween &&
        (oldWidget.useTween != widget.useTween ||
            oldWidget.offsetTween != widget.offsetTween)) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset:
          widget.useTween
              ? widget.offsetTween.evaluate(_animation)
              : widget.offset,
      child: widget.child,
    );
  }
}

class IssueCardData {
  final bool expanded;
  final bool sideBySide;

  IssueCardData({required this.expanded, required this.sideBySide});

  IssueCardData copyWith({bool? expanded, bool? sideBySide}) => IssueCardData(
    expanded: expanded ?? this.expanded,
    sideBySide: sideBySide ?? this.sideBySide,
  );
}

class IssueCardCubit extends Cubit<IssueCardData> {
  IssueCardCubit(super.initialState);

  void setSideBySide(bool value) => emit(state.copyWith(sideBySide: value));
}
