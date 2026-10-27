import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/brand_tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common.dart';
import '../models/ticket_model.dart';

class TicketCard extends StatelessWidget {
  const TicketCard({super.key, required this.ticket, required this.onTap});
  final TicketModel ticket;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      semanticLabel: '${ticket.subject}, ${ticket.status.label}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(ticket.subject, style: context.text.titleMedium, maxLines: 2)),
              StatusChip(label: ticket.status.label, tone: ticket.status.tone),
            ],
          ),
          if (ticket.lastMessage != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(ticket.lastMessage!, maxLines: 2, overflow: TextOverflow.ellipsis, style: context.text.bodyMedium),
          ],
          const SizedBox(height: AppSpacing.md),
          Text('${ticket.category.label}, ${Formatters.relative(ticket.updatedAt)}', style: context.text.bodySmall),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message});
  final TicketMessage message;

  @override
  Widget build(BuildContext context) {
    final mine = !message.fromStaff;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: Radius.circular(mine ? 18 : 4),
      bottomRight: Radius.circular(mine ? 4 : 18),
    );
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.78),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Column(
            crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: mine ? AppColors.ink : context.colors.surface,
                  borderRadius: radius,
                  border: mine ? null : Border.all(color: context.brand.line),
                ),
                child: SelectableText(
                  message.text,
                  style: context.text.bodyMedium?.copyWith(color: mine ? Colors.white : null),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${mine ? 'You' : (message.authorName ?? 'Busiserve team')}, '
                '${message.createdAt == null ? 'sending' : Formatters.dateTime(message.createdAt)}',
                style: context.text.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
