import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/ticket_model.dart';

abstract class SupportRemoteDataSource {
  String newTicketId();
  String newMessageId(String ticketId);
  Stream<List<TicketModel>> watchForCustomer(String uid);
  Stream<TicketModel?> watchById(String id);
  Stream<List<TicketMessage>> watchMessages(String ticketId);
  Future<void> createTicket(String uid, String authorName, NewTicket ticket);
  Future<void> sendMessage({
    required String uid,
    required String authorName,
    required String ticketId,
    required String messageId,
    required String text,
  });
}

class FirestoreSupportDataSource implements SupportRemoteDataSource {
  FirestoreSupportDataSource([FirebaseFirestore? db]) : _db = db;
  final FirebaseFirestore? _db;
  FirebaseFirestore get _store => _db ?? FirebaseFirestore.instance;

  @override
  String newTicketId() => _store.collection('tickets').doc().id;

  @override
  String newMessageId(String ticketId) => _store.collection('tickets/$ticketId/messages').doc().id;

  @override
  Stream<List<TicketModel>> watchForCustomer(String uid) => _store
      .collection('tickets')
      .where('customerId', isEqualTo: uid)
      .orderBy('updatedAt', descending: true)
      .limit(50)
      .snapshots()
      .map((s) => s.docs.map((d) => TicketModel.fromMap(d.data(), id: d.id)).toList());

  @override
  Stream<TicketModel?> watchById(String id) => _store
      .doc('tickets/$id')
      .snapshots()
      .map((d) => d.exists ? TicketModel.fromMap(d.data()!, id: d.id) : null);

  @override
  Stream<List<TicketMessage>> watchMessages(String ticketId) => _store
      .collection('tickets/$ticketId/messages')
      .orderBy('createdAt')
      .limit(200)
      .snapshots()
      .map((s) => s.docs.map((d) => TicketMessage.fromMap(d.data(), id: d.id)).toList());

  /// Writes the ticket and its first message atomically. If a previous
  /// attempt with the same id already succeeded, does nothing.
  @override
  Future<void> createTicket(String uid, String authorName, NewTicket t) async {
    final ref = _store.doc('tickets/${t.id}');
    final existing = await ref.get();
    if (existing.exists) return;
    final batch = _store.batch()
      ..set(ref, {
        'customerId': uid,
        'subject': t.subject.trim(),
        'category': t.category.name,
        'status': 'open',
        if (t.relatedId != null) 'relatedId': t.relatedId,
        'lastMessage': t.message.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      })
      ..set(ref.collection('messages').doc(), {
        'authorId': uid,
        'authorRole': 'customer',
        'authorName': authorName,
        'text': t.message.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    await batch.commit();
  }

  @override
  Future<void> sendMessage({
    required String uid,
    required String authorName,
    required String ticketId,
    required String messageId,
    required String text,
  }) async {
    final ticket = _store.doc('tickets/$ticketId');
    final batch = _store.batch()
      ..set(ticket.collection('messages').doc(messageId), {
        'authorId': uid,
        'authorRole': 'customer',
        'authorName': authorName,
        'text': text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      })
      ..update(ticket, {
        'lastMessage': text.trim(),
        'status': 'open',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    await batch.commit();
  }
}
