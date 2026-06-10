package com.smartvote.dto;
import lombok.*;

@Data @Builder @AllArgsConstructor @NoArgsConstructor
public class UserDto {
    private Long id;
    private String fullName;
    private String email;
    private String role;
    private boolean isVerified;
}
