import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flex_console_for_bluetooth_serial/util/form/common_form_page.dart';

import '../console_widget_creator.dart';

/// Creates a console widget that contains a headline text.
///
/// The text will be styled to headlineMedium of the theme of the context.
final consoleHeadlineTextWidgetCreator = ConsoleWidgetCreator(
  name: "Headline Text",
  description: "Displays a headline text.",
  series: "Decoration Widgets",
  builder: (context, property) => Container(
    alignment: Alignment.centerLeft,
    child: Text(
      property["text"]?.toString() ?? "",
      style: Theme.of(context).textTheme.headlineMedium,
      overflow: TextOverflow.fade,
    ),
  ),
  propertyCreator: (context, {oldProperty}) {
    final propCompleter = Completer<ConsoleWidgetProperty?>();
    String newText = oldProperty?["text"]?.toString() ?? "";

    // Open the edit form, then return the edited property.
    // If edit form is closed without saving, return null.
    CommonFormPage.show(
      context,
      title: "Property Edit",
      content: Column(children: [
        TextFormField(
            initialValue: newText,
            decoration: const InputDecoration(labelText: "Text"),
            autofocus: true,
            onChanged: (value) => newText = value),
      ]),
    ).then((ok) {
      if (ok) {
        propCompleter.complete({"text": newText});
      } else {
        propCompleter.complete(oldProperty);
      }
    });

    return propCompleter.future;
  },
  sampleProperty: {"text": "Sample Text"},
);
