import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Vertical stack where each child overlaps the previous one by [overlap]
/// (later children paint on top) — the design's stacked reminder cards.
/// Unlike a Stack, it sizes itself to its content.
class OverlappingColumn extends MultiChildRenderObjectWidget {
  const OverlappingColumn({
    super.key,
    required this.overlap,
    required super.children,
  });

  final double overlap;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      RenderOverlappingColumn(overlap);

  @override
  void updateRenderObject(
    BuildContext context,
    RenderOverlappingColumn renderObject,
  ) => renderObject.overlap = overlap;
}

class _OverlapParentData extends ContainerBoxParentData<RenderBox> {}

class RenderOverlappingColumn extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _OverlapParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _OverlapParentData> {
  RenderOverlappingColumn(this._overlap);

  double _overlap;
  set overlap(double value) {
    if (value == _overlap) return;
    _overlap = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _OverlapParentData) {
      child.parentData = _OverlapParentData();
    }
  }

  @override
  void performLayout() {
    final childConstraints = BoxConstraints(maxWidth: constraints.maxWidth);
    var y = 0.0;
    var bottom = 0.0;
    var child = firstChild;
    while (child != null) {
      child.layout(childConstraints, parentUsesSize: true);
      final data = child.parentData! as _OverlapParentData;
      data.offset = Offset(0, y);
      bottom = math.max(bottom, y + child.size.height);
      y += math.max(0, child.size.height - _overlap);
      child = data.nextSibling;
    }
    size = constraints.constrain(Size(constraints.maxWidth, bottom));
  }

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}
