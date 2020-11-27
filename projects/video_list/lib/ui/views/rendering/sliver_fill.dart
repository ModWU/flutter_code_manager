import 'package:flutter/rendering.dart';
import 'package:video_list/ui/views/rendering/sliver_fixed_extent_list.dart';

/// A sliver that contains multiple box children that each fill the viewport.
///
/// [RenderSliverFillViewport] places its children in a linear array along the
/// main axis. Each child is sized to fill the viewport, both in the main and
/// cross axis. A [viewportFraction] factor can be provided to size the children
/// to a multiple of the viewport's main axis dimension (typically a fraction
/// less than 1.0).
///
/// See also:
///
///  * [RenderSliverFillRemaining], which sizes the children based on the
///    remaining space rather than the viewport itself.
///  * [RenderSliverFixedExtentList], which has a configurable [itemExtent].
///  * [RenderSliverList], which does not require its children to have the same
///    extent in the main axis.
class RenderSliverFillViewport2 extends RenderSliverFixedExtentBoxAdaptor2 {
  /// Creates a sliver that contains multiple box children that each fill the
  /// viewport.
  ///
  /// The [childManager] argument must not be null.
  RenderSliverFillViewport2({
    RenderSliverBoxChildManager childManager,
    double viewportFraction = 1.0,
  }) : assert(viewportFraction != null),
        assert(viewportFraction > 0.0),
        _viewportFraction = viewportFraction,
        super(childManager: childManager);

  @override
  double get itemExtent => constraints.viewportMainAxisExtent * viewportFraction;

  /// The fraction of the viewport that each child should fill in the main axis.
  ///
  /// If this fraction is less than 1.0, more than one child will be visible at
  /// once. If this fraction is greater than 1.0, each child will be larger than
  /// the viewport in the main axis.
  double get viewportFraction => _viewportFraction;
  double _viewportFraction;

  bool _keepStartEdge;
  bool get keepStartEdge => _keepStartEdge;

  set viewportFraction(double value) {
    assert(value != null);
    if (_viewportFraction == value)
      return;
    _viewportFraction = value;
    markNeedsLayout();
  }


}