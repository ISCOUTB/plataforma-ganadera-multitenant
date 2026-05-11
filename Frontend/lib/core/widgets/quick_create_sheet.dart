import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../l10n/app_localizations.dart';

class QuickCreateSheet extends StatelessWidget {
  const QuickCreateSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    
    return SafeArea(
      top: false,
      child: Padding(
        // Reducimos un poco el padding vertical para ganar espacio
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12), 
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle de arrastre (Fijo arriba)
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Usamos Flexible + SingleChildScrollView para el contenido
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(S.of(context).quickCreate,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(S.of(context).quickCreateSubtitle,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: cs.onSurfaceVariant)),
                    const SizedBox(height: 20),
                    _CreateAction(
                      icon: PhosphorIcons.cow(PhosphorIconsStyle.fill),
                      label: S.of(context).newAnimalQuick,
                      hint: S.of(context).newAnimalHint,
                      onTap: () => _navigate(context, '/inventory/animales/new'),
                    ),
                    const SizedBox(height: 10),
                    _CreateAction(
                      icon: PhosphorIcons.barn(PhosphorIconsStyle.fill),
                      label: S.of(context).newFarmQuick,
                      hint: S.of(context).newFarmHint,
                      onTap: () => _navigate(context, '/inventory/fincas/new'),
                    ),
                    const SizedBox(height: 10),
                    _CreateAction(
                      icon: PhosphorIcons.plant(PhosphorIconsStyle.fill),
                      label: S.of(context).newPaddockQuick,
                      hint: S.of(context).newPaddockHint,
                      onTap: () => _navigate(context, '/inventory/potreros/new'),
                    ),
                    const SizedBox(height: 10),
                    _CreateAction(
                      icon: PhosphorIcons.firstAidKit(PhosphorIconsStyle.fill),
                      label: S.of(context).newHealthQuick,
                      hint: S.of(context).newHealthHint,
                      onTap: () => _navigate(context, '/health/salud/new'),
                    ),
                    const SizedBox(height: 10),
                    _CreateAction(
                      icon: PhosphorIcons.wallet(PhosphorIconsStyle.fill),
                      label: S.of(context).newFinanceQuick,
                      hint: S.of(context).newFinanceHint,
                      onTap: () => _navigate(context, '/money/finanzas/new'),
                    ),
                    const SizedBox(height: 10),
                    _CreateAction(
                      icon: PhosphorIcons.arrowsLeftRight(PhosphorIconsStyle.fill),
                      label: S.of(context).newTransferQuick,
                      hint: S.of(context).newTransferHint,
                      onTap: () => _navigate(context, '/money/movimientos/new'),
                    ),
                    // Espacio extra al final para que el último botón no quede pegado al borde
                    const SizedBox(height: 12), 
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigate(BuildContext context, String path) {
    Navigator.of(context).pop();
    context.push(path);
  }
}


class _CreateAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final String hint;
  final VoidCallback onTap;

  const _CreateAction({
    required this.icon,
    required this.label,
    required this.hint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: PhosphorIcon(icon, color: cs.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hint,
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: cs.onSurfaceVariant,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
