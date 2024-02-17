import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flex_console_for_bluetooth_serial/console_widget_creator/control_widgets/adjuster_widget/console_adjuster_widget_property.dart';
import 'package:flex_console_for_bluetooth_serial/util/widget/console_widget_card.dart';
import 'package:flex_console_for_bluetooth_serial/util/broadcaster/multi_channel_broadcaster.dart';

/// Creates a adjuster to control a value with a slider and increment/decrement
/// buttons.
class ConsoleAdjusterWidget extends StatefulWidget {
  /// The property of the widget.
  final ConsoleAdjusterWidgetProperty property;

  /// The target broadcaster.
  final MultiChannelBroadcaster? broadcaster;

  const ConsoleAdjusterWidget({
    super.key,
    required this.property,
    this.broadcaster,
  });

  @override
  State<ConsoleAdjusterWidget> createState() => _ConsoleAdjusterWidgetState();
}

class _ConsoleAdjusterWidgetState extends State<ConsoleAdjusterWidget> {
  /// The step of the controlled value in range 0-[widget.property.divisions].
  late int _step;

  /// The size of the step to convert [_step] to [_value].
  late double _stepSize;

  /// Whether the widget is activated.
  bool _activate = false;

  /// The subscription for the targe channel.
  StreamSubscription? _subscription;

  /// The cache of the [_step] broadcasted previously.
  int? _prevStep;

  /// The value determined by [_step].
  double get _value => _step * _stepSize + widget.property.minValue;

  /// Converts the value to the step.
  int _valueToStep(double value) {
    return ((value - widget.property.minValue) / _stepSize).round();
  }

  /// Updates members with widget.
  void _initState() {
    _stepSize = ((widget.property.maxValue - widget.property.minValue) /
        widget.property.divisions);

    final latestValue = widget.property.channel != null
        ? widget.broadcaster?.read(widget.property.channel!)
        : null;

    _setStep(
      _valueToStep(latestValue ?? widget.property.initialValue),
      broadcast: latestValue == null,
    );
  }

  /// Updates the subscription.
  void _initBroadcastListening() {
    _subscription?.cancel();
    _subscription = null;

    if (widget.property.channel != null) {
      _subscription = widget.broadcaster
          ?.streamOn(widget.property.channel!)
          ?.listen((event) {
        // Exit when already activated.
        if (_activate) return;

        // Update the value without the broadcasting.
        // NOTE: The echo back broadcasting can causes the convergence.
        if (mounted) {
          _setStep(_valueToStep(event), broadcast: false);
        }
      });
    }
  }

  /// Set the state [_step] to [step] with the arrangement and broadcast to the
  /// stream if [broadcast] is true.
  void _setStep(int step, {required bool broadcast}) {
    // Set the value with the limitation in the property.
    setState(() {
      if (step < 0) {
        _step = 0;
      } else if (step > widget.property.divisions) {
        _step = widget.property.divisions;
      } else {
        _step = step;
      }
    });

    // Compare with the previous value to avoid the meaningless streaming.
    if (_step != _prevStep) {
      _prevStep = _step;

      if (broadcast && widget.property.channel != null) {
        widget.broadcaster?.sinkOn(widget.property.channel!)?.add(_value);
      }
    }
  }

  /// Set the state [_activate] to [activate].
  void _setActivate(bool activate) {
    setState(() {
      _activate = activate;
    });
  }

  @override
  void initState() {
    _initState();

    _initBroadcastListening();

    super.initState();
  }

  @override
  void didUpdateWidget(covariant ConsoleAdjusterWidget oldWidget) {
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
    return ConsoleWidgetCard(
      activate: _activate,
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        child: Column(children: [
          Flexible(
            flex: 2,
            fit: FlexFit.tight,
            child: FittedBox(
              child: Text(_value
                  .toStringAsFixed(widget.property.displayFractionDigits)),
            ),
          ),
          Flexible(
            flex: 1,
            child: Row(
              children: [
                Flexible(
                  flex: 1,
                  child: Center(
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(Icons.remove,
                          color: Theme.of(context).colorScheme.primary),
                      onPressed: () => _setStep(_step - 1, broadcast: true),
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Center(
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(Icons.add,
                          color: Theme.of(context).colorScheme.primary),
                      onPressed: () => _setStep(_step + 1, broadcast: true),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            flex: 2,
            child: SliderTheme(
              data: const SliderThemeData(overlayColor: Colors.transparent),
              child: Slider(
                min: widget.property.minValue,
                max: widget.property.maxValue,
                value: _value,
                onChanged: (value) =>
                    _setStep(_valueToStep(value), broadcast: true),
                onChangeStart: (value) => _setActivate(true),
                onChangeEnd: (value) => _setActivate(false),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
