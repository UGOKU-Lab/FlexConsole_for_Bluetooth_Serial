import 'package:flutter/material.dart';

import 'console_widget_creator.dart';

/// Displays an error caught in the console widgets.
class ConsoleErrorWidgetCreator extends ConsoleWidgetCreator {
  final String brief;
  final String detail;

  /// Creates an error widget creator with given [brief] and [detail] text.
  ConsoleErrorWidgetCreator({
    this.brief = "Error",
    this.detail = "Error occurred.",
  }) : super(
          name: "Error",
          description: "Replaces a widget with one or more errors.",
          series: "System Widgets",
          propertyCreator: (context, {oldProperty}) =>
              Future.value(oldProperty ?? {"brief": brief, "detail": detail}),
          builder: (context, property) => _ConsoleErrorWidget({
            "brief": property["brief"] ?? brief,
            "detail": property["detail"] ?? detail,
          }),
        );

  /// Creates an error widget with [brief] and [detail] text.
  static Widget createWith({required String brief, required String detail}) {
    return _ConsoleErrorWidget({"brief": brief, "detail": detail});
  }

  /// Creates an error widget that displays the error related to the console
  /// widget creation with no property.
  static Widget get propertyNotDetermined => const _ConsoleErrorWidget({
        "brief": "Property Error",
        "detail": "The property is not determined yet.",
      });
}

/// Displays an error.
class _ConsoleErrorWidget extends StatelessWidget {
  final ConsoleWidgetProperty? property;

  /// Creates a error widget with [property].
  const _ConsoleErrorWidget(this.property);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.error),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(left: 5),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      property?["brief"] ?? "",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
              ],
            ),
            Divider(color: Theme.of(context).colorScheme.onErrorContainer),
            Container(
              alignment: Alignment.centerLeft,
              child: Text(
                property?["detail"] ?? "",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
