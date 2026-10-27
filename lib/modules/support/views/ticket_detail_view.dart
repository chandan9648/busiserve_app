import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_limits.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/brand_tokens.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/state_views.dart';
import '../controllers/ticket_detail_controller.dart';
import '../models/ticket_model.dart';
import '../widgets/support_widgets.dart';

class TicketDetailView extends GetView<TicketDetailController> {
  const TicketDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.ticket.value.dataOrNull?.subject ?? 'Support request', overflow: TextOverflow.ellipsis)),
      ),
      body: Obx(
        () => StateView<TicketModel>(
          state: controller.ticket.value,
          onRetry: controller.load,
          builder: (t) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.page, 0, AppSpacing.page, AppSpacing.sm),
                child: Row(
                  children: [
                    StatusChip(label: t.status.label, tone: t.status.tone),
                    const SizedBox(width: AppSpacing.sm),
                    Text(t.category.label, style: context.text.bodySmall),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: Obx(
                  () => StateView<List<TicketMessage>>(
                    state: controller.messages.value,
                    onRetry: controller.load,
                    emptyTitle: 'No messages yet',
                    emptyMessage: 'Write below and our team will reply here.',
                    builder: (m) => ListView.builder(
                      controller: controller.scrollCtrl,
                      padding: const EdgeInsets.all(AppSpacing.page),
                      itemCount: m.length,
                      itemBuilder: (_, i) => MessageBubble(message: m[i]),
                    ),
                  ),
                ),
              ),
              if (t.status.acceptsReplies) const _Composer() else const _ClosedNotice(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Composer extends GetView<TicketDetailController> {
  const _Composer();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.sm, AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: controller.replyCtrl,
                  minLines: 1,
                  maxLines: 5,
                  maxLength: AppLimits.chatMessageMax,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(hintText: 'Write a reply', counterText: ''),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Obx(
                () => IconButton.filled(
                  tooltip: 'Send',
                  onPressed: controller.canSend.value && !controller.isSending.value ? controller.send : null,
                  icon: controller.isSending.value
                      ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.send_rounded),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClosedNotice extends StatelessWidget {
  const _ClosedNotice();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.page),
        child: Text(
          'This request is closed. Start a new request if you need more help.',
          style: context.text.bodySmall?.copyWith(color: context.brand.muted),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
