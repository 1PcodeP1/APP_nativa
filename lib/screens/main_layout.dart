import 'package:flutter/material.dart';
import '../theme.dart';
import 'lobby_screen.dart';
import 'roulette_screen.dart'; // Maybe replace with a generic tables screen later, for now Roulette
import 'slots_screen.dart';
import 'promos_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({Key? key}) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const LobbyScreen(),
    const RouletteScreen(), // TODO: Change to a generic Tables screen if needed
    const SlotsScreen(),
    const PromosScreen(),
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
              icon: Icon(Icons.casino_outlined),
              activeIcon: Icon(Icons.casino),
              label: 'LOBBY',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.style_outlined),
              activeIcon: Icon(Icons.style),
              label: 'TABLES',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.view_comfy_alt_outlined),
              activeIcon: Icon(Icons.view_comfy_alt),
              label: 'SLOTS',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events_outlined),
              activeIcon: Icon(Icons.emoji_events),
              label: 'PROMOS',
            ),
          ],
          selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0),
          unselectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.normal, letterSpacing: 1.0),
        ),
      ),
    );
  }
}
