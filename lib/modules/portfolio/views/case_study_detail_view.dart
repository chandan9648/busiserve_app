import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/brand_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/hex_shape.dart';
import '../../../core/widgets/state_views.dart';
import '../controllers/case_study_detail_controller.dart';
import '../models/case_study_model.dart';
import '../widgets/case_study_card.dart';

class CaseStudyDetailView extends GetView<CaseStudyDetailController> {
  const CaseStudyDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Obx(
        () => StateView<CaseStudyModel>(
          state: controller.state.value,
          onRetry: controller.load,
          builder: (c) => ResponsiveBody(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(AppSpacing.page, 0, AppSpacing.page, AppSpacing.xxl),
              children: [
                Row(
                  children: [
                    HexBadge(icon: industryIcon(c.industry), size: 44, gradient: AppColors.arrow),
                    const SizedBox(width: AppSpacing.md),
                    Text(c.industry, style: context.text.titleSmall?.copyWith(color: AppColors.flame)),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Semantics(header: true, child: Text(c.title, style: context.text.headlineMedium)),
                const SizedBox(height: AppSpacing.md),
                Text(c.summary, style: context.text.bodyLarge),
                if (c.challenge != null) _Section(title: 'The challenge', body: c.challenge!),
                if (c.solution != null) _Section(title: 'What we did', body: c.solution!),
                if (c.results.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xl),
                  Text('Results', style: context.text.titleLarge),
                  const SizedBox(height: AppSpacing.md),
                  for (final r in c.results)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.trending_up_rounded, size: 20, color: AppColors.flame),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(child: Text(r, style: context.text.bodyMedium)),
                        ],
                      ),
                    ),
                ],
                if (c.technologies.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [for (final t in c.technologies) Chip(label: Text(t))],
                  ),
                ],
                const SizedBox(height: AppSpacing.xxl),
                AppButton(label: 'Start a similar project', onPressed: controller.startSimilarProject),
                const SizedBox(height: AppSpacing.sm),
                TextButton.icon(
                  onPressed: controller.openWebsite,
                  icon: const Icon(Icons.open_in_new_rounded, size: 18),
                  label: const Text('Read the full case study'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: context.text.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(body, style: context.text.bodyLarge?.copyWith(color: context.brand.muted)),
        ],
      ),
    );
  }
}
