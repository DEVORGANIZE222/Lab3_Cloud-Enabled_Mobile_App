import 'package:flutter/foundation.dart';

import '../models/student.dart';
import '../models/team.dart';
import '../models/view_state.dart';
import '../services/services.dart';
import 'guard.dart';

class CreateTeamViewModel extends ChangeNotifier {
  CreateTeamViewModel(this._student, this._teams, this._analytics, this._crash);

  final Student _student;
  final TeamRepository _teams;
  final AnalyticsService _analytics;
  final CrashReporter _crash;

  bool creating = false;
  AppFailure? failure;

  static const defaultCategories = ['Web/Cloud', 'Mobile', 'AI/ML', 'IoT', 'Fintech', 'EdTech'];
  static const suggestedRoles = [
    'Frontend Dev',
    'Backend Dev',
    'UI/UX Designer',
    'Mobile Dev',
    'AI Engineer',
    'QA Tester',
    'Business Analyst',
  ];
  static const suggestedTags = [
    'Flutter',
    'React',
    'NodeJS',
    'Python',
    'Firebase',
    'Docker',
    'Spring Boot',
    'Figma',
  ];

  Future<Team?> createTeam({
    required String name,
    required String topic,
    required String category,
    String? description,
    List<String> tags = const [],
    List<String> openRoles = const [],
  }) async {
    creating = true;
    failure = null;
    notifyListeners();

    try {
      final team = await _teams.createTeam(
        student: _student,
        name: name,
        topic: topic,
        category: category,
        description: description,
        tags: tags,
        openRoles: openRoles,
      );
      await _analytics.logCreateTeam(teamId: team.id, teamCode: team.code);
      creating = false;
      notifyListeners();
      return team;
    } on AlreadyInTeamException catch (e) {
      creating = false;
      failure = AppFailure(
        'Already in a team',
        'You are already a member of team ${e.teamCode}. Leave your current team on My Team first.',
        code: 'already-in-team',
      );
      notifyListeners();
      return null;
    } catch (e, st) {
      creating = false;
      failure = await toFailure(e, st, crash: _crash, reason: 'create_team');
      notifyListeners();
      return null;
    }
  }
}

