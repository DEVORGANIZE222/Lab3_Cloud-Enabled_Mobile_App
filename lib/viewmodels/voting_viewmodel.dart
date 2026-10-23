import 'package:flutter/foundation.dart';
import '../models/view_state.dart';
import '../models/vote_model.dart';
import '../services/voting_service.dart';

class VotingViewModel extends ChangeNotifier {
  final VotingService votingService;
  final ViewState<List<VoteModel>> _state = const InitialState();
  String? _selectedCandidateId;

  VotingViewModel({required this.votingService});

  ViewState<List<VoteModel>> get state => _state;
  String? get selectedCandidateId => _selectedCandidateId;

  void selectCandidate(String candidateId) {
    _selectedCandidateId = candidateId;
    notifyListeners();
  }

  Future<void> submitVote(String teamId, String voterId) async {
    // TODO: Team implement voting submission & leader threshold check
  }
}
