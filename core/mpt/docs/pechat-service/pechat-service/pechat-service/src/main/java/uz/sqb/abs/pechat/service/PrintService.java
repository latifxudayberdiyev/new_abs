package uz.sqb.abs.pechat.service;

import org.springframework.web.multipart.MultipartFile;

public interface PrintService {
    byte[] generate(MultipartFile file, String data);

    byte[] generateWithId(String id, String data);

    MultipartFile convertToMultipartFile(byte[] fileBytes);
}
