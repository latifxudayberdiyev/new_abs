package uz.sqb.abs.pechat.util;

import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;
import java.io.ByteArrayInputStream;
import java.io.IOException;

public class DocumentTypeDetector {

    public static DocumentType detect(byte[] content) {
        try (ZipInputStream zis = new ZipInputStream(new ByteArrayInputStream(content))) {
            ZipEntry entry;
            while ((entry = zis.getNextEntry()) != null) {
                String name = entry.getName();
                if (name.equals("word/document.xml")) {
                    return DocumentType.DOCX;
                }
                if (name.equals("xl/workbook.xml")) {
                    return DocumentType.XLSX;
                }
            }
        } catch (IOException e) {
            throw new RuntimeException("Fayl turini aniqlab bo'lmadi: " + e.getMessage(), e);
        }
        throw new IllegalArgumentException("Noma'lum fayl formati — na Word, na Excel");
    }
}
