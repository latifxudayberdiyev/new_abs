package uz.sqb.abs.pechat.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uz.sqb.abs.pechat.constant.ExceptionStarterErrorCodes;
import uz.sqb.abs.pechat.payload.error.ErrorShortDto;
import uz.sqb.abs.pechat.property.ErrorCodeProperties;
import uz.sqb.abs.pechat.util.CacheUtil;


import java.util.Arrays;

public class DefaultErrorMessageService implements ErrorMessageService {
  private static final Logger log = LoggerFactory.getLogger(DefaultErrorMessageService.class);
  private final String defaultErrorCode;
  private final CacheUtil cacheUtil;

  public DefaultErrorMessageService(CacheUtil cacheUtil, ErrorCodeProperties errorCodeProperties) {
    this.defaultErrorCode =
        errorCodeProperties.team()
            + ":"
            + errorCodeProperties.service()
            + ":"
            + ExceptionStarterErrorCodes.INTERNAL_SERVER_ERROR;
    this.cacheUtil = cacheUtil;
  }

  @Override
  public String getErrorMessage(String language, String code, Object... params) {
    return cacheUtil
        .get(ErrorMessageService.ERROR_CODE_CACHE_PREFIX, code, ErrorShortDto.class)
        .or(
            () ->
                cacheUtil.get(
                    ErrorMessageService.ERROR_CODE_CACHE_PREFIX,
                    defaultErrorCode,
                    ErrorShortDto.class))
        .map(
            errorMessage -> {
              String message = errorMessage.message().getMessage(language);
              if (errorMessage.formattable() && params.length != 0) {
                return getFormattedMessage(message, params);
              }
              return message;
            })
        .orElseGet(
            () -> {
              log.error("can not error message translation  with code {}", code);
              return "internal server error";
            });
  }

  private String getFormattedMessage(String errorMessage, Object[] params) {
    try {
      return errorMessage.formatted(params);
    } catch (Exception e) {
      log.error(
          "can not get formatted message. message is:{}, params is:{}",
          errorMessage,
          Arrays.toString(params),
          e);
    }
    return "internal service error";
  }
}
