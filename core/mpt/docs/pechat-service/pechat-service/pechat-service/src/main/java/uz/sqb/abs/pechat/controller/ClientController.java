package uz.sqb.abs.pechat.controller;


import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import uz.sqb.abs.pechat.payload.auth.AuthLoginRequest;
import uz.sqb.abs.pechat.payload.auth.AuthRefreshTokenRequest;
import uz.sqb.abs.pechat.payload.auth.AuthResponse;
import uz.sqb.abs.pechat.payload.base.BaseResponse;
import uz.sqb.abs.pechat.service.ClientService;


@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
public class ClientController {

    private final ClientService clientService;

    @PostMapping("/login")
    public BaseResponse<AuthResponse> login(@RequestBody AuthLoginRequest requestBody) {
        AuthResponse response = clientService.login(requestBody);
        return BaseResponse.ok(response);   
    }

    @PostMapping("/refresh-token")
    public BaseResponse<AuthResponse> refreshToken(@Valid @RequestBody AuthRefreshTokenRequest requestBody) {
        AuthResponse response = clientService.refreshToken(requestBody);
        return BaseResponse.ok(response);
    }
}
