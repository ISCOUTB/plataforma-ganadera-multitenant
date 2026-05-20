import 'package:flutter/material.dart';

import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Bottom navigation bar del shell. Conectado al router vía
/// [currentLocation] (string que viene de `state.matchedLocation`) y
/// [onTap] que recibe el path destino.
class HomeBottomNav extends StatelessWidget {
  final String currentLocation;
  final ValueChanged<String> onTap;

  const HomeBottomNav({
    super.key,
    required this.currentLocation,
    required this.onTap,
  });

  static const _items = <_NavItem>[
    _NavItem(
      icon: Icons.home_rounded,
      label: 'HOME',
      path: RoutePaths.home,
    ),
    _NavItem(
      icon: Icons.inventory_2_outlined,
      label: 'INVENTORY',
      path: RoutePaths.inventory,
    ),
    _NavItem(
      icon: Icons.medical_services_outlined,
      label: 'HEALTH',
      path: RoutePaths.health,
    ),
    _NavItem(
      icon: Icons.account_balance_wallet_outlined,
      label: 'MONEY',
      path: RoutePaths.money,
    ),
    _NavItem(
      icon: Icons.settings_outlined,
      label: 'SETTINGS',
      path: RoutePaths.settings,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(
          top: BorderSide(color: cs.outline, width: 1),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(4, 10, 4, 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (final item in _items)
            Expanded(
              child: _NavButton(
                item: item,
                active: currentLocation.startsWith(item.path),
                onTap: () => onTap(item.path),
              ),
            ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String path;
  const _NavItem({
    required this.icon,
    required this.label,
    required this.path,
  });
}

class _NavButton extends StatelessWidget {
  final _NavItem item;
  final bool active;
  final VoidCallback onTap;

  const _NavButton({
    required this.item,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = active ? cs.primary : cs.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: active ? cs.primary.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.fade,
              style: AppTextStyles.navLabel.copyWith(
                color: color,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
