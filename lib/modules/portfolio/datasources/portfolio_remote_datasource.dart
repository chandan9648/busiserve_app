import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/case_study_model.dart';

abstract class PortfolioRemoteDataSource {
  Future<List<CaseStudyModel>> fetchCaseStudies();
}

class FirestorePortfolioDataSource implements PortfolioRemoteDataSource {
  FirestorePortfolioDataSource([FirebaseFirestore? db]) : _db = db;
  final FirebaseFirestore? _db;

  @override
  Future<List<CaseStudyModel>> fetchCaseStudies() async {
    final snap = await (_db ?? FirebaseFirestore.instance)
        .collection('caseStudies')
        .where('published', isEqualTo: true)
        .orderBy('order')
        .get();
    return snap.docs.map((d) => CaseStudyModel.fromMap(d.data(), id: d.id)).toList();
  }
}
