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
String iWhere =" cl_acc like '%"+code+"___'";
%><t:form title="<%=si_title%>" minWidth="fill" minHeight="fill">
<table class="formToolbar" align="center" >
	<tr>
		<td id="sumControls" align="right">
		<td id="tableControls" align="right" >
</table>
<t:table from="Core_Info_Leads_v" where="<%= iWhere%>" >
	<t:field id="1" name="id" label="<%=si_id%>">
		<t:filter operator="=" mask="12|0-9"/>
	</t:field>
	<t:field id="2" name="cl_mfo" label="<%=si_cl_mfo%>" />
	<t:field id="3" name="substr(cl_acc,-20)" label="<%=si_cl_acc%>" >
		<t:filter operator="_like_" />
	</t:field>
	<t:field id="4" name="co_mfo" label="<%=si_co_mfo%>" >
		<t:filter operator="_like_" />
	</t:field>
	<t:field id="5" name="substr(co_acc,-20)" label="<%=si_co_acc%>" >
		<t:filter operator="_like_" />
	</t:field>
	<t:field id="6" name="sum_pay" label="<%=si_sum_pay%>"   type="sum" >
		<t:sum label="<%=si_all_sum_pay%>" type="sum" />
	</t:field>
	<t:field id="7" name="state_id" label="<%=si_state_id%>" type="number" >
		<t:filter optionSQL="select '<option value='|| State_Id||' >' || name from v_Doclead_State" />
	</t:field>
	<t:field id="8" name="state_name" label="<%=si_state_name%>" type="quote" />
	<t:field id="9" name="(select code_emp ||' - '|| core_adm_util.user_name(code_emp, 'N') from dual)" label="<%=si_account_owner%>" type="quote"/>
	<t:field id="10" name="pay_purpose" label="<%=si_purpose%>" type="quote"/>
	<t:field id="11" name="doc_type_id" label="<%=si_doc_name%>" type="quote"/>
	<t:field id="12" name="emp_birth" label="<%=si_emp%>" type="quote"/>
	<t:field id="13" name="op_dc" label="<%=si_operation%>"/>
	<t:grid page="" numbering="" withoutCursor="" >
		<t:column for="1" />
		<t:column for="2" />
		<t:column for="3" />
		<t:column for="4" />
		<t:column for="5" />
		<t:column for="6" align="right"/>
		<t:column for="8" />
		<t:foot>
			<t:row>
				<t:cell for="11" align="left" size="100%" />
				<t:cell for="12" align="left" size="100%" />
			</t:row>
			<t:row>			
				<t:cell for="13" align="left" size="100%" />
				<t:cell for="9" align="left" size="100%" />
			</t:row>
			<t:row>
				<t:cell for="10" colspan="4" align="left" size="100%" />
			</t:row>
		</t:foot>
	</t:grid>
</t:table>
</t:form>
</t:page>
<%!
	static final int si_title				= SI("Просмотр документов ","","","");
	static final int si_id					= SI("ИД документа","","","");
	static final int si_cl_mfo				= SI("МФО<br/>клиента");
	static final int si_cl_acc				= SI("Счет клиента");
	static final int si_co_mfo				= SI("МФО<br/>корреспондента");
	static final int si_co_acc				= SI("Счет корреспондента");
	static final int si_sum_pay				= SI("Сумма");
	static final int si_state_id			= SI("Состояние");
	static final int si_state_name			= SI("Состояние");
	static final int si_all_sum_pay			= SI("Обшая сумма документов");
	static final int si_purpose				= SI("Детали платежа");
	static final int si_doc_name			= SI("Транзакция");
	static final int si_account_owner		= SI("Счет владелеца","","","");
	static final int si_emp					= SI("Сотрудник");
	static final int si_operation			= SI("Операция");
//-------------------------------------------------------------------------------------------------
%><%@ include file="/language.jsp" %>