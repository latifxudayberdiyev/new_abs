package uz.sqb.abs.pechat.service.file_service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatusCode;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;
import uz.sqb.abs.pechat.constant.ExceptionStarterErrorCodes;
import uz.sqb.abs.pechat.exceptions.ExternalServiceException;
import uz.sqb.abs.pechat.exceptions.ServiceException;
import uz.sqb.abs.pechat.payload.auth.AuthLoginRequest;
import uz.sqb.abs.pechat.payload.auth.AuthResponse;
import uz.sqb.abs.pechat.payload.base.BaseResponse;
import uz.sqb.abs.pechat.payload.file.DownloadLinkResponse;
import uz.sqb.abs.pechat.payload.file.FileGenerateLinkRequest;
import uz.sqb.abs.pechat.util.CacheUtil;

import java.net.URI;
import java.time.Duration;
import java.util.Optional;
import java.util.UUID;

@Service
public class FileServiceImpl implements FileService {

    private static final String TOKEN_CACHE_PREFIX = "pechat:token";
    private static final String TOKEN_CACHE_KEY = "access-token";
    private static final String FILE_NOT_FOUND_CACHE_PREFIX = "pechat:not-found";
    private static final Duration FILE_NOT_FOUND_TTL = Duration.ofSeconds(30);

    private final WebClient webClient;
    private final CacheUtil cacheUtil;
    private final Duration tokenTtl;

    @Value("${external.new-abs.username}")
    private String username;

    @Value("${external.new-abs.password}")
    private String password;

    public FileServiceImpl(
            WebClient.Builder webClient,
            CacheUtil cacheUtil,
            @Value("${external.new-abs.base-url}") String baseUrl,
            @Value("${external.new-abs.token-ttl-seconds:900}") long tokenTtlSeconds) {
        this.webClient = webClient
                .baseUrl(baseUrl)
                .build();
        this.cacheUtil = cacheUtil;
        this.tokenTtl = Duration.ofSeconds(tokenTtlSeconds);
    }

    @Override
    public byte[] getFileById(String id) {
        Optional<Boolean> cachedNotFound = cacheUtil.get(FILE_NOT_FOUND_CACHE_PREFIX, id, Boolean.class);
        if (cachedNotFound.isPresent()) {
            throw new ServiceException(ExceptionStarterErrorCodes.FILE_NOT_FOUND, 404, (Throwable) null, id);
        }

        String token = login();

        String cleaned = id.trim().replaceAll("^\"|\"$", "");

        UUID fileId;
        try {
            fileId = UUID.fromString(cleaned);
        } catch (IllegalArgumentException e) {
            throw new ServiceException(ExceptionStarterErrorCodes.INVALID_INPUT, 400, e, cleaned);
        }



        FileGenerateLinkRequest requestBody = new FileGenerateLinkRequest(fileId, 60);

        DownloadLinkResponse response;
        try {
            response = webClient.post()
                    .uri("/api/v1/file/generate-link")
                    .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                    .bodyValue(requestBody)
                    .retrieve()
                    .onStatus(status -> status.value() == 401, res ->
                            Mono.error(new IllegalStateException("Unauthorized: token is missing or invalid")))
                    .onStatus(status -> status.value() == 404, res ->
                            Mono.error(new ServiceException(
                                    ExceptionStarterErrorCodes.FILE_NOT_FOUND,
                                    404, (Throwable) null, id)))
                    .onStatus(HttpStatusCode::is4xxClientError, res ->
                            res.bodyToMono(String.class).flatMap(body ->
                                    Mono.error(new ExternalServiceException(
                                            ExceptionStarterErrorCodes.EXTERNAL_SERVICE_ERROR, 400,
                                            "File-service rejected the request", body))))
                    .onStatus(HttpStatusCode::is5xxServerError, res ->
                            res.bodyToMono(String.class).flatMap(body ->
                                    Mono.error(new ExternalServiceException(
                                            ExceptionStarterErrorCodes.EXTERNAL_SERVICE_ERROR, 502,
                                            "File-service returned a server error", body))))
                    .bodyToMono(DownloadLinkResponse.class)
                    .timeout(Duration.ofSeconds(10))
                    .block();
        } catch (ServiceException e) {
            cacheUtil.setWithDuration(FILE_NOT_FOUND_CACHE_PREFIX, id, true, FILE_NOT_FOUND_TTL);
            throw e;
        }

        if (response == null || response.data() == null || response.data().url() == null
                || response.data().url().isBlank()) {
            throw new IllegalStateException("Download link is empty for file id: " + id);
        }

        URI uri = URI.create(response.data().url());

        return webClient.get()
                .uri(uri)
                .retrieve()
                .onStatus(HttpStatusCode::isError, res ->
                        res.bodyToMono(String.class).flatMap(body ->
                                Mono.error(new ExternalServiceException(
                                        ExceptionStarterErrorCodes.EXTERNAL_SERVICE_ERROR, 502,
                                        "Failed to download file from storage", body))))
                .bodyToMono(byte[].class)
                .timeout(Duration.ofSeconds(30))
                .block();
    }

    @Override
    public String login() {
        Optional<String> cachedToken = cacheUtil.get(TOKEN_CACHE_PREFIX, TOKEN_CACHE_KEY, String.class);
        if (cachedToken.isPresent()) {
            return cachedToken.get();
        }

        String freshToken = performLogin();

        cacheUtil.setWithDuration(TOKEN_CACHE_PREFIX, TOKEN_CACHE_KEY, freshToken, tokenTtl);

        return freshToken;
    }


    @Override
    public String refreshToken() {
        String freshToken = performLogin();
        cacheUtil.setWithDuration(TOKEN_CACHE_PREFIX, TOKEN_CACHE_KEY, freshToken, tokenTtl);
        return freshToken;
    }

    private String performLogin() {
        AuthLoginRequest request = new AuthLoginRequest(username, password);

        BaseResponse<AuthResponse> response = webClient.post()
                .uri("/api/v1/auth/login")
                .bodyValue(request)
                .retrieve()
                .onStatus(status -> status.value() == 401, res ->
                        Mono.error(new IllegalStateException("Invalid username or password")))
                .onStatus(HttpStatusCode::is4xxClientError, res ->
                        res.bodyToMono(String.class).flatMap(body ->
                                Mono.error(new ExternalServiceException(
                                        ExceptionStarterErrorCodes.EXTERNAL_SERVICE_ERROR, 400,
                                        "Auth service rejected the login request", body))))
                .onStatus(HttpStatusCode::is5xxServerError, res ->
                        res.bodyToMono(String.class).flatMap(body ->
                                Mono.error(new ExternalServiceException(
                                        ExceptionStarterErrorCodes.EXTERNAL_SERVICE_ERROR, 502,
                                        "Auth service returned a server error", body))))
                .bodyToMono(new ParameterizedTypeReference<BaseResponse<AuthResponse>>() {
                })
                .timeout(Duration.ofSeconds(10))
                .block();

        if (response == null || !response.success() || response.data() == null) {
            throw new IllegalStateException("Login failed: no token received");
        }

        String token = response.data().accessToken();
        if (token == null || token.isBlank()) {
            throw new IllegalStateException("Login succeeded but token is empty");
        }

        return token;
    }
}