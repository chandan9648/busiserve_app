import 'package:busiserve_app/core/errors/app_exception.dart';
import 'package:busiserve_app/modules/auth/models/user_model.dart';
import 'package:busiserve_app/modules/enquiry/models/enquiry_model.dart';
import 'package:busiserve_app/modules/enquiry/models/enquiry_subject.dart';
import 'package:busiserve_app/modules/notifications/models/notification_model.dart';
import 'package:busiserve_app/modules/portfolio/models/case_study_model.dart';
import 'package:busiserve_app/modules/projects/models/project_model.dart';
import 'package:busiserve_app/modules/quotations/models/quotation_model.dart';
import 'package:busiserve_app/modules/services/datasources/service_local_datasource.dart';
import 'package:busiserve_app/modules/services/models/service_model.dart';
import 'package:busiserve_app/modules/support/models/ticket_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ServiceModel', () {
    test('round-trips through a map', () {
      const s = ServiceModel(
        id: 'web-development',
        title: 'Web Development',
        summary: 's',
        focusAreas: ['A'],
        category: ServiceCategory.webAndApps,
        iconKey: 'web',
        order: 1,
      );
      final back = ServiceModel.fromMap(s.toMap());
      expect(back.id, s.id);
      expect(back.category, ServiceCategory.webAndApps);
      expect(back.websiteUrl, 'https://www.busiserve.in/services/web-development');
    });
    test('missing title throws DataParsingException', () {
      expect(() => ServiceModel.fromMap({'id': 'x'}), throwsA(isA<DataParsingException>()));
    });
    test('unknown category falls back safely', () {
      final s = ServiceModel.fromMap({'title': 'T', 'category': 'nonsense'}, id: 'x');
      expect(s.category, ServiceCategory.webAndApps);
      expect(s.order, 999);
    });
  });

  test('bundled catalogue matches the website (12 services, unique ids)', () {
    final items = const ServiceLocalDataSource().getServices();
    expect(items.length, 12);
    expect(items.map((s) => s.id).toSet().length, 12);
  });

  test('every service id is a valid enquiry subject', () {
    for (final s in const ServiceLocalDataSource().getServices()) {
      expect(EnquirySubject.byId(s.id), isNotNull, reason: s.id);
    }
    expect(EnquirySubject.all.length, 14);
  });

  group('EnquiryModel', () {
    test('parses Timestamp and status', () {
      final e = EnquiryModel.fromMap({
        'subject': 'app-development',
        'message': 'Need an app',
        'status': 'in_review',
        'createdAt': Timestamp.fromDate(DateTime.utc(2026, 1, 2)),
      }, id: '3b241101-e2bb-4255-8caf-4136c566a962',);
      expect(e.status, EnquiryStatus.inReview);
      expect(e.subjectLabel, 'Mobile App Development');
      expect(e.createdAt, DateTime.utc(2026, 1, 2));
      expect(e.reference, 'BS-3B241101');
    });
    test('request payload trims, lowercases and omits empties', () {
      const r = EnquiryRequest(
        idempotencyKey: 'k',
        name: ' Asha ',
        email: ' Asha@Example.COM ',
        subjectId: 'general',
        message: ' hello there ',
        phone: '  ',
      );
      final p = r.toPayload();
      expect(p['name'], 'Asha');
      expect(p['email'], 'asha@example.com');
      expect(p.containsKey('phone'), isFalse);
      expect(p.containsKey('customerId'), isFalse);
    });
  });

  group('QuotationModel', () {
    test('computes totals when missing', () {
      final q = QuotationModel.fromMap({
        'title': 'Website',
        'items': [
          {'description': 'Design', 'quantity': 1, 'unitPrice': 20000},
          {'description': 'Pages', 'quantity': 5, 'unitPrice': 3000},
        ],
        'tax': 6300,
      }, id: 'q1',);
      expect(q.subtotal, 35000);
      expect(q.total, 41300);
      expect(q.status, QuotationStatus.sent);
    });
    test('expiry', () {
      final q = QuotationModel.fromMap({'validUntil': DateTime(2026, 1, 1)}, id: 'q');
      expect(q.isExpiredAt(DateTime(2026, 2, 1)), isTrue);
    });
  });

  test('ProjectModel clamps progress', () {
    expect(ProjectModel.fromMap({'progress': 140}, id: 'p').progress, 100);
    expect(ProjectModel.fromMap({'progress': '45', 'status': 'in_progress'}, id: 'p').status, ProjectStatus.inProgress);
    expect(MilestoneModel.fromMap({'status': 'done'}, id: 'm').status, MilestoneStatus.done);
  });

  test('TicketModel and TicketMessage', () {
    final t = TicketModel.fromMap({'status': 'awaiting_customer', 'category': 'billing'}, id: 't');
    expect(t.status, TicketStatus.awaitingCustomer);
    expect(t.category, TicketCategory.billing);
    expect(TicketModel.fromMap({'status': 'closed'}, id: 't').status.acceptsReplies, isFalse);
    expect(TicketMessage.fromMap({'authorRole': 'staff', 'text': 'Hi'}, id: 'm').fromStaff, isTrue);
  });

  test('NotificationModel defaults', () {
    final n = NotificationModel.fromMap({'type': 'unknown'}, id: 'n');
    expect(n.type, NotificationType.general);
    expect(n.read, isFalse);
  });

  test('CaseStudyModel and UserModel', () {
    expect(CaseStudyModel.fromMap({'title': 'X'}, id: 'x').industry, 'Technology');
    expect(const UserModel(uid: 'u', name: 'Chandan Kumar', email: 'c@x.in').initials, 'CK');
    expect(const UserModel(uid: 'u', name: '', email: 'c@x.in').initials, 'C');
  });
}
