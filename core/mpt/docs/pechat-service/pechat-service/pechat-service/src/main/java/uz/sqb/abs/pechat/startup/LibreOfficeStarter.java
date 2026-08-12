package uz.sqb.abs.pechat.startup;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.ApplicationListener;
import org.springframework.stereotype.Component;

@Component
@Slf4j
public class LibreOfficeStarter implements ApplicationListener<ApplicationReadyEvent> {

    @Value("${external.libreoffice.path-start}")
    private String sofficePath;

    @Value("${external.libreoffice.port}")
    private int port;

    @Override
    public void onApplicationEvent(ApplicationReadyEvent event) {
        try {
            ProcessBuilder pb = new ProcessBuilder(
                sofficePath,
                "--headless",
                "--accept=socket,host=127.0.0.1,port=" + port + ";urp;",
                "--nofirststartwizard",
                "--nologo",
                "--nocrashreport",
                "--norestore"
            );
            pb.redirectErrorStream(true);
            pb.start();
            log.info("LibreOffice headless service started on port {}", port);
        } catch (Exception e) {
            log.error("Failed to start LibreOffice headless service", e);
        }
    }
}