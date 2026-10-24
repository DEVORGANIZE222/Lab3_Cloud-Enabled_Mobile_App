import 'dart:async';
import '../models/student.dart';
import '../models/team.dart';
import '../services/services.dart';

/// Cloud Firestore implementation of TeamRepository.
///
/// Handles teams collection, queries, capacity checks, transactions and listeners.
class FirestoreTeamRepository implements TeamRepository {
  @override
  Future<List<Team>> searchTeams({
    String query = '',
    Set<TeamFilter> filters = const {},
    int limit = 20,
  }) async {
    // TODO: Implement Firestore query with filters and search term
    return [];
  }

  @override
  Future<Team> getTeam(String teamId) async {
    // TODO: Implement Firestore doc fetch
    throw UnimplementedError();
  }

  @override
  Future<Team?> teamOf(String studentId) async {
    // TODO: Query team where memberIds contains studentId
    return null;
  }

  @override
  Stream<Team> watchTeam(String teamId) {
    // TODO: snapshots() on team document
    return const Stream.empty();
  }

  @override
  Stream<Team?> watchTeamOf(String studentId) {
    // TODO: snapshots() on teams where memberIds contains studentId
    return const Stream.empty();
  }

  @override
  Stream<void> teamsChanged() {
    // TODO: snapshots() on teams collection for updates
    return const Stream.empty();
  }

  @override
  Future<Team> joinTeam(String teamId, Student student) async {
    // TODO: Firestore runTransaction: check capacity (max 5) and add member
    throw UnimplementedError();
  }

  @override
  Future<void> leaveTeam(String teamId, String studentId) async {
    // TODO: Firestore runTransaction: remove studentId from members
    throw UnimplementedError();
  }

  @override
  Future<Team> castVote(String teamId, String voterId, String candidateId) async {
    // TODO: Firestore transaction: record vote, calculate majority, elect leader
    throw UnimplementedError();
  }

  @override
  Future<Team> lockTeam(String teamId, String leaderId) async {
    // TODO: Firestore transaction: check leader and member count (4-5), set isLocked = true
    throw UnimplementedError();
  }

  @override
  Future<int> inviteFromPool(String teamId) async {
    // TODO: Firestore transaction: invite available pool members into empty slots
    return 0;
  }
}
