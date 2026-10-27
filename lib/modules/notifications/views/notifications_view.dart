import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/common.dart';
import '../../../core/widgets/state_views.dart';
import '../controllers/notifications_controller.dart';
import '../models/notification_model.dart';
import '../widgets/notification_tile.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          Obx(
            () => TextButton(
              onPressed: controller.unreadCount == 0 || controller.isMarkingAll.value ? null : controller.markAllRead,
              child: const Text('Mark all read'),
            ),
          ),
        ],
      ),
      body: ResponsiveBody(
        child: Obx(
          () => StateView<List<NotificationModel>>(
            state: controller.state.value,
            onRetry: controller.load,
            emptyTitle: 'You are all caught up',
            emptyMessage: 'Updates on enquiries, quotations, projects and support will appear here.',
            emptyIcon: Icons.notifications_none_rounded,
            builder: (items) => ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (_, i) => NotificationTile(notification: items[i], onTap: () => controller.open(items[i])),
            ),
          ),
        ),
      ),
    );
  }
}
