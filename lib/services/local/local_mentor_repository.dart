import 'dart:math';

import '../../models/mentor.dart';
import '../../models/student.dart';
import '../../models/team.dart';
import '../../models/view_state.dart';
import '../services.dart';
import 'local_database.dart';

class LocalMentorRepository implements MentorRepository {
  LocalMentorRepository(this._db);
  final LocalDatabase _db;

  List<Mentor> _filter(String query, String? department, String? expertise, bool availableOnly) {
    final q = query.trim().toLowerCase();
    return _db.mentors.values.where((m) {
      if (availableOnly && !m.isAvailable) return false;
      if (department != null && department.isNotEmpty && m.department != department) {
        return false;
      }
      if (expertise != null &&
          expertise.isNotEmpty &&
          !m.expertise.any((e) => e.toLowerCase() == expertise.toLowerCase())) {
        return false;
      }
      if (q.isNotEmpty) {
        final matches = m.fullName.toLowerCase().contains(q) ||
            m.title.toLowerCase().contains(q) ||
            m.department.toLowerCase().contains(q) ||
            m.bio.toLowerCase().contains(q) ||
            m.expertise.any((e) => e.toLowerCase().contains(q));
        if (!matches) return false;
      }
      return true;
    }).toList();
  }

  @override
  Future<List<Mentor>> searchMentors({
    String query = '',
    String? department,
    String? expertise,
    bool availableOnly = false,
  }) async {
    await _db.roundTrip();
    return _filter(query, department, expertise, availableOnly);
  }

  @override
  Future<Mentor> getMentor(String mentorId) async {
    await _db.roundTrip();
    final m = _db.mentors[mentorId];
    if (m == null) {
      throw const AppFailure('Mentor not found', 'This mentor profile does not exist.', retryable: false);
    }
    return m;
  }

  @override
  Stream<List<Mentor>> watchMentors() async* {
    await _db.roundTrip();
    yield _db.mentors.values.toList();
    yield* _db.mentorChanges;
  }

  @override
  Future<List<MentorRequest>> getRequestsForTeam(String teamId) async {
    await _db.roundTrip();
    return List.unmodifiable(_db.mentorRequests[teamId] ?? const []);
  }

  @override
  Stream<List<MentorRequest>> watchRequestsForTeam(String teamId) async* {
    await _db.roundTrip();
    yield List.unmodifiable(_db.mentorRequests[teamId] ?? const []);
    yield* _db.mentorRequestChanges.where((tid) => tid == teamId).map((_) {
      return List.unmodifiable(_db.mentorRequests[teamId] ?? const []);
    });
  }

  @override
  Future<List<MentorRequest>> getRequestsForMentor(String mentorId) async {
    await _db.roundTrip();
    final all = <MentorRequest>[];
    for (final list in _db.mentorRequests.values) {
      all.addAll(list.where((r) => r.mentorId == mentorId));
    }
    all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return all;
  }

  @override
  Stream<List<MentorRequest>> watchRequestsForMentor(String mentorId) async* {
    await _db.roundTrip();
    List<MentorRequest> forMentor() {
      final all = <MentorRequest>[];
      for (final list in _db.mentorRequests.values) {
        all.addAll(list.where((r) => r.mentorId == mentorId));
      }
      all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return all;
    }

    yield forMentor();
    yield* _db.mentorRequestChanges.map((_) => forMentor());
  }

  @override
  Future<void> respondToRequest({required String requestId, required bool accept, String? reason}) async {
    await _db.roundTrip();
    _db.respondMentorRequest(requestId, accept, reason);
  }

  @override
  Future<List<Team>> getTeamsForMentor(String mentorId, [String? mentorName]) async {
    await _db.roundTrip();
    final mentor = _db.mentors[mentorId];
    final name = mentorName ?? mentor?.fullName;

    return _db.teams.values.where((t) {
      if (name != null && name.isNotEmpty && t.supervisor.toLowerCase().contains(name.toLowerCase())) {
        return true;
      }
      if (mentor != null && mentor.mentoredTeamNames.contains(t.name)) {
        return true;
      }
      return false;
    }).toList();
  }

  @override
  Future<MentorRequest> requestMentor({
    required String teamId,
    required String teamName,
    required String mentorId,
    required String mentorName,
    required Student sender,
    required String message,
  }) async {
    await _db.roundTrip();
    final mentor = _db.mentors[mentorId];
    if (mentor == null) {
      throw const AppFailure('Mentor unavailable', 'The selected mentor could not be found.', retryable: false);
    }
    if (!mentor.isAvailable) {
      throw AppFailure(
        'Mentor quota reached',
        '${mentor.fullName} already has ${mentor.maxQuota} Capstone teams. Please select another supervisor.',
        retryable: false,
      );
    }

    final existing = _db.mentorRequests[teamId] ?? [];
    if (existing.any((r) => r.mentorId == mentorId && r.status == MentorRequestStatus.pending)) {
      throw const AppFailure(
        'Request already sent',
        'Your team already has a pending supervision request to this mentor.',
        retryable: false,
      );
    }

    final id = 'req_${Random().nextInt(999999)}';
    final request = MentorRequest.create(
      id: id,
      teamId: teamId,
      teamName: teamName,
      mentorId: mentorId,
      mentorName: mentorName,
      sender: sender,
      message: message,
    );

    _db.putMentorRequest(request);
    return request;
  }

  @override
  Future<void> cancelRequest(String requestId) async {
    await _db.roundTrip();
    for (final entry in _db.mentorRequests.entries) {
      if (entry.value.any((r) => r.id == requestId)) {
        _db.cancelMentorRequest(entry.key, requestId);
        break;
      }
    }
  }
}
