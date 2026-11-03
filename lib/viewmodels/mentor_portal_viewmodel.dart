import 'package:flutter/foundation.dart';

import '../models/mentor.dart';
import '../models/student.dart';
import '../models/team.dart';
import '../models/view_state.dart';
import '../services/services.dart';

class MentorPortalViewModel extends ChangeNotifier {
  MentorPortalViewModel(
    this.me,
    this._mentorRepository,
    this._crash,
    this._analytics,
  );

  final Student me;
  final MentorRepository _mentorRepository;
  final CrashReporter _crash;
  final AnalyticsService _analytics;

  ViewState<Mentor> _state = const Loading();
  ViewState<Mentor> get state => _state;

  List<MentorRequest> _requests = [];
  List<MentorRequest> get requests => _requests;
  List<MentorRequest> get pendingRequests =>
      _requests.where((r) => r.status == MentorRequestStatus.pending).toList();

  List<Team> _teams = [];
  List<Team> get teams => _teams;

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  String get mentorId => me.mentorId ?? me.id;

  Future<void> load() async {
    _state = const Loading();
    notifyListeners();

    try {
      final mentor = await _mentorRepository.getMentor(mentorId);
      _requests = await _mentorRepository.getRequestsForMentor(mentorId);
      _teams = await _mentorRepository.getTeamsForMentor(mentorId, mentor.fullName);
      _state = Data(mentor);
      await _analytics.logViewMentor(mentorId: mentor.id, mentorName: mentor.fullName);
    } catch (e, st) {
      await _crash.recordError(e, st, reason: 'Failed to load mentor portal data');
      if (e is AppFailure) {
        _state = Failure(e);
      } else {
        _state = Failure(AppFailure.unexpected(e));
      }
    }
    notifyListeners();
  }

  Future<AppFailure?> acceptRequest(MentorRequest request) async {
    _isProcessing = true;
    notifyListeners();

    try {
      await _mentorRepository.respondToRequest(
        requestId: request.id,
        accept: true,
      );
      await load();
      _isProcessing = false;
      notifyListeners();
      return null;
    } catch (e, st) {
      _isProcessing = false;
      await _crash.recordError(e, st, reason: 'Failed to accept mentor request');
      notifyListeners();
      if (e is AppFailure) return e;
      return AppFailure.unexpected(e);
    }
  }

  Future<AppFailure?> rejectRequest(MentorRequest request, String reason) async {
    _isProcessing = true;
    notifyListeners();

    try {
      await _mentorRepository.respondToRequest(
        requestId: request.id,
        accept: false,
        reason: reason,
      );
      await load();
      _isProcessing = false;
      notifyListeners();
      return null;
    } catch (e, st) {
      _isProcessing = false;
      await _crash.recordError(e, st, reason: 'Failed to reject mentor request');
      notifyListeners();
      if (e is AppFailure) return e;
      return AppFailure.unexpected(e);
    }
  }
}

