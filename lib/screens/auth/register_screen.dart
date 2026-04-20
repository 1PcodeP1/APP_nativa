import 'package:flutter/material.dart';
import '../../db/auth_service.dart';
import '../../theme.dart';
import '../main_layout.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  bool _isLoading = false;
  String? _error;

  void _register() async {
    if (_emailCtrl.text.isEmpty || _passwordCtrl.text.isEmpty || _nameCtrl.text.isEmpty || _dobCtrl.text.isEmpty) {
      setState(() { _error = "Please complete all fields to proceed."; });
      return;
    }
    setState(() { _isLoading = true; _error = null; });
    // We use the email as the username for backend registration
    final success = await AuthService.register(_emailCtrl.text.trim(), _passwordCtrl.text, _nameCtrl.text.trim(), _emailCtrl.text.trim());
    if (!mounted) return;
    if (success) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainLayout()),
        (route) => false,
      );
    } else {
      setState(() { _isLoading = false; _error = "Registration failed. Email might already be in use."; });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)), // default to 18 years ago
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.black,
              surface: AppColors.surfaceContainerHigh,
              onSurface: AppColors.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobCtrl.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  bool _certifyAge = false;
  bool _agreeTerms = false;
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Darkest background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Back Button
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                ),
              ),
              const SizedBox(height: 16),

              Text(
                "EXCLUSIVITY AWAITS",
                style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2.0),
              ),
              const SizedBox(height: 16),
              Text(
                "Enter the",
                style: Theme.of(context).textTheme.displayLarge?.copyWith(color: Colors.white, height: 1.1),
              ),
              Text(
                "Private Atelier",
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: AppColors.primary,
                  fontStyle: FontStyle.italic,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Join an elite circle of high-stakes enthusiasts. Our private tables offer unparalleled limits and a bespoke gaming experience tailored for the discerning player.",
                style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 32),

              // Info Cards
              _buildInfoCard(Icons.diamond_outlined, "VIP Concierge", "24/7 personalized support for members."),
              const SizedBox(height: 8),
              _buildInfoCard(Icons.security_outlined, "Vaulted Security", "State-of-the-art encryption for your peace of mind."),
              const SizedBox(height: 48),

              // Main Form Container
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Stepper Visual
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStepIndicator(1, "PROFILE", true),
                        Expanded(child: Divider(color: AppColors.surfaceVariant)),
                        _buildStepIndicator(2, "SECURITY", false),
                        Expanded(child: Divider(color: AppColors.surfaceVariant)),
                        _buildStepIndicator(3, "VERIFICATION", false),
                      ],
                    ),
                    const SizedBox(height: 48),

                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(_error!, style: const TextStyle(color: AppColors.secondary), textAlign: TextAlign.center),
                      ),

                    // Fields
                    _buildFieldLabel("FULL LEGAL NAME"),
                    _buildInputField(controller: _nameCtrl, hint: "E.g. James Vane", icon: Icons.person_outline, isPassword: false),
                    const SizedBox(height: 24),

                    _buildFieldLabel("DATE OF BIRTH"),
                    _buildInputField(
                      controller: _dobCtrl, 
                      hint: "DD/MM/YYYY", 
                      icon: Icons.calendar_today_outlined, 
                      isPassword: false,
                      readOnly: true,
                      onTap: () => _selectDate(context),
                    ),
                    const SizedBox(height: 24),

                    _buildFieldLabel("EMAIL ADDRESS"),
                    _buildInputField(controller: _emailCtrl, hint: "james@vane.com", icon: Icons.email_outlined, isPassword: false),
                    const SizedBox(height: 24),

                    _buildFieldLabel("SECURITY PASSWORD"),
                    _buildInputField(controller: _passwordCtrl, hint: "••••••••", icon: Icons.lock_outline, isPassword: true),
                    const SizedBox(height: 32),

                    // Checkboxes
                    _buildCheckbox(
                      _certifyAge, 
                      "I certify that I am at least 18 years of age and legally allowed to participate in high-stakes gaming in my jurisdiction.", 
                      (val) => setState(() => _certifyAge = val ?? false)
                    ),
                    const SizedBox(height: 16),
                    _buildCheckbox(
                      _agreeTerms, 
                      "I agree to the Terms of Service and Privacy Charter of Grand Stakes.", 
                      (val) => setState(() => _agreeTerms = val ?? false),
                      hasLinks: true,
                    ),
                    const SizedBox(height: 48),

                    // Button
                    InkWell(
                      onTap: (_isLoading || !_certifyAge || !_agreeTerms) ? null : _register,
                      borderRadius: BorderRadius.circular(2),
                      child: Ink(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: (_certifyAge && _agreeTerms) ? AppColors.primary : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Center(
                          child: _isLoading 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "JOIN THE ELITE",
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward, color: Colors.black, size: 16),
                                ],
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Text("ESTABLISHED 2023 • CONFIDENTIAL & SECURE", style: TextStyle(color: AppColors.onSurfaceVariant.withValues(alpha: 0.5), fontSize: 8, letterSpacing: 1.5)),
                    )
                  ],
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(color: AppColors.surfaceContainerLowest, shape: BoxShape.circle),
                    child: Center(child: Text("18+", style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 10, fontWeight: FontWeight.bold))),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(color: AppColors.surfaceContainerLowest, shape: BoxShape.circle),
                    child: Icon(Icons.security, color: AppColors.onSurfaceVariant, size: 16),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text("© GRAND STAKES. ALL HIGH-ROLLER RIGHTS RESERVED.", textAlign: TextAlign.center, style: TextStyle(color: AppColors.onSurfaceVariant.withValues(alpha: 0.5), fontSize: 8, letterSpacing: 1.5)),
              const SizedBox(height: 4),
              Text("PLEASE PLAY RESPONSIBLY.", textAlign: TextAlign.center, style: TextStyle(color: AppColors.onSurfaceVariant.withValues(alpha: 0.5), fontSize: 8, letterSpacing: 1.5)),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: isActive ? AppColors.primary : AppColors.surfaceVariant, width: 1),
          ),
          child: Center(
            child: Text(
              step.toString(),
              style: TextStyle(
                color: isActive ? Colors.black : AppColors.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
            fontSize: 8,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller, 
    required String hint, 
    required IconData icon, 
    required bool isPassword,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(2),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && _obscureText,
        readOnly: readOnly,
        onTap: onTap,
        style: const TextStyle(color: AppColors.onSurface),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.onSurfaceVariant.withValues(alpha: 0.5)),
          suffixIcon: isPassword 
            ? IconButton(
                icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: AppColors.onSurfaceVariant, size: 20),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              ) 
            : Icon(icon, color: AppColors.onSurfaceVariant, size: 20),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildCheckbox(bool value, String text, ValueChanged<bool?> onChanged, {bool hasLinks = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24, height: 24,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            checkColor: Colors.black,
            side: BorderSide(color: AppColors.surfaceVariant),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: hasLinks 
            ? RichText(
                text: TextSpan(
                  style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12, height: 1.5),
                  children: [
                    const TextSpan(text: "I agree to the "),
                    TextSpan(text: "Terms of Service", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    const TextSpan(text: " and "),
                    TextSpan(text: "Privacy Charter", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    const TextSpan(text: " of Grand Stakes."),
                  ],
                ),
              )
            : Text(
                text,
                style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12, height: 1.5),
              ),
        ),
      ],
    );
  }
}
