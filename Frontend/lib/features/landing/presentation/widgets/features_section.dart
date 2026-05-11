import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Grid de funcionalidades. Hover-aware en desktop (cambia paleta).
class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key});

  static const _features = [
    _FeatureData(
      icon: Icons.pets_rounded,
      title: 'Inventario de ganado',
      desc:
          'Control total de tu hato con filtros por raza, género, estado y potrero. Historial de costos por animal.',
    ),
    _FeatureData(
      icon: Icons.medical_services_rounded,
      title: 'Control sanitario',
      desc:
          'Registra vacunas, desparasitaciones y enfermedades. Alertas automáticas de próximas aplicaciones.',
    ),
    _FeatureData(
      icon: Icons.account_balance_wallet_rounded,
      title: 'Finanzas integradas',
      desc:
          'Ingresos, gastos y balance en tiempo real. La venta de un animal crea el movimiento financiero automáticamente.',
    ),
    _FeatureData(
      icon: Icons.grass_rounded,
      title: 'Potreros inteligentes',
      desc:
          'Monitorea la ocupación de cada potrero con gauge visual. Rotación programada y control de capacidad.',
    ),
    _FeatureData(
      icon: Icons.notifications_active_rounded,
      title: 'Alertas en tiempo real',
      desc:
          'Centro consolidado con priorización por severidad. Vacunas vencidas, partos próximos, celos detectados.',
    ),
    _FeatureData(
      icon: Icons.business_rounded,
      title: 'Multi-tenant',
      desc:
          'Cada finca opera de forma aislada. Un superadmin gestiona todos los tenants desde un panel centralizado.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final isTablet = constraints.maxWidth < 900;
        final crossCount = isMobile ? 1 : (isTablet ? 2 : 3);

        return Container(
          width: double.infinity,
          color: const Color(0xFFF8FAFC),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 24 : 48,
                  vertical: isMobile ? 60 : 100,
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFF1E3A5F).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'FUNCIONALIDADES',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          color: const Color(0xFF1E3A5F),
                        ),
                      ),
                    ).animate().fadeIn(duration: 500.ms),
                    const SizedBox(height: 16),
                    Text(
                      'Todo lo que necesitas\npara gestionar tu finca',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isMobile ? 28 : 40,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0F172A),
                        height: 1.1,
                        letterSpacing: -1.5,
                      ),
                    ).animate().fadeIn(duration: 500.ms, delay: 100.ms),
                    const SizedBox(height: 56),
                    Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      children: List.generate(_features.length, (i) {
                        final f = _features[i];
                        final cardWidth = crossCount == 1
                            ? constraints.maxWidth - 48
                            : crossCount == 2
                                ? (constraints.maxWidth - 96 - 20) / 2
                                : (constraints.maxWidth - 96 - 40) / 3;
                        return SizedBox(
                          width: cardWidth.clamp(0, 380).toDouble(),
                          child: _FeatureCard(data: f, index: i),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FeatureData {
  final IconData icon;
  final String title;
  final String desc;
  const _FeatureData({
    required this.icon,
    required this.title,
    required this.desc,
  });
}

class _FeatureCard extends StatefulWidget {
  final _FeatureData data;
  final int index;
  const _FeatureCard({required this.data, required this.index});

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: _hovered ? const Color(0xFF1E3A5F) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _hovered ? Colors.transparent : const Color(0xFFE2E8F0),
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: const Color(0xFF1E3A5F).withValues(alpha: 0.2),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _hovered
                    ? const Color(0xFF3B82F6).withValues(alpha: 0.2)
                    : const Color(0xFF1E3A5F).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                widget.data.icon,
                color: _hovered
                    ? const Color(0xFF93C5FD)
                    : const Color(0xFF1E3A5F),
                size: 24,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.data.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _hovered ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.data.desc,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: _hovered
                    ? Colors.white.withValues(alpha: 0.65)
                    : const Color(0xFF64748B),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(
          duration: 500.ms,
          delay: Duration(milliseconds: 150 + widget.index * 100),
        )
        .slideY(begin: 0.15, end: 0);
  }
}
