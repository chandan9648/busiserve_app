import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/company_info.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/brand_tokens.dart';
import '../../../core/utils/launcher.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/hex_shape.dart';
import '../../../core/widgets/state_views.dart';
import '../../../routes/app_routes.dart';
import '../../auth/models/user_model.dart';
import '../controllers/profile_controller.dart';
import '../widgets/menu_tile.dart';

/// The Account tab.
class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: ResponsiveBody(
        child: Obx(() {
          final signedIn = controller.session.currentUid.value != null;
          return ListView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.page, 0, AppSpacing.page, AppSpacing.xxxl),
            children: [
              if (signedIn) const _SignedInHeader() else const _SignedOutCard(),
              if (signedIn)
                MenuGroup(
                  title: 'Your work',
                  children: [
                    MenuTile(
                      icon: Icons.request_quote_outlined,
                      title: 'Enquiries and quotations',
                      onTap: () => controller.open(Routes.myEnquiries),
                    ),
                    MenuTile(
                      icon: Icons.timeline_rounded,
                      title: 'Projects and milestones',
                      onTap: () => controller.open(Routes.projects),
                    ),
                    MenuTile(
                      icon: Icons.support_agent_rounded,
                      title: 'Support',
                      onTap: () => controller.open(Routes.tickets),
                    ),
                    MenuTile(
                      icon: Icons.notifications_none_rounded,
                      title: 'Notifications',
                      onTap: () => controller.open(Routes.notifications),
                    ),
                  ],
                ),
              MenuGroup(
                title: 'Settings',
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Appearance', style: context.text.titleSmall),
                        const SizedBox(height: AppSpacing.md),
                        SizedBox(
                          width: double.infinity,
                          child: SegmentedButton<ThemeMode>(
                            showSelectedIcon: false,
                            segments: const [
                              ButtonSegment(value: ThemeMode.system, label: Text('System')),
                              ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                              ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
                            ],
                            selected: {controller.themeMode.value},
                            onSelectionChanged: (s) => controller.setThemeMode(s.first),
                          ),
                        ),
                      ],
                    ),
                  ),
                  MenuTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy and data',
                    onTap: () => controller.open(Routes.privacy),
                  ),
                ],
              ),
              MenuGroup(
                title: 'Contact ${CompanyInfo.shortName}',
                children: [
                  const MenuTile(
                    icon: Icons.call_outlined,
                    title: CompanyInfo.phoneDisplay,
                    onTap: Launcher.call,
                  ),
                  MenuTile(
                    icon: Icons.mail_outline_rounded,
                    title: 'Email us',
                    subtitle: CompanyInfo.email,
                    onTap: () => Launcher.email(),
                  ),
                  MenuTile(
                    icon: Icons.language_rounded,
                    title: 'Visit busiserve.in',
                    onTap: () => Launcher.web(CompanyInfo.website),
                  ),
                  MenuTile(
                    icon: Icons.sell_outlined,
                    title: 'Pricing',
                    onTap: () => Launcher.web(CompanyInfo.pricingUrl),
                  ),
                ],
              ),
              if (signedIn) ...[
                const SizedBox(height: AppSpacing.xl),
                AppButton.secondary(
                  label: 'Sign out',
                  icon: Icons.logout_rounded,
                  isLoading: controller.isSigningOut.value,
                  onPressed: controller.signOut,
                ),
              ],
            ],
          );
        }),
      ),
    );
  }
}

class _SignedOutCard extends GetView<ProfileController> {
  const _SignedOutCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: AppColors.hero,
        borderRadius: BorderRadius.circular(AppRadius.panel - 4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HexBadge(icon: Icons.person_outline_rounded, size: 52, gradient: AppColors.arrow),
          const SizedBox(height: AppSpacing.lg),
          Text('Your Busiserve account', style: context.text.titleLarge?.copyWith(color: Colors.white)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Sign in to track enquiries, quotations, project milestones and support requests.',
            style: context.text.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.8)),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(label: 'Sign in', onPressed: controller.goToLogin),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: controller.goToRegister,
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              child: const Text('Create account'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SignedInHeader extends GetView<ProfileController> {
  const _SignedInHeader();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => StateView<UserModel>(
        state: controller.profile.value,
        onRetry: controller.retry,
        loading: const SizedBox(height: 96, child: LoadingView()),
        builder: (u) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              child: Row(
                children: [
                  ClipPath(
                    clipper: const HexClipper(),
                    child: Container(
                      width: 60,
                      height: 64,
                      decoration: const BoxDecoration(gradient: AppColors.circuit),
                      alignment: Alignment.center,
                      child: Text(
                        u.initials,
                        style: context.text.titleLarge?.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(u.name.isEmpty ? 'Your profile' : u.name, style: context.text.titleMedium),
                        const SizedBox(height: 2),
                        Text(u.email, style: context.text.bodySmall, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Edit profile',
                    onPressed: () => controller.open(Routes.editProfile),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                ],
              ),
            ),
            if (!controller.session.isEmailVerified) ...[
              const SizedBox(height: AppSpacing.md),
              const InlineNotice(
                icon: Icons.mark_email_unread_outlined,
                message: 'Verify your email using the link we sent, then reopen the app.',
              ),
            ],
          ],
        ),
      ),
    );
  }
}
