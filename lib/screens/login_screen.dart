import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'signup_screen.dart';
import 'phone_auth_screen.dart';
import 'forgot_password_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home.dart';
import 'admin_login_screen.dart';
import '../utils/app_strings.dart';
import '/main_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool obscure = true;

  Future<void> handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      await AuthService.loginWithEmail(
        emailController.text.trim(),
        passwordController.text,
      );

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
            (route) => false,
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text (AppStrings.text('invalid_login'))),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Widget gradientButton({
    required String text,
    required VoidCallback onTap,
    Widget? icon,
    bool loading = false,
  }) {
    return InkWell(
      onTap: loading ? null : onTap,
      borderRadius: BorderRadius.circular(32),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF1B5E20),
              Color(0xFF2E7D32),
              Color(0xFF66BB6A),
            ],
          ),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Center(
          child: loading
              ? const SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                icon,
                const SizedBox(width: 2),
              ],
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          /// 🌿 CURVED HEADER
          ClipPath(
            clipper: CurvedHeaderClipper(),
            child: Container(
              height: 300,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF1B5E20),
                    Color(0xFF2E7D32),
                    Color(0xFF81C784),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                children: [
                  const SizedBox(height: 45),

                  /// TEXT
                  Text(
                    AppStrings.text('hello'),
                    style: GoogleFonts.poppins(
                      fontSize: 44,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppStrings.text('welcome_back'),
                    style: GoogleFonts.poppins(
                      fontSize: 30,
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// LOGIN CARD
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 18,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            AppStrings.text('login_account'),
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            AppStrings.text('login_subtitle'),
                            style: TextStyle(color: Colors.black54),
                          ),

                          const SizedBox(height: 15),

                          /// EMAIL
                          TextFormField(
                            controller: emailController,
                            decoration: InputDecoration(
                              labelText: AppStrings.text('email'),
                              labelStyle:
                              const TextStyle(color: Colors.black),
                              suffixIcon:
                              const Icon(Icons.person_outline),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return AppStrings.text('email_required');
                              }
                              if (!v.contains('@')) {
                                return AppStrings.text('email_invalid');
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 15),

                          /// PASSWORD
                          TextFormField(
                            controller: passwordController,
                            obscureText: obscure,
                            decoration: InputDecoration(
                              labelText: AppStrings.text('password'),
                              labelStyle:
                              const TextStyle(color: Colors.black),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  obscure
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() => obscure = !obscure);
                                },
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.length < 6) {
                                return AppStrings.text('password_min');
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 4),

                          /// FORGOT PASSWORD
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                    const ForgotPasswordScreen(),
                                  ),
                                );
                              },
                              child:  Text(
                                AppStrings.text('forgot_password'),
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          /// LOGIN (GRADIENT)
                          gradientButton(
                            text: AppStrings.text('login_account'),
                            loading: isLoading,
                            onTap: handleLogin,
                          ),

                          const SizedBox(height: 14),

                          /// OTP LOGIN
                          OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                  const PhoneAuthScreen(
                                      isSignup: false),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(32),
                              ),side: const BorderSide(
                              color: Colors.green, // border color
                              width: 2,)
                            ),
                            child:  Text(
                              AppStrings.text('login_with_otp'),
                              style: TextStyle(color: Colors.black),
                            ),
                          ),

                          const SizedBox(height: 14),

                          /// GOOGLE LOGIN (ADDED)
                          gradientButton(
                            text: AppStrings.text('continue_google'),
                            icon: const Icon(
                              Icons.g_mobiledata,
                              color: Colors.white,
                            ),
                            onTap: () async {
                              setState(() => isLoading = true);
                              final result =
                              await AuthService.loginWithGoogle();
                              setState(() => isLoading = false);

                              if (result == null) return;
                              if (!mounted) return;

                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (_) => const MainShell()),
                                    (route) => false,
                              );
                            },
                          ),

                          const SizedBox(height: 8),

                          /// CREATE ACCOUNT
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SignupScreen(),
                                ),
                              );
                            },
                            child: Text(
                              AppStrings.text('create_account'),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          TextButton(
                          onPressed: () {
    Navigator.push(
    context,
    MaterialPageRoute(
    builder: (_) => const AdminLoginScreen(),
    ),
    );
    },
    style: TextButton.styleFrom(
    padding: const EdgeInsets.symmetric(
    horizontal: 6,
    vertical: 2,
    ),
    minimumSize: Size.zero, // removes default min size
    tapTargetSize: MaterialTapTargetSize.shrinkWrap, // reduces touch area
    ),
    child:  Text(
      AppStrings.text('login_admin'),
    style: TextStyle(
    fontSize: 14, // 👈 smaller text
    color: Color(0xFF1B5E20),
    fontWeight: FontWeight.w600,
    ),
    ),
    )
    ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 🎯 PERFECT CURVE CLIPPER
class CurvedHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 90);

    path.quadraticBezierTo(
      size.width * 0.25,
      size.height,
      size.width * 0.6,
      size.height - 60,
    );

    path.quadraticBezierTo(
      size.width * 0.9,
      size.height - 120,
      size.width,
      size.height - 100,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
