# EXEMatching: Lab 3 Cloud-Enabled Mobile App

PRM393 Lab 3, team DEVORGANIZE222. A Flutter Android app for FPT Capstone team registration, built from the team's
Lab 2 design ([Figma PRM_LAB2](https://www.figma.com/design/Z42q9LamOZojK54FSBDcCd/PRM_LAB2),
[Lab 2 repo](https://github.com/DEVORGANIZE222/PRM393_LAB2_uiuxdesign)), with an AI-driven E2E suite (Google ARTEMIS)
and an AI code review.

Students sign in with their @fpt.edu.vn Google account, find a team with open slots and join it (Flow 1), elect a
leader (Flow 2), and the leader locks the roster, recovering from "too few members" by inviting from the Waiting Pool
(Flow 3).

## Contents & Deliverables

| Path | What it is |
|---|---|
| `lib/` | The app: MVVM with Provider, go_router. See [docs/architecture.md](docs/architecture.md). |
| `lib/firebase/` | Concrete Firebase implementations: Auth, Firestore, Storage, Messaging, Analytics, Remote Config, Crashlytics. |
| `lib/services/services.dart` | Abstract service interfaces keeping ViewModels and UI completely decoupled from Firebase SDKs. |
| `e2e_test/` | ARTEMIS E2E suite (Python). 13 test cases x 3 runs = 39 runs. See [docs/test-plan.md](docs/test-plan.md). |
| `evidence/` | Verifiable proofs: console screenshots, DebugView events, Crashlytics reports, Remote Config before/after. |
| `docs/design-traceability.md` | Figma frame → route → widget → ViewModel → screenshot, and 16 systematic deviations with heuristics. |
| `docs/code-review.md` | AI code review on PR #8 (Google Gemini): 5 findings across 3 categories, 3 fix commits. |
| `report/Lab03_DEVORGANIZE222.pdf` | **Final Report (10 pages, PDF)** satisfying all 11 required sections. |
| `slides/Lab03_DEVORGANIZE222_slides.pdf` | **Presentation slides (17 slides, PDF)**, built by `dart run tool/generate_slides_pdf.dart`. |
| `slides/Lab03_DEVORGANIZE222_slides.pptx` | The same deck as an editable PowerPoint file for Canva or PowerPoint, built by `python tool/generate_slides_pptx.py` (needs `python-pptx` and `pillow`). |
| **Demo Video Link** | _Not uploaded yet: add the Drive/YouTube link here after recording._ |

## Run the app

Requirements: Flutter **3.47.4** (Dart **3.13.3**; any Flutter 3.47.x from 3.47.3 works), Android SDK, an emulator or device on Android 7.0+.

```bash
flutter pub get
flutter run
```

The app talks to the live Firebase project `prm393-lab-3-exematching` (`android/app/google-services.json`).
Before the first run:

1. Register your debug keystore SHA-1 for the Android app in the Firebase Console (Google Sign-In needs it).
2. Seed Firestore (registration window, roster, 5 teams, Waiting Pool, students):
   `python tool/seed_firestore_lab3.py --token "$(gcloud auth print-access-token)"` (or `--key serviceAccount.json`).
3. Add the Google account you sign in with to `allowedEmails/{email}` with `enabled: true`; any other account is
   rejected with "This account is not on the class roster".
4. Deploy the rules in `firebase/firestore.rules` and `firebase/storage.rules`.

For the Remote Config demo, publish `registration_closed = true` in the console (the Waiting Pool entry on Home also needs `enable_waiting_pool = true`, the default); the app activates
updates in real time (`onConfigUpdated`). For DebugView: `adb shell setprop debug.firebase.analytics.app com.devorganize222.exematching`.

## Run the E2E tests

1. Install [Google ARTEMIS](https://github.com/google/artemis) at commit `351ca84` and put your own `GEMINI_API_KEY` in
   ARTEMIS's `.env` (never in this repository). Start it with `uv run artemis ui`.
2. Build and install the app on the emulator: `flutter build apk --debug`, then
   `adb install -r build/app/outputs/flutter-apk/app-debug.apk`.
3. Run the suite (13 cases, 3 runs each):

```bash
cd e2e_test
uv sync
uv run pytest -v --junitxml=evidence/junit.xml
```

Evidence for every run (agent output, screenshot, accessibility tree, analytics events) is written to
`e2e_test/evidence/`. Details, cases and results: [docs/test-plan.md](docs/test-plan.md).

## Pinned versions

| Component | Version |
|---|---|
| Flutter / Dart | 3.47.4 / 3.13.3 |
| go_router | 18.1.1 |
| provider | 6.1.5+1 |
| intl | 0.20.3 |
| shared_preferences | 2.5.6 |
| path_provider | 2.1.6 |
| pdf | 3.13.1 |
| share_plus | 13.3.1 |
| flutter_lints | 6.0.0 |
| Google ARTEMIS and `artemis-client` | commit `351ca8422f7b5b54e80a9c1ce03a222e02415b6b` |
| pytest / pytest-asyncio | 8.4.2 / 1.2.0 |
| LLM for ARTEMIS runs | `gemini-3.5-flash-lite` (fallback `gemini-3.1-flash-lite`), ARTEMIS `flash` profile |
| Test device | Android emulator Pixel API 36 (Android 16), 1080 × 2400 |

## AI tools used

| Tool | Used for | Where the output is |
|---|---|---|
| Claude Code / Antigravity | Writing the Flutter app, MVVM architecture, E2E suite and docs | Git commits and documentation |
| Google Gemini (`gemini-3.5-flash-lite`) | Automated Pull Request #8 code review via GitHub Actions | [docs/code-review.md](docs/code-review.md) & GitHub review comments |
| Google ARTEMIS with Gemini Flash | Driving the 13 automated E2E test cases on the Android 16 emulator | `e2e_test/`, `e2e_test/evidence/`, [docs/test-plan.md](docs/test-plan.md) |
| Google ARTEMIS with Gemini Pro | Unscripted exploratory testing session | [docs/test-plan.md §4](docs/test-plan.md) |

Every AI result was checked by a human engineer: E2E assertions read real device state, and every code review finding has a recorded decision.

## Firebase Integration (Production Active)

All 6 Firebase services are fully implemented in `lib/firebase/` and actively wired into the application via `lib/app/providers.dart`:
- **Authentication**: Native Google Sign-In with Centralized Roster Allowlist (`allowedEmails` in Firestore).
- **Cloud Firestore**: Atomic transactions for team joins, votes, lock operations, and Waiting Pool recovery. Security rules strictly enforce authorization.
- **Cloud Storage**: Per-user team report exports to `reports/{uid}/...` protected by UID-isolated rules.
- **Cloud Messaging (FCM)**: Push notification handling across foreground, background, and terminated lifecycle states, with deep navigation.
- **Analytics**: 10 events with ID/count parameters only (no email, name or search text); `login` with the user ID, `search_teams` and `cast_vote` shown in DebugView ([evidence/debugview](evidence/debugview)).
- **Crashlytics & Remote Config**: Fatal error capture, handled diagnostic reporting with custom keys, and zero-rebuild runtime configuration updates.

---

## Demo Video Script & Walkthrough (Target: 7–8 Minutes)

The demo video follows the exact walkthrough order specified in Handout Section 9:

| Timestamp | Segment | What is Shown on Screen & In Firebase Console |
|---|---|---|
| **00:00 – 00:45** | **Intro & Sign-In (Auth)** | • App launch on Android emulator.<br>• Sign-in attempt with unauthorized account -> "This account is not on the class roster" banner.<br>• Sign-in with allowed roster account -> Lands smoothly on Home Dashboard.<br>• Console: Show Authentication -> Users tab matching project ID `prm393-lab-3-exematching`. |
| **00:45 – 02:00** | **Flow 1: Discover & Join Team** | • Navigate to Browse tab; toggle skill chip "AI/ML" and search "drone".<br>• Show empty state by searching non-existent term, then tap "Clear Filters".<br>• Simulate network drop via Airplane mode -> Observe "Can't connect right now" error -> Reconnect & tap "Try Again".<br>• Open FinTech Guard, tap Join Team and confirm. My Team shows 3 of 5 members. |
| **02:00 – 03:00** | **Flow 2: Leader Election** | • Switch to My Team tab; open "Vote for Leader" screen.<br>• Demonstrate that vote tallies remain hidden before casting a vote.<br>• Select yourself as candidate and submit the vote.<br>• Observe Firestore real-time transaction update; leader elected banner appears. |
| **03:00 – 04:15** | **Flow 3: Lock & Recovery** | • Leader navigates to "Review & Lock". Initial attempt blocked (<4 members).<br>• Tap "Invite from Waiting Pool" -> Automated candidate matching assigns `Khanh Vo`.<br>• Condition checks turn green; tap "Lock Roster" -> Generates official code `CM-AI04-XXXX`.<br>• Tap "Share Team Link" -> Android system Share Sheet opens natively. |
| **04:15 – 05:15** | **Storage & FCM Live Demo** | • Profile screen: Tap "Export & Upload PDF". Progress bar reaches 100%, displaying download URL.<br>• Console: Show Storage bucket with file under `reports/{uid}/`.<br>• Send FCM test notification from Console -> Verify in-app Alerts inbox badge and tap navigation. |
| **05:15 – 06:15** | **Remote Config & Crashlytics** | • Console: add `registration_closed = true` and Publish -> while the app stays open, Home switches to the "Registration closed" banner and shows "View matching status" (Waiting Pool). Delete the parameter and Publish again to reopen registration.<br>• Profile screen: Tap "Send Test Error" -> Snackbar confirms non-fatal sent.<br>• Tap "Force Test Crash" -> App crashes.<br>• Console: Show Crashlytics dashboard with Fatal issue, User ID, and custom key `screen=profile`. |
| **06:15 – 07:00** | **ARTEMIS Automated E2E Run** | • Terminal: Run `uv run pytest -k "test_tc03" -v` -> Show ARTEMIS AI agent controlling the device live, asserting on Semantics tree and Logcat.<br>• Show `junit.xml` test results. |
| **07:00 – 07:30** | **AI Code Review Walkthrough** | • Show GitHub Pull Request #8 review comments.<br>• Explain finding GR-01 (team updates were not limited to roster fields) and the corresponding fix commit `c9543a3`. |
