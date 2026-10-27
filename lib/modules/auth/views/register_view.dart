import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_limits.dart';
import '../../../core/constants/company_info.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/brand_tokens.dart';
import '../../../core/utils/launcher.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../controllers/register_controller.dart';
import '../widgets/auth_scaffold.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final link = context.text.bodyMedium?.copyWith(
      color: context.colors.tertiary,
      fontWeight: FontWeight.w700,
      decoration: TextDecoration.underline,
    );
    return AuthScaffold(
      title: 'Create your account',
      subtitle: 'Follow quotations, project milestones and support conversations in one place.',
      children: [
        Obx(() => FormError(message: controller.errorMessage.value)),
        Form(
          key: controller.formKey,
          child: AutofillGroup(
            child: Column(
              children: [
                AppTextField(
                  controller: controller.nameCtrl,
                  label: 'Full name',
                  prefixIcon: Icons.person_outline_rounded,
                  textCapitalization: TextCapitalization.words,
                  autofillHints: const [AutofillHints.name],
                  maxLength: AppLimits.nameMax,
                  validator: Validators.name,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: controller.emailCtrl,
                  label: 'Email',
                  prefixIcon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  validator: Validators.email,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  controller: controller.phoneCtrl,
                  label: 'Phone (optional)',
                  prefixIcon: Icons.call_outlined,
                  keyboardType: TextInputType.phone,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  validator: Validators.phone,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  controller: controller.passwordCtrl,
                  label: 'Password',
                  prefixIcon: Icons.lock_outline_rounded,
                  isPassword: true,
                  autofillHints: const [AutofillHints.newPassword],
                  helperText: 'At least 8 characters, with a letter and a number.',
                  validator: Validators.password,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  controller: controller.confirmCtrl,
                  label: 'Confirm password',
                  prefixIcon: Icons.lock_outline_rounded,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  validator: (v) => Validators.confirmPassword(v, controller.passwordCtrl.text),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Obx(
          () => CheckboxListTile(
            value: controller.acceptedTerms.value,
            onChanged: (v) => controller.acceptedTerms.value = v ?? false,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            title: Text.rich(
              TextSpan(
                style: context.text.bodyMedium,
                children: [
                  const TextSpan(text: 'I agree to the '),
                  TextSpan(
                    text: 'Terms of Service',
                    style: link,
                    recognizer: TapGestureRecognizer()..onTap = () => Launcher.web(CompanyInfo.termsUrl),
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: link,
                    recognizer: TapGestureRecognizer()..onTap = () => Launcher.web(CompanyInfo.privacyUrl),
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Obx(
          () => AppButton(
            label: 'Create account',
            isLoading: controller.isLoading.value,
            onPressed: controller.register,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Already have an account?', style: context.text.bodyMedium?.copyWith(color: context.brand.muted)),
            TextButton(onPressed: controller.goToLogin, child: const Text('Sign in')),
          ],
        ),
      ],
    );
  }
}
