import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flex_console_for_bluetooth_serial/bluetooth/connection_provider.dart';
import 'package:flex_console_for_bluetooth_serial/bluetooth/target_device_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// The page to connect a bluetooth device.
class DeviceConnectionPage extends StatefulWidget {
  const DeviceConnectionPage({Key? key}) : super(key: key);

  @override
  State<DeviceConnectionPage> createState() => _DeviceConnectionPageState();
}

class _DeviceConnectionPageState extends State<DeviceConnectionPage> {
  /// Checks the permissions and start discovering bluetooth devices.
  late final _startupTask = !kIsWeb && Platform.isAndroid
      ? Future(() async {
          // Try to get the permission for the bluetooth connection.
          final permissions = await [
            Permission.bluetoothConnect,
            Permission.bluetoothScan
          ].request();

          if (!permissions.values.every((permission) => permission.isGranted)) {
            throw Exception("Required permissions are not granted.");
          }
        }).then((_) => _startDiscovery())
      : Future.error(Exception("This platform is not supported."));

  /// The devices discovered.
  final _discoveredDevices = <BluetoothDevice>{};

  /// The subscription for the stream of the discovering results.
  StreamSubscription? _discoverySubscription;

  void _startDiscovery() {
    _discoverySubscription?.cancel();

    setState(() {
      _discoveredDevices.clear();

      _discoverySubscription =
          FlutterBluetoothSerial.instance.startDiscovery().listen(
        (result) {
          setState(() => _discoveredDevices.add(result.device));
        },
        onDone: () => setState(() => _discoverySubscription = null),
      );
    });
  }

  @override
  void dispose() {
    _discoverySubscription?.cancel();
    FlutterBluetoothSerial.instance.cancelDiscovery();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Peripheral Devices'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _discoverySubscription == null ? _startDiscovery : null,
            icon: const Icon(Icons.replay),
          )
        ],
      ),
      body: FutureBuilder(
        future: _startupTask,
        builder: (context, snapshot) {
          // Handle error.
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Theme.of(context).colorScheme.error),
                  const Text(""),
                  const Text("Failed to discover devices.")
                ],
              ),
            );
          }

          // List the bonded devices.
          if (snapshot.connectionState == ConnectionState.done) {
            return Consumer(
              builder: (context, ref, _) {
                // The notifier of the target device for the request.
                final targetDeviceNotifier =
                    ref.watch(targetDeviceProvider.notifier);

                // The actual target device.
                final currentTargetDevice =
                    ref.watch(connectionTargetDeviceProvider);

                // The status of the connection.
                final connectionStatus = ref.watch(connectionProvider).when(
                    data: (data) => 'established',
                    loading: () => 'negotiating',
                    error: (error, trace) => 'error');

                // The list of the discovered devices.
                final deviceList = _discoveredDevices.toList();

                return ListView.builder(
                  itemCount: deviceList.length,
                  itemBuilder: (context, index) {
                    final BluetoothDevice device = deviceList[index];

                    return ListTile(
                      title: Text(device.name ?? "-"),
                      subtitle: Text(device.address),
                      enabled: connectionStatus != 'negotiating',
                      trailing: currentTargetDevice == device
                          ? connectionStatus == 'established'
                              ? const Icon(Icons.bluetooth_connected)
                              : connectionStatus == 'negotiating'
                                  ? const CircularProgressIndicator()
                                  : const Icon(Icons.error)
                          : null,
                      onTap: () {
                        // Request the connection to the device.
                        targetDeviceNotifier.state = device;
                      },
                    );
                  },
                );
              },
            );
          }

          // Show the indicator.
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
