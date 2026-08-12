<%@ page contentType="text/html;charset=WINDOWS-1251" language="java" %>
<%@ page import="java.sql.*, java.util.*, uz.fido_biznes.cms.*" %>
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
	String code = request.getParameter("code");
	boolean is_edit = (code != null && !code.equals(""));
	if (is_edit) {
		try {
			out.println("<script>var data=" + stored.execJsonRequestFunction("Core_Api.Get_Model_Clob", request) + ";</script>");
			/* fillForm() (form.js) "data" ichidagi HAR BIR kalitni forma elementiga
			   avtomatik yozishga urinadi (initForm -> fillForm) va mos elementi yo'q
			   kalitda (masalan state, product_id) xato tashlab, butun window.onload'ni
			   to'xtatadi (brauzer konsolida tasdiqlangan: "Cannot read properties of
			   null (reading 'setValue')" at fillForm). Shu uchun asl modelni
			   pfProdModel'ga ko'chirib, "data"ni bo'shatamiz. */
			out.println("<script>window.pfProdModel={};for(var k in data){window.pfProdModel[k]=data[k];delete data[k];}</script>");
		} catch (Exception ex) {
			Util.alertUserMessage(ex, out);
		}
	}
%><t:form title="<%=is_edit?si_edit_title:si_title%>" minWidth="fill" minHeight="fill">
	<style>
		/* stats.jsp'dagi bilan bir xil o'zi yozilgan kalendar popup uchun mustaqil stil -
		   umumiy dizayn tizimidan (pf.css) mustaqil, faqat shu sahifada ishlatiladi. */
		.date-picker-btn {
			position: absolute; right: 8px; top: 50%; transform: translateY(-50%);
			width: 22px; height: 20px;
			border: 1px solid transparent; border-radius: 4px; background: transparent;
			cursor: pointer; font-size: 12px; line-height: 1; padding: 0; color: #666;
		}
		.date-picker-btn:hover { background: #eef2fb; }
		.date-picker-popup {
			position: absolute; left: 0; top: 52px; z-index: 1000; width: 230px; box-sizing: border-box;
			background: #fff; border: 1px solid #d7dee8; border-radius: 6px;
			box-shadow: 0 4px 14px rgba(16,24,40,.12); padding: 8px; font-size: 12px;
		}
		.date-picker-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 6px; }
		.date-picker-label { font-weight: 600; color: #222; font-size: 12px; }
		.date-picker-nav { width: 24px; height: 24px; border: 1px solid transparent; background: transparent; border-radius: 4px; cursor: pointer; color: #666; }
		.date-picker-nav:hover { background: #eef2fb; }
		.date-picker-grid { display: grid; grid-template-columns: repeat(7, 1fr); gap: 2px; }
		.date-picker-dayname { text-align: center; font-size: 10px; color: #888; padding: 3px 0; font-weight: 600; text-transform: uppercase; }
		.date-picker-day { text-align: center; padding: 5px 0; border-radius: 4px; cursor: pointer; color: #222; }
		.date-picker-day:hover { background: #eef2fb; }
		.date-picker-day.other-month { color: #bbb; }
		.date-picker-day.today { font-weight: 700; color: #3457ef; }
		.date-picker-day.selected { background: #3457ef; color: #fff; }
	</style>
	<script>
		var g_datePicker = null;
		var MONTH_NAMES  = ['Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun', 'Iyul', 'Avgust', 'Sentabr', 'Oktabr', 'Noyabr', 'Dekabr'];
		var DAY_NAMES    = ['Du', 'Se', 'Ch', 'Pa', 'Ju', 'Sh', 'Ya'];

		function fmtDate(d) {
			return ('0' + d.getDate()).slice(-2) + '.' +
				('0' + (d.getMonth() + 1)).slice(-2) + '.' +
				d.getFullYear();
		}

		function parseDMY(str) {
			var p = (str || '').split('.');
			if (p.length !== 3) return null;
			var dt = new Date(parseInt(p[2], 10), parseInt(p[1], 10) - 1, parseInt(p[0], 10));
			return isNaN(dt.getTime()) ? null : dt;
		}

		function sameDay(a, b) {
			return a.getFullYear() === b.getFullYear() && a.getMonth() === b.getMonth() && a.getDate() === b.getDate();
		}

		function closeDatePicker() {
			if (g_datePicker) {
				g_datePicker.remove();
				g_datePicker = null;
			}
			document.removeEventListener('mousedown', onDatePickerOutsideClick, true);
		}

		function onDatePickerOutsideClick(e) {
			if (g_datePicker && !g_datePicker.contains(e.target) && !(e.target.classList && e.target.classList.contains('date-picker-btn'))) {
				closeDatePicker();
			}
		}

		function renderDatePicker(input, viewDate, selectedDate) {
			g_datePicker.innerHTML = '';

			var header = document.createElement('div');
			header.className = 'date-picker-header';

			var prev = document.createElement('button');
			prev.type = 'button';
			prev.className = 'date-picker-nav';
			prev.textContent = '<';
			prev.onclick = function() {
				renderDatePicker(input, new Date(viewDate.getFullYear(), viewDate.getMonth() - 1, 1), selectedDate);
			};

			var label = document.createElement('span');
			label.className = 'date-picker-label';
			label.textContent = MONTH_NAMES[viewDate.getMonth()] + ' ' + viewDate.getFullYear();

			var next = document.createElement('button');
			next.type = 'button';
			next.className = 'date-picker-nav';
			next.textContent = '>';
			next.onclick = function() {
				renderDatePicker(input, new Date(viewDate.getFullYear(), viewDate.getMonth() + 1, 1), selectedDate);
			};

			header.appendChild(prev);
			header.appendChild(label);
			header.appendChild(next);
			g_datePicker.appendChild(header);

			var grid = document.createElement('div');
			grid.className = 'date-picker-grid';

			for (var d = 0; d < DAY_NAMES.length; d++) {
				var dayName = document.createElement('div');
				dayName.className = 'date-picker-dayname';
				dayName.textContent = DAY_NAMES[d];
				grid.appendChild(dayName);
			}

			var firstOfMonth = new Date(viewDate.getFullYear(), viewDate.getMonth(), 1);
			var startOffset  = (firstOfMonth.getDay() + 6) % 7;
			var startDate    = new Date(firstOfMonth);
			startDate.setDate(startDate.getDate() - startOffset);
			var today = new Date();

			for (var i = 0; i < 42; i++) {
				var cellDate = new Date(startDate);
				cellDate.setDate(startDate.getDate() + i);

				var cell = document.createElement('div');
				cell.className = 'date-picker-day';
				if (cellDate.getMonth() !== viewDate.getMonth()) cell.className += ' other-month';
				if (sameDay(cellDate, today)) cell.className += ' today';
				if (selectedDate && sameDay(cellDate, selectedDate)) cell.className += ' selected';
				cell.textContent = cellDate.getDate();

				(function(value) {
					cell.onclick = function() {
						input.value = fmtDate(value);
						closeDatePicker();
					};
				})(cellDate);

				grid.appendChild(cell);
			}

			g_datePicker.appendChild(grid);
		}

		function openDatePicker(input) {
			closeDatePicker();

			var selected = parseDMY(input.value) || new Date();
			var viewDate = new Date(selected.getFullYear(), selected.getMonth(), 1);
			var holder = input.parentNode;

			g_datePicker = document.createElement('div');
			g_datePicker.className = 'date-picker-popup';
			holder.appendChild(g_datePicker);

			renderDatePicker(input, viewDate, selected);

			setTimeout(function() {
				document.addEventListener('mousedown', onDatePickerOutsideClick, true);
			}, 0);
		}

		function pfShowExtraLangs(containerId, btnId) {
			document.getElementById(containerId).style.display = "grid";
			document.getElementById(btnId).style.display = "none";
		}

		function onLoad() {
			var m = window.pfProdModel;
			if (m) {
				/* SM_R_PROCESSES.RELATION_KEY = 'product_id' EDIT_PF_PRODUCT uchun -
				   Sm_Kernel.Set_Object aynan shu nomdagi maydonni qidiradi, "sm_relation_id"
				   emas. Noto'g'ri nom bilan saqlashda "ORA-01403: no data found" xato beradi. */
				document.fm.product_id.value = m.product_id;
				document.fm.code.value = m.code;
				document.fm.category_id.value = m.category_id;
				document.fm.name_uz.value = m.name_uz || '';
				document.fm.name_ru.value = m.name_ru || '';
				document.fm.name_en.value = m.name_en || '';
				document.fm.description_uz.value = m.description_uz || '';
				document.fm.description_ru.value = m.description_ru || '';
				document.fm.description_en.value = m.description_en || '';
				document.fm.delivery_type_id.value = m.delivery_type_id;
				document.fm.owner_id.value = m.owner_id || '';
				if (m.start_date) document.getElementById("start_date").setValue(m.start_date);
				if (m.end_date) document.getElementById("end_date").setValue(m.end_date);
				document.fm.continue_on_expiry.checked = (m.continue_on_expiry == 1);

				/* MLT_LANGUAGES'dan dinamik qo'shilgan qo'shimcha til maydonlari
				   (name_lang5, description_lang6, ...) - qaysi indekslar mavjudligi
				   bazadan keladi, shu uchun kalit nomi bo'yicha umumiy qidiruv.
				   Nomi va tavsifi bo'limlari mustaqil ravishda ochiladi. */
				var hasExtraName = false, hasExtraDesc = false;
				for (var k in m) {
					if (/^name_lang\d+$/.test(k) && document.fm[k]) {
						document.fm[k].value = m[k] || '';
						if (m[k]) hasExtraName = true;
					} else if (/^description_lang\d+$/.test(k) && document.fm[k]) {
						document.fm[k].value = m[k] || '';
						if (m[k]) hasExtraDesc = true;
					}
				}
				if (hasExtraName) pfShowExtraLangs('pfExtraNameLangs', 'pfAddNameLangBtn');
				if (hasExtraDesc) pfShowExtraLangs('pfExtraDescLangs', 'pfAddDescLangBtn');
			} else {
				document.getElementById("start_date").setValue(fmtDate(new Date()));
				document.getElementById("end_date").setValue('31.12.9999');
			}
		}
	</script>
	<div id="basepanel" class="panel">
		<iframe name="frm" style="display:none"></iframe>
		<form name="fm" method="post" action="product.jsp?process_code=<%=is_edit?"EDIT_PF_PRODUCT":"CREATE_PF_PRODUCT"%>" target="frm">
			<input type="hidden" name="request" value="save">
			<input type="hidden" name="product_id" value="">
			<input type="hidden" name="code" value="">
			<input type="hidden" name="user_id" value="<%=user.getUserCode()%>">
			<table class="formToolbar" align="center">
				<tr>
					<td>
						<input type="submit" value="<%=lang.get(si_save)%>">
					<td id="tableControls" align="right">
						<input type="button" onclick="parent.close();" value="<%=lang.get(si_exit)%>">
			</table>
			<div style="display:grid;grid-template-columns:2fr;gap:5px">
				<div class="form-group">
					<select name="category_id" r="1" class="form-control"><%
						Statement stC = null;
						ResultSet rsC = null;
						try {
							stC = conn.createStatement();
							rsC = stC.executeQuery("select ID, NAME from PF_R_CATEGORIES_V order by NAME");
							boolean any = false;
							while (rsC.next()) {
								any = true;
								long catId = rsC.getLong("ID");
								String catName = rsC.getString("NAME");
					%>
						<option value="<%=catId%>"><%=esc(catName)%></option><%
							}
							if (!any) {
					%>
						<option value=""><%=lang.get(si_no_categories)%></option><%
							}
						} finally {
							if (rsC != null) rsC.close();
							if (stC != null) stC.close();
						}
					%>
					</select>
					<label><%=lang.get(si_category)%> <q></q>:</label>
				</div>
			</div>
			<div class="section-label" style="margin-top:6px;"><%=lang.get(si_name)%></div>
			<div class="hint" style="margin:-2px 0 6px;"><%=lang.get(si_name_hint)%></div>
			<div style="display:grid;grid-template-columns:1fr 1fr 1fr;gap:5px">
				<div class="form-group">
					<input name="name_uz" mask="255|" class="form-control">
					<label>UZ:</label>
				</div>
				<div class="form-group">
					<input name="name_ru" mask="255|" class="form-control">
					<label>RU:</label>
				</div>
				<div class="form-group">
					<input name="name_en" mask="255|" class="form-control">
					<label>ENG:</label>
				</div>
			</div>
			<div id="pfExtraNameLangs" style="display:none;grid-template-columns:1fr 1fr 1fr;gap:5px;margin-top:5px;"><%
				Statement stLN = null;
				ResultSet rsLN = null;
				try {
					stLN = conn.createStatement();
					rsLN = stLN.executeQuery("select LANG_INDEX, NAME from MLT_LANGUAGES where STATE='A' and LANG_INDEX not in (1,3,4) order by PRIORITY");
					while (rsLN.next()) {
						int langIdx = rsLN.getInt("LANG_INDEX");
						String langName = rsLN.getString("NAME");
			%>
				<div class="form-group">
					<input name="name_lang<%=langIdx%>" mask="255|" class="form-control">
					<label><%=esc(langName)%>:</label>
				</div><%
					}
				} finally {
					if (rsLN != null) rsLN.close();
					if (stLN != null) stLN.close();
				}
			%>
			</div>
			<div style="margin:6px 0 10px;">
				<input type="button" id="pfAddNameLangBtn" onclick="pfShowExtraLangs('pfExtraNameLangs', 'pfAddNameLangBtn');" value="+ <%=lang.get(si_add_lang)%>">
			</div>
			<div class="section-label" style="margin-top:16px;"><%=lang.get(si_description)%></div>
			<div style="display:grid;grid-template-columns:1fr 1fr 1fr;gap:5px">
				<div class="form-group">
					<textarea name="description_uz" rows="2" class="form-control"></textarea>
					<label>UZ:</label>
				</div>
				<div class="form-group">
					<textarea name="description_ru" rows="2" class="form-control"></textarea>
					<label>RU:</label>
				</div>
				<div class="form-group">
					<textarea name="description_en" rows="2" class="form-control"></textarea>
					<label>ENG:</label>
				</div>
			</div>
			<div id="pfExtraDescLangs" style="display:none;grid-template-columns:1fr 1fr 1fr;gap:5px;margin-top:5px;"><%
				Statement stLD = null;
				ResultSet rsLD = null;
				try {
					stLD = conn.createStatement();
					rsLD = stLD.executeQuery("select LANG_INDEX, NAME from MLT_LANGUAGES where STATE='A' and LANG_INDEX not in (1,3,4) order by PRIORITY");
					while (rsLD.next()) {
						int langIdx = rsLD.getInt("LANG_INDEX");
						String langName = rsLD.getString("NAME");
			%>
				<div class="form-group">
					<textarea name="description_lang<%=langIdx%>" rows="2" class="form-control"></textarea>
					<label><%=esc(langName)%>:</label>
				</div><%
					}
				} finally {
					if (rsLD != null) rsLD.close();
					if (stLD != null) stLD.close();
				}
			%>
			</div>
			<div style="margin:6px 0 10px;">
				<input type="button" id="pfAddDescLangBtn" onclick="pfShowExtraLangs('pfExtraDescLangs', 'pfAddDescLangBtn');" value="+ <%=lang.get(si_add_lang)%>">
			</div>
			<div style="display:grid;grid-template-columns:2fr;gap:5px">
				<div class="form-group">
					<select name="delivery_type_id" r="1" class="form-control"><%
						Statement stD = null;
						ResultSet rsD = null;
						try {
							stD = conn.createStatement();
							rsD = stD.executeQuery("select ID, NAME from PF_R_PRODUCT_DELIVERY_TYPES_V order by SORT_ORDER");
							while (rsD.next()) {
								long dtId = rsD.getLong("ID");
								String dtName = rsD.getString("NAME");
					%>
						<option value="<%=dtId%>"><%=esc(dtName)%></option><%
							}
						} finally {
							if (rsD != null) rsD.close();
							if (stD != null) stD.close();
						}
					%>
					</select>
					<label><%=lang.get(si_delivery_type)%> <q></q>:</label>
				</div>
			</div>
			<div style="display:grid;grid-template-columns:2fr;gap:5px">
				<div class="form-group">
					<select name="owner_id" class="form-control"><%
						Statement stO = null;
						ResultSet rsO = null;
						try {
							stO = conn.createStatement();
							rsO = stO.executeQuery("select USER_ID, CB_CODE, NAME from CORE_USERS_V where STATE='A' and IS_ACCESS_DENIED='N' order by NAME");
					%>
						<option value=""><%=lang.get(si_owner_none)%></option><%
							while (rsO.next()) {
								long ownerId = rsO.getLong("USER_ID");
								String ownerLabel = rsO.getString("CB_CODE") + " - " + rsO.getString("NAME");
						%>
						<option value="<%=ownerId%>"><%=esc(ownerLabel)%></option><%
							}
						} finally {
							if (rsO != null) rsO.close();
							if (stO != null) stO.close();
						}
					%>
					</select>
					<label><%=lang.get(si_owner)%>:</label>
				</div>
			</div>
			<div style="display:grid;grid-template-columns:1fr 1fr;gap:5px">
				<div class="form-group">
					<input type="text" id="start_date" name="start_date" mask="date" class="form-control" style="padding-right:30px;">
					<button type="button" class="date-picker-btn" onclick="openDatePicker(document.getElementById('start_date'));">&#128197;</button>
					<label><%=lang.get(si_start_date)%>:</label>
				</div>
				<div class="form-group">
					<input type="text" id="end_date" name="end_date" mask="date" class="form-control" style="padding-right:30px;">
					<button type="button" class="date-picker-btn" onclick="openDatePicker(document.getElementById('end_date'));">&#128197;</button>
					<label><%=lang.get(si_end_date)%>:</label>
				</div>
			</div>
			<div style="margin-bottom:16px;">
				<label style="display:flex;align-items:center;gap:6px;font-size:13px;">
					<input type="checkbox" name="continue_on_expiry" value="1">
					<%=lang.get(si_continue_on_expiry)%>
				</label>
				<div style="font-size:11px;color:#888;margin-top:3px;margin-left:22px;"><%=lang.get(si_continue_on_expiry_hint)%></div>
			</div>
		</form>
	</div>
</t:form>
</t:page>
<t:requests>
	<t:request name="save"><%
		try {
			stored.execJsonRequestProcedure("Core_Api.Execute_Process_Clob", request);
			out.print("<script>alert('" + lang.get(si_success) + "');parent.returnValue=true;parent.close();</script>");
		} catch (Exception ex) {
			response.setHeader("RT", "alert");
			Util.alertUserMessage(ex, out);
			out.print("<script>parent.pageLock(false);</script>");
		}
	%></t:request>
</t:requests>
<%!
	static String esc(String s) {
		if (s == null) return "";
		return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
	}
	static final int si_title = SI("Создать продукт", "Ма&#1203;сулот яратиш", "Mahsulot yaratish", "Create product");
	static final int si_edit_title = SI("Изменить продукт", "Ма&#1203;сулотни &#1118;згартириш", "Mahsulotni o'zgartirish", "Edit product");
	static final int si_category = SI("Категория продукта", "Ма&#1203;сулот категорияси", "Mahsulot kategoriyasi", "Product category");
	static final int si_no_categories = SI("Сначала создайте категорию.", "Аввал категория яратинг.", "Avval kategoriya yarating.", "Create a category first.");
	static final int si_name = SI("Наименование продукта", "Ма&#1203;сулот номи", "Mahsulot nomi", "Product name");
	static final int si_name_hint = SI("Обязательно заполнить хотя бы одно из полей (UZ / RU / ENG).", "Камида биттаси (UZ / RU / ENG) тулдирилиши шарт.", "Kamida bittasi (UZ / RU / ENG) to'ldirilishi shart.", "At least one of the fields (UZ / RU / ENG) must be filled.");
	static final int si_description = SI("Описание продукта", "Ма&#1203;сулот тавсифи", "Mahsulot tavsifi", "Product description");
	static final int si_add_lang = SI("Добавить язык", "Тил &#1179;&#1118;шиш", "Til qo'shish", "Add language");
	static final int si_delivery_type = SI("Тип продукта", "Ма&#1203;сулот тури", "Mahsulot turi", "Product type");
	static final int si_owner = SI("Ответственный сотрудник", "Маъсул ходим", "Mas'ul xodim", "Responsible employee");
	static final int si_owner_none = SI("Не назначен", "Тайинланмаган", "Tayinlanmagan", "Not assigned");
	static final int si_start_date = SI("Дата начала действия", "Бошланиш санаси", "Boshlanish sanasi", "Start date");
	static final int si_end_date = SI("Дата окончания действия", "Тугаш санаси", "Tugash sanasi", "End date");
	static final int si_continue_on_expiry = SI("Связанные продукты продолжают работать после истечения срока", "Бо&#1171;ланган ма&#1203;сулотлар муддати тугаганда ишлашда давом этади", "Bog'langan mahsulotlar muddati tugaganda ishlashda davom etadi", "Linked products keep working after this product expires");
	static final int si_continue_on_expiry_hint = SI("Если срок действия этого продукта истечёт, связанные с ним продукты не будут заблокированы.", "Агар шу ма&#1203;сулот муддати тугаса, у билан бо&#1171;ланган ма&#1203;сулотлар блокланмайди.", "Agar shu mahsulot muddati tugasa, u bilan bog'langan mahsulotlar bloklanmaydi.", "If this product expires, products linked to it are not blocked.");
	static final int si_save = SI("Сохранить", "Са&#1179;лаш", "Saqlash", "Save");
	static final int si_exit = SI("Отмена", "Бекор &#1179;илиш", "Bekor qilish", "Cancel");
	static final int si_success = SI("Успешно выполнено!", "Муваффа&#1179;иятли бажарилди!", "Muvaffaqiyatli bajarildi!", "Successfully executed!");
%>
<%@ include file="/language.jsp" %>
