<%@ page contentType="text/html;charset=WINDOWS-1251" language="java" %>
<%@ page import="java.io.*, java.net.*, java.util.*" %>
<%@ page import="javax.servlet.http.HttpServletResponse" %>
<%@ page import="uz.fido_biznes.cms.*" %>
<%@ page import="uz.sqb.abs.fileclient.FileServiceClient" %>
<%@ page import="uz.sqb.abs.fileclient.config.FileServiceClientFactory" %>
<%@ page import="uz.sqb.abs.fileclient.dto.BaseResponse" %>
<%@ page import="uz.sqb.abs.fileclient.dto.FileGenerateLinkResponse" %>
<%@ page import="uz.sqb.abs.fileclient.dto.ErrorData" %>
<jsp:useBean id="user" class="iabs.User" scope="session" />
<%
	Language lang = new Language(user.getLanguageIndex(), sentences);
	String fileId = request.getParameter("file_id");
	String fileName = request.getParameter("file_name");
	String errorMessage = null;

	if (user.getUserCode() == null) {
		errorMessage = "Session expired";
	} else if (fileId == null || fileId.equals("")) {
		errorMessage = lang.get(si_no_file);
	} else {
		try {
			Properties props = new Properties();
			InputStream in = application.getResourceAsStream("/WEB-INF/fileservice.properties");
			try {
				props.load(in);
			} finally {
				if (in != null) in.close();
			}
			FileServiceClient client = FileServiceClientFactory.init(props.getProperty("url"));

			BaseResponse<FileGenerateLinkResponse> resp = client.generateLink(UUID.fromString(fileId), 3600);
			if (!resp.isSuccess() || resp.getData() == null) {
				ErrorData err = resp.getError();
				throw new Exception(err != null ? err.getMessage() : "generate-link failed");
			}

			/* file-service MinIO presigned URL'ni ichki host (masalan 127.0.0.1:9000)
			 * bilan qaytaradi - bu tashqaridan yetib bo'lmaydigan manzil, lekin
			 * imzo (X-Amz-Signature) aynan shu Host qiymati uchun hisoblangan.
			 * Shuning uchun ulanish nuqtasini fileservice.properties dagi
			 * haqiqiy (tashqi) hostga almashtiramiz, Host headerni esa
			 * o'zgartirmaymiz - aks holda imzo tekshiruvi o'tmaydi. */
			String realHost = new URI(props.getProperty("url")).getHost();
			downloadViaPresignedUrl(resp.getData().getUrl(), realHost, fileName, response);
			return;
		} catch (Exception ex) {
			errorMessage = ex.getMessage();
		}
	}
%><html><body><%=esc(errorMessage)%></body></html>
<%!
	static final int si_no_file = SI("Файл топилмади", "Файл топилмади", "Fayl topilmadi", "File not found");

	static String esc(String s) {
		if (s == null) return "";
		return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
	}

	static void downloadViaPresignedUrl(String presignedUrl, String realHost, String fileName, HttpServletResponse response) throws Exception {
		URI uri = new URI(presignedUrl);
		int port = uri.getPort() == -1 ? 80 : uri.getPort();
		String hostHeader = uri.getHost() + ":" + port;
		String pathAndQuery = uri.getRawPath() + (uri.getRawQuery() != null ? "?" + uri.getRawQuery() : "");

		try (Socket sock = new Socket(realHost, port)) {
			sock.setSoTimeout(15000);
			OutputStream out = sock.getOutputStream();
			String req = "GET " + pathAndQuery + " HTTP/1.1\r\n"
				+ "Host: " + hostHeader + "\r\n"
				+ "Connection: close\r\n\r\n";
			out.write(req.getBytes("ISO-8859-1"));
			out.flush();

			InputStream in = sock.getInputStream();
			byte[] headerRaw = readHeaders(in);
			String headerText = new String(headerRaw, "ISO-8859-1");
			String statusLine = headerText.split("\r\n")[0];
			int statusCode = Integer.parseInt(statusLine.split(" ")[1]);

			byte[] body = readBody(in, headerText);
			if (statusCode != 200) {
				throw new Exception("[" + statusCode + "] " + new String(body, "UTF-8"));
			}

			String contentType = "application/octet-stream";
			for (String line : headerText.split("\r\n")) {
				if (line.toLowerCase().startsWith("content-type:")) {
					contentType = line.substring(line.indexOf(':') + 1).trim();
				}
			}
			response.setContentType(contentType);
			response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName.replace("\"", "") + "\"");
			response.setContentLength(body.length);
			response.getOutputStream().write(body);
			response.getOutputStream().flush();
		}
	}

	static byte[] readHeaders(InputStream in) throws IOException {
		ByteArrayOutputStream buf = new ByteArrayOutputStream();
		int prev = -1, cur;
		while ((cur = in.read()) != -1) {
			buf.write(cur);
			if (prev == '\r' && cur == '\n') {
				byte[] b = buf.toByteArray();
				if (b.length >= 4 && b[b.length-2] == '\r' && b[b.length-1] == '\n'
						&& b[b.length-3] == '\n' && b[b.length-4] == '\r') break;
			}
			prev = cur;
		}
		return buf.toByteArray();
	}

	static byte[] readBody(InputStream in, String headerText) throws IOException {
		int contentLength = -1;
		boolean chunked = false;
		for (String line : headerText.split("\r\n")) {
			String low = line.toLowerCase();
			if (low.startsWith("content-length:")) contentLength = Integer.parseInt(line.substring(line.indexOf(':') + 1).trim());
			else if (low.startsWith("transfer-encoding:") && low.contains("chunked")) chunked = true;
		}
		ByteArrayOutputStream body = new ByteArrayOutputStream();
		if (chunked) {
			while (true) {
				StringBuilder sizeLine = new StringBuilder();
				int c;
				while ((c = in.read()) != -1 && c != '\n') if (c != '\r') sizeLine.append((char) c);
				int size = Integer.parseInt(sizeLine.toString().trim(), 16);
				if (size == 0) { in.read(); in.read(); break; }
				body.write(in.readNBytes(size));
				in.read(); in.read();
			}
		} else if (contentLength > 0) {
			body.write(in.readNBytes(contentLength));
		} else if (contentLength < 0) {
			byte[] buf = new byte[8192];
			int n;
			while ((n = in.read(buf)) != -1) body.write(buf, 0, n);
		}
		return body.toByteArray();
	}
%>
<%@ include file="/language.jsp" %>
