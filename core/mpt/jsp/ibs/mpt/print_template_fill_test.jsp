<%@ page contentType="text/html;charset=WINDOWS-1251" language="java" %>
<%@ page import="java.io.*, java.util.*, java.util.regex.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.http.HttpServletResponse" %>
<%@ page import="uz.fido_biznes.cms.*" %>
<%@ page import="uz.sqb.abs.pechatclient.PechatServiceClient" %>
<%@ page import="uz.sqb.abs.pechatclient.config.PechatServiceClientFactory" %>
<%@ page import="uz.sqb.abs.pechatclient.dto.ErrorData" %>
<%@ page import="uz.sqb.abs.pechatclient.exception.PechatServiceException" %>
<%@ taglib uri="/WEB-INF/cms.tld" prefix="t" %>
<jsp:useBean id="cods" class="iabs.oraDBConnection" scope="session" />
<jsp:useBean id="stored" class="uz.fido_biznes.sql.StoredObject" scope="session" />
<jsp:useBean id="user" class="iabs.User" scope="session" />
<%
	/* PECHAT SISTEMA - Phase 4 - TEST muhiti.
	 * JSON MPT_PRINT_API.Get_All_Resolved_Vars orqali avtomatik hisoblanadi
	 * (P2.6), so'ng pechat-service-client.jar orqali tashqi pechat-service'ga
	 * (file_id + placeholders JSON) yuboriladi - u shablonni file-service'dan
	 * o'zi topib, to'ldirib, tayyor faylni (PDF yoki DOCX) qaytaradi. Bizning
	 * tomonda endi na Apache POI, na file-service bilan to'g'ridan-to'g'ri
	 * ish (generateLink/MinIO) kerak emas - hammasi pechat-service ichida.
	 */
	Connection conn = cods.getConnection();
	Language lang = new Language(user.getLanguageIndex(), sentences);
	pageContext.setAttribute(Resource.STR_LANGUAGE, lang);
	String errorMessage = null;

	String action = request.getParameter("action");
	String selectedFileId = request.getParameter("file_id");
	String resolvedJson = null;
	if ("preview".equals(action)) {
		try {
			String fileId = selectedFileId;
			if (fileId == null || fileId.equals("")) throw new Exception("Fayl tanlanmadi");
			resolvedJson = getResolvedVarsJson(conn, fileId, user.getUserCode());
		} catch (Exception ex) {
			errorMessage = ex.getMessage();
		}
	} else if ("fill".equals(action)) {
		try {
			String fileId = selectedFileId;
			if (fileId == null || fileId.equals("")) throw new Exception("Fayl tanlanmadi");

			String json = getResolvedVarsJson(conn, fileId, user.getUserCode());
			String placeholdersJson = extractPlaceholdersJson(json);

			Properties props = new Properties();
			InputStream in = application.getResourceAsStream("/WEB-INF/pechatservice.properties");
			try { props.load(in); } finally { if (in != null) in.close(); }
			PechatServiceClient client = PechatServiceClientFactory.init(
				props.getProperty("url"), props.getProperty("user"), props.getProperty("password"));

			byte[] result = client.generateWithId(fileId, placeholdersJson);

			String contentType = "application/octet-stream";
			String ext = "bin";
			if (result.length >= 4 && result[0] == '%' && result[1] == 'P' && result[2] == 'D' && result[3] == 'F') {
				contentType = "application/pdf";
				ext = "pdf";
			} else if (result.length >= 2 && result[0] == 'P' && result[1] == 'K') {
				contentType = "application/vnd.openxmlformats-officedocument.wordprocessingml.document";
				ext = "docx";
			}

			response.setContentType(contentType);
			response.setHeader("Content-Disposition", "attachment; filename=\"pechat_" + fileId + "." + ext + "\"");
			response.setContentLength(result.length);
			response.getOutputStream().write(result);
			response.getOutputStream().flush();
			return;
		} catch (PechatServiceException pse) {
			ErrorData ed = pse.getErrorData();
			errorMessage = ed != null ? ed.message() : pse.getMessage();
		} catch (Exception ex) {
			errorMessage = ex.getMessage();
		}
	}
%><t:page><t:form title="<%=si_title%>" minWidth="700" minHeight="500">
	<div class="form-group" style="padding:10px">
<%
		if (errorMessage != null) {
%>
		<div style="color:red;margin-bottom:10px"><b><%=esc(errorMessage)%></b></div>
<%
		}
%>
		<form method="post" action="print_template_fill_test.jsp">
			<input type="hidden" name="action" id="formAction" value="fill">
			<div class="form-group">
				<select name="file_id" class="form-control" r="1">
					<option value=""></option>
<%
		try {
			PreparedStatement ps = conn.prepareStatement(
				"select f.file_id, s.setting_name, f.lang_code, f.file_name" +
				"  from mpt_print_setting_files f" +
				"  join mpt_print_settings s on s.setting_id = f.setting_id" +
				" order by s.setting_name, f.lang_code");
			ResultSet rs = ps.executeQuery();
			while (rs.next()) {
				String rowFileId = rs.getString("file_id");
				boolean isSelected = rowFileId.equals(selectedFileId);
%>
					<option value="<%=rowFileId%>"<%=isSelected ? " selected" : ""%>><%=esc(rs.getString("setting_name"))%> [<%=rs.getString("lang_code")%>] - <%=esc(rs.getString("file_name"))%></option>
<%
			}
			rs.close();
			ps.close();
		} catch (Exception ex) {
			out.print("<!-- " + ex.getMessage() + " -->");
		}
%>
				</select>
				<label>Shablon fayli:</label>
			</div>
<%
		if (resolvedJson != null) {
%>
			<div class="form-group">
				<textarea readonly class="form-control" rows="8" style="font-family:monospace"><%=esc(resolvedJson)%></textarea>
				<label>MPT_PRINT_API.Get_All_Resolved_Vars natijasi:</label>
			</div>
<%
		}
%>
			<input type="button" value="JSON'ni ko'rish" onclick="getDOM('formAction').value='preview';this.form.submit();">
			<input type="button" value="To'ldirish va yuklab olish" onclick="getDOM('formAction').value='fill';this.form.submit();">
		</form>
	</div>
</t:form>
</t:page>
<%!
	static final int si_title = SI("Шаблонни тулдириш (TEST)", "Шаблонни тулдириш (TEST)", "Shablonni to'ldirish (TEST)", "Fill template (TEST)");

	static String esc(String s) {
		if (s == null) return "";
		return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
	}

	/* MPT_PRINT_API.Get_All_Resolved_Vars(group_code, record_id, lang_code,
	 * user_id, params) ni chaqiradi va CLOB natijani String qilib qaytaradi.
	 *
	 * group_code MPT_PRINT_SETTINGS bilan ko'prik: bu jadvalda "guruh"
	 * tushunchasi yo'q, shuning uchun har bir shablon (setting_id) o'ziga
	 * xos "mpt_setting_<id>" nomli guruh sifatida ko'riladi. Mapping
	 * (Register_Doc_Mapping) shu group_code bilan ro'yxatga olinishi kerak -
	 * aks holda placeholders bo'sh qaytadi (xato emas). */
	static String getResolvedVarsJson(Connection conn, String fileId, String userId) throws Exception {
		String settingId = null;
		String langCode = null;
		PreparedStatement ps = conn.prepareStatement(
			"select setting_id, lang_code from mpt_print_setting_files where file_id = ?");
		try {
			ps.setString(1, fileId);
			ResultSet rs = ps.executeQuery();
			try {
				if (!rs.next()) throw new Exception("Fayl topilmadi: " + fileId);
				settingId = rs.getString("setting_id");
				langCode = rs.getString("lang_code");
			} finally {
				rs.close();
			}
		} finally {
			ps.close();
		}

		String groupCode = "mpt_setting_" + settingId;
		CallableStatement cs = conn.prepareCall("{? = call Mpt_Print_Api.Get_All_Resolved_Vars(?,?,?,?,?)}");
		try {
			cs.registerOutParameter(1, Types.CLOB);
			cs.setString(2, groupCode);
			cs.setNull(3, Types.VARCHAR);
			cs.setString(4, langCode);
			cs.setInt(5, Integer.parseInt(userId));
			cs.setNull(6, Types.CLOB);
			cs.execute();
			Clob clob = cs.getClob(1);
			if (clob == null) return "{}";
			return clob.getSubString(1, (int) clob.length());
		} finally {
			cs.close();
		}
	}

	/* Get_All_Resolved_Vars to'liq javobidan ("language"/"placeholders"/
	 * "tables"/"qr_codes" envelope) faqat "placeholders" ichki obyektini
	 * ajratib, pechat-service kutgan ko'rinishga o'giradi:
	 *  - envelope OLIB TASHLANADI - faqat tekis {"kalit":"qiymat",...}
	 *    yuborilishi kerak (aks holda 400: "Cannot deserialize ... from
	 *    Object value", chunki server butun body'ni Map<String,String>
	 *    deb o'qiydi)
	 *  - kalitlardan "[" "]" olib tashlanadi - MPT_PRINT_API "[client_name]"
	 *    ko'rinishida qaytaradi, lekin pechat-service to'ldirishda faqat
	 *    qavssiz "client_name" kalitini document ichidagi [client_name]
	 *    bilan bog'lay oladi (sinovda tasdiqlangan). */
	static String extractPlaceholdersJson(String json) {
		Map<String, String> vars = new LinkedHashMap<String, String>();
		if (json != null) {
			int start = json.indexOf("\"placeholders\":{");
			if (start != -1) {
				start += "\"placeholders\":{".length() - 1;
				int depth = 0;
				int end = start;
				for (int i = start; i < json.length(); i++) {
					char c = json.charAt(i);
					if (c == '{') depth++;
					else if (c == '}') {
						depth--;
						if (depth == 0) { end = i; break; }
					}
				}
				String inner = json.substring(start, end + 1);
				Matcher m = Pattern.compile("\"(\\[?[a-zA-Z_][a-zA-Z0-9_]*\\]?)\"\\s*:\\s*\"((?:[^\"\\\\]|\\\\.)*)\"").matcher(inner);
				while (m.find()) {
					String key = m.group(1);
					if (key.startsWith("[") && key.endsWith("]")) key = key.substring(1, key.length() - 1);
					String val = m.group(2).replace("\\\"", "\"").replace("\\\\", "\\");
					vars.put(key, val);
				}
			}
		}

		StringBuilder sb = new StringBuilder("{");
		boolean first = true;
		for (Map.Entry<String, String> e : vars.entrySet()) {
			if (!first) sb.append(',');
			first = false;
			sb.append('"').append(e.getKey()).append("\":\"")
				.append(e.getValue().replace("\\", "\\\\").replace("\"", "\\\""))
				.append('"');
		}
		sb.append('}');
		return sb.toString();
	}
%>
<%@ include file="/language.jsp" %>
