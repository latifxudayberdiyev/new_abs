package uz.sqb.abs.pechat.startup;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import uz.sqb.abs.pechat.service.file_service.FileService;

@Slf4j
@Component
@RequiredArgsConstructor
public class TokenWarmUpRunner {

    private final FileService fileService;

    @Scheduled(fixedRateString = "${external.new-abs.token-refresh-interval-ms}")
    public void refreshTokenPeriodically() {
        try {
            log.info("Scheduled refresh: forcing fresh login...");
            fileService.refreshToken();
            log.info("Scheduled refresh: auth token successfully refreshed");
        } catch (Exception e) {
            log.warn("Scheduled refresh: could not refresh auth token, cache will expire naturally " +
                    "and next real request will re-login. Reason: {}", e.getMessage());
        }
    }
}