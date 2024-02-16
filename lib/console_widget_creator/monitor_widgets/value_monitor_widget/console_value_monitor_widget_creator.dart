import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flex_console_for_bluetooth_serial/broadcaster_provider.dart';
import 'package:flex_console_for_bluetooth_serial/console_widget_creator/monitor_widgets/value_monitor_widget/console_value_monitor_widget.dart';
import 'package:flex_console_for_bluetooth_serial/console_widget_creator/monitor_widgets/value_monitor_widget/console_value_monitor_widget_property.dart';
import 'package:flex_console_for_bluetooth_serial/console_widget_creator/typed_console_widget_creator.dart';

/// Creates the adjuster that adjusts a value with a slider and increments/
/// decremental buttons.
final consoleValueMonitorWidgetCreator = TypedConsoleWidgetCreator(
  ConsoleValueMonitorProperty.fromUntyped,
  name: "Value Monitor",
  description: "Displays a value.",
  series: "Monitor Widgets",
  propertyCreator: ConsoleValueMonitorProperty.create,
  builder: (context, property) => Consumer(
    builder: (context, ref, _) => ConsoleValueMonitorWidget(
      property: property,
      broadcaster: ref.watch(broadcasterProvider),
    ),
  ),
  previewBuilder: (context, property) => ConsoleValueMonitorWidget(
    property: property,
    initialValue: 0,
  ),
  sampleBuilder: (context) => ConsoleValueMonitorWidget(
    property: ConsoleValueMonitorProperty(),
    initialValue: 64,
  ),
);
