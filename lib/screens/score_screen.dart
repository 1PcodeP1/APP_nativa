import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../theme.dart';
import '../db/auth_service.dart';

class ScoreScreen extends StatefulWidget {
  const ScoreScreen({Key? key}) : super(key: key);

  @override
  State<ScoreScreen> createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('PUNTAJE Y ESTADÍSTICAS', style: TextStyle(letterSpacing: 2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ValueListenableBuilder<Box>(
        valueListenable: Hive.box('usersBox').listenable(),
        builder: (context, box, _) {
          final double balance = AuthService.currentBalance.toDouble();
          final transactions = AuthService.getTransactions();
          final int totalPlayed = transactions.length;
          
          int wonGames = 0;
          for (var tx in transactions) {
            if (tx['amount'] > 0) wonGames++;
          }
          final double winRate = totalPlayed > 0 ? (wonGames / totalPlayed) * 100 : 0.0;

          return AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: Opacity(
                  opacity: _animController.value,
                  child: ListView(
                    padding: const EdgeInsets.all(24.0),
                    children: [
                      _buildStatCard('Balance Actual', '\$${balance.toStringAsFixed(2)}', Icons.account_balance_wallet, isHighlight: true),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildStatCard('Win Rate', '${winRate.toStringAsFixed(1)}%', Icons.trending_up, color: Colors.green)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildStatCard('Partidas', '$totalPlayed', Icons.casino)),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Text('HISTORIAL DE RENDIMIENTO', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primary, letterSpacing: 2)),
                      const SizedBox(height: 16),
                      if (transactions.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Center(child: Text("Sin partidas jugadas aún.", style: TextStyle(color: Colors.white54))),
                        ),
                      ...transactions.take(15).map((tx) {
                        bool isWin = tx['amount'] > 0;
                        String sign = isWin ? '+' : '';
                        return _buildHistoryRow(tx['game'] ?? 'Game', '$sign\$${tx['amount']}', isWin);
                      }).toList(),
                    ],
                  ),
                ),
              );
            }
          );
        }
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, {bool isHighlight = false, Color? color}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isHighlight ? AppColors.surfaceContainerHigh : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color ?? AppColors.primary, size: 28),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12, letterSpacing: 1)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: AppColors.onSurface, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildHistoryRow(String game, String amount, bool isWin) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(game, style: const TextStyle(color: AppColors.onSurface, fontSize: 16)),
          Text(amount, style: TextStyle(color: isWin ? Colors.greenAccent : Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
