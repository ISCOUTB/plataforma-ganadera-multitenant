import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../l10n/app_localizations.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final t = S.of(context);
    return Scaffold(
      backgroundColor: cs.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(24),
              ),
              child: PhosphorIcon(
                PhosphorIcons.cow(PhosphorIconsStyle.fill),
                color: cs.onPrimary,
                size: 44,
              ),
            )
                .animate()
                .scale(
                  begin: const Offset(0.3, 0.3),
                  end: const Offset(1, 1),
                  duration: 600.ms,
                  curve: Curves.easeOutBack,
                )
                .fadeIn(duration: 400.ms),
            const SizedBox(height: 24),
            Text(
              t.appName,
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: cs.onPrimary,
                letterSpacing: -1,
              ),
            )
                .animate()
                .fadeIn(delay: 200.ms, duration: 500.ms)
                .slideY(begin: 0.3, end: 0, duration: 500.ms),
            const SizedBox(height: 8),
            Text(
              t.appSlogan,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onPrimary.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
            const SizedBox(height: 40),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: cs.onPrimary.withValues(alpha: 0.5),
              ),
            ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
          ],
        ),
      ),
    );
  }
}
