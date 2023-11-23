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
  final Stream<Uint8List>? inputStream;
  final Sink<Uint8List>? outputSink;

  late Timer _timer;
  final _sendDataMap = <SppStateChannel, int>{};

  /// The stream that translate the binary data from the [inputStream] and
  /// [outputSink] to the [_ValueOnChannel], then broadcasts to the branches.
  late final _root = StreamController<_ValueOnChannel>.broadcast();

  /// The branches of root streams.
  late final _branches =
      <SppStateChannel, _TwoWayStreamController<double, double>>{};

  final _buffer = <int>[];

  /// Creates a broadcaster using [inputStream] and [outputSink].
  SppStateBroadcaster({this.inputStream, this.outputSink}) {
    // Add a listener for the SPP input stream.
    inputStream?.listen((data) {
      _buffer.addAll(data);

      while (_buffer.length >= 3) {
        final sppData = _ValueOnChannel.fromIntList(_buffer);

        if (sppData != null) {
          // Push the data to the downward branches.
          _root.sink.add(sppData);
          _buffer.removeRange(0, 3);
        } else {
          // Discard first byte and go next.
          _buffer.removeAt(0);
        }
      }
    });

    // Set the timer for the first call.
    _timer = Timer(const Duration(milliseconds: 100), _periodicWrite);
  }

  void _periodicWrite() {
    for (final entry in _sendDataMap.entries) {
      final channel = entry.key.value;
      final value = entry.value;

      // Send to the device.
      outputSink?.add(_ValueOnChannel(channel, value).toUint8List());
    }

    _sendDataMap.clear();

    _timer = Timer(const Duration(milliseconds: 100), _periodicWrite);
  }

  void dispose() {
    _timer.cancel();
  }

  /// Gets the stream on the [channel].
  @override
  Stream<double>? streamOn(BroadcastChannel channel) {
    if (channel is! SppStateChannel) return null;

    return _getBranch(channel)?.downward.stream;
  }

  /// Gets the sink on the [channel].
  @override
  Sink<double>? sinkOn(BroadcastChannel channel) {
    if (channel is! SppStateChannel) return null;

    return _getBranch(channel)?.upward.sink;
  }

  _TwoWayStreamController<double, double>? _getBranch(SppStateChannel channel) {
    if (!_branches.containsKey(channel)) {
      final upward = StreamController<double>();
      final downward = StreamController<double>.broadcast();

      // Broadcast data to the branch by the channel.
      _root.stream.listen((event) {
        if (event.channel == channel.value) {
          downward.sink.add(event.value.toDouble());
        }
      });

      // Pass data to the root with the channel.
      upward.stream.listen((event) {
        final value = event.floor();

        // Echo back to downward.
        downward.sink.add(event);

        // Store the data to the map.
        _sendDataMap[channel] = value;
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
