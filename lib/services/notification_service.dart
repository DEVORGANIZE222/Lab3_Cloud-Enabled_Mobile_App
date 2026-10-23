import '../models/notification_model.dart';

abstract class NotificationService {
  Future<void> requestPermission();
  Stream<List<NotificationModel>> get notificationsStream;
  Future<void> markAsRead(String notificationId);
}

class FirebaseNotificationService implements NotificationService {
  @override
  Future<void> requestPermission() async {}

  @override
  Stream<List<NotificationModel>> get notificationsStream => const Stream.empty();

  @override
  Future<void> markAsRead(String notificationId) async {}
}
