import '../services/services.dart';

/// Firebase Crashlytics implementation.
class FirebaseCrashReporter implements CrashReporter {
  @override
  Future<void> setUserId(String? id) async {
    // TODO: FirebaseCrashlytics.instance.setUserIdentifier(id ?? '')
  }

  @override
  Future<void> setKey(String key, Object value) async {
    // TODO: FirebaseCrashlytics.instance.setCustomKey(key, value)
  }

  @override
  Future<void> recordError(Object error, StackTrace stack, {required String reason}) async {
    // TODO: FirebaseCrashlytics.instance.recordError(error, stack, reason: reason)
  }

  @override
  Future<void> testCrash() async {
    // TODO: FirebaseCrashlytics.instance.crash()
  }
}
