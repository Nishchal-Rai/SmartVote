package com.smartvote.entity;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "votes", uniqueConstraints = @UniqueConstraint(columnNames = {"election_id","voter_id"}))
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Vote {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "election_id", nullable = false)
    private Election election;
    @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "voter_id", nullable = false)
    private User voter;
    @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "candidate_id", nullable = false)
    private Candidate candidate;
    @Column(name = "voted_at") @Builder.Default
    private LocalDateTime votedAt = LocalDateTime.now();
}
