package uz.sqb.abs.pechat.property;

import jakarta.validation.constraints.NotBlank;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.validation.annotation.Validated;

@Validated
@ConfigurationProperties(prefix = "sqb.new-abs.exception")
public record ErrorCodeProperties(@NotBlank String team, @NotBlank String service) {}
