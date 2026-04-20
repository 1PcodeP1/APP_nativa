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

  void _login() async {
    if (_usernameCtrl.text.isEmpty || _passwordCtrl.text.isEmpty) {
      setState(() { _error = "Please enter your credentials to continue."; });
      return;
    }
    setState(() { _isLoading = true; _error = null; });
    final success = await AuthService.login(_usernameCtrl.text.trim(), _passwordCtrl.text);
    if (!mounted) return;
    if (success) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainLayout()));
    } else {
      setState(() { _isLoading = false; _error = "Invalid credentials. Please try again."; });
    }
  }

  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Darkest background
      body: SafeArea(
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
                      "Welcome Back",
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
                    Text("IDENTITY", style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    const SizedBox(height: 8),
                    _buildInputField(
                      controller: _usernameCtrl,
                      hint: "Username or Email",
                      icon: Icons.alternate_email,
                      isPassword: false,
                    ),
                    const SizedBox(height: 24),

                    // Credential Field
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("CREDENTIAL", style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                        Text("FORGOT?", style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.onSurfaceVariant, letterSpacing: 1.5)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildInputField(
                      controller: _passwordCtrl,
                      hint: "••••••••",
                      icon: Icons.lock_outline,
                      isPassword: true,
                    ),
                    const SizedBox(height: 32),

                    // Login Button
                    InkWell(
                      onTap: _isLoading ? null : _login,
                      borderRadius: BorderRadius.circular(2),
                      child: Ink(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Center(
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
                    ),
                    const SizedBox(height: 32),

                    // Or Continue Via
                    Row(
                      children: [
                        Expanded(child: Divider(color: AppColors.surfaceVariant)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text("OR CONTINUE VIA", style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.onSurfaceVariant, letterSpacing: 1.5)),
                        ),
                        Expanded(child: Divider(color: AppColors.surfaceVariant)),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Social Buttons
                    Row(
                      children: [
                        Expanded(
                          child: _buildSocialBtn("GOOGLE", Icons.g_mobiledata),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildSocialBtn("APPLE", Icons.apple),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 48),

              // Footer Request Invitation
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Not a member of the circle? ", style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                  InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
                    },
                    child: Text("Request Invitation", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
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
    );
  }

  Widget _buildInputField({required TextEditingController controller, required String hint, required IconData icon, required bool isPassword}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(2),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && _obscureText,
        style: const TextStyle(color: AppColors.onSurface),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.onSurfaceVariant.withValues(alpha: 0.5)),
          prefixIcon: Icon(icon, color: AppColors.onSurfaceVariant, size: 20),
          suffixIcon: isPassword 
            ? IconButton(
                icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: AppColors.onSurfaceVariant, size: 20),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              ) 
            : null,
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildSocialBtn(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.onSurfaceVariant, size: 20),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: AppColors.onSurface, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        ],
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
