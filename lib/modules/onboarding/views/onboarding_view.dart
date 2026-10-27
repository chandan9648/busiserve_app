import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/brand_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/hex_shape.dart';
import '../controllers/onboarding_controller.dart';
import '../models/onboarding_page.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.md, AppSpacing.sm, 0),
              child: Row(
                children: [
                  const BrandLogo(height: 44),
                  const Spacer(),
                  Obx(
                    () => AnimatedOpacity(
                      opacity: controller.isLast ? 0 : 1,
                      duration: const Duration(milliseconds: 200),
                      child: TextButton(
                        onPressed: controller.isLast ? null : controller.finish,
                        child: const Text('Skip'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                itemCount: controller.pages.length,
                itemBuilder: (_, i) => _PageContent(page: controller.pages[i]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.page, 0, AppSpacing.page, AppSpacing.xl),
              child: Obx(
                () => Column(
                  children: [
                    Semantics(
                      label: 'Page ${controller.page.value + 1} of ${controller.pages.length}',
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (var i = 0; i < controller.pages.length; i++)
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              height: 6,
                              width: controller.page.value == i ? 28 : 8,
                              decoration: BoxDecoration(
                                gradient: controller.page.value == i ? AppColors.arrow : null,
                                color: controller.page.value == i ? null : context.brand.line,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppButton(
                      label: controller.isLast ? 'Get started' : 'Next',
                      icon: controller.isLast ? Icons.check_rounded : null,
                      onPressed: controller.next,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageContent extends StatelessWidget {
  const _PageContent({required this.page});
  final OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page + 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.xxxl),
          SizedBox(
            height: 220,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 10,
                  child: HexBadge(icon: page.icon, size: 150, gradient: AppColors.hero),
                ),
                const Positioned(
                  left: 118,
                  top: 0,
                  child: HexBadge(icon: Icons.north_east_rounded, size: 64, gradient: AppColors.arrow),
                ),
                const Positioned(
                  left: 128,
                  top: 140,
                  child: HexBadge(icon: Icons.bolt_rounded, size: 46, gradient: AppColors.circuit),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(page.title, style: context.text.displaySmall),
          const SizedBox(height: AppSpacing.lg),
          Text(page.body, style: context.text.bodyLarge?.copyWith(color: context.brand.muted)),
        ],
      ),
    );
  }
}
