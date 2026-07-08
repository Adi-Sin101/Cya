import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_mode_provider.dart';
import 'cya_app.dart';
import 'splash_sprite_animation.dart';

class CyaBootstrap extends ConsumerStatefulWidget {
  const CyaBootstrap({super.key});

  @override
  ConsumerState<CyaBootstrap> createState() => _CyaBootstrapState();
}

class _CyaBootstrapState extends ConsumerState<CyaBootstrap> {
  bool _showApp = false;

  void _finishSplash() {
    if (_showApp || !mounted) return;
    setState(() => _showApp = true);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: _showApp
          ? const CyaApp(key: ValueKey('app'))
          : MaterialApp(
              key: const ValueKey('splash'),
              title: 'Cya!',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: ref.watch(themeModeProvider),
              home: _SplashView(onSkip: _finishSplash),
            ),
    );
  }
}

class _SplashView extends StatelessWidget {
  const _SplashView({required this.onSkip});

  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sage,
      body: SafeArea(
        child: Center(
          child: GestureDetector(
            onTap: onSkip,
            child: SizedBox.square(
              dimension: 300,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // Match the sprite frame's off-white background so the scaled
                  // square blends seamlessly into the circle.
                  color: const Color(0xFFFDFBF9),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 32,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                child: ClipOval(
                  // The sprite frame is square (mascot + "Cya!" + slogan). To keep
                  // ALL of it inside the circle, inset it to the circle's inscribed
                  // square (side = D/√2 ≈ 212 for D=300); 46px padding leaves margin.
                  child: Padding(
                    padding: const EdgeInsets.all(46),
                    child: SplashSpriteAnimation(onComplete: onSkip),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
