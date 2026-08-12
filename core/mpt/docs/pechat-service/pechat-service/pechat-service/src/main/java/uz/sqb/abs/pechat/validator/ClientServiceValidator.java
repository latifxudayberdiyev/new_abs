package uz.sqb.abs.pechat.validator;

import org.springframework.util.StringUtils;
import uz.sqb.abs.pechat.constant.ExceptionStarterErrorCodes;
import uz.sqb.abs.pechat.exceptions.ServiceException;
import uz.sqb.abs.pechat.payload.auth.AuthLoginRequest;
import uz.sqb.abs.pechat.payload.auth.AuthRefreshTokenRequest;


public final class ClientServiceValidator {
    private ClientServiceValidator() {
        throw new IllegalStateException("Utility class");
    }

    public static void isValidRequest(AuthLoginRequest requestBody) {
        if (!StringUtils.hasText(requestBody.username()) || !StringUtils.hasText(requestBody.password())) {
            throw ServiceException.with400(ExceptionStarterErrorCodes.INVALID_INPUT);
        }
    }

    public static void isValidRequest(AuthRefreshTokenRequest requestBody) {
        if (!StringUtils.hasText(requestBody.refreshToken())) {
            throw ServiceException.with400(ExceptionStarterErrorCodes.INVALID_INPUT);
        }
    }
}
