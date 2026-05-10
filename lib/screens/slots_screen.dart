import 'package:flutter/material.dart';
import '../theme.dart';
import '../db/auth_service.dart';
import 'slot_game_screen.dart';
import 'config_screen.dart';
import 'auth/login_screen.dart';
import 'transactions_screen.dart';
import 'package:video_player/video_player.dart';

class SlotsScreen extends StatefulWidget {
  const SlotsScreen({Key? key}) : super(key: key);

  @override
  State<SlotsScreen> createState() => _SlotsScreenState();
}

class _SlotsScreenState extends State<SlotsScreen> {
  int _balance = 0;

  @override
  void initState() {
    super.initState();
    _balance = AuthService.currentBalance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Darkest background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.account_circle, color: AppColors.primary, size: 32),
          onPressed: () => Navigator.pushNamed(context, '/profile'),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                "GRAND STAKES",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primary, 
                  fontStyle: FontStyle.italic, 
                  fontWeight: FontWeight.bold
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.primary.withValues(alpha: 0.5))),
              ),
              child: Text(
                "\$$_balance",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primary),
              ),
            ),
          ],
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
            // Top Banner
            _buildTopBanner(),
            const SizedBox(height: 32),

            // Slot Games List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildSlotCard(
                    title: "Eye of Ra",
                    subtitle: "Discover ancient treasures hidden beneath the shifting sands of the desert.",
                    buttonText: "PLAY NOW",
                    buttonColor: AppColors.primary,
                    textColor: Colors.black,
                    imagePath: "assets/images/eye_of_ra_slot.png",
                    theme: const SlotTheme(
                      title: "Eye of Ra",
                      symbols: ["👁️", "🐫", "🏺", "🦂", "🐍"],
                      primaryColor: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSlotCard(
                    title: "Royal Cherry",
                    subtitle: "The ultimate classic experience refined for the modern player.",
                    buttonText: "BET MAX",
                    buttonColor: const Color(0xFF8B0000), // Red
                    textColor: Colors.white,
                    imagePath: "assets/images/royal_cherry_slot.png",
                    theme: const SlotTheme(
                      title: "Royal Cherry",
                      symbols: ["🍒", "🔔", "7️⃣", "BAR", "🍉"],
                      primaryColor: Color(0xFF8B0000),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSlotCard(
                    title: "Nebula Gems",
                    subtitle: "Drift through deep space while collecting cosmic wealth.",
                    buttonText: "PLAY NOW",
                    buttonColor: const Color(0xFF5C8DF6), // Blue
                    textColor: Colors.black,
                    imagePath: "assets/images/nebula_gems_slot.png",
                    theme: const SlotTheme(
                      title: "Nebula Gems",
                      symbols: ["💎", "💠", "🌟", "☄️", "🚀"],
                      primaryColor: Color(0xFF5C8DF6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // VIP Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("THE VIP EXPERIENCE", style: TextStyle(color: AppColors.primary, fontSize: 10, letterSpacing: 2.0, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text("Exclusive Tables for the Discerning Bettor", style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32, height: 1.1)),
                  const SizedBox(height: 16),
                  Text("Our private salon features premium limits and dedicated concierge service for those who demand excellence.", style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12, height: 1.5)),
                  const SizedBox(height: 32),
                  _buildSlotCard(
                    title: "VIP Safe Work",
                    subtitle: "Members Only",
                    buttonText: "REQUEST ACCESS",
                    buttonColor: Colors.black,
                    textColor: AppColors.primary,
                    hasBorder: true,
                    onTapOverride: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => const _VideoEasterEggDialog(),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBanner() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/images/slots_cover.png'), // Placeholder
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("GRAND CASINO", style: TextStyle(color: AppColors.primary, fontSize: 10, letterSpacing: 2.0, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("\$1,420,000", style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 48, fontWeight: FontWeight.w300)),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
              ),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SlotGameScreen(
                theme: SlotTheme(
                  title: "Grand Pit",
                  symbols: ["💰", "💎", "7️⃣", "🔔", "🌟"],
                  primaryColor: AppColors.primary,
                )
              ))),
              child: const Text("ENTER THE PIT", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlotCard({
    required String title,
    required String subtitle,
    required String buttonText,
    required Color buttonColor,
    required Color textColor,
    bool hasBorder = false,
    String? imagePath,
    SlotTheme? theme,
    VoidCallback? onTapOverride,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: hasBorder ? Border.all(color: AppColors.primary.withValues(alpha: 0.5), width: 1) : null,
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              gradient: imagePath == null ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.surfaceVariant, Colors.black],
              ) : null,
            ),
            child: imagePath != null
                ? Image.asset(imagePath, fit: BoxFit.cover)
                : const Center(
                    child: Icon(Icons.casino, size: 64, color: Colors.white24),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white)),
                const SizedBox(height: 8),
                Text(subtitle, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                const SizedBox(height: 16),
                InkWell(
                  onTap: onTapOverride ?? () {
                    if (theme != null) {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => SlotGameScreen(theme: theme)));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("VIP Access Required.")));
                    }
                  },
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: buttonColor,
                        borderRadius: BorderRadius.circular(2),
                        border: hasBorder ? Border.all(color: AppColors.primary) : null,
                      ),
                      child: Center(
                        child: Text(buttonText, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 12)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoEasterEggDialog extends StatefulWidget {
  const _VideoEasterEggDialog({Key? key}) : super(key: key);

  @override
  State<_VideoEasterEggDialog> createState() => _VideoEasterEggDialogState();
}

class _VideoEasterEggDialogState extends State<_VideoEasterEggDialog> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/images/gato_riendo.mp4')
      ..initialize().then((_) {
        _controller.setLooping(true);
        _controller.play();
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "¿Creíste que había algo aquí?",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          if (_controller.value.isInitialized)
            AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            )
          else
            const Padding(
              padding: EdgeInsets.all(48.0),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CERRAR", style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
