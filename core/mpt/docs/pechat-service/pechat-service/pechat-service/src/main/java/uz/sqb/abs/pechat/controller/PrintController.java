package uz.sqb.abs.pechat.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import uz.sqb.abs.pechat.service.PrintService;

@RestController
@RequestMapping("/api/v1/print")
@RequiredArgsConstructor
public class PrintController {

    private final PrintService printService;


    @PostMapping(value = "/generate", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<?> generate(@RequestParam("file") MultipartFile file, @RequestParam("data") String data) {
        byte[] result = printService.generate(file, data);

        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_PDF)
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"generated.pdf\"")
                .body(result);
    }


    @PostMapping(value = "/generate-with-id/{id}", consumes = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<?> generateWithId(@PathVariable String id, @RequestBody String data) {
        byte[] result = printService.generateWithId(id, data);

        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_PDF)
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"generated.pdf\"")
                .body(result);
    }

}
