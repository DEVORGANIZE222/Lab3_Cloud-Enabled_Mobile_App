import '../services/services.dart';

/// Firebase Analytics implementation for user actions tracking.
class FirebaseAnalyticsService implements AnalyticsService {
  @override
  Future<void> setUserId(String? id) async {
    // TODO: FirebaseAnalytics.instance.setUserId(id: id)
  }

  @override
  Future<void> logLogin({required String method}) async {
    // TODO: FirebaseAnalytics.instance.logLogin(loginMethod: method)
  }

  @override
  Future<void> logLogout() async {
    // TODO: FirebaseAnalytics.instance.logEvent(name: 'logout')
  }

  @override
  Future<void> logSearch({required String term, required int resultCount, required List<String> filters}) async {
    // TODO: log search event
  }

  @override
  Future<void> logViewTeam({required String teamId, required String teamCode}) async {
    // TODO: log view_item event
  }

  @override
  Future<void> logJoinTeam({required String teamId, required int memberCount}) async {
    // TODO: log join_team event
  }

  @override
  Future<void> logVote({required String teamId, required bool changed}) async {
    // TODO: log vote event
  }

  @override
  Future<void> logInviteFromPool({required String teamId, required int invited}) async {
    // TODO: log pool_invite event
  }

  @override
  Future<void> logLockRoster({required String teamId, required int memberCount}) async {
    // TODO: log lock_roster event
  }

  @override
  Future<void> logExportReport({required String teamId, required int fileSizeKb}) async {
    // TODO: log export_report event
  }
}
