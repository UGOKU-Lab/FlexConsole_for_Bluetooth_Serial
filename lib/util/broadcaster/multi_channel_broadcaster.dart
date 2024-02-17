import 'dart:async';

abstract class BroadcastChannel {
  String get identifier;
  String? get name;
  String? get description;

  @override
  String toString() => identifier;

  @override
  int get hashCode => identifier.hashCode;

  @override
  bool operator ==(Object other) {
    return hashCode == other.hashCode && runtimeType == other.runtimeType;
  }
}

abstract class MultiChannelBroadcaster {
  /// Gets the stream of the [channelId].
  Stream<double>? streamOn(String channelId);

  /// Gets the sink of the [channelId].
  Sink<double>? sinkOn(String channelId);

  /// Reads the latest value of the [channelId].
  double? read(String channelId);
}
