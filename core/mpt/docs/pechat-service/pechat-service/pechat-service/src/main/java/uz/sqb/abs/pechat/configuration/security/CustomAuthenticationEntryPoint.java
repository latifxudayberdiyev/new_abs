package uz.sqb.abs.pechat.configuration.security;

import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.ServletOutputStream;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.AuthenticationEntryPoint;
import uz.sqb.abs.pechat.payload.base.BaseResponse;
import uz.sqb.abs.pechat.payload.base.ErrorData;
import uz.sqb.abs.pechat.payload.util.HttpHeaderUtil;
import uz.sqb.abs.pechat.property.ErrorCodeProperties;
import uz.sqb.abs.pechat.service.ErrorMessageService;


import java.io.IOException;


@Slf4j
public class CustomAuthenticationEntryPoint implements AuthenticationEntryPoint {

    private final ObjectMapper objectMapper;
    private final ErrorMessageService errorMessageService;
    private final HttpHeaderUtil httpHeaderUtil;
    private final String errorCode;

    public CustomAuthenticationEntryPoint(ObjectMapper objectMapper, ErrorMessageService errorMessageService, HttpHeaderUtil httpHeaderUtil, ErrorCodeProperties errorCodeProperties) {
        this.objectMapper = objectMapper;
        this.httpHeaderUtil = httpHeaderUtil;
        this.errorMessageService = errorMessageService;
        this.errorCode = errorCodeProperties.team() + ":" + errorCodeProperties.service() + ":" + HttpStatus.UNAUTHORIZED;
    }

    @Override
    public void commence(HttpServletRequest request, HttpServletResponse response,
                         AuthenticationException e) throws IOException {
        log.error("Unauthorized", e);
        response.addHeader(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE);
        response.setStatus(HttpStatus.UNAUTHORIZED.value());
        ServletOutputStream outputStream = response.getOutputStream();
        String language = httpHeaderUtil.requireHeaderValueElse(HttpHeaders.ACCEPT_LANGUAGE, "uz");
        objectMapper.writeValue(outputStream, getResponseData(language));
        response.flushBuffer();
    }

    private BaseResponse<Void> getResponseData(String language) {
        ErrorData errorData = ErrorData.withoutDetails(errorCode, errorMessageService.getErrorMessage(language, errorCode), HttpStatus.UNAUTHORIZED.value());
        return BaseResponse.error(errorData);
    }

}
