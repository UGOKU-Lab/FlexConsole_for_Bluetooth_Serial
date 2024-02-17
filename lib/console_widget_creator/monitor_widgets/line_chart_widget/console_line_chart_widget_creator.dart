import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flex_console_for_bluetooth_serial/broadcaster_provider.dart';
import 'package:flex_console_for_bluetooth_serial/console_widget_creator/monitor_widgets/line_chart_widget/console_line_chart_widget.dart';
import 'package:flex_console_for_bluetooth_serial/console_widget_creator/monitor_widgets/line_chart_widget/console_line_chart_widget_property.dart';
import 'package:flex_console_for_bluetooth_serial/console_widget_creator/typed_console_widget_creator.dart';

/// Creates the adjuster that adjusts a value with a slider and increments/
/// decremental buttons.
final consoleLineChartWidgetCreator = TypedConsoleWidgetCreator(
  ConsoleLineChartWidgetProperty.fromUntyped,
  name: "Line Chart",
  description: "Displays a line chart.",
  series: "Monitor Widgets",
  propertyCreator: ConsoleLineChartWidgetProperty.create,
  builder: (context, property) => Consumer(
    builder: (context, ref, _) => ConsoleLineChartWidget(
      property: property,
      broadcaster: ref.watch(broadcasterProvider),
    ),
  ),
  previewBuilder: (context, property) => ConsoleLineChartWidget(
    property: property,
    initialValues: List.filled(property.samples, 0.5),
    start: false,
  ),
  sampleBuilder: (context) => const ConsoleLineChartWidget(
    property: ConsoleLineChartWidgetProperty(),
    initialValues: [0.4, 0.6, 0.5, 0.6],
    start: false,
  ),
);
