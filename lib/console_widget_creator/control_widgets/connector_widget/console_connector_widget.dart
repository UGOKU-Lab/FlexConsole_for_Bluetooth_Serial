import 'dart:async';
import 'dart:math';

import 'package:flex_console_for_bluetooth_serial/console_widget_creator/control_widgets/connector_widget/console_connector_widget_property.dart';
import 'package:flutter/material.dart';
import 'package:flex_console_for_bluetooth_serial/util/widget/console_widget_card.dart';
import 'package:flex_console_for_bluetooth_serial/util/broadcaster/multi_channel_broadcaster.dart';

class ConsoleConnectorWidget extends StatefulWidget {
  final ConsoleConnectorWidgetProperty property;
  final MultiChannelBroadcaster? broadcaster;

  const ConsoleConnectorWidget({
    super.key,
    required this.property,
    this.broadcaster,
  });

  @override
  State<ConsoleConnectorWidget> createState() => _ConsoleConnectorWidgetState();
}

class _ConsoleConnectorWidgetState extends State<ConsoleConnectorWidget> {
  double? _value;

  bool _on = true;

  bool _activate = false;

  StreamSubscription<double>? _subscription;

  void _initBroadcastListening() {
    _subscription?.cancel();
    _subscription = null;

    if (widget.property.channelSrc == null) {
      return;
    }

    _subscription = widget.broadcaster
        ?.streamOn(widget.property.channelSrc!)
        ?.listen((event) {
      _setValue(event);

      if (_on && widget.property.channelDst != null) {
        widget.broadcaster?.sinkOn(widget.property.channelDst!)?.add(event);
      }
    });
  }

  /// Sets the state [_value] to [value].
  void _setValue(double value) {
    setState(() {
      _value = value;
    });
  }

  /// Sets the state [_activate] to [activated].
  void _setActivate(bool activated) {
    setState(() {
      _activate = activated;
    });
  }

  @override
  void initState() {
    super.initState();

    _initBroadcastListening();
  }

  @override
  void didUpdateWidget(covariant ConsoleConnectorWidget oldWidget) {
    if (widget.broadcaster != oldWidget.broadcaster ||
        widget.property.channelSrc != oldWidget.property.channelSrc) {
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
      child: LayoutBuilder(
        builder: (context, constraints) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => setState(() => _activate = true),
          onTapCancel: () => setState(() => _activate = false),
          onTap: () {
            setState(() {
              _activate = false;
              _on = !_on;
            });
          },
          onLongPress: () => {},
          child: Container(
            color: _on
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surface,
            child: Center(
              child: _on
                  ? Icon(Icons.directions_outlined,
                      size:
                          min(constraints.maxHeight, constraints.maxWidth) / 2,
                      color: Theme.of(context).colorScheme.surface)
                  : Icon(Icons.directions_off_outlined,
                      size:
                          min(constraints.maxHeight, constraints.maxWidth) / 2,
                      color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ),
      ),
    );
  }
}
