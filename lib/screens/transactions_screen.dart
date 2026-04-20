import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import '../db/auth_service.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

  Future<void> _showDepositDialog() async {
    final TextEditingController _amountCtrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        title: const Text("Deposit Funds", style: TextStyle(color: AppColors.primary)),
        content: TextField(
          controller: _amountCtrl,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: "Amount",
            prefixText: "\$ ",
            prefixStyle: TextStyle(color: AppColors.primary),
            labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL", style: TextStyle(color: AppColors.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, _amountCtrl.text),
            child: const Text("DEPOSIT", style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      int amount = int.tryParse(result) ?? 0;
      if (amount > 0) {
        await AuthService.updateBalance(amount, gameName: "Deposit");
        setState(() {});
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("\$$amount deposited successfully."), backgroundColor: Colors.green.shade800));
      }
    }
  }

  Future<void> _showWithdrawDialog() async {
    final TextEditingController _amountCtrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        title: const Text("Withdraw Funds", style: TextStyle(color: AppColors.primary)),
        content: TextField(
          controller: _amountCtrl,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: "Amount",
            prefixText: "\$ ",
            prefixStyle: TextStyle(color: AppColors.primary),
            labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL", style: TextStyle(color: AppColors.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, _amountCtrl.text),
            child: const Text("WITHDRAW", style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      int amount = int.tryParse(result) ?? 0;
      if (amount > 0) {
        if (AuthService.currentBalance >= amount) {
          await AuthService.updateBalance(-amount, gameName: "Withdrawal");
          setState(() {});
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("\$$amount withdrawn successfully."), backgroundColor: Colors.blue.shade800));
        } else {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text("Insufficient funds for withdrawal."), backgroundColor: Colors.red.shade800));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> txs = AuthService.getTransactions();

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
                  Text("THE LEDGER", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, letterSpacing: 2.0, fontSize: 10)),
                ],
              ),
              const SizedBox(height: 8),
              Text("Transaction\nHistory", style: Theme.of(context).textTheme.displayLarge?.copyWith(color: Colors.white, height: 1.1)),
              const SizedBox(height: 24),

              // Deposit & Withdraw Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      onPressed: _showDepositDialog,
                      child: const Text("DEPOSIT", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      onPressed: _showWithdrawDialog,
                      child: const Text("WITHDRAW", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    ),
                  ),
                ],
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

              // Transactions List
              txs.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Text("No transactions recorded yet.", style: TextStyle(color: AppColors.onSurfaceVariant)),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: txs.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final tx = txs[index];
                        final amount = tx['amount'] as int;
                        final game = tx['game'] as String;
                        final dateStr = tx['timestamp'] as String;
                        final date = DateTime.tryParse(dateStr) ?? DateTime.now();

                        bool isPositive = amount > 0;
                        String formattedAmount = _currencyFormat.format(amount.abs());
                        if (isPositive) {
                          formattedAmount = "+$formattedAmount";
                        } else {
                          formattedAmount = "-$formattedAmount";
                        }

                        IconData icon;
                        Color iconColor;
                        if (game.toLowerCase().contains('deposit')) {
                          icon = Icons.account_balance_wallet_outlined;
                          iconColor = AppColors.primary;
                        } else if (game.toLowerCase().contains('withdrawal')) {
                          icon = Icons.account_balance;
                          iconColor = Colors.white;
                        } else if (game.toLowerCase().contains('promo')) {
                          icon = Icons.card_giftcard;
                          iconColor = Colors.purpleAccent;
                        } else {
                          icon = Icons.casino;
                          iconColor = AppColors.secondary;
                        }

                        // Add date header if it's the first or a different day
                        Widget? header;
                        if (index == 0) {
                          header = _buildDateHeader(DateFormat('MMMM d, yyyy').format(date).toUpperCase());
                        } else {
                          final prevTx = txs[index - 1];
                          final prevDate = DateTime.tryParse(prevTx['timestamp']) ?? DateTime.now();
                          if (date.day != prevDate.day || date.month != prevDate.month || date.year != prevDate.year) {
                            header = _buildDateHeader(DateFormat('MMMM d, yyyy').format(date).toUpperCase());
                          }
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (header != null) ...[
                              if (index > 0) const SizedBox(height: 24),
                              header,
                            ],
                            _buildTransactionCard(
                              icon: icon,
                              iconColor: iconColor,
                              title: game,
                              subtitle: DateFormat('hh:mm a').format(date),
                              amount: formattedAmount,
                              isPositive: isPositive,
                              status: "PROCESSED",
                              statusColor: Colors.blueAccent,
                            ),
                          ],
                        );
                      },
                    ),
              const SizedBox(height: 32),

              // Load Previous Records Button
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: AppColors.surfaceVariant),
                      bottom: BorderSide(color: AppColors.surfaceVariant),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("LOAD PREVIOUS RECORDS", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 2.0)),
                      SizedBox(width: 8),
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
        border: isSelected ? const Border(bottom: BorderSide(color: AppColors.primary, width: 2)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.primary, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
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
          const Expanded(child: Divider(color: AppColors.surfaceVariant)),
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
