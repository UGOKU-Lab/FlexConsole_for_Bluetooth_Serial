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
  Stream<double>? streamOn(BroadcastChannel channel);

  Sink<double>? sinkOn(BroadcastChannel channel);
}
