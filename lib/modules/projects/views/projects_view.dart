import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/state_views.dart';
import '../controllers/projects_controller.dart';
import '../models/project_model.dart';
import '../widgets/project_widgets.dart';

class ProjectsView extends GetView<ProjectsController> {
  const ProjectsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Projects')),
      body: ResponsiveBody(
        child: Obx(
          () => StateView<List<ProjectModel>>(
            state: controller.state.value,
            onRetry: controller.load,
            emptyTitle: 'No projects yet',
            emptyMessage: 'Once work begins, you can follow every milestone here.',
            emptyIcon: Icons.timeline_rounded,
            emptyActionLabel: 'Start a project',
            onEmptyAction: controller.startProject,
            builder: (items) => ListView.separated(
              padding: const EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.sm, AppSpacing.page, AppSpacing.xxl),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (_, i) => ProjectCard(project: items[i], onTap: () => controller.open(items[i])),
            ),
          ),
        ),
      ),
    );
  }
}
