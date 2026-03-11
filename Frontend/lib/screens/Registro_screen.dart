import 'package:flutter/material.dart';
import '../components/input_field.dart';
import '../components/primary_button.dart';
import '../services/api_service.dart';
import 'Dashboard_screen.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});
  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _nombreCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _api = ApiService();
  bool _loading = false;
  bool _terminos = false;
  String? _error;

  Future<void> _registro() async {
    if (_passCtrl.text != _confirmCtrl.text) {
      setState(() { _error = 'Las contraseñas no coinciden'; });
      return;
    }
    if (!_terminos) {
      setState(() { _error = 'Debes aceptar los términos y condiciones'; });
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await _api.registro(_emailCtrl.text.trim(),
        _passCtrl.text.trim(), _nombreCtrl.text.trim());
      if (mounted) {
        Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()));
      }
    } catch (e) {
      setState(() { _error = 'Error al registrar. El correo ya existe.'; });
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text("FarmLink",
                      style: TextStyle(color: Color(0xFF2E7D32),
                        fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text("Crea tu cuenta",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 32),
                    _label("Nombre completo"),
                    InputField(hint: "Ingresa tu nombre completo",
                      icon: Icons.person_outline, controller: _nombreCtrl),
                    const SizedBox(height: 20),
                    _label("Correo electrónico"),
                    InputField(hint: "correo@ejemplo.com",
                      icon: Icons.email_outlined, controller: _emailCtrl),
                    const SizedBox(height: 20),
                    _label("Contraseña"),
                    InputField(hint: "Mínimo 8 caracteres",
                      icon: Icons.lock_outline, obscure: true, controller: _passCtrl),
                    const SizedBox(height: 20),
                    _label("Confirmar contraseña"),
                    InputField(hint: "Repite tu contraseña",
                      icon: Icons.lock_outline, obscure: true, controller: _confirmCtrl),
                    const SizedBox(height: 20),
                    if (_error != null) ...[
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 12),
                    ],
                    Row(children: [
                      Checkbox(
                        value: _terminos,
                        onChanged: (v) => setState(() { _terminos = v ?? false; }),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                      ),
                      const Text("Acepto los "),
                      const Text("términos y condiciones",
                        style: TextStyle(color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.w600)),
                    ]),
                    const SizedBox(height: 24),
                    _loading
                      ? const CircularProgressIndicator()
                      : PrimaryButton(text: "Registrarse", onPressed: _registro),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)));
}
