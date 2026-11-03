import 'package:flutter/foundation.dart';

import '../models/mentor.dart';
import '../models/view_state.dart';
import '../services/services.dart';

class MentorListViewModel extends ChangeNotifier {
  MentorListViewModel(this._repository, this._analytics, this._crash);

  final MentorRepository _repository;
  final AnalyticsService _analytics;
  final CrashReporter _crash;

  ViewState<List<Mentor>> _state = const Loading();
  ViewState<List<Mentor>> get state => _state;

  String _query = '';
  String get query => _query;

  String? _selectedExpertise;
  String? get selectedExpertise => _selectedExpertise;

  bool _availableOnly = false;
  bool get availableOnly => _availableOnly;

  final List<String> availableExpertises = const [
    'All',
    'AI/ML',
    'Web/Cloud',
    'Mobile',
    'Cybersecurity',
  ];

  Future<void> load() async {
    _state = const Loading();
    notifyListeners();
    await _fetch();
  }

  Future<void> search(String q) async {
    _query = q;
    await _fetch();
  }

  Future<void> setExpertise(String? expertise) async {
    _selectedExpertise = (expertise == null || expertise == 'All') ? null : expertise;
    await _fetch();
  }

  Future<void> toggleAvailableOnly() async {
    _availableOnly = !_availableOnly;
    await _fetch();
  }

  Future<void> _fetch() async {
    try {
      final list = await _repository.searchMentors(
        query: _query,
        expertise: _selectedExpertise,
        availableOnly: _availableOnly,
      );
      if (list.isEmpty) {
        _state = const Empty();
      } else {
        _state = Data(list);
      }
      if (_query.isNotEmpty) {
        await _analytics.logSearch(
          term: _query,
          resultCount: list.length,
          filters: [_selectedExpertise ?? 'All'],
        );
      }
    } catch (e, st) {
      await _crash.recordError(e, st, reason: 'Failed to search mentors');
      if (e is AppFailure) {
        _state = Failure(e);
      } else {
        _state = Failure(AppFailure.unexpected(e));
      }
    }
    notifyListeners();
  }
}
