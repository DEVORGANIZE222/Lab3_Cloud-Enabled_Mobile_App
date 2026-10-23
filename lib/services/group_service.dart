import '../models/team_model.dart';

abstract class GroupService {
  Future<List<TeamModel>> getTeams({String? query, String? tagFilter});
  Future<TeamModel> getTeamById(String teamId);
  Future<void> requestToJoin(String teamId, String userId);
  Future<void> lockTeamRoster(String teamId);
  Future<void> broadcastToWaitingPool(String teamId);
}

class FirestoreGroupService implements GroupService {
  @override
  Future<List<TeamModel>> getTeams({String? query, String? tagFilter}) async => [];

  @override
  Future<TeamModel> getTeamById(String teamId) async => throw UnimplementedError();

  @override
  Future<void> requestToJoin(String teamId, String userId) async {}

  @override
  Future<void> lockTeamRoster(String teamId) async {}

  @override
  Future<void> broadcastToWaitingPool(String teamId) async {}
}
