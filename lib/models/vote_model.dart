/// Model for Leader Vote
class VoteModel {
  final String id;
  final String teamId;
  final String voterId;
  final String candidateId;
  final DateTime timestamp;

  const VoteModel({
    required this.id,
    required this.teamId,
    required this.voterId,
    required this.candidateId,
    required this.timestamp,
  });
}
