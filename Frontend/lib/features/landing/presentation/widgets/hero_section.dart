import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Bloque superior de la landing: fondo degradado, headline, CTAs y
/// "floating cards" con métricas demo. Es la entrada visual principal.
class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        final isMobile = constraints.maxWidth < 600;

        return Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0F2440),
                Color(0xFF1E3A5F),
                Color(0xFF1A3355),
              ],
            ),
          ),
          child: Stack(
            children: [
              const Positioned.fill(child: _GeometricPattern()),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      isMobile ? 24 : 48,
                      isMobile ? 80 : 120,
                      isMobile ? 24 : 48,
                      isMobile ? 60 : 100,
                    ),
                    child: isWide
                        ? const Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 5,
                                child: _HeroText(isMobile: false),
                              ),
                              SizedBox(width: 60),
                              Expanded(
                                flex: 4,
                                child: _FloatingCards(),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              _HeroText(isMobile: isMobile),
                              const SizedBox(height: 48),
                              const _FloatingCards(),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GeometricPattern extends StatelessWidget {
  const _GeometricPattern();

  @override
  Widget build(BuildContext context) => CustomPaint(painter: _PatternPainter());
}

class _PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (double i = -size.height; i < size.width + size.height; i += 80) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }

    final circlePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.02)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.3),
      size.width * 0.25,
      circlePaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.8),
      size.width * 0.15,
      circlePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HeroText extends StatelessWidget {
  final bool isMobile;
  const _HeroText({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment:
          isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF3B82F6),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Plataforma SaaS Multitenant',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: const Color(0xFF93C5FD),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(duration: 600.ms, delay: 200.ms)
            .slideY(begin: 0.3, end: 0),
        const SizedBox(height: 28),
        Text(
          'Gestión ganadera\ninteligente',
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
          style: TextStyle(
            fontSize: isMobile ? 36 : 56,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            height: 1.05,
            letterSpacing: -2,
          ),
        )
            .animate()
            .fadeIn(duration: 600.ms, delay: 400.ms)
            .slideY(begin: 0.2, end: 0),
        const SizedBox(height: 20),
        Text(
          'Digitaliza el control de tu hato. Inventario, salud,\nreproducción, finanzas y alertas en una sola plataforma.',
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
          style: TextStyle(
            fontSize: isMobile ? 15 : 18,
            fontWeight: FontWeight.w400,
            color: Colors.white.withValues(alpha: 0.65),
            height: 1.6,
          ),
        )
            .animate()
            .fadeIn(duration: 600.ms, delay: 600.ms)
            .slideY(begin: 0.2, end: 0),
        const SizedBox(height: 40),
        Wrap(
          alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
          spacing: 16,
          runSpacing: 12,
          children: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => context.push('/register'),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color:
                            const Color(0xFF3B82F6).withValues(alpha: 0.4),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Text(
                    'Comenzar gratis',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            )
                .animate()
                .fadeIn(duration: 500.ms, delay: 800.ms)
                .slideY(begin: 0.3, end: 0),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => context.push('/login'),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    'Iniciar sesión',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            )
                .animate()
                .fadeIn(duration: 500.ms, delay: 900.ms)
                .slideY(begin: 0.3, end: 0),
          ],
        ),
      ],
    );
  }
}

class _FloatingCards extends StatelessWidget {
  const _FloatingCards();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 340,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: _StatCard(
              icon: PhosphorIcons.cow(PhosphorIconsStyle.fill),
              label: 'Animales activos',
              value: '450',
              color: const Color(0xFF3B82F6),
            )
                .animate()
                .fadeIn(duration: 600.ms, delay: 700.ms)
                .slideX(begin: -0.2, end: 0)
                .slideY(begin: 0.1, end: 0),
          ),
          Positioned(
            top: 80,
            right: 0,
            child: _StatCard(
              icon: PhosphorIcons.wallet(PhosphorIconsStyle.fill),
              label: 'Balance',
              value: '\$5.05M',
              color: const Color(0xFF10B981),
            )
                .animate()
                .fadeIn(duration: 600.ms, delay: 900.ms)
                .slideX(begin: 0.2, end: 0)
                .slideY(begin: -0.1, end: 0),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: _StatCard(
              icon: PhosphorIcons.barn(PhosphorIconsStyle.fill),
              label: 'Fincas',
              value: '3',
              color: const Color(0xFFF59E0B),
            )
                .animate()
                .fadeIn(duration: 600.ms, delay: 1100.ms)
                .slideY(begin: 0.3, end: 0),
          ),
          Positioned(
            bottom: 80,
            right: 30,
            child: _StatCard(
              icon: PhosphorIcons.bell(PhosphorIconsStyle.fill),
              label: 'Alertas',
              value: '12',
              color: const Color(0xFFEF4444),
              compact: true,
            )
                .animate()
                .fadeIn(duration: 600.ms, delay: 1300.ms)
                .slideX(begin: 0.3, end: 0),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool compact;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 16 : 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2E4A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: compact ? 36 : 44,
            height: compact ? 36 : 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: compact ? 18 : 22),
          ),
          SizedBox(width: compact ? 10 : 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: compact ? 20 : 26,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: compact ? 11 : 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
