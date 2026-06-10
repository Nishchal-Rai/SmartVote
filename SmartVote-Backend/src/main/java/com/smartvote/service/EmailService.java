package com.smartvote.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.smartvote.entity.OTP;
import com.smartvote.entity.User;
import com.smartvote.repository.OTPRepository;
import com.smartvote.repository.UserRepository;

import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;

@Service
@RequiredArgsConstructor
@Slf4j
public class EmailService {

    private final JavaMailSender mailSender;
    private final UserRepository userRepository;
    private final OTPRepository otpRepository;
    private final PasswordEncoder passwordEncoder;

    public void sendOtpEmail(String toEmail, String otpCode) {
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
            helper.setTo(toEmail);
            helper.setSubject("SmartVote — Your Login OTP");
            helper.setText(buildEmailBody(otpCode), true);
            mailSender.send(message);
            log.info("OTP email sent to {}", maskEmail(toEmail));
        } catch (MessagingException e) {
            log.error("Failed to send OTP email: {}", e.getMessage());
            throw new RuntimeException("Failed to send OTP email. Please try again.");
        }
    }

    private String buildEmailBody(String otpCode) {
        return """
                <div style="font-family: Arial, sans-serif; max-width: 500px; margin: auto;">
                    <h2 style="color: #3D35C8;">SmartVote Login OTP</h2>
                    <p>Your one-time password is:</p>
                    <div style="font-size: 36px; font-weight: bold; letter-spacing: 8px;
                                color: #3D35C8; padding: 16px; background: #f0f0ff;
                                border-radius: 8px; text-align: center;">
                        %s
                    </div>
                    <p style="color: #666; font-size: 13px;">
                        This OTP expires in <strong>10 minutes</strong>.<br>
                        Do not share this code with anyone.
                    </p>
                </div>
                """.formatted(otpCode);
    }

    public String maskEmail(String email) {
        if (email == null || !email.contains("@")) return "***";
        String[] parts = email.split("@");
        return parts[0].charAt(0) + "***@" + parts[1];
    }

    public Map<String, Object> resendOTP(String email) {
        User user = userRepository.findByEmail(email)
            .orElseThrow(() -> new RuntimeException("User not found"));

        if (user.isVerified()) {
            throw new RuntimeException("Account is already verified");
        }

        // Delete old OTP
        OTP existingOTP = otpRepository.findByVoterIdAndIsUsedFalse(user.getId())
            .orElse(null);
        if (existingOTP != null) {
            existingOTP.setUsed(true);
            otpRepository.save(existingOTP);
        }

        // Generate new OTP
        String otpCode = String.valueOf((int)(Math.random() * 900000) + 100000);
        String hashedOTP = passwordEncoder.encode(otpCode);

        OTP newOTP = new OTP();
        newOTP.setVoter(user);
        newOTP.setOtpHash(hashedOTP);
        newOTP.setUsed(false);
        newOTP.setExpiresAt(LocalDateTime.now().plusMinutes(10));
        otpRepository.save(newOTP);

        // Send email
        sendOtpEmail(user.getEmail(), otpCode);

        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "OTP resent to " + email);
        return response;
    }
}