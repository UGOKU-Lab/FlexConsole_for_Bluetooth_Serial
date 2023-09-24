import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides the target bluetooth device.
///
/// Change the state of the notifier to select the target device.
final targetDeviceProvider = StateProvider<BluetoothDevice?>((ref) {
  return null;
});
