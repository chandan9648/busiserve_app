import 'package:busiserve_app/core/errors/app_exception.dart';
import 'package:busiserve_app/modules/enquiry/models/enquiry_model.dart';
import 'package:busiserve_app/modules/enquiry/repositories/enquiry_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

void main() {
  const request = EnquiryRequest(
    idempotencyKey: '3b241101-e2bb-4255-8caf-4136c566a962',
    name: 'Asha',
    email: 'asha@example.com',
    subjectId: 'general',
    message: 'Hello, we need a website.',
  );

  test('reports configuration error when Firebase is unavailable', () async {
    final repo = EnquiryRepository(remote: FakeEnquiryRemote(), session: FakeAuthSession(isAvailable: false));
    await expectLater(repo.submit(request), throwsA(isA<ConfigurationException>()));
  });

  test('maps remote failures to AppException', () async {
    final repo = EnquiryRepository(
      remote: FakeEnquiryRemote(failuresBeforeSuccess: 1, failure: const RequestTimeoutException()),
      session: FakeAuthSession(),
    );
    await expectLater(repo.submit(request), throwsA(isA<RequestTimeoutException>()));
    expect((await repo.submit(request)).enquiryId, request.idempotencyKey);
  });

  test('watchMine requires sign-in', () {
    final repo = EnquiryRepository(remote: FakeEnquiryRemote(), session: FakeAuthSession());
    expect(repo.watchMine, throwsA(isA<AuthenticationException>()));
  });
}
