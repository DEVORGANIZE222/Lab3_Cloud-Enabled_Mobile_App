# AI code review

| | |
|---|---|
| Tool | Claude Code `/code-review` (Anthropic, model Claude Opus 5.5), effort **high** |
| Date | 23 Oct 2026 |
| Target | `lib/` at `826b395` (Merge of PR #1: the app after Flows 1–3) |
| Method | 8 finder angles run by the AI: line-by-line, removed behaviour, cross-file callers, reuse, simplification, efficiency, altitude (root cause vs. patch) and project conventions. Duplicates merged; findings ranked by severity. |
| Human step | Every finding was checked against the code and the Lab 2 rules before deciding. A decision is **Fix**, **Won't fix** (the finding is wrong or conflicts with a rule) or **Defer** (real, but out of scope for this lab). |

The review found **12 findings in 4 kinds** (correctness 7, efficiency 2, altitude 1, reuse 2).
**10 were fixed** in 8 commits, **1 deferred**, and **1 rejected** because it conflicts with the Lab 2 rule.

## Findings

| ID | Kind | Where | Finding | Decision | Reason | Fix commit |
|---|---|---|---|---|---|---|
| CR-01 | correctness | `viewmodels/team_detail_viewmodel.dart:78` | On "team full", `join()` refetched the team outside any `try`. Offline, the refetch threw out of `join()`; the overlay closed with no message. | **Fix** | Real error path of Flow 1's alternative path. The refetch now has its own `try` and ends as `JoinFailed` with the offline message. | `d2cd210` |
| CR-02 | correctness | `services/local/local_team_repository.dart:138` | The leader is not re-checked when the team grows: Minh, elected with 2 of 3 votes, stays leader at 4 members (2 of 4 is not a majority) and can lock. | **Won't fix** | Lab 2 Flow 2 elects the leader by majority *at the time of the vote*; a later join does not start a new election. Re-electing on every join would block Flow 3 (the pool member who unblocks the lock would also remove the leader). Votes can still change until the roster is locked, and a changed vote re-runs the majority check. | — |
| CR-03 | correctness | `viewmodels/notifications_viewmodel.dart:69` | `open`, `markAllRead`, `decline`, `restore` had no error handling. With Firestore offline, Decline threw past the screen and Undo never appeared. | **Fix** | Same failure handling as the rest of the app: each write returns an `AppFailure` that the screen shows; Undo is offered only when the decline worked. | `e5fc83a` |
| CR-04 | correctness | `services/local/local_team_repository.dart:179` | The pool student was removed from the pool *before* the delayed join. If the team filled or locked first, the join was skipped and the student was lost. | **Fix** | The student now leaves the pool only when they actually join, and a second invite in the meantime cannot add them twice. | `982af18` |
| CR-05 | correctness | `services/local/local_team_repository.dart:82` | Join, leave, vote, lock and invite used `teams[id]!`. A deleted team gave a null-check crash, reported as "Something went wrong". | **Fix** | One `_team(id)` lookup shared with `getTeam`, so every operation fails with "This team no longer exists". | `982af18` |
| CR-06 | correctness | `viewmodels/dashboard_viewmodel.dart:79` | Home kept the time of its last load: the countdown never moved, Urgent never appeared under 48 h, and the closed state never appeared at the deadline. | **Fix** | A 30-second tick updates the time; `registrationClosed` is derived from it plus the Remote Config flag. | `ab2ac3a` |
| CR-07 | correctness | `viewmodels/profile_viewmodel.dart:97` | If the upload stream ended without a download URL, the export stayed "Uploading" and the button stayed locked. | **Fix** | An upload that ends without a URL becomes "Upload didn't finish" with a retry. Matters for the Firebase Storage implementation, where uploads can be cancelled. | `64b485a` |
| CR-08 | efficiency | `services/local/local_database.dart:69` | Every repository call does its own DNS lookup (up to 4 s) to detect offline. | **Defer** | Real cost, but only in the local development implementation, which the Firebase implementation replaces (Firestore has its own offline cache). | — |
| CR-09 | efficiency | `main.dart:15` | `ensureSemantics()` ran in release builds too, building the semantics tree every frame without an accessibility service. | **Fix** | On only in debug and profile builds, or with `--dart-define=E2E_SEMANTICS=true` for E2E release builds. | `f1ec63f` |
| CR-10 | altitude | `screens/browse/browse_screen.dart:135` | Browse re-ran its search only when Team Detail was popped, a patch for one path. Joins from Alerts, pool members or tab switches left stale slot counts. | **Fix** | Root cause fixed: `TeamRepository.teamsChanged()` (a Firestore snapshot listener later), and `BrowseViewModel` refreshes in place without a spinner. The screen patch is removed. | `982af18`, `22f69f4` |
| CR-11 | reuse | `screens/team_detail/team_detail_screen.dart:76` (and 5 more) | The failure snackbar was copied into 6 handlers and the "You're not in a team yet" empty state into 3 screens. | **Fix** | `showFailure()` and `NoTeamState` in `screens/shared/feedback.dart`, so a copy change is made once (UI consistency checklist). | `c135916` |
| CR-12 | reuse | `screens/pool/random_pool_screen.dart:140` | `_Row` (Random Pool) and `_InfoRow` (Team Detail) were the same key-value row with different layouts. | **Fix** | One `InfoRow` in the design system (`widgets/status.dart`). | `c135916` |

## Verification

- `flutter analyze`: no issues after the fixes.
- The fixed app was rebuilt and the E2E suite was run again against it; see [test-plan.md](test-plan.md#results).
- CR-01, CR-03 and CR-07 cover failure paths that the seeded local data cannot trigger on demand. They were checked by reading the code paths and are covered once the Firebase implementation can fail.

## What the AI got right, and where a human was needed

- The AI found real failure paths that manual testing on a good network missed (CR-01, CR-03, CR-07) and a time bug that only shows when a screen stays open (CR-06).
- CR-10 is the most useful kind of finding: it named the patch added during testing and pointed to the root cause.
- CR-02 shows why a human decides: the code does what the AI described, but the behaviour follows the Lab 2 voting rule. Changing it would have broken Flow 3.
- CR-08 is correct, but its cost sits in code that is meant to be replaced, so fixing it now would be wasted work.
