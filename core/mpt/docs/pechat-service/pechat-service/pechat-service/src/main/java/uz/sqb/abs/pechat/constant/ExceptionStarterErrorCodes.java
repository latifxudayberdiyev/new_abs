package uz.sqb.abs.pechat.constant;

public final class ExceptionStarterErrorCodes {

    public static final String BAD_REQUEST = "-1";
    public static final String UNAUTHORIZED = "-2";
    public static final String ACCESS_DENIED = "-3";
    public static final String NOT_FOUND = "-4";
    public static final String INTERNAL_SERVER_ERROR = "-5";
    public static final String INVALID_MEDIA_TYPE_ERROR = "-6";

    public static final String FILE_SIZE_EXCEEDED = "-7";

    public static final String HEADER_MISSING = "-8";

    public static final String INVALID_INPUT = "-9";
    public static final String INVALID_PATH_VARIABLE = "-10";
    public static final String TYPE_IS_NOT_MATCH = "-11";
    public static final String REQUEST_PARAM_MISSING = "-12";
    public static final String INVALID_REQUEST = "-13";



    public static final String FILE_NOT_FOUND = "-15";

    public static final String EXTERNAL_SERVICE_UNREACHABLE = "-18";

    public static final String EXTERNAL_SERVICE_ERROR = "-19";

    public static final String CACHE_UNAVAILABLE = "-20";

    private ExceptionStarterErrorCodes() {
        throw new IllegalStateException("Utility class");
    }
}