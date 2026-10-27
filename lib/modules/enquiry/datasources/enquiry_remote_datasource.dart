import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../../core/config/app_env.dart';
import '../../../core/constants/app_limits.dart';
import '../../../core/errors/app_exception.dart';
import '../models/enquiry_model.dart';

abstract class EnquiryRemoteDataSource {
  Future<EnquiryResult> create(EnquiryRequest request);
  Stream<List<EnquiryModel>> watchForCustomer(String uid);
}

class FirebaseEnquiryDataSource implements EnquiryRemoteDataSource {
  FirebaseEnquiryDataSource({FirebaseFunctions? functions, FirebaseFirestore? db})
      : _functions = functions,
        _db = db;

  final FirebaseFunctions? _functions;
  final FirebaseFirestore? _db;

  FirebaseFunctions get _fn => _functions ?? FirebaseFunctions.instanceFor(region: AppEnv.functionsRegion);
  FirebaseFirestore get _store => _db ?? FirebaseFirestore.instance;

  /// Enquiries are written only by the trusted function, which validates the
  /// payload and de-duplicates on `idempotencyKey`.
  @override
  Future<EnquiryResult> create(EnquiryRequest request) async {
    final callable = _fn.httpsCallable(
      'createEnquiry',
      options: HttpsCallableOptions(timeout: AppLimits.requestTimeout),
    );
    final res = await callable.call<Object?>(request.toPayload());
    final data = res.data;
    if (data is! Map) throw const DataParsingException(cause: 'createEnquiry returned no map');
    return EnquiryResult.fromMap(data.map((k, v) => MapEntry(k.toString(), v)));
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
