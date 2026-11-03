import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

void main() async {
  final pdf = pw.Document(
    title: 'PRM393 Lab 3 Presentation Slides - EXEMatching',
    author: 'DEVORGANIZE222',
  );

  final primary = PdfColor.fromHex('#1E3A8A'); // Navy
  final accent = PdfColor.fromHex('#0D9488');  // Teal
  final bgLight = PdfColor.fromHex('#F8FAFC');
  final borderCol = PdfColor.fromHex('#E2E8F0');
  final textDark = PdfColor.fromHex('#0F172A');
  final textMuted = PdfColor.fromHex('#64748B');

  pw.PageTheme slideTheme() {
    return pw.PageTheme(
      pageFormat: PdfPageFormat.a4.landscape,
      margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 30),
      theme: pw.ThemeData.withFont(
        base: pw.Font.helvetica(),
        bold: pw.Font.helveticaBold(),
        italic: pw.Font.helveticaOblique(),
      ),
    );
  }

  pw.Widget buildSlideHeader(String title, String category, int slideNum) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 14),
      padding: const pw.EdgeInsets.only(bottom: 8),
      decoration: pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: accent, width: 2)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(category.toUpperCase(), style: pw.TextStyle(color: accent, fontSize: 8, fontWeight: pw.FontWeight.bold)),
              pw.Text(title, style: pw.TextStyle(color: primary, fontSize: 16, fontWeight: pw.FontWeight.bold)),
            ],
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: pw.BoxDecoration(color: primary, borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4))),
            child: pw.Text('SLIDE $slideNum / 15', style: pw.TextStyle(color: PdfColors.white, fontSize: 8, fontWeight: pw.FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  pw.Widget buildCard(String title, List<String> bullets, {PdfColor? color}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: bgLight,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        border: pw.Border.all(color: color ?? borderCol, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: pw.TextStyle(color: color ?? primary, fontSize: 10, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          ...bullets.map((b) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 4),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('• ', style: pw.TextStyle(color: accent, fontSize: 9, fontWeight: pw.FontWeight.bold)),
                pw.Expanded(child: pw.Text(b, style: pw.TextStyle(color: textDark, fontSize: 8.5))),
              ],
            ),
          )),
        ],
      ),
    );
  }

  // ==================== SLIDE 1: TITLE SLIDE ====================
  pdf.addPage(
    pw.Page(
      pageTheme: slideTheme(),
      build: (context) => pw.Container(
        padding: const pw.EdgeInsets.all(24),
        decoration: pw.BoxDecoration(
          color: primary,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        ),
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('PRM393 — MOBILE PROGRAMMING · LAB 3', style: pw.TextStyle(color: PdfColor.fromHex('#93C5FD'), fontSize: 11, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 12),
            pw.Text('EXEMatching: Cloud-Enabled Mobile App', style: pw.TextStyle(color: PdfColors.white, fontSize: 26, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 6),
            pw.Text('Firebase Cloud Backend · Google ARTEMIS Automated Testing · AI-Assisted Code Review', style: pw.TextStyle(color: PdfColors.white, fontSize: 12)),
            pw.SizedBox(height: 20),
            pw.Container(height: 1, color: accent),
            pw.SizedBox(height: 16),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  pw.Text('DEVELOPMENT TEAM: DEVORGANIZE222', style: pw.TextStyle(color: PdfColors.white, fontSize: 9, fontWeight: pw.FontWeight.bold)),
                  pw.Text('Platform: Flutter (Android API 36 / Pixel API 36)', style: pw.TextStyle(color: PdfColor.fromHex('#CBD5E1'), fontSize: 8)),
                ]),
                pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
                  pw.Text('Firebase ID: prm393-lab-3-exematching', style: pw.TextStyle(color: PdfColors.white, fontSize: 9, fontWeight: pw.FontWeight.bold)),
                  pw.Text('Package: com.devorganize222.exematching', style: pw.TextStyle(color: PdfColor.fromHex('#CBD5E1'), fontSize: 8)),
                ]),
              ],
            ),
          ],
        ),
      ),
    ),
  );

  // ==================== SLIDE 2: TOPIC, PERSONA & FLOWS ====================
  pdf.addPage(
    pw.Page(
      pageTheme: slideTheme(),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          buildSlideHeader('Topic, Persona & Three Critical User Flows', 'Lab 2 Design Recap', 2),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: buildCard('TARGET PERSONA & SUCCESS CRITERION', [
                  'Persona: Minh Le — senior Software Engineering student facing capstone registration deadline.',
                  'Problem: Difficulty finding matching teammates, coordinating leader election, and recovering if a member drops.',
                  'Success Criterion: Fast team discovery, confidential leader election, and seamless recovery via Waiting Pool to lock roster before deadline.',
                ]),
              ),
              pw.SizedBox(width: 14),
              pw.Expanded(
                child: buildCard('THREE CRITICAL FLOWS IMPLEMENTED', [
                  'Flow 1 (Discover & Join): Search with skill chips -> View details -> Join open role -> Concurrency check.',
                  'Flow 2 (Leader Voting): Confidential voting -> Real-time tally reveal upon majority -> Confirmation dialog.',
                  'Flow 3 (Roster Finalization): Leader validates criteria (4-5 members) -> Recovers via Waiting Pool -> Locks team.',
                ]),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  // ==================== SLIDE 3: SCREENS & SYSTEMATIC DEVIATIONS ====================
  pdf.addPage(
    pw.Page(
      pageTheme: slideTheme(),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          buildSlideHeader('Screen Implementation & UX Deviations', 'Design Traceability', 3),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: buildCard('10 PRODUCTION SCREENS BUILT', [
                  'SCR_01 Sign In: Google SSO with allowed roster check.',
                  'SCR_02 Dashboard: Active team status & countdown banner.',
                  'SCR_03 Browse: Debounced search, skill chips, empty state.',
                  'SCR_04 Team Detail: Role selection & atomic join modal.',
                  'SCR_05 My Team: Roster management & dynamic action button.',
                  'SCR_06 Leader Voting: Hidden tallies & majority election.',
                  'SCR_07 Lock Review: Capacity check & Waiting Pool recovery.',
                  'SCR_08 Random Pool: Queue status & estimated match time.',
                  'SCR_09 Alerts: Inbox with Decline + Undo support.',
                  'Profile Screen: Firebase Demo Area & Cloud Export.',
                ]),
              ),
              pw.SizedBox(width: 14),
              pw.Expanded(
                child: buildCard('KEY HEURISTIC DEVIATIONS (docs/design-traceability.md)', [
                  'DV-01: Unified "Group" and "Team" to "Team" everywhere (UI Consistency Heuristic).',
                  'DV-04: Replaced unhandled join "request" with direct open-slot join validated by backend transaction.',
                  'DV-05: Front-loaded error messages ("Can\'t lock yet: needs 1 more member" instead of vague technical codes).',
                  'DV-08: Added Profile screen as single destination for user profile and Firebase verification actions.',
                  'DV-09/10: Elevated contrast to exceed WCAG AA standards (buttons >=48dp, text >=14sp, colors >=4.5:1).',
                ]),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  // ==================== SLIDE 4: ARCHITECTURE & MVVM ====================
  pdf.addPage(
    pw.Page(
      pageTheme: slideTheme(),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          buildSlideHeader('MVVM Architecture & Layer Separation', 'Clean Architecture', 4),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: buildCard('STRICT DOWNWARD DEPENDENCIES', [
                  'View Layer (lib/screens/ & lib/widgets/): Pure declarative widgets, zero SDK calls, zero business logic.',
                  'ViewModel Layer (lib/viewmodels/): ChangeNotifier owning ViewState<T>, validation rules, and analytics triggers.',
                  'Service Layer (lib/services/): Abstract interfaces defining cloud and data contracts.',
                  'Data/Cloud Layer (lib/firebase/): Concrete Firebase SDK implementations encapsulated entirely.',
                  'Composition Root (lib/app/providers.dart): Single file injecting singletons into ViewModels via Provider.',
                ]),
              ),
              pw.SizedBox(width: 14),
              pw.Expanded(
                child: buildCard('EXPLICIT STATE MODELING (ViewState<T>)', [
                  'Loading: Renders skeleton list or non-blocking spinner.',
                  'Empty: Renders informative illustration, clear message, and single recovery action (e.g. "Clear Filters").',
                  'Failure: Contains AppFailure with title, cause, and retryable flag -> shows retry button (never crashes).',
                  'Data: Renders populated domain models.',
                  'Unit-Testable: ViewModels can be tested with fake service implementations without running emulator.',
                ]),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  // ==================== SLIDE 5: DESIGN SYSTEM IN CODE ====================
  pdf.addPage(
    pw.Page(
      pageTheme: slideTheme(),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          buildSlideHeader('Design System in Code & Reusable Widget Library', 'Design Tokens & UI Kit', 5),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: buildCard('CENTRALIZED DESIGN TOKENS (lib/theme/)', [
                  'ColorScheme: Material 3 scheme with custom FPT brand tokens (Primary #0284C7, Success #15803D, Warning #B4530A).',
                  'TextTheme: Strict typography hierarchy using Roboto (system font on Android API 36).',
                  'AppSpacing: Named constants xs (4), sm (8), md (16), lg (24), xl (32).',
                  'AppRadius: Named corner radiuses sm (4), md (8), lg (12), pill (999).',
                  'AppElevation: Low elevation tokens for modern flat design.',
                ]),
              ),
              pw.SizedBox(width: 14),
              pw.Expanded(
                child: buildCard('REUSABLE COMPONENT LIBRARY (lib/widgets/)', [
                  'AppButton: Primary, secondary, destructive, text with loading overlay and 48dp minimum touch target.',
                  'AppTextField: Styled search and form inputs with focused borders and clear actions.',
                  'AppCard: Standard elevated card and SelectableCard with radio check indicator.',
                  'Status Indicators: StatusBadge, InfoBanner, SlotRow, AppProgressBar (icon + label, never color alone).',
                  'AppNavigationShell: Custom bottom navigation with real-time unread notification badge.',
                ]),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  // ==================== SLIDE 6: FIREBASE AUTH & ROSTER SECURITY ====================
  pdf.addPage(
    pw.Page(
      pageTheme: slideTheme(),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          buildSlideHeader('Firebase Authentication & Roster Authorization', 'Cloud Service 01', 6),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: buildCard('AUTHENTICATION IMPLEMENTATION', [
                  'Google Sign-In: Native Google credential sign-in via FirebaseAuth.instance.signInWithCredential().',
                  'Session Stream: Directly subscribes to authStateChanges() for immediate login/logout state routing.',
                  'Sign-Out Cleanup: Explicitly signs out of both Google and Firebase, purging user memory cache.',
                  'Cancellation & Offline: User cancellation or network drop emits clean AppFailure with user guidance.',
                ]),
              ),
              pw.SizedBox(width: 14),
              pw.Expanded(
                child: buildCard('CENTRALIZED ROSTER ALLOWLIST (K19+ SOLUTION)', [
                  'Problem: FPT students from K19+ use non-standard email domains, requiring flexible yet secure roster validation.',
                  'Solution: Firestore collection allowedEmails/{email} stores authorized class roster with enabled: true.',
                  'Two-Tier Check: Client-side _studentFor() verifies email against roster; Security Rules enforce isRosterMember().',
                  'Unauthorized Denial: Non-roster Google accounts are immediately rejected with "This is not an FPT account" (TC-01).',
                ]),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  // ==================== SLIDE 7: CLOUD FIRESTORE & CONCURRENCY ====================
  pdf.addPage(
    pw.Page(
      pageTheme: slideTheme(),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          buildSlideHeader('Cloud Firestore Transactions & Security Rules', 'Cloud Service 02', 7),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: buildCard('CONCURRENT TRANSACTIONS (firestore_team_repository.dart)', [
                  'Atomic Roster Mutations: Join, leave, vote, lock, and pool-invite run in runTransaction.',
                  'Double-Join Prevention: Validates memberIds before committing; concurrent joins safely abort and retry.',
                  'Leader Election: Tallies remain hidden in UI until member votes; election declares winner at majority (>50%).',
                  'Waiting Pool Recovery: Atomic assignment of candidate from waitingPool to team in a single transaction.',
                ]),
              ),
              pw.SizedBox(width: 14),
              pw.Expanded(
                child: buildCard('FIRESTORE SECURITY RULES (firebase/firestore.rules)', [
                  'Roster Gating: All queries require isRosterMember() (email in allowedEmails).',
                  'Whitelist Update Fields (GR-01 Fix): Students can ONLY modify 8 roster fields (members, votes, leaderId, lockCode).',
                  'Immutability: Team metadata (supervisor, capacity, topic) cannot be tampered with by clients.',
                  'User Isolation: students/{uid} and notifications readable/writable exclusively by resource owner.',
                ]),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  // ==================== SLIDE 8: CLOUD STORAGE & UID ISOLATION ====================
  pdf.addPage(
    pw.Page(
      pageTheme: slideTheme(),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          buildSlideHeader('Firebase Cloud Storage & User Isolation', 'Cloud Service 03', 8),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: buildCard('REPORT GENERATION & UPLOAD (firebase_storage_service.dart)', [
                  'PDF Synthesis: PdfReportService renders formal team summary PDF matching Figma design tokens.',
                  'Per-User Path: Automatically uploaded to reports/{uid}/{fileName} in Firebase Cloud Storage.',
                  'Real-Time Progress: Emits UploadProgress stream updating visual progress bar from 0% to 100%.',
                  'Download Verification: Retrieves and displays signed download URL upon upload completion.',
                ]),
              ),
              pw.SizedBox(width: 14),
              pw.Expanded(
                child: buildCard('STRICT STORAGE SECURITY RULES (firebase/storage.rules)', [
                  'Strict Isolation: allow read, write: if request.auth != null && request.auth.uid == userId;',
                  'No Open Rules: Never uses allow read, write: if true; (which would cause zero marks on storage).',
                  'Cross-User Denial: Student A is strictly forbidden from reading or overwriting Student B\'s reports.',
                  'Console Evidence: Bucket prm393-lab-3-exematching.firebasestorage.app holds verified PDF uploads.',
                ]),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  // ==================== SLIDE 9: CLOUD MESSAGING (FCM) ====================
  pdf.addPage(
    pw.Page(
      pageTheme: slideTheme(),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          buildSlideHeader('Firebase Cloud Messaging Across 3 Lifecycle States', 'Cloud Service 04', 9),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: buildCard('LIFECYCLE COVERAGE & PERMISSIONS', [
                  'Android 13+ Consent: Requests POST_NOTIFICATIONS permission at runtime; handles denial with non-blocking toast.',
                  'Foreground State: onMessage captures notifications, updates badge count, and appends to Alerts inbox.',
                  'Background State: onBackgroundMessage runs isolated top-level handler saving record to Firestore inbox.',
                  'Terminated State: getInitialMessage launches app from cold start; onMessageOpenedApp triggers deep link.',
                ]),
              ),
              pw.SizedBox(width: 14),
              pw.Expanded(
                child: buildCard('INTERACTIVE INBOX & DEEP LINKING', [
                  'In-App Notification Center: Alerts tab displays live history of received system updates and team invites.',
                  'Interactive Actions: Decline invite includes non-blocking Undo snackbar that restores state immediately.',
                  'Targeted Navigation: Tapping a notification with teamId payload navigates directly to Team Detail screen.',
                  'Console Proof: Test messages sent from Firebase Console received across all 3 lifecycle states.',
                ]),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  // ==================== SLIDE 10: GOOGLE ANALYTICS & DEBUGVIEW ====================
  pdf.addPage(
    pw.Page(
      pageTheme: slideTheme(),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          buildSlideHeader('Google Analytics for Firebase & DebugView Verification', 'Cloud Service 05', 10),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: buildCard('PRIVACY-BY-DESIGN EVENT PLAN (docs/analytics-plan.md)', [
                  'Zero PII Policy: Absolutely no student email, full name, or raw student code passed as parameters.',
                  'User Identity: Authenticated User ID set once via setUserId(uid) following Google Sign-In.',
                  'Standard Recommended Names: login, logout, search_teams, view_team.',
                  'Custom Domain Events: join_team, cast_vote, invite_pool, lock_roster, export_report.',
                  'Typed Parameters: query_length (int), result_count (int), team_id (string), file_size_kb (int).',
                ]),
              ),
              pw.SizedBox(width: 14),
              pw.Expanded(
                child: buildCard('DEBUGVIEW REAL-TIME VERIFICATION', [
                  'ADB Debug Flag: adb shell setprop debug.firebase.analytics.app com.devorganize222.exematching',
                  'Live Stream: All 9 events observed in real-time on Firebase Console -> Analytics -> DebugView.',
                  'Product Answers: Analytics answer key questions (e.g. Which topics are searched most? What % of teams lock?).',
                  'Evidence Saved: Detailed parameter inspector screenshots preserved in evidence/debugview/.',
                ]),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  // ==================== SLIDE 11: CRASHLYTICS & REMOTE CONFIG ====================
  pdf.addPage(
    pw.Page(
      pageTheme: slideTheme(),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          buildSlideHeader('Crashlytics Telemetry & Real-Time Remote Config', 'Cloud Service 06 & Diagnostics', 11),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: buildCard('FIREBASE CRASHLYTICS (firebase_crash_reporter.dart)', [
                  'Fatal Crash Capture: FlutterError.onError and PlatformDispatcher record uncaught engine exceptions.',
                  'Handled Non-Fatal: Profile button triggers diagnostic recordError with custom keys (screen=profile, cohort=FA26).',
                  'Test Crash Action: Dedicated Profile button invokes .crash() -> verified on Console with User ID.',
                  'User Feedback: Non-fatal errors always display user-facing explanations, never crashing the UI.',
                ]),
              ),
              pw.SizedBox(width: 14),
              pw.Expanded(
                child: buildCard('FIREBASE REMOTE CONFIG (ZERO-REBUILD UPDATES)', [
                  'In-App Fallback: ConfigKeys.defaults provides safe defaults when offline (enable_waiting_pool=true).',
                  'Instant Activation: onConfigUpdated automatically activates published parameters in real time.',
                  'Observable Behavior: Changing enable_waiting_pool on Console instantly hides Waiting Pool card on Home.',
                  'Zero Rebuild: Verified live without stopping the app, reinstalling the APK, or modifying code.',
                ]),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  // ==================== SLIDE 12: ARTEMIS AUTOMATED E2E ====================
  pdf.addPage(
    pw.Page(
      pageTheme: slideTheme(),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          buildSlideHeader('Automated E2E Testing with Google ARTEMIS', 'Quality Assurance & Automation', 12),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: buildCard('ARTEMIS AI AGENT HARNESS (e2e_test/)', [
                  'Multimodal Driving: ARTEMIS drives real Android 16 emulator using Gemini Flash profile (~3-5s/step).',
                  '13 Comprehensive Test Cases: Covers all 3 user flows, error paths, native share sheet, and storage upload.',
                  '3-Run Reliability Rule: Every case runs 3 times independently (39 runs total) to eliminate flaky results.',
                  'Ground-Truth Assertions: Asserts on Semantics accessibility tree and Logcat (never status=="SUCCESS" alone).',
                ]),
              ),
              pw.SizedBox(width: 14),
              pw.Expanded(
                child: buildCard('39-RUN EXECUTION BENCHMARK RESULTS', [
                  'Overall Pass Rate: 39/39 (100% Pass) across all 13 test cases after harness stabilization.',
                  'Average Duration: ~24.0s per test case execution.',
                  'Harness Improvements (Commit 9652bb4): Token refresh on 401, E2E cooldown to respect 15 RPM quota.',
                  'Trace Evidence: Complete run logs, accessibility dumps, and final.png images stored in e2e_test/evidence/.',
                ]),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  // ==================== SLIDE 13: ARTEMIS EXPLORATORY SESSION ====================
  pdf.addPage(
    pw.Page(
      pageTheme: slideTheme(),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          buildSlideHeader('ARTEMIS Exploratory Testing Findings', 'AI-Driven Stress Testing', 13),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: buildCard('25-MINUTE UNSCRIPTED PRO SESSION', [
                  'Autonomous Agent: Driven by Gemini Pro Profile with zero pre-scripted steps.',
                  'Goal: Identify potential layout overflows, state synchronization bugs, and network edge cases.',
                  'Stress Scenarios Tested: Rapid filter chip toggling, long topic text truncation, network cut during voting.',
                  'Zero Fatal Crashes: Application handled all chaotic inputs without unexpected crashes or freeze.',
                ]),
              ),
              pw.SizedBox(width: 14),
              pw.Expanded(
                child: buildCard('OBSERVATIONS & REFINEMENTS MADE', [
                  'Layout Resilience: Text wrapping and ellipsis prevented overflow errors at both 360dp and 412dp viewports.',
                  'Firestore Resilience: Disconnecting network during vote triggered clean retry UI without data loss.',
                  'Usability Improvement Identified: Added percentage progress label to PDF upload bar based on session feedback.',
                  'Trust Assessment: Multi-run verification proved that AI agents are highly effective for mobile exploratory QA.',
                ]),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  // ==================== SLIDE 14: AI-ASSISTED CODE REVIEW ====================
  pdf.addPage(
    pw.Page(
      pageTheme: slideTheme(),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          buildSlideHeader('AI-Assisted Code Review on PR #8 (Google Gemini)', 'Engineering Rigor & Integrity', 14),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: buildCard('AUTOMATED REVIEW WORKFLOW (.github/workflows/)', [
                  'Single-Request Review: gemini_review.py sends source diff to gemini-3.5-flash-lite (completed in 14s).',
                  '5 Line-Tied Findings: Spanning security, concurrency, and reliability categories.',
                  'Engineering Decisions: 3 accepted and fixed; 2 rejected with documented technical reasoning.',
                  'Traceable Commits: Each accepted fix is anchored to its own Git commit naming the finding ID.',
                ]),
              ),
              pw.SizedBox(width: 14),
              pw.Expanded(
                child: buildCard('KEY FINDINGS & AUDITABLE DECISIONS', [
                  'GR-01 (Security · Accepted · Commit c9543a3): Join rule allowed modifying team metadata. Widened to whitelist 8 fields.',
                  'GR-02 (Concurrency · Rejected): AI suggested querying inside transaction. Rejected: client SDK does not support it; in-transaction re-read already guarantees safety.',
                  'GR-03 (Reliability · Accepted · Commit ee6ec78): KeyError on missing Firebase CLI token replaced with clear guidance.',
                  'GR-04 (Reliability · Accepted · Commit d6926d1): Added logging for Remote Config start-up fetch failure.',
                ]),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  // ==================== SLIDE 15: CHALLENGES, LESSONS & CONCLUSION ====================
  pdf.addPage(
    pw.Page(
      pageTheme: slideTheme(),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          buildSlideHeader('Challenges Encountered, Lessons Learned & Conclusion', 'Summary & Academic Verification', 15),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: buildCard('ENGINEERING CHALLENGES & SOLUTIONS', [
                  'Challenge 1: Firebase Storage rules cannot perform cross-service firestore.get() lookups -> Solved via UID folder isolation.',
                  'Challenge 2: Multi-turn AI review exhausted free-tier API quotas -> Solved via single-request structured review script.',
                  'Challenge 3: Background isolate handling of FCM messages -> Solved with dedicated top-level background handler.',
                  'Challenge 4: K19+ non-edu email accounts -> Solved with Centralized Roster Allowlist on Firestore.',
                ]),
              ),
              pw.SizedBox(width: 14),
              pw.Expanded(
                child: buildCard('FINAL VERIFICATION & CONCLUSION', [
                  'Architecture: 100% MVVM compliance with Provider; zero Firebase SDK calls in presentation widgets.',
                  'Firebase: All 6 services verified with live device evidence, security rules, and real-time synchronization.',
                  'Testing: 13 E2E test cases verified across 39 runs with Google ARTEMIS + 25-minute exploratory testing.',
                  'Conclusion: EXEMatching is a robust, cloud-enabled production-ready Flutter app meeting all Lab 3 criteria.',
                ]),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  final outputFile = File('slides/Lab03_DEVORGANIZE222_slides.pdf');
  await outputFile.parent.create(recursive: true);
  await outputFile.writeAsBytes(await pdf.save());
  print('Successfully generated Lab 3 Slides: ${outputFile.path} (${await outputFile.length()} bytes)');
}

