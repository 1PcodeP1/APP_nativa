import 'package:flutter/material.dart';
import '../theme.dart';
import '../db/auth_service.dart';

class CreditsScreen extends StatefulWidget {
  const CreditsScreen({Key? key}) : super(key: key);

  @override
  State<CreditsScreen> createState() => _CreditsScreenState();
}

class _CreditsScreenState extends State<CreditsScreen> {

  int _tapCount = 0;

  void _handleEasterEgg(BuildContext context) {
    _tapCount++;
    if (_tapCount == 7) {
      AuthService.updateBalance(100000, gameName: 'Secret Easter Egg');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('🎉 EASTER EGG ENCONTRADO! +\$100,000 Fichas! 🎉', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 3),
        ),
      );
      _tapCount = 0; // reset
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('CRÉDITOS', style: TextStyle(letterSpacing: 2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => _handleEasterEgg(context),
                child: Icon(Icons.code, size: 64, color: AppColors.primary),
              ),
              const SizedBox(height: 24),
              Text(
                'GRAND STAKES SIMULATOR',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.onSurface,
                      letterSpacing: 3,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Versión 3.0 Pro',
                style: TextStyle(color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 48),
              _buildCreditItem('Desarrollo Core', 'Daniel Gonzales Cardona\nSantiago Posso Acevedo\nCarlos Andrés Baena Moncada'),
              _buildCreditItem('Diseño UI/UX', 'The Precision Atelier'),
              _buildCreditItem('Tecnologías', 'Flutter & Hive DB'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreditItem(String role, String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        children: [
          Text(role, style: TextStyle(color: AppColors.primary, fontSize: 12, letterSpacing: 2)),
          const SizedBox(height: 4),
          Text(name, style: const TextStyle(color: AppColors.onSurface, fontSize: 18, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
