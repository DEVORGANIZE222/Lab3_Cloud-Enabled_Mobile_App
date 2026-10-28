import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_notification.dart';
import '../services/services.dart';

class FirebaseNotificationRepository implements NotificationRepository {
  FirebaseNotificationRepository([FirebaseFirestore? firestore]) : _db = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _db;
  CollectionReference<Map<String, dynamic>> _items(String uid) =>
      _db.collection('students').doc(uid).collection('notifications');
  AppNotification _from(DocumentSnapshot<Map<String, dynamic>> d) {
    final v = d.data()!;
    return AppNotification(
      id: d.id,
      kind: NotificationKind.values.byName(v['kind'] as String? ?? 'system'),
      title: v['title'] as String? ?? '',
      body: v['body'] as String? ?? '',
      createdAt: (v['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      read: v['read'] as bool? ?? false,
      teamId: v['teamId'] as String?,
      actionLabel: v['actionLabel'] as String?,
    );
  }

  Map<String, dynamic> _to(AppNotification n) => {
    'kind': n.kind.name,
    'title': n.title,
    'body': n.body,
    'createdAt': Timestamp.fromDate(n.createdAt),
    'read': n.read,
    'teamId': n.teamId,
    'actionLabel': n.actionLabel,
  };
  @override
  Stream<List<AppNotification>> watch(String studentId) =>
      _items(studentId).orderBy('createdAt', descending: true).snapshots().map((s) => s.docs.map(_from).toList());
  @override
  Future<void> markRead(String studentId, String notificationId) =>
      _items(studentId).doc(notificationId).update({'read': true});
  @override
  Future<void> markAllRead(String studentId) async {
    final b = _db.batch();
    for (final d in (await _items(studentId).where('read', isEqualTo: false).get()).docs) {
      b.update(d.reference, {'read': true});
    }
    await b.commit();
  }

  @override
  Future<void> remove(String studentId, String notificationId) => _items(studentId).doc(notificationId).delete();
  @override
  Future<void> restore(String studentId, AppNotification notification) =>
      _items(studentId).doc(notification.id).set(_to(notification));
}
