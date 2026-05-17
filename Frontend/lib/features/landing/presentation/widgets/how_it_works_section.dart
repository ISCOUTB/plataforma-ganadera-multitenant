import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Sección "tres pasos para empezar".
class HowItWorksSection extends StatelessWidget {
  const HowItWorksSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final isWide = constraints.maxWidth >= 900;

        return Container(
          width: double.infinity,
          color: const Color(0xFFF8FAFC),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
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
                            const Color(0xFF1B4D1E).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'CÓMO FUNCIONA',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          color: const Color(0xFF1B4D1E),
                        ),
                      ),
                    ).animate().fadeIn(duration: 500.ms),
                    const SizedBox(height: 16),
                    Text(
                      'Tres pasos para empezar',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isMobile ? 28 : 40,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -1.5,
                      ),
                    ).animate().fadeIn(duration: 500.ms, delay: 100.ms),
                    const SizedBox(height: 56),
                    isWide
                        ? const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _StepCard(
                                  number: '01',
                                  title: 'Registra tu finca',
                                  desc:
                                      'Crea tu cuenta, define tu tenant y configura los datos de tu predio.',
                                  index: 0,
                                ),
                              ),
                              _Connector(),
                              Expanded(
                                child: _StepCard(
                                  number: '02',
                                  title: 'Agrega tu ganado',
                                  desc:
                                      'Registra animales, potreros y configura los parámetros sanitarios.',
                                  index: 1,
                                ),
                              ),
                              _Connector(),
                              Expanded(
                                child: _StepCard(
                                  number: '03',
                                  title: 'Gestiona todo',
                                  desc:
                                      'Dashboard con métricas, alertas y control financiero en tiempo real.',
                                  index: 2,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: const [
                              _StepCard(
                                number: '01',
                                title: 'Registra tu finca',
                                desc:
                                    'Crea tu cuenta, define tu tenant y configura los datos de tu predio.',
                                index: 0,
                              ),
                              SizedBox(height: 24),
                              _StepCard(
                                number: '02',
                                title: 'Agrega tu ganado',
                                desc:
                                    'Registra animales, potreros y configura los parámetros sanitarios.',
                                index: 1,
                              ),
                              SizedBox(height: 24),
                              _StepCard(
                                number: '03',
                                title: 'Gestiona todo',
                                desc:
                                    'Dashboard con métricas, alertas y control financiero en tiempo real.',
                                index: 2,
                              ),
                            ],
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

class _Connector extends StatelessWidget {
  const _Connector();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: SizedBox(
        width: 60,
        child: Center(
          child: Container(
            height: 2,
            width: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF2E7D32).withValues(alpha: 0.1),
                  const Color(0xFF2E7D32).withValues(alpha: 0.5),
                  const Color(0xFF2E7D32).withValues(alpha: 0.1),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final String number;
  final String title;
  final String desc;
  final int index;

  const _StepCard({
    required this.number,
    required this.title,
    required this.desc,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1B4D1E), Color(0xFF2E7D32)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        )
            .animate()
            .fadeIn(
              duration: 500.ms,
              delay: Duration(milliseconds: 200 + index * 150),
            )
            .scale(
              begin: const Offset(0.7, 0.7),
              end: const Offset(1, 1),
              curve: Curves.easeOutBack,
            ),
        const SizedBox(height: 20),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ).animate().fadeIn(
              duration: 500.ms,
              delay: Duration(milliseconds: 300 + index * 150),
            ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            desc,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF64748B),
              height: 1.5,
            ),
          ),
        ).animate().fadeIn(
              duration: 500.ms,
              delay: Duration(milliseconds: 400 + index * 150),
            ),
      ],
    );
  }
}
