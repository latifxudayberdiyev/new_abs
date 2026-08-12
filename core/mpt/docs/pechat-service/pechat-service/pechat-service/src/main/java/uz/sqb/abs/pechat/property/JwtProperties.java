package uz.sqb.abs.pechat.property;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.validation.annotation.Validated;

/**
 * @param secret                jwt secret
 * @param accessTokenExpiresIn  access token expires at in milliseconds
 * @param refreshTokenExpiresIn refresh token expires at in milliseconds
 */
@Validated
@ConfigurationProperties(prefix = "sqb.new-abs.security.jwt")
public record JwtProperties(
        @NotBlank String secret,
        @NotNull Long accessTokenExpiresIn,
        @NotNull Long refreshTokenExpiresIn) {
}
