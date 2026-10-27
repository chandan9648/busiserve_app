import '../../../core/utils/parsing.dart';
import '../../../core/constants/status_tone.dart';

enum QuotationStatus {
  sent('Awaiting your reply', StatusTone.info),
  accepted('Accepted', StatusTone.success),
  declined('Declined', StatusTone.danger),
  revised('Revised', StatusTone.warning),
  expired('Expired', StatusTone.neutral);

  const QuotationStatus(this.label, this.tone);
  final String label;
  final StatusTone tone;

  static QuotationStatus fromKey(String? key) => QuotationStatus.values
      .firstWhere((s) => s.name == key, orElse: () => QuotationStatus.sent);
}

class QuotationItem {
  const QuotationItem({required this.description, required this.quantity, required this.unitPrice});

  factory QuotationItem.fromMap(Map<String, dynamic> map) => QuotationItem(
        description: Parse.string(map, 'description'),
        quantity: Parse.number(map, 'quantity', 1),
        unitPrice: Parse.number(map, 'unitPrice'),
      );

  final String description;
  final double quantity;
  final double unitPrice;
  double get amount => quantity * unitPrice;
}

/// `quotations/{id}` — written by staff only, readable by the customer.
class QuotationModel {
  const QuotationModel({
    required this.id,
    required this.title,
    required this.status,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.currency,
    this.enquiryId,
    this.notes,
    this.validUntil,
    this.createdAt,
  });

  factory QuotationModel.fromMap(Map<String, dynamic> map, {required String id}) {
    final items = Parse.mapList(map, 'items').map(QuotationItem.fromMap).toList();
    final subtotal = map.containsKey('subtotal')
        ? Parse.number(map, 'subtotal')
        : items.fold<double>(0, (sum, i) => sum + i.amount);
    final tax = Parse.number(map, 'tax');
    return QuotationModel(
      id: id,
      title: Parse.string(map, 'title', 'Quotation'),
      status: QuotationStatus.fromKey(Parse.optString(map, 'status')),
      items: items,
      subtotal: subtotal,
      tax: tax,
      total: map.containsKey('total') ? Parse.number(map, 'total') : subtotal + tax,
      currency: Parse.string(map, 'currency', 'INR'),
      enquiryId: Parse.optString(map, 'enquiryId'),
      notes: Parse.optString(map, 'notes'),
      validUntil: Parse.date(map, 'validUntil'),
      createdAt: Parse.date(map, 'createdAt'),
    );
  }

  final String id;
  final String title;
  final QuotationStatus status;
  final List<QuotationItem> items;
  final double subtotal;
  final double tax;
  final double total;
  final String currency;
  final String? enquiryId;
  final String? notes;
  final DateTime? validUntil;
  final DateTime? createdAt;

  bool isExpiredAt(DateTime now) =>
      status == QuotationStatus.expired || (validUntil != null && validUntil!.isBefore(now));
}
