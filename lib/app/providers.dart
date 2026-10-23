import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/local/local_auth_service.dart';
import '../services/local/local_database.dart';
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
/// FIREBASE TEAMMATE: replace each `Local*` / `Debug*` instance below with the
/// Firebase implementation from `lib/firebase/` (same interface). Screens and
/// ViewModels need no change.
class AppServices {
  AppServices._(this.providers);

  final List<SingleChildWidget> providers;

  static Future<AppServices> create() async {
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
      Provider<TeamRepository>.value(value: LocalTeamRepository(db)),
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
