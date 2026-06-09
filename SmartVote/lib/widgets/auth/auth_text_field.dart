import 'package:flutter/material.dart';


class AuthTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final bool obscure;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final IconData prefixIcon;

  const AuthTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.prefixIcon,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.obscure ? _obscured : false,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      style: const TextStyle(
        color: Color(0xFF1A1A2E),
        fontSize: 15,
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: const TextStyle(color: Color(0xFF6B7280)),
        prefixIcon: Icon(widget.prefixIcon, color: Color(0xFF3D35C8), size: 20),
        suffixIcon: widget.obscure
            ? IconButton(
          icon: Icon(
            _obscured ? Icons.visibility_off : Icons.visibility,
            color: const Color(0xFF6B7280),
            size: 20,
          ),
          onPressed: () => setState(() => _obscured = !_obscured),
        )
            : null,
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF3D35C8), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        ),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      ),
    );
  }
}