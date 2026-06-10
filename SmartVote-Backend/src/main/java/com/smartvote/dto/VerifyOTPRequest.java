package com.smartvote.dto;

import lombok.Data;

@Data
public class VerifyOTPRequest {
    private String voterEmail;
    private String otpCode;
}