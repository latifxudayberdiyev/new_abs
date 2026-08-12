package uz.sqb.abs.pechat.annotation.validator;

import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;
import uz.sqb.abs.pechat.annotation.ValidHttpMethod;

public class ValidHttpMethodValidator implements ConstraintValidator<ValidHttpMethod, String> {
    @Override
    public boolean isValid(String method, ConstraintValidatorContext constraintValidatorContext) {
        if (method == null) {
            return true;
        }
        return switch (method) {
            case "GET", "HEAD", "PUT", "POST", "PATCH", "DELETE", "OPTIONS", "TRACE" -> true;
            default -> false;
        };
    }
}