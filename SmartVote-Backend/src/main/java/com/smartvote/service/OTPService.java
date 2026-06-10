package com.smartvote.service;

import com.smartvote.entity.OTP;
import com.smartvote.entity.User;
import com.smartvote.repository.OTPRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.security.SecureRandom;
import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
@Slf4j
public class OTPService {

    private final OTPRepository otpRepository;
    private final PasswordEncoder passwordEncoder;
    private static final SecureRandom RANDOM = new SecureRandom();

    @Transactional
    public String generateAndStoreOTP(User voter, OTP.Purpose purpose) {
        otpRepository.invalidateAllForVoter(voter, purpose);

        String plainOTP = String.format("%06d", RANDOM.nextInt(1_000_000));

        OTP otp = OTP.builder()
                .voter(voter)
                .otpHash(passwordEncoder.encode(plainOTP))
                .purpose(purpose)
                .expiresAt(LocalDateTime.now().plusMinutes(10))
                .build();
        otpRepository.save(otp);

        return plainOTP;
    }

    @Transactional
    public void verifyOTP(User voter, String plainOTP, OTP.Purpose purpose) {
        OTP otp = otpRepository
                .findTopByVoterAndIsUsedFalseAndPurposeOrderByCreatedAtDesc(voter, purpose)
                .orElseThrow(() -> new IllegalStateException("No active OTP found. Please request a new one."));

        if (otp.isExpired()) {
            throw new IllegalStateException("OTP has expired. Please request a new one.");
        }
        if (otp.isMaxAttemptsReached()) {
            throw new IllegalStateException("Too many failed attempts. Please request a new OTP.");
        }
        if (!passwordEncoder.matches(plainOTP, otp.getOtpHash())) {
            otp.setAttempts(otp.getAttempts() + 1);
            otpRepository.save(otp);
            int remaining = 5 - otp.getAttempts();
            throw new IllegalArgumentException("Invalid OTP. " + remaining + " attempt(s) remaining.");
        }

        otp.setUsed(true);
        otpRepository.save(otp);
    }
}