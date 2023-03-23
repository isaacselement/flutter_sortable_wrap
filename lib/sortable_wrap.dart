import 'package:flutter/material.dart';

import 'package:flutter_sortable_wrap/sortable_item.dart';
import 'package:flutter_sortable_wrap/sortable_utils.dart';

class SortableWrap extends StatefulWidget {
  const SortableWrap({
    Key? key,
    required this.children,
    required this.onSorted,
    this.onSortStart,
    this.onSortCancel,
    this.spacing = 0.0,
    this.runSpacing = 0.0,
  }) : super(key: key);

  final List<Widget> children;

  /// Events
  final void Function(int oldIndex, int newIndex) onSorted;
  final void Function(int index)? onSortStart;
  final void Function(int index)? onSortCancel;

  /// TODO ... To complete the remaining properties that need to pass to [Wrap] ...
  /// Properties pass to the official [Wrap]
  final double spacing;
  final double runSpacing;

  @override
  State<SortableWrap> createState() => SortableWrapState();
}

class SortableWrapState extends State<SortableWrap> {
  /// BuildContexts & Size & Count Properties, use them after determined
  late BuildContext wrapperContext;
  late BuildContext anyElementContext;
  late Size wrapperSize;
  late Size anyElementSize;
  late int elementCountPerRow;
  late int elementCountPerColumn;

  /// Dragging & Index Properties
  SortableElement? draggingElement;

  bool get isDragging => draggingElement != null;

  bool isDraggingMe(SortableElement e) => draggingElement == e;

  /// Cached array that keep the index status before swap on rolling
  List<SortableElement> preservedElements = [];

  /// Cached array that representing the realtime swap index when a drag is under way
  List<SortableElement> animationElements = [];

  @override
  void initState() {
    super.initState();
    initCachedWithChildren();
  }

  @override
  void didUpdateWidget(covariant SortableWrap old) {
    super.didUpdateWidget(old);
    initCachedWithChildren();
  }

  void initCachedWithChildren() {
    preservedElements.clear();
    for (int i = 0; i < widget.children.length; i++) {
      preservedElements.add(SortableElement(widget.children[i], i)..parent = this);
    }
    syncPreservedCacheIndexes();

    animationElements.clear();
    animationElements.addAll(preservedElements);
  }

  void syncPreservedCacheIndexes() {
    for (int i = 0; i < preservedElements.length; i++) {
      preservedElements[i].preservedIndex = i;
    }
  }

  @override
  void dispose() {
    super.dispose();

    /// clear cached
    draggingElement = null;
    preservedElements.clear();
    animationElements.clear();
  }

  @override
  Widget build(BuildContext context) {
    Widget builder = Builder(
      builder: (context) {
        wrapperContext = context;
        return Wrap(
          spacing: widget.spacing,
          runSpacing: widget.runSpacing,
          children: animationElements.map((e) => enclosedWithDraggable(e)).toList(),
        );
      },
    );
    // return ColoredBox(color: Colors.grey, child: builder); // for debug :)
    Widget clip(Widget child) => ClipRect(child: child);
    return clip(builder);
  }

  /// Wrapped with draggable widget
  Widget enclosedWithDraggable(SortableElement element) {
    int index = preservedElements.indexOf(element);

    /// A. Return the widget in dragging mode
    if (isDragging) {
      if (isDraggingMe(element)) {
        return IgnorePointer(ignoring: true, child: Opacity(opacity: 0.2, child: element.view));
      } else {
        return SortableItem(key: ValueKey(index), element: element, onEventHit: eventDoRollingInDragging);
      }
    }

    /// B. Return the widget in idle mode
    void safeInvoke(VoidCallback fn) {
      try {
        fn();
      } catch (e, s) {
        iDebugLog('❗👠🩸 ERROR! please check it out: $e, $s');
      }
    }

    /// Drag finish (end/complete/canceled) callback
    void onDragFinished() {
      int newIndex = element.visibleIndex;
      int oldIndex = element.preservedIndex;
      setState(() {
        /// synchronize cache preserved elements with animation elements
        preservedElements.clear();
        preservedElements.addAll(animationElements);
        syncPreservedCacheIndexes();

        draggingElement = null;
      });

      /// invoke caller's callback
      safeInvoke(() => oldIndex != newIndex ? widget.onSorted(oldIndex, newIndex) : widget.onSortCancel?.call(oldIndex));
    }

    /// Drag started callback
    void onDragStarted() {
      iDebugLog('Drag start index: $index');
      iDebugLog('Context\'s size: ${wrapperContext.size}');
      iDebugLog('Element\'s size: ${anyElementContext.size}');

      /// calculate the row & column & count/size at this moment, for window may resizeable when running as Desktop App
      assert(wrapperContext.size != null, 'Wrap\'s size cannot be determined!');
      assert(anyElementContext.size != null, 'Element\'s size cannot be determined!');
      wrapperSize = wrapperContext.size!;
      anyElementSize = anyElementContext.size!;
      double width = wrapperSize.width;
      double height = wrapperSize.height;
      double ew = anyElementSize.width;
      double eh = anyElementSize.height;
      elementCountPerRow = width ~/ ew;
      elementCountPerColumn = height ~/ eh;
      iDebugLog('[START] count on per row: $elementCountPerRow, count on per column: $elementCountPerColumn');
      while (elementCountPerRow * ew + (elementCountPerRow - 1) * widget.spacing > width) {
        elementCountPerRow--;
      }
      while (elementCountPerColumn * eh + (elementCountPerColumn - 1) * widget.runSpacing > height) {
        elementCountPerColumn--;
      }
      iDebugLog('[FINAL] count on per row: $elementCountPerRow, count on per column: $elementCountPerColumn');

      /// set current dragging element
      setState(() {
        draggingElement = element;
      });

      /// invoke caller's callback
      safeInvoke(() => widget.onSortStart?.call(element.preservedIndex));
    }

    /// Drag end callback
    void onDragEnd(DraggableDetails details) {
      onDragFinished();
    }

    /// Drag complete callback
    void onDragCompleted() {
      onDragFinished();
    }

    /// Drag canceled callback
    void onDraggableCanceled(Velocity velocity, Offset offset) {
      onDragFinished();
    }

    return Draggable<Widget>(
      /// A key is needed, for keeping DraggableState when inner setState called.
      key: ValueKey(index),
      data: element.view,
      child: Builder(builder: (context) {
        anyElementContext = context;
        return element.view;
      }),
      feedback: Transform(
        transform: new Matrix4.rotationZ(0),
        alignment: FractionalOffset.topLeft,
        child: Material(
          elevation: 18.0,
          child: element.view,
          // child: Card(child: element.view),
          shadowColor: Colors.transparent,
          // shadowColor: Colors.grey,
          color: Colors.transparent,
          borderRadius: BorderRadius.zero,
        ),
      ),
      childWhenDragging: IgnorePointer(ignoring: true, child: Opacity(opacity: 0.2, child: element.view)),
      onDragEnd: onDragEnd,
      onDragStarted: onDragStarted,
      onDragCompleted: onDragCompleted,
      onDraggableCanceled: onDraggableCanceled,
    );
  }

  /// Events
  void eventDoRollingInDragging(SortableItemState beHitItemState, Widget draggingWidget) {
    assert(draggingElement != null, 'Dragging status is a mess now, please check it out.');
    assert(draggingElement?.view == draggingWidget, 'Got a different dragging view, please check it out.');

    SortableElement dragging = draggingElement!;
    SortableElement element = beHitItemState.widget.element;

    int toIndex = animationElements.indexOf(element);
    int draggingIndex = animationElements.indexOf(dragging);
    bool isDraggingInSameRow = toIndex ~/ elementCountPerRow == draggingIndex ~/ elementCountPerRow;

    /// To lower index means user dragging to left, user dragging to left or top, the hit target should animate to right
    bool isDraggingToLowerIndex = toIndex < draggingIndex;
    int i = isDraggingToLowerIndex ? draggingIndex - 1 : draggingIndex + 1;
    for (; isDraggingToLowerIndex ? i >= toIndex : i <= toIndex; isDraggingToLowerIndex ? i-- : i++) {
      SortableElement e = animationElements[i];

      /// Swap the index in cached data
      int sourceIndex = i;
      int destinationIndex = isDraggingToLowerIndex ? i + 1 : i - 1;
      animationElements.swap(sourceIndex, destinationIndex);

      /// Handle animation by corresponding item's state
      SortableItemState itemState = e.state;
      itemState.sourceIndex = sourceIndex;
      itemState.destinationIndex = destinationIndex;
      itemState.startAnimation(isDraggingInSameRow);
    }

    /// Make sure you see the right thing on the right position
    setState(() {});
  }
}
