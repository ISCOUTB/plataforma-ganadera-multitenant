import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/section_header.dart';
import '../../domain/entities/alertas_summary.dart';
import '../bloc/alertas_bloc.dart';

class AlertasPage extends StatelessWidget {
  const AlertasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AlertasBloc>(
      create: (_) => getIt<AlertasBloc>()..add(const AlertasStarted()),
      child: const _AlertasView(),
    );
  }
}

class _AlertasView extends StatelessWidget {
  const _AlertasView();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      bottom: false,
      child: BlocBuilder<AlertasBloc, AlertasState>(
        builder: (context, state) {
          return switch (state.status) {
            AlertasStatus.initial ||
            AlertasStatus.loading =>
              const AppLoading(),
            AlertasStatus.error => AppErrorView(
                failure: state.failure!,
                onRetry: () =>
                    context.read<AlertasBloc>().add(const AlertasRefreshed()),
              ),
            AlertasStatus.loaded => _buildContent(context, state.data!, cs),
          };
        },
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, AlertasSummary data, ColorScheme cs) {
    return RefreshIndicator(
      color: cs.primary,
      onRefresh: () async {
        context.read<AlertasBloc>().add(const AlertasRefreshed());
      },
      child: ListView(
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          const SectionHeader(
            title: 'Alertas',
            subtitle: 'Centro consolidado de urgencias',
            showBack: true,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _SummaryHeader(data: data),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: _MiniCard(
                    icon: Icons.vaccines_rounded,
                    label: 'Salud vencida',
                    value: '${data.saludVencidas}',
                    color: cs.error,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MiniCard(
                    icon: Icons.schedule_rounded,
                    label: 'Salud próxima',
                    value: '${data.saludProximas}',
                    color: cs.tertiary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: _MiniCard(
                    icon: PhosphorIcons.heart(PhosphorIconsStyle.fill),
                    label: 'Partos próximos',
                    value: '${data.partosProximos}',
                    color: cs.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MiniCard(
                    icon: PhosphorIcons.flame(PhosphorIconsStyle.fill),
                    label: 'En celo',
                    value: '${data.enCelo}',
                    color: cs.secondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (data.alertasPriorizadas.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Text(
                'PRIORIZADAS',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: cs.onSurface,
                    ),
              ),
            ),
            for (final alerta in data.alertasPriorizadas)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: _PriorityRow(alerta: alerta),
              ),
          ],
        ],
      ),
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  final AlertasSummary data;
  const _SummaryHeader({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${data.totalAlertas}',
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: cs.onSurface,
                  height: 1,
                ),
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'alertas activas',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (data.urgentes > 0)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: cs.error.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${data.urgentes} urgente(s) — requieren atención',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: cs.error,
                  fontWeight: FontWeight.w800,
                ),
              ),
            )
          else
            Text(
              'Todo bajo control',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}

class _MiniCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MiniCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: cs.onSurface,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriorityRow extends StatelessWidget {
  final AlertaPrioritaria alerta;
  const _PriorityRow({required this.alerta});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final color = switch (alerta.severity) {
      AlertaSeverity.high => cs.error,
      AlertaSeverity.medium => cs.tertiary,
      AlertaSeverity.low => cs.primary,
    };
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: color, width: 4),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alerta.tipo.replaceAll('_', ' ').toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: color,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _describe(alerta.detalle),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              alerta.severity.label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _describe(Map<String, dynamic> detalle) {
    return detalle['producto_aplicado']?.toString() ??
        detalle['descripcion_enfermedad']?.toString() ??
        detalle['tipo_intervencion']?.toString() ??
        detalle['pk_id_reproduccion']?.toString() ??
        'Sin detalle';
  }
}
