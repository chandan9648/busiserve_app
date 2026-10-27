import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/service_model.dart';

abstract class ServiceRemoteDataSource {
  Future<List<ServiceModel>> fetchServices();
}

/// Reads `services` documents with `published == true`, ordered by `order`.
/// Staff edit these through the console or an admin tool.
class FirestoreServiceDataSource implements ServiceRemoteDataSource {
  FirestoreServiceDataSource([FirebaseFirestore? db]) : _db = db;
  final FirebaseFirestore? _db;

  @override
  Future<List<ServiceModel>> fetchServices() async {
    final snap = await (_db ?? FirebaseFirestore.instance)
        .collection('services')
        .where('published', isEqualTo: true)
        .orderBy('order')
        .get();
    return snap.docs.map((d) => ServiceModel.fromMap(d.data(), id: d.id)).toList();
  }
}
