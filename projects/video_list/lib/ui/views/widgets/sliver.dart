import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:video_list/ui/views/rendering/sliver_multi_box_adaptor.dart';

/// A base class for sliver that have multiple box children.
///
/// Helps subclasses build their children lazily using a [SliverChildDelegate].
///
/// The widgets returned by the [delegate] are cached and the delegate is only
/// consulted again if it changes and the new delegate's
/// [SliverChildDelegate.shouldRebuild] method returns true.
abstract class SliverMultiBoxAdaptorWidget2 extends SliverWithKeepAliveWidget {
  /// Initializes fields for subclasses.
  const SliverMultiBoxAdaptorWidget2({
    Key key,
    this.delegate,
  })  : assert(delegate != null),
        super(key: key);

  /// {@template flutter.widgets.sliverMultiBoxAdaptor.delegate}
  /// The delegate that provides the children for this widget.
  ///
  /// The children are constructed lazily using this delegate to avoid creating
  /// more children than are visible through the [Viewport].
  ///
  /// See also:
  ///
  ///  * [SliverChildBuilderDelegate] and [SliverChildListDelegate], which are
  ///    commonly used subclasses of [SliverChildDelegate] that use a builder
  ///    callback and an explicit child list, respectively.
  /// {@endtemplate}
  final SliverChildDelegate delegate;

  @override
  SliverMultiBoxAdaptorElement2 createElement() =>
      SliverMultiBoxAdaptorElement2(this);

  @override
  RenderSliverMultiBoxAdaptor2 createRenderObject(BuildContext context);

  /// Returns an estimate of the max scroll extent for all the children.
  ///
  /// Subclasses should override this function if they have additional
  /// information about their max scroll extent.
  ///
  /// This is used by [SliverMultiBoxAdaptorElement] to implement part of the
  /// [RenderSliverBoxChildManager] API.
  ///
  /// The default implementation defers to [delegate] via its
  /// [SliverChildDelegate.estimateMaxScrollOffset] method.
  double estimateMaxScrollOffset(
    SliverConstraints constraints,
    int firstIndex,
    int lastIndex,
    double leadingScrollOffset,
    double trailingScrollOffset,
  ) {
    assert(lastIndex >= firstIndex);
    return delegate.estimateMaxScrollOffset(
      firstIndex,
      lastIndex,
      leadingScrollOffset,
      trailingScrollOffset,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
        .add(DiagnosticsProperty<SliverChildDelegate>('delegate', delegate));
  }
}

/// An element that lazily builds children for a [SliverMultiBoxAdaptorWidget].
///
/// Implements [RenderSliverBoxChildManager], which lets this element manage
/// the children of subclasses of [RenderSliverMultiBoxAdaptor].
class SliverMultiBoxAdaptorElement2 extends RenderObjectElement
    implements RenderSliverBoxChildManager {
  /// Creates an element that lazily builds children for the given widget.
  ///
  /// If `replaceMovedChildren` is set to true, a new child is proactively
  /// inflate for the index that was previously occupied by a child that moved
  /// to a new index. The layout offset of the moved child is copied over to the
  /// new child. RenderObjects, that depend on the layout offset of existing
  /// children during [RenderObject.performLayout] should set this to true
  /// (example: [RenderSliverList]). For RenderObjects that figure out the
  /// layout offset of their children without looking at the layout offset of
  /// existing children this should be set to false (example:
  /// [RenderSliverFixedExtentList]) to avoid inflating unnecessary children.
  SliverMultiBoxAdaptorElement2(SliverMultiBoxAdaptorWidget2 widget,
      {bool replaceMovedChildren = false})
      : _replaceMovedChildren = replaceMovedChildren,
        super(widget);

  final bool _replaceMovedChildren;

  @override
  SliverMultiBoxAdaptorWidget2 get widget =>
      super.widget as SliverMultiBoxAdaptorWidget2;

  @override
  RenderSliverMultiBoxAdaptor2 get renderObject =>
      super.renderObject as RenderSliverMultiBoxAdaptor2;

  @override
  void update(covariant SliverMultiBoxAdaptorWidget2 newWidget) {
    final SliverMultiBoxAdaptorWidget2 oldWidget = widget;
    super.update(newWidget);
    final SliverChildDelegate newDelegate = newWidget.delegate;
    final SliverChildDelegate oldDelegate = oldWidget.delegate;
    if (newDelegate != oldDelegate &&
        (newDelegate.runtimeType != oldDelegate.runtimeType ||
            newDelegate.shouldRebuild(oldDelegate))) performRebuild();
  }

  final SplayTreeMap<int, Element> _childElements =
      SplayTreeMap<int, Element>();
  RenderBox _currentBeforeChild;

  @override
  void performRebuild() {
    super.performRebuild();
    _currentBeforeChild = null;
    assert(_currentlyUpdatingChildIndex == null);
    try {
      final SplayTreeMap<int, Element> newChildren =
          SplayTreeMap<int, Element>();
      final Map<int, double> indexToLayoutOffset = HashMap<int, double>();

      void processElement(int index) {
        _currentlyUpdatingChildIndex = index;
        if (_childElements[index] != null &&
            _childElements[index] != newChildren[index]) {
          // This index has an old child that isn't used anywhere and should be deactivated.
          _childElements[index] =
              updateChild(_childElements[index], null, index);
        }
        final Element newChild =
            updateChild(newChildren[index], _build(index), index);
        if (newChild != null) {
          _childElements[index] = newChild;
          final SliverMultiBoxAdaptorParentData2 parentData = newChild
              .renderObject.parentData as SliverMultiBoxAdaptorParentData2;
          if (index == 0) {
            parentData.layoutOffset = 0.0;
          } else if (indexToLayoutOffset.containsKey(index)) {
            parentData.layoutOffset = indexToLayoutOffset[index];
          }
          if (!parentData.keptAlive)
            _currentBeforeChild = newChild.renderObject as RenderBox;
        } else {
          _childElements.remove(index);
          _sameIndexCache.remove(index);
        }
      }

      for (final int index in _childElements.keys.toList()) {
        final Key key = _childElements[index].widget.key;
        final int newIndex =
            key == null ? null : widget.delegate.findIndexByKey(key);
        final SliverMultiBoxAdaptorParentData2 childParentData =
            _childElements[index].renderObject?.parentData
                as SliverMultiBoxAdaptorParentData2;

        if (childParentData != null && childParentData.layoutOffset != null)
          indexToLayoutOffset[index] = childParentData.layoutOffset;

        if (newIndex != null && newIndex != index) {
          // The layout offset of the child being moved is no longer accurate.
          if (childParentData != null) childParentData.layoutOffset = null;

          newChildren[newIndex] = _childElements[index];
          if (_replaceMovedChildren) {
            // We need to make sure the original index gets processed.
            newChildren.putIfAbsent(index, () => null);
          }
          // We do not want the remapped child to get deactivated during processElement.
          _childElements.remove(index);
          _sameIndexCache.remove(index);
        } else {
          newChildren.putIfAbsent(index, () => _childElements[index]);
        }
      }

      renderObject.debugChildIntegrityEnabled =
          false; // Moving children will temporary violate the integrity.
      newChildren.keys.forEach(processElement);
      if (_didUnderflow) {
        final int lastKey = _childElements.lastKey() ?? -1;
        final int rightBoundary = lastKey + 1;
        newChildren[rightBoundary] = _childElements[rightBoundary];
        processElement(rightBoundary);
      }
    } finally {
      _currentlyUpdatingChildIndex = null;
      renderObject.debugChildIntegrityEnabled = true;
    }
  }

  Widget _build(int index) {
    return widget.delegate.build(this, index);
  }


  int _getSameIndex(int index) {
    SliverChildDelegate delegate = widget.delegate;

    if (delegate is SliverChildBuilderDelegateWithSameIndex) {
      Map<int, int> sameIndexMap = delegate.findSameIndex();

      if (sameIndexMap == null)
        return null;

      int sameIndex = sameIndexMap[index];

      if (sameIndex == null) {
        for (int key in sameIndexMap.keys) {
          if (sameIndexMap[key] == index) {
            sameIndex = key;
            break;
          }
        }
      }

      if (sameIndex == null ||
          sameIndex < 0 ||
          sameIndex >= childCount ||
          sameIndex == index) return null;
      return sameIndex;
    }

    return null;
  }

  Map<int, SameIndexRenderObject> _sameIndexCache = {};

  @override
  void createChild(int index, {RenderBox after}) {
    assert(_currentlyUpdatingChildIndex == null);
    print("wcc##createChild:::::index: $index");
    owner.buildScope(this, () {
      final bool insertFirst = after == null;
      assert(insertFirst || _childElements[index - 1] != null);
      _currentBeforeChild = insertFirst
          ? null
          : _sameIndexCache[index - 1] ??
              (_childElements[index - 1].renderObject as RenderBox);
      Element newChild;
      try {
        _currentlyUpdatingChildIndex = index;
        final int sameIndex = _getSameIndex(index);
        final Widget newWidget = _build(index);
        //newChild = updateChild(_childElements[index], newWidget, index);
        if (sameIndex == null) {
          newChild = updateChild(_childElements[index], newWidget, index);
        } else {
          Element oldElement = _childElements[index] ?? _childElements[sameIndex];

          if (oldElement != null && Widget.canUpdate(oldElement.widget, newWidget)) {
            forgetChild(oldElement);
            deactivateChild(oldElement);
            owner.inactiveElements.remove(oldElement);
            oldElement.activateWithParent(this, index);
          }

          newChild = updateChild(oldElement, newWidget, index);
        }

      } finally {
        _currentlyUpdatingChildIndex = null;
      }
      if (newChild != null) {
        _childElements[index] = newChild;
      } else {
        _childElements.remove(index);
        _sameIndexCache.remove(index);
      }
    });
  }

  @override
  Element updateChild(Element child, Widget newWidget, dynamic newSlot) {
    final SliverMultiBoxAdaptorParentData2 oldParentData =
        child?.renderObject?.parentData as SliverMultiBoxAdaptorParentData2;
    final Element newChild = super.updateChild(child, newWidget, newSlot);
    final SliverMultiBoxAdaptorParentData2 newParentData =
        newChild?.renderObject?.parentData as SliverMultiBoxAdaptorParentData2;

    // Preserve the old layoutOffset if the renderObject was swapped out.
    if (oldParentData != newParentData &&
        oldParentData != null &&
        newParentData != null) {
      print("updateChild1 => oldParentData: ${oldParentData.layoutOffset}");
      newParentData.layoutOffset = oldParentData.layoutOffset;
    } else {
      /*if (_currentlyUpdatingChildIndex == 0)
        newParentData.layoutOffset = 0;*/
      print("updateChild2 => oldParentData: ${oldParentData?.layoutOffset}");
    }
    return newChild;
  }

  @override
  void forgetChild(Element child) {
    assert(child != null);
    assert(child.slot != null);
    assert(_childElements.containsKey(child.slot));
    _childElements.remove(child.slot);
    _sameIndexCache.remove(child.slot);
    super.forgetChild(child);
  }

  @override
  void removeChild(RenderBox child) {
    final int index = renderObject.indexOf(child);

    print("wcc##removeChild:::::index: $index");

    assert(_currentlyUpdatingChildIndex == null);
    assert(index >= 0);
    owner.buildScope(this, () {
      assert(_childElements.containsKey(index));
      try {
        _currentlyUpdatingChildIndex = index;
        final Element result = updateChild(_childElements[index], null, index);
        assert(result == null);
      } finally {
        _currentlyUpdatingChildIndex = null;
      }
      _childElements.remove(index);
      _sameIndexCache.remove(index);
      assert(!_childElements.containsKey(index));
    });
  }

  static double _extrapolateMaxScrollOffset(
    int firstIndex,
    int lastIndex,
    double leadingScrollOffset,
    double trailingScrollOffset,
    int childCount,
  ) {
    if (lastIndex == childCount - 1) return trailingScrollOffset;
    final int reifiedCount = lastIndex - firstIndex + 1;
    final double averageExtent =
        (trailingScrollOffset - leadingScrollOffset) / reifiedCount;
    final int remainingCount = childCount - lastIndex - 1;
    return trailingScrollOffset + averageExtent * remainingCount;
  }

  @override
  double estimateMaxScrollOffset(
    SliverConstraints constraints, {
    int firstIndex,
    int lastIndex,
    double leadingScrollOffset,
    double trailingScrollOffset,
  }) {
    final int childCount = estimatedChildCount;
    if (childCount == null) return double.infinity;
    return widget.estimateMaxScrollOffset(
          constraints,
          firstIndex,
          lastIndex,
          leadingScrollOffset,
          trailingScrollOffset,
        ) ??
        _extrapolateMaxScrollOffset(
          firstIndex,
          lastIndex,
          leadingScrollOffset,
          trailingScrollOffset,
          childCount,
        );
  }

  /// The best available estimate of [childCount], or null if no estimate is available.
  ///
  /// This differs from [childCount] in that [childCount] never returns null (and must
  /// not be accessed if the child count is not yet available, meaning the [createChild]
  /// method has not been provided an index that does not create a child).
  ///
  /// See also:
  ///
  ///  * [SliverChildDelegate.estimatedChildCount], to which this getter defers.
  int get estimatedChildCount => widget.delegate.estimatedChildCount;

  @override
  int get childCount {
    int result = estimatedChildCount;
    if (result == null) {
      // Since childCount was called, we know that we reached the end of
      // the list (as in, _build return null once), so we know that the
      // list is finite.
      // Let's do an open-ended binary search to find the end of the list
      // manually.
      int lo = 0;
      int hi = 1;
      const int max = kIsWeb
          ? 9007199254740992 // max safe integer on JS (from 0 to this number x != x+1)
          : ((1 << 63) - 1);
      while (_build(hi - 1) != null) {
        lo = hi - 1;
        if (hi < max ~/ 2) {
          hi *= 2;
        } else if (hi < max) {
          hi = max;
        } else {
          throw FlutterError(
              'Could not find the number of children in ${widget.delegate}.\n'
              'The childCount getter was called (implying that the delegate\'s builder returned null '
              'for a positive index), but even building the child with index $hi (the maximum '
              'possible integer) did not return null. Consider implementing childCount to avoid '
              'the cost of searching for the final child.');
        }
      }
      while (hi - lo > 1) {
        final int mid = (hi - lo) ~/ 2 + lo;
        if (_build(mid - 1) == null) {
          hi = mid;
        } else {
          lo = mid;
        }
      }
      result = lo;
    }
    return result;
  }

  @override
  void didStartLayout() {
    assert(debugAssertChildListLocked());
  }

  @override
  void didFinishLayout() {
    assert(debugAssertChildListLocked());
    final int firstIndex = _childElements.firstKey() ?? 0;
    final int lastIndex = _childElements.lastKey() ?? 0;
    widget.delegate.didFinishLayout(firstIndex, lastIndex);
  }

  int _currentlyUpdatingChildIndex;

  @override
  bool debugAssertChildListLocked() {
    assert(_currentlyUpdatingChildIndex == null);
    return true;
  }

  @override
  void didAdoptChild(RenderBox child) {
    assert(_currentlyUpdatingChildIndex != null);
    final SliverMultiBoxAdaptorParentData2 childParentData =
        child.parentData as SliverMultiBoxAdaptorParentData2;
    childParentData.index = _currentlyUpdatingChildIndex;
  }

  bool _didUnderflow = false;

  @override
  void setDidUnderflow(bool value) {
    _didUnderflow = value;
  }

  @override
  void insertRenderObjectChild(covariant RenderObject child, int slot) {
    assert(slot != null);
    assert(_currentlyUpdatingChildIndex == slot);
    assert(renderObject.debugValidateChild(child));
    renderObject.insert(child as RenderBox, after: _currentBeforeChild);
    assert(() {
      final SliverMultiBoxAdaptorParentData2 childParentData =
          child.parentData as SliverMultiBoxAdaptorParentData2;
      assert(slot == childParentData.index);
      return true;
    }());
  }

  @override
  void moveRenderObjectChild(
      covariant RenderObject child, int oldSlot, int newSlot) {
    assert(newSlot != null);
    assert(_currentlyUpdatingChildIndex == newSlot);
    renderObject.move(child as RenderBox, after: _currentBeforeChild);
  }

  @override
  void removeRenderObjectChild(covariant RenderObject child, int slot) {
    assert(_currentlyUpdatingChildIndex != null);
    renderObject.remove(child as RenderBox);
  }

  @override
  void visitChildren(ElementVisitor visitor) {
    // The toList() is to make a copy so that the underlying list can be modified by
    // the visitor:
    assert(!_childElements.values.any((Element child) => child == null));
    _childElements.values.cast<Element>().toList().forEach(visitor);
  }

  @override
  void debugVisitOnstageChildren(ElementVisitor visitor) {
    _childElements.values.cast<Element>().where((Element child) {
      final SliverMultiBoxAdaptorParentData2 parentData =
          child.renderObject.parentData as SliverMultiBoxAdaptorParentData2;
      double itemExtent;
      switch (renderObject.constraints.axis) {
        case Axis.horizontal:
          itemExtent = child.renderObject.paintBounds.width;
          break;
        case Axis.vertical:
          itemExtent = child.renderObject.paintBounds.height;
          break;
      }

      return parentData.layoutOffset != null &&
          parentData.layoutOffset <
              renderObject.constraints.scrollOffset +
                  renderObject.constraints.remainingPaintExtent &&
          parentData.layoutOffset + itemExtent >
              renderObject.constraints.scrollOffset;
    }).forEach(visitor);
  }
}

typedef ChildSameIndexGetter = Map<int, int> Function();

class SliverChildBuilderDelegateWithSameIndex
    extends SliverChildBuilderDelegate {
  const SliverChildBuilderDelegateWithSameIndex(
    NullableIndexedWidgetBuilder builder, {
    ChildIndexGetter findChildIndexCallback,
    this.findChildSameIndexCallback,
    int childCount,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
  }) : super(
          builder,
          findChildIndexCallback: findChildIndexCallback,
          childCount: childCount,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
          addSemanticIndexes: addSemanticIndexes,
        );

  final ChildSameIndexGetter findChildSameIndexCallback;

  Map<int, int> findSameIndex() {
    if (findChildSameIndexCallback == null) return null;

    return findChildSameIndexCallback();
  }
}
