package com.smartvote.service;

import com.smartvote.dto.*;
import com.smartvote.entity.*;
import com.smartvote.repository.*;
//import com.smartvote.security.UserPrincipal;
import lombok.RequiredArgsConstructor;
//import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ElectionService {

    private final ElectionRepository electionRepository;
    private final CandidateRepository candidateRepository;
    private final VoteRepository voteRepository;
    private final UserRepository userRepository;

    public List<ElectionDto> getActiveElections(Long userId) {
        return electionRepository.findByStatus(Election.Status.ACTIVE)
                .stream().map(e -> toDto(e, userId)).collect(Collectors.toList());
    }

    public List<ElectionDto> getAllElections(Long userId) {
        return electionRepository.findAll()
                .stream().map(e -> toDto(e, userId)).collect(Collectors.toList());
    }

    public ElectionDto getElection(Long id, Long userId) {
        Election election = electionRepository.findById(id)
                .orElseThrow(() -> new NoSuchElementException("Election not found"));
        return toDto(election, userId);
    }

    @Transactional
    public ElectionDto createElection(CreateElectionRequest req, User creator) {
        Election election = Election.builder()
                .title(req.getTitle())
                .description(req.getDescription())
                .votingType(req.getVotingType())
                .startDate(req.getStartDate())
                .endDate(req.getEndDate())
                .createdBy(creator)
                .status(Election.Status.DRAFT)
                .build();
        election = electionRepository.save(election);

        if (req.getCandidates() != null) {
            for (CandidateDto cd : req.getCandidates()) {
                Candidate c = Candidate.builder()
                        .name(cd.getName())
                        .party(cd.getParty())
                        .description(cd.getDescription())
                        .election(election)
                        .build();
                candidateRepository.save(c);
            }
        }
        return toDto(electionRepository.findById(election.getId()).orElseThrow(), creator.getId());
    }

    @Transactional
    public ElectionDto updateStatus(Long electionId, String status, User admin) {
        Election election = electionRepository.findById(electionId)
                .orElseThrow(() -> new NoSuchElementException("Election not found"));
        election.setStatus(Election.Status.valueOf(status.toUpperCase()));
        return toDto(electionRepository.save(election), admin.getId());
    }

    @Transactional
    public void castVote(VoteRequest req, User voter) {
        Election election = electionRepository.findById(req.getElectionId())
                .orElseThrow(() -> new NoSuchElementException("Election not found"));
        if (election.getStatus() != Election.Status.ACTIVE) {
            throw new IllegalStateException("Election is not active");
        }
        if (voteRepository.existsByElectionIdAndVoterId(req.getElectionId(), voter.getId())) {
            throw new IllegalStateException("You have already voted in this election");
        }
        Candidate candidate = candidateRepository.findById(req.getCandidateId())
                .orElseThrow(() -> new NoSuchElementException("Candidate not found"));
        Vote vote = Vote.builder().election(election).voter(voter).candidate(candidate).build();
        voteRepository.save(vote);
    }

    private ElectionDto toDto(Election e, Long userId) {
        Map<Long, Long> voteCounts = new HashMap<>();
        voteRepository.countVotesByCandidate(e.getId())
                .forEach(row -> voteCounts.put((Long) row[0], (Long) row[1]));

        List<CandidateDto> candidates = e.getCandidates().stream().map(c ->
                CandidateDto.builder()
                        .id(c.getId()).name(c.getName()).party(c.getParty())
                        .description(c.getDescription()).photoUrl(c.getPhotoUrl())
                        .voteCount(voteCounts.getOrDefault(c.getId(), 0L))
                        .build()
        ).collect(Collectors.toList());

        return ElectionDto.builder()
                .id(e.getId()).title(e.getTitle()).description(e.getDescription())
                .votingType(e.getVotingType()).status(e.getStatus().name())
                .startDate(e.getStartDate()).endDate(e.getEndDate())
                .createdBy(e.getCreatedBy() != null ? e.getCreatedBy().getFullName() : "")
                .candidates(candidates)
                .hasVoted(userId != null && voteRepository.existsByElectionIdAndVoterId(e.getId(), userId))
                .totalVotes(voteRepository.countByElectionId(e.getId()))
                .build();
    }
}
