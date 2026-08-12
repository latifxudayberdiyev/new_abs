package uz.sqb.abs.pechat.service;

import java.io.InputStream;
import java.util.Map;

public interface ExcelTemplateEngine {
    byte[] fillTemplate(InputStream inputStream, Map<String, String> values);
}
