import 'package:cloud_functions/cloud_functions.dart';

import '../../../core/config/app_env.dart';
import '../../../core/constants/app_limits.dart';
import '../models/deletion_request_model.dart';

abstract class PrivacyRemoteDataSource {
  Future<void> deleteAccount(DeletionRequest request);
}

class FirebasePrivacyDataSource implements PrivacyRemoteDataSource {
  FirebasePrivacyDataSource([FirebaseFunctions? functions]) : _functions = functions;
  final FirebaseFunctions? _functions;

  /// The function deletes the auth user and personal data, and anonymises
  /// business records that must be kept (see firebase/functions/src/account.ts).
  @override
  Future<void> deleteAccount(DeletionRequest request) async {
    final fn = (_functions ?? FirebaseFunctions.instanceFor(region: AppEnv.functionsRegion))
        .httpsCallable('deleteAccount', options: HttpsCallableOptions(timeout: AppLimits.requestTimeout * 3));
    await fn.call<Object?>(request.toPayload());
  }
}
