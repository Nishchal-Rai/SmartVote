package com.smartvote.controller;

import com.smartvote.dto.ApiResponse;
import com.smartvote.dto.AuthRequest;
import com.smartvote.dto.AuthResponse;
import com.smartvote.dto.LoginResponse;
import com.smartvote.dto.RegisterRequest;
import com.smartvote.dto.ResendOtpDto;
import com.smartvote.dto.VerifyOTPRequest;
import com.smartvote.entity.OTP;
import com.smartvote.service.AuthService;
import com.smartvote.service.EmailService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;
      private final EmailService emailService;

    @PostMapping("/register")
    public ResponseEntity<ApiResponse<LoginResponse>> register(
            @Valid @RequestBody RegisterRequest req) {
        return ResponseEntity.ok(ApiResponse.ok("Registration successful", authService.register(req)));
    }

    @PostMapping("/login")
    public ResponseEntity<ApiResponse<AuthResponse>> login(
            @Valid @RequestBody AuthRequest req) {
        return ResponseEntity.ok(ApiResponse.ok("Login successful", authService.login(req)));
    }

     @PostMapping("/resendOtp")
    public ResponseEntity<ApiResponse<Map<String, Object>>> sendOTP(@RequestBody ResendOtpDto req) {
        return ResponseEntity.ok(ApiResponse.ok("OTP sent successfully", emailService.resendOTP(req.getEmail())));
    }

    @PostMapping("/verifyOtp")
    public ResponseEntity<ApiResponse<AuthResponse>> verifyOTP(
            @Valid @RequestBody VerifyOTPRequest  req) {
        return ResponseEntity.ok(ApiResponse.ok("Account verified successfully", authService.verifyOTP(req)));
    }
}
