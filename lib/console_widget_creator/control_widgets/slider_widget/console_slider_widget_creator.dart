import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flex_console_for_bluetooth_serial/broadcaster_provider.dart';
import 'package:flex_console_for_bluetooth_serial/console_widget_creator/control_widgets/slider_widget/console_slider_widget.dart';
import 'package:flex_console_for_bluetooth_serial/console_widget_creator/control_widgets/slider_widget/console_slider_widget_property.dart';
import 'package:flex_console_for_bluetooth_serial/console_widget_creator/typed_console_widget_creator.dart';

/// The creator of volume slider.
final consoleSliderWidgetCreator = TypedConsoleWidgetCreator(
  ConsoleSliderWidgetProperty.fromUntyped,
  name: "Slider",
  description: "Controls a value by vertical swipes.",
  series: "Control Widgets",
  builder: (context, property) => Consumer(
    builder: (context, ref, _) => ConsoleSliderWidget(
      property: property,
      broadcaster: ref.watch(broadcasterProvider),
      availableChannels: ref.watch(availableChannelProvider).toList(),
    ),
  ),
  propertyCreator: ConsoleSliderWidgetProperty.edit,
  previewBuilder: (context, property) => ConsoleSliderWidget(
    property: property,
  ),
  sampleProperty:
      ConsoleSliderWidgetProperty(minValue: 0, maxValue: 255, initialValue: 64),
);
