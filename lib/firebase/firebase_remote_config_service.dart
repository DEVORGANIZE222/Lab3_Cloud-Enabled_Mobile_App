import 'dart:async';
import '../services/services.dart';

/// Firebase Remote Config implementation with fallback defaults.
class FirebaseRemoteConfigService implements ConfigService {
  final _changesController = StreamController<void>.broadcast();

  @override
  Stream<void> get changes => _changesController.stream;

  @override
  int getInt(String key) {
    // TODO: Read from FirebaseRemoteConfig.instance.getInt(key)
    return (ConfigKeys.defaults[key] as int?) ?? 0;
  }

  @override
  bool getBool(String key) {
    // TODO: Read from FirebaseRemoteConfig.instance.getBool(key)
    return (ConfigKeys.defaults[key] as bool?) ?? false;
  }

  @override
  Future<bool> refresh() async {
    // TODO: FirebaseRemoteConfig.instance.fetchAndActivate()
    return false;
  }
}
