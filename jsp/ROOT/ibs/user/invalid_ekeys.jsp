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

%><t:page>
<t:form title = "<%= si_formTitle %>" minHeight="fill" minWidth="fill" noCache="">
<table class=formToolbar cellspacing=6>
<tr><td>
    <button onClick="if(go({url:'dvs_user_form.jsp',param:{empCode:getData(1)},target:'modalE'}))go({})">Редактировать</button>
    <button onClick="go({url:'dvs_settings.jsp',target:'modalE'})">Настройки</button>
    <span id=filterControls></span>
  <td align=right id=tableControls>
</table>

<t:table from="asa_ekeys_v">
    <t:field id="2" name="filial_code" labelText="Филиал"><t:filter mask="mfo" labelText="Код филиала" showInGrid="" /></t:field>
    <t:field id="1" name="code" labelText="Код" ><t:filter mask="number(9)" labelText="Код сотрудника" showInGrid="" /></t:field>
    <t:field id="3" name="local_code" labelText="Лок."/>
    <t:field id="4" name="name" type="quote" labelText="Имя"><t:filter operator="_search_" size="30" /></t:field>
    <t:field id="6" name="rank_name" labelText="Должность"><t:filter operator="_search_" size="30" /></t:field>
    <t:field id="9" name="dvs_user_ids" labelText="DVS коды"><t:filter operator="_like_"/></t:field>
    <t:field id="7" name="condition" labelText="Статус"><t:filter option="<%= si_ConditionOption %>" /></t:field>
    <t:field id="8" name="condition_name" labelText="Статус"/>
    <t:grid page="" withoutCursor="" numbering="">
      <t:column for="2" />
      <t:column for="3" />
      <t:column for="1" />
      <t:column for="4" align="left" />
      <t:column for="6" align="left" />
      <t:column for="8" />
      <t:column for="9" />
    </t:grid>
</t:table>
</t:form>
</t:page>
<%!
static final int si_formTitle = SI("DVS ключи","DVS калитлари","DVS kalitlari","");
//-------------------------------------------------------------------------------------------------
%><%@ include file="/language.jsp" %>
