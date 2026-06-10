package com.smartvote.dto;

import lombok.*;

@Data
@Builder

public class LoginResponse {
    private String voterId;
    private String email;
    private String message;
}