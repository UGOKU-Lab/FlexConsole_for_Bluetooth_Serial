import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flex_console_for_bluetooth_serial/bluetooth/spp_state_broadcaster_provider.dart';
import 'package:flex_console_for_bluetooth_serial/bluetooth/spp_state_broadcaster.dart';
import 'package:flex_console_for_bluetooth_serial/util/broadcaster/multi_channel_broadcaster.dart';

/// Provides a multi-channel broadcaster for the current connection.
final broadcasterProvider = Provider<MultiChannelBroadcaster>((ref) {
  return ref.watch(sspStateBroadcasterProvider);
});

/// Provides list of available channels on the [broadcasterProvider].
final availableChannelProvider = Provider<Iterable<BroadcastChannel>>((ref) {
  return List.generate(256, (index) => SppStateChannel(index));
});
