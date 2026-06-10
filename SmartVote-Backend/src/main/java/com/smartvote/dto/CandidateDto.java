package com.smartvote.dto;
import lombok.*;

@Data @Builder @AllArgsConstructor @NoArgsConstructor
public class CandidateDto {
    private Long id;
    private String name;
    private String party;
    private String description;
    private String photoUrl;
    private long voteCount;
}
