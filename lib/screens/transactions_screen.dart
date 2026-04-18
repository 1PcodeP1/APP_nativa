import 'package:flutter/material.dart';
import '../theme.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

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
                        backgroundImage: NetworkImage("https://i.pravatar.cc/100?img=11"), // Placeholder for profile
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
                          Text("\$25,450", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.notifications_outlined, color: AppColors.primary, size: 24),
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
                  Text("THE LEDGER", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, letterSpacing: 2.0, fontSize: 10)),
                ],
              ),
              const SizedBox(height: 8),
              Text("Transaction\nHistory", style: Theme.of(context).textTheme.displayLarge?.copyWith(color: Colors.white, height: 1.1)),
              const SizedBox(height: 16),
              Text(
                "Review your high-stakes movements within the atelier. Every deposit and withdrawal meticulously recorded for your records.",
                style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 32),

              // Filter Grid
              Row(
                children: [
                  Expanded(child: _buildFilterCard("SCOPE", "All Records", true)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildFilterCard("TYPE", "Deposits", false)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildFilterCard("TYPE", "Withdrawals", false)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildFilterCard("PERIOD", "Last 30 Days", false)),
                ],
              ),
              const SizedBox(height: 40),

              // Date Group: October 24, 2023
              _buildDateHeader("OCTOBER 24, 2023"),
              _buildTransactionCard(
                icon: Icons.account_balance_wallet_outlined,
                iconColor: AppColors.primary,
                title: "Instant Deposit",
                subtitle: "Visa Premium • *** 8842",
                amount: "+\$12,500.00",
                isPositive: true,
                status: "PROCESSED",
                statusColor: Colors.blueAccent,
                isSelected: true,
              ),
              const SizedBox(height: 8),
              _buildTransactionCard(
                icon: Icons.account_balance,
                iconColor: Colors.white,
                title: "Direct Withdrawal",
                subtitle: "Bank Transfer • Grand Swiss Bank",
                amount: "-\$5,000.00",
                isPositive: false,
                status: "PENDING APPROVAL",
                statusColor: AppColors.primary,
              ),
              const SizedBox(height: 32),

              // Date Group: October 22, 2023
              _buildDateHeader("OCTOBER 22, 2023"),
              _buildTransactionCard(
                icon: Icons.diamond_outlined,
                iconColor: AppColors.secondary,
                title: "VIP Bonus Reward",
                subtitle: "Platinum Status Monthly Incentive",
                amount: "+\$2,500.00",
                isPositive: true,
                status: "PROCESSED",
                statusColor: Colors.blueAccent,
              ),
              const SizedBox(height: 8),
              _buildTransactionCard(
                icon: Icons.currency_bitcoin,
                iconColor: Colors.white,
                title: "Crypto Liquidation",
                subtitle: "Bitcoin Wallet • btc1q...9x2",
                amount: "-\$1,250.00",
                isPositive: false,
                status: "PROCESSED",
                statusColor: Colors.blueAccent,
              ),
              const SizedBox(height: 32),

              // Load Previous Records Button
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: AppColors.surfaceVariant),
                      bottom: BorderSide(color: AppColors.surfaceVariant),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("LOAD PREVIOUS RECORDS", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 2.0)),
                      const SizedBox(width: 8),
                      Icon(Icons.keyboard_arrow_down, color: AppColors.primary, size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterCard(String label, String value, bool isSelected) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(4),
        border: isSelected ? Border(bottom: BorderSide(color: AppColors.primary, width: 2)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: AppColors.primary, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDateHeader(String date) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Text(date, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2.0)),
          const SizedBox(width: 16),
          Expanded(child: Divider(color: AppColors.surfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildTransactionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String amount,
    required bool isPositive,
    required String status,
    required Color statusColor,
    bool isSelected = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(4),
        border: isSelected ? Border.all(color: Colors.blueAccent.withValues(alpha: 0.5), width: 1) : null,
      ),
      child: Row(
        children: [
          // Icon Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 10)),
              ],
            ),
          ),
          // Amount & Status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  color: isPositive ? AppColors.primary : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(width: 6, height: 6, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Text(status, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
