package uz.sqb.abs.pechat.annotation;

import jakarta.validation.Constraint;
import jakarta.validation.Payload;
import uz.sqb.abs.pechat.annotation.validator.ValidHttpMethodValidator;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

@Constraint(
        validatedBy = {ValidHttpMethodValidator.class}
)
@Target({ElementType.METHOD, ElementType.FIELD, ElementType.ANNOTATION_TYPE, ElementType.CONSTRUCTOR, ElementType.PARAMETER, ElementType.TYPE_USE})
@Retention(RetentionPolicy.RUNTIME)
public @interface ValidHttpMethod {
    String message() default "not valid http method";

    Class<?>[] groups() default {};

    Class<? extends Payload>[] payload() default {};

}
