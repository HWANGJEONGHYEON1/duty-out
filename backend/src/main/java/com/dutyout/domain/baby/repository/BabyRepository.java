package com.dutyout.domain.baby.repository;

import com.dutyout.domain.baby.entity.Baby;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface BabyRepository extends JpaRepository<Baby, Long> {

    List<Baby> findByUserId(Long userId);

    Optional<Baby> findByIdAndUserId(Long id, Long userId);

    boolean existsByUserId(Long userId);

    long countByUserId(Long userId);
}
