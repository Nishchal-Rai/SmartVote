package com.smartvote.dto;
import lombok.*;

@Data @Builder @AllArgsConstructor @NoArgsConstructor
public class AuthResponse {
    private String token;
    private String tokenType = "Bearer";
    private UserDto user;
}
