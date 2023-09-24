import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flex_console_for_bluetooth_serial/broadcaster_provider.dart';
import 'package:flex_console_for_bluetooth_serial/console_widget_creator/control_widgets/toggle_switch_widget/console_toggle_switch_widget.dart';
import 'package:flex_console_for_bluetooth_serial/console_widget_creator/control_widgets/toggle_switch_widget/console_toggle_switch_widget_property.dart';
import 'package:flex_console_for_bluetooth_serial/console_widget_creator/typed_console_widget_creator.dart';

/// The creator of a toggle switch.
final consoleToggleSwitchWidgetCreator = TypedConsoleWidgetCreator(
  ConsoleToggleSwitchWidgetProperty.fromUntyped,
  name: "Toggle Switch",
  description: "Switches values each time you tap.",
  series: "Control Widgets",
  builder: (context, property) => Consumer(
    builder: (context, ref, _) => ConsoleToggleSwitchWidget(
      property: property,
      broadcaster: ref.watch(broadcasterProvider),
      availableChannels: ref.watch(availableChannelProvider).toList(),
    ),
  ),
  previewBuilder: (context, property) => ConsoleToggleSwitchWidget(
    property: property,
  ),
  propertyCreator: ConsoleToggleSwitchWidgetProperty.edit,
);
