import 'package:flutter/material.dart';
import '../theme.dart';
import '../db/auth_service.dart';
import 'roulette_screen.dart';
import 'blackjack_screen.dart';
import 'baccarat_screen.dart';
import 'slots_screen.dart';
import 'config_screen.dart';
import 'transactions_screen.dart';

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({Key? key}) : super(key: key);

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  int _balance = 0;

  @override
  void initState() {
    super.initState();
    _balance = AuthService.currentBalance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.account_circle, color: AppColors.primary, size: 32),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ConfigScreen())),
        ),
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("GRAND STAKES", style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.primary, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold)),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.primary.withValues(alpha: 0.5))),
                ),
                child: Text("\$$_balance", style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primary)),
              )
            ],
          ),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu, color: AppColors.primary),
            color: AppColors.surfaceContainerHigh,
            onSelected: (value) {
              if (value == 'profile') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ConfigScreen()));
              } else if (value == 'banking') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const TransactionsScreen()));
              } else if (value == 'logout') {
                AuthService.logout();
                Navigator.pushReplacementNamed(context, '/');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Text('Profile & Settings', style: TextStyle(color: AppColors.primary)),
              ),
              const PopupMenuItem(
                value: 'banking',
                child: Text('Deposit / Cash Out', style: TextStyle(color: AppColors.primary)),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Text('Log Out', style: TextStyle(color: AppColors.secondary)),
              ),
            ],
          ),
        ],
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            // Header Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("The High-Roller's\nPrivate Atelier", style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 48, height: 1.1)),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () {},
                    child: Ink(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(color: AppColors.primary),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: const Text("REQUEST INVITATION", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 10)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // THE COLLECTION
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: const Text("THE COLLECTION", style: TextStyle(color: AppColors.primary, fontSize: 10, letterSpacing: 2.0, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            _buildCollectionItem(
              title: "Midnight Roulette",
              subtitle: "Exclusive High Stakes",
              imageAsset: "assets/images/roulette_cover.png",
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RouletteScreen())),
            ),
            const SizedBox(height: 48),

            // THE PIT FLOOR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: const Text("THE PIT FLOOR", style: TextStyle(color: AppColors.primary, fontSize: 10, letterSpacing: 2.0, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildPitFloorItem(
                    title: "Blackjack & Poker",
                    subtitle: "Table Limits: \$500 - \$50,000",
                    imageAsset: "assets/images/blackjack_cover.png",
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BlackjackScreen())),
                  ),
                  const SizedBox(height: 16),
                  _buildPitFloorItem(
                    title: "Grand Slots",
                    subtitle: "Jackpot: \$1,420,000",
                    imageAsset: "assets/images/slots_cover.png",
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SlotsScreen())),
                  ),
                  const SizedBox(height: 16),
                  _buildPitFloorItem(
                    title: "French Roulette",
                    subtitle: "Table Limits: \$100 - \$25,000",
                    imageAsset: "assets/images/roulette_cover.png",
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RouletteScreen())),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // VIP Lounge Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [const Color(0xFF382A2A), Colors.black],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("The VIP Lounge", style: TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text("Reserved for our most prestigious members.", style: TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BaccaratScreen())),
                      child: const Text("ENTER LOUNGE  →", style: TextStyle(color: AppColors.primary, fontSize: 10, letterSpacing: 2.0, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 48),

            // Stats Banner
            Container(
              color: AppColors.surfaceContainerLowest,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem("GAMES PLAYED", "1,248"),
                  _buildStatItem("TOTAL WINNINGS", "\$4,250,900"),
                  _buildStatItem("RECENT WIN", "+\$12,500"),
                  _buildStatItem("STATUS", "Platinum"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollectionItem({required String title, required String subtitle, required String imageAsset, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 300,
        margin: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(
            image: AssetImage(imageAsset),
            fit: BoxFit.cover,
            colorFilter: const ColorFilter.mode(Colors.black45, BlendMode.darken),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: const Center(child: Icon(Icons.play_arrow, color: AppColors.primary, size: 48)),
              ),
              const SizedBox(height: 24),
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(subtitle, style: const TextStyle(color: AppColors.primary, fontSize: 12, letterSpacing: 1.0)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPitFloorItem({required String title, required String subtitle, required String imageAsset, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(imageAsset),
                    fit: BoxFit.cover,
                    colorFilter: const ColorFilter.mode(Colors.black54, BlendMode.darken),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 10)),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B0000), // Red button
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: const Text("ENTER THE PIT", style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                        ),
                        const Text("RULES", style: TextStyle(color: Colors.white38, fontSize: 8, letterSpacing: 1.0)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: AppColors.primary, fontSize: 8, letterSpacing: 1.0)),
      ],
    );
  }
}
