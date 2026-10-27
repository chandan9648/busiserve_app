import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/common.dart';
import '../../profile/widgets/menu_tile.dart';
import '../controllers/privacy_controller.dart';

class PrivacySettingsView extends GetView<PrivacyController> {
  const PrivacySettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy and data')),
      body: ResponsiveBody(
        child: Obx(
          () => ListView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.page, 0, AppSpacing.page, AppSpacing.xxl),
            children: [
              MenuGroup(
                title: 'Diagnostics',
                children: [
                  SwitchListTile(
                    value: controller.crashReporting.value,
                    onChanged: controller.crashReportingSupported ? controller.setCrashReporting : null,
                    title: const Text('Send crash reports'),
                    subtitle: const Text(
                      'Helps us fix problems. Reports include device and app details, never your messages or passwords.',
                    ),
                  ),
                ],
              ),
              if (controller.session.isLoggedIn)
                MenuGroup(
                  title: 'Notifications',
                  children: [
                    SwitchListTile(
                      value: controller.pushEnabled.value,
                      onChanged: controller.setPushEnabled,
                      title: const Text('Push notifications'),
                      subtitle: const Text('Quotations, project updates and support replies.'),
                    ),
                  ],
                ),
              MenuGroup(
                title: 'Policies',
                children: [
                  MenuTile(icon: Icons.policy_outlined, title: 'Privacy policy', onTap: controller.openPrivacyPolicy),
                  MenuTile(icon: Icons.gavel_outlined, title: 'Terms of service', onTap: controller.openTerms),
                  MenuTile(
                    icon: Icons.currency_rupee_rounded,
                    title: 'Refund and cancellation policy',
                    onTap: controller.openRefundPolicy,
                  ),
                ],
              ),
              if (controller.session.isLoggedIn)
                MenuGroup(
                  title: 'Account',
                  children: [
                    MenuTile(
                      icon: Icons.delete_outline_rounded,
                      title: 'Delete account',
                      subtitle: 'Permanently remove your account and personal data.',
                      destructive: true,
                      onTap: controller.openDeleteAccount,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
