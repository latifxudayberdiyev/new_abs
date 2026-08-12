package uz.sqb.abs.pechat.payload.base;

import java.util.Map;


public record ErrorData(String code, String message, int httpCode, Map<String, String> details) {
    public static ErrorData withoutDetails(String code, String message, int httpCode) {
        return new ErrorData(code, message, httpCode, null);
    }
}
