import 'package:flutter/material.dart';
import '../theme.dart';
import '../logic/card_deck.dart';
import '../db/auth_service.dart';
import 'config_screen.dart';
import 'auth/login_screen.dart';
import 'transactions_screen.dart';

class BaccaratScreen extends StatefulWidget {
  const BaccaratScreen({Key? key}) : super(key: key);

  @override
  State<BaccaratScreen> createState() => _BaccaratScreenState();
}

class _BaccaratScreenState extends State<BaccaratScreen> {
  final Deck _deck = Deck();
  int _balance = 0;
  String _message = "Select a bet zone.";
  bool _isPlaying = false;
  
  List<PlayingCard> _bankerH = [];
  List<PlayingCard> _playerH = [];
  
  // 0: Banker, 1: Player, 2: Tie
  int? _selectedBetType;
  final int _betAmount = 100; // Fixed bet for simplicity in baccarat currently

  @override
  void initState() {
    super.initState();
    _balance = AuthService.currentBalance;
  }

  void _updateBal(int amount) {
    AuthService.updateBalance(amount, gameName: 'Baccarat');
    setState(() { _balance = AuthService.currentBalance; });
  }

  int _calcHand(List<PlayingCard> hand) {
    int v = 0;
    for (var c in hand) {
      v += c.baccaratValue;
    }
    return v % 10;
  }

  void _placeBet(int type) async {
    if (_isPlaying || _balance < _betAmount) return;
    
    _updateBal(-_betAmount);
    setState(() {
      _selectedBetType = type;
      _isPlaying = true;
      _message = "Dealing...";
      _bankerH = [_deck.draw(), _deck.draw()];
      _playerH = [_deck.draw(), _deck.draw()];
    });
    
    // Simulate drawing speed
    await Future.delayed(const Duration(seconds: 1));
    
    int pV = _calcHand(_playerH);
    int bV = _calcHand(_bankerH);
    
    // Third card logic basic
    if (pV < 8 && bV < 8) { // If neither natural
      if (pV <= 5) {
        _playerH.add(_deck.draw());
        pV = _calcHand(_playerH);
      }
      if (bV <= 5) { // Simplified banker rule
        _bankerH.add(_deck.draw());
        bV = _calcHand(_bankerH);
      }
    }
    
    await Future.delayed(const Duration(seconds: 1));
    
    int winner = 2; // Tie
    if (pV > bV) winner = 1; // Player
    else if (bV > pV) winner = 0; // Banker
    
    setState(() {
      _isPlaying = false;
      if (winner == _selectedBetType) {
        _message = "YOU WON!";
        if (winner == 0) _updateBal((_betAmount * 1.95).toInt()); // Banker 5% commission
        else if (winner == 1) _updateBal(_betAmount * 2); // Player 1:1
        else _updateBal(_betAmount * 9); // Tie 8:1
      } else {
        _message = "YOU LOST.";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            children: [
              Text("\$$_balance", style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
              const Text("AVAILABLE BALANCE", style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 8, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
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
              } else if (value == 'logout') {
                AuthService.logout();
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Text('Profile & Settings', style: TextStyle(color: AppColors.primary)),
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
      body: SafeArea(
        child: Column(
          children: [
             Padding(
               padding: const EdgeInsets.all(16.0),
               child: Text(_message, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.primary)),
             ),
             // Live Table HUD
             if (_bankerH.isNotEmpty)
               Expanded(
                 flex: 1,
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                   children: [
                     Column(
                       children: [
                         const Text("BANKER", style: TextStyle(color: AppColors.secondaryContainer, fontWeight: FontWeight.bold)),
                         AnimatedSwitcher(
                           duration: const Duration(milliseconds: 500),
                           transitionBuilder: (w, anim) => SlideTransition(position: Tween(begin: const Offset(0,-0.5), end: Offset.zero).animate(anim), child: FadeTransition(opacity: anim, child: w)),
                           child: Text("${_calcHand(_bankerH)}", key: ValueKey(_bankerH.length), style: const TextStyle(color: AppColors.onSurface, fontSize: 48)),
                         ),
                       ]
                     ),
                     Column(
                       children: [
                         const Text("PLAYER", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                         AnimatedSwitcher(
                           duration: const Duration(milliseconds: 500),
                           transitionBuilder: (w, anim) => SlideTransition(position: Tween(begin: const Offset(0,-0.5), end: Offset.zero).animate(anim), child: FadeTransition(opacity: anim, child: w)),
                           child: Text("${_calcHand(_playerH)}", key: ValueKey(_playerH.length), style: const TextStyle(color: AppColors.onSurface, fontSize: 48)),
                         ),
                       ]
                     ),
                   ],
                 )
               ),
              // Betting Zones
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: _BetZone(
                          title: "BANKER",
                          payout: "PAYS 0.95 TO 1",
                          baseColor: AppColors.secondaryContainer,
                          onTap: () => _placeBet(0),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _BetZone(
                          title: "PLAYER",
                          payout: "PAYS 1 TO 1",
                          baseColor: AppColors.primary,
                          onTap: () => _placeBet(1),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _BetZone(
                          title: "TIE",
                          payout: "PAYS 8 TO 1",
                          baseColor: AppColors.surfaceContainerHighest,
                          textColor: AppColors.onSurface,
                          onTap: () => _placeBet(2),
                        ),
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
}

class _BetZone extends StatelessWidget {
  final String title;
  final String payout;
  final Color baseColor;
  final Color? textColor;
  final VoidCallback onTap;

  const _BetZone({
    Key? key,
    required this.title,
    required this.payout,
    required this.baseColor,
    required this.onTap,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveTextColor = textColor ?? AppColors.surface;
    return InkWell(
      onTap: onTap,
      child: Ink(
        color: baseColor.withOpacity(0.8), // No radii (0px corner constraint)
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 48,
                    color: effectiveTextColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  payout,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: effectiveTextColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
