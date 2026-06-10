package com.smartvote.dto;
import lombok.*;
import java.time.LocalDateTime;
import java.util.List;

@Data @Builder @AllArgsConstructor @NoArgsConstructor
public class ElectionDto {
    private Long id;
    private String title;
    private String description;
    private String votingType;
    private String status;
    private LocalDateTime startDate;
    private LocalDateTime endDate;
    private String createdBy;
    private List<CandidateDto> candidates;
    private boolean hasVoted;
    private long totalVotes;
}
