import 'package:flutter/material.dart';
import '../theme.dart';
import '../db/auth_service.dart';

class VipScreen extends StatefulWidget {
  const VipScreen({Key? key}) : super(key: key);

  @override
  State<VipScreen> createState() => _VipScreenState();
}

class _VipScreenState extends State<VipScreen> {
  bool _isVip = false;

  @override
  void initState() {
    super.initState();
    _isVip = AuthService.isVip();
  }

  void _requestAccess() async {
    await AuthService.upgradeToVip();
    setState(() {
      _isVip = true;
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Welcome to the inner circle."),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.diamond, color: AppColors.primary, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    "High Rollers",
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isVip ? "Private Access Granted" : "Private Access Only",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: _isVip ? AppColors.primary : AppColors.secondaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(24)),
                ),
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!_isVip) ...[
                      Text(
                        "To join the private tables, contact your dedicated host or request access.",
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),
                      InkWell(
                        onTap: _requestAccess,
                        borderRadius: BorderRadius.circular(2),
                        child: Ink(
                          decoration: BoxDecoration(
                            color: AppColors.secondaryContainer,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            child: Text(
                              "REQUEST ACCESS",
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      const Icon(Icons.check_circle_outline, color: AppColors.primary, size: 64),
                      const SizedBox(height: 24),
                      Text(
                        "Welcome back, ${AuthService.currentUser}.",
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Your exclusive tables are being prepared.",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
