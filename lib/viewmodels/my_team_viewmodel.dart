import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/student.dart';
import '../models/team.dart';
import '../models/view_state.dart';
import '../services/services.dart';
import 'guard.dart';

enum TeamPhase { inFormation, electLeader, readyToLock, locked }

/// SCR_05: team workspace. Empty state = not in a team.
class MyTeamViewModel extends ChangeNotifier {
  MyTeamViewModel(this._student, this._teams, this._crash);

  final Student _student;
  final TeamRepository _teams;
  final CrashReporter _crash;
  StreamSubscription<Team?>? _watch;

  ViewState<Team> state = const Loading();
  bool leaving = false;
  bool resigning = false;

  String get myId => _student.id;

  bool isLeader(Team t) => t.leaderId == _student.id;
  bool hasVoted(Team t) => t.votes.containsKey(_student.id);

  TeamPhase phaseOf(Team t) {
    if (t.locked) return TeamPhase.locked;
    if (!t.hasLeader) return TeamPhase.electLeader;
    if (!t.meetsSizeRule) return TeamPhase.inFormation;
    return TeamPhase.readyToLock;
  }

  Future<void> load() async {
    state = const Loading();
    notifyListeners();
    try {
      final team = await _teams.teamOf(_student.id);
      state = team == null ? const Empty() : Data(team);
      await _watch?.cancel();
      _watch = _teams.watchTeamOf(_student.id).listen((t) {
        state = t == null ? const Empty() : Data(t);
        notifyListeners();
      });
    } catch (e, st) {
      state = Failure(await toFailure(e, st, crash: _crash, reason: 'my_team_load'));
    }
    notifyListeners();
  }

  Future<AppFailure?> leave(Team team) async {
    leaving = true;
    notifyListeners();
    try {
      await _teams.leaveTeam(team.id, _student.id);
      state = const Empty();
      return null;
    } catch (e, st) {
      return toFailure(e, st, crash: _crash, reason: 'leave_team');
    } finally {
      leaving = false;
      notifyListeners();
    }
  }

  Future<AppFailure?> resignLeader(Team team) async {
    resigning = true;
    notifyListeners();
    try {
      final updated = await _teams.resignLeader(team.id, _student.id);
      state = Data(updated);
      return null;
    } catch (e, st) {
      return toFailure(e, st, crash: _crash, reason: 'resign_leader');
    } finally {
      resigning = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _watch?.cancel();
    super.dispose();
  }
}
