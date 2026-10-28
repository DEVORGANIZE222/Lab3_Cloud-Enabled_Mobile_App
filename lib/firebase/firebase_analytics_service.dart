import 'package:firebase_analytics/firebase_analytics.dart';

import '../services/services.dart';

/// Firebase Analytics implementation for user actions tracking.
class FirebaseAnalyticsService implements AnalyticsService {
  FirebaseAnalyticsService([FirebaseAnalytics? analytics]) : _analytics = analytics ?? FirebaseAnalytics.instance;
  final FirebaseAnalytics _analytics;
  Future<void> _event(String name, Map<String, Object> parameters) =>
      _analytics.logEvent(name: name, parameters: parameters);
  @override
  Future<void> setUserId(String? id) async {
    await _analytics.setUserId(id: id);
  }

  @override
  Future<void> logLogin({required String method}) async {
    await _analytics.logLogin(loginMethod: method);
  }

  @override
  Future<void> logLogout() async {
    await _event('logout', {});
  }

  @override
  Future<void> logSearch({required String term, required int resultCount, required List<String> filters}) async {
    await _event('search_teams', {
      'query_length': term.length,
      'result_count': resultCount,
      'filter_count': filters.length,
    });
  }

  @override
  Future<void> logViewTeam({required String teamId, required String teamCode}) async {
    await _event('view_team', {'team_id': teamId, 'team_code': teamCode});
  }

  @override
  Future<void> logJoinTeam({required String teamId, required int memberCount}) async {
    await _event('join_team', {'team_id': teamId, 'member_count': memberCount});
  }

  @override
  Future<void> logVote({required String teamId, required bool changed}) async {
    await _event('cast_vote', {'team_id': teamId, 'changed': changed});
  }

  @override
  Future<void> logInviteFromPool({required String teamId, required int invited}) async {
    await _event('invite_pool', {'team_id': teamId, 'invited_count': invited});
  }

  @override
  Future<void> logLockRoster({required String teamId, required int memberCount}) async {
    await _event('lock_roster', {'team_id': teamId, 'member_count': memberCount});
  }

  @override
  Future<void> logExportReport({required String teamId, required int fileSizeKb}) async {
    await _event('export_report', {'team_id': teamId, 'file_size_kb': fileSizeKb});
  }
}
