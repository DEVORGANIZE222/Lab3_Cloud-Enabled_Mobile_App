import 'package:flutter/foundation.dart';
import '../models/view_state.dart';
import '../models/team_model.dart';
import '../services/group_service.dart';

class DashboardViewModel extends ChangeNotifier {
  final GroupService groupService;
  final ViewState<TeamModel?> _state = const InitialState();

  DashboardViewModel({required this.groupService});

  ViewState<TeamModel?> get state => _state;

  Future<void> loadDashboardData(String? teamId) async {
    // TODO: Team implement loading current user team & countdown status
  }
}
