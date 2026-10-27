import 'package:busiserve_app/core/errors/app_exception.dart';
import 'package:busiserve_app/core/state/view_state.dart';
import 'package:busiserve_app/modules/services/controllers/services_controller.dart';
import 'package:busiserve_app/modules/services/datasources/service_local_datasource.dart';
import 'package:busiserve_app/modules/services/models/service_model.dart';
import 'package:busiserve_app/modules/services/repositories/service_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../helpers/fakes.dart';

void main() {
  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  group('ServiceRepository', () {
    test('uses remote catalogue when available', () async {
      final repo = ServiceRepository(local: const ServiceLocalDataSource(), remote: FakeServiceRemote(items: [sampleService]));
      final items = await repo.getServices();
      expect(items.single.id, 'remote-service');
    });

    test('falls back to bundled catalogue on remote error', () async {
      final repo = ServiceRepository(
        local: const ServiceLocalDataSource(),
        remote: FakeServiceRemote(error: const NetworkException()),
      );
      expect((await repo.getServices()).length, 12);
    });

    test('falls back when remote is empty, and caches', () async {
      final remote = FakeServiceRemote();
      final repo = ServiceRepository(local: const ServiceLocalDataSource(), remote: remote);
      await repo.getServices();
      await repo.getServices();
      expect(remote.calls, 1);
      await repo.getServices(refresh: true);
      expect(remote.calls, 2);
    });

    test('getService throws NotFound for unknown id', () async {
      final repo = ServiceRepository(local: const ServiceLocalDataSource());
      await expectLater(repo.getService('nope'), throwsA(isA<NotFoundException>()));
      expect((await repo.getService('app-development')).title, 'App Development');
    });
  });

  group('ServicesController', () {
    test('initial -> loading -> success, then filters', () async {
      final c = ServicesController(ServiceRepository(local: const ServiceLocalDataSource()));
      expect(c.state.value, isA<InitialState<List<ServiceModel>>>());
      Get.put(c);
      expect(c.state.value, isA<LoadingState<List<ServiceModel>>>());
      await Future<void>.delayed(Duration.zero);
      expect(c.state.value.dataOrNull!.length, 12);

      c.selectCategory(ServiceCategory.aiAutomation);
      await Future<void>.delayed(Duration.zero);
      expect(c.state.value.dataOrNull!.map((s) => s.id), ['ai-agent-development', 'automation-n8n']);

      c.search('zzz');
      await Future<void>.delayed(Duration.zero);
      expect(c.state.value, isA<EmptyState<List<ServiceModel>>>());
      expect(c.hasFilters, isTrue);

      c.clearFilters();
      await Future<void>.delayed(Duration.zero);
      expect(c.state.value.dataOrNull!.length, 12);
    });
  });
}
