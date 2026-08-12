package uz.sqb.abs.pechat.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.transaction.annotation.Transactional;
import uz.sqb.abs.pechat.domain.Client;

import java.time.LocalDateTime;
import java.util.Optional;
import java.util.UUID;

public interface ClientRepository extends JpaRepository<Client, UUID> {
    @Query("select c from Client c where c.clientId = ?1")
    Optional<Client> findByClientId(String username);

    @Modifying
    @Transactional
    @Query("update Client c set c.lastLoginAt = ?2 where c.id = ?1")
    void updateLastUpdatedAt(UUID id, LocalDateTime lastLoginAt);
}