import 'package:flutter/material.dart';
import '../theme.dart';
import 'lobby_screen.dart';
import 'slots_screen.dart'; // Este será nuestro tab de "JUEGO" simulador
import 'score_screen.dart';
import 'credits_screen.dart';
import '../services/sound_service.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({Key? key}) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    SoundService.playBackgroundJazz();
  }

  @override
  void dispose() {
    SoundService.stopBackgroundJazz();
    super.dispose();
  }
  
  final List<Widget> _screens = [
    const LobbyScreen(),
    const SlotsScreen(),
    const ScoreScreen(),
    const CreditsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          backgroundColor: AppColors.surfaceContainerLowest,
          currentIndex: _currentIndex,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.onSurface.withOpacity(0.5),
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'HOME',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.videogame_asset_outlined),
              activeIcon: Icon(Icons.videogame_asset),
              label: 'JUEGO',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.leaderboard_outlined),
              activeIcon: Icon(Icons.leaderboard),
              label: 'PUNTAJE',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.info_outline),
              activeIcon: Icon(Icons.info),
              label: 'CRÉDITOS',
            ),
          ],
          selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0),
          unselectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.normal, letterSpacing: 1.0),
        ),
      ),
    );
  }
}

