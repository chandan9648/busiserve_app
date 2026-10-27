import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/brand_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/hex_shape.dart';
import '../../../core/widgets/state_views.dart';
import '../controllers/service_detail_controller.dart';
import '../models/service_model.dart';
import '../widgets/service_icon.dart';

class ServiceDetailView extends GetView<ServiceDetailController> {
  const ServiceDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Obx(
        () => StateView<ServiceModel>(
          state: controller.state.value,
          onRetry: controller.load,
          builder: (s) => _Body(service: s),
        ),
      ),
      bottomNavigationBar: Obx(
        () => controller.state.value.dataOrNull == null
            ? const SizedBox.shrink()
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.sm, AppSpacing.page, AppSpacing.md),
                  child: AppButton(
                    label: 'Discuss this service',
                    icon: Icons.chat_bubble_outline_rounded,
                    onPressed: controller.startEnquiry,
                  ),
                ),
              ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.service});
  final ServiceModel service;

  static const _principles = [
    ('Built around your business', 'Shaped around the way you work and the customers you serve.'),
    ('Easy to use', 'Clear layouts and thoughtful interactions that make everyday tasks simpler.'),
    ('Connected systems', 'Your website, applications and business workflows, together.'),
    ('Room to grow', 'A considered technical foundation for your next stage of growth.'),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ServiceDetailController>();
    return ResponsiveBody(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.page, 0, AppSpacing.page, AppSpacing.xxl),
        children: [
          HexBadge(icon: serviceIcon(service.iconKey), size: 72, gradient: AppColors.circuit),
          const SizedBox(height: AppSpacing.xl),
          Semantics(header: true, child: Text(service.title, style: context.text.headlineMedium)),
          const SizedBox(height: AppSpacing.sm),
          Text(service.summary, style: context.text.bodyLarge?.copyWith(color: context.brand.muted)),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [for (final f in service.focusAreas) Chip(label: Text(f))],
          ),
          if (service.description != null) ...[
            const SizedBox(height: AppSpacing.xl),
            Text(service.description!, style: context.text.bodyLarge),
          ],
          if (service.highlights.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            Text('What is included', style: context.text.titleLarge),
            const SizedBox(height: AppSpacing.md),
            for (final h in service.highlights)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle_rounded, size: 20, color: context.brand.success),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: Text(h, style: context.text.bodyMedium)),
                  ],
                ),
              ),
          ],
          const SizedBox(height: AppSpacing.xxl),
          Text('How we work', style: context.text.titleLarge),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              children: [
                for (var i = 0; i < _principles.length; i++) ...[
                  if (i > 0) const Divider(height: AppSpacing.xl),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 6,
                        height: 38,
                        decoration: BoxDecoration(
                          gradient: AppColors.arrow,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_principles[i].$1, style: context.text.titleSmall),
                            const SizedBox(height: 2),
                            Text(_principles[i].$2, style: context.text.bodySmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: TextButton.icon(
              onPressed: controller.openWebsite,
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
              label: const Text('Read more on busiserve.in'),
            ),
          ),
        ],
      ),
    );
  }
}
