import 'package:get/get.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/errors/failure.dart';
import '../../../core/state/view_state.dart';
import '../../../routes/app_routes.dart';
import '../models/service_model.dart';
import '../repositories/service_repository.dart';

class ServicesController extends GetxController {
  ServicesController(this._repository);
  final ServiceRepository _repository;

  final state = Rx<ViewState<List<ServiceModel>>>(const InitialState());
  final selectedCategory = Rxn<ServiceCategory>();
  final query = ''.obs;
  List<ServiceModel> _all = const [];
  bool _loaded = false;
  Worker? _filterWorker;

  bool get hasFilters => selectedCategory.value != null || query.value.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    load();
    _filterWorker = everAll([selectedCategory, query], (_) => _applyFilter());
  }

  @override
  void onClose() {
    _filterWorker?.dispose();
    super.onClose();
  }

  void clearFilters() {
    selectedCategory.value = null;
    query.value = '';
  }

  Future<void> load({bool refresh = false}) async {
    if (state.value.isLoading) return;
    state.value = const LoadingState();
    try {
      _all = await _repository.getServices(refresh: refresh);
      _loaded = true;
      _applyFilter();
    } on AppException catch (e) {
      state.value = ErrorState(Failure.fromException(e));
    }
  }

  void selectCategory(ServiceCategory? category) =>
      selectedCategory.value = selectedCategory.value == category ? null : category;

  void search(String value) => query.value = value.trim().toLowerCase();

  void _applyFilter() {
    if (!_loaded) return;
    final cat = selectedCategory.value;
    final q = query.value;
    final filtered = _all.where((s) {
      final matchesCat = cat == null || s.category == cat;
      final matchesQuery = q.isEmpty ||
          s.title.toLowerCase().contains(q) ||
          s.focusAreas.any((f) => f.toLowerCase().contains(q));
      return matchesCat && matchesQuery;
    }).toList();
    state.value = listState(filtered);
  }

  List<ServiceModel> get all => _all;

  void open(ServiceModel s) => Get.toNamed(Routes.serviceDetailPath(s.id));
}
