package uz.sqb.abs.pechat.domain;


import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Getter
@Setter
@Entity
@Table(name = "clients")
@NoArgsConstructor
public class Client {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false, unique = true)
    private String clientId;

    @Column(nullable = false)
    private String clientSecret;

    @Column(nullable = false)
    private String description;

    private LocalDateTime lastLoginAt;

    @JdbcTypeCode(SqlTypes.ARRAY)
    private List<String> roles;

    public Client(String clientId, String clientSecret, String description, List<String> roles) {
        this.clientId = clientId;
        this.clientSecret = clientSecret;
        this.description = description;
        this.roles = roles;
    }

    public String getIdAsString() {
        return id.toString();
    }
}
