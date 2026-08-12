package uz.sqb.abs.pechat.configuration.security;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import uz.sqb.abs.pechat.constant.ExceptionStarterErrorCodes;
import uz.sqb.abs.pechat.exceptions.ServiceException;


@Component
public class UserSession {

    public SecurityUserDetails requireUserDetails() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null) {
            throw new ServiceException(ExceptionStarterErrorCodes.UNAUTHORIZED, 401, null);
        }
        if (authentication.getPrincipal() instanceof SecurityUserDetails userDetails) {
            return userDetails;
        }
        throw new ServiceException(ExceptionStarterErrorCodes.UNAUTHORIZED, 401, null);
    }

}
