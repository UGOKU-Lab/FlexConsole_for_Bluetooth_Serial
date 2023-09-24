import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flex_console_for_bluetooth_serial/console_widget_creator/typed_console_widget_creator.dart';
import 'package:flex_console_for_bluetooth_serial/util/form/common_form_page.dart';
import 'package:flex_console_for_bluetooth_serial/util/form/channel_selector.dart';
import 'package:flex_console_for_bluetooth_serial/util/form/double_field.dart';
import 'package:flex_console_for_bluetooth_serial/util/form/integer_field.dart';

import '../../console_widget_creator.dart';

/// The property of the console widget.
@immutable
class ConsoleLineChartWidgetProperty implements TypedConsoleWidgetProperty {
  /// The identifier of the channel to broadcast the control value.
  final String? channel;

  /// The min value of the area.
  final double minValue;

  /// The max value of the area.
  final double maxValue;

  /// The number of the sampling value.
  final int samples;

  /// The sampling period[ms].
  final int period;

  /// Creates a property.
  const ConsoleLineChartWidgetProperty({
    this.channel,
    this.minValue = 0,
    this.maxValue = 255,
    this.samples = 10,
    this.period = 100,
  });

  /// Creates a property from the untyped [property].
  ConsoleLineChartWidgetProperty.fromUntyped(ConsoleWidgetProperty property)
      : channel = selectAttributeAs(property, "channel", null),
        minValue = selectAttributeAs(property, "minValue", 0),
        maxValue = selectAttributeAs(property, "maxValue", 255),
        samples = selectAttributeAs(property, "samples", 10),
        period = selectAttributeAs(property, "period", 100);

  @override
  ConsoleWidgetProperty toUntyped() => {
        "channel": channel,
        "minValue": minValue,
        "maxValue": maxValue,
        "samples": samples,
        "period": period,
      };

  @override
  String? validate() {
    if (maxValue == minValue) {
      return "Max and min must be different.";
    }

    return null;
  }

  /// Edits interactively to create new property.
  static Future<ConsoleLineChartWidgetProperty?> create(
    BuildContext context, {
    ConsoleLineChartWidgetProperty? oldProperty,
  }) {
    final propCompleter = Completer<ConsoleLineChartWidgetProperty?>();
    final initial = oldProperty ?? const ConsoleLineChartWidgetProperty();

    // Attributes of the property for editing.
    String? newChannel = initial.channel;
    double newMinValue = initial.minValue;
    double newMaxValue = initial.maxValue;
    int newSamples = initial.samples;
    int newPeriod = initial.period;

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
              Text("Input Value",
                  style: Theme.of(context).textTheme.headlineMedium),
              DoubleInputField(
                  labelText: "Min Value",
                  initValue: newMinValue,
                  nullable: false,
                  onValueChange: (value) => newMinValue = value!,
                  valueValidator: (value) {
                    if (value! == newMaxValue) {
                      return "Min must be different from max.";
                    }
                    return null;
                  }),
              DoubleInputField(
                  labelText: "Max Value",
                  initValue: newMaxValue,
                  nullable: false,
                  onValueChange: (value) => newMaxValue = value!,
                  valueValidator: (value) {
                    if (value! == newMinValue) {
                      return "Max must be different from min.";
                    }
                    return null;
                  }),
              const Text(""),
              Text("Sampling",
                  style: Theme.of(context).textTheme.headlineMedium),
              IntInputField(
                  labelText: "Number of samplings",
                  initValue: newSamples,
                  maxValue: 100,
                  minValue: 2,
                  nullable: false,
                  onValueChange: (value) => newSamples = value!),
              IntInputField(
                  labelText: "Sampling period in [ms]",
                  initValue: newPeriod,
                  minValue: 10,
                  nullable: false,
                  onValueChange: (value) => newPeriod = value!),
              const Text(""),
            ],
          ),
        ),
      ),
    )
        .then((ok) {
      if (ok) {
        propCompleter.complete(ConsoleLineChartWidgetProperty(
          channel: newChannel,
          minValue: newMinValue,
          maxValue: newMaxValue,
          samples: newSamples,
          period: newPeriod,
        ));
      } else {
        propCompleter.complete(oldProperty);
      }
    });

    return propCompleter.future;
  }
}
