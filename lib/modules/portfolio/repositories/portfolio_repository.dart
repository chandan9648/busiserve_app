import '../../../core/errors/app_exception.dart';
import '../../../core/errors/error_handler.dart';
import '../datasources/portfolio_local_datasource.dart';
import '../datasources/portfolio_remote_datasource.dart';
import '../models/case_study_model.dart';

class PortfolioRepository {
  PortfolioRepository({required this.local, this.remote});

  final PortfolioLocalDataSource local;
  final PortfolioRemoteDataSource? remote;
  List<CaseStudyModel>? _cache;

  Future<List<CaseStudyModel>> getCaseStudies({bool refresh = false}) async {
    if (!refresh && _cache != null) return _cache!;
    List<CaseStudyModel>? items;
    if (remote != null) {
      try {
        final fetched = await remote!.fetchCaseStudies();
        if (fetched.isNotEmpty) items = fetched;
      } catch (e, st) {
        ErrorHandler.handle(e, st, context: 'case studies remote (falling back)');
      }
    }
    items ??= local.getCaseStudies();
    final sorted = [...items]..sort((a, b) => a.order.compareTo(b.order));
    return _cache = List.unmodifiable(sorted);
  }

  Future<CaseStudyModel> getCaseStudy(String id) async {
    for (final c in await getCaseStudies()) {
      if (c.id == id) return c;
    }
    throw const NotFoundException('This case study is no longer available.');
  }
}
