import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/errors/app_exception.dart';
import '../models/deletion_request_model.dart';

abstract class PrivacyRemoteDataSource {
  Future<void> deleteAccount(DeletionRequest request);
}

class FirebasePrivacyDataSource implements PrivacyRemoteDataSource {
  FirebasePrivacyDataSource({FirebaseAuth? auth, FirebaseFirestore? db})
      : _auth = auth,
        _db = db;

  final FirebaseAuth? _auth;
  final FirebaseFirestore? _db;

  FirebaseAuth get _signIn => _auth ?? FirebaseAuth.instance;
  FirebaseFirestore get _store => _db ?? FirebaseFirestore.instance;

  static const int _batchSize = 300;

  /// Deletes the profile, its subcollections and the Auth user. The caller
  /// re-authenticates first, which is what lets `User.delete()` succeed.
  ///
  /// Business records (enquiries, quotations, projects, tickets) are retained
  /// and keep pointing at the deleted uid. Anonymising them needs the Admin
  /// SDK, so staff clear them from the console.
  @override
  Future<void> deleteAccount(DeletionRequest request) async {
    final user = _signIn.currentUser;
    if (user == null) {
      throw const AuthenticationException('Sign in again to delete your account.');
    }
    final profile = _store.doc('users/${user.uid}');

    for (final name in const ['devices', 'notifications']) {
      await _clear(profile.collection(name));
    }
    await profile.delete();
    // Last, so any failure above can be retried while still signed in.
    await user.delete();
  }

  Future<void> _clear(CollectionReference<Map<String, dynamic>> ref) async {
    while (true) {
      final page = await ref.limit(_batchSize).get();
      if (page.docs.isEmpty) return;
      final batch = _store.batch();
      for (final doc in page.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      if (page.docs.length < _batchSize) return;
    }
  }
}
