import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/registration.dart';
import '../models/student.dart';
import '../models/team.dart';
import '../models/view_state.dart';
import '../services/services.dart';
import 'guard.dart';

class DashboardData {
  const DashboardData({
    required this.student,
    required this.window,
    required this.team,
    required this.registrationClosed,
    required this.showPoolEntry,
    required this.now,
  });

  final Student student;
  final RegistrationWindow window;
  final Team? team;
  final bool registrationClosed;
  final bool showPoolEntry;
  final DateTime now;

  Duration get timeLeft => window.closesAt.difference(now);

  /// Deadline is urgent below 48 hours (Lab 2 critique F-05).
  bool get urgent => timeLeft.inHours < 48;

  /// "Formation health" chips on the Figma Dashboard.
  bool get sizeOk => team?.meetsSizeRule ?? false;
  bool get leaderOk => team?.hasLeader ?? false;

  DashboardData withTeam(Team? team) => DashboardData(
    student: student,
    window: window,
    team: team,
    registrationClosed: registrationClosed,
    showPoolEntry: showPoolEntry,
    now: now,
  );
}

/// SCR_02: deadline countdown, team status, next step.
class DashboardViewModel extends ChangeNotifier {
  DashboardViewModel(this._student, this._teams, this._registration, this._config, this._crash) {
    _configSub = _config.changes.listen((_) => load());
    _teamSub = _teams.watchTeamOf(_student.id).listen(_onTeam);
  }

  final Student _student;
  final TeamRepository _teams;
  final RegistrationService _registration;
  final ConfigService _config;
  final CrashReporter _crash;
  late final StreamSubscription<void> _configSub;
  late final StreamSubscription<Team?> _teamSub;

  ViewState<DashboardData> state = const Loading();

  Future<void> load() async {
    state = const Loading();
    notifyListeners();
    try {
      final results = await Future.wait([_registration.currentWindow(), _teams.teamOf(_student.id)]);
      final window = results[0] as RegistrationWindow;
      final now = DateTime.now();
      state = Data(
        DashboardData(
          student: _student,
          window: window,
          team: results[1] as Team?,
          registrationClosed: _config.getBool(ConfigKeys.registrationClosed) || window.isClosed(now),
          showPoolEntry: _config.getBool(ConfigKeys.showPoolEntry),
          now: now,
        ),
      );
    } catch (e, st) {
      state = Failure(await toFailure(e, st, crash: _crash, reason: 'dashboard_load'));
    }
    notifyListeners();
  }

  /// Team changed elsewhere (joined, voted, locked): update without a spinner.
  void _onTeam(Team? team) {
    final s = state;
    if (s is! Data<DashboardData>) return;
    state = Data(s.value.withTeam(team));
    notifyListeners();
  }

  @override
  void dispose() {
    _teamSub.cancel();
    _configSub.cancel();
    super.dispose();
  }
}
