import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/brand_tokens.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/common.dart';
import '../controllers/delete_account_controller.dart';

class DeleteAccountView extends GetView<DeleteAccountController> {
  const DeleteAccountView({super.key});

  @override
  Widget build(BuildContext context) {
    final danger = context.brand.danger;
    return Scaffold(
      appBar: AppBar(title: const Text('Delete account')),
      body: ResponsiveBody(
        child: Form(
          key: controller.formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.page),
            children: [
              Text('This cannot be undone.', style: context.text.headlineSmall),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Deleting your account signs you out everywhere and removes your profile, saved devices '
                'and notifications. Enquiries, quotations, projects and support history are kept only '
                'where we must keep business records, with your name and contact details removed.',
                style: context.text.bodyMedium?.copyWith(color: context.brand.muted),
              ),
              const SizedBox(height: AppSpacing.xl),
              Obx(
                () => controller.errorMessage.value == null
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                        child: InlineNotice(message: controller.errorMessage.value!, isError: true),
                      ),
              ),
              AppTextField(
                controller: controller.passwordCtrl,
                label: 'Your password',
                prefixIcon: Icons.lock_outline_rounded,
                isPassword: true,
                autofillHints: const [AutofillHints.password],
                validator: (v) => Validators.required(v, field: 'Password'),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                controller: controller.reasonCtrl,
                label: 'Why are you leaving? (optional)',
                maxLines: 3,
                maxLength: 500,
                textInputAction: TextInputAction.newline,
              ),
              Obx(
                () => CheckboxListTile(
                  value: controller.confirmed.value,
                  onChanged: (v) => controller.confirmed.value = v ?? false,
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('I understand my account will be permanently deleted.'),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Obx(
                () => FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: danger, foregroundColor: Colors.white),
                  onPressed: controller.isDeleting.value ? null : controller.deleteAccount,
                  icon: controller.isDeleting.value
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.delete_forever_rounded),
                  label: const Text('Delete my account'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
