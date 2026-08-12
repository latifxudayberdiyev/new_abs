package uz.sqb.abs.pechat.payload.util;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.stereotype.Component;

import java.util.Objects;
import java.util.Optional;

@Component
public class HttpHeaderUtil {
    private final HttpServletRequest httpServletRequest;

    public HttpHeaderUtil(HttpServletRequest httpServletRequest) {
        this.httpServletRequest = httpServletRequest;
    }

    public String requireHeaderValueElse(String header, String defaultValue) {
        String language = this.httpServletRequest.getHeader(header);
        return language == null ? defaultValue : language;
    }

    public Optional<String> getHeaderValue(String header) {
        Objects.requireNonNull(header);
        return Optional.ofNullable(httpServletRequest.getHeader(header));
    }

}
