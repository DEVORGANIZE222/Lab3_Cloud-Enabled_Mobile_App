import 'package:flutter/foundation.dart';
import '../models/view_state.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationViewModel extends ChangeNotifier {
  final NotificationService notificationService;
  final ViewState<List<NotificationModel>> _state = const InitialState();

  NotificationViewModel({required this.notificationService});

  ViewState<List<NotificationModel>> get state => _state;

  Future<void> loadNotifications() async {
    // TODO: Team implement loading notifications
  }

  Future<void> markAsRead(String id) async {
    // TODO: Team implement marking notification as read
  }
}
