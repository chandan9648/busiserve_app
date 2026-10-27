import '../../../core/utils/parsing.dart';
import '../../../core/constants/status_tone.dart';

enum TicketCategory {
  general('General question'),
  project('Ongoing project'),
  quotation('Quotation'),
  billing('Billing and payments'),
  technical('Technical issue');

  const TicketCategory(this.label);
  final String label;

  static TicketCategory fromKey(String? key) =>
      TicketCategory.values.firstWhere((c) => c.name == key, orElse: () => TicketCategory.general);
}

enum TicketStatus {
  open('Open', StatusTone.info),
  awaitingCustomer('Needs your reply', StatusTone.warning),
  resolved('Resolved', StatusTone.success),
  closed('Closed', StatusTone.neutral);

  const TicketStatus(this.label, this.tone);
  final String label;
  final StatusTone tone;

  bool get acceptsReplies => this != TicketStatus.closed;

  static TicketStatus fromKey(String? key) => switch (key) {
        'awaiting_customer' => TicketStatus.awaitingCustomer,
        'resolved' => TicketStatus.resolved,
        'closed' => TicketStatus.closed,
        _ => TicketStatus.open,
      };
}

/// `tickets/{id}`
class TicketModel {
  const TicketModel({
    required this.id,
    required this.subject,
    required this.category,
    required this.status,
    this.lastMessage,
    this.relatedId,
    this.createdAt,
    this.updatedAt,
  });

  factory TicketModel.fromMap(Map<String, dynamic> map, {required String id}) => TicketModel(
        id: id,
        subject: Parse.string(map, 'subject', 'Support request'),
        category: TicketCategory.fromKey(Parse.optString(map, 'category')),
        status: TicketStatus.fromKey(Parse.optString(map, 'status')),
        lastMessage: Parse.optString(map, 'lastMessage'),
        relatedId: Parse.optString(map, 'relatedId'),
        createdAt: Parse.date(map, 'createdAt'),
        updatedAt: Parse.date(map, 'updatedAt'),
      );

  final String id;
  final String subject;
  final TicketCategory category;
  final TicketStatus status;
  final String? lastMessage;
  final String? relatedId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}

/// `tickets/{id}/messages/{messageId}`
class TicketMessage {
  const TicketMessage({
    required this.id,
    required this.text,
    required this.fromStaff,
    this.authorName,
    this.createdAt,
  });

  factory TicketMessage.fromMap(Map<String, dynamic> map, {required String id}) => TicketMessage(
        id: id,
        text: Parse.string(map, 'text'),
        fromStaff: Parse.string(map, 'authorRole') == 'staff',
        authorName: Parse.optString(map, 'authorName'),
        createdAt: Parse.date(map, 'createdAt'),
      );

  final String id;
  final String text;
  final bool fromStaff;
  final String? authorName;

  /// Null while the server timestamp is pending (message just sent).
  final DateTime? createdAt;
}

class NewTicket {
  const NewTicket({
    required this.id,
    required this.subject,
    required this.category,
    required this.message,
    this.relatedId,
  });

  /// Generated once per form so a retried submit cannot create a duplicate.
  final String id;
  final String subject;
  final TicketCategory category;
  final String message;
  final String? relatedId;
}
