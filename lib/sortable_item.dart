// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_sortable_wrap/sortable_utils.dart';
import 'package:flutter_sortable_wrap/sortable_wrap.dart';

class SortableItem extends StatefulWidget {
  SortableItem({
    Key? key,
    required this.element,
    required this.onEventHit,
  }) : super(key: key) {
    element.widget = this;
  }

  final OnEventHit onEventHit;
  final SortableElement element;

  @override
  SortableItemState createState() => SortableItemState();
}

class SortableItemState extends State<SortableItem> with TickerProviderStateMixin {
  /// Animations controllers
  late AnimationController slideToRightController;
  late AnimationController slideToLeftController;

  /// Use for creating a clone ghost view when user dragging to different row
  GhostType ghostType = GhostType.None;

  void setGhostType(GhostType type) => setState(() => ghostType = type);

  /// Visible index for rolling from / rolling to
  late int sourceIndex;
  late int destinationIndex;

  /// Start the rolling animation
  void startAnimation(bool isDraggingInSameRow, int draggingIndex) {
    bool isSlideToRight = destinationIndex > sourceIndex;
    bool isSlideToLeft = destinationIndex < sourceIndex;
    TickerFuture? animationFuture;
    if (isSlideToRight) {
      /// slide to right, use 'reverse', offset.x: -1.0 -> 0.0
      animationFuture = slideToLeftController.reverse(from: 1.0);
    } else if (isSlideToLeft) {
      /// slide to left, use 'reverse', offset.x: 1.0 -> 0.0
      animationFuture = slideToRightController.reverse(from: 1.0);
    }

    /// dragging in the same row/line, just return
    if (isDraggingInSameRow) return;

    /// TODO ... Need a dependent ghost to roll out when hit the first(slide2left)/last(slide2right) one
    /// "destinationIndex != draggingIndex" fix animation effect issue: Hit the first/last one or Dragging one is the first/last one

    /// stick a ghost for the last/first position element
    if (isSlideToRight) {
      if (element.isTheLastOne) {
        if (destinationIndex != draggingIndex) {
          setGhostType(GhostType.Next);
        }
      }
    } else if (isSlideToLeft) {
      if (element.isTheFirstOne) {
        if (destinationIndex != draggingIndex) {
          setGhostType(GhostType.Previous);
        }
      }
    }
    if (ghostType != GhostType.None) {
      animationFuture?.then((value) {
        setGhostType(GhostType.None);
      });
    }
  }

  /// Data or Relation holder, anyway ...
  SortableElement get element => widget.element;

  @override
  void initState() {
    super.initState();
    slideToRightController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    slideToLeftController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
  }

  @override
  void dispose() {
    /// call animation controller first before super.dispose()
    slideToRightController.dispose();
    slideToLeftController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    element.state = this;

    /// append capacity of animation
    Widget _capacityAnimate(Widget child) {
      child = SlideTransition(
        child: child,
        position:
            Tween<Offset>(begin: const Offset(0.0, 0.0), end: const Offset(1.0, 0.0)).animate(slideToRightController),
      );
      child = SlideTransition(
        child: child,
        position:
            Tween<Offset>(begin: const Offset(0.0, 0.0), end: const Offset(-1.0, 0.0)).animate(slideToLeftController),
      );
      return child;
    }

    /// append capacity of able be hit
    Widget _capacityHit(Widget child, OnEventHit onEventHit) {
      List<Widget> children = [
        child,
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          child: DragTarget<SortableElement>(
            builder: (BuildContext context, List<SortableElement?> candidateData, List<dynamic> rejectedData) {
              return const SizedBox();
              // return ColoredBox(color: Colors.grey.withAlpha(128), child: SizedBox());  // for debug :)
            },
            onWillAccept: (SortableElement? toAccept) {
              if (toAccept == null) return false;
              onEventHit(this, toAccept);
              return true;
            },
            onAccept: (SortableElement accepted) {},
            onLeave: (Object? leaving) {},
          ),
        ),
      ];

      /// insert or append a ghost/clone view
      if (ghostType != GhostType.None) {
        double spacing = element.parent.widget.spacing;
        double width = element.parent.anyElementSize.width;
        bool isInFrontOfMe = ghostType == GhostType.Previous;
        double x = isInFrontOfMe ? -width - spacing : width + spacing;
        SortableElement sibling = isInFrontOfMe ? element.previousToMe : element.nextToMe;

        /// x -> in front of me or behind me
        Widget ghostView = Positioned(top: 0, bottom: 0, left: x, child: sibling.view);
        children.insert(isInFrontOfMe ? 0 : children.length, ghostView);
      }
      return Stack(clipBehavior: Clip.none, children: children);
    }

    return _capacityAnimate(_capacityHit(element.view, widget.onEventHit));
  }
}

/// Data or Relation Model
class SortableElement {
  /// The caller's view
  late Widget view;

  /// The caller's children index, the most original index
  late int originalIndex;

  /// The [SortableWrapState] context/state i'm staying in
  late SortableWrapState parent;

  /// Element index before dragging start
  late int preservedIndex;

  /// The [SortableItem] widget i'm binding to
  late SortableItem widget;

  /// The [SortableItemState] widget i'm binding to, corresponding to this [widget]
  late SortableItemState state;

  /// Element index of on rolling what you are looking at
  int get visibleIndex => parent.animationElements.indexOf(this);

  SortableElement get nextToMe => parent.animationElements[visibleIndex + 1];

  SortableElement get previousToMe => parent.animationElements[visibleIndex - 1];

  /// If is the first one on a row
  bool get isTheFirstOne => isTheFirstOnRow(parent.animationElements);

  /// If is the last one on a row
  bool get isTheLastOne => isTheLastOnRow(parent.animationElements);

  bool isTheFirstOnRow(List<SortableElement> elements) {
    int index = elements.indexOf(this);
    return index != 0 && index % parent.elementCountPerRow == 0;
  }

  bool isTheLastOnRow(List<SortableElement> elements) {
    int index = elements.indexOf(this);
    return index != elements.length - 1 && (index + 1) % parent.elementCountPerRow == 0;
  }
}

enum GhostType { None, Previous, Next }

typedef OnEventHit = void Function(SortableItemState state, SortableElement accept);
