import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flex_console_for_bluetooth_serial/console_edit_page.dart';
import 'package:flex_console_for_bluetooth_serial/console_panel/generation_parameter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The save object that contains the parameters to build the console.
class ConsoleSaveObject {
  /// The title of the save.
  String title;

  /// The parameter of the console panel.
  ConsolePanelParameter parameter;

  /// Creates a save object named to the [title] with the [parameter].
  ConsoleSaveObject(this.title, this.parameter);

  /// Creates a save object from a JSON map.
  factory ConsoleSaveObject.fromJson(dynamic json) {
    if (json is! Map) {
      return ConsoleSaveObject.fromError(
        "Illegal Save Object",
        "The save object must be a map.",
      );
    }

    final title = json["title"];

    if (title is! String) {
      return ConsoleSaveObject.fromError(
        "Illegal Save Object",
        'The "title" property must be a string.',
      );
    }

    final parameter = ConsolePanelParameter.fromJson(json["parameter"]);

    return ConsoleSaveObject(title, parameter);
  }

  /// Creates a save object with the error described in [brief] and [detail]ed
  /// texts.
  factory ConsoleSaveObject.fromError(
    String brief,
    String detail, {
    String title = '!ERROR!',
  }) {
    return ConsoleSaveObject(
      title,
      ConsolePanelParameter.fromError(brief, detail),
    );
  }

  /// Returns a JSON map.
  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "parameter": parameter.toJson(),
    };
  }

  /// Creates new object with copied data.
  ConsoleSaveObject copy() {
    return ConsoleSaveObject(title, parameter.copy());
  }
}

/// The page that lists consoles.
class ConsoleListPage extends StatefulWidget {
  const ConsoleListPage({super.key});

  @override
  State<ConsoleListPage> createState() => _ConsoleListPageState();
}

class _ConsoleListPageState extends State<ConsoleListPage> {
  List<ConsoleSaveObject> _saves = [];
  final Set<int> _selectedIndexes = {};

  bool get _inSelectMode => _selectedIndexes.isNotEmpty;

  @override
  void initState() {
    SharedPreferences.getInstance().then((pref) {
      setState(() {
        _saves = pref
                .getStringList("consoles")
                ?.map((json) => jsonDecode(json))
                .whereType<Map<String, dynamic>>()
                .map((map) => ConsoleSaveObject.fromJson(map))
                .toList() ??
            [];
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Consoles"),
          centerTitle: true,
          actions: [
            ...(_selectedIndexes.isEmpty
                ? [
                    IconButton(
                        onPressed: _addConsole, icon: const Icon(Icons.add)),
                  ]
                : []),
            ...(_selectedIndexes.length == 1
                ? [
                    // Duplicate the selected save.
                    IconButton(
                        onPressed: () async {
                          final selectedSave = _saves[_selectedIndexes.first];
                          setState(() {
                            _saves.add(ConsoleSaveObject(
                                _getUniqueTitle(selectedSave.title),
                                selectedSave.parameter.copy()));
                          });
                        },
                        icon: const Icon(Icons.content_copy_outlined)),
                  ]
                : []),
            ...(_selectedIndexes.isNotEmpty
                ? [
                    IconButton(
                        onPressed: _deleteSelection,
                        icon: const Icon(Icons.delete)),
                  ]
                : []),
          ],
        ),
        body: _saves.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("Nothing here.",
                        style: Theme.of(context).textTheme.bodyLarge),
                    const Text(""),
                    OutlinedButton(
                        onPressed: _addConsole, child: const Text("Create new"))
                  ],
                ),
              )
            : ListView.builder(
                itemCount: _saves.length,
                itemBuilder: (context, index) => _ConsoleListTile(
                  _saves[index],
                  selected: _selectedIndexes.contains(index),
                  showCheckbox: _selectedIndexes.isNotEmpty,
                  onTap: () {
                    // Pop the target console if not in select mode.
                    if (!_inSelectMode) {
                      // Save consoles.
                      SharedPreferences.getInstance().then((pref) {
                        pref.setStringList(
                            "consoles",
                            _saves
                                .map((save) => jsonEncode(save.toJson()))
                                .toList());

                        // Set the
                        pref.setString("recentlyUsed",
                            jsonEncode(_saves[index].parameter.toJson()));
                      });

                      // Pop the tapped console.
                      Navigator.of(context).pop(_saves[index].parameter);
                    }
                    // Toggle select for the target in select mode.
                    else {
                      _toggleSelection(index);
                    }
                  },
                  onLongPress: () {
                    setState(() {
                      _toggleSelection(index);
                    });
                  },
                  trailing: !_inSelectMode
                      ? Wrap(children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editConsoleAt(index),
                          ),
                        ])
                      : null,
                ),
              ),
      ),
      onPopInvoked: (final didPop) async {
        // Save current parameters.
        await SharedPreferences.getInstance().then((pref) {
          pref.setStringList("consoles",
              _saves.map((save) => jsonEncode(save.toJson())).toList());
        });
      },
    );
  }

  /// Toggles the selection of the item indexed at [index].
  void _toggleSelection(int index) {
    // Remove if already selected, otherwise add.
    setState(() {
      if (!_selectedIndexes.remove(index)) {
        _selectedIndexes.add(index);
      }
    });
  }

  /// Deletes all selected items.
  void _deleteSelection() {
    final shouldDeleteCompleter = Completer<bool>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Warning"),
        content: const Text(
            "The selected consoles will be lost permanently. Continue?"),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                shouldDeleteCompleter.complete(false);
              },
              child: const Text("No")),
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                shouldDeleteCompleter.complete(true);
              },
              child: const Text("Yes")),
        ],
      ),
    );

    shouldDeleteCompleter.future.then((shouldDelete) {
      // Do nothing if canceled.
      if (!shouldDelete) return;

      final selectionList = _selectedIndexes.toList();
      selectionList.sort();

      // Remove the selection from the tail of the list.
      for (final index in selectionList.reversed) {
        _saves.removeAt(index);
      }

      // Update for also [_save].
      setState(() {
        _selectedIndexes.clear();
      });
    });
  }

  /// Returns the unique title begins with the [title].
  ///
  /// The serial number may be appended to the tail.
  String _getUniqueTitle(String title) {
    final baseTitle = title;
    final existingTitles = _saves.map((save) => save.title).toList();
    int serialNo = 1;

    // Determine the title: "title #".
    while (existingTitles.contains(title)) {
      title = "$baseTitle $serialNo";
      serialNo++;
    }

    return title;
  }

  /// Adds a console.
  Future _addConsole() async {
    // Push the edit page.
    final ConsoleSaveObject? save =
        await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ConsoleEditPage(
          save: ConsoleSaveObject(_getUniqueTitle("Untitled"),
              ConsolePanelParameter(rows: 2, columns: 2, cells: [])),
          focusTitle: true),
    ));

    // Add a save object with the popped parameter.
    if (save != null) {
      _saves
          .add(ConsoleSaveObject(_getUniqueTitle(save.title), save.parameter));
    }

    // Renew the list.
    setState(() {
      _saves.sort((a, b) => a.title.compareTo(b.title));
    });
  }

  /// Edits the console indexed at the [index].
  Future _editConsoleAt(int index) async {
    // Push the edit page.
    final ConsoleSaveObject? save =
        await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ConsoleEditPage(save: _saves[index]),
    ));

    // Update a save object with the popped parameter.
    if (save != null) {
      _saves.removeAt(index);
      _saves
          .add(ConsoleSaveObject(_getUniqueTitle(save.title), save.parameter));

      setState(() {
        _saves.sort((a, b) => a.title.compareTo(b.title));
      });
    }
  }
}

/// The list tile for the console.
class _ConsoleListTile extends ListTile {
  final ConsoleSaveObject saveObject;
  final bool showCheckbox;

  _ConsoleListTile(
    this.saveObject, {
    this.showCheckbox = false,
    super.selected,
    super.onTap,
    super.onLongPress,
    super.trailing,
  }) : super(
          title: Text(saveObject.title),
          leading: showCheckbox
              ? (Icon(
                  selected ? Icons.check_box : Icons.check_box_outline_blank))
              : null,
        );
}
