import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smartvote/services/api_service.dart';
import '../constants/AppConstants.dart';


class OtpService {

  static Future<OtpResult> verifyOtp(String email1, String otp) async {
    try {
      final response = await http
          .post(
        Uri.parse('${ApiConstants.baseUrl}/auth/verifyOtp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'voterEmail': email1, 'otpCode': otp}),
      )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return OtpResult.success();
      }

      // Try to parse the error message from the response body
      final body = _parseBody(response.body);
      final message = body['message'] as String? ??
          body['error'] as String? ??
          'Verification failed. Please try again.';

      return OtpResult.failure(message);
    } catch (_) {
      return OtpResult.failure('Network error. Please check your connection.');
    }
  }

  /// Resend an OTP to the given email.
  static Future<OtpResult> resendOtp(String email) async {
    try {
      final response = await http
          .post(
        Uri.parse('${ApiConstants.baseUrl}/auth/resendOtp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return OtpResult.success();
      }

      final body = _parseBody(response.body);
      final message = body['message'] as String? ?? 'Failed to resend OTP.';
      return OtpResult.failure(message);
    } catch (_) {
      return OtpResult.failure('Network error. Please check your connection.');
    }
  }

  static Map<String, dynamic> _parseBody(String raw) {
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }
}

class OtpResult {
  final bool success;
  final String? errorMessage;

  OtpResult._({required this.success, this.errorMessage});

  factory OtpResult.success() => OtpResult._(success: true);
  factory OtpResult.failure(String message) =>
      OtpResult._(success: false, errorMessage: message);
}