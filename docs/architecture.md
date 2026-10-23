# Architecture Documentation — EXEMatching (PRM393 Lab 3)

## 1. Folder Structure Overview

```text
lib/
├── models/       # Immutable data models and state containers (shared across layers)
├── services/     # Business logic abstractions and Firebase SDK wrappers
├── firebase/     # Low-level Firebase initializations and options configuration
├── viewmodels/   # MVVM ChangeNotifier ViewModels managing UI states and user intents
├── screens/      # Pure presentation screens (observe ViewModels, forward user events)
├── widgets/      # Reusable design system components, state views (Loading/Empty/Error)
├── theme/        # Centralized design tokens (ColorScheme, TextTheme, AppSpacing, AppRadius)
└── utils/        # Helper utilities (PDF generation, date-time formatters)
```

---

## 2. Layer Diagram (Mermaid)

Dependencies strictly flow downwards. A layer never imports from or depends on the layer above it.

```mermaid
graph TD
    subgraph ViewLayer["Presentation Layer (View)"]
        Screens["Screens (screens/)"]
        Widgets["Reusable Widgets (widgets/)"]
    end

    subgraph ViewModelLayer["ViewModel Layer (State & Logic)"]
        VM["ViewModels (viewmodels/ with Provider)"]
        ViewState["Explicit State Models (Loading / Empty / Error / Data)"]
    end

    subgraph ServiceLayer["Service & Repository Layer (Domain/Data)"]
        Services["Services (services/ & firebase/)"]
    end

    subgraph ExternalLayer["External Infrastructure"]
        Firestore[("Cloud Firestore")]
        FirebaseAuth["Firebase Auth"]
        Storage["Cloud Storage"]
        RemoteConfig["Firebase Remote Config"]
        Analytics["Firebase Analytics"]
        Crashlytics["Firebase Crashlytics"]
    end

    subgraph ModelLayer["Shared Models"]
        DataModels["Plain Data Models (models/)"]
    end

    Screens -->|Dispatches Events / Listens to State| VM
    Widgets -->|Reads Theme & Callbacks| Screens
    VM -->|Calls Async Methods| Services
    VM -->|Emits State| ViewState
    Services -->|Serializes / Deserializes| DataModels
    Services -->|I/O Operations| Firestore
    Services -->|Auth State| FirebaseAuth
    Services -->|Upload Files| Storage
    Services -->|Fetch Flags| RemoteConfig
    Services -->|Log Events| Analytics
    Services -->|Record Errors| Crashlytics
    VM -.->|Reads| DataModels
    Screens -.->|Renders| DataModels
```

---

## 3. Sequence Diagram (Flow 1: Search & Browse Groups)

```mermaid
sequenceDiagram
    autonumber
    actor User as Student
    participant View as BrowseGroupsScreen
    participant VM as GroupListViewModel
    participant Service as GroupService
    participant Analytics as AnalyticsService
    participant Firestore as Cloud Firestore

    User->>View: Enters keyword "AI" in search input
    View->>VM: onSearchQueryChanged("AI")
    Note over VM: Debounce 300ms
    VM->>VM: emit(LoadingState)
    VM->>Analytics: logSearchEvent(searchTerm: "AI")
    Analytics-->>VM: event logged
    VM->>Service: searchTeams(query: "AI")
    Service->>Firestore: collection("teams").where("tags", arrayContains: "AI").get()
    alt Data returned (count > 0)
        Firestore-->>Service: QuerySnapshot (List of Team documents)
        Service-->>VM: List<TeamModel>
        VM->>VM: emit(SuccessState(teams))
        VM-->>View: notifyListeners()
        View-->>User: Renders Group Cards with open slots
    else No teams match keyword
        Firestore-->>Service: QuerySnapshot (empty)
        Service-->>VM: []
        VM->>VM: emit(EmptyState("Không tìm thấy nhóm phù hợp"))
        VM-->>View: notifyListeners()
        View-->>User: Displays AppEmptyView with "Reset Filters" action
    else Network failure
        Firestore-->>Service: FirebaseException / NetworkError
        Service-->>VM: throws AppException
        VM->>VM: emit(ErrorState("Lỗi kết nối", onRetry))
        VM-->>View: notifyListeners()
        View-->>User: Displays AppErrorView with Retry button
    end
```

---

## 4. ViewModel to Services Dependency Table

Every ViewModel receives its required services via Dependency Injection (Provider). ViewModels never construct singleton instances of services directly, making them 100% unit-testable with mock/fake services.

| ViewModel Name | File Location | Services Injected & Used | Responsibilities |
|---|---|---|---|
| `AuthViewModel` | `lib/viewmodels/auth_viewmodel.dart` | `FirebaseAuthService`, `AnalyticsService` | Manages login state, Google SSO authentication, domain validation (`@fpt.edu.vn`), and sign-out. |
| `DashboardViewModel` | `lib/viewmodels/dashboard_viewmodel.dart` | `GroupService`, `RemoteConfigService` | Loads student's current capstone status, urgent deadline countdowns, and quick actions. |
| `GroupListViewModel` | `lib/viewmodels/group_list_viewmodel.dart` | `GroupService`, `AnalyticsService`, `RemoteConfigService` | Manages group search query, tag filtering, debouncing, and pagination. |
| `GroupDetailViewModel` | `lib/viewmodels/group_detail_viewmodel.dart` | `GroupService`, `AnalyticsService` | Displays roster, validates open slots ($< 5$), and handles join requests. |
| `MyGroupViewModel` | `lib/viewmodels/my_group_viewmodel.dart` | `GroupService`, `VotingService` | Loads user's active group details, member roles, and current election status. |
| `VotingViewModel` | `lib/viewmodels/voting_viewmodel.dart` | `VotingService`, `AnalyticsService` | Manages leader candidate selection, records votes, and listens to real-time vote tallies. |
| `LockReviewViewModel` | `lib/viewmodels/lock_review_viewmodel.dart` | `GroupService`, `StorageService`, `AnalyticsService` | Validates team quota ($\ge 4$ members), performs lock confirmation, triggers random pool recruitment on error path, and generates PDF. |
| `NotificationViewModel` | `lib/viewmodels/notification_viewmodel.dart` | `NotificationService` | Subscribes to FCM pushes, displays notification list, and routes on tap. |
| `ProfileViewModel` | `lib/viewmodels/profile_viewmodel.dart` | `FirebaseAuthService`, `StorageService`, `RemoteConfigService`, `CrashlyticsService` | Firebase demonstration hub: upload test file, trigger handled error/crash, reload Remote Config. |

---

## 5. Architectural Quality Checklist (Grading Rules Enforced)
- [x] **No SDK Direct Call:** No UI widget calls `http`, `FirebaseAuth.instance`, `FirebaseFirestore.instance`, or `FirebaseAnalytics.instance`.
- [x] **Zero Business Logic in UI:** All aggregation, filtering, quota validation, and string mutations reside in ViewModels or Services.
- [x] **Explicit ViewState:** Every screen loading asynchronous data observes a sealed `ViewState` (`InitialState`, `LoadingState`, `EmptyState`, `ErrorState`, `SuccessState`).
- [x] **Service Injection:** ViewModels receive interfaces via Provider, enabling isolated unit testing.
