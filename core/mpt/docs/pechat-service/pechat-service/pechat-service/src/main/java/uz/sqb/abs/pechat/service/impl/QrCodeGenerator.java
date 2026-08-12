package uz.sqb.abs.pechat.service.impl;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.EncodeHintType;
import com.google.zxing.WriterException;
import com.google.zxing.client.j2se.MatrixToImageWriter;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.QRCodeWriter;
import com.google.zxing.qrcode.decoder.ErrorCorrectionLevel;
import org.springframework.stereotype.Component;
import uz.sqb.abs.pechat.constant.ExceptionStarterErrorCodes;
import uz.sqb.abs.pechat.exceptions.ServiceException;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.EnumMap;
import java.util.Map;

@Component
public class QrCodeGenerator {

    private static final int DEFAULT_SIZE = 300; // piksel, kvadrat (300x300)

    public byte[] generate(String content) {
        return generate(content, DEFAULT_SIZE);
    }

    public byte[] generate(String content, int size) {
        if (content == null || content.isBlank()) {
            throw new ServiceException(ExceptionStarterErrorCodes.INVALID_INPUT, 400,
                    (Throwable) null, "QR code content is empty");
        }

        try {
            Map<EncodeHintType, Object> hints = new EnumMap<>(EncodeHintType.class);
            hints.put(EncodeHintType.ERROR_CORRECTION, ErrorCorrectionLevel.M);
            hints.put(EncodeHintType.MARGIN, 1);
            hints.put(EncodeHintType.CHARACTER_SET, "UTF-8");

            QRCodeWriter writer = new QRCodeWriter();
            BitMatrix matrix = writer.encode(content, BarcodeFormat.QR_CODE, size, size, hints);

            ByteArrayOutputStream out = new ByteArrayOutputStream();
            MatrixToImageWriter.writeToStream(matrix, "PNG", out);
            return out.toByteArray();

        } catch (WriterException | IOException e) {
            throw new ServiceException(ExceptionStarterErrorCodes.INTERNAL_SERVER_ERROR, 500, e);
        }
    }
}