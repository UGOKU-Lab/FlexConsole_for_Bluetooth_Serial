import 'package:flutter/material.dart';

/// Creates a frame that show the state of the activation.
///
/// This provides a visual feedback for console widgets.
class ConsoleWidgetCard extends StatelessWidget {
  final bool activate;
  final Widget child;

  const ConsoleWidgetCard(
      {super.key, this.activate = false, required this.child});

  @override
  Widget build(context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      margin: EdgeInsets.all(activate ? 0 : 5),
      padding: EdgeInsets.all(activate ? 5 : 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(activate ? 17 : 13)),
        color: activate
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.surface,
        boxShadow: const [
          BoxShadow(
              color: Colors.black12,
              spreadRadius: 0,
              blurRadius: 2,
              offset: Offset(0, 1)),
          BoxShadow(
              color: Colors.black12,
              spreadRadius: 1,
              blurRadius: 3,
              offset: Offset(0, 2)),
        ],
      ),
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(13)),
        ),
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
    );
  }
}
