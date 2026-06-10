package com.smartvote.repository;
import com.smartvote.entity.Election;
import com.smartvote.entity.Election.Status;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface ElectionRepository extends JpaRepository<Election, Long> {
    List<Election> findByStatus(Status status);
    List<Election> findByCreatedById(Long userId);
}
