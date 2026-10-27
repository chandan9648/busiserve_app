import '../../../core/errors/app_exception.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/services/auth_session.dart';
import '../datasources/quotation_remote_datasource.dart';
import '../models/quotation_model.dart';

class QuotationRepository {
  QuotationRepository({required QuotationRemoteDataSource remote, required AuthSession session})
      : _remote = remote,
        _session = session;

  final QuotationRemoteDataSource _remote;
  final AuthSession _session;

  Stream<List<QuotationModel>> watchMine() =>
      guardStream(_remote.watchForCustomer(_session.requireUid()), context: 'watch quotations');

  Stream<QuotationModel> watch(String id) {
    _session.requireUid();
    return guardStream(
      _remote.watchById(id).map((q) => q ?? (throw const NotFoundException('This quotation is no longer available.'))),
      context: 'watch quotation',
    );
  }
}
