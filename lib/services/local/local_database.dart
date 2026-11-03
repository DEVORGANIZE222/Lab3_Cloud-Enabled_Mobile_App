import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;

import '../../models/app_notification.dart';
import '../../models/student.dart';
import '../../models/mentor.dart';
import '../../models/team.dart';
import '../../models/view_state.dart';

/// In-memory store for the local (pre-Firebase) services, seeded from
/// `assets/seed/seed.json` on every app launch, so every E2E test starts from
/// the same data. Replaced by Cloud Firestore in the submitted build.
class LocalDatabase {
  LocalDatabase({this.latency = const Duration(milliseconds: 500), this.requireNetwork = true});

  final Duration latency;

  /// The local services refuse to answer without connectivity, so the app's
  /// offline/error states can be exercised exactly as with Firestore.
  final bool requireNetwork;

  late final Map<String, dynamic> _seed;
  final Map<String, Student> students = {};
  final Map<String, Team> teams = {};
  final Map<String, List<AppNotification>> notifications = {};
  final List<TeamMember> poolStudents = [];
  final Set<String> fillsOnNextJoin = {};
  final Map<String, Mentor> mentors = {};
  final Map<String, List<MentorRequest>> mentorRequests = {};
  late final DateTime launchedAt;

  final _teamChanges = StreamController<Team>.broadcast();
  final _notificationChanges = StreamController<String>.broadcast();
  final _mentorChanges = StreamController<List<Mentor>>.broadcast();
  final _mentorRequestChanges = StreamController<String>.broadcast();

  Stream<Team> get teamChanges => _teamChanges.stream;
  Stream<String> get notificationChanges => _notificationChanges.stream;
  Stream<List<Mentor>> get mentorChanges => _mentorChanges.stream;
  Stream<String> get mentorRequestChanges => _mentorRequestChanges.stream;

  Map<String, dynamic> get seed => _seed;

  Future<void> load() async {
    launchedAt = DateTime.now();
    _seed = jsonDecode(await rootBundle.loadString('assets/seed/seed.json')) as Map<String, dynamic>;
    for (final s in _seed['students'] as List) {
      final st = Student.fromJson(s as Map<String, dynamic>);
      students[st.id] = st;
    }
    for (final t in _seed['teams'] as List) {
      final map = t as Map<String, dynamic>;
      final team = Team.fromJson(map);
      teams[team.id] = team;
      if (map['_scenario'] == 'fillsOnNextJoin') fillsOnNextJoin.add(team.id);
    }
    for (final p in _seed['poolStudents'] as List) {
      poolStudents.add(TeamMember.fromJson(p as Map<String, dynamic>));
    }
    (_seed['notifications'] as Map<String, dynamic>).forEach((uid, list) {
      notifications[uid] = [
        for (final n in list as List) AppNotification.fromJson(n as Map<String, dynamic>, launchedAt),
      ];
    });
    if (_seed['mentors'] is List) {
      for (final m in _seed['mentors'] as List) {
        final mentor = Mentor.fromJson(m as Map<String, dynamic>);
        mentors[mentor.id] = mentor;
      }
    }
    if (_seed['mentorRequests'] is List) {
      for (final r in _seed['mentorRequests'] as List) {
        final req = MentorRequest.fromJson(r as Map<String, dynamic>);
        mentorRequests.putIfAbsent(req.teamId, () => []).add(req);
      }
    }
  }

  /// Simulates a round trip: waits [latency] and fails with
  /// [AppFailure.offline] when the device has no connectivity.
  Future<void> roundTrip() async {
    await Future<void>.delayed(latency);
    if (!requireNetwork) return;
    try {
      final result = await InternetAddress.lookup('firestore.googleapis.com').timeout(const Duration(seconds: 4));
      if (result.isEmpty || result.first.rawAddress.isEmpty) throw AppFailure.offline;
    } on SocketException {
      throw AppFailure.offline;
    } on TimeoutException {
      throw AppFailure.offline;
    }
  }

  void putTeam(Team team) {
    teams[team.id] = team;
    _teamChanges.add(team);
  }

  void addNotification(String uid, AppNotification n) {
    notifications.putIfAbsent(uid, () => []).insert(0, n);
    _notificationChanges.add(uid);
  }

  void notificationsChanged(String uid) => _notificationChanges.add(uid);

  void putMentorRequest(MentorRequest request) {
    mentorRequests.putIfAbsent(request.teamId, () => []).insert(0, request);
    _mentorRequestChanges.add(request.teamId);
  }

  void cancelMentorRequest(String teamId, String requestId) {
    mentorRequests[teamId]?.removeWhere((r) => r.id == requestId);
    _mentorRequestChanges.add(teamId);
  }

  void respondMentorRequest(String requestId, bool accept, String? reason) {
    for (final entry in mentorRequests.entries) {
      final list = entry.value;
      final i = list.indexWhere((r) => r.id == requestId);
      if (i >= 0) {
        final req = list[i];
        final updatedReq = req.copyWith(
          status: accept ? MentorRequestStatus.approved : MentorRequestStatus.rejected,
          decisionReason: reason,
        );
        list[i] = updatedReq;
        _mentorRequestChanges.add(entry.key);

        if (accept) {
          final team = teams[req.teamId];
          final mentor = mentors[req.mentorId];
          if (team != null && mentor != null) {
            final updatedTeam = Team(
              id: team.id,
              code: team.code,
              name: team.name,
              topic: team.topic,
              description: team.description,
              category: team.category,
              tags: team.tags,
              members: team.members,
              openRoles: team.openRoles,
              supervisor: mentor.fullName,
              capacity: team.capacity,
              leaderId: team.leaderId,
              votes: team.votes,
              locked: team.locked,
              lockCode: team.lockCode,
              lockedAt: team.lockedAt,
              invitesSent: team.invitesSent,
            );
            putTeam(updatedTeam);

            final names = List<String>.from(mentor.mentoredTeamNames);
            if (!names.contains(team.name)) names.add(team.name);
            final updatedMentor = mentor.copyWith(
              currentAssigned: mentor.currentAssigned + 1,
              mentoredTeamNames: names,
            );
            mentorUpdated(updatedMentor);
          }
        }
        break;
      }
    }
  }

  void mentorUpdated(Mentor m) {
    mentors[m.id] = m;
    _mentorChanges.add(mentors.values.toList());
  }
}
