package uz.sqb.abs.pechat.service;


import uz.sqb.abs.pechat.payload.auth.AuthLoginRequest;
import uz.sqb.abs.pechat.payload.auth.AuthRefreshTokenRequest;
import uz.sqb.abs.pechat.payload.auth.AuthResponse;

public interface ClientService {

    AuthResponse login(AuthLoginRequest requestBody);

    AuthResponse refreshToken(AuthRefreshTokenRequest requestBody);
}
