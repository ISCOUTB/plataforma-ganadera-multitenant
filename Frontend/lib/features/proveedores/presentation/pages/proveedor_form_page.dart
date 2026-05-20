import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/section_header.dart';
import '../../domain/repositories/proveedores_repository.dart';

class ProveedorFormPage extends StatefulWidget {
  final int? editId;
  const ProveedorFormPage({super.key, this.editId});

  @override
  State<ProveedorFormPage> createState() => _ProveedorFormPageState();
}

class _ProveedorFormPageState extends State<ProveedorFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _contactoCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  final _notasCtrl = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.editId != null) _loadExisting();
  }

  Future<void> _loadExisting() async {
    final p = await getIt<ProveedoresRepository>().getOne(widget.editId!);
    _nombreCtrl.text = p.nombre;
    _contactoCtrl.text = p.contacto ?? '';
    _telefonoCtrl.text = p.telefono ?? '';
    _emailCtrl.text = p.email ?? '';
    _direccionCtrl.text = p.direccion ?? '';
    _notasCtrl.text = p.notas ?? '';
    setState(() {});
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _contactoCtrl.dispose();
    _telefonoCtrl.dispose();
    _emailCtrl.dispose();
    _direccionCtrl.dispose();
    _notasCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final data = {
        'nombre': _nombreCtrl.text.trim(),
        if (_contactoCtrl.text.isNotEmpty) 'contacto': _contactoCtrl.text.trim(),
        if (_telefonoCtrl.text.isNotEmpty) 'telefono': _telefonoCtrl.text.trim(),
        if (_emailCtrl.text.isNotEmpty) 'email': _emailCtrl.text.trim(),
        if (_direccionCtrl.text.isNotEmpty) 'direccion': _direccionCtrl.text.trim(),
        if (_notasCtrl.text.isNotEmpty) 'notas': _notasCtrl.text.trim(),
      };
      if (widget.editId != null) {
        await getIt<ProveedoresRepository>().update(widget.editId!, data);
      } else {
        await getIt<ProveedoresRepository>().create(data);
      }
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Theme.of(context).colorScheme.error),
        );
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          SectionHeader(
            title: widget.editId != null ? 'Editar proveedor' : 'Nuevo proveedor',
            subtitle: 'Datos del proveedor de alimentos',
            showBack: true,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nombreCtrl,
                      decoration: const InputDecoration(labelText: 'Nombre *'),
                      validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _contactoCtrl,
                      decoration: const InputDecoration(labelText: 'Persona de contacto'),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _telefonoCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: 'Teléfono'),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _direccionCtrl,
                      decoration: const InputDecoration(labelText: 'Dirección'),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _notasCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Notas'),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(widget.editId != null ? 'Guardar cambios' : 'Crear proveedor'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}