import 'dart:async';

import 'package:flutter/material.dart';

/// The page to display the common formatted form.
class CommonFormPage extends StatelessWidget {
  /// The content of the form.
  final Widget content;

  /// The callback called when the form is closed with the successful status.
  final bool Function()? onFix;

  /// The title of the page.
  final String title;

  /// Creates a common form page.
  ///
  /// This page implements a form with validation and cancellation. If the
  /// inputs passed the validation, then pops true. Otherwise, on cancellation,
  /// pops false.
  ///
  /// [onFix] will be called when the form closed with the successful status.
  CommonFormPage({
    super.key,
    required this.title,
    required this.content,
    this.onFix,
  });

  late final GlobalKey<FormState> _formKey = GlobalKey();

  static Future<bool> show(
    BuildContext context, {
    String title = "Form",
    required Widget content,
  }) {
    return Navigator.of(context)
        .push<bool>(MaterialPageRoute(
          builder: (context) => CommonFormPage(title: title, content: content),
        ))
        .then((ok) => ok ?? false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                final ok = _formKey.currentState?.validate() ?? true;
                if (ok) Navigator.of(context).pop(true);
              },
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Form(
              key: _formKey,
              child: content,
            ),
          ),
        ),
      ),
      onWillPop: () {
        final shouldPop = Completer<bool>();

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Warning"),
            content: const Text("Changes will be discarded. Continue?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  shouldPop.complete(false);
                },
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  shouldPop.complete(true);
                },
                child: const Text("Yes"),
              ),
            ],
          ),
        );

        return shouldPop.future.then((shouldPop) {
          // Return the result before pop this form.
          if (shouldPop) {
            Navigator.of(context).pop(false);
          }

          // Always false because of that required pop is done above.
          return Future.value(false);
        });
      },
    );
  }
}
