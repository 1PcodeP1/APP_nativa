import 'dart:math';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../db/auth_service.dart';
import 'config_screen.dart';
import 'auth/login_screen.dart';
import 'transactions_screen.dart';

class SlotTheme {
  final String title;
  final List<String> symbols;
  final Color primaryColor;

  const SlotTheme({
    required this.title,
    required this.symbols,
    required this.primaryColor,
  });
}

class SlotGameScreen extends StatefulWidget {
  final SlotTheme theme;
  
  const SlotGameScreen({Key? key, required this.theme}) : super(key: key);

  @override
  State<SlotGameScreen> createState() => _SlotGameScreenState();
}

class _SlotGameScreenState extends State<SlotGameScreen>
    with SingleTickerProviderStateMixin {
  int _balance = 0;
  String _message = "SPIN TO WIN";
  bool _spinning = false;
  int _bet = 10;

  final List<String> _symbols = [];
  List<String> _currentReels = ["?", "?", "?"];

  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _balance = AuthService.currentBalance;
    _symbols.addAll(widget.theme.symbols);
    _currentReels = [_symbols[0], _symbols[0], _symbols[0]];
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
    AuthService.updateBalance(-_bet, gameName: widget.theme.title);
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
      if (_currentReels[0] == widget.theme.symbols.last) mult = 100;
      if (_currentReels[0] == widget.theme.symbols.first) mult = 50;
      AuthService.updateBalance(_bet * mult, gameName: '${widget.theme.title} Win');
      setState(() {
        _message = "JACKPOT! WON \$${_bet * mult}";
      });
    } else if (_currentReels[0] == _currentReels[1] ||
        _currentReels[1] == _currentReels[2] ||
        _currentReels[0] == _currentReels[2]) {
      AuthService.updateBalance(_bet * 2, gameName: '${widget.theme.title} Win');
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            children: [
              Text(widget.theme.title.toUpperCase(), style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: widget.theme.primaryColor, fontStyle: FontStyle.italic)),
              Text("\$$_balance AVAILABLE BALANCE", style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 8, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: widget.theme.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
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
