import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../db/auth_service.dart';
import 'config_screen.dart';
import 'auth/login_screen.dart';
import 'transactions_screen.dart';
import '../services/sound_service.dart';

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
  int _coinValue = 1;
  int _lines = 20;
  int get _totalBet => _coinValue * _lines;

  final List<String> _symbols = [];
  List<List<String>> _currentReels = List.generate(5, (_) => ["?", "?", "?", "?"]);
  final List<bool> _spinningReels = [false, false, false, false, false];
  int _spinCounter = 0;

  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _balance = AuthService.currentBalance;
    _symbols.addAll(widget.theme.symbols);
    _currentReels = List.generate(5, (_) => List.generate(4, (_) => _symbols[0]));
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
    if (_balance < _totalBet || _spinning) return;
    SoundService.playSpin();
    AuthService.updateBalance(-_totalBet, gameName: widget.theme.title);
    setState(() {
      _spinning = true;
      for (int i=0; i<5; i++) _spinningReels[i] = true;
      _balance = AuthService.currentBalance;
      _message = "SPINNING...";
    });

    _ctrl.repeat();

    // Simular el giro constante
    for (int i = 0; i < 25; i++) {
      await Future.delayed(const Duration(milliseconds: 80));
      if (!mounted) return;
      setState(() {
        _spinCounter++;
        for(int c=0; c<5; c++) {
          if(_spinningReels[c]) {
            for(int r=0; r<4; r++) {
              _currentReels[c][r] = _symbols[Random().nextInt(_symbols.length)];
            }
          }
        }
      });
      
      // Paradas escalonadas (staggered stopping effect)
      if (i == 10) setState(() => _spinningReels[0] = false);
      if (i == 14) setState(() => _spinningReels[1] = false);
      if (i == 18) setState(() => _spinningReels[2] = false);
      if (i == 21) setState(() => _spinningReels[3] = false);
      if (i == 24) setState(() => _spinningReels[4] = false);
    }

    _ctrl.stop();
    _checkWin();
  }

  void _checkWin() {
    Map<String, int> counts = {};
    for (var col in _currentReels) {
      for (var s in col) {
        counts[s] = (counts[s] ?? 0) + 1;
      }
    }
    
    int maxCount = 0;
    counts.forEach((k, v) {
      if (v > maxCount && k != "?") {
        maxCount = v;
      }
    });

    if (maxCount >= 8) {
      SoundService.playSlotJackpot();
      int mult = 500;
      AuthService.updateBalance(_totalBet * mult, gameName: '${widget.theme.title} Grand');
      setState(() => _message = "GRAND JACKPOT! WON \$${_totalBet * mult}");
    } else if (maxCount >= 6) {
      SoundService.playSlotJackpot();
      int mult = 100;
      AuthService.updateBalance(_totalBet * mult, gameName: '${widget.theme.title} Major');
      setState(() => _message = "MAJOR WIN! WON \$${_totalBet * mult}");
    } else if (maxCount >= 5) {
      SoundService.playSlotJackpot();
      int mult = 25;
      AuthService.updateBalance(_totalBet * mult, gameName: '${widget.theme.title} Minor');
      setState(() => _message = "MINOR WIN! WON \$${_totalBet * mult}");
    } else if (maxCount >= 4) {
      SoundService.playClick();
      int mult = 5;
      AuthService.updateBalance(_totalBet * mult, gameName: '${widget.theme.title} Mini');
      setState(() => _message = "MINI WIN! WON \$${_totalBet * mult}");
    } else {
      setState(() => _message = "NO LUCK.");
    }
    setState(() {
      _spinning = false;
      _balance = AuthService.currentBalance;
    });
  }

  Widget _buildJackpot(String label, int amount, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1.5)),
        Text("\$$amount", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }

  Widget _buildBetControl(String label, String value, VoidCallback onDec, VoidCallback onInc) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 10, fontWeight: FontWeight.bold)),
        Row(
          children: [
            InkWell(onTap: onDec, child: const Icon(Icons.remove_circle_outline, color: AppColors.primary, size: 20)),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
            InkWell(onTap: onInc, child: const Icon(Icons.add_circle_outline, color: AppColors.primary, size: 20)),
          ],
        ),
      ],
    );
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
              Text("\$$_balance AVAILABLE BALANCE", style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 8, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: widget.theme.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Jackpots Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: widget.theme.primaryColor, width: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildJackpot("GRAND", _totalBet * 500, Colors.redAccent),
                _buildJackpot("MAJOR", _totalBet * 100, Colors.orangeAccent),
                _buildJackpot("MINOR", _totalBet * 25, Colors.blueAccent),
                _buildJackpot("MINI", _totalBet * 5, Colors.purpleAccent),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          AnimatedScale(
            scale: _message.contains("WIN") || _message.contains("JACKPOT") ? 1.1 : 1.0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.elasticOut,
            child: Text(
              _message,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: _message.contains("WIN") || _message.contains("JACKPOT") ? Colors.amber : AppColors.primary,
                shadows: _message.contains("WIN") || _message.contains("JACKPOT") ? [const Shadow(color: Colors.amberAccent, blurRadius: 10)] : [],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Slot Grid
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              border: Border.all(color: widget.theme.primaryColor, width: 6),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: widget.theme.primaryColor.withValues(alpha: 0.2), blurRadius: 30, spreadRadius: 5),
              ],
            ),
            child: FittedBox(
              fit: BoxFit.contain,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (c) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(4, (r) => _buildReelCell(_currentReels[c][r], c, r)),
                  ),
                )),
              ),
            ),
          ),
          const SizedBox(height: 32),
          
          // Controls
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: widget.theme.primaryColor.withValues(alpha: 0.5), width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBetControl("COIN", "\$$_coinValue", () { if (!_spinning && _coinValue > 1) { SoundService.playClick(); setState(()=> _coinValue--); } }, () { if (!_spinning && _coinValue < 10) { SoundService.playClick(); setState(()=> _coinValue++); } }),
                _buildBetControl("LINES", "$_lines", () { if (!_spinning && _lines > 5) { SoundService.playClick(); setState(()=> _lines-=5); } }, () { if (!_spinning && _lines < 25) { SoundService.playClick(); setState(()=> _lines+=5); } }),
                Column(
                  children: [
                    const Text("TOTAL BET", style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 10, fontWeight: FontWeight.bold)),
                    Text("\$$_totalBet", style: const TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.w900)),
                  ],
                ),
                InkWell(
                  onTap: _spinning ? null : () => setState(() { _coinValue = 10; _lines = 25; }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: Colors.red.shade900, borderRadius: BorderRadius.circular(4)),
                    child: const Text("MAX\nBET", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: _spin,
            child: Ink(
              padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  colors: _spinning
                      ? [Colors.grey.shade900, Colors.grey.shade800]
                      : [widget.theme.primaryColor, AppColors.primaryContainer],
                ),
                boxShadow: _spinning ? [] : [
                  BoxShadow(color: widget.theme.primaryColor.withValues(alpha: 0.5), blurRadius: 15, offset: const Offset(0, 4))
                ]
              ),
              child: Text(
                "SPIN",
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppColors.surface,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReelCell(String icon, int colIndex, int rowIndex) {
    return Container(
      width: 55,
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white12, width: 1),
      ),
      alignment: Alignment.center,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 150),
        switchInCurve: Curves.bounceOut,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(animation),
            child: child,
          );
        },
        child: Text(
          icon, 
          key: ValueKey<String>("$colIndex-$rowIndex-$icon-$_spinCounter"), 
          style: const TextStyle(fontSize: 32)
        ),
      ),
    );
  }
}
