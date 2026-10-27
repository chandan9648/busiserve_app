import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/brand_tokens.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../controllers/login_controller.dart';
import '../widgets/auth_scaffold.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Sign in',
      subtitle: 'Track your enquiries, quotations, projects and support requests.',
      children: [
        Obx(() => FormError(message: controller.errorMessage.value)),
        Form(
          key: controller.formKey,
          child: AutofillGroup(
            child: Column(
              children: [
                AppTextField(
                  controller: controller.emailCtrl,
                  label: 'Email',
                  prefixIcon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email, AutofillHints.username],
                  validator: Validators.email,
                  onSubmitted: (_) => controller.passwordFocus.requestFocus(),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  controller: controller.passwordCtrl,
                  focusNode: controller.passwordFocus,
                  label: 'Password',
                  prefixIcon: Icons.lock_outline_rounded,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  validator: (v) => Validators.required(v, field: 'Password'),
                  onSubmitted: (_) => controller.signIn(),
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(onPressed: controller.goToForgotPassword, child: const Text('Forgot password?')),
        ),
        const SizedBox(height: AppSpacing.sm),
        Obx(
          () => AppButton(label: 'Sign in', isLoading: controller.isLoading.value, onPressed: controller.signIn),
        ),
        const SizedBox(height: AppSpacing.xl),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('New to Busiserve?', style: context.text.bodyMedium?.copyWith(color: context.brand.muted)),
            TextButton(onPressed: controller.goToRegister, child: const Text('Create account')),
          ],
        ),
      ],
    );
  }
}
