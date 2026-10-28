import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_limits.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/email_verification_notice.dart';
import '../controllers/create_ticket_controller.dart';
import '../models/ticket_model.dart';

class CreateTicketView extends GetView<CreateTicketController> {
  const CreateTicketView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New support request')),
      body: ResponsiveBody(
        child: Form(
          key: controller.formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.page),
            children: [
              const EmailVerificationNotice(padding: EdgeInsets.only(bottom: AppSpacing.lg)),
              Obx(
                () => controller.errorMessage.value == null
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                        child: InlineNotice(message: controller.errorMessage.value!, isError: true),
                      ),
              ),
              Obx(
                () => DropdownButtonFormField<TicketCategory>(
                  initialValue: controller.category.value,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Topic', prefixIcon: Icon(Icons.label_outline, size: 20)),
                  items: [
                    for (final c in TicketCategory.values) DropdownMenuItem(value: c, child: Text(c.label)),
                  ],
                  onChanged: controller.isSubmitting.value ? null : (c) => controller.category.value = c ?? TicketCategory.general,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                controller: controller.subjectCtrl,
                label: 'Subject',
                maxLength: AppLimits.ticketSubjectMax,
                textCapitalization: TextCapitalization.sentences,
                validator: (v) =>
                    Validators.minLength(v, 4, field: 'Subject') ??
                    Validators.maxLength(v, AppLimits.ticketSubjectMax, field: 'Subject'),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: controller.messageCtrl,
                label: 'How can we help?',
                maxLines: 7,
                minLines: 5,
                maxLength: AppLimits.chatMessageMax,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                textCapitalization: TextCapitalization.sentences,
                validator: (v) =>
                    Validators.minLength(v, AppLimits.messageMin, field: 'Message') ??
                    Validators.maxLength(v, AppLimits.chatMessageMax, field: 'Message'),
              ),
              const SizedBox(height: AppSpacing.lg),
              Obx(
                () => AppButton(
                  label: 'Send request',
                  icon: Icons.send_rounded,
                  isLoading: controller.isSubmitting.value,
                  onPressed: controller.submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
