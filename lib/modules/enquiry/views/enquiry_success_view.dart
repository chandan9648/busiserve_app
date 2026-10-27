import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/auth_session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/brand_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/hex_shape.dart';
import '../../../routes/app_routes.dart';

class EnquirySuccessView extends StatelessWidget {
  const EnquirySuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments is Map ? Get.arguments as Map : const {};
    final reference = args['reference'] as String?;
    final email = args['email'] as String?;
    final signedIn = Get.find<AuthSession>().isLoggedIn;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                children: [
                  const HexBadge(icon: Icons.check_rounded, size: 96, gradient: AppColors.arrow),
                  const SizedBox(height: AppSpacing.xl),
                  Semantics(
                    liveRegion: true,
                    child: Text('Message sent', style: context.text.headlineMedium, textAlign: TextAlign.center),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    email == null
                        ? 'Our team will get back to you soon.'
                        : 'Our team will reply to $email.',
                    style: context.text.bodyLarge?.copyWith(color: context.brand.muted),
                    textAlign: TextAlign.center,
                  ),
                  if (reference != null) ...[
                    const SizedBox(height: AppSpacing.xl),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.field),
                        border: Border.all(color: context.brand.line),
                      ),
                      child: Column(
                        children: [
                          Text('Reference', style: context.text.bodySmall),
                          const SizedBox(height: 2),
                          SelectableText(reference, style: context.text.titleLarge),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xxl),
                  if (signedIn)
                    AppButton(
                      label: 'Track my enquiries',
                      onPressed: () => Get.offNamed<void>(Routes.myEnquiries),
                    )
                  else
                    AppButton(
                      label: 'Create an account',
                      onPressed: () => Get.offNamed<void>(Routes.register),
                    ),
                  const SizedBox(height: AppSpacing.sm),
                  AppButton.secondary(
                    label: 'Back to home',
                    onPressed: () => Get.until((r) => r.settings.name == Routes.main || r.isFirst),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
