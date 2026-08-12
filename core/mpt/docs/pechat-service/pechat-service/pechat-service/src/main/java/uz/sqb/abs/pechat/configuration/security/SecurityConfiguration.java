package uz.sqb.abs.pechat.configuration.security;

import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import uz.sqb.abs.pechat.configuration.security.jwt.JwtAuthenticationFilter;
import uz.sqb.abs.pechat.configuration.security.jwt.JwtUtil;
import uz.sqb.abs.pechat.payload.util.HttpHeaderUtil;
import uz.sqb.abs.pechat.property.AuthorizationProperties;
import uz.sqb.abs.pechat.property.CorsProperties;
import uz.sqb.abs.pechat.property.ErrorCodeProperties;
import uz.sqb.abs.pechat.service.ErrorMessageService;


@Configuration(proxyBeanMethods = false)
@RequiredArgsConstructor
@EnableWebSecurity
@EnableMethodSecurity
public class SecurityConfiguration {

    private final CorsProperties corsProperties;
    private final ObjectMapper objectMapper;
    private final ErrorCodeProperties errorCodeProperties;
    private final AuthorizationProperties authorizationProperties;
    private final HttpHeaderUtil httpHeaderUtil;
    private final ErrorMessageService errorMessageService;
    private final JwtUtil jwtUtil;


    @Bean
    public SecurityFilterChain defaultSecurityFilterChain(HttpSecurity http) throws Exception {
        http.csrf(AbstractHttpConfigurer::disable);
        http.sessionManagement(sessionManagement -> sessionManagement
                .sessionCreationPolicy(SessionCreationPolicy.STATELESS));

        //cors configuration
        var corsConfig = new CorsConfiguration();
        corsConfig.setAllowedHeaders(corsProperties.getAllowedHeaders());
        corsConfig.setAllowedOrigins(corsProperties.getAllowedOrigins());
        corsConfig.setAllowedMethods(corsProperties.getAllowedMethods());
        corsConfig.setAllowCredentials(corsProperties.isAllowCredentials());
        corsConfig.setExposedHeaders(corsProperties.getExposedHeaders());
        var source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration(corsProperties.getUrlPattern(), corsConfig);
        http.cors(cors -> cors.configurationSource(source));

        //permit all patterns
        http.authorizeHttpRequests(
                httpReq -> httpReq
                        .requestMatchers(authorizationProperties.getRequestMatchers())
                        .permitAll()
                        .anyRequest()
                        .authenticated());


        //auth entry point
        var authEntryPoint = new CustomAuthenticationEntryPoint(objectMapper, errorMessageService, httpHeaderUtil, errorCodeProperties);
        var accessDeniedHandler = new CustomAccessDeniedHandler(objectMapper, errorMessageService, httpHeaderUtil, errorCodeProperties);

        //registering one per request filter which works before default username password authentication filter
        http.addFilterBefore(new JwtAuthenticationFilter(jwtUtil), UsernamePasswordAuthenticationFilter.class)
                .formLogin(AbstractHttpConfigurer::disable)
                .httpBasic(AbstractHttpConfigurer::disable);


        http.exceptionHandling(exceptionHandlingConfigurer ->
                exceptionHandlingConfigurer.authenticationEntryPoint(authEntryPoint)
                        .accessDeniedHandler(accessDeniedHandler));

        return http.build();
    }


    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder(10);
    }

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration config) throws Exception {
        return config.getAuthenticationManager();
    }

}
