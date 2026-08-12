<%@ page contentType="text/html;charset=WINDOWS-1251" language="java" %>
<%@ page import="java.sql.*, java.util.*, uz.fido_biznes.cms.*" %>
<%@ page import="oracle.sql.*, oracle.jdbc.*" %>
<%@ taglib uri="/WEB-INF/cms.tld" prefix="t" %>
<jsp:useBean id="cods" class="iabs.oraDBConnection" scope="session"/>
<jsp:useBean id="stored" class="uz.fido_biznes.sql.StoredObject" scope="session"/>
<jsp:useBean id="user" class="iabs.User" scope="session"/>
<%
	Connection conn = cods.getConnection();
	if (conn == null || user.getUserCode() == null) {
		pageContext.setAttribute(Resource.SESSION_EXPIRED, Boolean.TRUE);
	}
	Language lang = new Language(user.getLanguageIndex(), sentences);
	pageContext.setAttribute(Resource.STR_LANGUAGE, lang);
%><t:page><%
	String user_id = request.getParameter("user_id");
	boolean is_edit = (user_id != null && !user_id.equals(""));
	if (is_edit) {
		try {
			out.println("<script>var data=" + stored.execJsonRequestFunction("Core_Api.Get_Model_Clob", request) + ";</script>");
		} catch (Exception ex) {
			Util.alertUserMessage(ex, out);
		}
	}
%><t:form title="<%=is_edit?si_edit_title:si_add_title%>" minWidth="fill" minHeight="fill">
	<script>
      function rowCount(el) {
          return !el ? 0 : (el.tagName ? 1 : el.length);
      }

      function checkPasswords() {
          var n = rowCount(fm.password), i, p, c;
          for (i = 0; i < n; i++) {
              p = getDOMValue(getDOM(fm.password, i));
              c = getDOMValue(getDOM(fm.password_confirm, i));
              if (p != c) {
                  alert("<%=lang.get(si_pwd_mismatch)%>");
                  pageLock(false);
                  return false;
              }
          }
          return true;
      }

      function onLoad() {
          callRequest(fm.local_code);
          callRequest(fm.hr_user_id);
      }
	</script>
	<div id="basepanel" class="panel">
		<iframe name="frm" style="display:none"></iframe>
		<form name="fm" method="post" target="frm" onsubmit="return checkPasswords();">
			<input type="hidden" name="request" value="save">
			<table class="formToolbar" align="center">
				<tr>
					<td>
						<input type="submit" value="<%=lang.get(si_save)%>">
					<td id="tableControls" align="right">
						<input type="button" onclick="parent.close();" value="<%=lang.get(si_exit)%>">
			</table>
			<input type="hidden" name="cb_code" value="00440">
			<input type="hidden" name="user_id" value="">
			<div style="display:grid;grid-template-columns:1fr 2fr;gap:5px">
				<div class="form-group">
					<input name="local_code" mask="5|0-9"
					       reference="{name:'get_local_code',put:[fm.local_code,fm.local_code_name]}"
					       request="{name:'get_local_code',get:{local_code:fm.local_code},put:[fm.local_code_name]}" r="1"
					       class="form-control">
					<label><%=lang.get(si_local_code)%> <q></q>:</label>
				</div>
				<div class="form-group">
					<input name="local_code_name" class="form-control" readonly tabindex="-1">
					<label></label>
				</div>
			</div>
			<div class="form-group">
				<select name="user_type_id" class="form-control" r="1">
					<t:options code="code" name="name" from="core_r_user_types"/>
				</select>
				<label><%=lang.get(si_user_type_id)%> <q></q>:</label>
			</div>
			<div class="form-group">
				<input name="full_name" mask="80|" class="form-control">
				<label><%=lang.get(si_name)%>:</label>
			</div>
			<div class="form-group">
				<input name="pinfl" mask="14|0-9" class="form-control">
				<label><%=lang.get(si_pinfl)%>:</label>
			</div>
			<div class="form-group">
				<input name="date_birth" mask="date" class="form-control">
				<label><%=lang.get(si_date_birth)%>:</label>
			</div>
			<div style="display:grid;grid-template-columns:1fr 2fr;gap:5px">
				<div class="form-group">
					<input name="hr_user_id" mask="10|0-9"
					       reference="{name:'get_hr_user_id',put:[fm.hr_user_id,fm.hr_user_id_name]}"
					       request="{name:'get_hr_user_id',get:{hr_user_id:fm.hr_user_id},put:[fm.hr_user_id_name]}"
					       class="form-control">
					<label><%=lang.get(si_hr_user_id)%>:</label>
				</div>
				<div class="form-group">
					<input name="hr_user_id_name" class="form-control" readonly tabindex="-1">
					<label></label>
				</div>
			</div>
			<fieldset>
				<legend><%=lang.get(si_keys)%>
				</legend>
				<table width="100%" cellspacing="5" cellpadding="0">
					<tr>
						<th style="width:14%" align="left"><%=lang.get(si_provider_type)%>
						</th>
						<th style="width:26%" align="left"><%=lang.get(si_login)%>
						</th>
						<th style="width:20%" align="left"><%=lang.get(si_password)%>
						</th>
						<th style="width:20%" align="left"><%=lang.get(si_password_confirm)%>
						</th>
						<th style="width:9%" align="left"><%=lang.get(si_is_required)%>
						</th>
						<th style="width:10%" align="left"><%=lang.get(si_state)%>
						</th>
						<th style="width:1%">&nbsp;</th>
					</tr>
					<tr>
						<td align="center">
							<input type="hidden" name="identity_id" value="">
							<select name="provider_type" class="form-control" r="1">
								<t:options code="code" name="name" from="core_r_provider_types"/>
							</select>
						</td>
						<td>
							<div class="form-group">
								<input name="provider_key" mask="100|" class="form-control">
								<label></label>
							</div>
						</td>
						<td>
							<div class="form-group">
								<input type="password" name="password" mask="100|" autocomplete="new-password" class="form-control">
								<label></label>
							</div>
						</td>
						<td>
							<div class="form-group">
								<input type="password" name="password_confirm" mask="100|" autocomplete="new-password"
								       class="form-control">
								<label></label>
							</div>
						</td>
						<td align="center">
							<select name="is_required" class="form-control">
								<t:options code="code" name="name" from="core_r_yes_no"/>
							</select>
						</td>
						<td align="center">
							<select name="key_state" class="form-control">
								<t:options code="code" name="name" from="r_state_v"/>
							</select>
						</td>
						<td align="center"><input type="button" insdel="1"/></td>
					</tr>
				</table>
			</fieldset>
			<div class="form-group">
				<input name="phone_number" mask="15|" class="form-control">
				<label><%=lang.get(si_phone_number)%>:</label>
			</div>
			<div class="form-group">
				<input name="email" mask="100|" class="form-control">
				<label><%=lang.get(si_email)%>:</label>
			</div>
			<div class="form-group">
				<select name="is_access_denied" class="form-control">
					<t:options code="code" name="name" from="core_r_access_denieds"/>
				</select>
				<label><%=lang.get(si_is_access_denied)%>:</label>
			</div>
			<div class="form-group">
				<select name="state" class="form-control">
					<t:options code="code" name="name" from="r_state_v"/>
				</select>
				<label><%=lang.get(si_state)%>:</label>
			</div>
			<div class="form-group">
				<input name="activate_date" class="form-control">
				<label><%=lang.get(si_activate_date)%>:</label>
			</div>
			<div class="form-group">
				<input name="deactivate_date" class="form-control">
				<label><%=lang.get(si_deactivate_date)%>:</label>
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
	<t:request name="get_local_code"><%
		try {
			String local_code = request.getParameter("local_code");
			String name = stored.execSelect("select name from core_r_local_codes where code='" + Util.quotesEsc(local_code) + "'");
			if (name.equalsIgnoreCase("")) throw new Exception(lang.get(si_error_code));
			JArray result = new JArray();
			result.push(name);
			out.print(result.toString());
		} catch (Exception ex) {
			response.setHeader("RT", "error");
			out.print(Util.getUserMessage(ex));
		}
	%></t:request>
	<t:request name="get_hr_user_id"><%
		try {
			String hr_user_id = request.getParameter("hr_user_id");
			String name = stored.execSelect("select name from core_r_hr_users where code='" + Util.quotesEsc(hr_user_id) + "'");
			if (name.equalsIgnoreCase("")) throw new Exception(lang.get(si_error_code));
			JArray result = new JArray();
			result.push(name);
			out.print(result.toString());
		} catch (Exception ex) {
			response.setHeader("RT", "error");
			out.print(Util.getUserMessage(ex));
		}
	%></t:request>
</t:requests>
<t:references>
	<t:reference name="get_local_code">
		<t:table from="core_r_local_codes">
			<t:field id="1" name="code" label="<%=si_code%>">
				<t:filter operator="_like_" size="10" showInGrid=""/>
			</t:field>
			<t:field id="2" name="name" label="<%=si_ref_name%>" type="quote">
				<t:filter operator="_search_" showInGrid=""/>
			</t:field>
			<t:grid page="" numbering="" withoutCursor="" hideFilterButton="">
				<t:column for="1"/>
				<t:column for="2" align="left"/>
			</t:grid>
		</t:table>
	</t:reference>
	<t:reference name="get_hr_user_id">
		<t:table from="core_r_hr_users">
			<t:field id="1" name="code" label="<%=si_code%>">
				<t:filter operator="_like_" size="10" showInGrid=""/>
			</t:field>
			<t:field id="2" name="name" label="<%=si_ref_name%>" type="quote">
				<t:filter operator="_search_" showInGrid=""/>
			</t:field>
			<t:grid page="" numbering="" withoutCursor="" hideFilterButton="">
				<t:column for="1"/>
				<t:column for="2" align="left"/>
			</t:grid>
		</t:table>
	</t:reference>
</t:references>
<%!
	static final int si_add_title = SI("Добавление", "Кушиш", "Qo'shish", "Adding");
	static final int si_edit_title = SI("Изменение", "Узгартириш", "O'zgartirish", "Editing");
	static final int si_save = SI("Сохранить", "Сакраш", "Saqlash", "Save");
	static final int si_success = SI("Успешно выполнено!", "Муваффакиятли бажарилди!", "Muvaffaqiyatli bajarildi!", "Successfully executed!");
	static final int si_exit = SI("Выход", "Чикиш", "Chiqish", "Exit");
	static final int si_local_code = SI("Локальный код", "Локал код", "Lokal kod", "Local code");
	static final int si_user_type_id = SI("Тип пользователя", "Фойдаланувчи тури", "Foydalanuvchi turi", "User type");
	static final int si_name = SI("ФИО", "Ф.И.Ш.", "F.I.Sh.", "Full name");
	static final int si_pinfl = SI("ПИНФЛ", "ПИНФЛ", "PINFL", "PINFL");
	static final int si_date_birth = SI("Дата рождения", "Тугилган сана", "Tug'ilgan sana", "Date of birth");
	static final int si_hr_user_id = SI("HR ID", "HR ID", "HR ID", "HR ID");
	static final int si_login = SI("Логин", "Логин", "Login", "Login");
	static final int si_phone_number = SI("Телефон", "Телефон", "Telefon", "Phone");
	static final int si_email = SI("Email", "Email", "Email", "Email");
	static final int si_is_access_denied = SI("Доступ к системе", "Тизимга кириш хукуки", "Tizimga kirish huquqi", "System access");
	static final int si_state = SI("Состояние", "Холати", "Holati", "State");
	static final int si_activate_date = SI("Активен с", "Фаол бошланиш санаси", "Faol boshlanish sanasi", "Active from");
	static final int si_deactivate_date = SI("Активен до", "Фаол муддати", "Faol muddati", "Active until");
	static final int si_code = SI("Код", "Код", "Kod", "Code");
	static final int si_ref_name = SI("Наименование", "Номланиши", "Nomlanishi", "Name");
	static final int si_password = SI("Пароль", "Парол", "Parol", "Password");
	static final int si_password_confirm = SI("Подтверждение пароля", "Паролни тасдиклаш", "Parolni tasdiqlash", "Confirm password");
	static final int si_pwd_mismatch = SI("Пароли не совпадают!", "Пароллар мос келмади!", "Parollar mos kelmadi!", "Passwords do not match!");
	static final int si_provider_type = SI("Тип", "Тип", "Turi", "Type");
	static final int si_keys = SI("Логины и пароли", "Логины и пароли", "Loginlar va parollar", "Logins and passwords");
	static final int si_is_required = SI("Обязательный", "Обязательный", "Majburiy", "Required");
	static final int si_error_code = SI("Код не найден!", "Код топилмади!", "Kod topilmadi!", "Code not found!");
%>
<%@ include file="/language.jsp" %>
