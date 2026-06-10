package com.smartvote.entity;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity @Table(name = "elections")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Election {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @Column(nullable = false) private String title;
    @Column(columnDefinition = "TEXT") private String description;
    @Column(name = "voting_type", nullable = false) private String votingType;
    @Enumerated(EnumType.STRING) @Column(nullable = false)
    @Builder.Default private Status status = Status.DRAFT;
    @Column(name = "start_date", nullable = false) private LocalDateTime startDate;
    @Column(name = "end_date", nullable = false) private LocalDateTime endDate;
    @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "created_by")
    private User createdBy;
    @OneToMany(mappedBy = "election", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.EAGER)
    @Builder.Default private List<Candidate> candidates = new ArrayList<>();
    @OneToMany(mappedBy = "election", cascade = CascadeType.ALL)
    @Builder.Default private List<Vote> votes = new ArrayList<>();
    @Column(name = "created_at")
    @Builder.Default private LocalDateTime createdAt = LocalDateTime.now();
    public enum Status { DRAFT, ACTIVE, CLOSED }
}
