import 'dart:math';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:syncfusion_flutter_core/core.dart';

import '../common/chart_point.dart';
import '../common/circular_data_label.dart';
import '../common/core_tooltip.dart';
import '../interactions/tooltip.dart';
import '../utils/enum.dart';
import '../utils/helper.dart';
import '../utils/renderer_helper.dart';
import 'chart_series.dart';

/// This class has the properties of the Doughnut series.
///
/// To render a doughnut chart, create an instance of [DoughnutSeries],
/// and add it to the series
/// collection property of [SfCircularChart].
///
/// Provide options for opacity, stroke width, stroke color, and
/// point color mapper to customize the appearance.
///
/// {@youtube 560 315 https://www.youtube.com/watch?v=VJxPp7-2nGk}
@immutable
class DoughnutSeries<T, D> extends CircularSeries<T, D> {
  /// Creating an argument constructor of DoughnutSeries class.
  const DoughnutSeries({
    super.key,
    super.onCreateRenderer,
    super.onRendererCreated,
    super.onPointTap,
    super.onPointDoubleTap,
    super.onPointLongPress,
    super.dataSource,
    required super.xValueMapper,
    required super.yValueMapper,
    super.pointColorMapper,
    super.pointShaderMapper,
    super.pointRadiusMapper,
    super.dataLabelMapper,
    super.sortFieldValueMapper,
    super.startAngle = 0,
    super.endAngle = 360,
    super.radius = '80%',
    super.innerRadius = '50%',
    this.explode = false,
    this.explodeAll = false,
    this.explodeGesture = ActivationMode.singleTap,
    this.explodeOffset = '10%',
    this.explodeIndex,
    super.groupTo,
    super.groupMode,
    super.pointRenderMode,
    super.emptyPointSettings,
    Color strokeColor = Colors.transparent,
    double strokeWidth = 2.0,
    super.dataLabelSettings,
    super.enableTooltip = true,
    super.name,
    super.opacity,
    super.animationDuration,
    super.animationDelay,
    super.selectionBehavior,
    super.sortingOrder,
    super.legendIconType,
    super.cornerStyle = CornerStyle.bothFlat,
    super.initialSelectedDataIndexes,
  }) : super(borderColor: strokeColor, borderWidth: strokeWidth);

  /// Enables or disables the explode of slices on tap.
  ///
  /// Default to `false`.
  ///
  /// ```dart
  /// Widget build(BuildContext context) {
  ///    return Container(
  ///        child: SfCircularChart(
  ///            series: <DoughnutSeries<ChartData, String>>[
  ///                DoughnutSeries<ChartData, String>(
  ///                  explode: true
  ///                ),
  ///            ],
  ///        )
  ///    );
  /// }
  /// ```
  final bool explode;

  /// Enables or disables exploding all the slices at the initial rendering.
  ///
  /// Defaults to `false`.
  ///
  /// ```dart
  /// Widget build(BuildContext context) {
  ///    return Container(
  ///        child: SfCircularChart(
  ///            series: <DoughnutSeries<ChartData, String>>[
  ///                DoughnutSeries<ChartData, String>(
  ///                  explodeAll: true
  ///                ),
  ///            ],
  ///        )
  ///    );
  /// }
  /// ```
  final bool explodeAll;

  /// Index of the slice to explode it at the initial rendering.
  ///
  /// Defaults to `null`.
  ///
  /// ```dart
  /// Widget build(BuildContext context) {
  ///    return Container(
  ///        child: SfCircularChart(
  ///            series: <DoughnutSeries<ChartData, String>>[
  ///                DoughnutSeries<ChartData, String>(
  ///                  explode: true,
  ///                  explodeIndex: 2
  ///                ),
  ///            ],
  ///        )
  ///    );
  /// }
  /// ```
  final int? explodeIndex;

  /// Offset of exploded slice. The value ranges from 0% to 100%.
  ///
  /// Defaults to `20%`.
  ///
  ///```dart
  ///Widget build(BuildContext context) {
  ///    return Container(
  ///        child: SfCircularChart(
  ///            series: <DoughnutSeries<ChartData, String>>[
  ///                DoughnutSeries<ChartData, String>(
  ///                  explode: true,
  ///                  explodeOffset: '30%'
  ///                ),
  ///            ],
  ///        )
  ///    );
  ///}
  ///```
  final String explodeOffset;

  /// Gesture for activating the explode.
  ///
  /// Explode can be activated in `ActivationMode.none`,
  /// `ActivationMode.singleTap`, `ActivationMode.doubleTap`,
  /// and `ActivationMode.longPress`.
  ///
  /// Defaults to `ActivationMode.singleTap`.
  ///
  /// Also refer [ActivationMode].
  ///
  ///```dart
  ///Widget build(BuildContext context) {
  ///    return Container(
  ///        child: SfCircularChart(
  ///            series: <DoughnutSeries<ChartData, String>>[
  ///                DoughnutSeries<ChartData, String>(
  ///                  explode: true,
  ///                  explodeGesture: ActivationMode.singleTap
  ///                ),
  ///            ],
  ///        )
  ///    );
  ///}
  ///```
  final ActivationMode explodeGesture;

  @override
  List<ChartDataPointType> get positions => <ChartDataPointType>[
    ChartDataPointType.y,
  ];

  /// Create the  circular series renderer.
  @override
  DoughnutSeriesRenderer<T, D> createRenderer() {
    DoughnutSeriesRenderer<T, D>? seriesRenderer;
    if (onCreateRenderer != null) {
      seriesRenderer = onCreateRenderer!(this) as DoughnutSeriesRenderer<T, D>;
      // ignore: unnecessary_null_comparison
      return seriesRenderer;
    }
    return DoughnutSeriesRenderer<T, D>();
  }

  @override
  DoughnutSeriesRenderer<T, D> createRenderObject(BuildContext context) {
    final DoughnutSeriesRenderer<T, D> renderer =
        super.createRenderObject(context) as DoughnutSeriesRenderer<T, D>;
    renderer
      ..explode = explode
      ..explodeAll = explodeAll
      ..explodeIndex = explodeIndex
      ..explodeOffset = explodeOffset
      ..explodeGesture = explodeGesture;
    return renderer;
  }

  @override
  void updateRenderObject(
    BuildContext context,
    DoughnutSeriesRenderer<T, D> renderObject,
  ) {
    super.updateRenderObject(context, renderObject);
    renderObject
      ..explode = explode
      ..explodeAll = explodeAll
      ..explodeIndex = explodeIndex
      ..explodeOffset = explodeOffset
      ..explodeGesture = explodeGesture;
  }
}

/// Creates series renderer for doughnut series.
class DoughnutSeriesRenderer<T, D> extends CircularSeriesRenderer<T, D> {
  /// Calling the default constructor of [DoughnutSeriesRenderer] class.
  DoughnutSeriesRenderer();

  bool get explode => _explode;
  bool _explode = false;
  set explode(bool value) {
    if (_explode != value) {
      _explode = value;
      _updateExploding();
    }
  }

  bool get explodeAll => _explodeAll;
  bool _explodeAll = false;
  set explodeAll(bool value) {
    if (_explodeAll != value) {
      _explodeAll = value;
      if (!_explodeAll) {
        for (final ChartSegment segment in segments) {
          final DoughnutSegment<T, D> doughnutSegment =
              segment as DoughnutSegment<T, D>;
          if (explode && segment.currentSegmentIndex == explodeIndex) {
            doughnutSegment._isExploded = true;
          } else {
            doughnutSegment._isExploded = false;
          }
        }

        transformValues();
        markNeedsPaint();
      } else {
        _updateExploding();
      }
    }
  }

  int? get explodeIndex => _explodeIndex;
  int? _explodeIndex;
  set explodeIndex(int? value) {
    if (_explodeIndex != value) {
      _explodeIndex = value;
      _updateExploding();
    }
  }

  String get explodeOffset => _explodeOffset;
  String _explodeOffset = '10%';
  set explodeOffset(String value) {
    if (_explodeOffset != value) {
      _explodeOffset = value;
      transformValues();
      markNeedsPaint();
    }
  }

  ActivationMode get explodeGesture => _explodeGesture;
  ActivationMode _explodeGesture = ActivationMode.singleTap;
  set explodeGesture(ActivationMode value) {
    if (_explodeGesture != value) {
      _explodeGesture = value;
    }
  }

  /// Stores pointer down time to determine whether a long press interaction is handled at pointer up
  DateTime? _pointerHoldingTime;

  @override
  void setData(int index, ChartSegment segment) {
    super.setData(index, segment);

    num yValue = circularYValues[index].abs();
    // Handled the empty point here.
    yValue = yValue.isNaN || !segment.isVisible ? 0 : yValue;
    final double degree =
        (yValue.abs() / (sumOfY != 0 ? sumOfY : 1)) * totalAngle;
    final double pointEndAngle = pointStartAngle + degree;
    final double outerRadius =
        pointRadii.isNotEmpty
            ? percentToValue(
              pointRadii[index],
              (min(size.width, size.height)) / 2,
            )!
            : currentRadius;

    segment as DoughnutSegment<T, D>
      ..series = this
      .._degree = degree
      ..startAngle = pointStartAngle
      ..endAngle = pointEndAngle
      .._innerRadius = currentInnerRadius
      .._outerRadius = outerRadius
      .._center = center
      .._isExploded = explode && (index == explodeIndex || explodeAll)
      ..isEmpty =
          (emptyPointSettings.mode != EmptyPointMode.drop &&
              emptyPointSettings.mode != EmptyPointMode.gap) &&
          isEmpty(index);

    pointStartAngle = pointEndAngle;
  }

  @override
  DoughnutSegment<T, D> createSegment() => DoughnutSegment<T, D>();

  @override
  ShapeMarkerType effectiveLegendIconType() => ShapeMarkerType.doughnutSeries;

  @override
  void customizeSegment(ChartSegment segment) {
    updateSegmentColor(segment, borderColor, borderWidth);
    segment.fillPaint.shader = null;
    updateSegmentGradient(segment);
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    final bool isHit = super.hitTest(result, position: position);
    return explode || isHit;
  }

  @override
  void handlePointerDown(PointerDownEvent details) {
    if (explode && explodeGesture == ActivationMode.singleTap) {
      _pointerHoldingTime = DateTime.now();
    }
    super.handlePointerDown(details);
  }

  @override
  void handlePointerUp(PointerUpEvent details) {
    if (explode &&
        explodeGesture == ActivationMode.singleTap &&
        _pointerHoldingTime != null &&
        DateTime.now().difference(_pointerHoldingTime!).inMilliseconds <
            kLongPressTimeout.inMilliseconds) {
      _handleExploding(details.localPosition);
    }
    super.handlePointerUp(details);
  }

  @override
  void handleDoubleTap(Offset position) {
    final Offset localPosition = globalToLocal(position);
    if (explode && explodeGesture == ActivationMode.doubleTap) {
      _handleExploding(localPosition);
    }
    super.handleDoubleTap(position);
  }

  @override
  void handleLongPressStart(LongPressStartDetails details) {
    if (explode && explodeGesture == ActivationMode.longPress) {
      _handleExploding(details.localPosition);
    }
    super.handleLongPressStart(details);
  }

  void _handleExploding(Offset position) {
    for (final ChartSegment segment in segments) {
      final DoughnutSegment<T, D> doughnutSegment =
          segment as DoughnutSegment<T, D>;
      if (segment.contains(position)) {
        doughnutSegment._isExploded = !doughnutSegment._isExploded;
        if (doughnutSegment._isExploded) {
          _explodeIndex = segment.currentSegmentIndex;
        } else {
          _explodeIndex = -1;
        }
      } else {
        doughnutSegment._isExploded = false;
      }
    }

    forceTransformValues = true;
    markNeedsLayout();
  }

  void _updateExploding() {
    for (final ChartSegment segment in segments) {
      final DoughnutSegment<T, D> doughnutSegment =
          segment as DoughnutSegment<T, D>;
      if (!explode) {
        doughnutSegment._isExploded = false;
      } else {
        if (explodeAll || segment.currentSegmentIndex == explodeIndex) {
          doughnutSegment._isExploded = true;
        } else {
          doughnutSegment._isExploded = false;
        }
      }
    }

    forceTransformValues = true;
    markNeedsLayout();
  }

  @override
  Offset dataLabelPosition(CircularDataLabelBoxParentData current, Size size) {
    final DoughnutSegment<T, D> segment =
        segments[current.dataPointIndex] as DoughnutSegment<T, D>;
    current.point!
      ..degree = segment._degree
      ..isExplode = segment._isExploded
      ..isVisible = segment.isVisible
      ..explodeOffset = explodeOffset
      ..startAngle = segment._startAngle
      ..endAngle = segment._endAngle
      ..midAngle = (segment._startAngle + segment._endAngle) / 2
      ..innerRadius = segment._innerRadius
      ..outerRadius = segment._outerRadius
      ..center = center
      ..fill = palette[current.dataPointIndex % palette.length];

    _findDataLabelPosition(current.point!);
    return super.dataLabelPosition(current, size);
  }

  /// To find data label position.
  void _findDataLabelPosition(CircularChartPoint point) {
    point.midAngle =
        point.midAngle! > 360 ? point.midAngle! - 360 : point.midAngle!;
    point.dataLabelPosition =
        ((point.midAngle! >= -90 && point.midAngle! < 0) ||
                (point.midAngle! >= 0 && point.midAngle! < 90) ||
                (point.midAngle! >= 270))
            ? Position.right
            : Position.left;
  }
}

class DoughnutSegment<T, D> extends ChartSegment {
  late DoughnutSeriesRenderer<T, D> series;
  late double _degree;
  late double _innerRadius;
  late double _outerRadius;
  late Offset _center;
  bool _isExploded = false;
  Path fillPath = Path();
  double _priorStartAngle = double.nan;
  double _priorEndAngle = double.nan;

  double get startAngle => _startAngle;
  double _startAngle = double.nan;
  set startAngle(double value) {
    _priorStartAngle = _startAngle;
    _startAngle = value;
  }

  double get endAngle => _endAngle;
  double _endAngle = double.nan;
  set endAngle(double value) {
    _priorEndAngle = _endAngle;
    _endAngle = value;
  }

  @override
  void transformValues() {
    fillPath.reset();

    double degree = _degree * animationFactor;
    final double angle = calculateAngle(
      series.animationFactor == 1,
      series.startAngle,
      series.endAngle,
    );
    final double startAngle =
        lerpDouble(
          _priorEndAngle.isNaN ? angle : _priorStartAngle,
          _startAngle,
          animationFactor,
        )!;
    final double endAngle =
        _priorEndAngle.isNaN
            ? startAngle + degree
            : lerpDouble(_priorEndAngle, _endAngle, animationFactor)!;
    degree = _priorEndAngle.isNaN ? degree : endAngle - startAngle;

    // If the startAngle and endAngle value is same, then degree will be 0.
    // Hence no need to render segments.
    if (!isVisible && degree == 0) {
      return;
    }

    if (series.explode && _isExploded) {
      final double midAngle = (_startAngle + _endAngle) / 2;
      _center = calculateExplodingCenter(
        midAngle,
        _outerRadius,
        series.center,
        series.explodeOffset,
      );
    } else {
      _center = series.center;
    }

    final CornerStyle cornerStyle = series.cornerStyle;
    if (cornerStyle == CornerStyle.bothFlat) {
      fillPath = calculateArcPath(
        _innerRadius,
        _outerRadius,
        _center,
        startAngle,
        endAngle,
        degree,
        isAnimate: true,
      );
    } else {
      final num angleDeviation = findAngleDeviation(
        _innerRadius,
        _outerRadius,
        360,
      );
      final double actualStartAngle =
          (cornerStyle == CornerStyle.startCurve ||
                  cornerStyle == CornerStyle.bothCurve)
              ? (startAngle + angleDeviation)
              : startAngle;
      final double actualEndAngle =
          (cornerStyle == CornerStyle.endCurve ||
                  cornerStyle == CornerStyle.bothCurve)
              ? (endAngle - angleDeviation)
              : endAngle;

      fillPath = calculateRoundedCornerArcPath(
        cornerStyle,
        _innerRadius,
        _outerRadius,
        _center,
        actualStartAngle,
        actualEndAngle,
      );
    }
  }

  @override
  Paint getFillPaint() => fillPaint;

  @override
  Paint getStrokePaint() => strokePaint;

  @override
  void calculateSegmentPoints() {}

  @override
  bool contains(Offset position) {
    return fillPath.contains(position);
  }

  @override
  TooltipInfo? tooltipInfo({Offset? position, int? pointIndex}) {
    final ChartPoint<D> point = ChartPoint<D>(
      x: series.circularXValues[currentSegmentIndex],
      y: series.circularYValues[currentSegmentIndex],
    );
    final Offset location = calculateOffset(
      (_startAngle + _endAngle) / 2,
      (_innerRadius + _outerRadius) / 2,
      _center,
    );
    final TooltipPosition? tooltipPosition =
        series.parent?.tooltipBehavior?.tooltipPosition;
    final Offset preferredPos =
        tooltipPosition == TooltipPosition.pointer
            ? series.localToGlobal(position ?? location)
            : series.localToGlobal(location);
    return ChartTooltipInfo<T, D>(
      primaryPosition: preferredPos,
      secondaryPosition: preferredPos,
      text: series.tooltipText(point),
      header: '',
      data: series.dataSource![currentSegmentIndex],
      point: point,
      series: series.widget,
      renderer: series,
      seriesIndex: series.index,
      segmentIndex: currentSegmentIndex,
      pointIndex: currentSegmentIndex,
    );
  }

  @override
  void onPaint(Canvas canvas) {
    Paint paint = getFillPaint();
    if (paint.color != Colors.transparent) {
      canvas.drawPath(fillPath, paint);
    }

    paint = getStrokePaint();
    if (paint.color != Colors.transparent && paint.strokeWidth > 0) {
      canvas.drawPath(fillPath, paint);
    }
  }

  @override
  void dispose() {
    fillPath.reset();
    super.dispose();
  }
}
