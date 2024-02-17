import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flex_console_for_bluetooth_serial/console_widget_creator/monitor_widgets/value_monitor_widget/console_value_monitor_widget_property.dart';
import 'package:flex_console_for_bluetooth_serial/util/widget/console_widget_card.dart';
import 'package:flex_console_for_bluetooth_serial/util/broadcaster/multi_channel_broadcaster.dart';

/// The adjuster to control a value with a slider and increment/decrement
/// buttons.
class ConsoleValueMonitorWidget extends StatefulWidget {
  /// The property of the widget.
  final ConsoleValueMonitorProperty property;

  /// The target broadcaster.
  final MultiChannelBroadcaster? broadcaster;

  /// The initial value to display on preview and sample.
  final double? initialValue;

  const ConsoleValueMonitorWidget({
    super.key,
    required this.property,
    this.broadcaster,
    this.initialValue,
  });

  @override
  State<ConsoleValueMonitorWidget> createState() =>
      _ConsoleValueMonitorWidgetState();
}

class _ConsoleValueMonitorWidgetState extends State<ConsoleValueMonitorWidget> {
  /// The monitoring value.
  late double? _value = widget.initialValue;

  /// Whether the display value should not update.
  bool _pausing = false;

  /// The subscription for the targe channel.
  StreamSubscription? _subscription;

  /// Updates the subscription.
  void _initBroadcastListening() {
    // Cancel the subscription anyway.
    _subscription?.cancel();
    _subscription = null;

    if (widget.property.channel == null) {
      return;
    }

    // Subscribe if required.
    _subscription =
        widget.broadcaster?.streamOn(widget.property.channel!)?.listen((event) {
      _setValue(event);
    });
  }

  /// Sets the state [_value] to [value].
  void _setValue(double value) {
    _value = value;

    if (!_pausing) {
      setState(() {});
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
    // Manage the lister for the broadcasting.
    _initBroadcastListening();

    super.initState();
  }

  @override
  void didUpdateWidget(covariant ConsoleValueMonitorWidget oldWidget) {
    // Manage the lister for the broadcasting.
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
      activate: _pausing,
      child: LayoutBuilder(
        builder: (context, constraints) => Stack(children: [
          Container(
            color: Theme.of(context).colorScheme.surface,
            alignment: Alignment.center,
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: constraints.maxHeight / 2,
                  child: FittedBox(
                    child: Text(
                        _value?.toStringAsFixed(
                                widget.property.displayFractionDigits) ??
                            "-",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary)),
                  ),
                ),
              ],
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
