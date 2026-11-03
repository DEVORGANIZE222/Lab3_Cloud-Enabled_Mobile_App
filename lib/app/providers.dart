import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../firebase/firebase_analytics_service.dart';
import '../firebase/firebase_auth_service.dart';
import '../firebase/firebase_crash_reporter.dart';
import '../firebase/firebase_messaging_service.dart';
import '../firebase/firebase_notification_repository.dart';
import '../firebase/firebase_pool_repository.dart';
import '../firebase/firebase_remote_config_service.dart';
import '../firebase/firebase_storage_service.dart';
import '../firebase/firestore_mentor_repository.dart';
import '../firebase/firestore_team_repository.dart';
import '../services/local/local_auth_service.dart';
import '../services/local/local_database.dart';
import '../services/local/local_mentor_repository.dart';
import '../services/local/local_services.dart';
import '../services/local/local_team_repository.dart';
import '../services/pdf_report_service.dart';
import '../services/services.dart';
import '../viewmodels/session_viewmodel.dart';
import '../widgets/account_picker.dart';

/// Root navigator, also used by the local account picker.
final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Composition root: the only place that names concrete service classes.
///
/// Switches between local development implementations (seeded with test accounts
/// `minh.le@fpt.edu.vn`, `an.tran@fpt.edu.vn`) and Cloud Firebase services.
/// Pass `--dart-define=USE_FIREBASE=true` to force Firebase in production builds.
class AppServices {
  AppServices._(this.providers);

  final List<SingleChildWidget> providers;

  static Future<AppServices> create() async {
    const useFirebase = bool.fromEnvironment('USE_FIREBASE', defaultValue: false);
    final messaging = FirebaseMessagingService();

    if (useFirebase) {
      final auth = FirebaseAuthService(messaging: messaging);
      final AnalyticsService analytics = FirebaseAnalyticsService();
      final CrashReporter crash = FirebaseCrashReporter();
      final config = FirebaseRemoteConfigService();
      await config.initialize();

      return AppServices._([
        Provider<AuthService>.value(value: auth),
        Provider<FirebaseMessagingService>.value(value: messaging),
        Provider<TeamRepository>.value(value: FirestoreTeamRepository()),
        Provider<MentorRepository>.value(value: FirestoreMentorRepository()),
        Provider<NotificationRepository>.value(value: FirebaseNotificationRepository()),
        Provider<RegistrationService>.value(value: FirebaseRegistrationService()),
        Provider<PoolRepository>.value(value: FirebasePoolRepository()),
        Provider<ConfigService>.value(value: config),
        Provider<AnalyticsService>.value(value: analytics),
        Provider<CrashReporter>.value(value: crash),
        Provider<ReportService>.value(value: PdfReportService()),
        Provider<StorageService>.value(value: FirebaseStorageService()),
        ChangeNotifierProvider<SessionViewModel>(create: (_) => SessionViewModel(auth, analytics, crash)),
      ]);
    }

    // Default: Local development services with seeded test accounts.
    final prefs = await SharedPreferences.getInstance();
    final db = LocalDatabase();
    await db.load();

    final auth = LocalAuthService(db, prefs, (accounts) async {
      final context = rootNavigatorKey.currentContext;
      if (context == null) return null;
      return showAccountPicker(context, accounts);
    })..restore();

    final AnalyticsService analytics = DebugAnalyticsService();
    final CrashReporter crash = DebugCrashReporter();

    return AppServices._([
      Provider<AuthService>.value(value: auth),
      Provider<FirebaseMessagingService>.value(value: messaging),
      Provider<TeamRepository>.value(value: LocalTeamRepository(db)),
      Provider<MentorRepository>.value(value: LocalMentorRepository(db)),
      Provider<NotificationRepository>.value(value: LocalNotificationRepository(db)),
      Provider<RegistrationService>.value(value: LocalRegistrationService(db)),
      Provider<PoolRepository>.value(value: LocalPoolRepository(db)),
      Provider<ConfigService>.value(value: LocalConfigService()),
      Provider<AnalyticsService>.value(value: analytics),
      Provider<CrashReporter>.value(value: crash),
      Provider<ReportService>.value(value: PdfReportService()),
      Provider<StorageService>.value(value: LocalStorageService()),
      ChangeNotifierProvider<SessionViewModel>(create: (_) => SessionViewModel(auth, analytics, crash)),
    ]);
  }
}
