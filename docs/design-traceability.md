# Design traceability: Lab 2 → Flutter

**Source of truth:**
- Team Figma file **PRM_LAB2** (https://www.figma.com/design/Z42q9LamOZojK54FSBDcCd/PRM_LAB2), page *03 Final UI*.
- `design/DESIGN.md`, `design/screen-spec.md`, `ux/user-flow.md` and `handoff/flutter-handoff.md` in the Lab 2 repo (DEVORGANIZE222/PRM393_LAB2_uiuxdesign).

**Status values:** `done` = built and checked on the emulator at 360 and 412 dp; `planned` = not built yet; `needs Firebase` = the UI is built and the Firebase implementation is pending.

## 1. Screens

| Lab 2 screen | Figma frame | Flutter route | Screen widget | ViewModel | Data source | States implemented | Status |
|---|---|---|---|---|---|---|---|
| SCR_01 Sign In | `SCR_01: Sign In (FPT SSO)` | `/sign-in` | `SignInScreen` | `SignInViewModel` | `AuthService` | default · signing in · cancelled · wrong domain | planned |
| SCR_02 Dashboard | `SCR_02: Dashboard / Home` | `/home` (tab 1) | `DashboardScreen` | `DashboardViewModel` | `TeamRepository`, `RegistrationService` | loading · in a team · not in a team · registration closed · error | planned |
| SCR_03 Browse | `SCR_03: Browse Groups` | `/browse` (tab 2) | `BrowseScreen` | `BrowseViewModel` | `TeamRepository` | loading · results · empty · error | planned |
| SCR_04 Team Detail | `SCR_04: Group Detail` + `SRC4 Diaglog` | `/browse/team/:teamId` | `TeamDetailScreen` + `JoinTeamDialog` | `TeamDetailViewModel` | `TeamRepository` | loading · default · joining · team full · error | planned |
| SCR_05 My Team | `SCR_05: My Group Hub`, `SCR_05 (Leader View - Ready to Lock)` | `/team` (tab 3) | `MyTeamScreen` | `MyTeamViewModel` | `TeamRepository` | loading · no team · in formation · leader view · locked · error | planned |
| SCR_06 Leader Voting | `SCR_06: Leader Voting` | `/team/vote` | `LeaderVotingScreen` | `VotingViewModel` | `TeamRepository` | loading · nothing selected · selected · submitting · submitted · change-vote dialog · error | planned |
| SCR_07 Lock Review | `SCR_07: Group Lock Review & Error Recovery` | `/team/lock` | `LockReviewScreen` | `LockReviewViewModel` | `TeamRepository`, `PoolRepository` | loading · ready · blocked (< 4) · invites sent · confirm dialog · locking · locked · error | planned |
| SCR_08 Random Pool | `SCR_08: Random Pool Status` | `/home/pool` | `RandomPoolScreen` | `PoolStatusViewModel` | `PoolRepository` | loading · matching · refreshing · error | planned |
| SCR_09 Alerts | `SCR_09: Notifications & Invites` | `/alerts` (tab 4) | `NotificationsScreen` | `NotificationsViewModel` | `NotificationRepository` | loading · list · filtered · empty · error · decline-undo | planned |
| *(added)* Profile | — (handout §3: add if not designed) | `/profile` | `ProfileScreen` | `ProfileViewModel` | `AuthService`, `ReportService`, `StorageService`, `ConfigService`, `CrashReporter` | account · export/upload progress · uploaded (URL) · Remote Config values · Crashlytics demo · sign-out | planned |

## 2. Flows

| Lab 2 flow | Routes in order | Alternative / error path in the app | Status |
|---|---|---|---|
| Flow 1 · Discover & join | `/home` → `/browse` → `/browse/team/:id` → join dialog → `/team` | Team filled before confirming: the error message names the team and offers "Back to Browse", which returns to a refreshed list. No search results: empty state with "Clear filters". | planned |
| Flow 2 · Leader voting | `/team` → `/team/vote` → submit → `/team` | Change vote: confirmation dialog. Load error: retry. | planned |
| Flow 3 · Lock roster | `/team` (leader) → `/team/lock` → destructive dialog → locked | Fewer than 4 members: lock blocked with the reason. Recovery: "Invite from Waiting Pool", and lock unblocks when a student accepts. | planned |

## 3. Components

| Lab 2 component | Variants / states | Widget (`lib/widgets/`) |
|---|---|---|
| Button | primary · secondary · destructive · text × default · pressed · disabled · loading | `AppButton` |
| Text field | default · focused · filled · error · disabled | `AppTextField` (+ `AppSearchField`) |
| Card | default · pressed · selected | `AppCard`, `SelectableCard` |
| Bottom navigation | 4 destinations, one selected | `AppNavigationShell` |
| App bar | default · with back · with actions | `AppTopBar` |
| Dialog | confirmation · destructive | `showAppDialog()` |
| Loading | skeleton list · spinner · blocking overlay | `LoadingState`, `SkeletonList`, `BlockingOverlay` |
| Empty state | icon + message + one action | `EmptyState` |
| Error state | message + cause in plain language + retry | `ErrorState` |
| Badge / chip / banner / avatar / progress | tone variants | `StatusBadge`, `AppChip`, `InfoBanner`, `MemberAvatar`, `SlotRow`, `AppProgressBar` |

## 4. Deviations from the Figma file (with reasons)

The changes come from building the design against the two principle sets the team adopted for Lab 3:
- **UX Writing Best Practices Checklist** (Bobbie Wood: content heuristics).
- **UI Consistency Checklist** (identityforge.io).

Each change still has to be mirrored in the Figma file by a teammate with edit access.

| # | Figma | App | Reason (principle) |
|---|---|---|---|
| DV-01 | The same concept is called *Group* and *Team* ("My Group Hub", "Leave Group", "Team AI-04", "Request to Join Team") | **Team** everywhere: tab "My Team", "Leave Team", "Team Detail" | Consistency checklist: *each concept has one name throughout*. UX writing: *Consistent terminology*. |
| DV-02 | Button and heading case is mixed ("View Details & Join", "Submit Vote", "Cancel and return to hub") | Title Case for buttons, tabs and screen titles; sentence case for body, helper and error text | Consistency: *capitalisation follows one rule*. |
| DV-03 | Some primary buttons and the join dialog end with an arrow "→" while others don't | No arrows inside button labels; navigation is shown by the screen change | Consistency: *primary actions look the same*. |
| DV-04 | The join dialog sends a *request* to the leader ("Send Join Request?", "Confirm & Send Request") | The dialog says **"Join Team AI-04?"** and the confirm button reads **"Join Team"** | The Lab 2 Flow 1 spec joins directly after a real-time capacity check. A leader-approval step would add a waiting state that no flow covers. UX writing: *buttons name their action, confirmations echo it*. |
| DV-05 | Error copy such as "Ineligible to Lock Roster" puts the cause last | "Can't lock yet: 3 of 5 members" first, then the rule and what to do | UX writing, error messages: *actionable* and *front-loaded*. |
| DV-06 | Notification titles start with the actor ("FinTech Guard invited you to join their team as …") | The key words come first ("Invite: FinTech Guard · Mobile & Frontend") and the full sentence goes underneath | UX writing, notifications: *front-loaded* (still clear if truncated). |
| DV-07 | Decorative step badges ("Step 01/02/03") and extra copy on Sign In | Kept, but the copy is shortened to ≤ 2 lines per step | UX writing: *concise*, *readable* (about a sixth-grade level). |
| DV-08 | Dashboard and Team Detail show a bell, avatar and settings in the app bar | Avatar opens **Profile** (added screen); the bell opens the Alerts tab | Handout §3 (Profile screen required); consistency: one entry per destination. |

*(This table grows while building; the final version lists every difference.)*
