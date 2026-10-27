import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/quotation_model.dart';

abstract class QuotationRemoteDataSource {
  Stream<List<QuotationModel>> watchForCustomer(String uid);
  Stream<QuotationModel?> watchById(String id);
}

class FirestoreQuotationDataSource implements QuotationRemoteDataSource {
  FirestoreQuotationDataSource([FirebaseFirestore? db]) : _db = db;
  final FirebaseFirestore? _db;
  FirebaseFirestore get _store => _db ?? FirebaseFirestore.instance;

  @override
  Stream<List<QuotationModel>> watchForCustomer(String uid) => _store
      .collection('quotations')
      .where('customerId', isEqualTo: uid)
      .orderBy('createdAt', descending: true)
      .limit(50)
      .snapshots()
      .map((s) => s.docs.map((d) => QuotationModel.fromMap(d.data(), id: d.id)).toList());

  @override
  Stream<QuotationModel?> watchById(String id) => _store
      .doc('quotations/$id')
      .snapshots()
      .map((d) => d.exists ? QuotationModel.fromMap(d.data()!, id: d.id) : null);
}
