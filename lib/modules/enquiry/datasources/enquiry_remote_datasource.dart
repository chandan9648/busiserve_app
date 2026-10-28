import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/services/rate_limits.dart';
import '../models/enquiry_model.dart';

abstract class EnquiryRemoteDataSource {
  Future<EnquiryResult> create(EnquiryRequest request);
  Stream<List<EnquiryModel>> watchForCustomer(String uid);
}

class FirebaseEnquiryDataSource implements EnquiryRemoteDataSource {
  FirebaseEnquiryDataSource({FirebaseAuth? auth, FirebaseFirestore? db})
      : _auth = auth,
        _db = db;

  final FirebaseAuth? _auth;
  final FirebaseFirestore? _db;

  FirebaseAuth get _signIn => _auth ?? FirebaseAuth.instance;
  FirebaseFirestore get _store => _db ?? FirebaseFirestore.instance;

  /// Writes the enquiry straight to Firestore, where the security rules
  /// validate every field. The document id is the idempotency key, so a
  /// retried submit collides with the first write instead of duplicating it.
  @override
  Future<EnquiryResult> create(EnquiryRequest request) async {
    final uid = _signIn.currentUser?.uid;
    if (uid == null) {
      throw const AuthenticationException('Sign in to send an enquiry.');
    }
    final ref = _store.collection('enquiries').doc(request.idempotencyKey);

    if ((await ref.get()).exists) {
      return EnquiryResult(enquiryId: ref.id, duplicate: true);
    }
    final batch = _store.batch();
    await RateLimits.spend(_store, batch, uid: uid, limit: RateLimit.enquiry, docId: ref.id);
    batch.set(ref, {
      ...request.toPayload(),
      'customerId': uid,
      'status': 'received',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    try {
      await batch.commit();
    } on FirebaseException catch (e) {
      // Rules allow create but not update, so a racing second submit lands
      // here rather than overwriting the enquiry already on record.
      if (e.code == 'permission-denied' && (await ref.get()).exists) {
        return EnquiryResult(enquiryId: ref.id, duplicate: true);
      }
      rethrow;
    }
    return EnquiryResult(enquiryId: ref.id, duplicate: false);
  }

  @override
  Stream<List<EnquiryModel>> watchForCustomer(String uid) => _store
      .collection('enquiries')
      .where('customerId', isEqualTo: uid)
      .orderBy('createdAt', descending: true)
      .limit(50)
      .snapshots()
      .map((s) => s.docs.map((d) => EnquiryModel.fromMap(d.data(), id: d.id)).toList());
}
