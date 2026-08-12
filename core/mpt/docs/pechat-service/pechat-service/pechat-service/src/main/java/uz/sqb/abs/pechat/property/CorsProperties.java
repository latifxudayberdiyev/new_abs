package uz.sqb.abs.pechat.property;

import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.validation.annotation.Validated;

import java.util.Collections;
import java.util.List;


@Getter
@Setter
@Validated
@ConfigurationProperties(prefix = "sqb.new-abs.security.cors")
public class CorsProperties {
    private List<String> allowedHeaders = Collections.emptyList();
    private List<String> allowedOrigins = Collections.emptyList();
    private List<String> allowedMethods = Collections.emptyList();
    private List<String> exposedHeaders = Collections.emptyList();
    private String urlPattern = "";
    private boolean allowCredentials = false;
}
