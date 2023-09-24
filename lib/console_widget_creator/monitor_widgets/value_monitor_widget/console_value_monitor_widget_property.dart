import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flex_console_for_bluetooth_serial/console_widget_creator/typed_console_widget_creator.dart';
import 'package:flex_console_for_bluetooth_serial/util/form/common_form_page.dart';
import 'package:flex_console_for_bluetooth_serial/util/form/channel_selector.dart';
import 'package:flex_console_for_bluetooth_serial/util/form/integer_field.dart';

import '../../console_widget_creator.dart';

/// The property of the console widget.
class ConsoleValueMonitorProperty implements TypedConsoleWidgetProperty {
  /// The identifier of the channel to broadcast the control value.
  final String? channel;

  final int displayFractionDigits;

  /// Creates a property.
  ConsoleValueMonitorProperty({
    this.channel,
    this.displayFractionDigits = 0,
  });

  /// Creates a property from the untyped [property].
  ConsoleValueMonitorProperty.fromUntyped(ConsoleWidgetProperty property)
      : channel = selectAttributeAs(property, "channel", null),
        displayFractionDigits =
            selectAttributeAs(property, "displayFractionDigits", 0);

  @override
  ConsoleWidgetProperty toUntyped() => {
        "channel": channel,
        "displayFractionDigits": displayFractionDigits,
      };

  @override
  String? validate() {
    if (displayFractionDigits < 0 || displayFractionDigits > 20) {
      return "Display precision must be in the range 0-20.";
    }

    return null;
  }

  /// Edits interactively to create new property.
  static Future<ConsoleValueMonitorProperty?> create(
    BuildContext context, {
    ConsoleValueMonitorProperty? oldProperty,
  }) {
    final propCompleter = Completer<ConsoleValueMonitorProperty?>();
    final initial = oldProperty ?? ConsoleValueMonitorProperty();

    // Attributes of the property for editing.
    String? newChannel = initial.channel;
    int newDisplayPrecision = initial.displayFractionDigits;

    // Show a form to edit above attributes.
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => CommonFormPage(
          title: "Property Edit",
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(""),
              Text("Input Channel",
                  style: Theme.of(context).textTheme.headlineMedium),
              ChannelSelector(
                  initialValue: newChannel,
                  onChanged: (value) => newChannel = value),
              const Text(""),
              Text("Display",
                  style: Theme.of(context).textTheme.headlineMedium),
              IntInputField(
                labelText: "Fraction digits",
                initValue: newDisplayPrecision,
                // Max and min are limited by [double.toStringAsFixed].
                minValue: 0,
                maxValue: 20,
                nullable: false,
                onValueChange: (value) => newDisplayPrecision = value!,
              ),
            ],
          ),
        ),
      ),
    )
        .then((ok) {
      if (ok) {
        propCompleter.complete(ConsoleValueMonitorProperty(
          channel: newChannel,
          displayFractionDigits: newDisplayPrecision,
        ));
      } else {
        propCompleter.complete(oldProperty);
      }
    });

    return propCompleter.future;
  }
}
