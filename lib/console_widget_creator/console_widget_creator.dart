import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flex_console_for_bluetooth_serial/console_widget_creator/console_error_widget_creator.dart';

/// The property type for the console widget.
typedef ConsoleWidgetProperty = Map<String, dynamic>;

/// The function type for the creation of [ConsoleWidgetProperty] interactively
/// in the [context].
///
/// The current property will be passed as [oldProperty], or null at the first
/// creation.
///
/// The [oldProperty] and the return value describes the following scenarios:
///
/// - null -> null: the first creation is cancelled;
/// - null -> property: the first creation is completed;
/// - property -> null: the old property is not updated;
/// - property -> property: the old property is updated to the new one.
typedef ConsoleWidgetPropertyCreator = Future<ConsoleWidgetProperty?> Function(
  BuildContext context, {
  ConsoleWidgetProperty? oldProperty,
});

/// The builder type for the console widget.
typedef ConsoleWidgetBuilder = Widget Function(
  BuildContext,
  ConsoleWidgetProperty property,
);

/// The builder type for the preview console widget.
typedef PreviewConsoleWidgetBuilder = Widget Function(
  BuildContext,
  ConsoleWidgetProperty property,
);

/// The builder type for the sample console widgets.
typedef SampleConsoleWidgetBuilder = Widget Function(BuildContext);

/// The base of all console widget creators.
///
/// All of console widgets have its own property for building. The property will
/// be created through [propertyCreator] interactively. Then, a functional
/// widget will be created with the property by a builder function created with
/// the [builder].
///
/// [previewBuilder] should create a builder for un-functional console widget
/// with the created property. These widgets will be shown for a preview on
/// editing. If null, [builder] will be used alternatively.
///
/// [sampleBuilder] also should create un-functional console widget builder.
/// However, in contrast to [previewBuilder], the builder does not need any
/// property. If null, [builder] will be used alternatively with the property
/// [sampleProperty] or an empty map.
///
/// The property can be validated with [propertyValidator] before each builds.
/// The returned string, indicating the error detail, will be shown in the
/// error widget built alternatively.
class ConsoleWidgetCreator {
  /// The name of the providing console widget.
  ///
  /// This must be unique in the app.
  final String name;

  /// The description for the providing console widget.
  final String description;

  /// The series of the providing console widget.
  final String series;

  /// Creates a property to build a console widget.
  final ConsoleWidgetPropertyCreator propertyCreator;

  /// The property to build the sample widget with [builder].
  ///
  /// If [sampleBuilder] is given, the property will be used never.
  final ConsoleWidgetProperty? sampleProperty;

  /// Validates the property before each builds.
  ///
  /// The returned error detail will be shown in the error widget alternatively
  /// built. The returned null shows no error in the property.
  final String? Function(ConsoleWidgetProperty)? propertyValidator;

  final ConsoleWidgetBuilder _builder;
  final PreviewConsoleWidgetBuilder? _previewBuilder;
  final SampleConsoleWidgetBuilder? _sampleBuilder;

  /// Creates a builder of the console widget with a property.
  ConsoleWidgetBuilder get builder => (context, property) {
        // Validate the property if required.
        final result = propertyValidator?.call(property);

        if (result != null) {
          return ConsoleErrorWidgetCreator.createWith(
              brief: "Property Error", detail: result);
        }

        return _builder(context, property);
      };

  /// Creates a builder of the un-functional console preview widget with a
  /// property.
  PreviewConsoleWidgetBuilder get previewBuilder => (context, property) {
        // Validate the property if required.
        final result = propertyValidator?.call(property);

        if (result != null) {
          return ConsoleErrorWidgetCreator.createWith(
              brief: "Property Error", detail: result);
        }

        return (_previewBuilder ?? _builder).call(context, property);
      };

  /// Creates a builder of the un-function console sample widget with no
  /// property.
  SampleConsoleWidgetBuilder get sampleBuilder => (context) {
        // Sample builder is the first priority.
        if (_sampleBuilder != null) return _sampleBuilder!(context);

        return builder(context, sampleProperty ?? {});
      };

  /// Creates a console widget creator named [name].
  ///
  /// The [description] and [series] show the use-case to the users briefly.
  ///
  /// All of console widgets have its own property for building. The property
  /// will be created through [propertyCreator] interactively. Then, a
  /// functional widget will be created with the property by a builder function
  /// created with the [builder].
  ///
  /// [previewBuilder] should create a builder for un-functional console widget
  /// with the created property. These widgets will be shown for a preview on
  /// editing. If null, [builder] will be used alternatively.
  ///
  /// [sampleBuilder] also should create un-functional console widget builder.
  /// However, in contrast to [previewBuilder], the builder does not need any
  /// property. If null, [builder] will be used alternatively with the property
  /// [sampleProperty] or an empty map.
  ///
  /// The property can be validated with [propertyValidator] before each builds.
  /// The returned string, indicating the error detail, will be shown in the
  /// error widget built alternatively.
  ConsoleWidgetCreator({
    required this.name,
    required this.description,
    required this.series,
    required this.propertyCreator,
    required ConsoleWidgetBuilder builder,
    PreviewConsoleWidgetBuilder? previewBuilder,
    SampleConsoleWidgetBuilder? sampleBuilder,
    this.sampleProperty,
    this.propertyValidator,
  })  : _builder = builder,
        _previewBuilder = previewBuilder,
        _sampleBuilder = sampleBuilder;
}
