import 'package:flutter/material.dart';

/// FAB cuadrado con esquinas redondeadas (squircle), no circular.
class AppSquircleFab extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final double size;

  const AppSquircleFab({
    super.key,
    required this.onPressed,
    this.icon = Icons.add,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.primary,
      borderRadius: BorderRadius.circular(18),
      elevation: 6,
      shadowColor: cs.primary.withValues(alpha: 0.35),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, color: cs.onPrimary, size: 30),
        ),
      ),
    );
  }
}
