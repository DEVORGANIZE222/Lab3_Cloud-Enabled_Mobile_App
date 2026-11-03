# Firebase Crashlytics Evidence

This directory contains verifiable records of crashes and handled non-fatal errors in **Firebase Crashlytics Dashboard** for package `com.devorganize222.exematching`.

## 1. Handled Non-Fatal Error (Diagnostic Flow)
- **Trigger Location:** Profile Screen -> Action `Send Test Error`.
- **Implementation:** `ProfileViewModel.sendNonFatal()` sets custom diagnostic keys (`screen=profile`, `cohort=FA26`, `team_id=demo-flutter`) and calls `CrashReporter.recordError()`.
- **UI Feedback:** Displays a non-blocking toast/snackbar: *"Non-fatal error sent with your user ID and key 'screen'"*.
- **Console Verification:**
  - Issue recorded under Crashlytics Non-fatal events.
  - Keys tab displays: `screen: profile`, `cohort: FA26`.
  - Data tab displays: Authenticated User ID.

## 2. Deliberate Fatal Crash (Test Crash Action)
- **Trigger Location:** Profile Screen -> Action `Force Test Crash`.
- **Implementation:** `FirebaseCrashReporter.testCrash()` invokes `FirebaseCrashlytics.instance.crash()`.
- **Android Logcat Output:**
  ```text
  FATAL EXCEPTION: main
  Process: com.devorganize222.exematching
  java.lang.Error: FirebaseCrashlyticsTestCrash
  ```
- **Console Verification:**
  - Issue title: `FlutterFirebaseCrashlyticsPlugin.crash$lambda$0` / `FirebaseCrashlyticsTestCrash`.
  - Event count: `1 crash / 1 user`.
  - Crash stack trace clearly pinned to test trigger line.

