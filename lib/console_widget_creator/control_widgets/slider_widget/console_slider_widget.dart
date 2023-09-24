import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flex_console_for_bluetooth_serial/console_widget_creator/console_error_widget_creator.dart';
import 'package:flex_console_for_bluetooth_serial/console_widget_creator/control_widgets/slider_widget/console_slider_widget_property.dart';
import 'package:flex_console_for_bluetooth_serial/util/widget/console_widget_card.dart';
import 'package:flex_console_for_bluetooth_serial/util/widget/handle_widget.dart';
import 'package:flex_console_for_bluetooth_serial/util/broadcaster/multi_channel_broadcaster.dart';

class ConsoleSliderWidget extends StatefulWidget {
  final ConsoleSliderWidgetProperty? property;
  final MultiChannelBroadcaster? broadcaster;
  final List<BroadcastChannel>? availableChannels;

  const ConsoleSliderWidget({
    super.key,
    this.property,
    this.broadcaster,
    this.availableChannels,
  });

  @override
  State<ConsoleSliderWidget> createState() => _ConsoleSliderWidgetState();
}

class _ConsoleSliderWidgetState extends State<ConsoleSliderWidget> {
  late ConsoleSliderWidgetProperty _prop;
  late double _rateOffset;
  double _rateDelta = 0;
  bool _activate = false;

  double? _prevValue;
  BroadcastChannel? _channel;
  StreamSubscription? _subscription;

  double get _rate => _rateOffset + _rateDelta;

  /// Sets the delta value and adds the value to the sink.
  void _setRateDelta(double rateDelta) {
    setState(() {
      _rateDelta = rateDelta.clamp(-_rateOffset, 1 - _rateOffset);
    });

    final value = ((_prop.maxValue - _prop.minValue) * _rate + _prop.minValue)
        .floorToDouble();

    if (_channel != null && _prevValue != value) {
      widget.broadcaster?.sinkOn(_channel!)?.add(value);
    }

    _prevValue = value;
  }

  /// Adds the delta to the value and sets the delta to zero.
  void _fixValue() {
    _rateOffset = _rate.clamp(0, 1);
    _rateDelta = 0;
  }

  @override
  void initState() {
    // Initialize members with the widget.
    _prop = widget.property ?? ConsoleSliderWidgetProperty();
    _rateOffset = ((_prop.initialValue - _prop.minValue) /
            (_prop.maxValue - _prop.minValue))
        .clamp(0, 1);
    _channel = widget.availableChannels
        ?.where((chan) => chan.identifier == _prop.channel)
        .firstOrNull;

    // Add a lister for the broadcasting.
    if (_channel != null) {
      _subscription?.cancel();

      _subscription = widget.broadcaster?.streamOn(_channel!)?.listen((event) {
        // Exit when already activated.
        if (_activate) return;

        // Update the value.
        if (mounted) {
          setState(() {
            _rateOffset =
                ((event - _prop.minValue) / (_prop.maxValue - _prop.minValue))
                    .clamp(0, 1);
            _rateDelta = 0;
          });
        }
      });
    }

    super.initState();
  }

  @override
  void didUpdateWidget(covariant ConsoleSliderWidget oldWidget) {
    if (widget.property != oldWidget.property) {
      // Initialize members with the widget.
      _prop = widget.property ?? ConsoleSliderWidgetProperty();
      _rateOffset = ((_prop.initialValue - _prop.minValue) /
              (_prop.maxValue - _prop.minValue))
          .clamp(0, 1);
      _channel = widget.availableChannels
          ?.where((chan) => chan.identifier == _prop.channel)
          .firstOrNull;
    }

    if (widget.broadcaster != oldWidget.broadcaster ||
        widget.property?.channel != oldWidget.property?.channel) {
      // Add a lister for the broadcasting.
      if (_channel != null) {
        _subscription?.cancel();

        _subscription =
            widget.broadcaster?.streamOn(_channel!)?.listen((event) {
          // Exit when already activated.
          if (_activate) return;

          // Update the value.
          if (mounted) {
            setState(() {
              _rateOffset =
                  ((event - _prop.minValue) / (_prop.maxValue - _prop.minValue))
                      .clamp(0, 1);
              _rateDelta = 0;
            });
          }
        });
      }
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final paramError = _prop.validate();
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
