import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Parent data structure used by [RenderSliverMultiBoxAdaptor].
class SliverMultiBoxAdaptorParentData2 extends SliverLogicalParentData
    with ContainerParentDataMixin<RenderBox>, KeepAliveParentDataMixin {
  /// The index of this child according to the [RenderSliverBoxChildManager].
  int index;

  @override
  bool get keptAlive => _keptAlive;
  bool _keptAlive = false;

  @override
  String toString() =>
      'index=$index; ${keepAlive == true ? "keepAlive; " : ""}${super.toString()}';
}

/// A sliver with multiple box children.
///
/// [RenderSliverMultiBoxAdaptor] is a base class for slivers that have multiple
/// box children. The children are managed by a [RenderSliverBoxChildManager],
/// which lets subclasses create children lazily during layout. Typically
/// subclasses will create only those children that are actually needed to fill
/// the [SliverConstraints.remainingPaintExtent].
///
/// The contract for adding and removing children from this render object is
/// more strict than for normal render objects:
///
/// * Children can be removed except during a layout pass if they have already
///   been laid out during that layout pass.
/// * Children cannot be added except during a call to [childManager], and
///   then only if there is no child corresponding to that index (or the child
///   child corresponding to that index was first removed).
///
/// See also:
///
///  * [RenderSliverToBoxAdapter], which has a single box child.
///  * [RenderSliverList], which places its children in a linear
///    array.
///  * [RenderSliverFixedExtentList], which places its children in a linear
///    array with a fixed extent in the main axis.
///  * [RenderSliverGrid], which places its children in arbitrary positions.
abstract class RenderSliverMultiBoxAdaptor2 extends RenderSliver
    with
        ContainerRenderObjectMixin<RenderBox, SliverMultiBoxAdaptorParentData2>,
        RenderSliverHelpers,
        RenderSliverWithKeepAliveMixin {
  /// Creates a sliver with multiple box children.
  ///
  /// The [childManager] argument must not be null.
  RenderSliverMultiBoxAdaptor2({
    RenderSliverBoxChildManager childManager,
    bool loop = false,
  })  : assert(childManager != null),
        _childManager = childManager,
        assert(loop != null),
        _loop = loop {
    assert(() {
      _debugDanglingKeepAlives = <RenderBox>[];
      return true;
    }());
  }

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! SliverMultiBoxAdaptorParentData2)
      child.parentData = SliverMultiBoxAdaptorParentData2();
  }

  /// The delegate that manages the children of this object.
  ///
  /// Rather than having a concrete list of children, a
  /// [RenderSliverMultiBoxAdaptor] uses a [RenderSliverBoxChildManager] to
  /// create children during layout in order to fill the
  /// [SliverConstraints.remainingPaintExtent].
  @protected
  RenderSliverBoxChildManager get childManager => _childManager;
  final RenderSliverBoxChildManager _childManager;

  bool _loop;
  bool get loop => _loop;
  set loop(bool value) {
    assert(value != null);
    if (_loop == value)
      return;
    _loop = value;
    markNeedsLayout();
  }

  /// The nodes being kept alive despite not being visible.
  final Map<int, RenderBox> _keepAliveBucket = <int, RenderBox>{};

  List<RenderBox> _debugDanglingKeepAlives;

  /// Indicates whether integrity check is enabled.
  ///
  /// Setting this property to true will immediately perform an integrity check.
  ///
  /// The integrity check consists of:
  ///
  /// 1. Verify that the children index in childList is in ascending order.
  /// 2. Verify that there is no dangling keepalive child as the result of [move].
  bool get debugChildIntegrityEnabled => _debugChildIntegrityEnabled;
  bool _debugChildIntegrityEnabled = true;
  set debugChildIntegrityEnabled(bool enabled) {
    assert(enabled != null);
    assert(() {
      _debugChildIntegrityEnabled = enabled;
      return _debugVerifyChildOrder() &&
          (!_debugChildIntegrityEnabled || _debugDanglingKeepAlives.isEmpty);
    }());
  }

  @override
  void adoptChild(RenderObject child) {
    super.adoptChild(child);
    final SliverMultiBoxAdaptorParentData2 childParentData =
    child.parentData as SliverMultiBoxAdaptorParentData2;
    if (child is SameIndexRenderObject) {
      final SliverMultiBoxAdaptorParentData2 realChildParentData =
      child.renderBox.parentData as SliverMultiBoxAdaptorParentData2;

      childParentData.keepAlive = realChildParentData.keepAlive;
    }

    if (!childParentData._keptAlive)
      childManager.didAdoptChild(child as RenderBox);
  }

  bool _debugAssertChildListLocked() =>
      childManager.debugAssertChildListLocked();

  /// Verify that the child list index is in strictly increasing order.
  ///
  /// This has no effect in release builds.
  bool _debugVerifyChildOrder() {
    if (_debugChildIntegrityEnabled) {
      RenderBox child = firstChild;
      int index;
      while (child != null) {
        index = indexOf(child);
        child = childAfter(child);
        assert(child == null || indexOf(child) > index);
      }
    }
    return true;
  }

  @override
  void insert(RenderBox child, {RenderBox after}) {
    assert(!_keepAliveBucket.containsValue(child));
    super.insert(child, after: after);
    assert(firstChild != null);
    assert(_debugVerifyChildOrder());
    print("wuchaochao##log => insert child => index:${(child.parentData as SliverMultiBoxAdaptorParentData2).index}  child.hashcode:${child.hashCode} after.hashcode:${after?.hashCode}");
  }

  @override
  void move(RenderBox child, {RenderBox after}) {
    // There are two scenarios:
    //
    // 1. The child is not keptAlive.
    // The child is in the childList maintained by ContainerRenderObjectMixin.
    // We can call super.move and update parentData with the new slot.
    //
    // 2. The child is keptAlive.
    // In this case, the child is no longer in the childList but might be stored in
    // [_keepAliveBucket]. We need to update the location of the child in the bucket.
    final SliverMultiBoxAdaptorParentData2 childParentData =
        child.parentData as SliverMultiBoxAdaptorParentData2;
    if (!childParentData.keptAlive) {
      super.move(child, after: after);
      childManager.didAdoptChild(child); // updates the slot in the parentData
      // Its slot may change even if super.move does not change the position.
      // In this case, we still want to mark as needs layout.
      markNeedsLayout();
    } else {
      // If the child in the bucket is not current child, that means someone has
      // already moved and replaced current child, and we cannot remove this child.
      if (_keepAliveBucket[childParentData.index] == child) {
        _keepAliveBucket.remove(childParentData.index);
      }
      assert(() {
        _debugDanglingKeepAlives.remove(child);
        return true;
      }());
      // Update the slot and reinsert back to _keepAliveBucket in the new slot.
      childManager.didAdoptChild(child);
      // If there is an existing child in the new slot, that mean that child will
      // be moved to other index. In other cases, the existing child should have been
      // removed by updateChild. Thus, it is ok to overwrite it.
      assert(() {
        if (_keepAliveBucket.containsKey(childParentData.index))
          _debugDanglingKeepAlives.add(_keepAliveBucket[childParentData.index]);
        return true;
      }());
      _keepAliveBucket[childParentData.index] = child;
    }
    print("wuchaochao##log => move child => index:${(child.parentData as SliverMultiBoxAdaptorParentData2).index}  child.hashcode:${child.hashCode} after.hashcode:${after?.hashCode}");
  }

  @override
  void remove(RenderBox child) {
     final SliverMultiBoxAdaptorParentData2 childParentData =
        child.parentData as SliverMultiBoxAdaptorParentData2;
     print("wuchaochao##log => remove child => index:${childParentData.index}  child.hashcode:${child.hashCode}  childParentData._keptAlive:${childParentData._keptAlive}");

     if (!childParentData._keptAlive) {
      super.remove(child);
      return;
    }
    assert(_keepAliveBucket[childParentData.index] == child);
    assert(() {
      _debugDanglingKeepAlives.remove(child);
      return true;
    }());
    _keepAliveBucket.remove(childParentData.index);
    dropChild(child);

  }

  @override
  void removeAll() {
    super.removeAll();
    _keepAliveBucket.values.forEach(dropChild);
    _keepAliveBucket.clear();
  }

  void _createOrObtainChild(int index, {RenderBox after}) {
    invokeLayoutCallback<SliverConstraints>((SliverConstraints constraints) {
      assert(constraints == this.constraints);
      if (_keepAliveBucket.containsKey(index)) {
        final RenderBox child = _keepAliveBucket.remove(index);
        final SliverMultiBoxAdaptorParentData2 childParentData =
            child.parentData as SliverMultiBoxAdaptorParentData2;
        assert(childParentData._keptAlive);
        dropChild(child);
        child.parentData = childParentData;
        insert(child, after: after);
        childParentData._keptAlive = false;
      } else {
        _childManager.createChild(index, after: after);
      }
    });
  }

  void _destroyOrCacheChild(RenderBox child) {
    final SliverMultiBoxAdaptorParentData2 childParentData =
        child.parentData as SliverMultiBoxAdaptorParentData2;
    if (childParentData.keepAlive) {
      assert(!childParentData._keptAlive);
      remove(child);
      _keepAliveBucket[childParentData.index] = child;
      child.parentData = childParentData;
      super.adoptChild(child);
      childParentData._keptAlive = true;
    } else {
      assert(child.parent == this);
      _childManager.removeChild(child);
      assert(child.parent == null);
    }
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    for (final RenderBox child in _keepAliveBucket.values) child.attach(owner);
  }

  @override
  void detach() {
    super.detach();
    for (final RenderBox child in _keepAliveBucket.values) child.detach();
  }

  @override
  void redepthChildren() {
    super.redepthChildren();
    _keepAliveBucket.values.forEach(redepthChild);
  }

  @override
  void visitChildren(RenderObjectVisitor visitor) {
    super.visitChildren(visitor);
    _keepAliveBucket.values.forEach(visitor);
  }

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    super.visitChildren(visitor);
    // Do not visit children in [_keepAliveBucket].
  }

  /// Called during layout to create and add the child with the given index and
  /// scroll offset.
  ///
  /// Calls [RenderSliverBoxChildManager.createChild] to actually create and add
  /// the child if necessary. The child may instead be obtained from a cache;
  /// see [SliverMultiBoxAdaptorParentData2.keepAlive].
  ///
  /// Returns false if there was no cached child and `createChild` did not add
  /// any child, otherwise returns true.
  ///
  /// Does not layout the new child.
  ///
  /// When this is called, there are no visible children, so no children can be
  /// removed during the call to `createChild`. No child should be added during
  /// that call either, except for the one that is created and returned by
  /// `createChild`.
  @protected
  bool addInitialChild({int index = 0, double layoutOffset = 0.0}) {
    assert(_debugAssertChildListLocked());
    assert(firstChild == null);
    _createOrObtainChild(index, after: null);
    if (firstChild != null) {
      assert(firstChild == lastChild);
      assert(indexOf(firstChild) == index);
      final SliverMultiBoxAdaptorParentData2 firstChildParentData =
          firstChild.parentData as SliverMultiBoxAdaptorParentData2;
      firstChildParentData.layoutOffset = layoutOffset;
      return true;
    }
    childManager.setDidUnderflow(true);
    return false;
  }

  /// Called during layout to create, add, and layout the child before
  /// [firstChild].
  ///
  /// Calls [RenderSliverBoxChildManager.createChild] to actually create and add
  /// the child if necessary. The child may instead be obtained from a cache;
  /// see [SliverMultiBoxAdaptorParentData2.keepAlive].
  ///
  /// Returns the new child or null if no child was obtained.
  ///
  /// The child that was previously the first child, as well as any subsequent
  /// children, may be removed by this call if they have not yet been laid out
  /// during this layout pass. No child should be added during that call except
  /// for the one that is created and returned by `createChild`.
  @protected
  RenderBox insertAndLayoutLeadingChild(
    BoxConstraints childConstraints, {
    bool parentUsesSize = false,
  }) {
    assert(_debugAssertChildListLocked());
    final int index = indexOf(firstChild) - 1;
    _createOrObtainChild(index, after: null);
    if (indexOf(firstChild) == index) {
      firstChild.layout(childConstraints, parentUsesSize: parentUsesSize);
      return firstChild;
    }
    childManager.setDidUnderflow(true);
    return null;
  }

  /// Called during layout to create, add, and layout the child after
  /// the given child.
  ///
  /// Calls [RenderSliverBoxChildManager.createChild] to actually create and add
  /// the child if necessary. The child may instead be obtained from a cache;
  /// see [SliverMultiBoxAdaptorParentData2.keepAlive].
  ///
  /// Returns the new child. It is the responsibility of the caller to configure
  /// the child's scroll offset.
  ///
  /// Children after the `after` child may be removed in the process. Only the
  /// new child may be added.
  @protected
  RenderBox insertAndLayoutChild(
    BoxConstraints childConstraints, {
    RenderBox after,
    bool parentUsesSize = false,
  }) {
    assert(_debugAssertChildListLocked());
    assert(after != null);
    final int index = indexOf(after) + 1;
    _createOrObtainChild(index, after: after);
    final RenderBox child = childAfter(after);
    if (child != null && indexOf(child) == index) {
      child.layout(childConstraints, parentUsesSize: parentUsesSize);
      return child;
    }
    childManager.setDidUnderflow(true);
    return null;
  }

  /// Called after layout with the number of children that can be garbage
  /// collected at the head and tail of the child list.
  ///
  /// Children whose [SliverMultiBoxAdaptorParentData2.keepAlive] property is
  /// set to true will be removed to a cache instead of being dropped.
  ///
  /// This method also collects any children that were previously kept alive but
  /// are now no longer necessary. As such, it should be called every time
  /// [performLayout] is run, even if the arguments are both zero.
  @protected
  void collectGarbage(int leadingGarbage, int trailingGarbage) {
    assert(_debugAssertChildListLocked());
    assert(childCount >= leadingGarbage + trailingGarbage);
    invokeLayoutCallback<SliverConstraints>((SliverConstraints constraints) {
      while (leadingGarbage > 0) {
        _destroyOrCacheChild(firstChild);
        leadingGarbage -= 1;
      }
      while (trailingGarbage > 0) {
        _destroyOrCacheChild(lastChild);
        trailingGarbage -= 1;
      }
      // Ask the child manager to remove the children that are no longer being
      // kept alive. (This should cause _keepAliveBucket to change, so we have
      // to prepare our list ahead of time.)
      _keepAliveBucket.values
          .where((RenderBox child) {
            final SliverMultiBoxAdaptorParentData2 childParentData =
                child.parentData as SliverMultiBoxAdaptorParentData2;
            return !childParentData.keepAlive;
          })
          .toList()
          .forEach(_childManager.removeChild);
      assert(_keepAliveBucket.values.where((RenderBox child) {
        final SliverMultiBoxAdaptorParentData2 childParentData =
            child.parentData as SliverMultiBoxAdaptorParentData2;
        return !childParentData.keepAlive;
      }).isEmpty);
    });
  }

  /// Returns the index of the given child, as given by the
  /// [SliverMultiBoxAdaptorParentData2.index] field of the child's [parentData].
  int indexOf(RenderBox child) {
    assert(child != null);
    final SliverMultiBoxAdaptorParentData2 childParentData =
        child.parentData as SliverMultiBoxAdaptorParentData2;
    assert(childParentData.index != null);
    return childParentData.index;
  }

  /// Returns the dimension of the given child in the main axis, as given by the
  /// child's [RenderBox.size] property. This is only valid after layout.
  @protected
  double paintExtentOf(RenderBox child) {
    child = _getRealChild(child);
    print("paintExtentOf => child is SameIndexRenderObject: ${child is SameIndexRenderObject}");
    assert(child != null);
    assert(child.hasSize);
    switch (constraints.axis) {
      case Axis.horizontal:
        return child.size.width;
      case Axis.vertical:
        return child.size.height;
    }
  }

  @override
  bool hitTestChildren(SliverHitTestResult result,
      {double mainAxisPosition, double crossAxisPosition}) {
    RenderBox child = lastChild;
    final BoxHitTestResult boxResult = BoxHitTestResult.wrap(result);
    while (child != null) {
      if (hitTestBoxChild(boxResult, child,
          mainAxisPosition: mainAxisPosition,
          crossAxisPosition: crossAxisPosition)) return true;
      child = childBefore(child);
    }
    return false;
  }

  @override
  double childMainAxisPosition(RenderBox child) {
    return childScrollOffset(child) - constraints.scrollOffset;
  }

  @override
  double childScrollOffset(RenderObject child) {
    assert(child != null);
    assert(child.parent == this);
    final SliverMultiBoxAdaptorParentData2 childParentData =
        child.parentData as SliverMultiBoxAdaptorParentData2;
    return childParentData.layoutOffset;
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    if (_keepAliveBucket.containsKey(indexOf(child))) {
      // It is possible that widgets under kept alive children want to paint
      // themselves. For example, the Material widget tries to paint all
      // InkFeatures under its subtree as long as they are not disposed. In
      // such case, we give it a zero transform to prevent them from painting.
      transform.setZero();
    } else {
      applyPaintTransformForBoxChild(child, transform);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (firstChild == null) return;
    // offset is to the top-left corner, regardless of our axis direction.
    // originOffset gives us the delta from the real origin to the origin in the axis direction.
    Offset mainAxisUnit, crossAxisUnit, originOffset;
    bool addExtent;
    switch (applyGrowthDirectionToAxisDirection(
        constraints.axisDirection, constraints.growthDirection)) {
      case AxisDirection.up:
        mainAxisUnit = const Offset(0.0, -1.0);
        crossAxisUnit = const Offset(1.0, 0.0);
        originOffset = offset + Offset(0.0, geometry.paintExtent);
        addExtent = true;
        break;
      case AxisDirection.right:
        mainAxisUnit = const Offset(1.0, 0.0);
        crossAxisUnit = const Offset(0.0, 1.0);
        originOffset = offset;
        addExtent = false;
        break;
      case AxisDirection.down:
        mainAxisUnit = const Offset(0.0, 1.0);
        crossAxisUnit = const Offset(1.0, 0.0);
        originOffset = offset;
        addExtent = false;
        break;
      case AxisDirection.left:
        mainAxisUnit = const Offset(-1.0, 0.0);
        crossAxisUnit = const Offset(0.0, 1.0);
        originOffset = offset + Offset(geometry.paintExtent, 0.0);
        addExtent = true;
        break;
    }
    print("paint paint paint paint ..........");
    assert(mainAxisUnit != null);
    assert(addExtent != null);
    RenderBox child = firstChild;
    while (child != null) {
      final double mainAxisDelta = childMainAxisPosition(child);
      final double crossAxisDelta = childCrossAxisPosition(child);
      Offset childOffset = Offset(
        originOffset.dx +
            mainAxisUnit.dx * mainAxisDelta +
            crossAxisUnit.dx * crossAxisDelta,
        originOffset.dy +
            mainAxisUnit.dy * mainAxisDelta +
            crossAxisUnit.dy * crossAxisDelta,
      );
      if (addExtent) childOffset += mainAxisUnit * paintExtentOf(child);

      // If the child's visible interval (mainAxisDelta, mainAxisDelta + paintExtentOf(child))
      // does not intersect the paint extent interval (0, constraints.remainingPaintExtent), it's hidden.
      if (mainAxisDelta < constraints.remainingPaintExtent &&
          mainAxisDelta + paintExtentOf(child) > 0) {
        RenderBox realRenderBox = _getRealChild(child);
        print("paint child => realRenderBox is SameIndexRenderObject: ${realRenderBox is SameIndexRenderObject}");
        context.paintChild(realRenderBox, childOffset);
      }

      child = childAfter(child);
    }
    print("paint paint paint paint .......... end end");
  }

  RenderBox _getRealChild(RenderBox child) {
    if (child is SameIndexRenderObject) {
      print("getRealChild => index:${child.index} sameIndex:${child.sameIndex} renderBox:${child.renderBox}");
      return child.renderBox;
    }
    return child;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsNode.message(firstChild != null
        ? 'currently live children: ${indexOf(firstChild)} to ${indexOf(lastChild)}'
        : 'no children current live'));
  }

  /// Asserts that the reified child list is not empty and has a contiguous
  /// sequence of indices.
  ///
  /// Always returns true.
  bool debugAssertChildListIsNonEmptyAndContiguous() {
    assert(() {
      assert(firstChild != null);
      int index = indexOf(firstChild);
      RenderBox child = childAfter(firstChild);
      while (child != null) {
        index += 1;
        assert(indexOf(child) == index);
        child = childAfter(child);
      }
      return true;
    }());
    return true;
  }

  @override
  List<DiagnosticsNode> debugDescribeChildren() {
    final List<DiagnosticsNode> children = <DiagnosticsNode>[];
    if (firstChild != null) {
      RenderBox child = firstChild;
      while (true) {
        final SliverMultiBoxAdaptorParentData2 childParentData =
            child.parentData as SliverMultiBoxAdaptorParentData2;
        children.add(child.toDiagnosticsNode(
            name: 'child with index ${childParentData.index}'));
        if (child == lastChild) break;
        child = childParentData.nextSibling;
      }
    }
    if (_keepAliveBucket.isNotEmpty) {
      final List<int> indices = _keepAliveBucket.keys.toList()..sort();
      for (final int index in indices) {
        children.add(_keepAliveBucket[index].toDiagnosticsNode(
          name: 'child with index $index (kept alive but not laid out)',
          style: DiagnosticsTreeStyle.offstage,
        ));
      }
    }
    return children;
  }
}

class SameIndexRenderObject extends RenderBox {

  final int sameIndex;
  final int index;
  final RenderBox renderBox;
  SameIndexRenderObject({this.index, this.sameIndex, this.renderBox}) : assert(index != null), assert(sameIndex != null), assert(renderBox != null);

  @override
  bool get sizedByParent => true;

  @override
  void performLayout() {
    super.performLayout();
  }

  @override
  bool hitTest(BoxHitTestResult result, {Offset position}) {
    return renderBox.hitTest(result, position: position);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {Offset position}) {
    return renderBox.hitTestChildren(result, position: position);
  }

  @override
  bool hitTestSelf(Offset position) {
    return renderBox.hitTestSelf(position);
  }

  @override
  void handleEvent(PointerEvent event, covariant BoxHitTestEntry entry) {
    renderBox.handleEvent(event, entry);
  }

}
