import 'package:flutter/material.dart';

import '../widgets/cta_section.dart';
import '../widgets/features_section.dart';
import '../widgets/footer_section.dart';
import '../widgets/hero_section.dart';
import '../widgets/how_it_works_section.dart';
import '../widgets/stats_strip.dart';

/// FarmLink Landing Page — orquesta las 6 secciones de la home.
class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SelectionArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: const [
            HeroSection(),
            FeaturesSection(),
            StatsStrip(),
            HowItWorksSection(),
            CtaSection(),
            FooterSection(),
          ],
        ),
      ),
    );
  }
}
