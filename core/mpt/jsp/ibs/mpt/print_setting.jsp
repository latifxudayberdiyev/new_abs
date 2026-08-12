<%@ page contentType="text/html;charset=WINDOWS-1251" language="java" %>
<%@ page import="java.sql.*, java.util.*, uz.fido_biznes.cms.*" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="oracle.sql.*, oracle.jdbc.*" %>
<%@ taglib uri="/WEB-INF/cms.tld" prefix="t" %>
<jsp:useBean id="cods" class="iabs.oraDBConnection" scope="session" />
<jsp:useBean id="stored" class="uz.fido_biznes.sql.StoredObject" scope="session" />
<jsp:useBean id="user" class="iabs.User" scope="session" />
<%
	Connection conn = cods.getConnection();
	if (conn == null || user.getUserCode() == null) {
		pageContext.setAttribute(Resource.SESSION_EXPIRED, Boolean.TRUE);
	}
	Language lang = new Language(user.getLanguageIndex(), sentences);
	pageContext.setAttribute(Resource.STR_LANGUAGE, lang);
%><t:page><%
	String setting_id = request.getParameter("setting_id");
	boolean is_edit = (setting_id != null && !setting_id.equals(""));
	if (is_edit) {
		PreparedStatement ps = null;
		ResultSet rs = null;
		try {
			ps = conn.prepareStatement(
				"select json_object(" +
				"'setting_id' value setting_id, " +
				"'setting_name' value setting_name, " +
				"'module_code' value module_code, " +
				"'template_code' value template_code, " +
				"'file_type' value file_type, " +
				"'file_format' value file_format, " +
				"'open_as_pdf' value open_as_pdf, " +
				"'activation_date' value to_char(activation_date, 'dd.mm.yyyy'), " +
				"'deactivation_date' value to_char(deactivation_date, 'dd.mm.yyyy'), " +
				"'description' value description, " +
				"'is_active' value is_active" +
				") as json_data from mpt_print_settings where setting_id = ?");
			ps.setString(1, setting_id);
			rs = ps.executeQuery();
			if (rs.next()) {
				out.println("<script>var data=" + rs.getString("json_data") + ";</script>");
			}
		} catch (Exception ex) {
			Util.alertUserMessage(ex, out);
		} finally {
			if (rs != null) rs.close();
			if (ps != null) ps.close();
		}
	}

	/* Shablon fayli har bir til uchun alohida yuklanadi. Tillar ro'yxati
	 * qattiq kodlanmaydi - mpt_languages_v dan olinadi, shuning uchun
	 * MLT ga yangi til qo'shilsa forma o'zi yangi polya chizadi.
	 * Massiv elementlari: [0]=file_field_name, [1]=lang_name, [2]=is_required, [3]=lang_code.
	 * "save" so'rovida ham xuddi shu ro'yxat qayta o'qiladi - fayl_maydon
	 * nomidan til kodini string parslash bilan taxmin qilmaslik uchun.
	 */
	List<String[]> langFields = new ArrayList<String[]>();
	if (conn != null) {
		PreparedStatement psl = null;
		ResultSet rsl = null;
		try {
			psl = conn.prepareStatement(
				"select file_field_name, lang_name, is_required, lang_code" +
				"  from mpt_languages_v" +
				" where is_active = 'Y'" +
				" order by priority, lang_index");
			rsl = psl.executeQuery();
			while (rsl.next()) {
				langFields.add(new String[] {
					rsl.getString("file_field_name"),
					rsl.getString("lang_name"),
					rsl.getString("is_required"),
					rsl.getString("lang_code") });
			}
		} catch (Exception ex) {
			Util.alertUserMessage(ex, out);
		} finally {
			if (rsl != null) rsl.close();
			if (psl != null) psl.close();
		}
	}

	/* Tahrirlashda avval yuklangan fayllar bo'lsa - status matnini
	 * boshidanoq ko'rsatish uchun (fillForm bilan emas, chunki file
	 * input'ning o'zini dasturiy to'ldirib bo'lmaydi).
	 */
	Map<String, String[]> existingFiles = new HashMap<String, String[]>();
	if (is_edit && conn != null) {
		PreparedStatement psf = null;
		ResultSet rsf = null;
		try {
			psf = conn.prepareStatement(
				"select f.lang_code, f.file_id, f.file_name" +
				"  from mpt_print_setting_files f" +
				" where f.setting_id = ?");
			psf.setString(1, setting_id);
			rsf = psf.executeQuery();
			while (rsf.next()) {
				existingFiles.put(rsf.getString("lang_code"),
					new String[] { rsf.getString("file_id"), rsf.getString("file_name") });
			}
		} catch (Exception ex) {
			Util.alertUserMessage(ex, out);
		} finally {
			if (rsf != null) rsf.close();
			if (psf != null) psf.close();
		}
	}
%><t:form title="<%=is_edit?si_edit_title:si_add_title%>" minWidth="fill" minHeight="fill">
	<script>
		function toggleFormat() {
			var type = fm.file_type.value;
			var opts = fm.file_format.options;
			var firstOk = -1;
			for (var i = 0; i < opts.length; i++) {
				var isWord = opts[i].className.indexOf("fmt-word") >= 0;
				var isExcel = opts[i].className.indexOf("fmt-excel") >= 0;
				var disable = (type == "WORD" && !isWord) || (type == "EXCEL" && !isExcel);
				opts[i].disabled = disable;
				opts[i].style.display = disable ? "none" : "";
				if (!disable && firstOk < 0) firstOk = i;
			}
			if (fm.file_format.selectedIndex < 0 || opts[fm.file_format.selectedIndex].disabled) {
				if (firstOk >= 0) fm.file_format.selectedIndex = firstOk;
			}
			/* Fayl tanlash dialogi faqat tanlangan tur uchun mos kengaytmalarni ko'rsatsin
			 */
			var accept = (type == "EXCEL") ? ".xlsx" : ".doc,.docx";
			var files = document.getElementsByClassName("templateFile");
			for (var i = 0; i < files.length; i++) files[i].accept = accept;
		}

		/* Radio faqat ko'rinish uchun, qiymat yashirin open_as_pdf polyasida
		 * yuboriladi - fillForm ham, submit ham shu polya bilan ishlaydi.
		 */
		function setOpenAsPdf(v) {
			getDOM("open_as_pdf").value = v;
		}

		function syncOpenAsPdf() {
			var v = getDOM("open_as_pdf").value;
			if (v != "Y" && v != "N") {
				v = "N";
				getDOM("open_as_pdf").value = v;
			}
			var r = fm.open_as_pdf_sel;
			for (var i = 0; i < r.length; i++) r[i].checked = (r[i].value == v);
		}

		function checkFileSize(el) {
			var max = <%=MAX_FILE_SIZE_MB%> * 1024 * 1024;
			if (el.files && el.files[0] && el.files[0].size > max) {
				alert("<%=lang.get(si_size_limit)%>");
				el.value = "";
				return false;
			}
			return true;
		}

		/* Har bir til uchun fayl darhol, asosiy formadan mustaqil ravishda
		 * ko'rinmas iframe orqali print_setting_upload.jsp ga yuboriladi -
		 * shu paytda boshqa kiritilgan maydonlar (nomi, moduli va h.k.)
		 * tegilmay qoladi. Natijada kelgan file_id shu yerdagi yashirin
		 * <field>_id / <field>_name maydoniga yoziladi - haqiqiy DB yozuvi
		 * esa faqat "Сохранить" bosilganda amalga oshadi (t:request save).
		 */
		function uploadTemplateFile(el, fieldName) {
			if (!checkFileSize(el)) return;
			if (!el.files || !el.files[0]) return;
			getDOM(fieldName + "_status").innerText = "<%=esc(lang.get(si_uploading))%>";
			getDOM(fieldName + "_status").style.color = "#7F8C8D";
			el.form.submit();
		}

		function onTemplateFileUploaded(fieldName, fileId, fileName) {
			getDOM(fieldName + "_id").value = fileId;
			getDOM(fieldName + "_name").value = fileName;
			var s = getDOM(fieldName + "_status");
			s.innerText = fileName;
			s.style.color = "#2E7D32";
		}

		function onTemplateFileFailed(fieldName, message) {
			if (!fieldName) return;
			var s = getDOM(fieldName + "_status");
			s.innerText = message || "<%=esc(lang.get(si_upload_failed))%>";
			s.style.color = "#C0392B";
		}

		function onLoad() {
			toggleFormat();
			syncOpenAsPdf();
		}
	</script>
	<div id="basepanel" class="panel">
		<iframe name="frm" style="display:none"></iframe>
		<form name="fm" method="post" target="frm">
			<input type="hidden" name="request" value="save">
			<input type="hidden" name="setting_id" value="">
			<input type="hidden" name="open_as_pdf" id="open_as_pdf" value="N">
			<input type="hidden" name="user_id" value="<%=user.getUserCode()%>">
			<table class="formToolbar" align="center">
				<tr>
					<td>
						<input type="submit" value="<%=lang.get(si_save)%>">
					<td id="tableControls" align="right">
						<input type="button" onclick="parent.close();" value="<%=lang.get(si_exit)%>">
			</table>
			<div class="form-group">
				<input name="setting_name" mask="200|" r="1" class="form-control">
				<label><%=lang.get(si_name)%> <q></q>:</label>
			</div>
			<div style="display:grid;grid-template-columns:1fr 1fr;gap:5px">
				<div class="form-group">
					<select name="module_code" class="form-control" r="1">
						<option value=""></option>
						<t:options code="module_code" name="module_name" from="mpt_modules_v" />
					</select>
					<label><%=lang.get(si_module)%> <q></q>:</label>
				</div>
				<div class="form-group">
					<select name="template_code" class="form-control" r="1">
						<option value=""></option>
						<t:options code="template_code" name="template_name" from="mpt_template_types" />
					</select>
					<label><%=lang.get(si_template_type)%> <q></q>:</label>
				</div>
			</div>
			<div style="display:grid;grid-template-columns:1fr 1fr;gap:5px">
				<div class="form-group">
					<select name="file_type" class="form-control" r="1" onchange="toggleFormat();">
						<option value="WORD"><%=lang.get(si_type_word)%></option>
						<option value="EXCEL"><%=lang.get(si_type_excel)%></option>
					</select>
					<label><%=lang.get(si_file_type)%> <q></q>:</label>
				</div>
				<div class="form-group">
					<select name="file_format" class="form-control" r="1">
						<option value="DOC" class="fmt-word">doc</option>
						<option value="DOCX" class="fmt-word">docx</option>
						<option value="XLSX" class="fmt-excel">xlsx</option>
						<option value="PDF" class="fmt-word fmt-excel">pdf</option>
					</select>
					<label><%=lang.get(si_file_format)%> <q></q>:</label>
				</div>
			</div>
			<div style="display:grid;grid-template-columns:1fr 1fr;gap:5px">
				<div class="form-group filled">
					<span class="form-control" style="display:flex;align-items:center;gap:20px">
						<label style="display:inline-flex;align-items:center;gap:5px;cursor:pointer">
							<input type="radio" name="open_as_pdf_sel" value="Y" onclick="setOpenAsPdf('Y');"><%=lang.get(si_yes)%>
						</label>
						<label style="display:inline-flex;align-items:center;gap:5px;cursor:pointer">
							<input type="radio" name="open_as_pdf_sel" value="N" onclick="setOpenAsPdf('N');"><%=lang.get(si_no)%>
						</label>
					</span>
					<label><%=lang.get(si_open_as_pdf)%> <q></q>:</label>
				</div>
				<div class="form-group">
					<select name="is_active" class="form-control" r="1">
						<option value="Y"><%=lang.get(si_active)%></option>
						<option value="N"><%=lang.get(si_inactive)%></option>
					</select>
					<label><%=lang.get(si_state)%>:</label>
				</div>
			</div>
			<div style="display:grid;grid-template-columns:1fr 1fr;gap:5px">
				<div class="form-group">
					<input name="activation_date" mask="date" r="1" class="form-control">
					<label><%=lang.get(si_activation_date)%> <q></q>:</label>
				</div>
				<div class="form-group">
					<input name="deactivation_date" mask="date" class="form-control">
					<label><%=lang.get(si_deactivation_date)%>:</label>
				</div>
			</div>
			<div class="form-group">
				<textarea name="description" mask="1000|" class="form-control" rows="2"></textarea>
				<label><%=lang.get(si_description)%>:</label>
			</div>
<%
			for (int i = 0; i < langFields.size(); i++) {
				String[] lf = langFields.get(i);
				String[] existing = existingFiles.get(lf[3]);
%>
			<input type="hidden" name="<%=lf[0]%>_id" id="<%=lf[0]%>_id" value="<%=existing != null ? existing[0] : ""%>">
			<input type="hidden" name="<%=lf[0]%>_name" id="<%=lf[0]%>_name" value="<%=existing != null ? esc(existing[1]) : ""%>">
<%
			}
%>
		</form>
<%
		if (!langFields.isEmpty()) {
%>
		<div style="display:grid;grid-template-columns:1fr 1fr;gap:5px">
<%
			for (int i = 0; i < langFields.size(); i++) {
				String[] lf = langFields.get(i);
				boolean required = "Y".equals(lf[2]);
				String[] existing = existingFiles.get(lf[3]);
%>
			<div>
				<iframe name="uf_<%=lf[0]%>" style="display:none"></iframe>
				<form target="uf_<%=lf[0]%>" method="post" enctype="multipart/form-data" action="print_setting_upload.jsp">
					<input type="hidden" name="target_field" value="<%=lf[0]%>">
					<div class="form-group filled">
						<input type="file" name="file" class="form-control templateFile"
							   onchange="uploadTemplateFile(this, '<%=lf[0]%>');">
						<label><%=lang.get(si_choose_file)%> <%=esc(lf[1])%><%=required?" <q></q>":""%>:</label>
					</div>
				</form>
				<div id="<%=lf[0]%>_status" style="font-size:11px;color:<%=existing != null ? "#2E7D32" : "#7F8C8D"%>;margin:2px 0 6px 5px"><%
					if (existing != null) {
						out.print(esc(existing[1]));
						out.print(" <a href=\"print_setting_download.jsp?file_id=" + URLEncoder.encode(existing[0], "UTF-8")
							+ "&file_name=" + URLEncoder.encode(existing[1], "UTF-8") + "\" target=\"_blank\">"
							+ esc(lang.get(si_download)) + "</a>");
					}
				%></div>
			</div>
<%
			}
%>
		</div>
		<div style="padding:0 5px 5px;font-size:11px;color:#7F8C8D"><%=lang.get(si_size_limit)%></div>
<%
		}
%>
	</div>
</t:form>
</t:page>
<t:requests>
	<t:request name="save"><%
		try {
			ServletCallableStatement cs = new ServletCallableStatement(stored, request);
			cs.setProcedure("Mpt_Admin_Api.Save_Print_Setting");
			cs.setString("i_Setting_Name", request.getParameter("setting_name"));
			cs.setString("i_Module_Code", request.getParameter("module_code"));
			cs.setString("i_Template_Code", request.getParameter("template_code"));
			cs.setString("i_File_Type", request.getParameter("file_type"));
			cs.setString("i_File_Format", request.getParameter("file_format"));
			cs.setNumberParameter("i_User_Id", "user_id");
			String setting_id = request.getParameter("setting_id");
			if (setting_id != null && !setting_id.equals("")) {
				cs.setNumberParameter("i_Setting_Id", "setting_id");
			}
			cs.setString("i_Activation_Date", request.getParameter("activation_date"));
			cs.setString("i_Deactivation_Date", request.getParameter("deactivation_date"));
			cs.setString("i_Description", request.getParameter("description"));
			cs.setString("i_Is_Active", request.getParameter("is_active"));
			cs.setString("i_Open_As_Pdf", request.getParameter("open_as_pdf"));
			cs.registerNumber("o_Setting_Id");
			cs.execute();
			long newSettingId = Long.parseLong(cs.getString("o_Setting_Id"));

			/* Har bir til uchun: agar shu so'rovda yangi fayl yuklangan
			 * bo'lsa (yashirin <field>_id to'ldirilgan bo'lsa), file-service
			 * dagi file_id ni MPT_PRINT_SETTING_FILES ga bog'laymiz. Fayl
			 * qayta yuklanmagan bo'lsa - avvalgi bog'lanish tegilmay qoladi.
			 */
			PreparedStatement psl = cods.getConnection().prepareStatement(
				"select file_field_name, lang_code from mpt_languages_v where is_active = 'Y'");
			ResultSet rsl = psl.executeQuery();
			long userId = Long.parseLong(request.getParameter("user_id"));
			while (rsl.next()) {
				String fieldName = rsl.getString("file_field_name");
				String fileId = request.getParameter(fieldName + "_id");
				if (fileId != null && !fileId.equals("")) {
					String fileName = request.getParameter(fieldName + "_name");
					ServletCallableStatement csf = new ServletCallableStatement(stored, request);
					csf.setProcedure("Mpt_Admin_Api.Save_Print_Setting_File");
					csf.setNumber("i_Setting_Id", String.valueOf(newSettingId));
					csf.setString("i_Lang_Code", rsl.getString("lang_code"));
					csf.setString("i_File_Id", fileId);
					csf.setString("i_File_Name", fileName);
					csf.setNumber("i_User_Id", String.valueOf(userId));
					csf.execute();
				}
			}
			rsl.close();
			psl.close();

			out.print("<script>alert('" + lang.get(si_success) + "');parent.returnValue=true;parent.close();</script>");
		} catch (Exception ex) {
			response.setHeader("RT", "alert");
			Util.alertUserMessage(ex, out);
			out.print("<script>parent.pageLock(false);</script>");
		}
	%></t:request>
</t:requests>
<%!
	static final int MAX_FILE_SIZE_MB = 40;

	/* Til nomi ma'lumotlar bazasidan keladi - label ichiga chiqarishdan oldin
	 * HTML uchun xavfsiz holga keltiriladi.
	 */
	static String esc(String s) {
		if (s == null) return "";
		return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
	}

	static final int si_add_title = SI("Добавление шаблона", "Шаблон кушиш", "Shablon qo'shish", "Add template");
	static final int si_edit_title = SI("Изменение шаблона", "Шаблонни узгартириш", "Shablon o'zgartirish", "Edit template");
	static final int si_save = SI("Сохранить", "Саклаш", "Saqlash", "Save");
	static final int si_success = SI("Успешно выполнено!", "Муваффакиятли бажарилди!", "Muvaffaqiyatli bajarildi!", "Successfully executed!");
	static final int si_exit = SI("Выход", "Чикиш", "Chiqish", "Exit");
	static final int si_name = SI("Название шаблона", "Шаблон номи", "Shablon nomi", "Template name");
	static final int si_module = SI("Модуль", "Модул", "Modul", "Module");
	static final int si_template_type = SI("Тип шаблона", "Шаблон тури", "Shablon turi", "Template type");
	static final int si_file_type = SI("Тип файла", "Файл тури", "Fayl turi", "File type");
	static final int si_type_word = SI("Word", "Word", "Word", "Word");
	static final int si_type_excel = SI("Excel", "Excel", "Excel", "Excel");
	static final int si_file_format = SI("Формат", "Формат", "Format", "Format");
	static final int si_open_as_pdf = SI("Открыт файл в формате PDF.", "Файл PDF форматида очилади.", "Fayl PDF formatida ochiladi.", "Open file as PDF.");
	static final int si_yes = SI("Да", "Ха", "Ha", "Yes");
	static final int si_no = SI("Нет", "Йук", "Yo'q", "No");
	static final int si_choose_file = SI("Выберите файл", "Файлни танланг", "Faylni tanlang", "Choose file");
	static final int si_download = SI("Скачать", "Юклаб олиш", "Yuklab olish", "Download");
	static final int si_uploading = SI("Загрузка...", "Юкланмокда...", "Yuklanmoqda...", "Uploading...");
	static final int si_upload_failed = SI("Ошибка загрузки файла", "Файлни юклашда хатолик", "Faylni yuklashda xatolik", "File upload failed");
	static final int si_size_limit = SI("Размер загружаемых файлов не должен превышать 40 Мб", "Юкланадиган файллар хажми 40 Мб дан ошмаслиги керак", "Yuklanadigan fayllar hajmi 40 Mb dan oshmasligi kerak", "Uploaded files must not exceed 40 MB");
	static final int si_activation_date = SI("Дата активации", "Активация санаси", "Aktivatsiya sanasi", "Activation date");
	static final int si_deactivation_date = SI("Дата деактивации", "Деактивация санаси", "Deaktivatsiya sanasi", "Deactivation date");
	static final int si_state = SI("Состояние", "Холат", "Holat", "State");
	static final int si_active = SI("Активный", "Фаол", "Faol", "Active");
	static final int si_inactive = SI("Неактивный", "Нофаол", "Nofaol", "Inactive");
	static final int si_description = SI("Описание", "Тавсиф", "Tavsif", "Description");
%>
<%@ include file="/language.jsp" %>
