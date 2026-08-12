package uz.sqb.abs.pechat.exceptions;

import jakarta.validation.ConstraintViolationException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.RedisConnectionFailureException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.MissingServletRequestParameterException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;
import org.springframework.web.multipart.MaxUploadSizeExceededException;
import org.springframework.web.reactive.function.client.WebClientRequestException;
import uz.sqb.abs.pechat.constant.ExceptionStarterErrorCodes;
import uz.sqb.abs.pechat.payload.base.BaseResponse;
import uz.sqb.abs.pechat.payload.base.ErrorData;
import uz.sqb.abs.pechat.property.ErrorCodeProperties;


import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Slf4j
@RestControllerAdvice
public class DefaultGlobalRestExceptionHandler {

    private final String errorCodePrefix;

    public DefaultGlobalRestExceptionHandler(ErrorCodeProperties errorCodeProperties) {
        this.errorCodePrefix = errorCodeProperties.team() + ":" + errorCodeProperties.service();
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<BaseResponse<Void>> handleValidation(MethodArgumentNotValidException e) {
        log.warn("Validation error", e);
        Map<String, String> fields = null;
        List<FieldError> fieldErrors = e.getBindingResult().getFieldErrors();
        if (!fieldErrors.isEmpty()) {
            fields = fieldErrors.stream()
                    .collect(Collectors.toMap(
                            FieldError::getField,
                            fe -> fe.getDefaultMessage() != null ? fe.getDefaultMessage() : "invalid value",
                            (a, b) -> a));
        }
        return respond(ExceptionStarterErrorCodes.INVALID_INPUT, HttpStatus.BAD_REQUEST,
                "One or more fields are invalid", fields);
    }

    @ExceptionHandler(ConstraintViolationException.class)
    public ResponseEntity<BaseResponse<Void>> handleConstraintViolation(ConstraintViolationException e) {
        log.warn("Constraint violation: {}", e.getMessage());
        return respond(ExceptionStarterErrorCodes.INVALID_INPUT, HttpStatus.BAD_REQUEST, e.getMessage());
    }

    @ExceptionHandler(MissingServletRequestParameterException.class)
    public ResponseEntity<BaseResponse<Void>> handleMissingParam(MissingServletRequestParameterException e) {
        log.warn("Missing parameter: {}", e.getMessage());
        return respond(ExceptionStarterErrorCodes.REQUEST_PARAM_MISSING, HttpStatus.BAD_REQUEST, e.getMessage());
    }

    @ExceptionHandler(HttpMessageNotReadableException.class)
    public ResponseEntity<BaseResponse<Void>> handleNotReadable(HttpMessageNotReadableException e) {
        log.warn("Malformed request body: {}", e.getMessage());
        return respond(ExceptionStarterErrorCodes.INVALID_REQUEST, HttpStatus.BAD_REQUEST, "Request body is malformed");
    }

    @ExceptionHandler(MethodArgumentTypeMismatchException.class)
    public ResponseEntity<BaseResponse<Void>> handleTypeMismatch(MethodArgumentTypeMismatchException e) {
        String message = String.format("Parameter '%s' has an invalid format", e.getName());
        log.warn("Type mismatch: {}", message);
        return respond(ExceptionStarterErrorCodes.TYPE_IS_NOT_MATCH, HttpStatus.BAD_REQUEST, message);
    }


    @ExceptionHandler(MaxUploadSizeExceededException.class)
    public ResponseEntity<BaseResponse<Void>> handleMaxUploadSize(MaxUploadSizeExceededException e) {
        log.warn("Upload size exceeded: {}", e.getMessage());
        return respond(ExceptionStarterErrorCodes.FILE_SIZE_EXCEEDED, HttpStatus.PAYLOAD_TOO_LARGE,
                "File size exceeds the allowed limit");
    }

    @ExceptionHandler(ServiceException.class)
    public ResponseEntity<BaseResponse<Void>> handleServiceException(ServiceException e) {
        log.warn("ServiceException: code={}, status={}, message={}", e.getCode(), e.getStatus(), e.getMessage());
        ErrorData error = ErrorData.withoutDetails(buildErrorCode(e.getCode()), e.getMessage(), e.getStatus());
        return ResponseEntity.status(e.getStatus()).body(BaseResponse.error(error));
    }

    @ExceptionHandler(ExternalServiceException.class)
    public ResponseEntity<BaseResponse<Void>> handleExternalServiceException(ExternalServiceException e) {
        log.error("ExternalServiceException: code={}, status={}, detail={}",
                e.getCode(), e.getStatus(), e.getErrorDetail());
        ErrorData error = ErrorData.withoutDetails(buildErrorCode(e.getCode()), e.getMessage(), e.getStatus());
        return ResponseEntity.status(e.getStatus()).body(BaseResponse.error(error));
    }


    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<BaseResponse<Void>> handleIllegalArgument(IllegalArgumentException e) {
        log.warn("Bad request: {}", e.getMessage());
        return respond(ExceptionStarterErrorCodes.INVALID_INPUT, HttpStatus.BAD_REQUEST, e.getMessage());
    }

    @ExceptionHandler(IllegalStateException.class)
    public ResponseEntity<BaseResponse<Void>> handleIllegalState(IllegalStateException e) {
        log.warn("Invalid state: {}", e.getMessage());
        return respond(ExceptionStarterErrorCodes.UNAUTHORIZED, HttpStatus.CONFLICT, e.getMessage());
    }

    @ExceptionHandler(WebClientRequestException.class)
    public ResponseEntity<BaseResponse<Void>> handleWebClientRequest(WebClientRequestException e) {
        log.error("External service unreachable: {}", e.getMessage());
        return respond(ExceptionStarterErrorCodes.EXTERNAL_SERVICE_UNREACHABLE, HttpStatus.SERVICE_UNAVAILABLE,
                "External service is currently unreachable. Please try again later.");
    }

    @ExceptionHandler(RedisConnectionFailureException.class)
    public ResponseEntity<BaseResponse<Void>> handleRedisConnection(RedisConnectionFailureException e) {
        log.error("Redis connection failure: {}", e.getMessage());
        return respond(ExceptionStarterErrorCodes.CACHE_UNAVAILABLE, HttpStatus.SERVICE_UNAVAILABLE,
                "Cache service is temporarily unavailable");
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<BaseResponse<Void>> handleGeneric(Exception e) {
        log.error("Internal error", e);
        return respond(ExceptionStarterErrorCodes.INTERNAL_SERVER_ERROR, HttpStatus.INTERNAL_SERVER_ERROR,
                "Internal server error");
    }

    private String buildErrorCode(String code) {
        return errorCodePrefix + ":" + code;
    }

    private ResponseEntity<BaseResponse<Void>> respond(String code, HttpStatus status, String message) {
        return respond(code, status, message, null);
    }

    private ResponseEntity<BaseResponse<Void>> respond(String code, HttpStatus status, String message,
                                                       Map<String, String> fields) {
        ErrorData error = new ErrorData(buildErrorCode(code), message, status.value(),
                fields != null ? fields : Collections.emptyMap());
        return ResponseEntity.status(status).body(BaseResponse.error(error));
    }
}