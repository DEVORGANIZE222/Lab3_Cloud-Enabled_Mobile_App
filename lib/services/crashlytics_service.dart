abstract class CrashlyticsService {
  Future<void> setUserIdentifier(String userId);
  Future<void> setCustomKey(String key, dynamic value);
  Future<void> recordError(dynamic exception, StackTrace? stack, {String? reason});
  void triggerTestCrash();
}

class FirebaseCrashlyticsService implements CrashlyticsService {
  @override
  Future<void> setUserIdentifier(String userId) async {}

  @override
  Future<void> setCustomKey(String key, dynamic value) async {}

  @override
  Future<void> recordError(dynamic exception, StackTrace? stack, {String? reason}) async {}

  @override
  void triggerTestCrash() {}
}
