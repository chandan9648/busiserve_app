import 'dart:math' show min;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/company_info.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common.dart';
import '../controllers/splash_controller.dart';

/// Branded launch moment shown while the first app route is prepared.
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1150),
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
    final logoIn = CurvedAnimation(
      parent: _anim,
      curve: const Interval(0, .68, curve: Curves.easeOutBack),
    );
    final copyIn = CurvedAnimation(
      parent: _anim,
      curve: const Interval(.22, .78, curve: Curves.easeOutCubic),
    );
    final progress = CurvedAnimation(
      parent: _anim,
      curve: const Interval(.42, 1, curve: Curves.easeInOutCubic),
    );
    final screenSize = MediaQuery.sizeOf(context);
    final isCompact = screenSize.height < 620;
    final logoDiameter = min(
      190.0,
      min(screenSize.height * .32, screenSize.width - 56),
    );
    final markSize = min(screenSize.width * .30, logoDiameter * .68)
        .clamp(64.0, 132.0)
        .toDouble();

    return Scaffold(
      backgroundColor: AppColors.inkDeep,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(gradient: AppColors.hero),
          ),
          const _AmbientGlow(
            alignment: Alignment(-1.12, -0.92),
            color: AppColors.sky,
            diameter: 300,
          ),
          const _AmbientGlow(
            alignment: Alignment(1.18, .72),
            color: AppColors.flame,
            diameter: 260,
          ),
          IgnorePointer(
            child: Center(
              child: Container(
                width: 310,
                height: 310,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: Colors.white.withValues(alpha: .045)),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 28,
                vertical: isCompact ? 12 : 22,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        size: 15,
                        color: AppColors.amber.withValues(alpha: .95),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'DIGITAL INNOVATION',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: .68),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.4,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(flex: 3),
                  FadeTransition(
                    opacity: logoIn,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: .78, end: 1).animate(logoIn),
                      child: Container(
                        width: logoDiameter,
                        height: logoDiameter,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: .075),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: .19),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.sky.withValues(alpha: .18),
                              blurRadius: 48,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Center(
                          child: BrandLogo(height: markSize, markOnly: true),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: isCompact ? 17 : 34),
                  FadeTransition(
                    opacity: copyIn,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, .14),
                        end: Offset.zero,
                      ).animate(copyIn),
                      child: Column(
                        children: [
                          Text(
                            'BUSISERVE',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isCompact ? 25 : 29,
                              height: 1.05,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 3.4,
                            ),
                          ),
                          const SizedBox(height: 9),
                          Text(
                            'INFOTECH SOLUTION',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.sky.withValues(alpha: .95),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 3.1,
                            ),
                          ),
                          SizedBox(height: isCompact ? 12 : 22),
                          Text(
                            CompanyInfo.tagline,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: .72),
                              fontSize: 14,
                              height: 1.5,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(flex: 3),
                  FadeTransition(
                    opacity: copyIn,
                    child: Column(
                      children: [
                        Text(
                          'BUILDING WHAT\'S NEXT',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: .52),
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.2,
                          ),
                        ),
                        SizedBox(height: isCompact ? 8 : 13),
                        Container(
                          width: isCompact ? 96 : 116,
                          height: 3,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .13),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.centerLeft,
                          child: SizeTransition(
                            sizeFactor: progress,
                            axis: Axis.horizontal,
                            alignment: Alignment.centerLeft,
                            child: Container(
                              width: isCompact ? 96 : 116,
                              height: 3,
                              decoration: BoxDecoration(
                                gradient: AppColors.arrow,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        AppColors.amber.withValues(alpha: .45),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          CompanyInfo.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: .38),
                            fontSize: 10,
                            letterSpacing: .25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow({
    required this.alignment,
    required this.color,
    required this.diameter,
  });

  final Alignment alignment;
  final Color color;
  final double diameter;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: alignment,
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 54, sigmaY: 54),
          child: Container(
            width: diameter,
            height: diameter,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  color.withValues(alpha: .27),
                  color.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
