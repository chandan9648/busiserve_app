import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/brand_tokens.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/state_views.dart';
import '../controllers/portfolio_controller.dart';
import '../models/case_study_model.dart';
import '../widgets/case_study_card.dart';

class PortfolioView extends GetView<PortfolioController> {
  const PortfolioView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Our work')),
      body: ResponsiveBody(
        child: Obx(
          () => StateView<List<CaseStudyModel>>(
            state: controller.state.value,
            onRetry: () => controller.load(refresh: true),
            emptyTitle: 'No case studies yet',
            emptyMessage: 'New work will appear here soon.',
            builder: (items) => RefreshIndicator(
              onRefresh: () => controller.load(refresh: true),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.page, 0, AppSpacing.page, AppSpacing.xxl),
                children: [
                  Text('Proven results. Measurable impact.', style: context.text.headlineSmall),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'How we have helped organisations overcome complex challenges, streamline '
                    'operations and grow.',
                    style: context.text.bodyMedium?.copyWith(color: context.brand.muted),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Wrap(
                    spacing: AppSpacing.sm,
                    children: [
                      for (final i in controller.industries)
                        FilterChip(
                          label: Text(i),
                          selected: controller.industry.value == i,
                          onSelected: (_) => controller.selectIndustry(i),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  for (final c in items) ...[
                    CaseStudyCard(study: c, onTap: () => controller.open(c)),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
