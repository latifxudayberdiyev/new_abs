package uz.sqb.abs.pechat.service.impl;

import org.apache.poi.openxml4j.exceptions.InvalidFormatException;
import org.apache.poi.util.Units;
import org.apache.poi.xwpf.model.XWPFHeaderFooterPolicy;
import org.apache.poi.xwpf.usermodel.*;
import org.springframework.stereotype.Component;
import uz.sqb.abs.pechat.constant.ExceptionStarterErrorCodes;
import uz.sqb.abs.pechat.exceptions.ServiceException;
import uz.sqb.abs.pechat.service.WordTemplateEngine;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Component
public class WordTemplateEngineImpl implements WordTemplateEngine {

    private static final Pattern VARIABLE_PATTERN = Pattern.compile("\\[([a-zA-Z][a-zA-Z0-9_]*)\\]");
    private static final String QR_CODE_VARIABLE = "qr_code";
    private static final int QR_SIZE_EMU = Units.toEMU(100);

    private final QrCodeGenerator qrCodeGenerator;

    public WordTemplateEngineImpl(QrCodeGenerator qrCodeGenerator) {
        this.qrCodeGenerator = qrCodeGenerator;
    }

    @Override
    public byte[] fillTemplate(InputStream templateStream, Map<String, String> values) {
        try (XWPFDocument document = new XWPFDocument(templateStream)) {

            processParagraphs(document.getParagraphs(), values);

            for (XWPFTable table : document.getTables()) {
                processTable(table, values);
            }

            for (XWPFHeader header : document.getHeaderList()) {
                processParagraphs(header.getParagraphs(), values);
                for (XWPFTable table : header.getTables()) {
                    processTable(table, values);
                }
            }
            for (XWPFFooter footer : document.getFooterList()) {
                processParagraphs(footer.getParagraphs(), values);
                for (XWPFTable table : footer.getTables()) {
                    processTable(table, values);
                }
            }

            if (values.containsKey(QR_CODE_VARIABLE)) {
                addQrCodeToFooter(document, values.get(QR_CODE_VARIABLE));
            }

            ByteArrayOutputStream out = new ByteArrayOutputStream();
            document.write(out);
            return out.toByteArray();

        } catch (IOException e) {
            throw new RuntimeException("Write or Read exception in Word file: " + e.getMessage(), e);
        } catch (Exception e) {
            throw new RuntimeException("File is not Word format: " + e.getMessage(), e);
        }
    }

    private void processTable(XWPFTable table, Map<String, String> values) {
        for (XWPFTableRow row : table.getRows()) {
            for (XWPFTableCell cell : row.getTableCells()) {
                processParagraphs(cell.getParagraphs(), values);
                for (XWPFTable nestedTable : cell.getTables()) {
                    processTable(nestedTable, values);
                }
            }
        }
    }

    private void processParagraphs(List<XWPFParagraph> paragraphs, Map<String, String> values) {
        for (XWPFParagraph paragraph : paragraphs) {
            replaceInParagraph(paragraph, values);
        }
    }

    private void replaceInParagraph(XWPFParagraph paragraph, Map<String, String> values) {
        List<XWPFRun> runs = paragraph.getRuns();
        if (runs.isEmpty()) {
            return;
        }

        StringBuilder fullText = new StringBuilder();
        for (XWPFRun run : runs) {
            String text = run.getText(0);
            if (text != null) {
                fullText.append(text);
            }
        }

        String original = fullText.toString();
        Matcher matcher = VARIABLE_PATTERN.matcher(original);
        if (!matcher.find()) {
            return;
        }

        matcher.reset();
        StringBuilder replaced = new StringBuilder();
        int lastEnd = 0;
        while (matcher.find()) {
            replaced.append(original, lastEnd, matcher.start());
            String varName = matcher.group(1);
            String value = values.getOrDefault(varName, "");
            replaced.append(value);
            lastEnd = matcher.end();
        }
        replaced.append(original.substring(lastEnd));

        XWPFRun firstRun = runs.get(0);
        Boolean bold = firstRun.isBold();
        Boolean italic = firstRun.isItalic();
        String fontFamily = firstRun.getFontFamily();
        int fontSize = firstRun.getFontSize();
        String color = firstRun.getColor();
        UnderlinePatterns underline = firstRun.getUnderline();

        int runCount = runs.size();
        for (int i = runCount - 1; i >= 0; i--) {
            paragraph.removeRun(i);
        }

        XWPFRun newRun = paragraph.createRun();
        newRun.setText(replaced.toString());
        newRun.setBold(bold != null && bold);
        newRun.setItalic(italic != null && italic);
        if (fontFamily != null) {
            newRun.setFontFamily(fontFamily);
        }
        if (fontSize > 0) {
            newRun.setFontSize(fontSize);
        }
        if (color != null) {
            newRun.setColor(color);
        }
        if (underline != null) {
            newRun.setUnderline(underline);
        }
    }

    private void addQrCodeToFooter(XWPFDocument document, String qrContent) {
        byte[] qrImageBytes = qrCodeGenerator.generate(qrContent);

        XWPFHeaderFooterPolicy policy = document.getHeaderFooterPolicy();
        if (policy == null) {
            policy = document.createHeaderFooterPolicy();
        }

        XWPFFooter footer = policy.getDefaultFooter();
        if (footer == null) {
            footer = policy.createFooter(XWPFHeaderFooterPolicy.DEFAULT);
        }

        XWPFParagraph qrParagraph = footer.createParagraph();
        qrParagraph.setAlignment(ParagraphAlignment.CENTER);

        XWPFRun run = qrParagraph.createRun();
        try (ByteArrayInputStream imageStream = new ByteArrayInputStream(qrImageBytes)) {
            run.addPicture(imageStream, XWPFDocument.PICTURE_TYPE_PNG, "qr.png", QR_SIZE_EMU, QR_SIZE_EMU);
        } catch (IOException | InvalidFormatException e) {
            throw new ServiceException(ExceptionStarterErrorCodes.INTERNAL_SERVER_ERROR, 500, e);
        }
    }
}