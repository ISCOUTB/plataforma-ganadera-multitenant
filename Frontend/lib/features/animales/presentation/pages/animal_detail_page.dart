import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/di/injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/finca_rotation_guard.dart';
import '../../../../core/widgets/section_header.dart';
import '../../domain/entities/animal.dart';
import '../../domain/repositories/animal_repository.dart';
import '../bloc/animal_detail_bloc.dart';
import '../bloc/animales_list_bloc.dart';
import '../widgets/animal_timeline.dart';

class AnimalDetailPage extends StatelessWidget {
  final int animalId;
  const AnimalDetailPage({super.key, required this.animalId});

  @override
  Widget build(BuildContext context) {
    return FincaRotationGuard(
      fallbackRoute: RoutePaths.inventory,
      child: BlocProvider<AnimalDetailBloc>(
        create: (_) =>
            getIt<AnimalDetailBloc>()..add(AnimalDetailLoaded(animalId)),
        child: _AnimalDetailView(animalId: animalId),
      ),
    );
  }
}

class _AnimalDetailView extends StatelessWidget {
  final int animalId;
  const _AnimalDetailView({required this.animalId});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      bottom: false,
      child: BlocConsumer<AnimalDetailBloc, AnimalDetailState>(
        listener: (context, state) {
          final t = S.of(context);
          if (state.status == AnimalDetailStatus.deleted) {
            getIt<AnimalesListBloc>().add(const AnimalesListRefreshed());
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(t.animalDeleted),
                backgroundColor: cs.primary,
              ),
            );
            context.go('/inventory/animales');
          }
          if (state.status == AnimalDetailStatus.sold) {
            getIt<AnimalesListBloc>().add(const AnimalesListRefreshed());
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(t.animalSold),
                backgroundColor: cs.primary,
              ),
            );
          }
          if (state.status == AnimalDetailStatus.error && state.failure != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.failure!.message),
                backgroundColor: cs.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == AnimalDetailStatus.initial ||
              state.status == AnimalDetailStatus.loading) {
            return const AppLoading();
          }
          if (state.animal == null && state.failure != null) {
            return AppErrorView(
              failure: state.failure!,
              onRetry: () => context
                  .read<AnimalDetailBloc>()
                  .add(AnimalDetailLoaded(animalId)),
            );
          }
          final t = S.of(context);
          final a = state.animal!;
          final isVendido = a.estado == AnimalEstado.vendido;
          return ListView(
            padding: const EdgeInsets.only(bottom: 100),
            children: [
              SectionHeader(
                title: a.numeroIdentificacion,
                subtitle: '${a.raza} • ${a.peso.toStringAsFixed(0)} kg',
                showBack: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _IconBtn(
                      icon: Icons.edit_outlined,
                      onTap: () =>
                          context.push('/inventory/animales/${a.id}/edit'),
                    ),
                    const SizedBox(width: 8),
                    _IconBtn(
                      icon: Icons.delete_outline,
                      color: cs.error,
                      onTap: () => _confirmDelete(context),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _DetailRow(
                        icon: PhosphorIcons.genderIntersex(
                            PhosphorIconsStyle.bold),
                        label: t.gender,
                        value: a.genero.label,
                      ),
                      const Divider(height: 24),
                      _DetailRow(
                        icon: PhosphorIcons.calendar(PhosphorIconsStyle.bold),
                        label: t.birthDate,
                        value: a.fechaNacimiento != null
                            ? a.fechaNacimiento!
                                .toIso8601String()
                                .substring(0, 10)
                            : '—',
                      ),
                      const Divider(height: 24),
                      _DetailRow(
                        icon: PhosphorIcons.barn(PhosphorIconsStyle.bold),
                        label: t.farm,
                        value: a.fincaId ?? '—',
                      ),
                      const Divider(height: 24),
                      _DetailRow(
                        icon: PhosphorIcons.plant(PhosphorIconsStyle.bold),
                        label: t.paddock,
                        value: a.potreroId ?? '—',
                      ),
                      const Divider(height: 24),
                      _DetailRow(
                        icon: PhosphorIcons.checkCircle(
                            PhosphorIconsStyle.bold),
                        label: t.status,
                        value: a.estado.label,
                        valueColor: isVendido
                            ? cs.onSurfaceVariant
                            : cs.primary,
                      ),
                    ],
                  ),
                ),
              ),
              if (state.costos != null) ...[
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _CostosCard(costos: state.costos!),
                ),
              ],
              if (!isVendido) ...[
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _QuickActionCard(
                    icon: PhosphorIcons.plant(PhosphorIconsStyle.fill),
                    label: S.of(context).feedingHistory,
                    onTap: () => context
                        .push('/inventory/animales/${a.id}/alimentacion'),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              // Timeline cronológico
              if (state.timeline.isNotEmpty)
                AnimalTimeline(events: state.timeline),
              const SizedBox(height: 24),
              if (!isVendido)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _SellButton(
                    onPressed: () => _openSellSheet(context, a),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final t = S.of(context);
    final cs = Theme.of(context).colorScheme;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.deleteAnimal),
        content: Text(t.deleteAnimalMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: cs.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(t.delete),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      context.read<AnimalDetailBloc>().add(const AnimalDetailDeleted());
    }
  }

  Future<void> _openSellSheet(BuildContext context, Animal a) async {
    final bloc = context.read<AnimalDetailBloc>();
    final cs = Theme.of(context).colorScheme;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
        ),
        child: _SellForm(
          fincaId: a.fincaId,
          onSubmit: (input) {
            bloc.add(AnimalDetailVendido(input));
            Navigator.of(sheetCtx).pop();
          },
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        PhosphorIcon(icon, color: cs.primary, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: valueColor ?? cs.onSurface,
          ),
        ),
      ],
    );
  }
}

class _CostosCard extends StatelessWidget {
  final AnimalCostos costos;
  const _CostosCard({required this.costos});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = S.of(context);
    final fmt = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.accumulatedCosts,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 14),
          _CostRow(label: t.healthCost, value: fmt.format(costos.costoSalud)),
          const SizedBox(height: 8),
          _CostRow(
              label: t.feedingCost,
              value: fmt.format(costos.costoAlimentacion)),
          const Divider(height: 24),
          _CostRow(
            label: t.totalCost,
            value: fmt.format(costos.costoTotal),
            bold: true,
          ),
        ],
      ),
    );
  }
}

class _CostRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _CostRow({required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: bold ? 14 : 13,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
              color: bold ? cs.onSurface : cs.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: bold ? 16 : 14,
            fontWeight: FontWeight.w800,
            color: bold ? cs.primary : cs.onSurface,
          ),
        ),
      ],
    );
  }
}

class _SellButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _SellButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = S.of(context);
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: cs.primary,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.attach_money, color: cs.onPrimary, size: 20),
                const SizedBox(width: 8),
                Text(
                  t.sellAnimal,
                  style: TextStyle(
                    color: cs.onPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SellForm extends StatefulWidget {
  final String? fincaId;
  final ValueChanged<VenderAnimalInput> onSubmit;

  const _SellForm({required this.fincaId, required this.onSubmit});

  @override
  State<_SellForm> createState() => _SellFormState();
}

class _SellFormState extends State<_SellForm> {
  final _formKey = GlobalKey<FormState>();
  final _precioCtrl = TextEditingController();
  final _compradorCtrl = TextEditingController();
  DateTime _fecha = DateTime.now();

  @override
  void dispose() {
    _precioCtrl.dispose();
    _compradorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = S.of(context);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            Text(
              t.sellAnimal,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              t.sellDescription,
              style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _precioCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: t.salePrice,
                hintText: '2500000',
                prefixText: '\$ ',
              ),
              validator: (v) => (v == null || double.tryParse(v) == null)
                  ? 'Ingresa un precio válido'
                  : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _compradorCtrl,
              decoration: InputDecoration(
                labelText: t.buyer,
                hintText: 'Nombre del comprador',
              ),
              validator: (v) =>
                  (v == null || v.isEmpty) ? t.required : null,
            ),
            const SizedBox(height: 14),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: cs.outline),
              ),
              leading: Icon(Icons.calendar_today, color: cs.primary),
              title: Text(t.saleDate),
              subtitle: Text(_fecha.toIso8601String().substring(0, 10)),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _fecha,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now().add(const Duration(days: 1)),
                );
                if (picked != null) setState(() => _fecha = picked);
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (!_formKey.currentState!.validate()) return;
                widget.onSubmit(
                  VenderAnimalInput(
                    precioVenta: double.parse(_precioCtrl.text),
                    comprador: _compradorCtrl.text.trim(),
                    fechaVenta: _fecha,
                    fincaId: widget.fincaId,
                  ),
                );
              },
              child: Text(t.confirmSale),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
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
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: cs.onSurfaceVariant, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  const _IconBtn({required this.icon, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, color: color ?? cs.onSurface, size: 22),
        ),
      ),
    );
  }
}
