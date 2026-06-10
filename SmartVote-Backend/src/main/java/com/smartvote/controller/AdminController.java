package com.smartvote.controller;

import com.smartvote.dto.*;
import com.smartvote.entity.User;
import com.smartvote.repository.UserRepository;
import com.smartvote.security.UserPrincipal;
import com.smartvote.service.ElectionService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/admin")
//@PreAuthorize("hasRole('ADMIN')")
@RequiredArgsConstructor
public class AdminController {

    private final ElectionService electionService;
    private final UserRepository userRepository;

    @GetMapping("/elections")
    public ResponseEntity<ApiResponse<List<ElectionDto>>> getAllElections(
            @AuthenticationPrincipal UserPrincipal principal) {
        return ResponseEntity.ok(ApiResponse.ok("Success",
                electionService.getAllElections(principal.getUser().getId())));
    }
     @GetMapping("/ab")
    public String getAllElectis() {
        return "Hellow A";
    }

    @PostMapping("/elections")
    public ResponseEntity<ApiResponse<ElectionDto>> createElection(
            @Valid @RequestBody CreateElectionRequest req,
            @AuthenticationPrincipal UserPrincipal principal) {
        ElectionDto dto = electionService.createElection(req, principal.getUser());
        return ResponseEntity.ok(ApiResponse.ok("Election created", dto));
    }

    @PutMapping("/elections/{id}/status")
    public ResponseEntity<ApiResponse<ElectionDto>> updateStatus(
            @PathVariable Long id,
            @RequestBody Map<String, String> body,
            @AuthenticationPrincipal UserPrincipal principal) {
        ElectionDto dto = electionService.updateStatus(id, body.get("status"), principal.getUser());
        return ResponseEntity.ok(ApiResponse.ok("Status updated", dto));
    }

    @GetMapping("/users")
    public ResponseEntity<ApiResponse<List<User>>> getAllUsers() {
        return ResponseEntity.ok(ApiResponse.ok("Success", userRepository.findAll()));
    }
}
