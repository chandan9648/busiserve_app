import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/company_info.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/brand_tokens.dart';
import '../../../core/widgets/common.dart';
import '../controllers/splash_controller.dart';

/// The one orchestrated motion moment in the app: the logo settles in while
/// the growth arrow line draws underneath.
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void initState() {
    super.initState();
    Get.find<SplashController>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _anim.value = 1;
    } else if (!_anim.isAnimating && _anim.value == 0) {
      _anim.forward();
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logoIn = CurvedAnimation(parent: _anim, curve: const Interval(0, 0.7, curve: Curves.easeOutBack));
    final lineIn = CurvedAnimation(parent: _anim, curve: const Interval(0.45, 1, curve: Curves.easeOutCubic));
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 3),
            FadeTransition(
              opacity: logoIn,
              child: ScaleTransition(
                scale: Tween(begin: 0.86, end: 1.0).animate(logoIn),
                child: const BrandLogo(height: 190),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizeTransition(
              sizeFactor: lineIn,
              axis: Axis.horizontal,
              child: Container(
                width: 120,
                height: 4,
                decoration: BoxDecoration(
                  gradient: AppColors.arrow,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Spacer(flex: 4),
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xl),
              child: Text(
                'Your digital development partner',
                style: context.text.bodySmall?.copyWith(color: AppColors.textMuted),
                semanticsLabel: '${CompanyInfo.name}. Your digital development partner.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
