/// Model for Notification
class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type;
  final String? targetTeamId;
  final DateTime timestamp;
  final bool isRead;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.targetTeamId,
    required this.timestamp,
    this.isRead = false,
  });
}
