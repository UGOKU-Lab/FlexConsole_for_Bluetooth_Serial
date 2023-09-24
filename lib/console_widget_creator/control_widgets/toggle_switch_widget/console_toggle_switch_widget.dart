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
  final List<BroadcastChannel>? availableChannels;

  const ConsoleToggleSwitchWidget({
    super.key,
    required this.property,
    this.broadcaster,
    this.availableChannels,
  });

  @override
  State<ConsoleToggleSwitchWidget> createState() =>
      _ConsoleToggleSwitchWidgetState();
}

class _ConsoleToggleSwitchWidgetState extends State<ConsoleToggleSwitchWidget> {
  late ConsoleToggleSwitchWidgetProperty _prop;
  late double _value;
  bool _activate = false;

  BroadcastChannel? _channel;
  StreamSubscription? _subscription;

  /// Sets the delta value and adds the value to the sink.
  void _toggleValue() {
    setState(() {
      _value = _value == _prop.initialValue
          ? _prop.reversedValue
          : _prop.initialValue;
    });

    if (_channel != null) {
      widget.broadcaster?.sinkOn(_channel!)?.add(_value.toDouble());
    }
  }

  @override
  void initState() {
    // Initialize members with the widget.
    _prop = widget.property;
    _value = _prop.initialValue;
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
            if (event == _prop.initialValue) {
              _value = _prop.initialValue;
            } else if (event == _prop.reversedValue) {
              _value = _prop.reversedValue;
            }
          });
        }
      });
    }

    super.initState();
  }

  @override
  void didUpdateWidget(covariant ConsoleToggleSwitchWidget oldWidget) {
    if (widget.property != oldWidget.property) {
      // Initialize members with the widget.
      _prop = widget.property;
      _value = _prop.initialValue;
      _channel = widget.availableChannels
          ?.where((chan) => chan.identifier == _prop.channel)
          .firstOrNull;
    }

    if (widget.broadcaster != oldWidget.broadcaster ||
        widget.property.channel != oldWidget.property.channel) {
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
              if (event == _prop.initialValue) {
                _value = _prop.initialValue;
              } else if (event == _prop.reversedValue) {
                _value = _prop.reversedValue;
              }
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
            color: _value == _prop.initialValue
                ? Theme.of(context).colorScheme.background
                : Theme.of(context).colorScheme.primary,
            child: Center(
              child: _value == _prop.initialValue
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
