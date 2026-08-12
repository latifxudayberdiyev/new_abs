package uz.sqb.abs.pechat.configuration.security.jwt;

import com.auth0.jwt.JWT;
import com.auth0.jwt.JWTCreator;
import com.auth0.jwt.JWTVerifier;
import com.auth0.jwt.algorithms.Algorithm;
import com.auth0.jwt.interfaces.DecodedJWT;
import lombok.RequiredArgsConstructor;
import org.apache.commons.lang3.ObjectUtils;
import org.springframework.stereotype.Component;
import uz.sqb.abs.pechat.constant.ExceptionStarterErrorCodes;
import uz.sqb.abs.pechat.exceptions.ServiceException;
import uz.sqb.abs.pechat.property.JwtProperties;


import java.util.Collections;
import java.util.Date;
import java.util.Map;
import java.util.Objects;

@Component
@RequiredArgsConstructor
public class JwtUtil {
    private final JWTVerifier jwtVerifier;
    private final Algorithm algorithm;
    private final JwtProperties jwtProperties;

    public DecodedJWT getDecodedJWT(String token) {
        return jwtVerifier.verify(Objects.requireNonNull(token));
    }

    public String generateAccessToken(String subject, Map<String, Object> claims) {
        Date expiresAt = new Date(jwtProperties.accessTokenExpiresIn() + System.currentTimeMillis());
        return generateToken(subject, expiresAt, claims);
    }

    public String generateRefreshToken(String subject) {
        Date expiresAt = new Date(jwtProperties.refreshTokenExpiresIn() + System.currentTimeMillis());
        return generateToken(subject, expiresAt, Collections.emptyMap());
    }

    public String generateToken(String subject, Date expiresAt, Map<String, Object> claims) {
        try {
            JWTCreator.Builder builder = JWT.create();
            claims.forEach((k, v) -> {
                if (ObjectUtils.isArray(v)) {
                    builder.withArrayClaim(k, (String[]) v);
                } else {
                    builder.withClaim(k, String.valueOf(v));
                }
            });
            return builder.withSubject(subject)
                    .withIssuedAt(new Date())
                    .withExpiresAt(expiresAt)
                    .sign(algorithm);
        } catch (Exception e) {
            throw ServiceException.with500(ExceptionStarterErrorCodes.INTERNAL_SERVER_ERROR, e);
        }
    }

}
