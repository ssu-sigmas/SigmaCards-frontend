import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';
import 'login_screen.dart';
import 'registration_screen.dart';

class AuthScreen extends StatefulWidget {
  final Function(String email, String password) onLogin;
  final Function(String email, String password) onRegister;
  final VoidCallback? onBack;
  final bool initialIsLogin; // true для логина, false для регистрации

  const AuthScreen({
    super.key,
    required this.onLogin,
    required this.onRegister,
    this.onBack,
    this.initialIsLogin = true,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late bool _isLogin;

  @override
  void initState() {
    super.initState();
    _isLogin = widget.initialIsLogin;
  }

  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Back button
            if (widget.onBack != null)
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    onPressed: widget.onBack,
                    icon: Icon(
                      Icons.arrow_back,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ),
              ),

            // Toggle tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(AppStyles.borderRadius),
                  border: Border.all(
                    color: isDark ? Colors.white24 : Colors.black12,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTabButton(
                        context: context,
                        label: 'Вход',
                        isSelected: _isLogin,
                        onTap: () {
                          if (!_isLogin) {
                            setState(() {
                              _isLogin = true;
                            });
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: _buildTabButton(
                        context: context,
                        label: 'Регистрация',
                        isSelected: !_isLogin,
                        onTap: () {
                          if (_isLogin) {
                            setState(() {
                              _isLogin = false;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Auth form
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset(_isLogin ? -1.0 : 1.0, 0.0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeInOut,
                    )),
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                child: _isLogin
                    ? LoginScreen(
                        key: const ValueKey('login'),
                        onLogin: widget.onLogin,
                        onRegister: _toggleAuthMode,
                        // Не передаем onBack, так как кнопка уже есть в AuthScreen
                      )
                    : RegistrationScreen(
                        key: const ValueKey('register'),
                        onRegister: widget.onRegister,
                        onLogin: _toggleAuthMode,
                        // Не передаем onBack, так как кнопка уже есть в AuthScreen
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    Colors.purple.shade600,
                    Colors.blue.shade600,
                  ],
                )
              : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(AppStyles.borderRadius),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white70 : Colors.black54),
          ),
        ),
      ),
    );
  }
}

