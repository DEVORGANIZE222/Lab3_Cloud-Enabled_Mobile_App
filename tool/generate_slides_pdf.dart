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

  // A screenshot that is missing is shown as missing, never replaced by a stand-in.
  pw.Widget shot(String caption, String path, {double height = 300}) {
    final file = File(path);
    return pw.Column(
      children: [
        pw.Container(
          height: height,
          width: height * 0.45,
          decoration: pw.BoxDecoration(border: pw.Border.all(color: borderCol), borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6))),
          child: file.existsSync()
              ? pw.Image(pw.MemoryImage(file.readAsBytesSync()), fit: pw.BoxFit.contain)
              : pw.Center(child: pw.Text('missing:\n$path', style: pw.TextStyle(color: PdfColors.red, fontSize: 7), textAlign: pw.TextAlign.center)),
        ),
        pw.SizedBox(height: 4),
        pw.Text(caption, style: pw.TextStyle(color: textMuted, fontSize: 7.5)),
      ],
    );
  }

  // Pass counts per test case, read from the evidence of the last full run.
  // pytest writes a second <testcase> for a teardown error, so key by run.
  final outcome = <String, bool>{};
  final junit = File('e2e_test/evidence/junit.xml');
  if (junit.existsSync()) {
    final xml = junit.readAsStringSync();
    for (final m in RegExp(r'<testcase [^>]*name="(test_tc\d+[^"]*\[run\d+\])"[^>]*?(/>|>([\s\S]*?)</testcase>)').allMatches(xml)) {
      final failed = (m.group(3) ?? '').contains('<failure') || (m.group(3) ?? '').contains('<error');
      outcome[m.group(1)!] = (outcome[m.group(1)!] ?? true) && !failed;
    }
  }
  final runs = <String, List<bool>>{};
  for (final e in outcome.entries) {
    runs.putIfAbsent(RegExp(r'test_(tc\d+)').firstMatch(e.key)!.group(1)!.toUpperCase(), () => []).add(e.value);
  }
  final passedRuns = runs.values.expand((r) => r).where((ok) => ok).length;
  final totalRuns = runs.values.expand((r) => r).length;

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
          buildSlideHeader('Figma vs App: Key Screens & Deviations', 'Design Traceability', 3),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              shot('Figma SCR_02 Home', 'assets/figma/SCR_02_ Dashboard.png', height: 330),
              shot('App · Home', 'docs/screenshots/scr02_home.png', height: 330),
              shot('Figma SCR_03 Browse', 'assets/figma/SCR_03_ Browse Groups.png', height: 330),
              shot('App · Browse', 'docs/screenshots/scr03_browse.png', height: 330),
              shot('Figma SCR_07 Lock', 'assets/figma/SCR_07_ Group Lock Review & Error Recovery.png', height: 330),
              shot('App · Review & Lock', 'docs/screenshots/scr07_lock_error.png', height: 330),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Deviations (all recorded in docs/design-traceability.md): DV-01 "Team" everywhere instead of Group/Team; '
            'DV-04 direct open-slot join instead of a join request; DV-08 Profile/Settings as the Firebase demo area; '
            'DV-09/10 contrast raised to WCAG AA; vote counts hidden until the student votes (SCR_06).',
            style: pw.TextStyle(color: textDark, fontSize: 8),
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
                  'Unauthorized Denial: Non-roster Google accounts are immediately rejected with "This account is not on the class roster" (TC-01).',
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
                  'Handled Non-Fatal: Profile button triggers diagnostic recordError with custom keys (screen=profile; student_cohort set at sign-in).',
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
                child: buildCard('ARTEMIS HARNESS (e2e_test/) & HOW TO READ THE RESULTS', [
                  'ARTEMIS (Gemini flash-lite) drives the app on an Android 16 emulator with a real Google account.',
                  '13 cases cover the 3 Lab 2 flows, their error paths, a native share sheet and the Storage upload.',
                  'Each case runs 3 times; assertions check the accessibility tree, Logcat analytics and Firestore/Storage, '
                      'not the agent\'s SUCCESS flag alone.',
                  'Run 1 (2 Nov): 6/39. Causes: expired Firestore token in the harness, Gemini free-tier 429s, and two app '
                      'bugs found by the run (search box swallowed typed text; Waiting Pool invite denied by rules) - all fixed.',
                  'Evidence: e2e_test/evidence/ (junit.xml, result.json with trace ID, screen dump, screenshot per run); '
                      'failures explained in docs/test-plan.md.',
                ]),
              ),
              pw.SizedBox(width: 14),
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(color: bgLight, border: pw.Border.all(color: borderCol), borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6))),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        totalRuns == 0 ? 'FINAL RUN: no junit.xml found' : 'FINAL RUN: $passedRuns / $totalRuns runs passed',
                        style: pw.TextStyle(color: primary, fontSize: 10, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 6),
                      pw.TableHelper.fromTextArray(
                        headers: ['Case', 'Run 1', 'Run 2', 'Run 3', 'Pass rate'],
                        data: [
                          for (final id in (runs.keys.toList()..sort()))
                            [
                              id,
                              for (var i = 0; i < 3; i++) i < runs[id]!.length ? (runs[id]![i] ? 'PASS' : 'FAIL') : '-',
                              '${runs[id]!.where((ok) => ok).length}/${runs[id]!.length}',
                            ],
                        ],
                        headerStyle: pw.TextStyle(color: PdfColors.white, fontSize: 7.5, fontWeight: pw.FontWeight.bold),
                        headerDecoration: pw.BoxDecoration(color: primary),
                        cellStyle: pw.TextStyle(color: textDark, fontSize: 7.5),
                        cellPadding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      ),
                    ],
                  ),
                ),
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
                child: buildCard('CHALLENGES FOUND BY TESTING THE REAL APP', [
                  'Invite from Waiting Pool always failed: Firestore rules let students read only their own pool record (PERMISSION_DENIED in Logcat). Rules now allow unassigned records.',
                  'ARTEMIS could not type: a Semantics(textField) wrapper created a second, non-editable EditText, and Flutter ignored the Android Paste key. Both fixed in the app.',
                  'cast_vote sent a bool parameter: the event never reached Analytics and voting showed a false error.',
                  'Undo after declining an invite never appeared (card disposed before the snackbar).',
                  'Gemini free tier (20-500 requests/day per model) limited both the AI review and ARTEMIS runs.',
                ]),
              ),
              pw.SizedBox(width: 14),
              pw.Expanded(
                child: buildCard('LESSONS LEARNED', [
                  'The agent SUCCESS flag is not evidence: TC-12 reported "Undo restored 1 invite" while the screen showed 0; ground-truth checks caught it.',
                  'Generated or claimed results are worthless; only runs with trace IDs, screenshots and Firestore checks count.',
                  'Accessibility labels are test infrastructure: the same bug blocked TalkBack users and the test agent.',
                  'Security rules must be tested with the real client flows, not only read: a correct-looking rule broke Flow 3.',
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

