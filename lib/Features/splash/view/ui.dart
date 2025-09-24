import 'package:flutter/material.dart';
import '../../../Settings/utils/p_colors.dart';
import '../../../Settings/utils/p_pages.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkLogin();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PColors.darkGray,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Main Icon with slide animation
                    SlideTransition(
                      position: _slideAnimation,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: PColors.red,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: PColors.red.withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.receipt_long_rounded,
                          size: 60,
                          color: PColors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // App Title
                    SlideTransition(
                      position: _slideAnimation,
                      child: Text(
                        'Bill Vault',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: PColors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Subtitle
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        'Manage Your Warranties',
                        style: TextStyle(
                          fontSize: 16,
                          color: PColors.lightGray,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Loading indicator
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            PColors.red,
                          ),
                          backgroundColor: PColors.mediumGray.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void checkLogin() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        PPages.wrapperPageUi,
        (route) => false,
      );
    });
  }
}
