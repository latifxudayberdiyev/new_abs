package uz.sqb.abs.pechat.configuration.security.jwt;

import com.auth0.jwt.JWT;
import com.auth0.jwt.JWTVerifier;
import com.auth0.jwt.algorithms.Algorithm;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import uz.sqb.abs.pechat.property.JwtProperties;


@Configuration
@RequiredArgsConstructor
public class JwtConfiguration {
    private final JwtProperties jwtProperties;

    @Bean
    public JWTVerifier jwtVerifier(Algorithm algorithm) {
        return JWT.require(algorithm).build();
    }

    @Bean
    public Algorithm getAlgorithm() {
        return Algorithm.HMAC256(jwtProperties.secret().getBytes());
    }
}
