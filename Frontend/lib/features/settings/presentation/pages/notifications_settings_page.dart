import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsSettingsPage extends StatefulWidget {
  const NotificationsSettingsPage({super.key});

  @override
  State<NotificationsSettingsPage> createState() =>
      _NotificationsSettingsPageState();
}

class _NotificationsSettingsPageState
    extends State<NotificationsSettingsPage> {
  bool _salud = true;
  bool _reproduccion = true;
  bool _finanzas = false;
  bool _potreros = true;

  static const _keySalud = 'notif_salud';
  static const _keyRepro = 'notif_reproduccion';
  static const _keyFinanzas = 'notif_finanzas';
  static const _keyPotreros = 'notif_potreros';

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _salud = prefs.getBool(_keySalud) ?? true;
      _reproduccion = prefs.getBool(_keyRepro) ?? true;
      _finanzas = prefs.getBool(_keyFinanzas) ?? false;
      _potreros = prefs.getBool(_keyPotreros) ?? true;
    });
  }

  Future<void> _save(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: 0,
      ),
      backgroundColor: cs.surfaceBright,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        children: [
          Text(
            'Elige qué alertas quieres recibir',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          _SectionLabel('ALERTAS DE SALUD'),
          _NotifTile(
            icon: PhosphorIcons.heartbeat(PhosphorIconsStyle.bold),
            title: 'Salud animal',
            subtitle: 'Vacunas vencidas, enfermedades y desparasitaciones',
            value: _salud,
            color: cs.error,
            onChanged: (v) {
              setState(() => _salud = v);
              _save(_keySalud, v);
            },
          ),
          const SizedBox(height: 8),
          _SectionLabel('REPRODUCCIÓN'),
          _NotifTile(
            icon: PhosphorIcons.baby(PhosphorIconsStyle.bold),
            title: 'Reproducción',
            subtitle: 'Partos próximos, celos detectados y eventos vencidos',
            value: _reproduccion,
            color: const Color(0xFF9C27B0),
            onChanged: (v) {
              setState(() => _reproduccion = v);
              _save(_keyRepro, v);
            },
          ),
          const SizedBox(height: 8),
          _SectionLabel('FINANZAS'),
          _NotifTile(
            icon: PhosphorIcons.currencyDollar(PhosphorIconsStyle.bold),
            title: 'Alertas financieras',
            subtitle: 'Movimientos importantes y balance crítico',
            value: _finanzas,
            color: const Color(0xFF2E7D32),
            onChanged: (v) {
              setState(() => _finanzas = v);
              _save(_keyFinanzas, v);
            },
          ),
          const SizedBox(height: 8),
          _SectionLabel('POTREROS'),
          _NotifTile(
            icon: PhosphorIcons.mapTrifold(PhosphorIconsStyle.bold),
            title: 'Ocupación de potreros',
            subtitle: 'Potreros llenos o con capacidad crítica',
            value: _potreros,
            color: const Color(0xFFF59E0B),
            onChanged: (v) {
              setState(() => _potreros = v);
              _save(_keyPotreros, v);
            },
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: cs.onSurfaceVariant,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final Color color;
  final ValueChanged<bool> onChanged;

  const _NotifTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: SwitchListTile(
        secondary: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
        value: value,
        activeColor: cs.primary,
        onChanged: onChanged,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}