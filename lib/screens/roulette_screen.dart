import 'package:flutter/material.dart';
import 'dart:math';
import '../theme.dart';
import '../db/auth_service.dart';

// Standard European Roulette Sequence
const List<int> rouletteSequence = [
  0, 32, 15, 19, 4, 21, 2, 25, 17, 34, 6, 27, 13, 36, 11, 30, 8, 23, 10, 5,
  24, 16, 33, 1, 20, 14, 31, 9, 22, 18, 29, 7, 28, 12, 35, 3, 26
];

// Logic export for testing
Color getRouletteColor(int number) {
  if (number == 0) return AppColors.tertiary;
  const redNumbers = {1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36};
  return redNumbers.contains(number) ? AppColors.secondaryContainer : Colors.black;
}

class RouletteScreen extends StatefulWidget {
  const RouletteScreen({super.key});

  @override
  State<RouletteScreen> createState() => _RouletteScreenState();
}

class _RouletteScreenState extends State<RouletteScreen> with SingleTickerProviderStateMixin {
  late AnimationController _spinCtrl;
  Animation<double>? _wheelAnimation;
  Animation<double>? _ballAnimation;
  Animation<double>? _ballRadiusAnimation;

  bool _isSpinning = false;
  
  int _balance = 0;
  int _selectedChip = 10;
  final Map<String, int> _placedBets = {}; // zone -> amount
  final List<int> _history = []; // History of winning numbers
  
  int? _winningNumber;

  double _wheelAngle = 0;
  double _ballAngle = 0;

  final List<int> _chips = [1, 5, 10, 25, 100];

  @override
  void initState() {
    super.initState();
    _balance = AuthService.currentBalance;
    _spinCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 4));
    
    // Start with the ball at rest in the 0 slot
    _wheelAngle = 0;
    _ballAngle = 0; 
  }
  
  @override
  void dispose() {
    _spinCtrl.dispose();
    super.dispose();
  }

  void _placeBet(String zone) {
    if (_isSpinning) return;
    if (_balance < _selectedChip) return;

    AuthService.updateBalance(-_selectedChip);
    setState(() {
      _balance = AuthService.currentBalance;
      _placedBets[zone] = (_placedBets[zone] ?? 0) + _selectedChip;
      _winningNumber = null;
    });
  }

  void _repeatBet() {
    // Optional feature
  }

  Future<void> _spinRoulette() async {
    if (_isSpinning || _placedBets.isEmpty) return;

    setState(() {
      _isSpinning = true;
      _winningNumber = null;
    });

    final resultNumber = Random().nextInt(37);
    final winIndex = rouletteSequence.indexOf(resultNumber);
    final segmentAngle = (2 * pi / 37);
    final targetRelativeAngle = winIndex * segmentAngle;

    final double wheelSpins = 4.0; 
    final double ballSpins = -5.0; 

    final randomWheelOffset = Random().nextDouble() * 2 * pi;
    final endWheelAngle = _wheelAngle + (wheelSpins * 2 * pi) + randomWheelOffset;

    double normalizedTarget = (endWheelAngle + targetRelativeAngle) % (2 * pi);
    double currentBallMod = _ballAngle % (2 * pi);
    double diff = normalizedTarget - currentBallMod;
    if (diff > 0) diff -= 2 * pi; 
    
    double totalBallDiff = diff + (ballSpins * 2 * pi);
    double endBallAngle = _ballAngle + totalBallDiff;

    _wheelAnimation = Tween<double>(begin: _wheelAngle, end: endWheelAngle).animate(
      CurvedAnimation(parent: _spinCtrl, curve: Curves.easeOutCubic)
    );

    _ballAnimation = Tween<double>(begin: _ballAngle, end: endBallAngle).animate(
      CurvedAnimation(parent: _spinCtrl, curve: Curves.easeOutCubic)
    );

    _ballRadiusAnimation = TweenSequence([
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeIn)), weight: 70),
    ]).animate(_spinCtrl);

    await _spinCtrl.forward(from: 0);
    
    if (!mounted) return;

    _wheelAngle = endWheelAngle % (2 * pi);
    _ballAngle = endBallAngle % (2 * pi);

    int totalWin = 0;
    _placedBets.forEach((zone, amount) {
      if (zone == resultNumber.toString()) {
        totalWin += amount * 36;
      } else if (zone == "1ST 12" && resultNumber >= 1 && resultNumber <= 12) {
        totalWin += amount * 3;
      } else if (zone == "2ND 12" && resultNumber >= 13 && resultNumber <= 24) {
        totalWin += amount * 3;
      } else if (zone == "3RD 12" && resultNumber >= 25 && resultNumber <= 36) {
        totalWin += amount * 3;
      } else if (zone == "1 TO 18" && resultNumber >= 1 && resultNumber <= 18) {
        totalWin += amount * 2;
      } else if (zone == "19 TO 36" && resultNumber >= 19 && resultNumber <= 36) {
        totalWin += amount * 2;
      } else if (zone == "EVEN" && resultNumber != 0 && resultNumber % 2 == 0) {
        totalWin += amount * 2;
      } else if (zone == "ODD" && resultNumber != 0 && resultNumber % 2 != 0) {
        totalWin += amount * 2;
      } else if (zone == "RED" && resultNumber != 0 && getRouletteColor(resultNumber) == AppColors.secondaryContainer) {
        totalWin += amount * 2;
      } else if (zone == "BLACK" && resultNumber != 0 && getRouletteColor(resultNumber) == Colors.black) {
        totalWin += amount * 2;
      }
    });

    if (totalWin > 0) {
      AuthService.updateBalance(totalWin, gameName: 'Roulette Win');
    }

    setState(() {
      _winningNumber = resultNumber;
      _balance = AuthService.currentBalance;
      _placedBets.clear();
      _isSpinning = false;
      _history.insert(0, resultNumber);
      if (_history.length > 10) _history.removeLast();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppColors.primary),
          onPressed: () { /* Menu */ },
        ),
        title: Text(
          "GRAND STAKES",
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppColors.primary,
            fontStyle: FontStyle.italic,
          ),
        ),
        centerTitle: false,
        actions: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Text(
                "\$$_balance",
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // Upper Section: Wheel
          Expanded(
            flex: 5,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 280,
                    height: 280,
                    child: AnimatedBuilder(
                      animation: _spinCtrl,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: RouletteWheelPainter(
                            _wheelAnimation?.value ?? _wheelAngle,
                            _ballAnimation?.value ?? _ballAngle,
                            _ballRadiusAnimation?.value ?? 0.0,
                          ),
                        );
                      }
                    ),
                  ),
                  if (_winningNumber != null && !_isSpinning)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withOpacity(0.9),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),
                      child: Text(
                        _winningNumber.toString(),
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: getRouletteColor(_winningNumber!),
                        ),
                      ),
                    )
                ],
              ),
            ),
          ),
          
          // Middle Section: Betting Grid
          Expanded(
            flex: 5,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHistory(),
                  _buildBettingGrid(),
                ],
              ),
            ),
          ),

          // Lower Section: Chips and Controls
          SafeArea(
            child: Container(
              color: AppColors.surfaceContainerHigh, 
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildActionIcon(Icons.undo, () {}),
                        const SizedBox(width: 16),
                        ..._chips.map((val) => _buildChip(val)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildButton("REPEAT BET", false, _repeatBet),
                      const SizedBox(width: 16),
                      _buildButton("SPIN", true, _spinRoulette),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBettingGrid() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 0 Area
        _buildZone("0", AppColors.tertiary, width: 50, height: 150),
        
        // 1-36 Numbers Area
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: List.generate(12, (index) {
                int number = 3 + (index * 3);
                return _buildZone(number.toString(), getRouletteColor(number));
              }),
            ),
            Row(
              children: List.generate(12, (index) {
                int number = 2 + (index * 3);
                return _buildZone(number.toString(), getRouletteColor(number));
              }),
            ),
            Row(
              children: List.generate(12, (index) {
                int number = 1 + (index * 3);
                return _buildZone(number.toString(), getRouletteColor(number));
              }),
            ),
            // Dozens
            Row(
              children: [
                _buildZone("1ST 12", Colors.transparent, width: 200, height: 40, isDozen: true),
                _buildZone("2ND 12", Colors.transparent, width: 200, height: 40, isDozen: true),
                _buildZone("3RD 12", Colors.transparent, width: 200, height: 40, isDozen: true),
              ],
            ),
            // Outside Bets
            Row(
              children: [
                _buildZone("1 TO 18", Colors.transparent, width: 100, height: 40, isDozen: true),
                _buildZone("EVEN", Colors.transparent, width: 100, height: 40, isDozen: true),
                _buildZone("RED", AppColors.secondaryContainer, width: 100, height: 40, isDozen: true),
                _buildZone("BLACK", Colors.black, width: 100, height: 40, isDozen: true),
                _buildZone("ODD", Colors.transparent, width: 100, height: 40, isDozen: true),
                _buildZone("19 TO 36", Colors.transparent, width: 100, height: 40, isDozen: true),
              ],
            )
          ],
        )
      ],
    );
  }

  Widget _buildZone(String label, Color color, {double width = 50, double height = 50, bool isDozen = false}) {
    int betAmt = _placedBets[label] ?? 0;
    
    return GestureDetector(
      onTap: () => _placeBet(label),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color == Colors.transparent ? AppColors.surfaceVariant : color,
          border: Border.all(color: AppColors.surface, width: 1),
        ),
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: isDozen ? 12 : 16,
              ),
            ),
            if (betAmt > 0)
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surface, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  betAmt >= 1000 ? "${(betAmt / 1000).toStringAsFixed(1)}k" : betAmt.toString(),
                  style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistory() {
    if (_history.isEmpty) return const SizedBox(height: 40);
    return Container(
      height: 40,
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Text("HISTORY:  ", style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          ..._history.map((num) => Container(
            width: 32,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: getRouletteColor(num),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.surface, width: 1),
            ),
            alignment: Alignment.center,
            child: Text(
              num.toString(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.outline),
      ),
    );
  }

  Widget _buildChip(int value) {
    bool isSelected = _selectedChip == value;
    Color chipColor;
    switch (value) {
      case 1: chipColor = AppColors.surfaceVariant; break;
      case 5: chipColor = Colors.blue.shade800; break;
      case 10: chipColor = AppColors.primary; break;
      case 25: chipColor = AppColors.tertiary; break;
      case 100: chipColor = Colors.purple.shade800; break;
      default: chipColor = AppColors.secondaryContainer;
    }

    return GestureDetector(
      onTap: () => setState(() => _selectedChip = value),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: isSelected ? 50 : 40,
        height: isSelected ? 50 : 40,
        decoration: BoxDecoration(
          color: chipColor,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: AppColors.primaryContainer, width: 3) : Border.all(color: Colors.white24, width: 1),
          boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withOpacity(0.5), blurRadius: 10)] : [],
        ),
        alignment: Alignment.center,
        child: Text(
          value.toString(),
          style: TextStyle(
            color: isSelected && value == 10 ? AppColors.surface : AppColors.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: isSelected ? 18 : 14,
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String text, bool isPrimary, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : Colors.transparent,
          border: isPrimary ? null : Border.all(color: AppColors.outline),
          borderRadius: BorderRadius.circular(4),
          gradient: isPrimary ? const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryContainer],
          ) : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isPrimary ? AppColors.surface : AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class RouletteWheelPainter extends CustomPainter {
  final double wheelAngle;
  final double ballAngle;
  final double ballRadius;

  RouletteWheelPainter(this.wheelAngle, this.ballAngle, this.ballRadius);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw wood outer rim
    canvas.drawCircle(center, radius, Paint()..color = const Color(0xFF2A1C15));
    // Draw golden inner rim
    canvas.drawCircle(center, radius * 0.92, Paint()..color = AppColors.primaryContainer);
    // Draw black wheel base
    canvas.drawCircle(center, radius * 0.88, Paint()..color = const Color(0xFF1A1A1A));

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(wheelAngle);

    final segmentAngle = 2 * pi / 37;
    for (int i = 0; i < 37; i++) {
      int num = rouletteSequence[i];
      Color color = getRouletteColor(num);
      
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      
      // Draw slot arc
      canvas.drawArc(
        Rect.fromCircle(center: Offset.zero, radius: radius * 0.88),
        i * segmentAngle - segmentAngle / 2,
        segmentAngle,
        true,
        paint,
      );

      // Draw number text
      canvas.save();
      canvas.rotate(i * segmentAngle);
      canvas.translate(radius * 0.72, 0);
      canvas.rotate(pi / 2); // Orient text
      
      TextPainter tp = TextPainter(
        text: TextSpan(
          text: num.toString(), 
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }
    
    // Draw inner metallic center
    canvas.drawCircle(Offset.zero, radius * 0.55, Paint()..color = const Color(0xFF2C2C2C));
    canvas.drawCircle(Offset.zero, radius * 0.53, Paint()..color = AppColors.primaryContainer);
    canvas.drawCircle(Offset.zero, radius * 0.45, Paint()..color = const Color(0xFF3C3C3C));
    // Draw center cone
    canvas.drawCircle(Offset.zero, radius * 0.15, Paint()..color = AppColors.primary);

    // Draw 4 golden crossbars in center
    final crossbarPaint = Paint()..color = AppColors.primary..strokeWidth = 4;
    for (int i = 0; i < 4; i++) {
      canvas.save();
      canvas.rotate(i * pi / 2);
      canvas.drawLine(Offset.zero, Offset(radius * 0.45, 0), crossbarPaint);
      canvas.restore();
    }

    canvas.restore();

    // Draw ball
    // ballRadius = 1.0 (outer wood rim), 0.0 (in the numbered slot)
    final outerDistance = radius * 0.94;
    final innerDistance = radius * 0.80; // Distance of the numbered slots
    final ballDistance = innerDistance + (outerDistance - innerDistance) * ballRadius; 
    
    final ballX = center.dx + ballDistance * cos(ballAngle);
    final ballY = center.dy + ballDistance * sin(ballAngle);

    // Ball shadow
    canvas.drawCircle(Offset(ballX - 2, ballY + 2), 6, Paint()..color = Colors.black.withOpacity(0.5));
    // Ball base
    canvas.drawCircle(Offset(ballX, ballY), 6, Paint()..color = Colors.white);
    // Ball specular highlight
    canvas.drawCircle(Offset(ballX - 2, ballY - 2), 2, Paint()..color = Colors.white.withOpacity(0.8));
  }

  @override
  bool shouldRepaint(covariant RouletteWheelPainter oldDelegate) {
    return oldDelegate.wheelAngle != wheelAngle ||
           oldDelegate.ballAngle != ballAngle ||
           oldDelegate.ballRadius != ballRadius;
  }
}
