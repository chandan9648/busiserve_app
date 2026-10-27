import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/common.dart';
import '../controllers/forgot_password_controller.dart';
import '../widgets/auth_scaffold.dart';

class ForgotPasswordView extends GetView<ForgotPasswordController> {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Reset your password',
      subtitle: 'Enter the email you signed up with and we will send you a reset link.',
      children: [
        Obx(() {
          if (controller.sent.value) {
            return Column(
              children: [
                InlineNotice(
                  icon: Icons.mark_email_read_outlined,
                  message:
                      'If an account exists for ${controller.emailCtrl.text.trim()}, a reset link is on its way. '
                      'Check your inbox and spam folder.',
                ),
                const SizedBox(height: AppSpacing.xl),
                AppButton.secondary(label: 'Back to sign in', onPressed: () => Get.back<void>()),
              ],
            );
          }
          return Column(
            children: [
              FormError(message: controller.errorMessage.value),
              Form(
                key: controller.formKey,
                child: AppTextField(
                  controller: controller.emailCtrl,
                  label: 'Email',
                  prefixIcon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.email],
                  validator: Validators.email,
                  onSubmitted: (_) => controller.send(),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(label: 'Send reset link', isLoading: controller.isLoading.value, onPressed: controller.send),
            ],
          );
        }),
      ],
    );
  }
}
