import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flex_console_for_bluetooth_serial/util/form/common_form_page.dart';
import 'package:flex_console_for_bluetooth_serial/util/widget/console_widget_card.dart';

import '../console_widget_creator.dart';

/// Creates a console widget to note.
final consoleNoteWidgetCreator = ConsoleWidgetCreator(
  name: "Note",
  description: "Displays a note.",
  series: "Decoration Widgets",
  builder: (context, property) => ConsoleWidgetCard(
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              property["title"]?.toString() ?? "",
              style: Theme.of(context).textTheme.headlineMedium,
              overflow: TextOverflow.fade,
            ),
            Text(
              property["body"]?.toString() ?? "",
              style: Theme.of(context).textTheme.bodyLarge,
              overflow: TextOverflow.fade,
            ),
          ],
        ),
      ),
    ),
  ),
  propertyCreator: (context, {oldProperty}) {
    final propCompleter = Completer<ConsoleWidgetProperty?>();
    String newTitle = oldProperty?["title"]?.toString() ?? "";
    String newBody = oldProperty?["body"]?.toString() ?? "";

    // Open the edit form, then return the edited property.
    // If edit form is closed without saving, return null.
    CommonFormPage.show(
      context,
      title: "Property Edit",
      content: Column(children: [
        TextFormField(
            initialValue: newTitle,
            decoration: const InputDecoration(labelText: "Title"),
            autofocus: true,
            onChanged: (value) => newTitle = value),
        TextFormField(
            initialValue: newBody,
            decoration: const InputDecoration(labelText: "Body"),
            maxLines: null,
            onChanged: (value) => newBody = value),
      ]),
    ).then((ok) {
      if (ok) {
        propCompleter.complete({"title": newTitle, "body": newBody});
      } else {
        propCompleter.complete(oldProperty);
      }
    });

    return propCompleter.future;
  },
  sampleProperty: {"title": "Sample", "body": "Sample."},
);
