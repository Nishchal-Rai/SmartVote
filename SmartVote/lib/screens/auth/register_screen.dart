import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartvote/screens/auth/otp_screen.dart';
import 'package:smartvote/widgets/auth/auth_button.dart';
import 'package:smartvote/widgets/auth/auth_text_field.dart';
import '../../providers/auth_provider.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    auth.clearError();

    // Store the real email BEFORE the async call
    final realEmail = _emailController.text.trim();
    final email = await auth.register(
      _nameController.text.trim(),
      realEmail,
      _passwordController.text,
    );

    if (!mounted) return;

    if (email != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpScreen(email: realEmail),
        ),
      );
    } else if (auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error!),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }



  // Future<void> _handleRegister() async {
  //   if (!_formKey.currentState!.validate()) return;
  //   final auth = context.read<AuthProvider>();
  //   auth.clearError();
  //   final success = await auth.register(
  //     _nameController.text.trim(),
  //     _emailController.text.trim(),
  //     _passwordController.text,
  //   );
  //   if (success && mounted) {
  //     Navigator.pushReplacementNamed(context, '/home');
  //   } else if (mounted && auth.error != null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(auth.error!),
  //         backgroundColor: const Color(0xFFEF4444),
  //       ),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Color(0xFF1A1A2E),
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Create account 🚀',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Fill in the details below to get started',
                      style:
                          TextStyle(fontSize: 15, color: Color(0xFF6B7280)),
                    ),
                    const SizedBox(height: 32),
                    AuthTextField(
                      label: 'Full name',
                      controller: _nameController,
                      prefixIcon: Icons.person_outline_rounded,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      label: 'Email address',
                      controller: _emailController,
                      prefixIcon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Email is required';
                        if (!v.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      label: 'Password',
                      controller: _passwordController,
                      prefixIcon: Icons.key_rounded,
                      obscure: true,
                      validator: (v) {
                        if (v == null || v.isEmpty)
                          return 'Password is required';
                        if (v.length < 6) return 'Minimum 6 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      label: 'Confirm password',
                      controller: _confirmController,
                      prefixIcon: Icons.lock_outline_rounded,
                      obscure: true,
                      validator: (v) {
                        if (v != _passwordController.text)
                          return 'Passwords do not match';
                        return null;
                      },
                    ),
                    const SizedBox(height: 28),
                    AuthButton(
                      label: 'Create Account',
                      isLoading: isLoading,
                      onPressed: _handleRegister,
                    ),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account? ',
                          style: TextStyle(
                              color: Color(0xFF6B7280), fontSize: 14),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Text(
                            'Sign in',
                            style: TextStyle(
                              color: Color(0xFF3D35C8),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
