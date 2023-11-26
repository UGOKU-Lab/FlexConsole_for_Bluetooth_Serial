import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flex_console_for_bluetooth_serial/console_list_page.dart';
import 'package:flex_console_for_bluetooth_serial/console_panel/console_panel_widget.dart';
import 'package:flex_console_for_bluetooth_serial/console_panel/generation_parameter.dart';
import 'package:flex_console_for_bluetooth_serial/util/form/integer_field.dart';
import 'package:flex_console_for_bluetooth_serial/util/widget/reshaper_widget.dart';

import 'console_widget_creator/console_widget_creator_factory_widget.dart';
import 'console_widget_creator/console_widget_creator.dart';

/// The page to edit the console function and layout.
///
/// Starts with [save] as an initial state.
class ConsoleEditPage extends StatefulWidget {
  /// The initial save to edit.
  final ConsoleSaveObject save;

  /// Whether the title should be focused.
  final bool focusTitle;

  /// Creates a console edit page.
  ///
  /// Starts with [save] as an initial state.
  ///
  /// Automatically focuses on the title if [focusTitle] is true.
  const ConsoleEditPage({
    super.key,
    required this.save,
    this.focusTitle = false,
  });

  @override
  State<StatefulWidget> createState() => _ConsoleEditPageState();
}

class _ConsoleEditPageState extends State<ConsoleEditPage> {
  /// The edited save.
  late final ConsoleSaveObject _save = widget.save.copy();

  /// Whether editing the widget's shape.
  bool _reshaping = false;

  /// The target of the reshape.
  ConsolePanelCellParameter? _reshapeTargetCell;

  /// The background cells to add a new console widget.
  late final List<WidgetInConsolePanelCell> _backgroundCellCaches = [];

  @override
  void initState() {
    _updateBackgroundCellCache();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: IntrinsicWidth(
            child: TextFormField(
              autofocus: widget.focusTitle,
              initialValue: _save.title,
              style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: Theme.of(context).textTheme.titleLarge!.fontSize),
              onChanged: (value) => setState(() => _save.title = value),
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
                onPressed: _showGridEditor(context),
                icon: const Icon(Icons.grid_on)),
            IconButton(
                onPressed: () {
                  Navigator.of(context).pop(_save);
                },
                icon: const Icon(Icons.check)),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(5),
          child: LayoutBuilder(
            builder: (context, constraints) => Center(
              child: Stack(
                children: [
                  GestureDetector(onTap: _endReshape),
                  Center(
                    child: ConsolePanelWidget.fromParameter(
                      _save.parameter,
                      constraints: constraints,
                      cellContentBuilder: (context, cellParam) =>
                          ConsoleCreatorFactoryWidget.editorBuilder(
                        context,
                        cellParam.creator,
                        initialProperty: cellParam.property,
                        onPropertyChange: (property) {
                          if (property != null) {
                            _updateWidgetCellAt(cellParam.row, cellParam.column,
                                width: cellParam.width,
                                height: cellParam.height,
                                creator: cellParam.creator,
                                property: property);
                          } else if (cellParam.property == null) {
                            _removeCellAt(cellParam.row, cellParam.column);
                          }
                        },
                        onLongPress: _showBottomSheetFor(
                            cellParam.row, cellParam.column),
                      ),
                      backgroundCells: _backgroundCellCaches
                          .where((cache) => _save.parameter.cells.every(
                              (cell) => !cell.isOver(cache.row, cache.column)))
                          .toList(),
                      overlayBuilder: _reshaping
                          ? (context, gridSize) => Stack(
                                children: [
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: _endReshape,
                                  ),
                                  ReshaperOverlayWidget(
                                    unitSize: gridSize,
                                    width: _reshapeTargetCell!.width,
                                    height: _reshapeTargetCell!.height,
                                    x: _reshapeTargetCell!.column,
                                    y: _reshapeTargetCell!.row,
                                    onFix: (c, r, w, h) {
                                      if (_canPlace(r, c, w, h)) {
                                        _reshapeTargetCell!.column = c;
                                        _reshapeTargetCell!.row = r;
                                        _reshapeTargetCell!.width = w;
                                        _reshapeTargetCell!.height = h;
                                      }
                                      // Update or reset the adjuster.
                                      setState(() {});
                                    },
                                  )
                                ],
                              )
                          : null,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      onPopInvoked: (final didPop) async {
        if (didPop) return;

        // Cancellation action.
        final shouldPop = Completer<bool>();

        // Show the warning dialog, then pop null by the answer.
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Warning"),
            content: const Text("Changes will be discarded. Continue?"),
            actions: [
              TextButton(
                child: const Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                  shouldPop.complete(false);
                },
              ),
              TextButton(
                child: const Text("Yes"),
                onPressed: () {
                  Navigator.of(context).pop();
                  shouldPop.complete(true);
                },
              )
            ],
          ),
        );

        // Pop this page when "Yes" is pressed.
        await shouldPop.future.then((final shouldPop) {
          if (shouldPop) {
            Navigator.of(context).pop();
          }
        });
      },
    );
  }

  /// Shows the editor to change the number of rows and columns.
  Future<void> Function() _showGridEditor(BuildContext context) {
    return () async {
      int? rows = _save.parameter.rows, columns = _save.parameter.columns;
      final formKey = GlobalKey<FormState>();

      await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      IntInputField(
                        labelText: "# of Rows",
                        hintText: "1, 2 ... 8",
                        minValue: 1,
                        maxValue: 8,
                        initValue: rows,
                        onValueChange: (n) => rows = n,
                      ),
                      IntInputField(
                        labelText: "# of Columns",
                        hintText: "1, 2 ... 8",
                        minValue: 1,
                        maxValue: 8,
                        initValue: columns,
                        onValueChange: (n) => columns = n,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text("OK"),
                  onPressed: () {
                    final ok = formKey.currentState?.validate() ?? true;

                    if (ok) {
                      setState(() {
                        _save.parameter.rows = rows ?? _save.parameter.rows;
                        _save.parameter.columns =
                            columns ?? _save.parameter.columns;
                        _updateBackgroundCellCache();
                      });

                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            );
          });
    };
  }

  /// Adds a new widget to the save.
  void _updateWidgetCellAt(int row, int column,
      {required int width,
      required int height,
      required String creator,
      ConsoleWidgetProperty? property}) {
    setState(() {
      _save.parameter.cells.removeWhere((cell) => cell.isAt(row, column));
      _save.parameter.cells.add(ConsolePanelCellParameter(
          column: column,
          row: row,
          width: width,
          height: height,
          creator: creator,
          property: property));
    });
  }

  /// Shows a bottom sheet to select a console widget to be created.
  Future<void> Function() _showBottomSheetFor(int row, int column) {
    return () async {
      await showModalBottomSheet(
        clipBehavior: Clip.antiAlias,
        context: context,
        builder: (context) {
          return Wrap(
            children: [
              Column(
                children: [
                  SizedBox(
                    height: Theme.of(context).textTheme.titleMedium!.fontSize,
                  ),
                  ListTile(
                    leading: const Icon(Icons.transform),
                    title: const Text("Reshape"),
                    onTap: () {
                      Navigator.of(context).pop();
                      // Start the reshape of the selected target.
                      _startReshapeAt(row, column);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete),
                    title: const Text("Delete"),
                    onTap: () {
                      Navigator.of(context).pop();
                      // Remove the selected target.
                      _removeCellAt(row, column);
                    },
                  ),
                ],
              ),
            ],
          );
        },
      );
    };
  }

  /// Removes a cell at [row], [column]
  void _removeCellAt(int row, int column) {
    setState(() {
      _save.parameter.cells.removeWhere((cell) => cell.isAt(row, column));
    });
  }

  /// Determines a cell sized [width] and [height] can be placed at [row],
  /// [column].
  bool _canPlace(int row, int column, int width, int height) {
    if (column < 0 || row < 0) {
      return false;
    }
    if (width < 1 || height < 1) {
      return false;
    }
    if (column + width > _save.parameter.columns ||
        row + height > _save.parameter.rows) {
      return false;
    }
    if (_save.parameter.cells
        .where((cell) => cell != _reshapeTargetCell)
        .any((cell) => cell.isOverlap(row, column, width, height))) {
      return false;
    }

    return true;
  }

  /// Updates the background cells by the number of rows and columns.
  void _updateBackgroundCellCache() {
    _backgroundCellCaches.clear();
    _backgroundCellCaches.addAll(List.generate(
      _save.parameter.rows,
      (row) => List.generate(
        _save.parameter.columns,
        (column) => (row: row, column: column),
      ),
    ).expand((e) => e).map((indexes) => WidgetInConsolePanelCell(
          row: indexes.row,
          column: indexes.column,
          width: 1,
          height: 1,
          widget: ConsoleCreatorFactoryWidget(
            onCreatorSelected: (creator) {
              _updateWidgetCellAt(indexes.row, indexes.column,
                  width: 1, height: 1, creator: creator, property: null);
            },
          ),
        )));
  }

  /// Starts the reshape the cell at [row], [column].
  void _startReshapeAt(int row, int column) {
    setState(() {
      _reshapeTargetCell = _save.parameter.cells
          .where((cell) => cell.isAt(row, column))
          .firstOrNull;
      _reshaping = true;
    });
  }

  /// Ends the reshape.
  void _endReshape() {
    setState(() {
      _reshaping = false;
    });
  }
}
