import 'package:flutter/material.dart';
import '../theme.dart';
import '../db/auth_service.dart';

class PromosScreen extends StatefulWidget {
  const PromosScreen({super.key});

  @override
  State<PromosScreen> createState() => _PromosScreenState();
}

class _PromosScreenState extends State<PromosScreen> {
  final Set<String> _claimedPromos = {};

  void _claimPromo(String id, String title, int amount) {
    if (_claimedPromos.contains(id)) return;

    AuthService.updateBalance(amount, gameName: "Promo: $title");
    setState(() {
      _claimedPromos.add(id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Success! +\$$amount added to your balance from '$title'."),
        backgroundColor: Colors.green.shade800,
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Darkest background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom AppBar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 16,
                        backgroundImage: NetworkImage("https://i.pravatar.cc/100?img=11"),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("GRAND", style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.primary, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                          Text("STAKES", style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.primary, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("AVAILABLE", style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 8, letterSpacing: 1.0)),
                          Text("BALANCE", style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 8, letterSpacing: 1.0)),
                          Text("\$${AuthService.currentBalance}", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.primary, size: 24),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 32),

              // Title Section
              Row(
                children: [
                  Container(width: 30, height: 1, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text("THE ATELIER OFFERS", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, letterSpacing: 2.0, fontSize: 10)),
                ],
              ),
              const SizedBox(height: 8),
              Text("Exclusive\nPromotions", style: Theme.of(context).textTheme.displayLarge?.copyWith(color: Colors.white, height: 1.1)),
              const SizedBox(height: 16),
              Text(
                "Unlock daily rewards, claim your VIP bonuses, and multiply your bankroll with our curated selection of high-stakes promotions.",
                style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 32),

              // Filter Grid
              Row(
                children: [
                  Expanded(child: _buildFilterCard("TYPE", "All Promos", true)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildFilterCard("STATUS", "Available", false)),
                ],
              ),
              const SizedBox(height: 40),

              // Promos
              _buildDateHeader("AVAILABLE NOW"),
              _buildPromoCard(
                id: "welcome_bonus",
                icon: Icons.auto_awesome,
                iconColor: Colors.amber,
                title: "Welcome Bonus",
                subtitle: "Instant \$500 to start your journey",
                amount: 500,
                statusColor: Colors.green,
              ),
              const SizedBox(height: 16),
              _buildPromoCard(
                id: "daily_vip",
                icon: Icons.card_giftcard,
                iconColor: AppColors.primary,
                title: "Daily VIP Drop",
                subtitle: "Claim your daily \$100 courtesy chip",
                amount: 100,
                statusColor: Colors.green,
              ),
              const SizedBox(height: 16),
              _buildPromoCard(
                id: "weekend_reload",
                icon: Icons.account_balance_wallet,
                iconColor: Colors.blueAccent,
                title: "Weekend Reload",
                subtitle: "Extra \$250 added to your ledger",
                amount: 250,
                statusColor: Colors.orange,
              ),
              const SizedBox(height: 32),

              _buildDateHeader("UPCOMING"),
              _buildUpcomingCard(
                icon: Icons.stars,
                iconColor: Colors.purpleAccent,
                title: "High Roller Tournament",
                subtitle: "\$100,000 Prize Pool. Entry: \$1,000",
                status: "STARTS TOMORROW",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterCard(String label, String value, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.surfaceContainerHigh : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: isSelected ? AppColors.primary.withValues(alpha: 0.3) : Colors.transparent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value, style: TextStyle(color: isSelected ? AppColors.primary : Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              const Icon(Icons.keyboard_arrow_down, color: AppColors.onSurfaceVariant, size: 16),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader(String date) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(date, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2.0)),
    );
  }

  Widget _buildPromoCard({
    required String id,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required int amount,
    required Color statusColor,
  }) {
    bool isClaimed = _claimedPromos.contains(id);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(4),
        border: Border(left: BorderSide(color: isClaimed ? Colors.grey : iconColor, width: 2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainerLow,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: isClaimed ? Colors.grey : iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: isClaimed ? Colors.grey : Colors.white, fontSize: 14, fontWeight: FontWeight.bold, decoration: isClaimed ? TextDecoration.lineThrough : null)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 10)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              InkWell(
                onTap: isClaimed ? null : () => _claimPromo(id, title, amount),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isClaimed ? AppColors.surfaceContainerLow : AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(isClaimed ? "CLAIMED" : "CLAIM", style: TextStyle(color: isClaimed ? Colors.grey : AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 8),
              Text(isClaimed ? "COMPLETED" : "ACTIVE", style: TextStyle(color: isClaimed ? Colors.grey : statusColor, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String status,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(4),
        border: Border(left: BorderSide(color: iconColor, width: 2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainerLow,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 10)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: const Text("REGISTER", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              Text(status, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
            ],
          ),
        ],
      ),
    );
  }
}
