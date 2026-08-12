package uz.sqb.abs.pechat;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean;
import org.springframework.boot.context.properties.ConfigurationPropertiesScan;
import org.springframework.context.annotation.Bean;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.annotation.EnableScheduling;
import uz.sqb.abs.pechat.property.ErrorCodeProperties;
import uz.sqb.abs.pechat.service.DefaultErrorMessageService;
import uz.sqb.abs.pechat.service.ErrorMessageService;
import uz.sqb.abs.pechat.util.CacheUtil;

@ConfigurationPropertiesScan
@SpringBootApplication
@EnableScheduling
public class PechatServiceApplication {

	public static void main(String[] args) {
		SpringApplication.run(PechatServiceApplication.class, args);
	}

    @Bean
    @ConditionalOnMissingBean(ErrorMessageService.class)
    public ErrorMessageService defaultErrorMessageService(
            CacheUtil cacheUtil, ErrorCodeProperties errorCodeProperties) {
        return new DefaultErrorMessageService(cacheUtil, errorCodeProperties);
    }

}
