import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:smartvote/screens/elections/home_screen.dart';

import '../../services/otp_service.dart';
import '../../widgets/auth/auth_button.dart';

class OtpScreen extends StatefulWidget {
  final String email;

  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen>
    with SingleTickerProviderStateMixin {
  final _otpController = TextEditingController();

  // Mirrors RegisterScreen animation pattern exactly
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  bool _loading = false;
  bool _resending = false;

  // Tracks remaining attempts parsed from backend error messages
  int? _remainingAttempts;

  // ── Design tokens — identical to RegisterScreen ────────────────────────
  static const Color _bg = Color(0xFFF5F5F5);
  static const Color _dark = Color(0xFF1A1A2E);
  static const Color _muted = Color(0xFF6B7280);
  static const Color _primary = Color(0xFF3D35C8);
  static const Color _error = Color(0xFFEF4444);
  static const Color _border = Color(0xFFE5E7EB);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  // ── Mask email for display  e.g.  j***@gmail.com ─────────────────────
  String get _maskedEmail {
    final parts = widget.email.split('@');
    if (parts.length != 2 || parts[0].isEmpty) return widget.email;
    final name = parts[0];
    final masked = name.length <= 2
        ? '${name[0]}***'
        : '${name[0]}${'*' * (name.length - 1)}';
    return '$masked@${parts[1]}';
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.length != 6) return;
    setState(() {
      _loading = true;
      _remainingAttempts = null;
    });

    final result = await OtpService.verifyOtp(widget.email, _otpController.text);

    if (!mounted) return;
    setState(() => _loading = false);

    if (result.success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(),
        ),
      );
    } else {
      // Parse "X attempt(s) remaining" from the backend message
      final msg = result.errorMessage ?? 'Verification failed.';
      final match = RegExp(r'(\d+) attempt').firstMatch(msg);
      if (match != null) {
        setState(() => _remainingAttempts = int.tryParse(match.group(1)!));
      }

      _otpController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: _error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _resendOtp() async {
    setState(() {
      _resending = true;
      _remainingAttempts = null;
    });
    _otpController.clear();

    final result = await OtpService.resendOtp(widget.email);

    if (!mounted) return;
    setState(() => _resending = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.success
              ? 'A new code was sent to $_maskedEmail'
              : result.errorMessage ?? 'Failed to resend.',
        ),
        backgroundColor: result.success ? _primary : _error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ── Pinput themes — follow the same border/radius as AuthTextField ────
    final basePinTheme = PinTheme(
      width: 52,
      height: 58,
      textStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: _dark,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _border),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
    );

    final focusedPinTheme = basePinTheme.copyWith(
      decoration: basePinTheme.decoration!.copyWith(
        border: Border.all(color: _primary, width: 2),
      ),
    );

    final errorPinTheme = basePinTheme.copyWith(
      decoration: basePinTheme.decoration!.copyWith(
        border: Border.all(color: _error, width: 2),
      ),
    );

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Back button — exact copy from RegisterScreen ──────
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _border),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: _dark,
                        size: 16,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Shield icon in a pill ─────────────────────────────
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEEDFB),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      color: _primary,
                      size: 28,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Headline ──────────────────────────────────────────
                  const Text(
                    'Verify your email ✉️',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: _dark,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                          fontSize: 15, color: _muted, height: 1.5),
                      children: [
                        const TextSpan(text: 'We sent a 6-digit code to\n'),
                        TextSpan(
                          text: _maskedEmail,
                          style: const TextStyle(
                            color: _dark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 36),

                  // ── PIN input ─────────────────────────────────────────
                  Center(
                    child: Pinput(
                      controller: _otpController,
                      length: 6,
                      defaultPinTheme: basePinTheme,
                      focusedPinTheme: focusedPinTheme,
                      errorPinTheme: errorPinTheme,
                      keyboardType: TextInputType.number,
                      onCompleted: (_) => _verifyOtp(),
                    ),
                  ),

                  // ── Remaining attempts hint ───────────────────────────
                  if (_remainingAttempts != null) ...[
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        '$_remainingAttempts attempt${_remainingAttempts == 1 ? '' : 's'} remaining',
                        style: const TextStyle(
                          color: _error,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 28),

                  // ── Verify button — reuses AuthButton ─────────────────
                  AuthButton(
                    label: 'Verify Code',
                    isLoading: _loading,
                    onPressed: _verifyOtp,
                  ),

                  const SizedBox(height: 28),

                  // ── Resend row ────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Didn't receive the code? ",
                        style: TextStyle(color: _muted, fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: _resending ? null : _resendOtp,
                        child: _resending
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: _primary,
                                ),
                              )
                            : const Text(
                                'Resend',
                                style: TextStyle(
                                  color: _primary,
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
    );
  }
}
