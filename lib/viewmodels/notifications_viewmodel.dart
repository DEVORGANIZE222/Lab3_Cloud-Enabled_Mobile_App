import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/app_notification.dart';
import '../models/student.dart';
import '../models/view_state.dart';
import '../services/services.dart';
import 'guard.dart';

enum AlertFilter { all, invites, system }

/// SCR_09: notifications and invites (also receives FCM messages once connected).
class NotificationsViewModel extends ChangeNotifier {
  NotificationsViewModel(this._student, this._repo, this._teams, this._crash);

  final Student _student;
  final NotificationRepository _repo;
  final TeamRepository _teams;
  final CrashReporter _crash;
  StreamSubscription<List<AppNotification>>? _sub;

  List<AppNotification> _all = const [];
  ViewState<List<AppNotification>> state = const Loading();
  AlertFilter filter = AlertFilter.all;

  int get unread => _all.where((n) => !n.read).length;
  int count(AlertFilter f) => _filtered(f).length;

  List<AppNotification> _filtered(AlertFilter f) => switch (f) {
    AlertFilter.all => _all,
    AlertFilter.invites => _all.where((n) => n.kind == NotificationKind.invite).toList(),
    AlertFilter.system => _all.where((n) => n.kind != NotificationKind.invite).toList(),
  };

  void start() {
    _sub?.cancel();
    state = const Loading();
    notifyListeners();
    _sub = _repo
        .watch(_student.id)
        .listen(
          (list) {
            _all = list;
            _publish();
          },
          onError: (Object e, StackTrace st) async {
            state = Failure(await toFailure(e, st, crash: _crash, reason: 'notifications_watch'));
            notifyListeners();
          },
        );
  }

  void _publish() {
    final list = _filtered(filter);
    state = list.isEmpty ? const Empty() : Data(list);
    notifyListeners();
  }

  void setFilter(AlertFilter f) {
    filter = f;
    _publish();
  }

  Future<void> open(AppNotification n) => _repo.markRead(_student.id, n.id);
  Future<void> markAllRead() => _repo.markAllRead(_student.id);

  /// Removes the invite; the screen offers Undo via [restore].
  Future<void> decline(AppNotification n) => _repo.remove(_student.id, n.id);
  Future<void> restore(AppNotification n) => _repo.restore(_student.id, n);

  /// Accepting an invite joins the team (same server checks as Flow 1).
  Future<AppFailure?> accept(AppNotification n) async {
    if (n.teamId == null) return null;
    try {
      await _teams.joinTeam(n.teamId!, _student);
      await _repo.remove(_student.id, n.id);
      return null;
    } on AlreadyInTeamException catch (e) {
      return AppFailure(
        "You're already in Team ${e.teamCode}",
        'Leave Team ${e.teamCode} on My Team first, then accept this invite.',
        retryable: false,
      );
    } on TeamFullException catch (e) {
      return AppFailure(
        'This team just filled up',
        '${e.teamCode} has no open slots left. Browse other teams instead.',
        retryable: false,
      );
    } catch (e, st) {
      return toFailure(e, st, crash: _crash, reason: 'accept_invite');
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
