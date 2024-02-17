import 'dart:async';

import 'package:flex_console_for_bluetooth_serial/console_widget_creator/typed_console_widget_creator.dart';
import 'package:flutter/material.dart';
import 'package:flex_console_for_bluetooth_serial/util/form/common_form_page.dart';
import 'package:flex_console_for_bluetooth_serial/util/form/channel_selector.dart';

import '../../console_widget_creator.dart';

/// Parameter of the console widget.
class ConsoleConnectorWidgetProperty extends TypedConsoleWidgetProperty {
  /// The identifier of the source channel.
  final String? channelSrc;

  /// The identifier of the destination channel.
  final String? channelDst;

  /// Creates the parameter.
  ConsoleConnectorWidgetProperty({
    this.channelSrc,
    this.channelDst,
  });

  /// Creates the parameter from an [prop].
  factory ConsoleConnectorWidgetProperty.fromUntyped(
      ConsoleWidgetProperty prop) {
    return ConsoleConnectorWidgetProperty(
      channelSrc: selectAttributeAs(prop, "channelSrc", null),
      channelDst: selectAttributeAs(prop, "channelDst", null),
    );
  }

  /// Creates the property of itself.
  @override
  ConsoleWidgetProperty toUntyped() {
    return {
      "channelSrc": channelSrc,
      "channelDst": channelDst,
    };
  }

  @override
  String? validate() {
    if (channelSrc != null && channelDst != null && channelSrc == channelDst) {
      return "Source and destination must be different.";
    }

    return null;
  }

  static Future<ConsoleConnectorWidgetProperty?> edit(BuildContext context,
      {ConsoleConnectorWidgetProperty? oldProperty}) {
    final propCompleter = Completer<ConsoleConnectorWidgetProperty?>();
    final initial = oldProperty ?? ConsoleConnectorWidgetProperty();

    // Attributes of the parameter for editing.
    String? newChannelSrc = initial.channelSrc;
    String? newChannelDst = initial.channelDst;

    // Show a form to edit above parameters.
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => CommonFormPage(
          title: "Property Edit",
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(""),
              Text("Output Channel",
                  style: Theme.of(context).textTheme.headlineMedium),
              ChannelSelector(
                labelText: "Source",
                initialValue: newChannelSrc,
                onChanged: (value) => newChannelSrc = value,
                validator: (src) {
                  if (src != null && src == newChannelDst) {
                    return "Source and destination must be different.";
                  }

                  return null;
                },
              ),
              ChannelSelector(
                labelText: "Destination",
                initialValue: newChannelDst,
                onChanged: (value) => newChannelDst = value,
                validator: (dst) {
                  if (dst != null && dst == newChannelSrc) {
                    return "Source and destination must be different.";
                  }

                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    )
        .then((ok) {
      if (ok) {
        propCompleter.complete(ConsoleConnectorWidgetProperty(
          channelSrc: newChannelSrc,
          channelDst: newChannelDst,
        ));
      } else {
        propCompleter.complete(oldProperty);
      }
    });

    return propCompleter.future;
  }
}
