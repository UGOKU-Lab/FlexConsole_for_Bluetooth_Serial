import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flex_console_for_bluetooth_serial/console_widget_creator/console_error_widget_creator.dart';
import 'package:flex_console_for_bluetooth_serial/console_widget_creator/control_widgets/slider_widget/console_slider_widget_property.dart';
import 'package:flex_console_for_bluetooth_serial/util/widget/console_widget_card.dart';
import 'package:flex_console_for_bluetooth_serial/util/widget/handle_widget.dart';
import 'package:flex_console_for_bluetooth_serial/util/broadcaster/multi_channel_broadcaster.dart';

class ConsoleSliderWidget extends StatefulWidget {
  final ConsoleSliderWidgetProperty property;
  final MultiChannelBroadcaster? broadcaster;

  const ConsoleSliderWidget({
    super.key,
    required this.property,
    this.broadcaster,
  });

  @override
  State<ConsoleSliderWidget> createState() => _ConsoleSliderWidgetState();
}

class _ConsoleSliderWidgetState extends State<ConsoleSliderWidget> {
  late double _rateOffset;
  double _rateDelta = 0;
  bool _activate = false;

  double? _prevValue;
  StreamSubscription? _subscription;

  double get _rate => _rateOffset + _rateDelta;

  /// Sets the delta value and adds the value to the sink.
  void _setRateDelta(double rateDelta, {bool broadcast = true}) {
    setState(() {
      _rateDelta = rateDelta.clamp(-_rateOffset, 1 - _rateOffset);
    });

    final valueWidth = widget.property.valueWidth;
    final minValue = widget.property.minValue;
    final value = (valueWidth * _rate + minValue).floorToDouble();

    if (broadcast && widget.property.channel != null && _prevValue != value) {
      widget.broadcaster?.sinkOn(widget.property.channel!)?.add(value);
    }

    _prevValue = value;
  }

  /// Sets the offset value.
  void _setRateOffset(double value) {
    final valueWidth = widget.property.valueWidth;
    final offsetValue = value - widget.property.minValue;

    _rateOffset = (offsetValue / valueWidth).clamp(0, 1);
  }

  /// Adds the delta to the value and sets the delta to zero.
  void _fixValue() {
    _rateOffset = _rate.clamp(0, 1);
    _rateDelta = 0;
  }

  void _initState() {
    final latestValue = widget.property.channel != null
        ? widget.broadcaster?.read(widget.property.channel!)
        : null;

    _setRateOffset(latestValue ?? widget.property.initialValue);
    _setRateDelta(0, broadcast: latestValue == null);
  }

  void _initBroadcastListening() {
    _subscription?.cancel();
    _subscription = null;

    if (widget.property.channel == null) {
      return;
    }

    _subscription =
        widget.broadcaster?.streamOn(widget.property.channel!)?.listen((event) {
      // Exit when already activated.
      if (_activate) return;

      // Update the value.
      setState(() {
        _setRateOffset(event);
        _setRateDelta(0, broadcast: false);
      });
    });
  }

  @override
  void initState() {
    _initState();

    _initBroadcastListening();

    super.initState();
  }

  @override
  void didUpdateWidget(covariant ConsoleSliderWidget oldWidget) {
    if (widget.property != oldWidget.property) {
      _initState();
    }

    if (widget.broadcaster != oldWidget.broadcaster ||
        widget.property.channel != oldWidget.property.channel) {
      _initBroadcastListening();
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _subscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paramError = widget.property.validate();
    if (paramError != null) {
      return ConsoleErrorWidgetCreator.createWith(
          brief: "Parameter Error", detail: paramError);
    }

    return ConsoleWidgetCard(
      activate: _activate,
      child: LayoutBuilder(
        builder: (context, constraints) => Stack(children: [
          Column(
            children: [
              Flexible(
                flex: (constraints.maxHeight * (1 - _rate)).floor(),
                child: Container(color: Theme.of(context).colorScheme.surface),
              ),
              Flexible(
                flex: (constraints.maxHeight * _rate).floor(),
                child: Container(color: Theme.of(context).colorScheme.primary),
              ),
            ],
          ),
          // Icon
          Center(
            child: Icon(
              Icons.arrow_upward,
              size: min(constraints.maxHeight, constraints.maxWidth) / 2,
              color: Color.lerp(Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.surface, _rate),
            ),
          ),
          // Gesture handle.
          HandleWidget(
            onValueChange: (_, dy) =>
                _setRateDelta(-dy / constraints.maxHeight),
            onValueFix: () => _fixValue(),
            onActivationChange: (act) => setState(() => _activate = act),
          ),
        ]),
      ),
    );
  }
}
