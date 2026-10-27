import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/brand_tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/hex_shape.dart';
import '../../../core/widgets/state_views.dart';
import '../controllers/project_detail_controller.dart';
import '../models/project_model.dart';
import '../widgets/project_widgets.dart';

class ProjectDetailView extends GetView<ProjectDetailController> {
  const ProjectDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Project')),
      body: Obx(
        () => StateView<ProjectModel>(
          state: controller.project.value,
          onRetry: controller.load,
          builder: (p) => ResponsiveBody(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(AppSpacing.page, 0, AppSpacing.page, AppSpacing.xxl),
              children: [
                _Header(project: p),
                const SizedBox(height: AppSpacing.xl),
                Wrap(
                  spacing: AppSpacing.xl,
                  runSpacing: AppSpacing.md,
                  children: [
                    _Fact(label: 'Started', value: Formatters.date(p.startDate)),
                    _Fact(label: 'Target', value: Formatters.date(p.targetDate)),
                    if (p.managerName != null) _Fact(label: 'Project lead', value: p.managerName!),
                    _Fact(label: 'Last update', value: Formatters.relative(p.updatedAt)),
                  ],
                ),
                if (p.summary != null) ...[
                  const SizedBox(height: AppSpacing.xl),
                  Text(p.summary!, style: context.text.bodyLarge),
                ],
                const SizedBox(height: AppSpacing.xxl),
                Text('Milestones', style: context.text.titleLarge),
                const SizedBox(height: AppSpacing.lg),
                Obx(
                  () => StateView<List<MilestoneModel>>(
                    state: controller.milestones.value,
                    onRetry: controller.load,
                    loading: const SizedBox(height: 120, child: LoadingView()),
                    emptyTitle: 'Milestones coming soon',
                    emptyMessage: 'Your project lead will add the plan here.',
                    emptyIcon: Icons.flag_outlined,
                    builder: (m) => MilestoneTimeline(milestones: m),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                AppButton.secondary(
                  label: 'Ask a question',
                  icon: Icons.forum_outlined,
                  onPressed: controller.askQuestion,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.project});
  final ProjectModel project;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: AppColors.hero, borderRadius: BorderRadius.circular(AppRadius.panel - 6)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: HexLatticePainter(color: Colors.white.withValues(alpha: 0.05))),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(project.status.label, style: context.text.bodyMedium?.copyWith(color: AppColors.amber, fontWeight: FontWeight.w700)),
                const SizedBox(height: AppSpacing.sm),
                Text(project.title, style: context.text.headlineSmall?.copyWith(color: Colors.white)),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    Text('${project.progress}%', style: context.text.displaySmall?.copyWith(color: Colors.white)),
                    const SizedBox(width: AppSpacing.md),
                    Text('complete', style: context.text.bodyMedium?.copyWith(color: Colors.white70)),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                ProgressBar(percent: project.progress, onDark: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.text.bodySmall?.copyWith(color: context.brand.muted)),
        const SizedBox(height: 2),
        Text(value, style: context.text.titleSmall),
      ],
    );
  }
}
