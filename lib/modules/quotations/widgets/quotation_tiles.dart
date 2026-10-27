import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/brand_tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common.dart';
import '../../enquiry/models/enquiry_model.dart';
import '../models/quotation_model.dart';

class EnquiryTile extends StatelessWidget {
  const EnquiryTile({super.key, required this.enquiry});
  final EnquiryModel enquiry;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(enquiry.subjectLabel, style: context.text.titleMedium)),
              StatusChip(label: enquiry.status.label, tone: enquiry.status.tone),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(enquiry.message, maxLines: 2, overflow: TextOverflow.ellipsis, style: context.text.bodyMedium),
          const SizedBox(height: AppSpacing.md),
          Text('${enquiry.reference}, ${Formatters.date(enquiry.createdAt)}', style: context.text.bodySmall),
        ],
      ),
    );
  }
}

class QuotationTile extends StatelessWidget {
  const QuotationTile({super.key, required this.quotation, required this.onTap});
  final QuotationModel quotation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final expired = quotation.isExpiredAt(DateTime.now());
    return AppCard(
      onTap: onTap,
      semanticLabel: '${quotation.title}, ${Formatters.currency(quotation.total, currency: quotation.currency)}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(quotation.title, style: context.text.titleMedium)),
              StatusChip(
                label: expired && quotation.status == QuotationStatus.sent ? 'Expired' : quotation.status.label,
                tone: expired && quotation.status == QuotationStatus.sent ? StatusTone.neutral : quotation.status.tone,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            Formatters.currency(quotation.total, currency: quotation.currency),
            style: context.text.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            quotation.validUntil == null ? 'Sent ${Formatters.date(quotation.createdAt)}' : 'Valid until ${Formatters.date(quotation.validUntil)}',
            style: context.text.bodySmall?.copyWith(color: context.brand.muted),
          ),
        ],
      ),
    );
  }
}
