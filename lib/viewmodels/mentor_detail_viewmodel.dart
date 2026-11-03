import 'package:flutter/foundation.dart';

import '../models/mentor.dart';
import '../models/student.dart';
import '../models/team.dart';
import '../models/view_state.dart';
import '../services/services.dart';

class MentorDetailViewModel extends ChangeNotifier {
  MentorDetailViewModel(
    this.mentorId,
    this.me,
    this._mentorRepository,
    this._teamRepository,
    this._analytics,
    this._crash,
  );

  final String mentorId;
  final Student me;
  final MentorRepository _mentorRepository;
  final TeamRepository _teamRepository;
  final AnalyticsService _analytics;
  final CrashReporter _crash;

  ViewState<Mentor> _state = const Loading();
  ViewState<Mentor> get state => _state;

  Team? _myTeam;
  Team? get myTeam => _myTeam;

  List<MentorRequest> _teamRequests = [];
  List<MentorRequest> get teamRequests => _teamRequests;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  bool _isCancelling = false;
  bool get isCancelling => _isCancelling;

  bool get hasTeam => _myTeam != null;
  bool get isLeader => _myTeam != null && _myTeam!.leaderId == me.id;

  bool isAssignedMentor(Mentor mentor) {
    if (_myTeam == null) return false;
    final sup = _myTeam!.supervisor.toLowerCase();
    return sup.contains(mentor.fullName.toLowerCase()) ||
        mentor.mentoredTeamNames.any((n) => n.toLowerCase() == _myTeam!.name.toLowerCase());
  }

  MentorRequest? get existingPendingRequest {
    return _teamRequests
        .where((r) => r.mentorId == mentorId && r.status == MentorRequestStatus.pending)
        .firstOrNull;
  }

  Future<void> load() async {
    _state = const Loading();
    notifyListeners();

    try {
      final mentor = await _mentorRepository.getMentor(mentorId);
      _myTeam = await _teamRepository.teamOf(me.id);

      if (_myTeam != null) {
        _teamRequests = await _mentorRepository.getRequestsForTeam(_myTeam!.id);
      } else {
        _teamRequests = [];
      }

      _state = Data(mentor);
      await _analytics.logViewMentor(mentorId: mentor.id, mentorName: mentor.fullName);
    } catch (e, st) {
      await _crash.recordError(e, st, reason: 'Failed to load mentor details');
      if (e is AppFailure) {
        _state = Failure(e);
      } else {
        _state = Failure(AppFailure.unexpected(e));
      }
    }
    notifyListeners();
  }

  Future<AppFailure?> sendRequest(String message) async {
    if (_myTeam == null) {
      return const AppFailure(
        'No team found',
        'You must join or create a Capstone team before requesting a mentor.',
        retryable: false,
      );
    }

    final mentor = switch (_state) {
      Data<Mentor>(:final value) => value,
      _ => null,
    };

    if (mentor == null) {
      return const AppFailure('Mentor not loaded', 'Please wait for the profile to load.');
    }

    if (!mentor.isAvailable) {
      return AppFailure(
        'Mentor capacity reached',
        '${mentor.fullName} already has ${mentor.maxQuota} teams.',
        retryable: false,
      );
    }

    _isSubmitting = true;
    notifyListeners();

    try {
      await _mentorRepository.requestMentor(
        teamId: _myTeam!.id,
        teamName: _myTeam!.name,
        mentorId: mentor.id,
        mentorName: mentor.fullName,
        sender: me,
        message: message.trim(),
      );

      await _analytics.logRequestMentor(teamId: _myTeam!.id, mentorId: mentor.id);

      _teamRequests = await _mentorRepository.getRequestsForTeam(_myTeam!.id);
      _isSubmitting = false;
      notifyListeners();
      return null;
    } catch (e, st) {
      _isSubmitting = false;
      await _crash.recordError(e, st, reason: 'Failed to send mentor request');
      notifyListeners();
      if (e is AppFailure) return e;
      return AppFailure.unexpected(e);
    }
  }

  Future<AppFailure?> cancelRequest(String requestId) async {
    _isCancelling = true;
    notifyListeners();

    try {
      await _mentorRepository.cancelRequest(requestId);
      if (_myTeam != null) {
        _teamRequests = await _mentorRepository.getRequestsForTeam(_myTeam!.id);
      }
      _isCancelling = false;
      notifyListeners();
      return null;
    } catch (e, st) {
      _isCancelling = false;
      await _crash.recordError(e, st, reason: 'Failed to cancel mentor request');
      notifyListeners();
      if (e is AppFailure) return e;
      return AppFailure.unexpected(e);
    }
  }
}
