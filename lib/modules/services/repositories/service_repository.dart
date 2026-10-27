import '../../../core/errors/app_exception.dart';
import '../../../core/errors/error_handler.dart';
import '../datasources/service_local_datasource.dart';
import '../datasources/service_remote_datasource.dart';
import '../models/service_model.dart';

/// Remote catalogue first; the verified bundled catalogue if remote is
/// unavailable or empty. Public browsing therefore always works.
class ServiceRepository {
  ServiceRepository({required this.local, this.remote});

  final ServiceLocalDataSource local;
  final ServiceRemoteDataSource? remote;
  List<ServiceModel>? _cache;

  Future<List<ServiceModel>> getServices({bool refresh = false}) async {
    if (!refresh && _cache != null) return _cache!;
    List<ServiceModel>? items;
    if (remote != null) {
      try {
        final fetched = await remote!.fetchServices();
        if (fetched.isNotEmpty) items = fetched;
      } catch (e, st) {
        ErrorHandler.handle(e, st, context: 'services remote (falling back)');
      }
    }
    items ??= local.getServices();
    final sorted = [...items]..sort((a, b) => a.order.compareTo(b.order));
    return _cache = List.unmodifiable(sorted);
  }

  Future<ServiceModel> getService(String id) async {
    final all = await getServices();
    for (final s in all) {
      if (s.id == id) return s;
    }
    throw const NotFoundException('This service is no longer listed.');
  }
}
