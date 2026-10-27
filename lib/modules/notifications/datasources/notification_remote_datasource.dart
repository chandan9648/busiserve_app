import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Stream<List<NotificationModel>> watch(String uid);
  Future<void> markRead(String uid, String id);
  Future<void> markAllRead(String uid, List<String> ids);
}

class FirestoreNotificationDataSource implements NotificationRemoteDataSource {
  FirestoreNotificationDataSource([FirebaseFirestore? db]) : _db = db;
  final FirebaseFirestore? _db;
  FirebaseFirestore get _store => _db ?? FirebaseFirestore.instance;

  @override
  Stream<List<NotificationModel>> watch(String uid) => _store
      .collection('users/$uid/notifications')
      .orderBy('createdAt', descending: true)
      .limit(100)
      .snapshots()
      .map((s) => s.docs.map((d) => NotificationModel.fromMap(d.data(), id: d.id)).toList());

  @override
  Future<void> markRead(String uid, String id) =>
      _store.doc('users/$uid/notifications/$id').update({'read': true});

  @override
  Future<void> markAllRead(String uid, List<String> ids) async {
    // Firestore batches allow 500 writes.
    for (var i = 0; i < ids.length; i += 450) {
      final batch = _store.batch();
      for (final id in ids.skip(i).take(450)) {
        batch.update(_store.doc('users/$uid/notifications/$id'), {'read': true});
      }
      await batch.commit();
    }
  }
}
