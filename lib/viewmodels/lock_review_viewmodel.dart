import 'package:flutter/foundation.dart';
import '../models/view_state.dart';
import '../models/team_model.dart';
import '../services/group_service.dart';
import '../services/storage_service.dart';

class LockReviewViewModel extends ChangeNotifier {
  final GroupService groupService;
  final StorageService storageService;
  final ViewState<TeamModel> _state = const InitialState();

  LockReviewViewModel({
    required this.groupService,
    required this.storageService,
  });

  ViewState<TeamModel> get state => _state;

  Future<void> lockRoster(String teamId) async {
    // TODO: Team implement lock roster logic (Flow 3 Happy Path)
  }

  Future<void> broadcastToWaitingPool(String teamId) async {
    // TODO: Team implement recruitment broadcast (Flow 3 Recovery Path)
  }

  Future<void> generateAndUploadPdf(String teamId, String userId) async {
    // TODO: Team implement PDF generation & upload to Storage
  }
}
