package uz.sqb.abs.pechat.service;

public interface ErrorMessageService {
  String ERROR_CODE_CACHE_PREFIX = "ERROR_CODE";

  String getErrorMessage(String language, String code, Object... params);
}
