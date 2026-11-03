# Firebase Remote Config Evidence

This directory documents the dynamic configuration verification without rebuilding the Flutter application (`prm393-lab-3-exematching`).

## 1. Parameters Configured
Defined in `firebase/remote-config-defaults.json` and mirrored on Firebase Console:
- `enable_waiting_pool` (boolean, default: `true`): Controls visibility of Waiting Pool shortcut on Home Dashboard.
- `max_team_members` (integer, default: `5`): Maximum student capacity per team.
- `registration_closed` (boolean, default: `false`): Feature flag to simulate registration deadline expiry.

## 2. Dynamic Update Verification (Zero-Rebuild)
- **Mechanism:** `FirebaseRemoteConfigService` listens to `onConfigUpdated` stream and automatically invokes `activate()`.
- **In Debug Mode:** `minimumFetchInterval` is set to `Duration.zero` to enable instant live demonstration for the lecturer.
- **Console Demonstration:**
  1. Default State: `enable_waiting_pool = true` -> Dashboard renders Waiting Pool navigation card.
  2. Modified State: Change `enable_waiting_pool = false` on Firebase Console -> Click **Publish changes**.
  3. App Reaction: App receives update event; Waiting Pool card dynamically hides without restarting or reinstalling the APK.

