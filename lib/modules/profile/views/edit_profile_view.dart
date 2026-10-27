import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_limits.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/state_views.dart';
import '../controllers/edit_profile_controller.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: Obx(
        () => controller.isLoading.value
            ? const LoadingView()
            : ResponsiveBody(
                child: Form(
                  key: controller.formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(AppSpacing.page),
                    children: [
                      if (controller.errorMessage.value != null) ...[
                        InlineNotice(message: controller.errorMessage.value!, isError: true),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                      AppTextField(
                        controller: controller.nameCtrl,
                        label: 'Full name',
                        prefixIcon: Icons.person_outline_rounded,
                        textCapitalization: TextCapitalization.words,
                        maxLength: AppLimits.nameMax,
                        validator: Validators.name,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppTextField(
                        controller: controller.phoneCtrl,
                        label: 'Phone (optional)',
                        prefixIcon: Icons.call_outlined,
                        keyboardType: TextInputType.phone,
                        validator: Validators.phone,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppTextField(
                        controller: controller.companyCtrl,
                        label: 'Company (optional)',
                        prefixIcon: Icons.business_outlined,
                        textInputAction: TextInputAction.done,
                        validator: (v) => Validators.maxLength(v, AppLimits.companyMax, field: 'Company'),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text('Email: ${controller.email}', style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: AppSpacing.xl),
                      AppButton(
                        label: 'Save changes',
                        isLoading: controller.isSaving.value,
                        onPressed: controller.save,
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
