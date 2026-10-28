import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/company_info.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/brand_tokens.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/state_views.dart';
import '../../portfolio/models/case_study_model.dart';
import '../../portfolio/widgets/case_study_card.dart';
import '../../services/models/service_model.dart';
import '../../services/widgets/service_card.dart';
import '../controllers/home_controller.dart';
import '../widgets/contact_panel.dart';
import '../widgets/hero_panel.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: controller.refreshAll,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.sm, AppSpacing.sm, AppSpacing.lg),
                  child: Row(
                    children: [
                      const BrandLogo(height: 46),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Notifications',
                        onPressed: controller.openNotifications,
                        icon: const Icon(Icons.notifications_none_rounded),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: HeroPanel(onStart: controller.startProject, onExplore: controller.showAllServices),
              ),
              SliverToBoxAdapter(
                child: SectionHeader(
                  title: 'What we build',
                  actionLabel: 'All services',
                  onAction: controller.showAllServices,
                ),
              ),
              SliverToBoxAdapter(
                child: Obx(
                  () => StateView<List<ServiceModel>>(
                    state: controller.services.value,
                    onRetry: controller.loadServices,
                    loading: const SizedBox(height: 220, child: LoadingView()),
                    builder: (items) => _ServiceGrid(items: items.take(6).toList(), onTap: controller.openService),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: _WhyBusiserve()),
              SliverToBoxAdapter(
                child: SectionHeader(
                  title: 'Proven results',
                  actionLabel: 'See all',
                  onAction: controller.showAllWork,
                ),
              ),
              SliverToBoxAdapter(
                child: Obx(() {
                  final state = controller.caseStudies.value;
                  final scale = MediaQuery.textScalerOf(context).scale(1);
                  final cardWidth = (MediaQuery.sizeOf(context).width * 0.82).clamp(240.0, 320.0);
                  return SizedBox(
                    height: 250 + 210 * (scale - 1).clamp(0.0, 1.0),
                    child: StateView<List<CaseStudyModel>>(
                      state: state,
                      onRetry: controller.loadCaseStudies,
                      builder: (items) => ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: AppSpacing.pagePadding,
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
                        itemBuilder: (_, i) => SizedBox(
                          width: cardWidth,
                          child: CaseStudyCard(
                            study: items[i],
                            compact: true,
                            onTap: () => controller.openCaseStudy(items[i]),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
              SliverToBoxAdapter(
                child: ContactPanel(
                  onStart: controller.startProject,
                  onCall: controller.callUs,
                  onEmail: controller.email,
                  onMap: controller.openMap,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.xxl, AppSpacing.page, AppSpacing.xxxl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(CompanyInfo.footerLine, style: context.text.bodySmall),
                      const SizedBox(height: AppSpacing.xs),
                      Text('© ${DateTime.now().year} Busiserve. All rights reserved.', style: context.text.bodySmall),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceGrid extends StatelessWidget {
  const _ServiceGrid({required this.items, required this.onTap});
  final List<ServiceModel> items;
  final void Function(ServiceModel) onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final columns = c.maxWidth > 700 ? 4 : (c.maxWidth < 360 ? 2 : 3);
        // Size tiles from the actual text scale instead of a fixed aspect ratio,
        // so large system fonts and narrow screens never overflow.
        final style = context.text.titleSmall;
        final fontSize = style?.fontSize ?? 14;
        final lineHeight = MediaQuery.textScalerOf(context).scale(fontSize) * (style?.height ?? 1.3);
        final tileHeight = AppSpacing.md * 2 + 38 + AppSpacing.sm + lineHeight * 2 + 4;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: AppSpacing.pagePadding,
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            mainAxisExtent: tileHeight,
          ),
          itemBuilder: (_, i) => ServiceTile(service: items[i], onTap: () => onTap(items[i])),
        );
      },
    );
  }
}

/// "Good technology. A clear purpose." — four principles from busiserve.in.
class _WhyBusiserve extends StatelessWidget {
  const _WhyBusiserve();

  static const _items = [
    (Icons.business_center_outlined, 'Built around your business',
        'Websites and tools shaped around the way you work and the customers you serve.'),
    (Icons.touch_app_outlined, 'Easy to use',
        'Clear layouts and thoughtful interactions that make everyday tasks simpler.'),
    (Icons.cable_rounded, 'Connected systems',
        'Bring your website, applications and business workflows together.'),
    (Icons.trending_up_rounded, 'Room to grow',
        'A considered technical foundation for your next stage of growth.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.xxl, AppSpacing.page, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(header: true, child: Text('Good technology. A clear purpose.', style: context.text.headlineSmall)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Your digital tools should make business easier. We bring design and development '
            'together with a focus on the people using them.',
            style: context.text.bodyMedium?.copyWith(color: context.brand.muted),
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final (icon, title, body) in _items)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: context.colors.secondaryContainer,
                      borderRadius: BorderRadius.circular(AppRadius.chip),
                    ),
                    child: Icon(icon, size: 20, color: context.colors.onSecondaryContainer),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: context.text.titleMedium),
                        const SizedBox(height: 2),
                        Text(body, style: context.text.bodyMedium?.copyWith(color: context.brand.muted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
