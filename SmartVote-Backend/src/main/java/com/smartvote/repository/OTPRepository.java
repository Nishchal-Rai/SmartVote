package com.smartvote.repository;

import com.smartvote.entity.OTP;
import com.smartvote.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.transaction.annotation.Transactional;
import java.util.Optional;

public interface OTPRepository extends JpaRepository<OTP, String> {

    Optional<OTP> findTopByVoterAndIsUsedFalseAndPurposeOrderByCreatedAtDesc(
            User voter, OTP.Purpose purpose);

    @Modifying
    @Transactional
    @Query("UPDATE OTP o SET o.isUsed = true WHERE o.voter = :voter AND o.purpose = :purpose AND o.isUsed = false")
    void invalidateAllForVoter(User voter, OTP.Purpose purpose);

    Optional<OTP> findByVoterIdAndIsUsedFalse(Long id);
}