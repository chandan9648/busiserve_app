import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/brand_tokens.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/state_views.dart';
import '../controllers/services_controller.dart';
import '../models/service_model.dart';
import '../widgets/service_card.dart';

class ServicesView extends GetView<ServicesController> {
  const ServicesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Services')),
      body: ResponsiveBody(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.page, 0, AppSpacing.page, AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'From websites and enterprise software to data and AI, find the service that fits your next move.',
                    style: context.text.bodyMedium?.copyWith(color: context.brand.muted),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextField(
                    onChanged: controller.search,
                    textInputAction: TextInputAction.search,
                    decoration: const InputDecoration(
                      hintText: 'Search services',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 44,
              child: Obx(
                () => ListView(
                  scrollDirection: Axis.horizontal,
                  padding: AppSpacing.pagePadding,
                  children: [
                    for (final c in ServiceCategory.values)
                      Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: FilterChip(
                          label: Text(c.label),
                          selected: controller.selectedCategory.value == c,
                          onSelected: (_) => controller.selectCategory(c),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: Obx(
                () => StateView<List<ServiceModel>>(
                  state: controller.state.value,
                  onRetry: () => controller.load(refresh: true),
                  emptyTitle: controller.hasFilters ? 'No services match' : 'No services listed',
                  emptyMessage: controller.hasFilters
                      ? 'Try another word or clear the filters.'
                      : 'Pull to refresh, or contact us directly.',
                  emptyIcon: Icons.search_off_rounded,
                  emptyActionLabel: controller.hasFilters ? 'Clear filters' : null,
                  onEmptyAction: controller.hasFilters ? controller.clearFilters : null,
                  builder: (items) => RefreshIndicator(
                    onRefresh: () => controller.load(refresh: true),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.sm, AppSpacing.page, AppSpacing.xxl),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                      itemBuilder: (_, i) => ServiceCard(service: items[i], onTap: () => controller.open(items[i])),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
