import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/brand_tokens.dart';
import '../../../core/utils/formatters.dart';
import '../models/notification_model.dart';

IconData _iconFor(NotificationType t) => switch (t) {
      NotificationType.enquiry => Icons.mark_chat_read_outlined,
      NotificationType.quotation => Icons.request_quote_outlined,
      NotificationType.project => Icons.timeline_rounded,
      NotificationType.support => Icons.support_agent_rounded,
      NotificationType.general => Icons.campaign_outlined,
    };

class NotificationTile extends StatelessWidget {
  const NotificationTile({super.key, required this.notification, required this.onTap});
  final NotificationModel notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final unread = !notification.read;
    return Semantics(
      button: true,
      label: '${unread ? 'Unread. ' : ''}${notification.title}. ${notification.body}',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Container(
          color: unread ? context.colors.primaryContainer.withValues(alpha: 0.35) : null,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page, vertical: AppSpacing.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: context.colors.secondaryContainer,
                child: Icon(_iconFor(notification.type), size: 20, color: context.colors.onSecondaryContainer),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: context.text.titleSmall?.copyWith(
                              fontWeight: unread ? FontWeight.w800 : FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(Formatters.relative(notification.createdAt), style: context.text.bodySmall),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(notification.body, style: context.text.bodyMedium, maxLines: 3, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              if (unread) ...[
                const SizedBox(width: AppSpacing.sm),
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(color: context.colors.secondary, shape: BoxShape.circle),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
