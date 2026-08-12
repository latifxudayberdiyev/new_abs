<%@ page contentType="text/html;charset=WINDOWS-1251" language="java"%><%
%><%@ page import="java.sql.*,java.util.*, uz.fido_biznes.cms.*" %><%
%><%@ page import="oracle.sql.*, oracle.jdbc.*" %><%
%><%@ taglib uri="/WEB-INF/cms.tld" prefix="t"%><%
%><jsp:useBean id="cods" class="iabs.oraDBConnection" scope="session" /><%
%><jsp:useBean id="stored" class="uz.fido_biznes.sql.StoredObject" scope="session"/><%
%><jsp:useBean id="user" class="iabs.User" scope="session" /><%
	Connection conn = cods.getConnection();
	if (conn == null || user.getUserCode() == null)
		pageContext.setAttribute(Resource.SESSION_EXPIRED, Boolean.TRUE);
	Language lang = new Language(user.getLanguageIndex(), sentences);
	pageContext.setAttribute(Resource.STR_LANGUAGE, lang);
//-------------------------------------------------------------------------------------------------
%><t:page><%
	ServletCallableStatement cs = null;
	if (request.getParameter("sbmt") != null) {
		try {
			cs = new ServletCallableStatement(stored, request);
			cs.setProcedure("User_Api.Save_Asa_Settings");
			cs.setStringParameter("i_g_Check_Signature","gcs");
			cs.setStringParameter("i_g_Check_User_Registered","gur");
			cs.setStringParameter("i_g_Check_Signature_Onlogon","gso");
			cs.setStringParameter("i_g_Check_Serial_Number","gsn");
			cs.setArrayStringParameter("i_Check_Signature","cs");
			cs.setArrayStringParameter("i_Check_User_Registered","ur");
			cs.setArrayStringParameter("i_Check_Signature_Onlogon","so");
			cs.execute();
			%><script>function onLoad(){alert('Данные сохранены успешно!');}</script><%
		} catch (Exception ex) {
			Util.alertUserMessage(ex, out);
		}
	}
	%><script>data=<%= stored.execFunction("User_Api.Asa_Settings_Model") %></script><%
%><t:form noCache="" titleText="Закрепление DVS-ключей" minWidth="fill" minHeight="fill">
<table align=center class=formToolbar cellspacing=2>
	<tr><td><button onclick="go({form:tblForm,param:{sbmt:'',gcs:fm.gcs.getValue('N'),gur:fm.gur.getValue('N'),gso:fm.gso.getValue('N'),gsn:fm.gsn.getValue('N')}})">Сохранить</button>
	<td align=right id=tabControls><button onclick="top.close()">Выход</button>
</table>
<fieldset><legend>Глобалная настройка</legend>
<form name=fm>
<table>
	<tr><td><label><input type=checkbox name=gcs value=Y>Включить проверку ЭЦП</label>
	<tr><td><label><input type=checkbox name=gur value=Y>Регистрация пользователя в DVS обязательна</label>
	<tr><td><label><input type=checkbox name=gso value=Y>Проверить ЭЦП при авторизации пользователя</label>
	<tr><td><label><input type=checkbox name=gsn value=Y>Проверка серийного номера ключа</label>
	<td id="tableControls" align="right">
</table>
</form>
</fieldset>
<t:table from="asa_settings_v" >
	<t:field id="1" name="filial_code" labelText="Филиал коди" >
		<t:sort orderKey="1" />
	</t:field>
	<t:field id="2" name="name" labelText="Наименование" />
	<t:field id="3" name="check_signature" />
	<t:field id="4" name="user_registered" />
	<t:field id="5" name="signature_onlogon" />
	<t:grid numbering="" withoutCursor="" withoutRefreshButton="">
		<t:column for="1" />
		<t:column for="2" align="left" />
		<t:column for="1" type="checkbox" name="cs" checked="3" nowrap="" labelText="ЕЦП вкл" />
		<t:column for="1" type="checkbox" name="ur" checked="4" nowrap="" labelText="Рег.обязат." />
		<t:column for="1" type="checkbox" name="so" checked="5" nowrap="" labelText="ЕЦП при входе" />
	</t:grid>
</t:table>
</t:form>
</t:page>
<%!
//-------------------------------------------------------------------------------------------------
%><%@ include file="/language.jsp" %>
