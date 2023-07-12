import 'package:flutter/material.dart';

/// {@template carrot_percent_indicator}
/// Flutter package Carrot Percent Indicator
/// {@endtemplate}
// ignore: must_be_immutable
class CarrotPercentIndicator extends StatefulWidget {
  /// {@macro carrot_percent_indicator}
  CarrotPercentIndicator({
    super.key,
    this.fillColor = Colors.transparent,
    this.percent = 0.0,
    this.lineHeight = 5.0,
    this.width,
    Color? backgroundColor,
    this.linearGradientBackgroundColor,
    this.linearGradient,
    Color? progressColor,
    this.animation = false,
    this.animationDuration = 500,
    this.animateFromLastPercent = false,
    this.isRTL = false,
    this.leading,
    this.trailing,
    this.center,
    this.addAutomaticKeepAlive = true,
    this.barRadius,
    this.padding = const EdgeInsets.symmetric(horizontal: 10),
    this.alignment = MainAxisAlignment.start,
    this.maskFilter,
    this.clipLinearGradient = false,
    this.curve = Curves.linear,
    this.restartAnimation = false,
    this.onAnimationEnd,
    this.widgetIndicator,
    this.progressBorderColor,
  }) {
    if (linearGradient != null && progressColor != null) {
      throw ArgumentError('Cannot provide both linearGradient and progressColor');
    }
    _progressColor = progressColor ?? Colors.red;

    if (linearGradientBackgroundColor != null && backgroundColor != null) {
      throw ArgumentError('Cannot provide both linearGradientBackgroundColor and backgroundColor');
    }
    _backgroundColor = backgroundColor ?? const Color(0xFFB8C7CB);

    if (percent < 0.0 || percent > 1.0) {
      throw Exception("Percent value must be a double between 0.0 and 1.0, but it's $percent");
    }
  }

  /// {@macro carrot_percent_indicator}
  ///Percent value between 0.0 and 1.0
  final double percent;

  /// Width of the line
  final double? width;

  ///Height of the line
  final double lineHeight;

  ///Color of the background of the Line , default = transparent
  final Color fillColor;

  ///Color of the border of the progress bar , default = null
  final Color? progressBorderColor;

  ///First color applied to the complete line
  Color get backgroundColor => _backgroundColor;
  late Color _backgroundColor;

  ///First color applied to the complete line
  final LinearGradient? linearGradientBackgroundColor;

  /// get value of the progress bar
  Color get progressColor => _progressColor;

  late Color _progressColor;

  ///true if you want the Line to have animation
  final bool animation;

  ///duration of the animation in milliseconds, It only applies if animation attribute is true
  final int animationDuration;

  ///widget at the left of the Line
  final Widget? leading;

  ///widget at the right of the Line
  final Widget? trailing;

  ///widget inside the Line
  final Widget? center;

  /// The border radius of the progress bar (Will replace linearStrokeCap)
  final Radius? barRadius;

  ///alignment of the Row (leading-widget-center-trailing)
  final MainAxisAlignment alignment;

  ///padding to the CarrotPercentIndicator
  final EdgeInsets padding;

  /// set true if you want to animate the linear from the last percent value you set
  final bool animateFromLastPercent;

  /// If present, this will make the progress bar colored by this gradient.
  ///
  /// This will override [progressColor]. It is an error to provide both.
  final LinearGradient? linearGradient;

  /// set false if you don't want to preserve the state of the widget
  final bool addAutomaticKeepAlive;

  /// set true if you want to animate the linear from the right to left (RTL)
  final bool isRTL;

  /// Creates a mask filter that takes the progress shape being drawn and blurs it.
  final MaskFilter? maskFilter;

  /// Set true if you want to display only part of [linearGradient] based on percent value
  /// (ie. create 'VU effect'). If no [linearGradient] is specified this option is ignored.
  final bool clipLinearGradient;

  /// set a linear curve animation type
  final Curve curve;

  /// set true when you want to restart the animation, it restarts only when reaches 1.0 as a value
  /// defaults to false
  final bool restartAnimation;

  /// Callback called when the animation ends (only if `animation` is true)
  final VoidCallback? onAnimationEnd;

  /// Display a widget indicator at the end of the progress. It only works when `animation` is true
  final Widget? widgetIndicator;

  @override
  CarrotPercentIndicatorState createState() => CarrotPercentIndicatorState();
}

/// Manage the state of the progress bar
class CarrotPercentIndicatorState extends State<CarrotPercentIndicator>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  AnimationController? _animationController;
  late Animation<num>? _animation;
  double _percent = 0;
  final _containerKey = GlobalKey();
  final _keyIndicator = GlobalKey();
  double _containerWidth = 0;
  double _containerHeight = 0;
  double _indicatorWidth = 0;
  double _indicatorHeight = 0;

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _containerWidth = _containerKey.currentContext?.size?.width ?? 0.0;
          _containerHeight = _containerKey.currentContext?.size?.height ?? 0.0;
          if (_keyIndicator.currentContext != null) {
            _indicatorWidth = _keyIndicator.currentContext?.size?.width ?? 0.0;
            _indicatorHeight = _keyIndicator.currentContext?.size?.height ?? 0.0;
          }
        });
      }
    });
    if (widget.animation) {
      _animationController =
          AnimationController(vsync: this, duration: Duration(milliseconds: widget.animationDuration));
      _animation = Tween(begin: 0, end: widget.percent).animate(
        CurvedAnimation(parent: _animationController!, curve: widget.curve),
      )..addListener(() {
          setState(() {
            _percent = _animation!.value.toDouble();
          });
          if (widget.restartAnimation && _percent == 1.0) {
            _animationController!.repeat(min: 0, max: 1);
          }
        });
      _animationController!.addStatusListener((status) {
        if (widget.onAnimationEnd != null && status == AnimationStatus.completed) {
          widget.onAnimationEnd!();
        }
      });
      _animationController!.forward();
    } else {
      _updateProgress();
    }
    super.initState();
  }

  void _checkIfNeedCancelAnimation(CarrotPercentIndicator oldWidget) {
    if (oldWidget.animation && !widget.animation && _animationController != null) {
      _animationController!.stop();
    }
  }

  @override
  void didUpdateWidget(CarrotPercentIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.percent != widget.percent) {
      if (_animationController != null) {
        _animationController!.duration = Duration(milliseconds: widget.animationDuration);
        _animation = Tween(begin: widget.animateFromLastPercent ? oldWidget.percent : 0.0, end: widget.percent).animate(
          CurvedAnimation(parent: _animationController!, curve: widget.curve),
        );
        _animationController!.forward(from: 0);
      } else {
        _updateProgress();
      }
    }
    _checkIfNeedCancelAnimation(oldWidget);
  }

  void _updateProgress() {
    setState(() {
      _percent = widget.percent;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final items = List<Widget>.empty(growable: true);
    if (widget.leading != null) {
      items.add(widget.leading!);
    }
    final hasSetWidth = widget.width != null;
    final percentPositionedHorizontal = _containerWidth * _percent - _indicatorWidth / 3;
    final containerWidget = Container(
      width: hasSetWidth ? widget.width : double.infinity,
      height: widget.lineHeight,
      padding: widget.padding,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CustomPaint(
            key: _containerKey,
            painter: _LinearPainter(
              isRTL: widget.isRTL,
              progress: _percent,
              progressColor: widget.progressColor,
              progressBorderColor: widget.progressBorderColor,
              linearGradient: widget.linearGradient,
              backgroundColor: widget.backgroundColor,
              barRadius: widget.barRadius ?? Radius.zero, // If radius is not defined, set it to zero
              linearGradientBackgroundColor: widget.linearGradientBackgroundColor,
              maskFilter: widget.maskFilter,
              clipLinearGradient: widget.clipLinearGradient,
            ),
            child: (widget.center != null) ? Center(child: widget.center) : Container(),
          ),
          if (widget.widgetIndicator != null && _indicatorWidth == 0)
            Opacity(
              opacity: 0,
              key: _keyIndicator,
              child: widget.widgetIndicator,
            ),
          if (widget.widgetIndicator != null && _containerWidth > 0 && _indicatorWidth > 0)
            Positioned(
              right: widget.isRTL ? percentPositionedHorizontal : null,
              left: !widget.isRTL ? percentPositionedHorizontal : null,
              top: _containerHeight / 2 - _indicatorHeight,
              child: widget.widgetIndicator!,
            ),
        ],
      ),
    );

    if (hasSetWidth) {
      items.add(containerWidget);
    } else {
      items.add(
        Expanded(
          child: containerWidget,
        ),
      );
    }
    if (widget.trailing != null) {
      items.add(widget.trailing!);
    }

    return Material(
      color: Colors.transparent,
      child: ColoredBox(
        color: widget.fillColor,
        child: Row(
          mainAxisAlignment: widget.alignment,
          children: items,
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => widget.addAutomaticKeepAlive;
}

class _LinearPainter extends CustomPainter {
  _LinearPainter({
    required this.progress,
    required this.isRTL,
    required this.progressColor,
    required this.backgroundColor,
    required this.barRadius,
    required this.clipLinearGradient,
    this.progressBorderColor,
    this.linearGradient,
    this.maskFilter,
    this.linearGradientBackgroundColor,
  }) {
    _paintBackground.color = backgroundColor;

    _paintLine.color = progress == 0 ? progressColor.withOpacity(0) : progressColor;

    if (progressBorderColor != null) {
      _paintLineBorder.color = progress == 0 ? progressBorderColor!.withOpacity(0) : progressBorderColor!;
    }
  }
  final Paint _paintBackground = Paint();
  final Paint _paintLine = Paint();
  final Paint _paintLineBorder = Paint();
  final double progress;
  final bool isRTL;
  final Color progressColor;
  final Color? progressBorderColor;
  final Color backgroundColor;
  final Radius barRadius;
  final LinearGradient? linearGradient;
  final LinearGradient? linearGradientBackgroundColor;
  final MaskFilter? maskFilter;
  final bool clipLinearGradient;

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background first
    final backgroundPath = Path()
      ..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), barRadius));
    canvas
      ..drawPath(backgroundPath, _paintBackground)
      ..clipPath(backgroundPath);

    if (maskFilter != null) {
      _paintLineBorder.maskFilter = maskFilter;
      _paintLine.maskFilter = maskFilter;
    }

    if (linearGradientBackgroundColor != null) {
      final shaderEndPoint = clipLinearGradient ? Offset.zero : Offset(size.width, size.height);
      _paintBackground.shader =
          linearGradientBackgroundColor?.createShader(Rect.fromPoints(Offset.zero, shaderEndPoint));
    }

    // Then draw progress line
    final xProgress = size.width * progress;
    final linePath = Path();
    final linePathBorder = Path();
    final factor = progressBorderColor != null ? 2 : 0;
    final correction = factor * 2; //Left and right or top an down
    if (isRTL) {
      if (linearGradient != null) {
        _paintLineBorder.shader = _createGradientShaderRightToLeft(size, xProgress);
        _paintLine.shader = _createGradientShaderRightToLeft(size, xProgress);
      }
      linePath.addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width - size.width * progress, 0, xProgress, size.height),
          barRadius,
        ),
      );
    } else {
      if (linearGradient != null) {
        _paintLineBorder.shader = _createGradientShaderLeftToRight(size, xProgress);
        _paintLine.shader = _createGradientShaderLeftToRight(size, xProgress);
      }
      if (progressBorderColor != null) {
        linePathBorder.addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, xProgress, size.height), barRadius));
      }
      linePath.addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(factor.toDouble(), factor.toDouble(), xProgress - correction, size.height - correction),
          barRadius,
        ),
      );
    }
    if (progressBorderColor != null) {
      canvas.drawPath(linePathBorder, _paintLineBorder);
    }
    canvas.drawPath(linePath, _paintLine);
  }

  Shader _createGradientShaderRightToLeft(Size size, double xProgress) {
    final shaderEndPoint = clipLinearGradient ? Offset.zero : Offset(xProgress, size.height);
    return linearGradient!.createShader(
      Rect.fromPoints(
        Offset(size.width, size.height),
        shaderEndPoint,
      ),
    );
  }

  Shader _createGradientShaderLeftToRight(Size size, double xProgress) {
    final shaderEndPoint = clipLinearGradient ? Offset(size.width, size.height) : Offset(xProgress, size.height);
    return linearGradient!.createShader(
      Rect.fromPoints(
        Offset.zero,
        shaderEndPoint,
      ),
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
