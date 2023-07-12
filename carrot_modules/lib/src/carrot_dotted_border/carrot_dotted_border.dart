import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

part 'carrot_dash_painter.dart';

/// Add a dotted border around any [child] widget. The [strokeWidth] property
/// defines the width of the dashed border and [color] determines the stroke
/// paint color. [CircularIntervalList] is populated with the [dashPattern] to
/// render the appropriate pattern. The [radius] property is taken into account
/// only if the [borderType] is [BorderType.RRect]. A [customPath] can be passed in
/// as a parameter if you want to draw a custom shaped border.
class CarrotDottedBorder extends StatelessWidget {
  /// Creates a [CarrotDottedBorder] widget
  CarrotDottedBorder({
    required this.child,
    super.key,
    this.color = Colors.black,
    this.strokeWidth = 1,
    this.borderType = BorderType.Rect,
    this.dashPattern = const <double>[3, 1],
    this.padding = const EdgeInsets.all(2),
    this.borderPadding = EdgeInsets.zero,
    this.radius = Radius.zero,
    this.strokeCap = StrokeCap.butt,
    this.customPath,
  }) {
    assert(_isValidDashPattern(dashPattern), 'Invalid dash pattern');
  }

  /// A widget to be rendered inside the [CarrotDottedBorder]
  final Widget child;

  /// padding for the child inside the [CarrotDottedBorder]
  final EdgeInsets padding;

  /// padding for the border around the [child]
  final EdgeInsets borderPadding;

  /// The width of the dotted border
  final double strokeWidth;

  /// The color of the dotted border
  final Color color;

  /// The type of border to be drawn
  final List<double> dashPattern;

  /// The type of border to be drawn
  final BorderType borderType;

  /// The radius of the border if [borderType] is [BorderType.RRect]
  final Radius radius;

  /// The stroke cap of the border
  final StrokeCap strokeCap;

  /// A custom path to be drawn as the border
  final PathBuilder? customPath;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: CustomPaint(
            painter: _DashPainter(
              padding: borderPadding,
              strokeWidth: strokeWidth,
              radius: radius,
              color: color,
              borderType: borderType,
              dashPattern: dashPattern,
              customPath: customPath,
              strokeCap: strokeCap,
            ),
          ),
        ),
        Padding(
          padding: padding,
          child: child,
        ),
      ],
    );
  }

  /// Compute if [dashPattern] is valid. The following conditions need to be met
  /// * Cannot be null or empty
  /// * If [dashPattern] has only 1 element, it cannot be 0
  bool _isValidDashPattern(List<double>? dashPattern) {
    final dashSet = dashPattern?.toSet();
    if (dashSet == null) return false;
    if (dashSet.length == 1 && dashSet.elementAt(0) == 0.0) return false;
    if (dashSet.isEmpty) return false;
    return true;
  }
}

/// The different supported BorderTypes
enum BorderType { Circle, RRect, Rect, Oval }
