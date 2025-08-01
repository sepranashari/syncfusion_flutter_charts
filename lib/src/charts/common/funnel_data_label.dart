import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:syncfusion_flutter_core/core.dart';

import '../base.dart';
import '../series/funnel_series.dart';
import '../utils/enum.dart';
import '../utils/helper.dart';
import '../utils/typedef.dart';
import 'callbacks.dart';
import 'chart_point.dart';
import 'data_label.dart';
import 'element_widget.dart';

// ignore: must_be_immutable
base class FunnelChartDataLabelPositioned
    extends ParentDataWidget<ChartElementParentData>
    with LinkedListEntry<FunnelChartDataLabelPositioned> {
  FunnelChartDataLabelPositioned({
    super.key,
    required this.x,
    required this.y,
    required this.dataPointIndex,
    required this.position,
    required super.child,
  });

  final num x;
  final num y;
  final int dataPointIndex;
  final ChartDataPointType position;

  Path connectorPath = Path();
  Offset offset = Offset.zero;
  Size size = Size.zero;

  @override
  void applyParentData(RenderObject renderObject) {
    assert(renderObject.parentData is ChartElementParentData);
    final ChartElementParentData parentData =
        renderObject.parentData! as ChartElementParentData;
    bool needsLayout = false;

    if (parentData.x != x) {
      parentData.x = x;
      needsLayout = true;
    }

    if (parentData.y != y) {
      parentData.y = y;
      needsLayout = true;
    }

    if (parentData.dataPointIndex != dataPointIndex) {
      parentData.dataPointIndex = dataPointIndex;
      needsLayout = true;
    }

    if (parentData.position != position) {
      parentData.position = position;
      needsLayout = true;
    }

    if (needsLayout) {
      final RenderObject? targetParent = renderObject.parent;
      if (targetParent is RenderObject) {
        targetParent.markNeedsLayout();
      }
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => FunnelDataLabelStack;
}

class FunnelDataLabelContainer<T, D> extends StatefulWidget {
  const FunnelDataLabelContainer({
    super.key,
    required this.series,
    required this.dataSource,
    this.mapper,
    this.builder,
    required this.settings,
  });

  final ChartWidgetBuilder<T, D>? builder;
  final List<T> dataSource;
  final ChartValueMapper<T, String>? mapper;
  final FunnelSeries<T, D> series;
  final DataLabelSettings settings;

  @override
  State<FunnelDataLabelContainer<T, D>> createState() =>
      _FunnelDataLabelContainerState<T, D>();
}

typedef _ChartDataLabelWidgetBuilder<T, D> =
    Widget Function(
      T data,
      ChartPoint<D> point,
      FunnelSeries<T, D> series,
      int pointIndex,
      int seriesIndex,
      ChartDataPointType position,
    );

class _FunnelDataLabelContainerState<T, D>
    extends State<FunnelDataLabelContainer<T, D>>
    with ChartElementParentDataMixin<T, D> {
  List<FunnelChartDataLabelPositioned>? _builderChildren;
  LinkedList<FunnelChartDataLabelPositioned>? _textChildren;

  Widget _dataLabelFromBuilder(
    T data,
    ChartPoint<D> point,
    FunnelSeries<T, D> series,
    int pointIndex,
    int seriesIndex,
    ChartDataPointType position,
  ) {
    return widget.builder!(data, point, series, pointIndex, seriesIndex);
  }

  Widget _dataLabelFromMapper(
    T data,
    ChartPoint<D> point,
    FunnelSeries<T, D> series,
    int pointIndex,
    int seriesIndex,
    ChartDataPointType position,
  ) {
    final String text = widget.mapper!(data, pointIndex) ?? '';
    return _buildDataLabelText(text, pointIndex);
  }

  Widget _defaultDataLabel(
    T data,
    ChartPoint<D> point,
    FunnelSeries<T, D> series,
    int pointIndex,
    int seriesIndex,
    ChartDataPointType position,
  ) {
    final num value = point[position];
    final String formattedText = decimalLabelValue(value);
    return _buildDataLabelText(formattedText, pointIndex);
  }

  Color _dataPointColor(int dataPointIndex) {
    final DataLabelSettings settings = widget.settings;
    if (settings.color != null) {
      return settings.color!.withValues(alpha: settings.opacity);
    } else if (settings.useSeriesColor) {
      final int segmentsLastIndex = renderer!.segments.length - 1;
      return renderer!
          .segments[segmentsLastIndex - dataPointIndex]
          .fillPaint
          .color
          .withValues(alpha: settings.opacity);
    }
    return Colors.transparent;
  }

  DataLabelText _buildDataLabelText(String text, int pointIndex) {
    final RenderChartPlotArea parent = renderer!.parent!;
    final TextStyle dataLabelTextStyle = parent.themeData!.textTheme.bodySmall!
        .copyWith(color: Colors.transparent)
        .merge(parent.chartThemeData!.dataLabelTextStyle)
        .merge(widget.settings.textStyle);
    return DataLabelText(
      text: text,
      textStyle: dataLabelTextStyle,
      color: _dataPointColor(pointIndex),
    );
  }

  void _addToList(FunnelChartDataLabelPositioned child) {
    _builderChildren!.add(child);
  }

  void _addToLinkedList(FunnelChartDataLabelPositioned child) {
    _textChildren!.add(child);
  }

  void _buildDataLabels(
    _ChartDataLabelWidgetBuilder<T, D> callback,
    Function(FunnelChartDataLabelPositioned) add,
  ) {
    const List<ChartDataPointType> positions = ChartDataPointType.values;
    final int yLength = yLists?.length ?? 0;
    final int posAdj = _positionIndex(yLength);
    List<Object?>? actualXValues;
    if (xRawValues != null && xRawValues!.isNotEmpty) {
      actualXValues = xRawValues;
    } else {
      actualXValues = xValues;
    }

    if (actualXValues == null || renderer!.segments.isEmpty) {
      return;
    }

    for (int i = 0; i < renderer!.dataCount; i++) {
      _obtainLabel(i, actualXValues, yLength, positions, posAdj, callback, add);
    }
  }

  int _positionIndex(int yListsLength) {
    return yListsLength == 1 ? 0 : 1;
  }

  void _obtainLabel(
    int index,
    List<Object?> rawXValues,
    int yLength,
    List<ChartDataPointType> positions,
    int posAdj,
    _ChartDataLabelWidgetBuilder<T, D> callback,
    Function(FunnelChartDataLabelPositioned) add,
  ) {
    final num x = xValues![index];
    final ChartPoint<D> point = ChartPoint<D>(x: rawXValues[index] as D?);

    for (int k = 0; k < yLength; k++) {
      final List<num> yValues = yLists![k];
      point.y = yValues[index];
      final ChartDataPointType position = positions[k + posAdj];
      final FunnelChartDataLabelPositioned child =
          FunnelChartDataLabelPositioned(
            x: x,
            y: yValues[index],
            dataPointIndex: index,
            position: position,
            child: callback(
              widget.dataSource[index],
              point,
              widget.series,
              index,
              renderer!.index,
              position,
            ),
          );
      add(child);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChartElementLayoutBuilder<T, D>(
      state: this,
      builder: (BuildContext context, BoxConstraints constraints) {
        _ChartDataLabelWidgetBuilder<T, D> callback;
        _builderChildren?.clear();
        _textChildren?.clear();
        if (renderer != null &&
            renderer!.initialIsVisible &&
            yLists != null &&
            yLists!.isNotEmpty) {
          if (widget.builder != null) {
            callback = _dataLabelFromBuilder;
          } else {
            callback =
                widget.mapper != null
                    ? _dataLabelFromMapper
                    : _defaultDataLabel;
          }
          void Function(FunnelChartDataLabelPositioned child) add;
          if (widget.builder != null) {
            _builderChildren = <FunnelChartDataLabelPositioned>[];
            add = _addToList;
          } else {
            _textChildren = LinkedList<FunnelChartDataLabelPositioned>();
            add = _addToLinkedList;
          }

          if (xValues != null && xValues!.isNotEmpty) {
            _buildDataLabels(callback, add);
          }
        }

        return ChartFadeTransition(
          opacity: animation!,
          child: FunnelDataLabelStack<T, D>(
            series: renderer as FunnelSeriesRenderer<T, D>?,
            settings: widget.settings,
            labels: _textChildren,
            children: _builderChildren ?? <FunnelChartDataLabelPositioned>[],
          ),
        );
      },
    );
  }
}

class FunnelDataLabelStack<T, D> extends ChartElementStack {
  const FunnelDataLabelStack({
    super.key,
    required this.series,
    required this.labels,
    required this.settings,
    super.children,
  });

  final FunnelSeriesRenderer<T, D>? series;
  final LinkedList<FunnelChartDataLabelPositioned>? labels;
  final DataLabelSettings settings;

  @override
  RenderFunnelDataLabelStack<T, D> createRenderObject(BuildContext context) {
    return RenderFunnelDataLabelStack<T, D>()
      ..series = series
      ..labels = labels
      ..settings = settings;
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderFunnelDataLabelStack<T, D> renderObject,
  ) {
    super.updateRenderObject(context, renderObject);
    renderObject
      ..series = series
      ..labels = labels
      ..settings = settings;
  }
}

class RenderFunnelDataLabelStack<T, D> extends RenderChartElementStack {
  late FunnelSeriesRenderer<T, D>? series;
  late LinkedList<FunnelChartDataLabelPositioned>? labels;
  late DataLabelSettings settings;

  @override
  bool get sizedByParent => true;

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return false;
  }

  @override
  bool hitTestSelf(Offset position) {
    return series?.parent?.onDataLabelTapped != null &&
        _findSelectedDataLabelIndex(position) != -1;
  }

  int _findSelectedDataLabelIndex(Offset localPosition) {
    if (series?.parent?.onDataLabelTapped == null) {
      return -1;
    }

    if (childCount > 0) {
      RenderBox? child = lastChild;
      while (child != null) {
        final ChartElementParentData childParentData =
            child.parentData! as ChartElementParentData;
        if ((childParentData.offset & child.size).contains(localPosition)) {
          return childParentData.dataPointIndex;
        }
        child = childParentData.previousSibling;
      }
    } else if (labels != null) {
      for (int i = labels!.length - 1; i > -1; i--) {
        final FunnelChartDataLabelPositioned label = labels!.elementAt(i);
        final Rect rect = Rect.fromLTWH(
          label.offset.dx,
          label.offset.dy,
          label.size.width + settings.margin.horizontal,
          label.size.height + settings.margin.vertical,
        );
        if (rect.contains(localPosition)) {
          return label.dataPointIndex;
        }
      }
    }
    return -1;
  }

  @override
  void handleTapUp(Offset localPosition) {
    if (series?.parent?.onDataLabelTapped != null) {
      final int selectedIndex = _findSelectedDataLabelIndex(localPosition);
      if (selectedIndex == -1) {
        return;
      }

      final String text =
          childCount > 0
              ? ''
              : (labels!.elementAt(selectedIndex).child as DataLabelText).text;
      series!.parent!.onDataLabelTapped!(
        DataLabelTapDetails(
          series!.index,
          series!.viewportIndex(selectedIndex),
          text,
          settings,
          selectedIndex,
        ),
      );
    }
  }

  @override
  void setupParentData(RenderObject child) {
    if (child is! ChartElementParentData) {
      child.parentData = ChartElementParentData();
    }
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return constraints.biggest;
  }

  @override
  void performLayout() {
    if (series == null) {
      return;
    }

    if (childCount > 0) {
      RenderBox? child = firstChild;
      while (child != null) {
        final ChartElementParentData currentChildData =
            child.parentData! as ChartElementParentData;
        final RenderBox? nextSibling = currentChildData.nextSibling;
        child.layout(constraints, parentUsesSize: true);
        currentChildData.offset = series!.dataLabelPosition(
          currentChildData,
          child.size,
        );
        final Offset offset = _invokeDataLabelRender(
          currentChildData.dataPointIndex,
        );
        currentChildData.offset = Offset(
          currentChildData.offset.dx + offset.dx,
          currentChildData.offset.dy - offset.dy,
        );
        // TODO(Praveen): Builder works only for inner and outer position,
        // Need to handle for intersection.
        child = nextSibling;
      }
    } else if (labels != null) {
      for (final FunnelChartDataLabelPositioned currentLabel in labels!) {
        final ChartElementParentData currentLabelData =
            ChartElementParentData()
              ..x = currentLabel.x
              ..y = currentLabel.y
              ..dataPointIndex = currentLabel.dataPointIndex
              ..position = currentLabel.position;
        final DataLabelText details = currentLabel.child as DataLabelText;
        final Offset offset = _invokeDataLabelRender(
          currentLabel.dataPointIndex,
          details,
        );
        currentLabel.offset = Offset(
          currentLabel.offset.dx + offset.dx,
          currentLabel.offset.dy - offset.dy,
        );
        currentLabel.size = measureText(details.text, details.textStyle);
        currentLabel.offset += series!.dataLabelPosition(
          currentLabelData,
          currentLabel.size,
        );
        currentLabel.connectorPath = _calculateConnectorPath(
          currentLabel.dataPointIndex,
          currentLabel.offset,
          currentLabel.size,
        );
      }
    }
  }

  Path _calculateConnectorPath(int index, Offset offset, Size size) {
    final int segmentsLastIndex = series!.segments.length - 1;
    final List<Offset> points =
        series!.segments[segmentsLastIndex - index].points;
    final double startPoint = (points[1].dx + points[2].dx) / 2;
    final double endPoint = offset.dx;
    final double y = offset.dy + size.height / 2;
    return Path()
      ..moveTo(startPoint, y)
      ..lineTo(endPoint, y);
  }

  Offset _invokeDataLabelRender(int pointIndex, [DataLabelText? details]) {
    if (series!.parent?.onDataLabelRender != null) {
      final DataLabelRenderArgs dataLabelArgs = DataLabelRenderArgs(
        seriesRenderer: series,
        dataPoints: series!.chartPoints,
        viewportPointIndex: pointIndex,
        pointIndex: pointIndex,
      )..offset = settings.offset;
      if (details != null) {
        dataLabelArgs
          ..text = details.text
          ..textStyle = details.textStyle
          ..color = details.color;
      }

      series!.parent!.onDataLabelRender!(dataLabelArgs);
      if (details != null) {
        details
          ..text = dataLabelArgs.text ?? ''
          ..textStyle = details.textStyle.merge(dataLabelArgs.textStyle)
          ..color = dataLabelArgs.color;
      }

      return dataLabelArgs.offset;
    }

    return settings.offset;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.canvas
      ..save()
      ..clipRect(paintBounds);
    if (childCount > 0) {
      defaultPaint(context, offset);
    } else if (labels != null) {
      final List<RRect> previousRect = <RRect>[];
      final Paint fillPaint = Paint();
      final Paint strokePaint =
          Paint()
            ..color = settings.borderColor
            ..strokeWidth = settings.borderWidth
            ..style = PaintingStyle.stroke;
      for (final FunnelChartDataLabelPositioned label in labels!) {
        final DataLabelText details = label.child as DataLabelText;
        fillPaint.color = details.color;
        series!.drawDataLabelWithBackground(
          label.dataPointIndex,
          context.canvas,
          details.text,
          label.size,
          label.offset,
          settings.angle,
          details.textStyle,
          fillPaint,
          strokePaint,
          label.connectorPath,
          previousRect,
        );
      }
    }
    context.canvas.restore();
  }
}
