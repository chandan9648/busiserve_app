import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../auth/models/user_model.dart';

abstract class ProfileRemoteDataSource {
  Stream<UserModel?> watch(String uid);
  Future<void> update(UserModel profile);
}

class FirestoreProfileDataSource implements ProfileRemoteDataSource {
  FirestoreProfileDataSource({FirebaseFirestore? db, FirebaseAuth? auth}) : _db = db, _auth = auth;
  final FirebaseFirestore? _db;
  final FirebaseAuth? _auth;

  @override
  Stream<UserModel?> watch(String uid) => (_db ?? FirebaseFirestore.instance)
      .doc('users/$uid')
      .snapshots()
      .map((d) => d.exists ? UserModel.fromMap(d.data()!, uid: uid) : null);

  @override
  Future<void> update(UserModel profile) async {
    await (_db ?? FirebaseFirestore.instance).doc('users/${profile.uid}').set(
          {...profile.toEditableMap(), 'updatedAt': FieldValue.serverTimestamp()},
          SetOptions(merge: true),
        );
    await (_auth ?? FirebaseAuth.instance).currentUser?.updateDisplayName(profile.name.trim());
  }
}
