import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_dashboard.dart';

/// 🔵 ADMIN BLUE GRADIENT
const LinearGradient kAdminBlueGradient = LinearGradient(
  colors: [
    Color(0xFF0D47A1),
    Color(0xFF1565C0),
    Color(0xFF42A5F5),
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen>
    with SingleTickerProviderStateMixin {
  final adminIdCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  bool loading = false;

  late AnimationController _shakeController;
  late Animation<double> _shake;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _shake = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10, end: 0), weight: 1),
    ]).animate(_shakeController);
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    _shakeController.forward(from: 0);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> loginAdmin() async {
    if (adminIdCtrl.text.isEmpty ||
        emailCtrl.text.isEmpty ||
        passCtrl.text.isEmpty) {
      _showError('Please fill all admin credentials');
      return;
    }

    setState(() => loading = true);

    try {
      final cred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
      );

      final uid = cred.user!.uid;

      final adminDoc = await FirebaseFirestore.instance
          .collection('admins')
          .doc(adminIdCtrl.text.trim())
          .get();

      if (!adminDoc.exists) {
        await FirebaseAuth.instance.signOut();
        throw 'Invalid Admin ID';
      }

      final data = adminDoc.data()!;
      if (data['uid'] != uid ||
          data['email'] != emailCtrl.text.trim()) {
        await FirebaseAuth.instance.signOut();
        throw 'Admin credentials do not match';
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminDashboard()),
      );
    } catch (e) {
      _showError(
        e.toString().contains('password')
            ? 'Wrong password'
            : e.toString(),
      );
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      body: Stack(
        children: [
          /// 🔵 CURVED HEADER (SAME STYLE AS YOUR LOGIN)
          ClipPath(
            clipper: CurvedHeaderClipper(),
            child: Container(
              height: 300,
              decoration: const BoxDecoration(gradient: kAdminBlueGradient),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                children: [
                  const SizedBox(height: 50),

                  /// TITLE
                  const Text(
                    'Admin',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Secure Access',
                    style: TextStyle(
                      fontSize: 26,
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// LOGIN CARD
                  AnimatedBuilder(
                    animation: _shake,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(_shake.value, 0),
                        child: child,
                      );
                    },
                    child: Container(
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
                           Padding(
                             padding: const EdgeInsets.all(8.0),
                             child: Text("Login as Admin", style : TextStyle(fontSize: 16, fontWeight: FontWeight.w600) ),
                           ),
SizedBox(
  height: 12,
),
                          _field(
                            controller: adminIdCtrl,
                            label: 'Admin ID',
                            icon: Icons.badge,
                          ),
                          const SizedBox(height: 14),
                          _field(
                            controller: emailCtrl,
                            label: 'Admin Email',
                            icon: Icons.email,
                          ),
                          const SizedBox(height: 14),
                          _field(
                            controller: passCtrl,
                            label: 'Password',
                            icon: Icons.lock,
                            obscure: true,
                          ),
                          const SizedBox(height: 26),

                          OutlinedButton.icon(
                            onPressed: loading ? null : loginAdmin,
                            icon: const Icon(Icons.admin_panel_settings),
                            label: loading
                                ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                                : const Text('Login as Admin'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 54),
                              side: BorderSide(color: Colors.blue.shade600, width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              foregroundColor: Colors.blue.shade700,
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

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

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

/// 🎯 SAME CURVED HEADER CLIPPER AS LOGIN
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
