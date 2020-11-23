import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:video_list/ui/views/rendering/sliver_fill.dart';
import 'package:video_list/ui/views/widgets/sliver.dart';

/// A sliver that contains multiple box children that each fills the viewport.
///
/// [SliverFillViewport] places its children in a linear array along the main
/// axis. Each child is sized to fill the viewport, both in the main and cross
/// axis.
///
/// See also:
///
///  * [SliverFixedExtentList], which has a configurable
///    [SliverFixedExtentList.itemExtent].
///  * [SliverPrototypeExtentList], which is similar to [SliverFixedExtentList]
///    except that it uses a prototype list item instead of a pixel value to define
///    the main axis extent of each item.
///  * [SliverList], which does not require its children to have the same
///    extent in the main axis.
class SliverFillViewport2 extends StatelessWidget {
  /// Creates a sliver whose box children that each fill the viewport.
  const SliverFillViewport2({
    Key key,
    this.delegate,
    this.viewportFraction = 1.0,
    this.padEnds = true,
  })  : assert(viewportFraction != null),
        assert(viewportFraction > 0.0),
        assert(padEnds != null),
        super(key: key);

  /// The fraction of the viewport that each child should fill in the main axis.
  ///
  /// If this fraction is less than 1.0, more than one child will be visible at
  /// once. If this fraction is greater than 1.0, each child will be larger than
  /// the viewport in the main axis.
  final double viewportFraction;

  /// Whether to add padding to both ends of the list.
  ///
  /// If this is set to true and [viewportFraction] < 1.0, padding will be added
  /// such that the first and last child slivers will be in the center of
  /// the viewport when scrolled all the way to the start or end, respectively.
  /// You may want to set this to false if this [SliverFillViewport] is not the only
  /// widget along this main axis, such as in a [CustomScrollView] with multiple
  /// children.
  ///
  /// This option cannot be null. If [viewportFraction] >= 1.0, this option has no
  /// effect. Defaults to true.
  final bool padEnds;

  /// {@macro flutter.widgets.sliverMultiBoxAdaptor.delegate}
  final SliverChildDelegate delegate;

  @override
  Widget build(BuildContext context) {
    return _SliverFractionalPadding(
      viewportFraction: padEnds ? (1 - viewportFraction).clamp(0, 1) / 2 : 0,
      sliver: _SliverFillViewportRenderObjectWidget2(
        viewportFraction: viewportFraction,
        delegate: delegate,
      ),
    );
  }
}

class _SliverFractionalPadding extends SingleChildRenderObjectWidget {
  const _SliverFractionalPadding({
    this.viewportFraction = 0,
    Widget sliver,
  })  : assert(viewportFraction != null),
        assert(viewportFraction >= 0),
        assert(viewportFraction <= 0.5),
        super(child: sliver);

  final double viewportFraction;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderSliverFractionalPadding(viewportFraction: viewportFraction);

  @override
  void updateRenderObject(
      BuildContext context, _RenderSliverFractionalPadding renderObject) {
    renderObject.viewportFraction = viewportFraction;
  }
}

class _SliverFillViewportRenderObjectWidget2
    extends SliverMultiBoxAdaptorWidget2 {
  const _SliverFillViewportRenderObjectWidget2({
    Key key,
    SliverChildDelegate delegate,
    this.viewportFraction = 1.0,
  })  : assert(viewportFraction != null),
        assert(viewportFraction > 0.0),
        super(key: key, delegate: delegate);

  final double viewportFraction;

  @override
  RenderSliverFillViewport2 createRenderObject(BuildContext context) {
    final SliverMultiBoxAdaptorElement2 element =
        context as SliverMultiBoxAdaptorElement2;
    return RenderSliverFillViewport2(
        childManager: element, viewportFraction: viewportFraction);
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderSliverFillViewport2 renderObject) {
    renderObject
      ..viewportFraction = viewportFraction;
  }
}

class _RenderSliverFractionalPadding extends RenderSliverEdgeInsetsPadding {
  _RenderSliverFractionalPadding({
    double viewportFraction = 0,
  })  : assert(viewportFraction != null),
        assert(viewportFraction <= 0.5),
        assert(viewportFraction >= 0),
        _viewportFraction = viewportFraction;

  SliverConstraints _lastResolvedConstraints;

  double get viewportFraction => _viewportFraction;
  double _viewportFraction;
  set viewportFraction(double newValue) {
    assert(newValue != null);
    if (_viewportFraction == newValue) return;
    _viewportFraction = newValue;
    _markNeedsResolution();
  }

  @override
  EdgeInsets get resolvedPadding => _resolvedPadding;
  EdgeInsets _resolvedPadding;

  void _markNeedsResolution() {
    _resolvedPadding = null;
    markNeedsLayout();
  }

  void _resolve() {
    if (_resolvedPadding != null && _lastResolvedConstraints == constraints)
      return;

    assert(constraints.axis != null);
    final double paddingValue =
        constraints.viewportMainAxisExtent * viewportFraction;
    _lastResolvedConstraints = constraints;
    switch (constraints.axis) {
      case Axis.horizontal:
        _resolvedPadding = EdgeInsets.symmetric(horizontal: paddingValue);
        break;
      case Axis.vertical:
        _resolvedPadding = EdgeInsets.symmetric(vertical: paddingValue);
        break;
    }

    return;
  }

  @override
  void performLayout() {
    _resolve();
    super.performLayout();
  }
}
