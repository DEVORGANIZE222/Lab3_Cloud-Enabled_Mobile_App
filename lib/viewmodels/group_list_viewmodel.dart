import 'package:flutter/foundation.dart';
import '../models/view_state.dart';
import '../models/team_model.dart';
import '../services/group_service.dart';

class GroupListViewModel extends ChangeNotifier {
  final GroupService groupService;
  final ViewState<List<TeamModel>> _state = const InitialState();

  GroupListViewModel({required this.groupService});

  ViewState<List<TeamModel>> get state => _state;

  Future<void> searchGroups({String? query, String? tag}) async {
    // TODO: Team implement debounced search and filtering
  }
}
