package com.smartvote.service;

import com.smartvote.dto.*;
import com.smartvote.entity.OTP;
import com.smartvote.entity.User;
import com.smartvote.repository.UserRepository;
import com.smartvote.security.JwtUtils;
import com.smartvote.security.UserPrincipal;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final AuthenticationManager authenticationManager;
    private final JwtUtils jwtUtils;
    private final OTPService otpService;
    private final EmailService emailService;

    public LoginResponse register(RegisterRequest req) {
        if (userRepository.existsByEmail(req.getEmail())) {
            throw new IllegalArgumentException("Email already in use");
        }
        User user = User.builder()
                .fullName(req.getFullName())
                .email(req.getEmail())
                .password(passwordEncoder.encode(req.getPassword()))
                .role(User.Role.USER)
                .isVerified(false)
                .build();
        user = userRepository.save(user);

        String plainOTP = otpService.generateAndStoreOTP(user, OTP.Purpose.LOGIN);
        emailService.sendOtpEmail(user.getEmail(), plainOTP);

        return LoginResponse.builder()
                .voterId(user.getId().toString())
                .email(emailService.maskEmail(user.getEmail()))
                .message("OTP sent to your email. Please verify to activate your account.")
                .build();
    }

    public AuthResponse login(AuthRequest req) {
        Authentication auth = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(req.getEmail(), req.getPassword()));
        User user = ((UserPrincipal) auth.getPrincipal()).getUser();

        if (!user.isVerified()) {
            throw new IllegalArgumentException("Account not verified. Please verify OTP first.");
        }

        String token = jwtUtils.generateToken(new UserPrincipal(user));
        return buildAuthResponse(token, user);
    }

    public AuthResponse verifyOTP(VerifyOTPRequest req) {
        User user = userRepository.findByEmail(req.getVoterEmail())
                .orElseThrow(() -> new IllegalArgumentException("Invalid voter ID"));
        otpService.verifyOTP(user, req.getOtpCode(), OTP.Purpose.LOGIN);

        user.setVerified(true);
        userRepository.save(user);

        String token = jwtUtils.generateToken(new UserPrincipal(user));
        return buildAuthResponse(token, user);
    }

    private AuthResponse buildAuthResponse(String token, User user) {
        return AuthResponse.builder()
                .token(token)
                .user(UserDto.builder()
                        .id(user.getId())
                        .fullName(user.getFullName())
                        .email(user.getEmail())
                        .role(user.getRole().name())
                        .isVerified(user.isVerified())
                        .build())
                .build();
    }
}