package uz.sqb.abs.pechat.payload.file;

public record DownloadLinkResponse(FileUrlData data,boolean success) {
    public record FileUrlData(String url) {}
}
