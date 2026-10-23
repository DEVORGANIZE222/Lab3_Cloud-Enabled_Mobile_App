import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/team.dart';
import '../models/view_state.dart';
import '../services/services.dart';
import 'guard.dart';

/// SCR_03: search, filter chips, result list (limit from Remote Config).
class BrowseViewModel extends ChangeNotifier {
  BrowseViewModel(this._teams, this._config, this._analytics, this._crash) {
    _configSub = _config.changes.listen((_) => search());
  }

  final TeamRepository _teams;
  final ConfigService _config;
  final AnalyticsService _analytics;
  final CrashReporter _crash;
  late final StreamSubscription<void> _configSub;

  ViewState<List<Team>> state = const Loading();
  String query = '';
  final Set<TeamFilter> filters = {TeamFilter.openSlots};
  int _requestId = 0;

  int get maxResults => _config.getInt(ConfigKeys.browseMaxResults);
  bool get hasCriteria => query.isNotEmpty || filters.length != 1 || !filters.contains(TeamFilter.openSlots);

  Future<void> search([String? newQuery]) async {
    if (newQuery != null) query = newQuery.trim();
    final id = ++_requestId;
    state = const Loading();
    notifyListeners();
    try {
      final result = await _teams.searchTeams(query: query, filters: filters, limit: maxResults);
      if (id != _requestId) return; // a newer search started
      state = result.isEmpty ? const Empty() : Data(result);
      await _analytics.logSearch(term: query, resultCount: result.length, filters: [for (final f in filters) f.name]);
    } catch (e, st) {
      if (id != _requestId) return;
      state = Failure(await toFailure(e, st, crash: _crash, reason: 'browse_search'));
    }
    notifyListeners();
  }

  void toggleFilter(TeamFilter filter, bool on) {
    on ? filters.add(filter) : filters.remove(filter);
    search();
  }

  void clearCriteria() {
    query = '';
    filters
      ..clear()
      ..add(TeamFilter.openSlots);
    search();
  }

  @override
  void dispose() {
    _configSub.cancel();
    super.dispose();
  }
}
