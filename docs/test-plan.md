# E2E test plan (ARTEMIS)

Automated end-to-end tests for EXEMatching, driven by [Google ARTEMIS](https://github.com/google/artemis)
on an Android emulator. Code: [`e2e_test/`](../e2e_test).

## Approach

- **ARTEMIS performs the steps under test.** Each goal is written the way a student would describe the task,
  using the labels on screen. The agent is locked to the app package (`locked_app_package`), except TC-11,
  which checks the Android share sheet.
- **Structured output.** Every run asks the ARTEMIS Outputter for a JSON object (`expected_output`), which the
  test parses and asserts field by field.
- **Ground truth from the device.** The agent's report alone is not trusted. After each run the test reads the
  real accessibility tree over adb (`Semantics.identifier` is exposed as Android `resource-id`) and the
  `analytics_event` lines in Logcat, and asserts on those too.
- **Known start state.** Preconditions are set with adb, not by the agent: `pm clear`, launch, sign in with a
  seeded account, and for Flow 3 a scripted leader vote. The app reseeds its data on every launch, so each run
  starts from the same data.
- **Three runs per case.** `E2E_RUNS=3` (default) parametrises every test as `run1`, `run2`, `run3`; each run
  saves its evidence separately.

## Environment

| Item | Value |
|---|---|
| ARTEMIS | `google/artemis` @ `351ca8422f7b5b54e80a9c1ce03a222e02415b6b`, daemon started with `uv run artemis ui` |
| SDK | `artemis-client` from the same commit (pinned in `e2e_test/pyproject.toml`) |
| Profile | `flash` for the regression suite; `pro` for the exploratory session |
| LLM | Gemini, key in `artemis/.env` (`GEMINI_API_KEY`), never in this repository |
| Device | Android emulator `Pixel_API_36` (Android 16, 1080×2400, 420 dpi), serial `emulator-5554` |
| App | debug APK from `flutter build apk --debug`, package `com.devorganize222.exematching` |
| Test data | `assets/seed/seed.json`; accounts `minh.le@fpt.edu.vn` (Team AI-04, 3/5, no leader) and `an.tran@fpt.edu.vn` (no team) |

## Test cases

| ID | Flow / screen | Precondition | Goal given to ARTEMIS | Assertions (output + device) |
|---|---|---|---|---|
| TC-01 | Sign In, error path | Signed out | Sign in with the personal Gmail account | `signed_in=false`, title "This is not an FPT account"; `sign_in_message` banner on screen |
| TC-02 | Sign In → Home | Signed out | Sign in as Minh, read greeting, deadline, team | "Hi, Minh", deadline "… left", Team AI-04; `card_deadline` shown; `login` event |
| TC-03 | Flow 1, Browse | An signed in | Filter AI/ML, search "drone" | 1 result, Team AI-04; `browse_result_count` = 1; `search` event |
| TC-04 | Flow 1, empty state | An signed in | Search "quantum", clear filters | "No teams match your search"; 4 teams after clearing |
| TC-05 | Flow 1, offline | An signed in, network off | Open Browse; then retry online | "Can't connect right now" with Try Again; 4 teams after retry, no `state_error` |
| TC-06 | Flow 1, join | An signed in | Join FinTech Guard | Joined, My Team = FinTech Guard 3 of 5; `member_s_an` on screen; `join_group` event |
| TC-07 | Flow 1, alternative path | An signed in | Join EduSmart Analytics | Not joined, "just filled up", Join disabled, 5/5; `banner_team_filled` |
| TC-08 | Flow 2, hidden tallies | Minh signed in | Open voting without voting | Counts hidden, "Results appear after you vote", Submit disabled |
| TC-09 | Flow 2, vote | Minh signed in | Vote for Minh Le | Leader Minh Le with 2 votes; `banner_leader_elected`; `cast_vote` event |
| TC-10 | Flow 3, error + recovery | Minh elected leader | Review & Lock, invite from pool, lock | First error "Can't lock yet…", Khanh Vo joined, code `CM-AI04-XXXX`; `state_locked`; `invite_from_pool`, `lock_roster` events |
| TC-11 | Flow 3, native share sheet | Minh elected leader | Share Team Link, stop at the share sheet | Sheet open, text mentions the team; foreground activity is `com.android.intentresolver` |
| TC-12 | Alerts | Minh signed in | Decline FinTech invite, then Undo | 0 invites after decline, 1 after undo; "Invites (1)" on screen |
| TC-13 | Profile, file upload | Minh signed in | Export & Upload PDF | File `team-ai-04-YYYYMMDD-HHMM.pdf`, size > 0; `export_done`; `export_report` event |

13 cases × 3 runs = 39 runs per full pass.

## How to run

```powershell
# 1. ARTEMIS (once): put GEMINI_API_KEY in C:\PRM393\artemis\.env, then
cd C:\PRM393\artemis; uv run artemis ui        # daemon + console on http://127.0.0.1:8000

# 2. App on the emulator
flutter build apk --debug; adb install -r build\app\outputs\flutter-apk\app-debug.apk

# 3. Tests
cd e2e_test; uv sync
uv run pytest -v --junitxml=evidence/junit.xml           # all cases, 3 runs each
uv run pytest -v -k tc10 -s                               # one case
```

## Evidence

`e2e_test/evidence/<test>/run<N>/` holds, for every run: `result.json` (goal, ARTEMIS trace id, status,
turns, duration, raw output), `final.png` (device screenshot), `screen.txt` (accessibility tree) and
`analytics.txt` (events seen in Logcat). `evidence/junit.xml` is the pytest report. ARTEMIS keeps the
full trace for each trace id in its console.

## Results

Filled in after each full pass (see `evidence/junit.xml`).

| ID | Run 1 | Run 2 | Run 3 | Notes |
|---|---|---|---|---|
| TC-01 … TC-13 | pending | pending | pending | Waiting for a Gemini key in `artemis/.env` |
