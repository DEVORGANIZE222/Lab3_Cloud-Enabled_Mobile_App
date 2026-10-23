# Design Traceability Matrix — EXEMatching (PRM393 Lab 3)

## 1. Overview
This document maps every screen, component, and user flow from **Lab 2 (Figma & Specification)** into concrete Flutter routes, widgets, state models, and backend data sources in **Lab 3**.

* **Figma File:** `https://www.figma.com/design/Z42q9LamOZojK54FSBDcCd/PRM_LAB2?node-id=1-6`
* **Target Platforms:** Android Device / Emulator (Screen widths 360dp & 412dp)
* **Backend Data Source:** Cloud Firestore & Firebase Cloud Storage

---

## 2. Screen-to-Code Traceability Table

| Screen ID | Lab 2 Screen Name | Flutter Route | Flutter Screen Widget | ViewModel | Firestore Data Source / SDK | Status |
|---|---|---|---|---|---|---|
| `SCR_01` | Sign In (FPT SSO) | `/sign-in` | `SignInScreen` | `AuthViewModel` | Firebase Auth (Google Sign-In) | Implemented |
| `SCR_02` | Dashboard / Home | `/dashboard` | `DashboardScreen` | `DashboardViewModel` | `teams`, `users`, Remote Config | Implemented |
| `SCR_03` | Browse Groups | `/browse-groups` | `BrowseGroupsScreen` | `GroupListViewModel` | `teams` collection (queries & filters) | Implemented |
| `SCR_04` | Group Detail | `/group-detail` | `GroupDetailScreen` | `GroupDetailViewModel` | `teams/{id}`, `members` | Implemented |
| `SCR_05` | My Group Hub | `/my-group` | `MyGroupScreen` | `MyGroupViewModel` | `teams/{myTeamId}`, `votes` | Implemented |
| `SCR_06` | Leader Voting | `/leader-voting` | `LeaderVotingScreen` | `VotingViewModel` | `teams/{id}/votes` collection | Implemented |
| `SCR_07` | Group Lock & Recovery | `/lock-review` | `LockReviewScreen` | `LockReviewViewModel` | `teams/{id}` (update status to LOCKED) | Implemented |
| `SCR_08` | Random Pool Status | `/random-pool` | `RandomPoolScreen` | `RandomPoolViewModel` | `waiting_pool` collection | Implemented |
| `SCR_09` | Notifications & Invites | `/notifications` | `NotificationsScreen` | `NotificationViewModel`| `users/{uid}/notifications`, FCM | Implemented |
| `SCR_10` | Profile & Firebase Demo | `/profile` | `ProfileScreen` | `ProfileViewModel` | Firebase Storage, Crashlytics, Remote Config | Implemented |

---

## 3. User Flows Traceability

### Flow 1: Discover & Join an Open Capstone Group
- **Starting Point:** `SCR_02` (Dashboard) $\rightarrow$ Tap "Browse Groups".
- **Steps:**
  1. `SCR_03`: User searches for tag or keyword; debounced stream query sent to `GroupListViewModel`.
  2. User selects a group card $\rightarrow$ Navigates to `SCR_04` (`/group-detail`).
  3. `SCR_04`: User reviews roster (e.g. 3/5 members) and taps "Request to Join Team".
  4. Confirmation dialog appears $\rightarrow$ User taps "Confirm".
  5. **Happy Path:** Slot available $\rightarrow$ Joins team, updates state, navigates to `SCR_05` (`/my-group`).
  6. **Alternative Path:** Slot already filled ($5/5$) $\rightarrow$ Shows error toast, refreshes group status, keeps user on `SCR_03`.

### Flow 2: Team Leader Democratic Voting
- **Starting Point:** `SCR_05` (My Group Hub) $\rightarrow$ Banner shows "Leader Election Open".
- **Steps:**
  1. User taps "Vote for Leader" banner $\rightarrow$ Navigates to `SCR_06` (`/leader-voting`).
  2. `SCR_06`: Displays candidate cards with radio selection.
  3. User picks candidate $\rightarrow$ Taps "Submit My Vote".
  4. Vote recorded in `teams/{id}/votes/{uid}`.
  5. Realtime vote tally updates. When candidate reaches threshold $\ge 3$ votes $\rightarrow$ role designated as `LEADER`.
  6. Returns to `SCR_05` with Leader badge displayed.

### Flow 3: Group Roster Lock & Error Recovery
- **Starting Point:** `SCR_05` (My Group Hub, as elected Leader) $\rightarrow$ Tap "Proceed to Lock Team".
- **Steps:**
  1. Navigates to `SCR_07` (`/lock-review`).
  2. `LockReviewViewModel` checks member count:
     - **Happy Path (4 or 5 members):** "Lock Team Roster" button is active. Tapping displays destructive confirmation dialog. Confirming sets `isLocked = true`, disables roster edits, generates team confirmation code, and enables "Export Official Roster PDF".
     - **Error Path (< 4 members):** Button is disabled. High-contrast error banner appears: *"Chỉ có {count}/5 thành viên. Quy chế Capstone yêu cầu tối thiểu 4 thành viên."*
     - **Recovery Action:** Recovery card displays "Open Group to Public / Invite from Pool". Tapping broadcasts open slots to Random Pool or invites waiting candidates. Once accepted, member count updates to $\ge 4$ and Lock button unlocks.

---

## 4. Design System Component Mapping

| Lab 2 Component | Flutter Widget (`lib/widgets/`) | States Supported | Accessibility Guarantee |
|---|---|---|---|
| Primary Button | `AppPrimaryButton` / `FilledButton` | Default, Loading, Disabled | Min touch target $\ge 48\text{dp}$, `Semantics` label |
| Secondary Button | `OutlinedButton` | Default, Pressed | Min touch target $\ge 48\text{dp}$, contrast $\ge 4.5:1$ |
| Destructive Button | `FilledButton(style: error)` | Default, Pressed | High contrast error red `#BA1A1A` |
| Text Input | `TextFormField` | Default, Focused, Error | Clear label, helper text, min height 48dp |
| Status Card | `AppStatusCard` | In Formation, Ready to Lock, Locked | Explicit text + color indicators |
| State Views | `AppLoadingView`, `AppEmptyView`, `AppErrorView` | Loading spinner, Empty illustration, Error with Retry | Clear recovery CTA on every error state |

---

## 5. Recorded Deviations from Lab 2 Design

| Deviation ID | Screen / Component | Original Lab 2 Specification | Actual Implementation in Lab 3 | Rationale & Justification |
|---|---|---|---|---|
| `DEV-01` | `SCR_10` Profile Screen | Lab 2 did not define a standalone Profile screen (profile was a dropdown avatar in `SCR_02`). | Added `SCR_10` (`ProfileScreen`) in bottom navigation / app bar. | **Lab 3 Section 3 Requirement:** App must provide a dedicated Firebase demo area (Notification center, Storage upload progress, Remote Config display, Crashlytics trigger buttons). |
| `DEV-02` | `SCR_01` Google Sign-In | Figma prototype simulated FPT FeId webview. | Integrated Google OAuth (`google_sign_in` SDK) with `@fpt.edu.vn` domain verification. | Adheres to Firebase Authentication requirements and native Android account picker standards. |
