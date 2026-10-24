# EXEMatching: Lab 3 Cloud-Enabled Mobile App

PRM393 Lab 3, team DEVORGANIZE222. A Flutter Android app for FPT Capstone team registration, built from the team's
Lab 2 design ([Figma PRM_LAB2](https://www.figma.com/design/Z42q9LamOZojK54FSBDcCd/PRM_LAB2),
[Lab 2 repo](https://github.com/DEVORGANIZE222/PRM393_LAB2_uiuxdesign)), with an AI-driven E2E suite (Google ARTEMIS)
and an AI code review.

Students sign in with their @fpt.edu.vn Google account, find a team with open slots and join it (Flow 1), elect a
leader (Flow 2), and the leader locks the roster, recovering from "too few members" by inviting from the Waiting Pool
(Flow 3).

## Contents

| Path | What it is |
|---|---|
| `lib/` | The app: MVVM with Provider, go_router. See [docs/architecture.md](docs/architecture.md). |
| `lib/services/services.dart` | Service interfaces (auth, teams, notifications, config, analytics, crash reporting, storage). |
| `lib/services/local/` | Seeded local implementations used now. The Firebase implementations replace them in `lib/app/providers.dart` only. |
| `assets/seed/seed.json` | Test data: students, teams, notifications, pool. Reloaded on every launch. |
| `e2e_test/` | ARTEMIS E2E suite (Python). See [docs/test-plan.md](docs/test-plan.md). |
| `docs/design-traceability.md` | Figma frame → route → widget → ViewModel → screenshot, and every deviation from Figma with its reason. |
| `docs/screenshots/` | One screenshot per Figma frame, from the running app. |
| `docs/code-review.md` | AI code review: findings, decisions and fix commits. |

## Run the app

Requirements: Flutter **3.47.4** (Dart **3.13.3**; any Flutter 3.47.x from 3.47.3 works), Android SDK, an emulator or device on Android 7.0+.

```bash
flutter pub get
flutter run
```

Sign in from the account picker with a seeded test account (no password; the picker simulates Google Sign-In):

| Account | Starting state | Good for |
|---|---|---|
| `minh.le@fpt.edu.vn` | Team AI-04, 3 of 5 members, no leader | Flows 2 and 3, Alerts, Profile |
| `an.tran@fpt.edu.vn` | No team | Flow 1 (join FinTech Guard; EduSmart Analytics fills up just before you join) |
| `minh.personal@gmail.com` | Not an FPT account | The wrong-account error on Sign In |

Data resets every time the app starts; the signed-in account is remembered.

Config values (Remote Config keys) can be overridden at build time, for example to show the Random Pool screen:

```bash
flutter run --dart-define=CONFIG_OVERRIDES=registration_closed=true,browse_max_results=3
```

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
| Claude Code (Anthropic, Claude Opus 5.5) | Writing the Flutter app, the E2E suite and the docs with the team; reviews and fixes recorded in commits | Commits marked `Co-Authored-By: Claude` |
| Claude Code `/code-review` | AI code review of `lib/` | [docs/code-review.md](docs/code-review.md) |
| Google ARTEMIS with Gemini | Running the E2E goals on the emulator | `e2e_test/`, `e2e_test/evidence/`, [docs/test-plan.md](docs/test-plan.md) |

Every AI result was checked by a person: E2E assertions read the real device state, not only the agent's report, and
every code review finding has a recorded decision.

## Firebase

Firebase (Auth, Firestore, Cloud Messaging, Storage, Remote Config, Analytics, Crashlytics) is done by another team
member. Each service has an interface in `lib/services/services.dart`, and the comments name the Firebase behaviour
each one needs. Swap the `Local*` / `Debug*` classes in `lib/app/providers.dart`; no screen or ViewModel changes.
