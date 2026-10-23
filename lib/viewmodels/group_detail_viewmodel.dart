import 'package:flutter/foundation.dart';
import '../models/view_state.dart';
import '../models/team_model.dart';
import '../services/group_service.dart';

class GroupDetailViewModel extends ChangeNotifier {
  final GroupService groupService;
  final ViewState<TeamModel> _state = const InitialState();

  GroupDetailViewModel({required this.groupService});

  ViewState<TeamModel> get state => _state;

  Future<void> loadGroupDetails(String teamId) async {
    // TODO: Team implement loading group details
  }

  Future<void> requestToJoin(String teamId, String userId) async {
    // TODO: Team implement join request & error handling if full (5/5)
  }
}
