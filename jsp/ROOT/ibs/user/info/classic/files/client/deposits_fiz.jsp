<%@ page contentType="text/html;charset=WINDOWS-1251" language="java"%><%
%><%@ page import="java.sql.*,java.util.*, uz.fido_biznes.cms.*" %><%
%><%@ page import="oracle.sql.*, oracle.jdbc.*" %><%
%><%@ taglib uri="/WEB-INF/cms.tld" prefix="t"%><%
%><jsp:useBean id="cods" class="iabs.oraDBConnection" scope="session" /><%
%><jsp:useBean id="stored" class="uz.fido_biznes.sql.StoredObject" scope="session"/><%
%><jsp:useBean id="user" class="iabs.User" scope="session" /><%
	Connection conn = cods.getConnection();
	if(conn == null || user.getUserCode() == null)
		pageContext.setAttribute(Resource.SESSION_EXPIRED, Boolean.TRUE);
	Language lang = new Language(user.getLanguageIndex(), sentences);
	pageContext.setAttribute(Resource.STR_LANGUAGE, lang);
//-------------------------------------------------------------------------------------------------
%><t:page><%
String code         = stored.decryptParameterValue(request,"code","CORE_INFO");//request.getParameter("code");
String iWhere =" client_code = '"+code+"'";
%><t:form title="<%=si_title%>" minWidth="fill" minHeight="fill">
<table class="formToolbar" align="center" >
	<tr>
		<td>
		<td id="tableControls" align="right" >
</table>
<t:table from="core_info_dep_fiz_v" where="<%= iWhere %>">
	<t:field id="1" name="SAV_DEP_ID" label="<%=si_SAV_DEP_ID%>" />
	<t:field id="2" name="FILIAL_CODE" label="<%=si_FILIAL_CODE%>" />
	<t:field id="3" name="LOCAL_CODE" label="<%=si_LOCAL_CODE%>" />
	<t:field id="4" name="DEP_ID" label="<%=si_DEP_ID%>" />
	<t:field id="5" name="DEP_ID_CHAR" label="<%=si_DEP_ID_CHAR%>" />
	<t:field id="6" name="DEP_NAME" label="<%=si_DEP_NAME%>" type="quote" >
		<t:filter operator="_search_" />
	</t:field>
	<t:field id="7" name="COA_CODE" label="<%=si_COA_CODE%>" >
		<t:filter operator="_like_" />
	</t:field>
	<t:field id="8" name="CURRENCY_CODE" label="<%=si_CURRENCY_CODE%>" >
		<t:filter operator="=" />
	</t:field>
	<t:field id="9" name="PERS_ACC" label="<%=si_PERS_ACC%>" >
		<t:filter operator="_like_" />
	</t:field>
	<t:field id="10" name="ACC" label="<%=si_ACC%>" >
		<t:filter operator="_like_" />
	</t:field>
	<t:field id="11" name="ACC_PERCENT" label="<%=si_ACC_PERCENT%>" >
		<t:filter operator="_like_" />
	</t:field>
	<t:field id="12" name="OPEN_DATE" label="<%=si_OPEN_DATE%>" type="date" >
		<t:filter operator="=" />
	</t:field>
	<t:field id="13" name="TERM_PAYMENT" label="<%=si_TERM_PAYMENT%>" type="date" />
	<t:field id="14" name="EXPECTED_CLOSING_DATE" label="<%=si_EXPECTED_CLOSING_DATE%>" type="date" />
	<t:field id="15" name="DATE_CLOSE" label="<%=si_DATE_CLOSE%>" type="date" />
	<t:field id="16" name="SUMMA" label="<%=si_SUMMA%>" type="sum" />
	<t:field id="17" name="STATE_ID" label="<%=si_STATE_ID%>" />
	<t:field id="18" name="STATE_NAME" label="<%=si_STATE_NAME%>" type="quote" />
	<t:field id="19" name="CLIENT_CODE" label="<%=si_CLIENT_CODE%>" />
	<t:field id="20" name="CLIENT_ID" label="<%=si_CLIENT_ID%>" />
	<t:grid page="" numbering="" withoutCursor="" >
		<t:column for="1" />
		<t:column for="2" />
		<t:column for="6" />
		<t:column for="7" />
		<t:column for="8" />
		<t:column for="9" />
		<t:column for="10" />
		<t:column for="11" />
		<t:column for="16" />
		<t:column for="18" />
		<t:foot>
			<t:row>
				<t:cell for="12" />
				<t:cell for="13" />
				<t:cell for="14" />
				<t:cell for="15" />
			</t:row>
		</t:foot>
	</t:grid>
</t:table>
</t:form>
</t:page>
<%!
	static final int si_title					= SI(" ","","","");
	static final int si_SAV_DEP_ID				= SI("ID","","","");
	static final int si_FILIAL_CODE				= SI("Код филиала","","","");
	static final int si_LOCAL_CODE				= SI("Код локальной структуры","","","");
	static final int si_DEP_ID					= SI("ID вклада","","","");
	static final int si_DEP_ID_CHAR				= SI("Код вклада (Символьний)","","","");
	static final int si_DEP_NAME				= SI("Наименование вклада","","","");
	static final int si_COA_CODE				= SI("Балансовый счет","","","");
	static final int si_CURRENCY_CODE			= SI("Валюта","","","");
	static final int si_PERS_ACC				= SI("Номер депозитного счета (Л/С)","","","");
	static final int si_ACC						= SI("Депозитный Счет  (2xxxx)","","","");
	static final int si_ACC_PERCENT				= SI("Процентный Счет  (22xxx)","","","");
	static final int si_OPEN_DATE				= SI("Дата открытия","","","");
	static final int si_TERM_PAYMENT			= SI("Дата выплаты процентов","","","");
	static final int si_EXPECTED_CLOSING_DATE	= SI("Дата окончания","","","");
	static final int si_DATE_CLOSE				= SI("Дата фактический закрытия","","","");
	static final int si_SUMMA					= SI("Сумма вклада","","","");
	static final int si_STATE_ID				= SI("Состояние вклада","","","");
	static final int si_STATE_NAME				= SI("Состояние","","","");
	static final int si_CLIENT_CODE				= SI("Код клиента","","","");
	static final int si_CLIENT_ID				= SI("ID клиента","","","");
	
//-------------------------------------------------------------------------------------------------
%><%@ include file="/language.jsp" %>