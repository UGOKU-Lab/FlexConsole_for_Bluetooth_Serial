import 'package:flex_console_for_bluetooth_serial/console_widget_creator/console_error_widget_creator.dart';
import 'package:flex_console_for_bluetooth_serial/console_widget_creator/console_widget_creator.dart';

/// The parameter to generate a console panel cell.
///
/// The cell is at zero-based index [row], [column] of the console panel's grid.
/// The shape will be determined by [width] and [height]: the number of using
/// grid areas for each axises. The widget in the cell will be created by the
/// [creator] with the [property].
class ConsolePanelCellParameter {
  int row;
  int column;
  int width;
  int height;
  String creator;
  ConsoleWidgetProperty? property;

  ConsolePanelCellParameter({
    required this.row,
    required this.column,
    this.width = 1,
    this.height = 1,
    required this.creator,
    this.property,
  })  : assert(width > 0),
        assert(height > 0);

  /// Generates from the JSON map.
  factory ConsolePanelCellParameter.fromJson(dynamic json) {
    if (json is! Map) {
      return ConsolePanelCellParameter.fromError(
        "Illegal Cell Parameter",
        "The cell parameter must be a map.",
      );
    }

    final row = json["row"], column = json["column"];

    if (row is! int || column is! int) {
      return ConsolePanelCellParameter.fromError(
        "Illegal Cell Parameter",
        'The "row" and "cell" properties must be integers.',
      );
    }

    final width = json["width"], height = json["height"];

    if (width is! int || width < 1 || height is! int || height < 1) {
      return ConsolePanelCellParameter.fromError(
        "Illegal Cell Parameter",
        'The "width" and "height" properties must be positive integers.',
      );
    }

    final creator = json["creator"];

    if (creator is! String) {
      return ConsolePanelCellParameter.fromError(
        "Illegal Cell Parameter",
        'The "creator" property must be a string.',
      );
    }

    final property = json["property"];

    if (property is! ConsoleWidgetProperty) {
      return ConsolePanelCellParameter.fromError(
        "Illegal Cell Parameter",
        'The "property" property must be a map.',
      );
    }

    return ConsolePanelCellParameter(
      row: row,
      column: column,
      width: width,
      height: height,
      creator: creator,
      property: property,
    );
  }

  /// Creates a cell parameter with the error described in the [brief] and the
  /// [detail]ed texts.
  factory ConsolePanelCellParameter.fromError(
    String brief,
    String detail, {
    int row = 0,
    int column = 0,
  }) {
    return ConsolePanelCellParameter(
      row: row,
      column: column,
      creator: ConsoleErrorWidgetCreator().name,
      property: {"brief": brief, "detail": detail},
    );
  }

  /// Generates a JSON map of itself.
  Map<String, dynamic> toJson() {
    return {
      "row": row,
      "column": column,
      "width": width,
      "height": height,
      "creator": creator,
      "property": property,
    };
  }

  /// Whether the cell is at the [row] and the [column].
  bool isAt(int row, int column) {
    return this.row == row && this.column == column;
  }

  /// Whether the cell is over the [row] and the [column].
  bool isOver(int row, int column) {
    return (this.row <= row && row < this.row + height) &&
        (this.column <= column && column < this.column + width);
  }

  /// Whether the cell is overlap with the cell at the [row] and the [column],
  /// with the [width] and the [height].
  bool isOverlap(int row, int column, int width, int height) {
    final halfWidth = this.width / 2;
    final halfHeight = this.height / 2;
    final otherHalfWidth = width / 2;
    final otherHalfHeight = height / 2;

    return (this.column + halfWidth - column - otherHalfWidth).abs() <
            halfWidth + otherHalfWidth &&
        (this.row + halfHeight - row - otherHalfHeight).abs() <
            halfHeight + otherHalfHeight;
  }

  /// Creates new object with copied data.
  ///
  /// This method create a new object as copy of itself. Every members will be
  /// copied deeply except [property]; [property] is a dynamic map, so this
  /// will not be copied deeply. It is recommended to overwrite entire of the
  /// [property] for value changes, but member accessing.
  ConsolePanelCellParameter copy() {
    return ConsolePanelCellParameter(
        row: row,
        column: column,
        width: width,
        height: height,
        creator: creator,
        property: property != null ? Map.of(property!) : null);
  }
}

/// The parameter to generate a console panel.
///
/// The console panel can have [rows] x [columns] widgets as [cells] at most.
class ConsolePanelParameter {
  int rows;
  int columns;
  List<ConsolePanelCellParameter> cells;

  ConsolePanelParameter({
    required this.rows,
    required this.columns,
    required this.cells,
  });

  /// Creates a panel parameter from the JSON.

  factory ConsolePanelParameter.fromJson(dynamic json) {
    if (json is! Map) {
      return ConsolePanelParameter.fromError(
        "Illegal Panel Parameter",
        "Panel parameter must be a map.",
      );
    }

    final rows = json["rows"], columns = json["columns"];

    if (rows is! int || rows <= 0 || columns is! int || columns <= 0) {
      return ConsolePanelParameter.fromError(
        "Illegal Panel Parameter",
        'The "rows" and "columns" properties must be positive integers.',
      );
    }

    final cells = json["cells"];

    if (cells is! List) {
      return ConsolePanelParameter.fromError(
        "Illegal Panel Parameter",
        'The "cells" property must be a list.',
      );
    }

    return ConsolePanelParameter(
      rows: rows,
      columns: columns,
      cells: cells
          .map((cell) => ConsolePanelCellParameter.fromJson(cell))
          .toList(),
    );
  }

  /// Creates a panel parameter with the error described in the [brief] and
  /// the [detail]ed texts.
  factory ConsolePanelParameter.fromError(String brief, String detail) {
    return ConsolePanelParameter(
      rows: 1,
      columns: 1,
      cells: [ConsolePanelCellParameter.fromError(brief, detail)],
    );
  }

  /// Generates a JSON map of itself.
  Map<String, dynamic> toJson() {
    return {
      "columns": columns,
      "rows": rows,
      "cells": cells.map((cell) => cell.toJson()).toList(),
    };
  }

  /// Creates new object with the copied data.
  ConsolePanelParameter copy() {
    return ConsolePanelParameter(
      columns: columns,
      rows: rows,
      cells: cells.map((cell) => cell.copy()).toList(),
    );
  }
}
