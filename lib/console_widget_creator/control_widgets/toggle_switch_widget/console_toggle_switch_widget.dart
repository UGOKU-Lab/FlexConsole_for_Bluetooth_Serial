import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flex_console_for_bluetooth_serial/console_widget_creator/console_error_widget_creator.dart';
import 'package:flex_console_for_bluetooth_serial/console_widget_creator/control_widgets/toggle_switch_widget/console_toggle_switch_widget_property.dart';
import 'package:flex_console_for_bluetooth_serial/util/widget/console_widget_card.dart';
import 'package:flex_console_for_bluetooth_serial/util/broadcaster/multi_channel_broadcaster.dart';

class ConsoleToggleSwitchWidget extends StatefulWidget {
  final ConsoleToggleSwitchWidgetProperty property;
  final MultiChannelBroadcaster? broadcaster;

  const ConsoleToggleSwitchWidget({
    super.key,
    required this.property,
    this.broadcaster,
  });

  @override
  State<ConsoleToggleSwitchWidget> createState() =>
      _ConsoleToggleSwitchWidgetState();
}

class _ConsoleToggleSwitchWidgetState extends State<ConsoleToggleSwitchWidget> {
  late double _value;
  bool _activate = false;

  StreamSubscription? _subscription;

  /// Sets the delta value and adds the value to the sink.
  void _toggleValue() {
    setState(() {
      _value = _value == widget.property.initialValue
          ? widget.property.reversedValue
          : widget.property.initialValue;
    });

    if (widget.property.channel != null) {
      widget.broadcaster
          ?.sinkOn(widget.property.channel!)
          ?.add(_value.toDouble());
    }
  }

  void _initState() {
    final latestValue = widget.property.channel != null
        ? widget.broadcaster?.read(widget.property.channel!)
        : null;

    _value = latestValue ?? widget.property.initialValue;

    // Broadcast the initial value.
    if (latestValue == null && widget.property.channel != null) {
      widget.broadcaster
          ?.sinkOn(widget.property.channel!)
          ?.add(_value.toDouble());
    }
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
        if (event == widget.property.initialValue) {
          _value = widget.property.initialValue;
        } else if (event == widget.property.reversedValue) {
          _value = widget.property.reversedValue;
        }
      });
    });
  }

  @override
  void initState() {
    // Initialize state.
    _initState();

    // Add a lister for the broadcasting.
    _initBroadcastListening();

    super.initState();
  }

  @override
  void didUpdateWidget(covariant ConsoleToggleSwitchWidget oldWidget) {
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
  Widget build(BuildContext context) {
    final paramError = widget.property.validate();
    if (paramError != null) {
      return ConsoleErrorWidgetCreator.createWith(
          brief: "Parameter Error", detail: paramError);
    }

    return LayoutBuilder(
      builder: (context, constraints) => ConsoleWidgetCard(
        activate: _activate,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _activate = true),
          onTapCancel: () => setState(() => _activate = false),
          onTap: () {
            setState(() {
              _activate = false;
              _toggleValue();
            });
          },
          onLongPress: () => {},
          child: Container(
            color: _value == widget.property.initialValue
                ? Theme.of(context).colorScheme.background
                : Theme.of(context).colorScheme.primary,
            child: Center(
              child: _value == widget.property.initialValue
                  ? Icon(Icons.toggle_off_outlined,
                      size:
                          min(constraints.maxHeight, constraints.maxWidth) / 2,
                      color: Theme.of(context).colorScheme.primary)
                  : Icon(Icons.toggle_on_outlined,
                      size:
                          min(constraints.maxHeight, constraints.maxWidth) / 2,
                      color: Theme.of(context).colorScheme.surface),
            ),
          ),
        ),
      ),
    );
  }
}
