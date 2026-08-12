package uz.sqb.abs.pechat.service.impl;

import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellType;
import org.apache.poi.ss.usermodel.ClientAnchor;
import org.apache.poi.ss.usermodel.CreationHelper;
import org.apache.poi.ss.usermodel.Drawing;
import org.apache.poi.ss.usermodel.FormulaEvaluator;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.ss.util.CellReference;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.stereotype.Component;
import uz.sqb.abs.pechat.constant.ExceptionStarterErrorCodes;
import uz.sqb.abs.pechat.exceptions.ServiceException;
import uz.sqb.abs.pechat.service.ExcelTemplateEngine;


import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Component
public class ExcelTemplateEngineImpl implements ExcelTemplateEngine {

    private static final Pattern VARIABLE_PATTERN = Pattern.compile("\\[([a-zA-Z][a-zA-Z0-9_]*)\\]");

    private static final String QR_CODE_VARIABLE = "qr_code";
    private static final int QR_ANCHOR_COLUMN = 2; // QR kod boshlanadigan ustun
    private static final int QR_ANCHOR_WIDTH_COLS = 2; // nechta ustunni egallaydi
    private static final int QR_ANCHOR_HEIGHT_ROWS = 7; // nechta qatorni egallaydi
    private static final int QR_ROW_GAP = 2; // oxirgi ma'lumotli qatordan nechta qator pastda boshlanadi

    private final QrCodeGenerator qrCodeGenerator;

    public ExcelTemplateEngineImpl(QrCodeGenerator qrCodeGenerator) {
        this.qrCodeGenerator = qrCodeGenerator;
    }

    @Override
    public byte[] fillTemplate(InputStream templateStream, Map<String, String> values) {
        try (XSSFWorkbook workbook = new XSSFWorkbook(templateStream)) {

            for (int sheetIndex = 0; sheetIndex < workbook.getNumberOfSheets(); sheetIndex++) {
                XSSFSheet sheet = workbook.getSheetAt(sheetIndex);
                processSheet(sheet, values);
            }

            // Placeholder'lar almashtirilgandan keyin, formulalarni qayta hisoblatamiz
            FormulaEvaluator evaluator = workbook.getCreationHelper().createFormulaEvaluator();
            evaluator.evaluateAll();

            // QR kod - agar berilgan bo'lsa, har bir sheet'da [qr_code]
            // deb belgilangan (shablon tuzuvchisi ataylab qoldirgan) har
            // bir katakka qo'yiladi
            if (values.containsKey(QR_CODE_VARIABLE)) {
                for (int sheetIndex = 0; sheetIndex < workbook.getNumberOfSheets(); sheetIndex++) {
                    XSSFSheet sheet = workbook.getSheetAt(sheetIndex);
                    processQrCodePlaceholders(sheet, values.get(QR_CODE_VARIABLE), workbook);
                }
            }

            ByteArrayOutputStream out = new ByteArrayOutputStream();
            workbook.write(out);
            return out.toByteArray();

        } catch (IOException e) {
            throw new RuntimeException("Excel faylni o'qish/yozishda xatolik: " + e.getMessage(), e);
        } catch (Exception e) {
            throw new RuntimeException("Fayl Excel formatida emas yoki buzilgan: " + e.getMessage(), e);
        }
    }

    public byte[] fillByCellReference(InputStream templateStream, Map<String, String> cellValues) {
        try (XSSFWorkbook workbook = new XSSFWorkbook(templateStream)) {
            XSSFSheet sheet = workbook.getSheetAt(0);

            for (Map.Entry<String, String> entry : cellValues.entrySet()) {
                String reference = entry.getKey().trim();
                String value = entry.getValue();

                if (reference.contains(":")) {
                    writeToRange(sheet, reference, value);
                } else {
                    writeToSingleCell(sheet, reference, value);
                }
            }

            FormulaEvaluator evaluator = workbook.getCreationHelper().createFormulaEvaluator();
            evaluator.evaluateAll();

            ByteArrayOutputStream out = new ByteArrayOutputStream();
            workbook.write(out);
            return out.toByteArray();

        } catch (IOException e) {
            throw new RuntimeException("Excel faylni o'qish/yozishda xatolik: " + e.getMessage(), e);
        } catch (Exception e) {
            throw new RuntimeException("Fayl Excel formatida emas yoki buzilgan: " + e.getMessage(), e);
        }
    }

    private void writeToSingleCell(XSSFSheet sheet, String reference, String value) {
        CellReference cellRef;
        try {
            cellRef = new CellReference(reference);
        } catch (Exception e) {
            throw new ServiceException(ExceptionStarterErrorCodes.INVALID_INPUT, 400, e, reference);
        }

        Row row = sheet.getRow(cellRef.getRow());
        if (row == null) {
            row = sheet.createRow(cellRef.getRow());
        }

        Cell cell = row.getCell(cellRef.getCol());
        if (cell == null) {
            cell = row.createCell(cellRef.getCol());
        }

        cell.setBlank();
        cell.setCellValue(value);
    }


    private void writeToRange(XSSFSheet sheet, String rangeReference, String value) {
        CellRangeAddress range;
        try {
            range = CellRangeAddress.valueOf(rangeReference);
        } catch (Exception e) {
            throw new ServiceException(ExceptionStarterErrorCodes.INVALID_INPUT, 400, e, rangeReference);
        }

        for (int rowIdx = range.getFirstRow(); rowIdx <= range.getLastRow(); rowIdx++) {
            Row row = sheet.getRow(rowIdx);
            if (row == null) {
                row = sheet.createRow(rowIdx);
            }
            for (int colIdx = range.getFirstColumn(); colIdx <= range.getLastColumn(); colIdx++) {
                Cell cell = row.getCell(colIdx);
                if (cell == null) {
                    cell = row.createCell(colIdx);
                }
                cell.setBlank();
                cell.setCellValue(value);
            }
        }
    }


    private void processSheet(XSSFSheet sheet, Map<String, String> values) {
        for (Row row : sheet) {
            for (Cell cell : row) {
                replaceInCell(cell, values);
            }
        }
    }


    private void replaceInCell(Cell cell, Map<String, String> values) {
        if (cell.getCellType() != CellType.STRING) {
            return;
        }

        String original = cell.getStringCellValue();
        Matcher matcher = VARIABLE_PATTERN.matcher(original);
        if (!matcher.find()) {
            return; // bu katakda variable yo'q
        }

        matcher.reset();
        StringBuilder replaced = new StringBuilder();
        int lastEnd = 0;
        boolean isPureQrPlaceholder = original.trim().equals("[" + QR_CODE_VARIABLE + "]");
        while (matcher.find()) {
            replaced.append(original, lastEnd, matcher.start());
            String varName = matcher.group(1);
            if (varName.equals(QR_CODE_VARIABLE) && isPureQrPlaceholder) {
                // Bu katak QR uchun ATAYLAB qoldirilgan - matn sifatida
                // ALMASHTIRILMAYDI, keyinroq rasm bilan to'ldiriladi
                replaced.append(matcher.group());
                lastEnd = matcher.end();
                continue;
            }
            // Word'dan farqi: topilmasa BO'SH STRING qo'yiladi, placeholder emas
            String value = values.getOrDefault(varName, "");
            replaced.append(value);
            lastEnd = matcher.end();
        }
        replaced.append(original.substring(lastEnd));

        if (isPureQrPlaceholder) {
            return; // katak o'zgarishsiz qoldi - QR qo'yish bosqichi buni topadi
        }

        // setBlank() - "inline string" formatida saqlangan (masalan Excel'dan
        // boshqa tashqi vositada yaratilgan) kataklarda eski qiymat qoldiq
        // bo'lib qolmasligi uchun, cell'ni to'liq tozalab keyin yozamiz.
        cell.setBlank();
        cell.setCellValue(replaced.toString());
    }


    private void processQrCodePlaceholders(XSSFSheet sheet, String qrContent, Workbook workbook) {
        boolean foundExplicitPlaceholder = false;

        for (Row row : sheet) {
            for (Cell cell : row) {
                if (cell.getCellType() != CellType.STRING) {
                    continue;
                }
                if (cell.getStringCellValue().trim().equals("[" + QR_CODE_VARIABLE + "]")) {
                    cell.setBlank();
                    insertQrAt(sheet, cell.getRowIndex(), cell.getColumnIndex(), qrContent, workbook);
                    foundExplicitPlaceholder = true;
                }
            }
        }

        // Orqaga moslik: eski shablonlarda hech qanday [qr_code] katak
        // yo'q bo'lsa, avvalgidek - sheet oxiriga bitta marta qo'yiladi
        if (!foundExplicitPlaceholder) {
            int lastRow = sheet.getLastRowNum();
            insertQrAt(sheet, lastRow + QR_ROW_GAP, QR_ANCHOR_COLUMN, qrContent, workbook);
        }
    }

    private void insertQrAt(XSSFSheet sheet, int rowIndex, int colIndex, String qrContent, Workbook workbook) {
        byte[] qrImageBytes = qrCodeGenerator.generate(qrContent);
        int pictureIdx = workbook.addPicture(qrImageBytes, Workbook.PICTURE_TYPE_PNG);

        CreationHelper helper = workbook.getCreationHelper();
        Drawing<?> drawing = sheet.createDrawingPatriarch();
        ClientAnchor anchor = helper.createClientAnchor();

        anchor.setCol1(colIndex);
        anchor.setRow1(rowIndex);
        anchor.setCol2(colIndex + QR_ANCHOR_WIDTH_COLS);
        anchor.setRow2(rowIndex + QR_ANCHOR_HEIGHT_ROWS);

        drawing.createPicture(anchor, pictureIdx);
    }
}