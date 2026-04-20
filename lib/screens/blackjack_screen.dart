import 'package:flutter/material.dart';
import '../theme.dart';
import '../logic/card_deck.dart';
import '../db/auth_service.dart';
import 'config_screen.dart';
import 'auth/login_screen.dart';
import 'transactions_screen.dart';

class BlackjackScreen extends StatefulWidget {
  const BlackjackScreen({Key? key}) : super(key: key);

  @override
  State<BlackjackScreen> createState() => _BlackjackScreenState();
}

class _BlackjackScreenState extends State<BlackjackScreen> {
  final Deck _deck = Deck();
  List<PlayingCard> _playerH = [];
  List<PlayingCard> _dealerH = [];
  
  bool _isPlaying = false;
  bool _gameOver = false;
  String _message = "Place your bet.";
  int _betAmount = 100;
  int _activeBet = 0;
  int _balance = 0;

  @override
  void initState() {
    super.initState();
    _balance = AuthService.currentBalance;
  }

  void _updateBal(int amount) {
    AuthService.updateBalance(amount, gameName: 'Blackjack');
    setState(() { _balance = AuthService.currentBalance; });
  }

  int _calcHand(List<PlayingCard> hand) {
    int v = 0;
    int a = 0;
    for (var c in hand) {
      v += c.blackjackValue;
      if (c.rank == Rank.ace) a++;
    }
    while (v > 21 && a > 0) {
      v -= 10;
      a--;
    }
    return v;
  }

  void _placeBet() {
    if (_balance < _betAmount) {
      setState(() => _message = "Not enough funds.");
      return;
    }
    _updateBal(-_betAmount);
    setState(() {
      _activeBet = _betAmount;
      _playerH = [_deck.draw(), _deck.draw()];
      _dealerH = [_deck.draw(), _deck.draw()];
      _isPlaying = true;
      _gameOver = false;
      _message = "";
      if (_calcHand(_playerH) == 21) {
        _endGame();
      }
    });
  }

  void _fold() { // Surrender
    if (_playerH.length == 2 && !_gameOver) {
      setState(() {
        _message = "SURRENDER. RETURN HALF BET.";
        _updateBal((_activeBet / 2).toInt());
        _gameOver = true;
        _isPlaying = false;
      });
    }
  }

  void _doubleDown() {
    if (_playerH.length == 2 && !_gameOver) {
      if (_balance >= _activeBet) {
        _updateBal(-_activeBet);
        _activeBet *= 2;
        setState(() {
          _playerH.add(_deck.draw());
          if (_calcHand(_playerH) > 21) {
            _message = "BUST! YOU LOSE.";
            _endGame();
          } else {
            _stand();
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Not enough funds to Double.", style: TextStyle(color: Colors.white)), backgroundColor: Colors.red));
      }
    }
  }

  void _split() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Split functionality coming in next update.", style: TextStyle(color: Colors.white))));
  }

  void _hit() {
    setState(() {
      _playerH.add(_deck.draw());
      if (_calcHand(_playerH) > 21) {
        _message = "BUST! YOU LOSE.";
        _endGame();
      }
    });
  }

  void _stand() {
    setState(() {
      while (_calcHand(_dealerH) < 17) {
        _dealerH.add(_deck.draw());
      }
      _endGame();
    });
  }

  void _endGame() {
    _gameOver = true;
    _isPlaying = false;
    int pV = _calcHand(_playerH);
    int dV = _calcHand(_dealerH);

    if (pV <= 21) {
      if (pV == 21 && _playerH.length == 2 && !(dV == 21 && _dealerH.length == 2)) {
        _message = "BLACKJACK! YOU WIN 3:2";
        _updateBal((_activeBet * 2.5).toInt());
      } else if (dV > 21 || pV > dV) {
        _message = "YOU WIN!";
        _updateBal(_activeBet * 2);
      } else if (pV < dV) {
        _message = "DEALER WINS.";
      } else {
        _message = "PUSH (TIE).";
        _updateBal(_activeBet);
      }
    }
  }

  Widget _buildActionButton(String label, VoidCallback? onPressed, {bool isPrimary = false}) {
    return InkWell(
      onTap: onPressed ?? () {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("$label action coming soon!"),
          backgroundColor: AppColors.surfaceVariant,
        ));
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : Colors.black.withValues(alpha: 0.8),
          border: Border.all(color: AppColors.primary, width: isPrimary ? 0 : 1),
          borderRadius: BorderRadius.circular(4),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isPrimary ? Colors.black : AppColors.primary,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
      body: Stack(
        children: [
          // Red Felt Background
          Positioned(
            top: -100, bottom: -100, left: -50, right: -50,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF8B0000).withValues(alpha: 0.6), // Dark Red Felt
                borderRadius: BorderRadius.circular(400),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.1), width: 2),
              ),
            ),
          ),
          // GRAND STAKES Watermark
          Center(
            child: Opacity(
              opacity: 0.05,
              child: Text(
                "GRAND\nSTAKES",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 80,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.0,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
          // Game Elements
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 32),
                const Text("DEALER STANDS ON 17", style: TextStyle(color: AppColors.primary, fontSize: 10, letterSpacing: 2.0, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                
                // Dealer Area
                if (_dealerH.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _dealerH.asMap().entries.map((e) {
                      bool isHidden = !_gameOver && e.key == 0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _PlayingCardMockup(card: e.value, isHidden: isHidden),
                      );
                    }).toList(),
                  ),
                
                const Spacer(),
                
                // Center Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text("BLACKJACK PAYS 3 TO 2", style: TextStyle(color: AppColors.primary, fontSize: 12, letterSpacing: 2.0, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                ),
                
                const Spacer(),
                
                // Player Area
                if (_playerH.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _playerH.map((c) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _PlayingCardMockup(card: c),
                    )).toList(),
                  ),
                
                const SizedBox(height: 16),
                
                if (_message.isNotEmpty)
                  Text(_message, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.primary)),
                
                const SizedBox(height: 24),
                
                // Controls
                if (!_isPlaying) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: AppColors.primary),
                        onPressed: () {
                          if (_betAmount > 10) setState(() => _betAmount -= 10);
                        },
                      ),
                      Text("\$$_betAmount", style: Theme.of(context).textTheme.headlineMedium),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                        onPressed: () {
                          if (_betAmount + 10 <= _balance) setState(() => _betAmount += 10);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: _placeBet,
                    child: Ink(
                      padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 16),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.primary, AppColors.primaryContainer],
                        ),
                      ),
                      child: Text("PLACE BET", style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.surface, fontWeight: FontWeight.bold)),
                    ),
                  )
                ] else ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton("FOLD", _fold),
                        _buildActionButton("STAND", _stand),
                        _buildActionButton("HIT", _hit, isPrimary: true),
                        _buildActionButton("DOUBLE", _doubleDown),
                        _buildActionButton("SPLIT", _split),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayingCardMockup extends StatefulWidget {
  final PlayingCard? card;
  final bool isHidden;

  const _PlayingCardMockup({Key? key, this.card, this.isHidden = false}) : super(key: key);

  @override
  State<_PlayingCardMockup> createState() => _PlayingCardMockupState();
}

class _PlayingCardMockupState extends State<_PlayingCardMockup> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _slideAnim = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isHidden || widget.card == null) {
      return SlideTransition(
        position: _slideAnim,
        child: Container(
          width: 80,
          height: 110,
          decoration: BoxDecoration(
            color: const Color(0xFF382A2A), // Dark brown back
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.5), width: 1.5),
            boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 4, offset: Offset(2, 2))],
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.diamond_outlined, color: AppColors.primary, size: 32),
        ),
      );
    }
    
    return SlideTransition(
      position: _slideAnim,
      child: Transform.rotate(
        angle: (widget.card.hashCode % 10 - 5) * 0.01, // Slight random rotation
        child: Container(
          width: 80,
          height: 110,
          decoration: BoxDecoration(
            color: const Color(0xFFEAEAEA),
            borderRadius: BorderRadius.circular(6),
            boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 4, offset: Offset(2, 2))],
          ),
          padding: const EdgeInsets.all(6),
          child: Stack(
            children: [
              Positioned(
                top: 0, left: 0,
                child: Column(
                  children: [
                    Text(widget.card!.label, style: TextStyle(color: widget.card!.isRed ? const Color(0xFFD32F2F) : Colors.black87, fontSize: 18, fontWeight: FontWeight.w900)),
                    Text(widget.card!.suitSymbol, style: TextStyle(color: widget.card!.isRed ? const Color(0xFFFFCDD2) : Colors.black38, fontSize: 12)),
                  ],
                ),
              ),
              const Center(
                child: Icon(Icons.swipe_outlined, color: Colors.black87, size: 28),
              ),
              Positioned(
                bottom: 0, right: 0,
                child: RotatedBox(
                  quarterTurns: 2,
                  child: Column(
                    children: [
                      Text(widget.card!.label, style: TextStyle(color: widget.card!.isRed ? const Color(0xFFD32F2F) : Colors.black87, fontSize: 18, fontWeight: FontWeight.w900)),
                      Text(widget.card!.suitSymbol, style: TextStyle(color: widget.card!.isRed ? const Color(0xFFFFCDD2) : Colors.black38, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
