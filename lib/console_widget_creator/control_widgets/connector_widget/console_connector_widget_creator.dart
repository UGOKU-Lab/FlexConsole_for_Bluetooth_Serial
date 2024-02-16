import 'package:flex_console_for_bluetooth_serial/console_widget_creator/control_widgets/connector_widget/console_connector_widget.dart';
import 'package:flex_console_for_bluetooth_serial/console_widget_creator/control_widgets/connector_widget/console_connector_widget_property.dart';
import 'package:flex_console_for_bluetooth_serial/console_widget_creator/typed_console_widget_creator.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flex_console_for_bluetooth_serial/broadcaster_provider.dart';

/// The creator of a joystick.
final consoleConnectorWidgetCreator =
    TypedConsoleWidgetCreator<ConsoleConnectorWidgetProperty>(
  ConsoleConnectorWidgetProperty.fromUntyped,
  name: "Connector",
  description: "Passes values from source to destination channel.",
  series: "Control Widgets",
  builder: (context, property) => Consumer(
    builder: (context, ref, _) => ConsoleConnectorWidget(
      property: property,
      broadcaster: ref.watch(broadcasterProvider),
    ),
  ),
  previewBuilder: (context, property) => ConsoleConnectorWidget(
    property: property,
  ),
  propertyCreator: ConsoleConnectorWidgetProperty.edit,
);
