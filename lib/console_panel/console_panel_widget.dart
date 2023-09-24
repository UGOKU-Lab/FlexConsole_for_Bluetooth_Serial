import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flex_console_for_bluetooth_serial/console_panel/console_panel_cell_widget.dart';
import 'package:flex_console_for_bluetooth_serial/console_panel/generation_parameter.dart';

/// The widget in the specified cell of the console panel.
///
/// The [widget] will be placed at non-negative, zero-based [row] and [column]
/// of the console panel's grid. The shape will be determined by non-negative
/// [width] and [height]: the number of using grid areas for each axises.
class WidgetInConsolePanelCell {
  int row;
  int column;
  int width;
  int height;
  Widget widget;

  WidgetInConsolePanelCell({
    required this.row,
    required this.column,
    required this.height,
    required this.width,
    required this.widget,
  });

  WidgetInConsolePanelCell.fromParameter(ConsolePanelCellParameter param,
      {required this.widget})
      : row = param.row,
        column = param.column,
        width = param.width,
        height = param.height;

  /// Whether the widget is at [row] and [column].
  bool isAt(int row, int column) {
    return this.row == row && this.column == column;
  }
}

/// Creates a console panel.
///
/// The console panel will be expanded as can as, in the [constraints]. Each
/// [cells] will be placed on the square [rows] x [columns] grid of the entire
/// area.
class ConsolePanelWidget extends StatefulWidget {
  final BoxConstraints constraints;
  final int rows;
  final int columns;
  final List<WidgetInConsolePanelCell> cells;
  final Widget Function(BuildContext, double)? overlayBuilder;

  const ConsolePanelWidget({
    super.key,
    required this.constraints,
    required this.rows,
    required this.columns,
    required this.cells,
    this.overlayBuilder,
  });

  ConsolePanelWidget.fromParameter(
    ConsolePanelParameter param, {
    super.key,
    required this.constraints,
    List<WidgetInConsolePanelCell>? backgroundCells,
    Widget Function(BuildContext, ConsolePanelCellParameter)?
        cellContentBuilder,
    this.overlayBuilder,
  })  : rows = param.rows,
        columns = param.columns,
        cells = [
          ...(backgroundCells ?? []),
          ...(cellContentBuilder != null
              ? param.cells.map((p) => WidgetInConsolePanelCell.fromParameter(p,
                  widget: Builder(
                      builder: (context) => cellContentBuilder(context, p))))
              : [])
        ];

  @override
  State<StatefulWidget> createState() => ConsolePanelWidgetState();
}

class ConsolePanelWidgetState extends State<ConsolePanelWidget> {
  /// The generator of the widget in the inner child cell.
  late Iterable<Widget> _cells;

  /// The size of the grid.
  late double _gridSize;

  @override
  void initState() {
    // Calculate the unit cell size.
    _gridSize = _getGridSize();

    // Generate cells.
    _cells = _getCellGenerator();

    super.initState();
  }

  @override
  void didUpdateWidget(ConsolePanelWidget oldWidget) {
    _gridSize = _getGridSize();
    _cells = _getCellGenerator();

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.columns * _gridSize,
      height: widget.rows * _gridSize,
      // Body:
      child: Stack(
        children: [
          ..._cells,
          ...(widget.overlayBuilder != null
              ? [widget.overlayBuilder!(context, _gridSize)]
              : []),
        ],
      ),
    );
  }

  /// Gets the size of the squire grid.
  double _getGridSize() {
    return min(widget.constraints.maxHeight / widget.rows,
        widget.constraints.maxWidth / widget.columns);
  }

  /// Generates cell widgets on the grid.
  Iterable<Widget> _getCellGenerator() {
    // Generates cells.
    return List.generate(
            widget.rows,
            (row) => List.generate(
                widget.columns,
                // Position at the row and the column;
                (column) => ConsolePanelCellWidget(
                    gridSize: _gridSize,
                    row: row,
                    column: column,
                    width: _getWidgetAt(row, column)?.width ?? 1,
                    height: _getWidgetAt(row, column)?.height ?? 1,
                    child: _getWidgetAt(row, column)?.widget ?? Container())))
        .expand((widget) => widget);
  }

  /// Returns the cell at the specified position.
  ///
  /// The position of cell is calculated as [WidgetInConsolePanelCell.row] and
  /// [WidgetInConsolePanelCell.column]. The size will be ignored.
  WidgetInConsolePanelCell? _getWidgetAt(int row, int column) {
    return widget.cells.where((cell) => cell.isAt(row, column)).firstOrNull;
  }
}
