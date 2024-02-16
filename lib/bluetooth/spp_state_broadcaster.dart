import 'dart:async';
import 'dart:typed_data';

import 'package:flex_console_for_bluetooth_serial/util/broadcaster/multi_channel_broadcaster.dart';

class SppStateChannel implements BroadcastChannel {
  int value;

  SppStateChannel(this.value);

  @override
  String get identifier => value.toString();

  @override
  String? get name => "#$value";

  @override
  String? get description => null;

  @override
  int get hashCode => identifier.hashCode;

  @override
  bool operator ==(Object other) {
    return other is SppStateChannel && other.identifier == identifier;
  }
}

class SppStateBroadcaster implements MultiChannelBroadcaster {
  /// Available channels.
  final List<SppStateChannel> channels;

  /// Output sink of SPP communication.
  final Sink<Uint8List>? outputSink;

  /// The stream that translate the binary data from the [inputStream] and
  /// [outputSink] to the [_ValueOnChannel], then broadcasts to the branches.
  final _root = StreamController<_ValueOnChannel>.broadcast();

  /// The branches of root streams.
  final _branches =
      <SppStateChannel, _TwoWayStreamController<double, double>>{};

  late Timer _periodicSendTimer;
  final _sendDataMap = <SppStateChannel, int>{};
  final _receiveBuffer = <int>[];
  final _dataMap = <SppStateChannel, int>{};
  final _channelCache = <String, SppStateChannel?>{};

  /// Creates a broadcaster using [inputStream] and [outputSink].
  SppStateBroadcaster(
    this.channels, {
    Stream<Uint8List>? inputStream,
    this.outputSink,
  }) {
    // Add a listener for the SPP input stream.
    inputStream?.listen(_distribute);

    // Set the timer for the first call.
    _periodicSendTimer =
        Timer(const Duration(milliseconds: 100), _periodicSend);
  }

  void _distribute(data) {
    _receiveBuffer.addAll(data);

    while (_receiveBuffer.length >= 3) {
      final sppData = _ValueOnChannel.fromIntList(_receiveBuffer);

      if (sppData != null) {
        // Push the data to the downward branches.
        _root.sink.add(sppData);
        _receiveBuffer.removeRange(0, 3);
      } else {
        // Discard first byte and go next.
        _receiveBuffer.removeAt(0);
      }
    }
  }

  void _periodicSend() {
    for (final entry in _sendDataMap.entries) {
      final channel = entry.key.value;
      final value = entry.value;

      // Send to the device.
      outputSink?.add(_ValueOnChannel(channel, value).toUint8List());
    }

    _sendDataMap.clear();

    _periodicSendTimer =
        Timer(const Duration(milliseconds: 100), _periodicSend);
  }

  void dispose() {
    _periodicSendTimer.cancel();
  }

  @override
  Stream<double>? streamOn(String channelId) {
    final channel = _getChannel(channelId);

    if (channel == null) {
      return null;
    }

    return _getBranch(channel)?.downward.stream;
  }

  /// Gets the sink on the [channel].
  @override
  Sink<double>? sinkOn(String channelId) {
    final channel = _getChannel(channelId);

    if (channel == null) {
      return null;
    }

    return _getBranch(channel)?.upward.sink;
  }

  @override
  double? read(String channelId) {
    final channel = _getChannel(channelId);

    if (channel == null) {
      return null;
    }

    return _dataMap[channel]?.toDouble();
  }

  SppStateChannel? _getChannel(String channelId) {
    if (_channelCache[channelId] == null) {
      _channelCache[channelId] = channels
          .where((channel) => channel.identifier == channelId)
          .firstOrNull;
    }

    return _channelCache[channelId];
  }

  _TwoWayStreamController<double, double>? _getBranch(SppStateChannel channel) {
    if (!_branches.containsKey(channel)) {
      final upward = StreamController<double>();
      final downward = StreamController<double>.broadcast();

      // Broadcast data to the branch by the channel.
      _root.stream
          .where((event) => event.channel == channel.value)
          .listen((event) {
        downward.sink.add(event.value.toDouble());

        // Store the data to the map.
        _dataMap[channel] = event.value;
      });

      // Pass data to the root with the channel.
      upward.stream.listen((event) {
        final value = event.floor();

        // Echo back to downward.
        downward.sink.add(event);

        // Store the data to the map.
        _sendDataMap[channel] = value;
        _dataMap[channel] = value;
      });

      _branches[channel] = (upward: upward, downward: downward);
    }

    return _branches[channel];
  }
}

/// The bundle of the 2 streams.
typedef _TwoWayStreamController<T, U> = ({
  StreamController<T> upward,
  StreamController<U> downward
});

/// The [value] on the [channel].
///
/// This will be sent/received in 3 bytes:
///
/// - the first byte is the [channel];
/// - the second byte is the [value];
/// - the third byte is the xor checksum of the [channel] and [value].
class _ValueOnChannel {
  int channel, value;

  /// Creates a [value] on the [channel].
  _ValueOnChannel(this.channel, this.value);

  /// Parse the [list] of bytes to the value on channel.
  ///
  /// Returns null if given [list] is an invalid sequence.
  static _ValueOnChannel? fromIntList(List<int> list) {
    if (list.length < 3) {
      return null;
    }

    final channel = list[0];
    final value = list[1];
    final checksum = list[2];

    if (channel ^ value != checksum) {
      return null;
    }

    return _ValueOnChannel(channel, value);
  }

  /// Convert to the byte list.
  Uint8List toUint8List() {
    final checksum = channel ^ value;
    return Uint8List.fromList([channel, value, checksum]);
  }
}
