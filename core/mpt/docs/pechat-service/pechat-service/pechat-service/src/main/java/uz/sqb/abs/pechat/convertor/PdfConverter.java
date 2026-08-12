package uz.sqb.abs.pechat.convertor;
/*

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import uz.sqb.abs.pechat.constant.ExceptionStarterErrorCodes;
import uz.sqb.abs.pechat.exceptions.ServiceException;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

@Component
public class PdfConverter {

    private final String sofficePath;
    private final Path tempDir;

    public PdfConverter(
            @Value("${external.libreoffice.path:soffice}") String sofficePath,
            @Value("${external.libreoffice.temp-dir:${java.io.tmpdir}}") String tempDirPath) {
        this.sofficePath = sofficePath;
        this.tempDir = Path.of(tempDirPath);
    }

    public byte[] convertToPdf(byte[] fileBytes, String sourceExtension) {
        String uniqueId = UUID.randomUUID().toString();
        Path inputFile = tempDir.resolve(uniqueId + "." + sourceExtension);
        Path expectedPdfFile = tempDir.resolve(uniqueId + ".pdf");

        try {
            Files.write(inputFile, fileBytes);

            runSofficeConversion(inputFile);

            if (!Files.exists(expectedPdfFile)) {
                throw new ServiceException(ExceptionStarterErrorCodes.EXTERNAL_SERVICE_ERROR, 500,
                        (Throwable) null, "PDF conversion produced no output file");
            }

            return Files.readAllBytes(expectedPdfFile);

        } catch (IOException e) {
            throw new ServiceException(ExceptionStarterErrorCodes.EXTERNAL_SERVICE_ERROR, 500, e);
        } finally {
            deleteQuietly(inputFile);
            deleteQuietly(expectedPdfFile);
        }
    }

    private void runSofficeConversion(Path inputFile) {
        List<String> command = List.of(
                sofficePath,
                "--headless",
                "--convert-to", "pdf",
                "--outdir", tempDir.toString(),
                inputFile.toString()
        );

        try {
            Process process = new ProcessBuilder(command)
                    .redirectErrorStream(true)
                    .start();

            boolean finished = process.waitFor(60, TimeUnit.SECONDS);

            if (!finished) {
                process.destroyForcibly();
                throw new ServiceException(ExceptionStarterErrorCodes.EXTERNAL_SERVICE_ERROR, 504,
                        (Throwable) null, "PDF conversion timed out");
            }

            if (process.exitValue() != 0) {
                String output = new String(process.getInputStream().readAllBytes());
                throw new ServiceException(ExceptionStarterErrorCodes.EXTERNAL_SERVICE_ERROR, 500,
                        (Throwable) null, "LibreOffice exited with code " + process.exitValue() + ": " + output);
            }

        } catch (IOException e) {
            throw new ServiceException(ExceptionStarterErrorCodes.EXTERNAL_SERVICE_ERROR, 500, e);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new ServiceException(ExceptionStarterErrorCodes.EXTERNAL_SERVICE_ERROR, 500, e);
        }
    }

    private void deleteQuietly(Path path) {
        try {
            Files.deleteIfExists(path);
        } catch (IOException ignored) {

        }
    }
}*/

import lombok.RequiredArgsConstructor;
import org.jodconverter.core.office.OfficeManager;
import org.jodconverter.local.LocalConverter;
import org.springframework.stereotype.Component;
import uz.sqb.abs.pechat.constant.ExceptionStarterErrorCodes;
import uz.sqb.abs.pechat.exceptions.ServiceException;
import uz.sqb.abs.pechat.util.LibreOfficeManager;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;

@Component
@RequiredArgsConstructor
public class PdfConverter {

    private final LibreOfficeManager libreOfficeManager;

    public byte[] convertToPdf(byte[] fileBytes, String sourceExtension) {
        OfficeManager officeManager = libreOfficeManager.getOfficeManager();

        try (ByteArrayInputStream inputStream = new ByteArrayInputStream(fileBytes);
             ByteArrayOutputStream outputStream = new ByteArrayOutputStream()) {

            LocalConverter.make(officeManager)
                    .convert(inputStream)
                    .as(org.jodconverter.core.document.DefaultDocumentFormatRegistry
                            .getFormatByExtension(sourceExtension))
                    .to(outputStream)
                    .as(org.jodconverter.core.document.DefaultDocumentFormatRegistry.PDF)
                    .execute();

            return outputStream.toByteArray();

        } catch (Exception e) {
            throw new ServiceException(ExceptionStarterErrorCodes.EXTERNAL_SERVICE_ERROR, 500, e);
        }
    }
}
