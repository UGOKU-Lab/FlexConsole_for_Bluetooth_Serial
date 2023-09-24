import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flex_console_for_bluetooth_serial/console_widget_creator/monitor_widgets/line_chart_widget/console_line_chart_widget_property.dart';
import 'package:flex_console_for_bluetooth_serial/util/widget/console_widget_card.dart';
import 'package:flex_console_for_bluetooth_serial/util/broadcaster/multi_channel_broadcaster.dart';

/// A display widget that draws a line time chart.
class ConsoleLineChartWidget extends StatefulWidget {
  /// The property of the widget.
  final ConsoleLineChartWidgetProperty property;

  /// The target broadcaster.
  final MultiChannelBroadcaster? broadcaster;

  /// The available channels on the broadcaster.
  final List<BroadcastChannel>? availableChannels;

  /// The initial values to display on preview and sample.
  final List<double>? initialValues;

  /// Whether the widget should start sampling. (for preview and sample)
  final bool start;

  /// Creates a line chart widget.
  const ConsoleLineChartWidget({
    super.key,
    required this.property,
    this.broadcaster,
    this.availableChannels,
    this.initialValues,
    this.start = true,
  });

  @override
  State<ConsoleLineChartWidget> createState() => _ConsoleLineChartWidgetState();
}

class _ConsoleLineChartWidgetState extends State<ConsoleLineChartWidget> {
  /// The actual values.
  final _values = List<double>.empty(growable: true);

  /// The current value.
  late double _currentValue = widget.initialValues?.lastOrNull ?? 0;

  /// Whether the display value should not update.
  bool _pausing = false;

  /// The target broadcasting channel.
  BroadcastChannel? _channel;

  /// The subscription for the targe channel.
  StreamSubscription? _subscription;

  /// The timer to sample the value.
  Timer? _samplingTimer;

  /// Initialize members.
  void _initMember() {
    // Initialize values.
    _values.clear();
    _values.addAll(List.of(
        widget.initialValues ?? List.filled(widget.property.samples, 0)));

    // Initialize the channel to listen.
    _channel = widget.availableChannels
        ?.where((chan) => chan.identifier == widget.property.channel)
        .firstOrNull;
  }

  /// Updates the subscription.
  void _initSubscription() {
    // Cancel the subscription anyway.
    _subscription?.cancel();

    // Subscribe if required.
    if (_channel != null) {
      _subscription = widget.broadcaster?.streamOn(_channel!)?.listen((event) {
        _currentValue = event;
      });
    }
  }

  /// Updates the timer.
  void _initTimer() {
    // Cancel the timer anyway.
    _samplingTimer?.cancel();

    // Start periodic timer to sample the value.
    if (widget.start) {
      assert(widget.property.minValue != widget.property.maxValue);

      _samplingTimer = Timer.periodic(
          Duration(milliseconds: widget.property.period), (timer) {
        // Pop the oldest value and append the current value.
        _values.removeAt(0);
        _values.add((_currentValue - widget.property.minValue) /
            (widget.property.maxValue - widget.property.minValue));

        // Update the display.
        if (mounted && !_pausing) {
          setState(() {});
        }
      });
    }
  }

  /// Sets the state [_pausing] to [pausing]
  void _setPausing(bool pausing) {
    if (_pausing != pausing) {
      setState(() {
        _pausing = pausing;
      });
    }
  }

  @override
  void initState() {
    // Initialize the members.
    _initMember();

    // Manage the lister for the broadcasting.
    _initSubscription();

    // Setup the timer to update view.
    _initTimer();

    super.initState();
  }

  @override
  void didUpdateWidget(covariant ConsoleLineChartWidget oldWidget) {
    // Stop the timer before the initialization.
    _samplingTimer?.cancel();

    // Initialize members.
    if (widget.property != oldWidget.property) {
      _initMember();
    }

    // Manage the lister for the broadcasting.
    if (widget.broadcaster != oldWidget.broadcaster ||
        widget.property.channel != oldWidget.property.channel) {
      _initSubscription();
    }

    // Start the timer after all of other parameters have been updated.
    _initTimer();

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return ConsoleWidgetCard(
      activate: _pausing,
      child: LayoutBuilder(
        builder: (context, constraints) => Stack(children: [
          Container(
            color: Theme.of(context).colorScheme.surface,
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _ChartPainter(context, _values),
                size: Size(constraints.maxWidth, constraints.maxHeight),
              ),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (_) => _setPausing(true),
            onPanStart: (_) => _setPausing(true),
            onTapUp: (_) => _setPausing(false),
            onPanEnd: (_) => _setPausing(false),
          ),
        ]),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final BuildContext context;

  /// The list of y-values between 0 and 1.
  final Iterable<double> values;

  /// Creates a chart painter.
  _ChartPainter(this.context, this.values);

  @override
  void paint(Canvas canvas, Size size) {
    assert(values.isNotEmpty);

    final paint = Paint();

    const rightPadding = 10;

    // The dynamic drawing parameters.
    final unitSize = min(size.width, size.height) / values.length;
    final double lineWidth = max(unitSize / 4, 2);
    final double pointSize = unitSize * 2 / 3;

    final drawingSize = Size(
        size.width - pointSize / 2 - rightPadding, size.height - lineWidth);

    // The value points translated to the drawing area.
    final points = values.indexed.map((indexed) {
      final (index, value) = indexed;

      return Offset(drawingSize.width * index / (values.length - 1),
          (1 - value) * drawingSize.height + lineWidth / 2);
    }).toList();

    // Draw the background.
    paint.color = Theme.of(context).splashColor;

    final path = Path()
      ..addPolygon([
        Offset(0, size.height),
        ...points,
        Offset(points.last.dx, size.height),
      ], true);

    canvas.drawPath(path, paint);

    // Draw the foreground.
    paint.color = Theme.of(context).colorScheme.primary;

    canvas.drawPoints(
        PointMode.polygon, points, paint..strokeWidth = lineWidth);

    canvas.drawPoints(
        PointMode.points,
        points,
        paint
          ..strokeWidth = pointSize
          ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
