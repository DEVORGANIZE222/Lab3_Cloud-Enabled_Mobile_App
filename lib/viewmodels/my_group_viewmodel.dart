import 'package:flutter/foundation.dart';
import '../models/view_state.dart';
import '../models/team_model.dart';
import '../services/group_service.dart';

class MyGroupViewModel extends ChangeNotifier {
  final GroupService groupService;
  final ViewState<TeamModel?> _state = const InitialState();

  MyGroupViewModel({required this.groupService});

  ViewState<TeamModel?> get state => _state;

  Future<void> loadMyGroup(String? teamId) async {
    // TODO: Team implement loading current user group & member roles
  }

  Future<void> leaveGroup(String teamId, String userId) async {
    // TODO: Team implement leave group logic
  }
}
