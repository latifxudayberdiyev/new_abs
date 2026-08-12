package uz.sqb.abs.pechat.util;

import jakarta.annotation.PreDestroy;
import org.jodconverter.core.office.OfficeException;
import org.jodconverter.core.office.OfficeManager;
import org.jodconverter.local.office.LocalOfficeManager;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;

@Component
public class LibreOfficeManager {

    private OfficeManager officeManager;

    @Value("${external.libreoffice.path:soffice}")
    private String sofficePath;

    @EventListener(ApplicationReadyEvent.class)
    public void start() throws OfficeException {
        officeManager = LocalOfficeManager.builder()
                .officeHome(sofficePath)
                .portNumbers(2002)
                .install()
                .build();
        officeManager.start();
    }

    @PreDestroy
    public void stop() throws OfficeException {
        if (officeManager != null) {
            officeManager.stop();
        }
    }

    public OfficeManager getOfficeManager() {
        return officeManager;
    }
}