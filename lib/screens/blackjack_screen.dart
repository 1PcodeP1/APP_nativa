import 'package:flutter/material.dart';
import '../theme.dart';
import '../logic/card_deck.dart';
import '../db/auth_service.dart';
import '../services/sound_service.dart';
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
  List<PlayingCard> _splitH = []; // New split hand
  List<PlayingCard> _dealerH = [];
  
  bool _isPlaying = false;
  bool _gameOver = false;
  String _message = "Place your bet.";
  int _betAmount = 100;
  int _activeBet = 0;
  int _splitBet = 0; // Bet for split hand
  int _balance = 0;
  
  int _activeHand = 1; // 1 or 2

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
    SoundService.playClick();
    SoundService.playCardDraw();
    setState(() {
      _activeBet = _betAmount;
      _splitBet = 0;
      _playerH = [_deck.draw(), _deck.draw()];
      _splitH = [];
      _dealerH = [_deck.draw(), _deck.draw()];
      _isPlaying = true;
      _gameOver = false;
      _activeHand = 1;
      _message = "";
      if (_calcHand(_playerH) == 21) {
        _endGame();
      }
    });
  }

  void _fold() { // Surrender
    if (_playerH.length == 2 && !_gameOver && _splitH.isEmpty) {
      setState(() {
        _message = "SURRENDER. RETURN HALF BET.";
        _updateBal((_activeBet / 2).toInt());
        _gameOver = true;
        _isPlaying = false;
      });
    }
  }

  void _doubleDown() {
    if ((_activeHand == 1 ? _playerH.length : _splitH.length) == 2 && !_gameOver) {
      if (_balance >= (_activeHand == 1 ? _activeBet : _splitBet)) {
        int bet = _activeHand == 1 ? _activeBet : _splitBet;
        _updateBal(-bet);
        if (_activeHand == 1) _activeBet *= 2; else _splitBet *= 2;
        SoundService.playCardDraw();
        setState(() {
          if (_activeHand == 1) {
             _playerH.add(_deck.draw());
             if (_calcHand(_playerH) > 21) {
               if (_splitH.isEmpty) { _message = "BUST! YOU LOSE."; _endGame(); } else { _stand(); }
             } else { _stand(); }
          } else {
             _splitH.add(_deck.draw());
             _stand();
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Not enough funds to Double.", style: TextStyle(color: Colors.white)), backgroundColor: Colors.red));
      }
    }
  }

  void _split() {
    if (_playerH.length == 2 && _splitH.isEmpty && _playerH[0].blackjackValue == _playerH[1].blackjackValue) {
      if (_balance >= _activeBet) {
        _updateBal(-_activeBet);
        SoundService.playCardDraw();
        setState(() {
          _splitBet = _activeBet;
          _splitH = [_playerH.removeLast(), _deck.draw()];
          _playerH.add(_deck.draw());
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Not enough funds to Split.", style: TextStyle(color: Colors.white)), backgroundColor: Colors.red));
      }
    }
  }

  void _hit() {
    SoundService.playCardDraw();
    setState(() {
      if (_activeHand == 1) {
        _playerH.add(_deck.draw());
        if (_calcHand(_playerH) > 21) {
           if (_splitH.isNotEmpty) {
             _activeHand = 2; // Move to hand 2
           } else {
             _message = "BUST! YOU LOSE.";
             _endGame();
           }
        }
      } else {
        _splitH.add(_deck.draw());
        if (_calcHand(_splitH) > 21) {
           _stand();
        }
      }
    });
  }

  void _stand() {
    setState(() {
      if (_splitH.isNotEmpty && _activeHand == 1) {
        _activeHand = 2; // Move to second hand
      } else {
        while (_calcHand(_dealerH) < 17) {
          _dealerH.add(_deck.draw());
        }
        _endGame();
      }
    });
  }

  void _endGame() {
    _gameOver = true;
    _isPlaying = false;
    
    int dV = _calcHand(_dealerH);
    int pV = _calcHand(_playerH);
    
    // Evaluate Hand 1
    String res1 = "";
    if (pV <= 21) {
      if (pV == 21 && _playerH.length == 2 && !(dV == 21 && _dealerH.length == 2) && _splitH.isEmpty) {
        res1 = "BLACKJACK! (3:2)";
        SoundService.playWin();
        _updateBal((_activeBet * 2.5).toInt());
      } else if (dV > 21 || pV > dV) {
        res1 = "WIN";
        SoundService.playWin();
        _updateBal(_activeBet * 2);
      } else if (pV < dV) {
        res1 = "LOSE";
      } else {
        res1 = "PUSH";
        _updateBal(_activeBet);
      }
    } else {
      res1 = "BUST";
    }

    // Evaluate Hand 2 (if exists)
    if (_splitH.isNotEmpty) {
      int sV = _calcHand(_splitH);
      String res2 = "";
      if (sV <= 21) {
         if (dV > 21 || sV > dV) {
            res2 = "WIN";
            SoundService.playWin();
            _updateBal(_splitBet * 2);
         } else if (sV < dV) {
            res2 = "LOSE";
         } else {
            res2 = "PUSH";
            _updateBal(_splitBet);
         }
      } else {
        res2 = "BUST";
      }
      _message = "H1: $res1 | H2: $res2";
    } else {
      _message = res1 == "WIN" ? "YOU WIN! +\$${_activeBet * 2}" : res1 == "LOSE" ? "DEALER WINS." : res1 == "PUSH" ? "PUSH (TIE)." : res1 == "BUST" ? "BUST! YOU LOSE." : res1;
    }
  }

  Widget _buildChip(int amount) {
    return InkWell(
      onTap: () {
        if (_betAmount + amount <= _balance) {
          SoundService.playClick();
          setState(() => _betAmount += amount);
        }
      },
      child: Container(
        width: 50, height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surfaceContainerHigh,
          border: Border.all(color: AppColors.primary, width: 2),
        ),
        alignment: Alignment.center,
        child: Text("\$$amount", style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
      ),
    );
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
                if (_splitH.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Hand 1
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(border: Border.all(color: _activeHand == 1 ? AppColors.primary : Colors.transparent, width: 2), borderRadius: BorderRadius.circular(12)),
                        child: Row(children: _playerH.map((c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 2), child: _PlayingCardMockup(card: c))).toList()),
                      ),
                      // Hand 2
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(border: Border.all(color: _activeHand == 2 ? AppColors.primary : Colors.transparent, width: 2), borderRadius: BorderRadius.circular(12)),
                        child: Row(children: _splitH.map((c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 2), child: _PlayingCardMockup(card: c))).toList()),
                      ),
                    ],
                  )
                ] else if (_playerH.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _playerH.map((c) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _PlayingCardMockup(card: c),
                    )).toList(),
                  ),
                ],
                
                const SizedBox(height: 16),
                
                if (_message.isNotEmpty)
                  AnimatedScale(
                    scale: _message.contains("WIN") || _message.contains("BLACKJACK") ? 1.2 : 1.0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.elasticOut,
                    child: Text(
                      _message,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: _message.contains("WIN") || _message.contains("BLACKJACK") ? Colors.amber : AppColors.primary,
                        shadows: _message.contains("WIN") || _message.contains("BLACKJACK") ? [const Shadow(color: Colors.amberAccent, blurRadius: 10)] : [],
                      ),
                    ),
                  ),
                
                const SizedBox(height: 24),
                
                // Controls
                if (!_isPlaying) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildChip(10),
                      const SizedBox(width: 8),
                      _buildChip(50),
                      const SizedBox(width: 8),
                      _buildChip(100),
                      const SizedBox(width: 8),
                      _buildChip(500),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(icon: const Icon(Icons.clear, color: Colors.red), onPressed: () => setState(()=> _betAmount = 10)),
                      Text("TOTAL BET: \$$_betAmount", style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.primary)),
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
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _slideAnim = Tween<Offset>(begin: const Offset(0, -6), end: Offset.zero).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack)); // Salto de la carta con 3D
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnim,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX((1.0 - _ctrl.value) * 1.5) // Voltea la carta en 3D mientras cae
              ..rotateZ(((widget.card?.hashCode ?? 0) % 10 - 5) * 0.01), // Ligera inclinación natural
            alignment: Alignment.center,
            child: child,
          );
        },
        child: _buildCard(),
      ),
    );
  }
  
  Widget _buildCard() {
    if (widget.isHidden || widget.card == null) {
      return Container(
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
      );
    }
    
    return Container(
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
          Center(
            child: Text(
              widget.card!.suitSymbol, 
              style: TextStyle(
                color: widget.card!.isRed ? const Color(0xFFD32F2F).withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.1), 
                fontSize: 60
              )
            ),
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
    );
  }
}
