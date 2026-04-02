import 'dart:async';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '/main_shell.dart';


class PhoneAuthScreen extends StatefulWidget {
  final bool isSignup;
  const PhoneAuthScreen({super.key, required this.isSignup});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen>
    with SingleTickerProviderStateMixin {
  final phoneController = TextEditingController();
  final List<TextEditingController> otpControllers =
  List.generate(6, (_) => TextEditingController());

  String? verificationId;
  bool otpSent = false;
  bool isLoading = false;

  int resendSeconds = 30;
  Timer? resendTimer;

  String? errorText;

  late AnimationController shakeController;
  late Animation<double> shakeAnimation;

  // ---------------- INIT ----------------
  @override
  void initState() {
    super.initState();

    shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10, end: -10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10, end: 0), weight: 1),
    ]).animate(shakeController);
  }

  @override
  void dispose() {
    resendTimer?.cancel();
    shakeController.dispose();
    super.dispose();
  }

  // ---------------- TIMER ----------------
  void startResendTimer() {
    resendSeconds = 30;
    resendTimer?.cancel();
    resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendSeconds == 0) {
        timer.cancel();
      } else {
        setState(() => resendSeconds--);
      }
    });
  }

  // ---------------- CLEAR OTP ----------------
  void clearOtpBoxes() {
    for (final c in otpControllers) {
      c.clear();
    }
  }

  // ---------------- SEND / RESEND OTP ----------------
  Future<void> sendOtp() async {
    if (phoneController.text.trim().length != 10) {
      setState(() => errorText = 'Please enter a valid 10-digit mobile number');
      return;
    }

    setState(() {
      isLoading = true;
      errorText = null;
    });

    try {
      verificationId =
      await AuthService.sendOTP('+91${phoneController.text}');
      otpSent = true;
      clearOtpBoxes();
      startResendTimer();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP sent successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      setState(() => errorText = 'Failed to send OTP. Try again.');
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ---------------- VERIFY OTP ----------------
  Future<void> verifyOtp() async {
    final otp = otpControllers.map((e) => e.text).join();

    if (otp.length != 6) {
      setState(() => errorText = 'Please enter the complete 6-digit OTP');
      shakeController.forward(from: 0);
      return;
    }

    setState(() {
      isLoading = true;
      errorText = null;
    });

    try {
      if (widget.isSignup) {
        await AuthService.signupWithPhone(
          verificationId!,
          otp,
          '+91${phoneController.text}',
        );
      } else {
        await AuthService.loginWithPhone(
          verificationId!,
          otp,
        );
      }

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
            (route) => false,
      );
    } catch (_) {
      setState(() => errorText = 'Invalid OTP. Please try again.');
      shakeController.forward(from: 0);
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ---------------- OTP BOX ----------------
  Widget otpBox(int index) {
    return SizedBox(
      width: 44,
      height: 54,
      child: TextField(
        controller: otpControllers[index],
        maxLength: 1,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        autofillHints: const [AutofillHints.oneTimeCode],
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
            const BorderSide(color: Color(0xFF2E7D32), width: 2),
          ),
        ),
        onChanged: (v) {
          if (v.isNotEmpty && index < 5) {
            FocusScope.of(context).nextFocus();
          }
          if (v.isEmpty && index > 0) {
            FocusScope.of(context).previousFocus();
          }
        },
      ),
    );
  }

  // ---------------- GRADIENT BUTTON ----------------
  Widget gradientButton({
    required String text,
    required VoidCallback onTap,
    required bool loading,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(32),
      child: Ink(
        height: 52,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1B5E20),
              Color(0xFF2E7D32),
              Color(0xFF66BB6A),
            ],
          ),
          borderRadius: BorderRadius.all(Radius.circular(32)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(32),
          onTap: loading ? null : onTap,
          child: Center(
            child: loading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      body: Stack(
        children: [
          ClipPath(
            clipper: CurvedHeaderClipper(),
            child: Container(
              height: 280,
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
                  const SizedBox(height: 50),
                  const Text(
                    'Verify Phone',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Enter the OTP sent to your number',
                    style: TextStyle(color: Colors.white70),
                  ),

                  const SizedBox(height: 50),

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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!otpSent)
                          TextField(
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            onChanged: (_) {
                              if (errorText != null) {
                                setState(() => errorText = null);
                              }
                            },
                            decoration: InputDecoration(
                              counterText: '',
                              prefixText: '+91 ',
                              labelText: 'Mobile Number',
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),

                        if (errorText != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            errorText!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],

                        if (!otpSent) const SizedBox(height: 16),

                        if (!otpSent)
                          gradientButton(
                            text: 'Send OTP',
                            loading: isLoading,
                            onTap: sendOtp,
                          ),

                        if (otpSent) ...[
                          const SizedBox(height: 20),
                          const Text(
                            'Enter OTP',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 14),

                          AnimatedBuilder(
                            animation: shakeAnimation,
                            builder: (_, child) => Transform.translate(
                              offset: Offset(shakeAnimation.value, 0),
                              child: child,
                            ),
                            child: FittedBox(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  6,
                                      (i) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6),
                                    child: otpBox(i),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          if (errorText != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              errorText!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],

                          const SizedBox(height: 20),

                          gradientButton(
                            text: 'Verify & Continue',
                            loading: isLoading,
                            onTap: verifyOtp,
                          ),

                          const SizedBox(height: 12),

                          resendSeconds > 0
                              ? Text(
                            'Resend SMS in 0:$resendSeconds',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey),
                          )
                              : TextButton(
                            onPressed: sendOtp,
                            child: const Text(
                              'Resend SMS >',
                              style: TextStyle(
                                color: Color(0xFF2E7D32),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
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

class CurvedHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 90);
    path.quadraticBezierTo(
        size.width * 0.25, size.height, size.width * 0.6, size.height - 60);
    path.quadraticBezierTo(
        size.width * 0.9, size.height - 120, size.width, size.height - 100);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
