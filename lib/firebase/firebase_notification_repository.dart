import '../models/app_notification.dart';
import '../services/services.dart';

/// Cloud Firestore implementation of NotificationRepository.
class FirebaseNotificationRepository implements NotificationRepository {
  @override
  Stream<List<AppNotification>> watch(String studentId) {
    // TODO: Firestore snapshots on notifications for studentId
    return const Stream.empty();
  }

  @override
  Future<void> markRead(String studentId, String notificationId) async {
    // TODO: update read = true
  }

  @override
  Future<void> markAllRead(String studentId) async {
    // TODO: batch update read = true
  }

  @override
  Future<void> remove(String studentId, String notificationId) async {
    // TODO: delete doc
  }

  @override
  Future<void> restore(String studentId, AppNotification notification) async {
    // TODO: re-add doc
  }
}
