import 'package:flutter/material.dart';

/// Creates a cell in the console panel.
///
/// This positions itself by the [gridSize] of the console panel and the
/// zero-based indexes of the grid: [row], [column]. The shape is united by
/// [gridSize] and determined by the [width] and [height].
class ConsolePanelCellWidget extends StatelessWidget {
  final double gridSize;
  final int width;
  final int height;
  final int row;
  final int column;
  final Widget child;

  const ConsolePanelCellWidget({
    super.key,
    required this.gridSize,
    required this.row,
    required this.column,
    this.width = 1,
    this.height = 1,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: gridSize * row,
      left: gridSize * column,
      child: SizedBox(
        width: gridSize * width,
        height: gridSize * height,
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: child,
        ),
      ),
    );
  }
}
