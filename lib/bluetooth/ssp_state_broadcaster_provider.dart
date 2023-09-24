import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flex_console_for_bluetooth_serial/bluetooth/connection_provider.dart';
import 'package:flex_console_for_bluetooth_serial/bluetooth/ssp_state_broadcaster.dart';
import 'package:flex_console_for_bluetooth_serial/bluetooth/target_device_provider.dart';

/// Provides a broadcaster.
final sspStateBroadcasterProvider = Provider<SspStateBroadcaster>((ref) {
  final connection = ref.watch(connectionProvider);
  final device = ref.watch(connectionTargetDeviceProvider);

  return connection.when(
    loading: () => SspStateBroadcaster(),
    data: (connection) {
      final inputStream = connection?.input?.asBroadcastStream();

      // Add a listener to detect the disconnection.
      inputStream?.listen((event) {}, onDone: () {
        // Unselect the target if disconnected naturally.
        if (ref.read(connectionTargetDeviceProvider) == device) {
          ref.read(targetDeviceProvider.notifier).state = null;
        }
      });

      // Agent the output sink with the connection status of the device.
      final outputStreamController = StreamController<Uint8List>();

      outputStreamController.stream.listen((event) {
        if (device?.isConnected ?? false) {
          connection?.output.add(event);
        }
      });

      // Combine input and output streams.
      return SspStateBroadcaster(
        inputStream: inputStream,
        outputSink: outputStreamController.sink,
      );
    },
    error: (error, trace) => SspStateBroadcaster(),
  );
});
