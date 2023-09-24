import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flex_console_for_bluetooth_serial/broadcaster_provider.dart';

/// Creates a dropdown button to select a broadcast channel.
class ChannelSelector extends ConsumerWidget {
  final String? labelText;
  final String? initialValue;
  final void Function(String?)? onChanged;

  const ChannelSelector({
    super.key,
    this.labelText,
    this.initialValue,
    this.onChanged,
  });

  @override
  Widget build(context, ref) {
    var channel = initialValue;

    final availableChannels = ref.watch(availableChannelProvider);

    // Reset the channel if not available.
    if (availableChannels.every((chan) => chan.identifier != channel)) {
      channel = null;
    }

    // Return the stated dropdown button; the state makes the button can display
    // the selected option.
    return StatefulBuilder(
      builder: (context, setState) => DropdownButtonFormField(
        decoration: InputDecoration(labelText: labelText),
        itemHeight: null,
        isExpanded: true,
        value: channel,
        selectedItemBuilder: (context) => [
          Container(
              height: kMinInteractiveDimension,
              alignment: Alignment.centerLeft,
              child: const Text("Empty")),
          ...availableChannels.map((chan) => Container(
              height: kMinInteractiveDimension,
              alignment: Alignment.centerLeft,
              child: Text(chan.name ?? chan.identifier))),
        ],
        items: [
          const DropdownMenuItem(
              child: ListTile(
                  title: Text("Empty"),
                  subtitle: Text("No channel to allocate."))),
          ...availableChannels.map((chan) => DropdownMenuItem(
              value: chan.identifier,
              child: ListTile(
                title: Text(chan.name ?? chan.identifier),
                subtitle:
                    chan.description != null ? Text(chan.description!) : null,
              )))
        ],
        onChanged: (value) {
          setState(() {
            channel = value;
          });
          onChanged?.call(channel);
        },
      ),
    );
  }
}
