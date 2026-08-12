package uz.sqb.abs.pechat.payload.file;

import java.util.UUID;

public record FileGenerateLinkRequest(UUID fileId,Integer expiresIn) {
}
