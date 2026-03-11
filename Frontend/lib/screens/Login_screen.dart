import 'package:flutter/material.dart';
import '../components/input_field.dart';
import '../components/primary_button.dart';
import '../services/api_service.dart';
import 'Registro_screen.dart';
import 'Dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _api = ApiService();
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    setState(() { _loading = true; _error = null; });
    try {
      await _api.login(_emailCtrl.text.trim(), _passCtrl.text.trim());
      if (mounted) {
        Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()));
      }
    } catch (e) {
      setState(() { _error = 'Correo o contraseña incorrectos'; });
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
                    const Text("Inicia sesión",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 32),
                    _label("Correo electrónico"),
                    InputField(hint: "correo@ejemplo.com",
                      icon: Icons.email_outlined, controller: _emailCtrl),
                    const SizedBox(height: 20),
                    _label("Contraseña"),
                    InputField(hint: "Tu contraseña",
                      icon: Icons.lock_outline, obscure: true, controller: _passCtrl),
                    const SizedBox(height: 12),
                    const Align(alignment: Alignment.centerRight,
                      child: Text("¿Olvidaste tu contraseña?",
                        style: TextStyle(color: Color(0xFF2E7D32)))),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                    ],
                    const SizedBox(height: 24),
                    _loading
                      ? const CircularProgressIndicator()
                      : PrimaryButton(text: "Entrar", onPressed: _login),
                    const SizedBox(height: 20),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Text("¿No tienes cuenta? "),
                      GestureDetector(
                        onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const RegistroScreen())),
                        child: const Text("Registrarse",
                          style: TextStyle(color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.w600)),
                      ),
                    ]),
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
    child: Align(alignment: Alignment.centerLeft,
      child: Text(text,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500))));
}
