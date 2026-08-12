package uz.sqb.abs.pechat.property;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.http.HttpMethod;
import org.springframework.security.web.servlet.util.matcher.PathPatternRequestMatcher;
/*import org.springframework.security.web.util.matcher.AntPathRequestMatcher;*/
import org.springframework.security.web.util.matcher.RequestMatcher;
import org.springframework.validation.annotation.Validated;
import uz.sqb.abs.pechat.annotation.ValidHttpMethod;


import java.util.List;
import java.util.stream.Stream;


@Validated
@ConfigurationProperties(prefix = "sqb.new-abs.security.authorization")
public record AuthorizationProperties(@Valid List<SecurityRequestMatcher> permitAll) {

    public RequestMatcher[] getRequestMatchers() {
        if (permitAll == null) {
            return new RequestMatcher[0];
        }
        return permitAll
                .stream()
                .flatMap(SecurityRequestMatcher::getRequestMatchers)
                .toArray(RequestMatcher[]::new);
    }

    public record SecurityRequestMatcher(@NotBlank @ValidHttpMethod String method,
                                         @NotNull @Size(min = 1) List<String> patterns) {
        /*public Stream<RequestMatcher> getRequestMatchers() {
            return patterns
                    .stream()
                    .map(pattern -> new AntPathRequestMatcher(pattern, method, false));
        }*/

        public Stream<RequestMatcher> getRequestMatchers() {
            return patterns.stream()
                    .map(pattern -> PathPatternRequestMatcher.withDefaults()
                            .matcher(HttpMethod.valueOf(method), pattern));
        }
    }

}
