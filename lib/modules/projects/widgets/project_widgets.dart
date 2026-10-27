import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/brand_tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common.dart';
import '../models/project_model.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key, required this.percent, this.onDark = false});
  final int percent;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$percent percent complete',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(
          height: 8,
          child: Stack(
            children: [
              Container(color: onDark ? Colors.white.withValues(alpha: 0.15) : context.brand.line),
              FractionallySizedBox(
                widthFactor: percent / 100,
                child: Container(decoration: const BoxDecoration(gradient: AppColors.arrow)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProjectCard extends StatelessWidget {
  const ProjectCard({super.key, required this.project, required this.onTap});
  final ProjectModel project;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      semanticLabel: '${project.title}, ${project.status.label}, ${project.progress} percent',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(project.title, style: context.text.titleMedium)),
              StatusChip(label: project.status.label, tone: project.status.tone),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ProgressBar(percent: project.progress),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Text('${project.progress}% complete', style: context.text.bodySmall),
              const Spacer(),
              if (project.targetDate != null)
                Text('Target ${Formatters.date(project.targetDate)}', style: context.text.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}

/// Vertical timeline. Milestones are a real sequence, so they are numbered.
class MilestoneTimeline extends StatelessWidget {
  const MilestoneTimeline({super.key, required this.milestones});
  final List<MilestoneModel> milestones;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < milestones.length; i++)
          _MilestoneRow(milestone: milestones[i], number: i + 1, isLast: i == milestones.length - 1),
      ],
    );
  }
}

class _MilestoneRow extends StatelessWidget {
  const _MilestoneRow({required this.milestone, required this.number, required this.isLast});
  final MilestoneModel milestone;
  final int number;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final done = milestone.status == MilestoneStatus.done;
    final active = milestone.status == MilestoneStatus.inProgress;
    final line = context.brand.line;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: done ? AppColors.arrow : (active ? AppColors.circuit : null),
                    color: done || active ? null : context.colors.surface,
                    border: done || active ? null : Border.all(color: line, width: 2),
                  ),
                  child: done
                      ? const Icon(Icons.check_rounded, size: 18, color: Colors.white)
                      : Text(
                          '$number',
                          style: context.text.titleSmall?.copyWith(color: active ? Colors.white : context.brand.muted),
                        ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: done ? AppColors.amber : line,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xl, top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(milestone.title, style: context.text.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    done
                        ? 'Done ${Formatters.date(milestone.completedAt)}'
                        : milestone.dueDate == null
                            ? milestone.status.label
                            : '${milestone.status.label}, due ${Formatters.date(milestone.dueDate)}',
                    style: context.text.bodySmall,
                  ),
                  if (milestone.description != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(milestone.description!, style: context.text.bodyMedium),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
