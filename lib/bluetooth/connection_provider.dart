import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flex_console_for_bluetooth_serial/bluetooth/target_device_provider.dart';

/// Whether the connection process is on-going.
bool _negotiating = false;

/// The connection target.
BluetoothDevice? _connectionTargetDevice;

/// The connection.
BluetoothConnection? _connection;

/// Provides the current target device associated with the [connectionProvider].
///
/// This filters the devices from [targetDeviceProvider] to keep the connection
/// process legal. Successors received during the connection process will be
/// ignored.
final connectionTargetDeviceProvider = Provider<BluetoothDevice?>((ref) {
  final device = ref.watch(targetDeviceProvider);

  if (!_negotiating) {
    _connectionTargetDevice = device;
    return _connectionTargetDevice;
  }

  return _connectionTargetDevice;
});

/// Provides the bluetooth connection.
///
/// The target device of the connection can be got through the
/// [connectionTargetDeviceProvider].
final connectionProvider = FutureProvider<BluetoothConnection?>((ref) async {
  final device = ref.watch(connectionTargetDeviceProvider);

  if (device != null) {
    // Start the connection process.
    _negotiating = true;

    // Try to connect the target.
    try {
      await _connection?.close();
      _connection = await BluetoothConnection.toAddress(device.address);
    } catch (error) {
      // Unselect the target.
      ref.read(targetDeviceProvider.notifier).state = null;
    } finally {
      _negotiating = false;
    }
  } else {
    if (_connection?.isConnected ?? false) {
      await _connection?.close();
    }

    // End the connection process.
    _connection = null;
  }

  return _connection;
});
