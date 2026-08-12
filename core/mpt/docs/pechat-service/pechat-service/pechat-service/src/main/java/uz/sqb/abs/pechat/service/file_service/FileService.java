package uz.sqb.abs.pechat.service.file_service;

public interface FileService {

    byte[] getFileById(String id);

    String login();

    String refreshToken();
}
