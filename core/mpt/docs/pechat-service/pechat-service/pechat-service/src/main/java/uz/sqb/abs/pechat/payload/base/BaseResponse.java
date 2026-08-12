package uz.sqb.abs.pechat.payload.base;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonInclude;

@JsonIgnoreProperties(ignoreUnknown = true)
@JsonInclude(JsonInclude.Include.NON_NULL)
public record BaseResponse<T>(T data, ErrorData error, boolean success) {

    public static <B> BaseResponse<B> ok(B data) {
        return new BaseResponse<>(data, null, true);
    }

    public static <B> BaseResponse<B> ok() {
        return new BaseResponse<>(null, null, true);
    }

    public static <B> BaseResponse<B> error(ErrorData error) {
        return new BaseResponse<>(null, error, false);
    }
}
