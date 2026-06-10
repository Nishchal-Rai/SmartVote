package com.smartvote.controller;

import com.smartvote.dto.*;
//import com.smartvote.entity.User;
//import com.smartvote.repository.UserRepository;
import com.smartvote.security.UserPrincipal;
import com.smartvote.service.ElectionService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/elections")
@RequiredArgsConstructor
public class ElectionController {

    private final ElectionService electionService;

    @GetMapping
    public ResponseEntity<ApiResponse<List<ElectionDto>>> getActiveElections(
            @AuthenticationPrincipal UserPrincipal principal) {
        return ResponseEntity.ok(ApiResponse.ok("Success",
                electionService.getActiveElections(principal.getUser().getId())));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<ElectionDto>> getElection(
            @PathVariable Long id,
            @AuthenticationPrincipal UserPrincipal principal) {
        return ResponseEntity.ok(ApiResponse.ok("Success",
                electionService.getElection(id, principal.getUser().getId())));
    }

    @PostMapping("/vote")
    public ResponseEntity<ApiResponse<Void>> castVote(
            @Valid @RequestBody VoteRequest req,
            @AuthenticationPrincipal UserPrincipal principal) {
        electionService.castVote(req, principal.getUser());
        return ResponseEntity.ok(ApiResponse.ok("Vote cast successfully", null));
    }
}
