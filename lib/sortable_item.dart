import 'package:flutter/material.dart';
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
  void startAnimation(bool isDraggingInSameRow) {
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

    /// TODO ... Hit the first/last one animation effect issue ...

    /// stick a ghost for the last/first position element
    if (isSlideToRight) {
      if (element.isTheLastOne) {
        setGhostType(GhostType.Next);
      }
    } else if (isSlideToLeft) {
      if (element.isTheFirstOne) {
        setGhostType(GhostType.Previous);
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
    slideToRightController = AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    slideToLeftController = AnimationController(vsync: this, duration: Duration(milliseconds: 200));
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
        position: Tween<Offset>(begin: const Offset(0.0, 0.0), end: const Offset(1.0, 0.0)).animate(slideToRightController),
      );
      child = SlideTransition(
        child: child,
        position: Tween<Offset>(begin: const Offset(0.0, 0.0), end: const Offset(-1.0, 0.0)).animate(slideToLeftController),
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
          child: DragTarget<Widget>(
            builder: (BuildContext context, List<Widget?> candidateData, List<dynamic> rejectedData) {
              return SizedBox();
              // return ColoredBox(color: Colors.grey.withAlpha(128), child: SizedBox());  // for debug :)
            },
            onWillAccept: (Widget? toAccept) {
              if (toAccept == null) return false;
              onEventHit(this, toAccept);
              return true;
            },
            onAccept: (Widget accepted) {},
            onLeave: (Object? leaving) {},
          ),
        ),
      ];

      /// insert or append a ghost/clone view
      if (ghostType != GhostType.None) {
        double spacing = element.parent.widget.spacing;
        double width = element.parent.anyElementSize.width;
        bool isFrontGhost = ghostType == GhostType.Previous;
        double left = isFrontGhost ? -width - spacing : width + spacing;
        SortableElement sibling = isFrontGhost ? element.previousToMe : element.nextToMe;
        children.insert(isFrontGhost ? 0 : children.length, Positioned(top: 0, bottom: 0, left: left, child: sibling.view));
      }
      return Stack(clipBehavior: Clip.none, children: children);
    }

    return _capacityAnimate(_capacityHit(element.view, widget.onEventHit));
  }
}

/// Data or Relation Model
class SortableElement {
  SortableElement(this.view, this.originalIndex);

  /// The caller's view
  final Widget view;

  /// The caller's children index, the most original index
  final int originalIndex;

  /// The [SortableItem] widget i'm binding to
  late SortableItem widget;

  /// The [SortableItemState] widget i'm binding to, corresponding to this [widget]
  late SortableItemState state;

  /// The [SortableWrapState] context/state i'm staying in
  late SortableWrapState parent;

  /// Element index before dragging start
  late int preservedIndex;

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

typedef OnEventHit = void Function(SortableItemState state, Widget accept);
