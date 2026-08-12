package uz.sqb.abs.pechat.exceptions;


public class ExternalServiceException extends RuntimeException {

    private final String code;
    private final int status;
    private final String errorDetail;

    public ExternalServiceException(String code, int status, String message, String errorDetail) {
        super(message);
        this.code = code;
        this.status = status;
        this.errorDetail = errorDetail;
    }

    public String getCode() {
        return code;
    }

    public int getStatus() {
        return status;
    }

    public String getErrorDetail() {
        return errorDetail;
    }
}