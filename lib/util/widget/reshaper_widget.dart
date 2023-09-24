import 'dart:math';

import 'package:flutter/material.dart';

import 'handle_widget.dart';

class ReshaperOverlayWidget extends StatefulWidget {
  final double unitSize;
  final int width;
  final int height;
  final int x;
  final int y;
  final double handleWidth;
  final void Function(double)? onHeightChange;
  final void Function(double)? onWidthChange;
  final void Function(double, double)? onMove;
  final void Function(int, int, int, int)? onFix;

  const ReshaperOverlayWidget({
    super.key,
    required this.unitSize,
    required this.width,
    required this.height,
    required this.x,
    required this.y,
    this.handleWidth = 20,
    this.onHeightChange,
    this.onWidthChange,
    this.onMove,
    this.onFix,
  });

  @override
  State<StatefulWidget> createState() => _ReshaperOverlayWidgetState();
}

class _ReshaperOverlayWidgetState extends State<ReshaperOverlayWidget> {
  late double _width;
  late double _height;
  late double _x;
  late double _y;

  @override
  void initState() {
    _width = widget.width * widget.unitSize;
    _height = widget.height * widget.unitSize;
    _x = widget.x * widget.unitSize;
    _y = widget.y * widget.unitSize;

    super.initState();
  }

  @override
  void didUpdateWidget(covariant ReshaperOverlayWidget oldWidget) {
    _width = widget.width * widget.unitSize;
    _height = widget.height * widget.unitSize;
    _x = widget.x * widget.unitSize;
    _y = widget.y * widget.unitSize;

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: _x,
          top: _y,
          child: Stack(
            children: [
              Container(
                width: _width,
                height: _height,
                decoration: BoxDecoration(
                    color: Theme.of(context).splashColor,
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                    border: Border.all(
                        color:
                            Theme.of(context).buttonTheme.colorScheme!.primary,
                        width: 5)),
              ),
              SizedBox(
                width: _width,
                height: _height,
                child: Row(
                  children: [
                    SizedBox(
                      width: min(widget.handleWidth, _width / 4),
                      child: Center(
                        child: FittedBox(
                          child: Icon(Icons.arrow_left,
                              color: Theme.of(context)
                                  .buttonTheme
                                  .colorScheme!
                                  .primary),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(children: [
                        SizedBox(
                          height: min(widget.handleWidth, _height / 4),
                          child: Center(
                            child: FittedBox(
                              child: Icon(Icons.arrow_drop_up,
                                  color: Theme.of(context)
                                      .buttonTheme
                                      .colorScheme!
                                      .primary),
                            ),
                          ),
                        ),
                        Expanded(child: Container()),
                        SizedBox(
                          height: min(widget.handleWidth, _height / 4),
                          child: Center(
                            child: FittedBox(
                              child: Icon(Icons.arrow_drop_down,
                                  color: Theme.of(context)
                                      .buttonTheme
                                      .colorScheme!
                                      .primary),
                            ),
                          ),
                        ),
                      ]),
                    ),
                    SizedBox(
                      width: min(widget.handleWidth, _width / 4),
                      child: Center(
                        child: FittedBox(
                          child: Icon(Icons.arrow_right,
                              color: Theme.of(context)
                                  .buttonTheme
                                  .colorScheme!
                                  .primary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ReshaperWidget(
                width: _width,
                height: _height,
                x: _x,
                y: _y,
                handleWidth: widget.handleWidth,
                onHeightChange: (h) {
                  setState(() {
                    _height = h;
                  });
                  widget.onHeightChange?.call(h);
                },
                onWidthChange: (w) {
                  setState(() {
                    _width = w;
                  });
                  widget.onWidthChange?.call(w);
                },
                onMove: (x, y) {
                  setState(() {
                    _x = x;
                    _y = y;
                  });
                  widget.onMove?.call(x, y);
                },
                onFix: () {
                  widget.onFix?.call(
                    (_x / widget.unitSize).round(),
                    (_y / widget.unitSize).round(),
                    (_width / widget.unitSize).round(),
                    (_height / widget.unitSize).round(),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Creates a relatively controlling gesture widget.
class ReshaperWidget extends StatefulWidget {
  const ReshaperWidget({
    super.key,
    required this.width,
    required this.height,
    required this.x,
    required this.y,
    this.handleWidth = 10,
    this.onHeightChange,
    this.onWidthChange,
    this.onMove,
    this.onFix,
  });

  final double width;
  final double height;
  final double handleWidth;
  final double x;
  final double y;
  final void Function(double)? onHeightChange;
  final void Function(double)? onWidthChange;
  final void Function(double, double)? onMove;
  final void Function()? onFix;

  @override
  State<ReshaperWidget> createState() => _ReshaperWidgetState();
}

class _ReshaperWidgetState extends State<ReshaperWidget> {
  double _stretchRight = 0;
  double _stretchLeft = 0;
  double _stretchTop = 0;
  double _stretchBottom = 0;
  double _movementX = 0;
  double _movementY = 0;

  double _width = 0;
  double _height = 0;
  double _x = 0;
  double _y = 0;

  bool _isStretchingRight = false;
  bool _isStretchingLeft = false;
  bool _isStretchingTop = false;
  bool _isStretchingBottom = false;
  bool _isMoving = false;

  @override
  void initState() {
    _width = widget.width;
    _height = widget.height;

    _x = widget.x;
    _y = widget.y;

    super.initState();
  }

  @override
  void didUpdateWidget(ReshaperWidget oldWidget) {
    if (_isFixed()) {
      _width = widget.width;
      _height = widget.height;

      _stretchRight = 0;
      _stretchLeft = 0;
      _stretchTop = 0;
      _stretchBottom = 0;

      _x = widget.x;
      _y = widget.y;

      _movementX = 0;
      _movementY = 0;
    }

    super.didUpdateWidget(oldWidget);
  }

  double _getTotalWidth() {
    return max(_width + _stretchLeft + _stretchRight, 3 * widget.handleWidth);
  }

  double _getTotalHeight() {
    return max(_height + _stretchTop + _stretchBottom, 3 * widget.handleWidth);
  }

  void _setWidth(double w) {
    setState(() {
      _width = max(w, 0);
    });
  }

  void _setHeight(double h) {
    setState(() {
      _height = max(h, 0);
    });
  }

  void _setPosition(double x, double y) {
    _x = x;
    _y = y;
  }

  void _setStretchRight(double r) {
    setState(() => _stretchRight = r);
    widget.onWidthChange?.call(_getTotalWidth());
  }

  void _setStretchLeft(double l) {
    setState(() => _stretchLeft = l);
    widget.onWidthChange?.call(_getTotalWidth());
  }

  void _setStretchTop(double t) {
    setState(() => _stretchTop = t);
    widget.onHeightChange?.call(_getTotalHeight());
  }

  void _setStretchBottom(double b) {
    setState(() => _stretchBottom = b);
    widget.onHeightChange?.call(_getTotalHeight());
  }

  void _setMovement(double dx, double dy) {
    _movementX = dx;
    _movementY = dy;
    widget.onMove?.call(_x + dx, _y + dy);
  }

  bool _isFixed() {
    return !_isStretchingRight &&
        !_isStretchingLeft &&
        !_isStretchingTop &&
        !_isStretchingBottom &&
        !_isMoving;
  }

  void _callIfFixed() {
    if (_isFixed()) {
      widget.onFix?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: _getTotalWidth(),
        height: _getTotalHeight(),
        child: Row(
          children: [
            SizedBox(
                width: widget.handleWidth,
                child: Column(
                  children: [
                    SizedBox(height: widget.handleWidth, child: Container()),
                    // Left handle.
                    Expanded(
                      child: HandleWidget(onValueChange: (x, _) {
                        final prevWidth = _getTotalWidth();
                        _setStretchLeft(-x);
                        // Limit max change of the movement to the actual change
                        // of size, to avoid translations when sized to min.
                        _setMovement(
                            _movementX - _getTotalWidth() + prevWidth, 0);
                        _isStretchingLeft = true;
                        _isMoving = true;
                      }, onValueFix: () {
                        _setWidth(_width + _stretchLeft);
                        _setStretchLeft(0);
                        _setPosition(_x + _movementX, _y + _movementY);
                        _setMovement(0, 0);
                        _isStretchingLeft = false;
                        _isMoving = false;
                        _callIfFixed();
                      }),
                    ),
                    SizedBox(height: widget.handleWidth, child: Container()),
                  ],
                )),
            Expanded(
                child: Column(
              children: [
                // Top handle.
                SizedBox(
                  height: widget.handleWidth,
                  child: HandleWidget(onValueChange: (_, y) {
                    final prevHeight = _getTotalHeight();
                    _setStretchTop(-y);
                    // Limit max change of the movement to the actual change of
                    // size, to avoid translations when sized to min.
                    _setMovement(
                        0, _movementY - _getTotalHeight() + prevHeight);
                    _isStretchingTop = true;
                    _isMoving = true;
                  }, onValueFix: () {
                    _setHeight(_height + _stretchTop);
                    _setStretchTop(0);
                    _setPosition(_x + _movementX, _y + _movementY);
                    _setMovement(0, 0);
                    _isStretchingTop = false;
                    _isMoving = false;
                    _callIfFixed();
                  }),
                ),
                // Center handle.
                Expanded(
                    child: HandleWidget(
                  onValueChange: (dx, dy) {
                    _setMovement(dx, dy);
                    _isMoving = true;
                  },
                  onValueFix: () {
                    _setPosition(_x + _movementX, _y + _movementY);
                    _setMovement(0, 0);
                    _isMoving = false;
                    _callIfFixed();
                  },
                )),
                // Bottom handle.
                SizedBox(
                  height: widget.handleWidth,
                  child: HandleWidget(onValueChange: (_, y) {
                    _setStretchBottom(y);
                    _isStretchingBottom = true;
                  }, onValueFix: () {
                    _setHeight(_height + _stretchBottom);
                    _setStretchBottom(0);
                    _isStretchingBottom = false;
                    _callIfFixed();
                  }),
                ),
              ],
            )),
            SizedBox(
                width: widget.handleWidth,
                child: Column(
                  children: [
                    SizedBox(height: widget.handleWidth, child: Container()),
                    // Right handle.
                    Expanded(
                        child: HandleWidget(onValueChange: (x, _) {
                      _setStretchRight(x);
                      _isStretchingRight = true;
                    }, onValueFix: () {
                      _setWidth(_width + _stretchRight);
                      _setStretchRight(0);
                      _isStretchingRight = false;
                      _callIfFixed();
                    })),
                    SizedBox(height: widget.handleWidth, child: Container()),
                  ],
                )),
          ],
        ));
  }
}
