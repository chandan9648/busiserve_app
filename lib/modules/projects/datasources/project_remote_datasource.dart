import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/project_model.dart';

abstract class ProjectRemoteDataSource {
  Stream<List<ProjectModel>> watchForCustomer(String uid);
  Stream<ProjectModel?> watchById(String id);
  Stream<List<MilestoneModel>> watchMilestones(String projectId);
}

class FirestoreProjectDataSource implements ProjectRemoteDataSource {
  FirestoreProjectDataSource([FirebaseFirestore? db]) : _db = db;
  final FirebaseFirestore? _db;
  FirebaseFirestore get _store => _db ?? FirebaseFirestore.instance;

  @override
  Stream<List<ProjectModel>> watchForCustomer(String uid) => _store
      .collection('projects')
      .where('customerId', isEqualTo: uid)
      .orderBy('updatedAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => ProjectModel.fromMap(d.data(), id: d.id)).toList());

  @override
  Stream<ProjectModel?> watchById(String id) => _store
      .doc('projects/$id')
      .snapshots()
      .map((d) => d.exists ? ProjectModel.fromMap(d.data()!, id: d.id) : null);

  @override
  Stream<List<MilestoneModel>> watchMilestones(String projectId) => _store
      .collection('projects/$projectId/milestones')
      .orderBy('order')
      .snapshots()
      .map((s) => s.docs.map((d) => MilestoneModel.fromMap(d.data(), id: d.id)).toList());
}
