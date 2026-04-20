import 'package:flutter/material.dart';
import 'screens/main_layout.dart';
import 'screens/auth/login_screen.dart';
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
      title: 'Grand Stakes',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: AuthService.isLoggedIn ? const MainLayout() : const LoginScreen(),
    );
  }
}
