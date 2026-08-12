<%@ page contentType="text/html;charset=WINDOWS-1251" language="java" %>
<%@ page import="java.util.*, java.io.*, uz.fido_biznes.cms.*" %>
<%@ page import="org.apache.commons.fileupload.FileItem" %>
<%@ page import="org.apache.commons.fileupload.servlet.ServletFileUpload" %>
<%@ page import="org.apache.commons.fileupload.disk.DiskFileItemFactory" %>
<%@ page import="org.springframework.web.multipart.MultipartFile" %>
<%@ page import="uz.sqb.abs.fileclient.FileServiceClient" %>
<%@ page import="uz.sqb.abs.fileclient.config.FileServiceClientFactory" %>
<%@ page import="uz.sqb.abs.fileclient.dto.*" %>
<jsp:useBean id="user" class="iabs.User" scope="session" />
<%
	/* Faqat bitta tilning shabloni uchun mo'ljallangan, print_setting.jsp
	 * ichidagi ko'rinmas iframe orqali chaqiriladigan yordamchi sahifa.
	 * Asosiy formadan mustaqil - shu sababli fayl yuklanayotganda boshqa
	 * kiritilgan maydonlar (nomi, moduli va h.k.) yo'qolmaydi.
	 *
	 * Bu yerda ma'lumotlar bazasiga hech narsa yozilmaydi - faqat
	 * file-service'ga yuborib, qaytgan file_id ni ota oynadagi yashirin
	 * maydonga qaytaradi. Haqiqiy DB bog'lanishi (MPT_PRINT_SETTING_FILES)
	 * asosiy "Сохранить" bosilganda amalga oshadi.
	 */
	Language lang = new Language(user.getLanguageIndex(), sentences);
	String targetField = null;
	String errorMessage = null;
	if (user.getUserCode() == null) {
		errorMessage = "Session expired";
	} else {
		try {
			DiskFileItemFactory factory = new DiskFileItemFactory();
			ServletFileUpload upload = new ServletFileUpload(factory);
			upload.setSizeMax(MAX_FILE_SIZE_MB * 1024L * 1024L);
			List<FileItem> items = upload.parseRequest(request);
			FileItem fileItem = null;
			for (FileItem item : items) {
				if (item.isFormField()) {
					if ("target_field".equals(item.getFieldName())) {
						targetField = item.getString("UTF-8");
					}
				} else if (fileItem == null) {
					fileItem = item;
				}
			}
			if (fileItem == null || fileItem.getSize() == 0) {
				throw new Exception(lang.get(si_no_file));
			}

			MultipartFile multipartFile = new FileItemMultipartFile(fileItem);

			Properties props = new Properties();
			InputStream in = application.getResourceAsStream("/WEB-INF/fileservice.properties");
			try {
				props.load(in);
			} finally {
				if (in != null) in.close();
			}
			FileServiceClient client = FileServiceClientFactory.init(props.getProperty("url"));

			BaseResponse<List<FileUploadResponse>> resp = client.upload(multipartFile, FS_FOLDER);
			List<FileUploadResponse> list = resp.isSuccess() ? resp.getData() : null;
			FileUploadResponse data = (list != null && !list.isEmpty()) ? list.get(0) : null;
			if (data != null && data.getId() != null) {
				out.print("<script>parent.onTemplateFileUploaded("
					+ js(targetField) + "," + js(data.getId().toString()) + "," + js(fileItem.getName())
					+ ");</script>");
				return;
			} else {
				uz.sqb.abs.fileclient.dto.ErrorData err = resp.getError();
				errorMessage = err != null ? err.getMessage() : "Upload failed";
			}
		} catch (Exception ex) {
			errorMessage = ex.getMessage();
		}
	}
	out.print("<script>parent.onTemplateFileFailed(" + js(targetField) + "," + js(errorMessage) + ");</script>");
%><%!
	static final int MAX_FILE_SIZE_MB = 40;

	/* file-service papka nomi: server faqat ^[a-zA-Z0-9_-]+$ ni qabul qiladi,
	 * "/" belgisi HTTP 400 (NEW-ABS:FILE-SERVICE:-9) beradi. */
	static final String FS_FOLDER = "mpt_print_settings";

	static final int si_no_file = SI("Файл не выбран", "Файл танланмади", "Fayl tanlanmadi", "No file selected");

	static String js(String s) {
		if (s == null) return "null";
		return "'" + s.replace("\\", "\\\\").replace("'", "\\'").replace("\r", "").replace("\n", "\\n") + "'";
	}

	/* org.apache.commons.fileupload.FileItem ni org.springframework.web.multipart.MultipartFile
	 * ga o'rovchi ko'prik - file-service klienti Spring turini talab qiladi,
	 * bu ilova esa Spring emas, oddiy servlet/JSP (commons-fileupload orqali
	 * multipart parslaydi).
	 */
	static class FileItemMultipartFile implements MultipartFile {
		private final FileItem item;

		FileItemMultipartFile(FileItem item) {
			this.item = item;
		}

		public String getName() {
			return item.getFieldName();
		}

		public String getOriginalFilename() {
			return item.getName();
		}

		public String getContentType() {
			return item.getContentType();
		}

		public boolean isEmpty() {
			return item.getSize() == 0;
		}

		public long getSize() {
			return item.getSize();
		}

		public byte[] getBytes() throws IOException {
			return item.get();
		}

		public InputStream getInputStream() throws IOException {
			return item.getInputStream();
		}

		public void transferTo(File dest) throws IOException, IllegalStateException {
			try {
				item.write(dest);
			} catch (IOException ex) {
				throw ex;
			} catch (Exception ex) {
				throw new IOException(ex);
			}
		}
	}
%>
<%@ include file="/language.jsp" %>
