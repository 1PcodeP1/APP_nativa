import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'theme.dart';
import 'db/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.init();
  runApp(const GrandStakesApp());
}

class GrandStakesApp extends StatelessWidget {
  const GrandStakesApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grand Stakes Pro Sim',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: const SplashScreen(),
    );
  }
}

