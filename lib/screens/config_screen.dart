import 'package:flutter/material.dart';
import '../theme.dart';
import '../db/auth_service.dart';
import 'auth/login_screen.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  bool _jackpotAlerts = true;
  bool _tableOpenings = false;
  bool _marketingEditorial = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Darkest background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      Text("\$25,450", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(width: 16),
                      Icon(Icons.close, color: AppColors.primary, size: 24),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 32),

              // Title Section
              Text("Member Settings", style: Theme.of(context).textTheme.displayLarge?.copyWith(color: AppColors.primary, height: 1.1)),
              const SizedBox(height: 8),
              Text(
                "Tailor your high-stakes experience.",
                style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 32),

              // Account Essentials
              _buildSectionContainer(
                title: "Account Essentials",
                icon: Icons.account_circle_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabelValue("FULL LEGAL NAME", "James Vane"),
                    const SizedBox(height: 16),
                    _buildLabelValue("MEMBERSHIP TIER", "Platinum Member", isGolden: true, suffixIcon: Icons.diamond),
                    const SizedBox(height: 16),
                    _buildLabelValue("EMAIL ADDRESS", "j.vane@highstakes.com"),
                    const SizedBox(height: 16),
                    _buildLabelValue("CURRENCY PREFERRED", "USD - United States Dollar"),
                    const SizedBox(height: 24),
                    InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(2),
                      child: Ink(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B0000), // Deep red
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text(
                          "UPDATE PROFILE DETAILS",
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Notifications
              _buildSectionContainer(
                title: "Notifications",
                child: Column(
                  children: [
                    _buildToggle("Jackpot Alerts", "Notify when a major prize exceeds \$1M", _jackpotAlerts, (v) => setState(() => _jackpotAlerts = v)),
                    const SizedBox(height: 16),
                    _buildToggle("Table Openings", "Immersions for VIP table availability", _tableOpenings, (v) => setState(() => _tableOpenings = v)),
                    const SizedBox(height: 16),
                    _buildToggle("Marketing Editorial", "Weekly newsletter of curated opportunities", _marketingEditorial, (v) => setState(() => _marketingEditorial = v)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Privacy & Security
              _buildSectionContainer(
                title: "Privacy & Security",
                child: Column(
                  children: [
                    _buildNavRow(Icons.security_outlined, "Two-Factor Authentication", "Currently Enabled via Authenticator App"),
                    const SizedBox(height: 16),
                    _buildNavRow(Icons.vpn_key_outlined, "Change Secure Password", "Last changed 1 month ago"),
                    const SizedBox(height: 16),
                    _buildNavRow(Icons.history_outlined, "Login Activity", "View active sessions and devices"),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Player Care
              _buildSectionContainer(
                title: "Player Care",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "We prioritize your sophisticated play and well-being. Define your boundaries below.",
                      style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12, height: 1.5),
                    ),
                    const SizedBox(height: 24),
                    _buildLimitBar("DAILY DEPOSIT LIMIT", "\$5,000", 0.6),
                    const SizedBox(height: 24),
                    _buildLimitBar("WEEKLY LOSS LIMIT", "\$15,000", 0.4),
                    const SizedBox(height: 32),
                    
                    // Buttons
                    _buildActionBtn("Time-Out (Cooling Off)", Icons.timer_outlined),
                    const SizedBox(height: 12),
                    _buildActionBtn("Self-Exclusion", Icons.block_outlined),
                    const SizedBox(height: 24),

                    // Support Box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("NEED SUPPORT?", style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                          const SizedBox(height: 8),
                          Text(
                            "Our concierge is available 24/7 for responsible gaming guidance.",
                            style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
                          ),
                          const SizedBox(height: 16),
                          Text("Talk to a Care Specialist", style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 48),
                    Center(
                      child: InkWell(
                        onTap: () async {
                          await AuthService.logout();
                          if (context.mounted) {
                            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false);
                          }
                        },
                        child: Text("SIGN OUT", style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2.0)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionContainer({required String title, IconData? icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
              ],
              Text(title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildLabelValue(String label, String value, {bool isGolden = false, IconData? suffixIcon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(value, style: TextStyle(color: isGolden ? AppColors.primary : Colors.white, fontSize: 14)),
            if (suffixIcon != null) ...[
              const SizedBox(width: 8),
              Icon(suffixIcon, color: AppColors.primary, size: 14),
            ]
          ],
        ),
        const SizedBox(height: 4),
        Divider(color: AppColors.surfaceVariant),
      ],
    );
  }

  Widget _buildToggle(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
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
        Switch(
          value: value,
          onChanged: onChanged,
          activeTrackColor: AppColors.primary,
          inactiveThumbColor: AppColors.onSurfaceVariant,
          inactiveTrackColor: AppColors.surfaceContainerLow,
        ),
      ],
    );
  }

  Widget _buildNavRow(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
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
        Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant, size: 20),
      ],
    );
  }

  Widget _buildLimitBar(String label, String amount, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            Text(amount, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: AppColors.surfaceContainerLow,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          minHeight: 4,
        ),
      ],
    );
  }

  Widget _buildActionBtn(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          Icon(icon, color: AppColors.primary, size: 16),
        ],
      ),
    );
  }
}
