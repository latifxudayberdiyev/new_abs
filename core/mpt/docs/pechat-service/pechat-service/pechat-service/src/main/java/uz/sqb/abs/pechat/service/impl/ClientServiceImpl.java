package uz.sqb.abs.pechat.service.impl;

import com.auth0.jwt.exceptions.JWTVerificationException;
import com.auth0.jwt.interfaces.DecodedJWT;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.stereotype.Service;
import uz.sqb.abs.pechat.configuration.security.SecurityUserDetails;
import uz.sqb.abs.pechat.configuration.security.jwt.JwtUtil;
import uz.sqb.abs.pechat.constant.ExceptionStarterErrorCodes;
import uz.sqb.abs.pechat.domain.Client;
import uz.sqb.abs.pechat.exceptions.ServiceException;
import uz.sqb.abs.pechat.payload.auth.AuthLoginRequest;
import uz.sqb.abs.pechat.payload.auth.AuthRefreshTokenRequest;
import uz.sqb.abs.pechat.payload.auth.AuthResponse;
import uz.sqb.abs.pechat.repository.ClientRepository;
import uz.sqb.abs.pechat.service.ClientService;
import uz.sqb.abs.pechat.validator.ClientServiceValidator;


import java.time.LocalDateTime;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ClientServiceImpl implements ClientService {
    private final JwtUtil jwtUtil;
    private final ClientRepository clientRepository;
    private final AuthenticationManager authenticationManager;

    @Override
    public AuthResponse login(AuthLoginRequest requestBody) {
        ClientServiceValidator.isValidRequest(requestBody);
        try {
            UsernamePasswordAuthenticationToken usernamePasswordAuthenticationToken =
                    new UsernamePasswordAuthenticationToken(requestBody.username(), requestBody.password());
            Authentication authentication = authenticationManager.authenticate(usernamePasswordAuthenticationToken);
            if (authentication.isAuthenticated() && authentication.getPrincipal() instanceof SecurityUserDetails client) {
                Map<String, Object> claims = Map.of(
                        "clientId", client.clientId(),
                        "authorities", client.getAuthorities()
                                .stream()
                                .map(GrantedAuthority::getAuthority)
                                .toArray(String[]::new)
                );
                String accessToken = jwtUtil.generateAccessToken(client.id(), claims);
                String refreshToken = jwtUtil.generateRefreshToken(client.id());
                clientRepository.updateLastUpdatedAt(UUID.fromString(client.id()), LocalDateTime.now());
                return new AuthResponse(accessToken, refreshToken);
            }
            throw new ServiceException(ExceptionStarterErrorCodes.UNAUTHORIZED, 401, null);
        } catch (Exception e) {
            throw new ServiceException(ExceptionStarterErrorCodes.UNAUTHORIZED, 401, e);
        }
    }

    @Override
    public AuthResponse refreshToken(AuthRefreshTokenRequest requestBody) {
        try {
            ClientServiceValidator.isValidRequest(requestBody);
            DecodedJWT decodedJWT = jwtUtil.getDecodedJWT(requestBody.refreshToken());
            String subject = decodedJWT.getSubject();
            Client client = clientRepository.findById(UUID.fromString(subject))
                    .orElseThrow(() -> new ServiceException(ExceptionStarterErrorCodes.UNAUTHORIZED, 401, null));

            Map<String, Object> claims = Map.of(
                    "clientId", client.getClientId(),
                    "authorities", client.getRoles().toArray(String[]::new)
            );

            String accessToken = jwtUtil.generateAccessToken(String.valueOf(client.getId()), claims);
            client.setLastLoginAt(LocalDateTime.now());
            clientRepository.save(client);
            return new AuthResponse(accessToken, requestBody.refreshToken());
        } catch (JWTVerificationException e) {
            throw new ServiceException(ExceptionStarterErrorCodes.UNAUTHORIZED, 401, e);
        }
    }

}
