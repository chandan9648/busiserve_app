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
import '../../../core/widgets/common.dart';
import '../../../core/widgets/email_verification_notice.dart';
import '../controllers/enquiry_controller.dart';
import '../widgets/subject_dropdown.dart';

class EnquiryFormView extends GetView<EnquiryController> {
  const EnquiryFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Start a project')),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ResponsiveBody(
          child: Form(
            key: controller.formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(AppSpacing.page, 0, AppSpacing.page, AppSpacing.xxl),
              children: [
                Text('A rough idea is enough to start.', style: context.text.headlineSmall),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Describe the problem you want to solve. If you already have a website, a target '
                  'date or a budget in mind, include those details too.',
                  style: context.text.bodyMedium?.copyWith(color: context.brand.muted),
                ),
                const SizedBox(height: AppSpacing.xl),
                const EmailVerificationNotice(padding: EdgeInsets.only(bottom: AppSpacing.lg)),
                Obx(
                  () => controller.errorMessage.value == null
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                          child: InlineNotice(
                            message: controller.errorMessage.value!,
                            icon: Icons.error_outline_rounded,
                            isError: true,
                          ),
                        ),
                ),
                AppTextField(
                  controller: controller.nameCtrl,
                  label: 'Full name',
                  prefixIcon: Icons.person_outline_rounded,
                  textCapitalization: TextCapitalization.words,
                  autofillHints: const [AutofillHints.name],
                  maxLength: AppLimits.nameMax,
                  validator: (v) => controller.serverError('name') ?? Validators.name(v),
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: controller.emailCtrl,
                  label: 'Work email',
                  prefixIcon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  validator: (v) => controller.serverError('email') ?? Validators.email(v),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  controller: controller.phoneCtrl,
                  label: 'Phone (optional)',
                  prefixIcon: Icons.call_outlined,
                  keyboardType: TextInputType.phone,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  validator: (v) => controller.serverError('phone') ?? Validators.phone(v),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  controller: controller.companyCtrl,
                  label: 'Company (optional)',
                  prefixIcon: Icons.business_outlined,
                  textCapitalization: TextCapitalization.words,
                  autofillHints: const [AutofillHints.organizationName],
                  validator: (v) => Validators.maxLength(v, AppLimits.companyMax, field: 'Company'),
                ),
                const SizedBox(height: AppSpacing.lg),
                Obx(
                  () => SubjectDropdown(
                    value: controller.subject.value,
                    enabled: !controller.isSubmitting.value,
                    onChanged: (s) => controller.subject.value = s,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  controller: controller.messageCtrl,
                  label: 'Message',
                  hint: 'What do you want to build, and by when?',
                  maxLines: 6,
                  minLines: 5,
                  maxLength: AppLimits.messageMax,
                  textInputAction: TextInputAction.newline,
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (v) => controller.serverError('message') ?? Validators.message(v),
                ),
                const SizedBox(height: AppSpacing.lg),
                Obx(
                  () => AppButton(
                    label: 'Send message',
                    icon: Icons.send_rounded,
                    isLoading: controller.isSubmitting.value,
                    onPressed: controller.submit,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'We use these details only to reply to your enquiry. See our privacy policy on busiserve.in.',
                  style: context.text.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                const Divider(),
                const SizedBox(height: AppSpacing.lg),
                Text('Prefer to talk?', style: context.text.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    const ActionChip(
                      avatar: Icon(Icons.call_outlined, size: 18),
                      label: Text(CompanyInfo.phoneDisplay),
                      onPressed: Launcher.call,
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.mail_outline_rounded, size: 18),
                      label: const Text('Email us'),
                      onPressed: () => Launcher.email(subject: 'Project enquiry'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
