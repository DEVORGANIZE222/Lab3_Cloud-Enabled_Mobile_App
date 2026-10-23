abstract class AnalyticsService {
  Future<void> setUserId(String userId);
  Future<void> logLogin({required String method});
  Future<void> logSearch({required String searchTerm, int? resultCount});
  Future<void> logViewTeam({required String teamId, int? currentSlots});
  Future<void> logJoinRequest({required String teamId});
  Future<void> logVote({required String teamId});
  Future<void> logLockRoster({required String teamId, required int memberCount});
  Future<void> logExportReport({required String topic, required int fileSizeKb});
  Future<void> logLogout();
}

class FirebaseAnalyticsService implements AnalyticsService {
  @override
  Future<void> setUserId(String userId) async {}

  @override
  Future<void> logLogin({required String method}) async {}

  @override
  Future<void> logSearch({required String searchTerm, int? resultCount}) async {}

  @override
  Future<void> logViewTeam({required String teamId, int? currentSlots}) async {}

  @override
  Future<void> logJoinRequest({required String teamId}) async {}

  @override
  Future<void> logVote({required String teamId}) async {}

  @override
  Future<void> logLockRoster({required String teamId, required int memberCount}) async {}

  @override
  Future<void> logExportReport({required String topic, required int fileSizeKb}) async {}

  @override
  Future<void> logLogout() async {}
}
