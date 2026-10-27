import 'dart:async';

import 'package:busiserve_app/core/errors/app_exception.dart';
import 'package:busiserve_app/core/services/auth_session.dart';
import 'package:busiserve_app/modules/enquiry/datasources/enquiry_remote_datasource.dart';
import 'package:busiserve_app/modules/enquiry/models/enquiry_model.dart';
import 'package:busiserve_app/modules/services/datasources/service_remote_datasource.dart';
import 'package:busiserve_app/modules/services/models/service_model.dart';
import 'package:get/get.dart';

class FakeAuthSession implements AuthSession {
  FakeAuthSession({String? uid, this.isAvailable = true, this.email, this.displayName}) {
    currentUid.value = uid;
  }

  @override
  final RxnString currentUid = RxnString();
  @override
  final bool isAvailable;
  @override
  final String? email;
  @override
  final String? displayName;

  @override
  bool get isLoggedIn => currentUid.value != null;
  @override
  String? get uid => currentUid.value;
  @override
  bool get isEmailVerified => true;
  @override
  String requireUid() {
    final id = uid;
    if (id == null) throw const AuthenticationException('Sign in to continue.', code: 'unauthenticated');
    return id;
  }
}

class FakeServiceRemote implements ServiceRemoteDataSource {
  FakeServiceRemote({this.items = const [], this.error});
  final List<ServiceModel> items;
  final Object? error;
  int calls = 0;

  @override
  Future<List<ServiceModel>> fetchServices() async {
    calls++;
    if (error != null) throw error!;
    return items;
  }
}

/// Records every submission; can fail a set number of times first.
class FakeEnquiryRemote implements EnquiryRemoteDataSource {
  FakeEnquiryRemote({this.failuresBeforeSuccess = 0, this.failure = const NetworkException(), this.delay});
  int failuresBeforeSuccess;
  final AppException failure;
  final Duration? delay;
  final List<EnquiryRequest> requests = [];

  @override
  Future<EnquiryResult> create(EnquiryRequest request) async {
    requests.add(request);
    if (delay != null) await Future<void>.delayed(delay!);
    if (failuresBeforeSuccess > 0) {
      failuresBeforeSuccess--;
      throw failure;
    }
    return EnquiryResult(enquiryId: request.idempotencyKey, duplicate: false);
  }

  @override
  Stream<List<EnquiryModel>> watchForCustomer(String uid) => Stream.value(const []);
}

const sampleService = ServiceModel(
  id: 'remote-service',
  title: 'Remote Service',
  summary: 'From Firestore.',
  focusAreas: ['One'],
  category: ServiceCategory.webAndApps,
  iconKey: 'web',
  order: 1,
);
