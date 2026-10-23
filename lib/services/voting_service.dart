import '../models/vote_model.dart';

abstract class VotingService {
  Stream<List<VoteModel>> streamVotes(String teamId);
  Future<void> castVote({
    required String teamId,
    required String voterId,
    required String candidateId,
  });
}

class FirestoreVotingService implements VotingService {
  @override
  Stream<List<VoteModel>> streamVotes(String teamId) => const Stream.empty();

  @override
  Future<void> castVote({
    required String teamId,
    required String voterId,
    required String candidateId,
  }) async {}
}
