import 'package:flutter/material.dart';
import '../../db/auth_service.dart';
import '../../theme.dart';
import '../main_layout.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;
  String? _error;

  void _loginAsGuest() async {
    String user = _usernameCtrl.text.trim();
    String pass = _passwordCtrl.text.trim();
    
    setState(() { _isLoading = true; _error = null; });
    
    if (user.isEmpty && pass.isEmpty) {
      // Guest mode
      user = "Guest_${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}";
      pass = "1234";
      await AuthService.register(user, pass, user, '$user@casino.com');
    } else if (user.isNotEmpty && pass.isEmpty) {
      setState(() { _isLoading = false; _error = "Password required."; });
      return;
    } else if (user.isEmpty && pass.isNotEmpty) {
      setState(() { _isLoading = false; _error = "Username required."; });
      return;
    }
    
    // Try to login
    bool success = await AuthService.login(user, pass);
    
    if (!mounted) return;
    if (success) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainLayout()));
    } else {
      setState(() { _isLoading = false; _error = "Credenciales incorrectas. Verifica tu identidad."; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Darkest background
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Text(
                  "GRAND STAKES",
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: AppColors.primary,
                    letterSpacing: 2.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "THE HIGH-ROLLER'S PRIVATE ATELIER",
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 4.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    "Welcome to Grand Stakes Simulator. This is a risk-free environment. Play anonymously as a guest or create an identity to track your performance over time.",
                    style: TextStyle(color: AppColors.primary, fontSize: 12, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 48),

                // Main Card
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ]
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "Welcome",
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(_error!, style: const TextStyle(color: AppColors.secondary), textAlign: TextAlign.center),
                        ),

                      // Identity Field
                      Text("PLAYER CREDENTIALS", style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: TextField(
                          controller: _usernameCtrl,
                          style: const TextStyle(color: AppColors.onSurface),
                          decoration: InputDecoration(
                            hintText: "Enter identity (leave blank for Guest)",
                            hintStyle: TextStyle(color: AppColors.onSurfaceVariant.withValues(alpha: 0.5)),
                            prefixIcon: const Icon(Icons.person_outline, color: AppColors.onSurfaceVariant, size: 20),
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: TextField(
                          controller: _passwordCtrl,
                          obscureText: true,
                          style: const TextStyle(color: AppColors.onSurface),
                          decoration: InputDecoration(
                            hintText: "Password",
                            hintStyle: TextStyle(color: AppColors.onSurfaceVariant.withValues(alpha: 0.5)),
                            prefixIcon: const Icon(Icons.lock_outline, color: AppColors.onSurfaceVariant, size: 20),
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Login Button
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _loginAsGuest,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                          ),
                          child: _isLoading 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                            : Text(
                                "ENTER THE ATELIER",
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
                          },
                          child: Text("NO IDENTITY YET? CREATE ONE", style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12, letterSpacing: 1.5, decoration: TextDecoration.underline)),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 48),
                
                // Footer Links
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildFooterLink("PRIVACY\nPOLICY"),
                    _buildFooterLink("HOUSE\nRULES"),
                    _buildFooterLink("RESPONSIBLE\nGAMING"),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooterLink(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(color: AppColors.onSurfaceVariant.withValues(alpha: 0.5), fontSize: 10, letterSpacing: 1.5),
    );
  }
}
