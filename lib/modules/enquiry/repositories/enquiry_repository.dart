import '../../../core/errors/app_exception.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/services/auth_session.dart';
import '../datasources/enquiry_remote_datasource.dart';
import '../models/enquiry_model.dart';

class EnquiryRepository {
  EnquiryRepository({required EnquiryRemoteDataSource remote, required AuthSession session})
      : _remote = remote,
        _session = session;

  final EnquiryRemoteDataSource _remote;
  final AuthSession _session;

  /// Safe to call again with the same request after a network failure: the
  /// backend returns the original enquiry instead of creating another.
  Future<EnquiryResult> submit(EnquiryRequest request) async {
    if (!_session.isAvailable) {
      throw const ConfigurationException(
        'Online enquiries are not available yet. Email or call us instead.',
      );
    }
    return guard(() => _remote.create(request), context: 'createEnquiry');
  }

  Stream<List<EnquiryModel>> watchMine() {
    final uid = _session.requireUid();
    return guardStream(_remote.watchForCustomer(uid), context: 'watch enquiries');
  }
}
