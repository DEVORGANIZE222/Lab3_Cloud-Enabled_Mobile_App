/// Model for ExeMatching Startup Team
class TeamModel {
  final String id;
  final String name;
  final String topic;
  final String description;
  final List<String> tags;
  final String? leaderId;
  final List<String> memberIds;
  final int maxMembers;
  final bool isLocked;
  final String? confirmationCode;

  const TeamModel({
    required this.id,
    required this.name,
    required this.topic,
    this.description = '',
    this.tags = const [],
    this.leaderId,
    this.memberIds = const [],
    this.maxMembers = 5,
    this.isLocked = false,
    this.confirmationCode,
  });

  bool get isFull => memberIds.length >= maxMembers;
  bool get canLock => memberIds.length >= 4 && memberIds.length <= maxMembers;
}
