package com.smartvote.dto;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import java.time.LocalDateTime;
import java.util.List;

@Data
public class CreateElectionRequest {
    @NotBlank private String title;
    private String description;
    @NotBlank private String votingType;
    
    @NotNull private LocalDateTime startDate;
    @NotNull private LocalDateTime endDate;
    private List<CandidateDto> candidates;
}
