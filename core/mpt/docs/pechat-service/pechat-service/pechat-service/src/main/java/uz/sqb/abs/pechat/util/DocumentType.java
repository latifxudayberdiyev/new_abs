package uz.sqb.abs.pechat.util;

import org.springframework.http.MediaType;

public enum DocumentType {
    DOCX("generated.docx", "application/vnd.openxmlformats-officedocument.wordprocessingml.document"),
    XLSX("generated.xlsx", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"),
    DEFAULT("default", "application/vnd.openxmlformats-officedocument.presentationml.default"),;

    private final String filename;
    private final String contentType;

    DocumentType(String filename, String contentType) {
        this.filename = filename;
        this.contentType = contentType;
    }

    public String getFilename() {
        return filename;
    }

    public MediaType getContentType() {
        return MediaType.parseMediaType(contentType);
    }

    public static DocumentType fromFilename(String filename) {
        if (filename != null && filename.toLowerCase().endsWith(".docx")) {
            return DOCX;
        } else if (filename != null && filename.toLowerCase().endsWith(".xlsx")) {
            return XLSX;
        }
        return DEFAULT;
    }
}
