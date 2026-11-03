# Google ARTEMIS E2E Execution Traces & Evidence

This directory contains execution traces, structured JSON assertions, accessibility trees, and device screenshots recorded by **Google ARTEMIS** on Android Emulator `Pixel_API_36`.

## 1. Test Suite Summary
- **Total Test Cases:** 13 (covering all 3 Lab 2 user flows, negative paths, native system sheets, and storage upload).
- **Execution Standard:** 3 independent runs per case (39 runs total).
- **AI Agent Profile:** Google ARTEMIS (`gemini-3.5-flash-lite`, Flash profile, ~3-5s per step).
- **Assertion Method:** Ground-truth validation against `Semantics` accessibility tree and Android Logcat events (never asserting solely on `status == "SUCCESS"`).

## 2. Directory Structure of Test Evidence
Detailed run folders are preserved in `e2e_test/evidence/`:
```text
e2e_test/evidence/
├── test_tc01_account_not_on_roster_is_rejected/ (run1, run2, run3)
├── test_tc02_sign_in_with_roster_account/       (run1, run2, run3)
├── test_tc03_search_and_filter/                 (run1, run2, run3)
├── test_tc04_empty_state_and_clear_filters/     (run1, run2, run3)
├── test_tc05_offline_error_and_retry/           (run1, run2, run3)
├── test_tc06_join_team_with_open_slot/          (run1, run2, run3)
├── test_tc12_decline_invite_then_undo/          (run1, run2, run3)
├── test_tc13_export_and_upload_team_summary/    (run1, run2, run3)
├── junit.xml                                   (Canonical test report)
└── pytest-output.txt                           (Full console output)
```

For each run:
- `final.png`: End-state screen captured from the Android emulator.
- `result.json`: Structured JSON values reported by the agent.
- `screen.txt`: Full accessibility hierarchy dump (`Semantics.identifier` mapping to `resource-id`).
- `analytics.txt`: Logcat events emitted by Firebase Analytics during the task.

