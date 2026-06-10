package com.smartvote.repository;
import com.smartvote.entity.Vote;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.util.List;
import java.util.Optional;

public interface VoteRepository extends JpaRepository<Vote, Long> {
    boolean existsByElectionIdAndVoterId(Long electionId, Long voterId);
    Optional<Vote> findByElectionIdAndVoterId(Long electionId, Long voterId);
    long countByElectionId(Long electionId);
    @Query("SELECT v.candidate.id, COUNT(v) FROM Vote v WHERE v.election.id = :electionId GROUP BY v.candidate.id")
    List<Object[]> countVotesByCandidate(Long electionId);
}
