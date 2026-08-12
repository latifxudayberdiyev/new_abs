package uz.sqb.abs.pechat.service.impl;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import uz.sqb.abs.pechat.constant.ExceptionStarterErrorCodes;
import uz.sqb.abs.pechat.convertor.PdfConverter;
import uz.sqb.abs.pechat.exceptions.ServiceException;
import uz.sqb.abs.pechat.service.ExcelTemplateEngine;
import uz.sqb.abs.pechat.service.PrintService;
import uz.sqb.abs.pechat.service.WordTemplateEngine;
import uz.sqb.abs.pechat.service.file_service.FileService;
import uz.sqb.abs.pechat.util.ByteArrayMultipartFile;
import uz.sqb.abs.pechat.util.DocumentType;
import uz.sqb.abs.pechat.util.DocumentTypeDetector;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class PrintServiceImpl implements PrintService {

    private final ExcelTemplateEngine excelTemplateEngine;
    private final WordTemplateEngine wordTemplateEngine;
    private final FileService fileService;
    private final PdfConverter pdfConverter;


    @Override
    public byte[] generate(MultipartFile file, String data) {

        String filename = file.getOriginalFilename();

        if (filename == null || filename.isBlank()) {
            throw new IllegalArgumentException("File name is empty");
        }

        String lower = filename.toLowerCase();
        Map<String, String> values = parseJson(data);
        String extension;
        byte[] filledDocument;

        try {
            if (lower.endsWith(".docx")) {
                extension = "docx";
                filledDocument = wordTemplateEngine.fillTemplate(file.getInputStream(), values);
            } else if (lower.endsWith(".xlsx")) {
                extension = "xlsx";
                filledDocument = excelTemplateEngine.fillTemplate(file.getInputStream(), values);
            } else {
                throw new IllegalArgumentException("Invalid file type: " + filename);
            }
        } catch (IOException e) {
            throw new ServiceException(ExceptionStarterErrorCodes.INVALID_INPUT, 400, e);
        }

        return pdfConverter.convertToPdf(filledDocument, extension);
    }

    @Override
    public byte[] generateWithId(String id, String data) {
        Map<String, String> values = parseJson(data);
        byte[] fileBytes = fileService.getFileById(id);
        DocumentType type = DocumentTypeDetector.detect(fileBytes);

        String extension;
        byte[] filledDocument;

        if (type == DocumentType.DOCX) {
            extension = "docx";
            filledDocument = wordTemplateEngine.fillTemplate(new ByteArrayInputStream(fileBytes), values);
        } else if (type == DocumentType.XLSX) {
            extension = "xlsx";
            filledDocument = excelTemplateEngine.fillTemplate(new ByteArrayInputStream(fileBytes), values);
        } else {
            throw new IllegalArgumentException("Invalid file type: " + type);
        }

        return pdfConverter.convertToPdf(filledDocument, extension);
    }

    private Map<String, String> parseJson(String jsonData) {
        try {
            ObjectMapper objectMapper = new ObjectMapper();
            return objectMapper.readValue(jsonData, new TypeReference<Map<String, String>>() {
            });
        } catch (JsonProcessingException e) {
            throw new IllegalArgumentException("JSON format is wrong : " + e.getMessage(), e);
        }
    }

    @Override
    public MultipartFile convertToMultipartFile(byte[] fileBytes) {
        DocumentType type = DocumentTypeDetector.detect(fileBytes);

        return new ByteArrayMultipartFile(
                fileBytes,
                "file",
                type.getFilename(),
                type.name()
        );
    }

}

