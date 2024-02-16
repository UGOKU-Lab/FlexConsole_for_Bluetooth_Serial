import 'dart:async';
import 'dart:math';

import 'package:flex_console_for_bluetooth_serial/console_widget_creator/control_widgets/connector_widget/console_connector_widget_creator.dart';
import 'package:flutter/material.dart';
import 'package:flex_console_for_bluetooth_serial/console_widget_creator/control_widgets/adjuster_widget/console_adjuster_widget_creator.dart';
import 'package:flex_console_for_bluetooth_serial/console_widget_creator/control_widgets/joystick_widget/console_joystick_widget_creator.dart';
import 'package:flex_console_for_bluetooth_serial/console_widget_creator/control_widgets/toggle_switch_widget/console_toggle_switch_widget_creator.dart';
import 'package:flex_console_for_bluetooth_serial/console_widget_creator/console_error_widget_creator.dart';
import 'package:flex_console_for_bluetooth_serial/console_widget_creator/control_widgets/slider_widget/console_slider_widget_creator.dart';
import 'package:flex_console_for_bluetooth_serial/console_widget_creator/decoration_widgets/console_headline_text_widget_creator.dart';
import 'package:flex_console_for_bluetooth_serial/console_widget_creator/decoration_widgets/console_note_widget_creator.dart';
import 'package:flex_console_for_bluetooth_serial/console_widget_creator/decoration_widgets/console_title_text_widget_creator.dart';
import 'package:flex_console_for_bluetooth_serial/console_widget_creator/monitor_widgets/line_chart_widget/console_line_chart_widget_creator.dart';
import 'package:flex_console_for_bluetooth_serial/console_widget_creator/monitor_widgets/value_monitor_widget/console_value_monitor_widget_creator.dart';

import 'console_widget_creator.dart';

/// A factory for all [ConsoleWidgetCreator]s available to the user.
///
/// This factory builds a selector of the creators to the users. The selector
/// lists all available creators with it's name, description and sample. The
/// selected creator will be passed through [onCreatorSelected] callback as it's
/// name.
///
/// The selected creator can be used to build a console widget through
/// [consoleBuilder], and a editor widget to edit the property through
/// [editorBuilder].
class ConsoleCreatorFactoryWidget extends StatelessWidget {
  /// The list of all creators available to the user.
  static final List<ConsoleWidgetCreator> _creators = [
    // Control widgets.
    consoleToggleSwitchWidgetCreator,
    consoleSliderWidgetCreator,
    consoleJoystickWidgetCreator,
    consoleAdjusterWidgetCreator,
    consoleConnectorWidgetCreator,
    // Monitor widgets.
    consoleValueMonitorWidgetCreator,
    consoleLineChartWidgetCreator,
    // Decoration widgets.
    consoleHeadlineTextWidgetCreator,
    consoleTitleTextWidgetCreator,
    consoleNoteWidgetCreator,
  ];

  /// The callback function to notify the selected creator's name.
  ///
  /// The passed name can be used to [consoleBuilder] and [editorBuilder] to
  /// build a console widget and a editor widget, respectively.
  final void Function(String creator)? onCreatorSelected;

  const ConsoleCreatorFactoryWidget({
    super.key,
    this.onCreatorSelected,
  });

  /// Builds a console widget of the creator named [creatorName], with the
  /// [property].
  ///
  /// This invokes [ConsoleWidgetCreator.builder] of the creator.
  static Widget consoleBuilder(
    BuildContext context,
    String creatorName, {
    required ConsoleWidgetProperty property,
  }) {
    final creator = _getCreator(creatorName);
    return creator.builder(context, property);
  }

  /// Builds a editor widget of the creator named [creatorName], with the
  /// [initialProperty].
  ///
  /// The editor widget invokes the creator to create a new property on tap. The
  /// created property will be applied to the inner preview widget, and passed
  /// to [onPropertyChange] callback even if there are no value changes.  If
  /// [initialProperty] is not given, invokes the creator to create a new
  /// property on the first build without a tap action.
  ///
  /// [onLongPress] callback will be called on the long press. This callback is
  /// typically used to the higher level controls such as "delete widget".
  ///
  /// This builder is a wrapper of [_PropertyEditWidget].
  static Widget editorBuilder(
    BuildContext context,
    String creatorName, {
    void Function(ConsoleWidgetProperty?)? onPropertyChange,
    void Function()? onLongPress,
    ConsoleWidgetProperty? initialProperty,
  }) {
    final creator = _getCreator(creatorName);
    return _PropertyEditWidget(creator,
        onPropertyEdited: onPropertyChange,
        onLongPress: onLongPress,
        initialProperty: initialProperty);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      style: IconButton.styleFrom(shape: const BeveledRectangleBorder()),
      icon: LayoutBuilder(
        builder: (context, constraints) => Center(
          child: Icon(
            Icons.add,
            size: min(constraints.maxHeight, constraints.maxWidth) / 2,
            color: Theme.of(context).disabledColor,
          ),
        ),
      ),
      onPressed: () async {
        final ConsoleWidgetCreator? creator = await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          showDragHandle: true,
          builder: (context) => LayoutBuilder(
            builder: (context, constraints) => ListView(
              children: [
                ..._creators.map((creator) => creator.series).toSet().map(
                      (series) => ExpansionTile(
                        title: Text(series),
                        children: _creators
                            .where((creator) => creator.series == series)
                            .map(
                              (creator) => SizedBox(
                                height: constraints.maxWidth / 4,
                                child: Stack(
                                  children: [
                                    Container(
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.all(4),
                                      child: Row(
                                        children: [
                                          AspectRatio(
                                            aspectRatio: 1,
                                            child:
                                                creator.sampleBuilder(context),
                                          ),
                                          Expanded(
                                            child: Align(
                                              alignment:
                                                  AlignmentDirectional.topStart,
                                              child: ListTile(
                                                title: Text(
                                                  creator.name,
                                                  overflow: TextOverflow.fade,
                                                ),
                                                subtitle: Text(
                                                  creator.description,
                                                  overflow: TextOverflow.fade,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    TextButton(
                                      style: TextButton.styleFrom(
                                          shape:
                                              const BeveledRectangleBorder()),
                                      onPressed: () =>
                                          Navigator.of(context).pop(creator),
                                      child: Container(),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
              ],
            ),
          ),
        );

        if (creator != null) {
          onCreatorSelected?.call(creator.name);
        }
      },
    );
  }

  /// Returns a creator named [name].
  ///
  /// If there are no such creator, returns [ConsoleErrorWidgetCreator].
  static ConsoleWidgetCreator _getCreator(String name) {
    return [..._creators, ConsoleErrorWidgetCreator()]
            .where((c) => c.name == name)
            .firstOrNull ??
        ConsoleErrorWidgetCreator(
            brief: 'No widget named "$name"',
            detail: 'Failed to get a creator with name "$name".');
  }
}

/// Creates a editor of the console widget's property.
///
/// Builds a widget that invokes the [creator] to create a new property on tap.
/// The created property will be applied to the inner preview widget, and passed
/// to [onPropertyEdited] callback even if there are no value changes. If
/// [initialProperty] is not given, invokes the [creator] to create a new
/// property on the first build without a tap action.
///
/// [onLongPress] callback will be called on the long press. This callback is
/// typically used to the higher level controls such as "delete widget".
class _PropertyEditWidget extends StatefulWidget {
  /// The creator of the console widget.
  final ConsoleWidgetCreator creator;

  /// The callback function called on the property change.
  final void Function(ConsoleWidgetProperty?)? onPropertyEdited;

  /// The callback function called on the long press.
  final void Function()? onLongPress;

  /// The initial property of the console widget. If null, then invokes the
  /// [creator] to create a new property on the first build.
  final ConsoleWidgetProperty? initialProperty;

  /// Creates a property editor of the console widget's property.
  ///
  /// Builds a widget that invokes the [creator] to create a new property on
  /// tap. The created property will be applied to the inner preview widget, and
  /// passed to [onPropertyEdited] callback even if there are no value changes.
  /// If [initialProperty] is not given, invokes the [creator] to create a new
  /// property on the first build without a tap action.
  ///
  /// [onLongPress] callback will be called on the long press. This callback is
  /// typically used to the higher level controls such as "delete widget".
  const _PropertyEditWidget(
    this.creator, {
    this.onPropertyEdited,
    this.onLongPress,
    this.initialProperty,
  });

  @override
  State<StatefulWidget> createState() => _PropertyEditWidgetState();
}

class _PropertyEditWidgetState extends State<_PropertyEditWidget> {
  /// The current property.
  ConsoleWidgetProperty? _prop;

  /// Whether the property is already initialized.
  bool _initialized = false;

  @override
  void initState() {
    if (widget.initialProperty == null) {
      Future(_updateProperty);
    } else {
      _prop = widget.initialProperty;
      _initialized = true;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Return a button to edit the property with an untouchable preview widget.
    return Stack(fit: StackFit.expand, children: [
      _initialized
          ? (_prop != null
              ? widget.creator.previewBuilder(context, _prop!)
              : ConsoleErrorWidgetCreator.propertyNotDetermined)
          : Container(),
      TextButton(
        style: TextButton.styleFrom(
          shape: const BeveledRectangleBorder(),
        ),
        onPressed: _updateProperty,
        onLongPress: () => widget.onLongPress?.call(),
        child: Container(),
      ),
    ]);
  }

  /// Updates the property of the state.
  Future<void> _updateProperty() async {
    // Create a new property.
    final property =
        await widget.creator.propertyCreator(context, oldProperty: _prop);

    // Update.
    setState(() {
      _prop = property;
      _initialized = true;
    });

    widget.onPropertyEdited?.call(_prop);
  }
}
