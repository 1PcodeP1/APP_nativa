import 'package:flutter/material.dart';
import '../theme.dart';
import '../logic/card_deck.dart';
import '../db/auth_service.dart';

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
        _updateBal((_betAmount * 2.5).toInt());
      } else if (dV > 21 || pV > dV) {
        _message = "YOU WIN!";
        _updateBal(_betAmount * 2);
      } else if (pV < dV) {
        _message = "DEALER WINS.";
      } else {
        _message = "PUSH (TIE).";
        _updateBal(_betAmount);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Blackjack", style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(width: 16),
            Container( // Ghost Outline per Stitch
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.primary.withOpacity(0.5))),
              ),
              child: Text("\$$_balance", style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primary)),
            )
          ],
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Dealer Area
            Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("DEALER MUST DRAW TO 16, AND STAND ON 17", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.primary.withOpacity(0.5))),
                    const SizedBox(height: 16),
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
                  ],
                ),
              ),
            ),
            // Player Area
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer.withOpacity(0.1), // Felt texture
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_message.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Text(_message, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.primary)),
                      ),
                    
                    if (_playerH.isNotEmpty)
                      Text("YOUR HAND (${_calcHand(_playerH)})", style: Theme.of(context).textTheme.titleMedium),
                    
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _playerH.map((c) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _PlayingCardMockup(card: c),
                      )).toList(),
                    ),
                    const SizedBox(height: 48),
                    
                    if (!_isPlaying) ...[
                      // Apuestas
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
                      // Acciones Juego
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 48),
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: _stand,
                                child: Ink(
                                  padding: const EdgeInsets.symmetric(vertical: 24),
                                  color: AppColors.surfaceContainerHighest,
                                  child: const Center(child: Text("STAND", style: TextStyle(color: AppColors.onSurface))),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: InkWell(
                                onTap: _hit,
                                child: Ink(
                                  padding: const EdgeInsets.symmetric(vertical: 24),
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [AppColors.primary, AppColors.primaryContainer],
                                    ),
                                  ),
                                  child: const Center(child: Text("HIT", style: TextStyle(color: AppColors.surface, fontWeight: FontWeight.bold))),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ]
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
          width: 70,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.secondaryContainer,
            borderRadius: BorderRadius.circular(2),
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.diamond_outlined, color: AppColors.primary, size: 32),
        ),
      );
    }
    
    return SlideTransition(
      position: _slideAnim,
      child: Container(
        width: 70,
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(2),
          border: const Border(top: BorderSide(color: AppColors.primary, width: 2)), 
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.card!.label, style: TextStyle(color: widget.card!.isRed ? AppColors.secondaryContainer : AppColors.onSurface, fontSize: 24, fontWeight: FontWeight.bold)),
            Text(widget.card!.suitSymbol, style: TextStyle(color: widget.card!.isRed ? AppColors.secondaryContainer : AppColors.onSurface, fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
