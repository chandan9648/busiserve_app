import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/state_views.dart';
import '../controllers/tickets_controller.dart';
import '../models/ticket_model.dart';
import '../widgets/support_widgets.dart';

class TicketsView extends GetView<TicketsController> {
  const TicketsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Support')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.create,
        icon: const Icon(Icons.add_comment_outlined),
        label: const Text('New request'),
      ),
      body: ResponsiveBody(
        child: Obx(
          () => StateView<List<TicketModel>>(
            state: controller.state.value,
            onRetry: controller.load,
            emptyTitle: 'No support requests',
            emptyMessage: 'Have a question about a project, quotation or invoice? Send us a request.',
            emptyIcon: Icons.support_agent_rounded,
            emptyActionLabel: 'New request',
            onEmptyAction: controller.create,
            builder: (items) => ListView.separated(
              padding: const EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.sm, AppSpacing.page, 96),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (_, i) => TicketCard(ticket: items[i], onTap: () => controller.open(items[i])),
            ),
          ),
        ),
      ),
    );
  }
}
