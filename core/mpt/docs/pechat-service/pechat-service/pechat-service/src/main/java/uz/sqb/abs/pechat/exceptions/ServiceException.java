package uz.sqb.abs.pechat.exceptions;

public class ServiceException extends RuntimeException {

    private final String code;
    private final int status;
    private final transient Object[] params;

    public ServiceException(String code, int status, Throwable cause, Object... params) {
        super(code, cause);
        this.code = code;
        this.status = status;
        this.params = params;
    }



    public static ServiceException with400(String code, Object... params) {
        return new ServiceException(code, 400, null, params);
    }

    public static ServiceException with404(String code, Object... params) {
        return new ServiceException(code, 404, null, params);
    }

    public static ServiceException with500(String code, Object... params) {
        return new ServiceException(code, 500, null, params);
    }

    public String getCode() {
        return code;
    }

    public int getStatus() {
        return status;
    }

    public Object[] getParams() {
        return params;
    }
}

