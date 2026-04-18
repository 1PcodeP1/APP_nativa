import 'dart:math';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../db/auth_service.dart';

class SlotsScreen extends StatefulWidget {
  const SlotsScreen({Key? key}) : super(key: key);

  @override
  State<SlotsScreen> createState() => _SlotsScreenState();
}

class _SlotsScreenState extends State<SlotsScreen>
    with SingleTickerProviderStateMixin {
  int _balance = 0;
  String _message = "SPIN TO WIN";
  bool _spinning = false;
  int _bet = 10;

  final List<String> _symbols = ["🍒", "💎", "7️⃣", "🔔", "💰"];
  List<String> _currentReels = ["7️⃣", "7️⃣", "7️⃣"];

  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _balance = AuthService.currentBalance;
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _spin() async {
    if (_balance < _bet || _spinning) return;
    AuthService.updateBalance(-_bet, gameName: 'Golden Slots');
    setState(() {
      _spinning = true;
      _balance = AuthService.currentBalance;
      _message = "SPINNING...";
    });

    _ctrl.repeat();

    // Simulate spin logic
    for (int i = 0; i < 15; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      setState(() {
        _currentReels = [
          _symbols[Random().nextInt(_symbols.length)],
          _symbols[Random().nextInt(_symbols.length)],
          _symbols[Random().nextInt(_symbols.length)],
        ];
      });
    }

    _ctrl.stop();
    _checkWin();
  }

  void _checkWin() {
    if (_currentReels[0] == _currentReels[1] &&
        _currentReels[1] == _currentReels[2]) {
      int mult = 10;
      if (_currentReels[0] == "7️⃣") mult = 100;
      if (_currentReels[0] == "💰") mult = 50;
      AuthService.updateBalance(_bet * mult, gameName: 'Golden Slots Win');
      setState(() {
        _message = "JACKPOT! WON \$${_bet * mult}";
      });
    } else if (_currentReels[0] == _currentReels[1] ||
        _currentReels[1] == _currentReels[2] ||
        _currentReels[0] == _currentReels[2]) {
      AuthService.updateBalance(_bet * 2, gameName: 'Golden Slots Win');
      setState(() {
        _message = "MINI WIN! WON \$${_bet * 2}";
      });
    } else {
      setState(() {
        _message = "NOTHING.";
      });
    }
    setState(() {
      _spinning = false;
      _balance = AuthService.currentBalance;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          "Golden Slots",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppColors.primary),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                "\$$_balance",
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _message,
            style: Theme.of(
              context,
            ).textTheme.displayLarge?.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 48),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppColors.surfaceContainerLowest,
                  AppColors.surfaceContainerHighest,
                ],
              ),
              border: const Border(
                top: BorderSide(color: AppColors.primary, width: 4),
                bottom: BorderSide(color: AppColors.primary, width: 4),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildReel(_currentReels[0]),
                _buildReel(_currentReels[1]),
                _buildReel(_currentReels[2]),
              ],
            ),
          ),
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.remove_circle,
                  color: AppColors.primary,
                  size: 32,
                ),
                onPressed: _spinning || _bet <= 10
                    ? null
                    : () {
                        setState(() {
                          _bet -= 10;
                        });
                      },
              ),
              Text(
                " BET \$$_bet ",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.add_circle,
                  color: AppColors.primary,
                  size: 32,
                ),
                onPressed: _spinning || _bet >= _balance
                    ? null
                    : () {
                        setState(() {
                          _bet += 10;
                        });
                      },
              ),
            ],
          ),
          const SizedBox(height: 24),
          InkWell(
            onTap: _spin,
            child: Ink(
              padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _spinning
                      ? [Colors.grey, Colors.grey.shade800]
                      : [AppColors.primary, AppColors.primaryContainer],
                ),
              ),
              child: Text(
                "SPIN LOGIC",
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: AppColors.surface,
                  fontSize: 32,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReel(String icon) {
    return Container(
      width: 80,
      height: 100,
      color: Colors.black,
      alignment: Alignment.center,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 100),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -1),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
        child: Text(
          icon, 
          key: ValueKey<String>("$icon${DateTime.now().millisecondsSinceEpoch}"), 
          style: const TextStyle(fontSize: 48)
        ),
      ),
    );
  }
}
