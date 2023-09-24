import 'package:flutter/material.dart';
import 'package:flex_console_for_bluetooth_serial/console_widget_creator/console_widget_creator.dart';

/// The typed version of the [ConsoleWidgetPropertyCreator]
typedef TypedConsoleWidgetPropertyCreator<T extends TypedConsoleWidgetProperty>
    = Future<T?> Function(
  BuildContext, {
  T? oldProperty,
});

/// The typed version of the [ConsoleWidgetBuilder].
typedef TypedConsoleWidgetBuilder<T extends TypedConsoleWidgetProperty> = Widget
    Function(
  BuildContext,
  T,
);

/// The typed version of the [PreviewConsoleWidgetBuilder].
typedef TypedPreviewConsoleWidgetBuilder<T extends TypedConsoleWidgetProperty>
    = Widget Function(
  BuildContext,
  T,
);

/// The typed version of the [ConsoleWidgetProperty].
abstract class TypedConsoleWidgetProperty {
  /// Creates an untyped property of itself.
  ConsoleWidgetProperty toUntyped();

  /// Validates self.
  ///
  /// Returns the error detail if any of validation is failed.
  String? validate();
}

/// The typed version of the [ConsoleWidgetCreator].
class TypedConsoleWidgetCreator<T extends TypedConsoleWidgetProperty>
    extends ConsoleWidgetCreator {
  /// Creates a creator with the typed property [T], the implementation of the
  /// [TypedConsoleWidgetProperty].
  ///
  /// All property will be typed and untyped through [converter] and
  /// [TypedConsoleWidgetProperty.toUntyped].
  ///
  /// [TypedConsoleWidgetProperty.validate] will be used as the validator.
  TypedConsoleWidgetCreator(
    T Function(ConsoleWidgetProperty) converter, {
    required super.name,
    required super.description,
    required super.series,
    required TypedConsoleWidgetPropertyCreator<T> propertyCreator,
    required TypedConsoleWidgetBuilder<T> builder,
    TypedPreviewConsoleWidgetBuilder<T>? previewBuilder,
    super.sampleBuilder,
    T? sampleProperty,
  }) : super(
          propertyCreator: (context, {oldProperty}) => propertyCreator(
            context,
            oldProperty: oldProperty != null ? converter(oldProperty) : null,
          ).then((typed) => typed?.toUntyped()),
          builder: (context, prop) => builder(context, converter(prop)),
          previewBuilder: previewBuilder != null
              ? (context, property) =>
                  previewBuilder(context, converter(property))
              : null,
          sampleProperty: sampleProperty?.toUntyped(),
          propertyValidator: (prop) => converter(prop).validate(),
        );
}

/// Selects the [attribute] of the [property] as [T], or [defaultValue].
T selectAttributeAs<T>(
    ConsoleWidgetProperty property, String attribute, T defaultValue) {
  return property[attribute] is T ? property[attribute] : defaultValue;
}
