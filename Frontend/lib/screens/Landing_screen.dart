import 'package:flutter/material.dart';
import 'Login_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF9),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ------------------------------
            // ENCABEZADO / NAVBAR
            // ------------------------------
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // LOGO
                  Row(
                    children: [
                      Image.asset(
                        "assets/Logo.png",
                        height: 40,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "FarmLink",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),

                  // MENÚ (solo visible en pantallas grandes)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 700) {
                        return Row(
                          children: [
                            navItem("Inicio"),
                            navItem("Funcionalidades"),
                            navItem("Sobre Nosotros"),
                            navItem("Contacto"),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LoginScreen(),
                                  ),
                                );
                              },
                              child: const Text("Iniciar Sesión"),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2E7D32),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LoginScreen(),
                                  ),
                                );
                              },
                              child: const Text("Comenzar ahora"),
                            ),
                          ],
                        );
                      } else {
                        return const SizedBox();
                      }
                    },
                  ),
                ],
              ),
            ),

            // ------------------------------
            // HERO SECTION
            // ------------------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // CONTENIDO IZQUIERDO
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Gestión inteligente para tu finca ganadera",
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Conecta tus animales, tus datos y tu productividad en un solo lugar.",
                          style: TextStyle(fontSize: 18, color: Colors.black87),
                        ),
                        const SizedBox(height: 30),

                        // BOTONES
                        Wrap(
                          spacing: 20,
                          runSpacing: 12,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2E7D32),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {},
                              child: const Text("Saber más", style: TextStyle(fontSize: 18)),
                            ),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32, vertical: 16),
                                side: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                                );
                              },
                              child: const Text(
                                "Comenzar",
                                style: TextStyle(fontSize: 18, color: Color(0xFF2E7D32)),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 40),

                  // IMAGEN DEL HERO A LA DERECHA
                  Expanded(
                    flex: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        "assets/farm_hero.jpeg",
                        height: 320,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ------------------------------
            // SECCIÓN DE FUNCIONALIDADES
            // ------------------------------
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                children: [
                  const Text(
                    "Funcionalidades Principales",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 28),

                  Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    alignment: WrapAlignment.center,
                    children: [
                      featureCard("🐄", "Gestión del Hato",
                          "Controla información individual de cada animal."),
                      featureCard("💉", "Salud Animal",
                          "Registra tratamientos, vacunas y genera alertas."),
                      featureCard("💰", "Finanzas",
                          "Administra ingresos, egresos y reportes."),
                      featureCard("📊", "Análisis",
                          "Obtén estadísticas avanzadas y reportes automáticos."),
                    ],
                  ),
                ],
              ),
            ),

            // ------------------------------
            // SOBRE NOSOTROS
            // ------------------------------
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CONTENIDO IZQUIERDO
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Sobre FarmLink",
                          style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32)),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "En FarmLink creemos que el futuro del campo está en la tecnología. "
                              "Creamos una plataforma que conecta la información de tu finca para hacer "
                              "la ganadería más eficiente, sostenible y rentable.\n\n"
                              "Nuestro compromiso es con los productores que buscan innovar "
                              "sin perder la esencia del campo.",
                          style: TextStyle(fontSize: 17),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 40),

                  // IMAGEN A LA DERECHA
                  Expanded(
                    flex: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        "assets/about_us.jpeg",
                        height: 250,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ------------------------------
            // FOOTER
            // ------------------------------
            Container(
              width: double.infinity,
              color: const Color(0xFF2E7D32),
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: const Column(
                children: [
                  Text(
                    "Contacto: soporte@farmlink.com",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "© 2025 FarmLink. Todos los derechos reservados.",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------
  // WIDGETS PERSONALIZADOS
  // ------------------------------

  Widget navItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget featureCard(String icon, String title, String description) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 8),
          Text(description, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}