import 'package:flutter/material.dart';

/// Creates a relatively controllable gesture widgets.
///
/// This callbacks [onValueChange] with the pan movement from the origin: where
/// the gesture started. [onValueFix] will be called back at the gesture end.
/// [onActivationChange] will be called with true when tap down detected, and
/// called with false when tap up, pan end or long tap is detected; only in
/// activation, some control callbacks can be fired.
///
/// The long tap is assigned to the cancellation behavior.
class HandleWidget extends StatefulWidget {
  const HandleWidget({
    Key? key,
    required this.onValueChange,
    required this.onValueFix,
    this.onActivationChange,
  }) : super(key: key);

  final void Function(double, double)? onValueChange;
  final void Function()? onValueFix;
  final void Function(bool)? onActivationChange;

  @override
  State<StatefulWidget> createState() => _HandleWidgetState();
}

class _HandleWidgetState extends State<HandleWidget> {
  double _originX = 0;
  double _originY = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => widget.onActivationChange?.call(true),
      onTapUp: (_) => widget.onActivationChange?.call(false),
      onPanStart: (details) {
        _originX = details.localPosition.dx;
        _originY = details.localPosition.dy;
        widget.onActivationChange?.call(true);
      },
      onPanUpdate: (details) {
        final dx = details.localPosition.dx - _originX;
        final dy = details.localPosition.dy - _originY;
        widget.onValueChange?.call(dx, dy);
      },
      onPanEnd: (details) {
        widget.onValueFix?.call();
        widget.onActivationChange?.call(false);
      },
      onLongPress: () => widget.onActivationChange?.call(false),
    );
  }
}
