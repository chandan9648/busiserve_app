import '../../../core/utils/parsing.dart';
import '../../../core/constants/status_tone.dart';
import 'enquiry_subject.dart';

enum EnquiryStatus {
  received('Received', StatusTone.info),
  inReview('In review', StatusTone.warning),
  quoted('Quote sent', StatusTone.success),
  closed('Closed', StatusTone.neutral);

  const EnquiryStatus(this.label, this.tone);
  final String label;
  final StatusTone tone;

  static EnquiryStatus fromKey(String? key) => switch (key) {
        'in_review' => EnquiryStatus.inReview,
        'quoted' => EnquiryStatus.quoted,
        'closed' => EnquiryStatus.closed,
        _ => EnquiryStatus.received,
      };
}

/// An enquiry as stored in `enquiries/{idempotencyKey}` by the createEnquiry
/// Cloud Function.
class EnquiryModel {
  const EnquiryModel({
    required this.id,
    required this.subjectId,
    required this.message,
    required this.status,
    required this.createdAt,
    this.name,
    this.email,
  });

  factory EnquiryModel.fromMap(Map<String, dynamic> map, {required String id}) => EnquiryModel(
        id: id,
        subjectId: Parse.string(map, 'subject', 'general'),
        message: Parse.string(map, 'message'),
        status: EnquiryStatus.fromKey(Parse.optString(map, 'status')),
        createdAt: Parse.date(map, 'createdAt'),
        name: Parse.optString(map, 'name'),
        email: Parse.optString(map, 'email'),
      );

  final String id;
  final String subjectId;
  final String message;
  final EnquiryStatus status;
  final DateTime? createdAt;
  final String? name;
  final String? email;

  String get subjectLabel => EnquirySubject.labelFor(subjectId);

  /// Short reference shown to customers.
  String get reference => 'BS-${id.substring(0, id.length < 8 ? id.length : 8).toUpperCase()}';
}

/// What the app sends to `createEnquiry`.
class EnquiryRequest {
  const EnquiryRequest({
    required this.idempotencyKey,
    required this.name,
    required this.email,
    required this.subjectId,
    required this.message,
    this.phone,
    this.company,
  });

  final String idempotencyKey;
  final String name;
  final String email;
  final String subjectId;
  final String message;
  final String? phone;
  final String? company;

  Map<String, dynamic> toPayload() => {
        'idempotencyKey': idempotencyKey,
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'subject': subjectId,
        'message': message.trim(),
        if (phone != null && phone!.trim().isNotEmpty) 'phone': phone!.trim(),
        if (company != null && company!.trim().isNotEmpty) 'company': company!.trim(),
        'source': 'mobile_app',
      };
}

class EnquiryResult {
  const EnquiryResult({required this.enquiryId, required this.duplicate});

  factory EnquiryResult.fromMap(Map<String, dynamic> map) => EnquiryResult(
        enquiryId: Parse.requireString(map, 'enquiryId'),
        duplicate: Parse.boolean(map, 'duplicate'),
      );

  final String enquiryId;
  final bool duplicate;

  String get reference => 'BS-${enquiryId.substring(0, enquiryId.length < 8 ? enquiryId.length : 8).toUpperCase()}';
}
