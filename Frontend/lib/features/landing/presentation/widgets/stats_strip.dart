import 'package:flutter/material.dart';

/// Banda con métricas animadas (count-up) sobre fondo oscuro.
class StatsStrip extends StatelessWidget {
  const StatsStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            vertical: isMobile ? 48 : 60,
            horizontal: isMobile ? 24 : 48,
          ),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E3A5F), Color(0xFF0F2440)],
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Wrap(
                alignment: WrapAlignment.spaceAround,
                spacing: isMobile ? 32 : 48,
                runSpacing: 32,
                children: const [
                  _AnimatedStat(
                      end: 10000, suffix: '+', label: 'Animales gestionados'),
                  _AnimatedStat(end: 500, suffix: '+', label: 'Fincas'),
                  _AnimatedStat(end: 99, suffix: '.9%', label: 'Uptime'),
                  _AnimatedStat(end: 2, suffix: '', label: 'Idiomas'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AnimatedStat extends StatefulWidget {
  final int end;
  final String suffix;
  final String label;

  const _AnimatedStat({
    required this.end,
    required this.suffix,
    required this.label,
  });

  @override
  State<_AnimatedStat> createState() => _AnimatedStatState();
}

class _AnimatedStatState extends State<_AnimatedStat>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        final val = (_anim.value * widget.end).round();
        return Column(
          children: [
            Text(
              '$val${widget.suffix}',
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ],
        );
      },
    );
  }
}
