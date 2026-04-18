import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme.dart';
import 'roulette_screen.dart';
import 'blackjack_screen.dart';
import 'baccarat_screen.dart';
import 'slots_screen.dart';
import 'config_screen.dart';

class LobbyScreen extends StatelessWidget {
  const LobbyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.only(left: 64, right: 48, bottom: 8),
              child: Text(
                "Welcome",
                style: Theme.of(context).textTheme.displayLarge,
                textAlign: TextAlign.left,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 64, right: 48, bottom: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "The Atelier Lounge",
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.left,
                  ),
                  IconButton(
                    icon: const Icon(Icons.account_circle, color: AppColors.primary, size: 32),
                    onPressed: () {
                       Navigator.push(context, MaterialPageRoute(builder: (_) => const ConfigScreen()));
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _buildGlassCard(
                    context,
                    title: "European Roulette",
                    subtitle: "Table Limits: \$10 - \$5,000",
                    imageAsset: "assets/images/roulette_cover.png",
                    gradientColors: [AppColors.primary.withOpacity(0.2), Colors.transparent],
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RouletteScreen())),
                  ),
                  const SizedBox(height: 16),
                  _buildGlassCard(
                    context,
                    title: "Blackjack",
                    subtitle: "Table Limits: \$50 - \$10,000",
                    imageAsset: "assets/images/blackjack_cover.png",
                    gradientColors: [AppColors.secondaryContainer.withOpacity(0.2), Colors.transparent],
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BlackjackScreen())),
                  ),
                  const SizedBox(height: 16),
                  _buildGlassCard(
                    context,
                    title: "Baccarat",
                    subtitle: "Table Limits: \$100 - \$25,000",
                    imageAsset: "assets/images/baccarat_cover.png",
                    gradientColors: [AppColors.primary.withOpacity(0.05), Colors.transparent],
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BaccaratScreen())),
                  ),
                  const SizedBox(height: 16),
                  _buildGlassCard(
                    context,
                    title: "Slot Machines",
                    subtitle: "Table Limits: \$10 - \$1,000",
                    imageAsset: "assets/images/slots_cover.png",
                    gradientColors: [AppColors.primary.withOpacity(0.15), Colors.transparent],
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SlotsScreen())),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassCard(BuildContext context, {
    required String title,
    required String subtitle,
    required String imageAsset,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: Stack(
        children: [
          // Background AI Image
          Positioned.fill(
            child: Image.asset(imageAsset, fit: BoxFit.cover),
          ),
          // Glass Layer
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: InkWell(
              onTap: onTap,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant.withOpacity(0.8),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradientColors,
                  ),
                ),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        height: 2,
                        width: 48, // "Gold Filigree" short accent
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryContainer],
                          )
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(
                            subtitle,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.onSurface.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
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
