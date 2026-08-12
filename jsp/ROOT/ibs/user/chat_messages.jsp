<%@ page contentType="text/html;charset=WINDOWS-1251" language="java"%><%
%><%@ page import="java.sql.*,java.util.*, uz.fido_biznes.cms.*" %><%
%><%@ page import="oracle.sql.*, oracle.jdbc.driver.*" %><%
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
  if (request.getParameter("rq") != null) {
    try {
      ServletCallableStatement cs = new ServletCallableStatement(stored, request);
      cs.setProcedure("User_Api.Delete_Chat_Message");
      cs.setArrayNumberParameter("i_message_ids","messageId");
      cs.execute();
      %><script>top.returnValue=true</script><%
    } catch(Exception ex) {
      Util.alertUserMessage(ex, out, false);
    }
  }
%><t:form title = "<%= si_formTitle %>" minHeight="fill" minWidth="fill" >
<script>
function onLoad(){
  if(!dataExist()){
    getDOM('btnDel').disabled = true;
  }
}
</script>
<iframe name=frm width=0 height=0></iframe>
<table class=formToolbar cellspacing=6>
<tr><td>
    <button id=btnDel onClick="go({form:tblForm, param:{rq:'dm'}})"><%=lang.get(si_del)%></button>
  <td align=right id=tableControls><button onclick="top.close()"><%=lang.get(si_exit)%></button>
	<tr class="filterControls"><td colspan=2 align="center"><b><%=lang.get(si_search)%></b><span id="filterControls"></span>
</table>
<t:table from="chat_messages_v">
    <t:field id="1" name="message_id" />
    <t:field id="2" name="message" label="<%=si_message%>" type="quote">
		  <t:filter operator="_search_" showInGrid=""/>
		</t:field>
    <t:field id="3" name="created_on" label="<%=si_created_on%>" type="datetime">
		  <t:filter operator="range" mask="date"/>
		</t:field>
    <t:field id="4" name="created_name" label="<%=si_created_name%>" type="quote"/>
    <t:grid page="" withoutCursor="true" numbering="" withoutSortButtons="">
      <t:column for="1" type="checkbox" name="messageId"/>
      <t:column for="3"/>
      <t:column for="2" align="left"/>
      <t:column for="4" align="left"/>
    </t:grid>
</t:table>
</t:form>
</t:page>
<%!
static final int si_formTitle			= SI("Принятые сообщения","&#1178;абул &#1179;илинган &#1203;абарлар","Qabul qilingan habarlar","");
static final int si_del						= SI("Удалить выбранные сообщения","","","");
static final int si_exit					= SI("Выход","Чи&#1179;иш","Chiqish","Exit");
static final int si_message				= SI("Сообщение","Хабар","Xabar","Message");
static final int si_created_on		= SI("Дата","Сана","Sana","Date");
static final int si_created_name	= SI("Кто создал","Ким яратган","Kim yaratgan","Created name");
static final int si_search							= SI("Поиск : ","&#1178;идирув : ","Qidiruv : ","Search : ");
//-------------------------------------------------------------------------------------------------
%><%@ include file="/language.jsp" %>
