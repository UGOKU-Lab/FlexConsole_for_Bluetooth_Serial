import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flex_console_for_bluetooth_serial/util/broadcaster/multi_channel_broadcaster.dart';

@immutable
class EchoBackChannel implements BroadcastChannel {
  final String value;

  @override
  String get identifier => value;

  @override
  String? get name => "Channel $value";

  @override
  String? get description => 'A channel named "$value".';

  const EchoBackChannel(this.value);
}

@immutable
class EchoBackData {
  final int value;

  const EchoBackData({required this.value});
}

class EchoBackBroadcaster implements MultiChannelBroadcaster {
  final List<EchoBackChannel> channels;

  final _root = StreamController<_EchoBackRawData>.broadcast();
  final Map<String, _TwoWayStreamController> _branches = {};
  final Map<EchoBackChannel, double> _dataMap = {};

  EchoBackBroadcaster(this.channels);

  @override
  Stream<double>? streamOn(String channelId) {
    final channel = _getChannel(channelId);

    if (channel == null) {
      return null;
    }

    return _getBranch(channel)?.downward.stream;
  }

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

    return _dataMap[channel];
  }

  EchoBackChannel? _getChannel(String channelId) {
    return channels
        .where((channel) => channel.identifier == channelId)
        .firstOrNull;
  }

  _TwoWayStreamController? _getBranch(EchoBackChannel channel) {
    if (!_branches.containsKey(channel.value)) {
      final upward = StreamController<double>();
      final downward = StreamController<double>.broadcast();

      // Distribute data to the branch by the channel.
      _root.stream
          .where((event) => event.channelId == channel.identifier)
          .listen((event) => downward.sink.add(event.value));

      // Pass data to the root with the channel.
      upward.stream.listen((event) {
        _dataMap[channel] = event;
        _root.sink.add(_EchoBackRawData(channel.value, event));
      });

      _branches[channel.value] = (upward: upward, downward: downward);
    }

    return _branches[channel.value];
  }
}

typedef _TwoWayStreamController = ({
  StreamController<double> upward,
  StreamController<double> downward
});

@immutable
class _EchoBackRawData {
  final String channelId;
  final dynamic value;

  const _EchoBackRawData(this.channelId, this.value);
}
