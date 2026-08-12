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

  String user_id = stored.execFunction("Setup.Employee_Code");
%>

<t:form >
  <form name="fm" method="post">
    <input type="hidden" name="request" value="deactivate">
    <input type="hidden" name="action" value="D">
    <input type="hidden" name="user_id" value="<%=user_id%>">
  </form>

  <script>
  if(confirm("<%=lang.get(si_confirm)%>"))
    _.fm.submit();
  else
  {
    go({url:'profile.jsp', target:parent._right, lock:false});
    //top.goSetting(top);
  }

  </script>
</t:form></t:page>

<t:request name="deactivate"><%
  try{
    ServletCallableStatement cs = new ServletCallableStatement(stored,request);
    cs.setProcedure("core_adm_api.Change_User_State");
    cs.setAllParameters("request");
    cs.execute();%>
    <script>
      alert('<%= lang.get(si_success) %>');
      // logging out without dialog form
      top.closeNav();
      top.outPage();
    </script><%
  } catch(Exception ex) {
    %><script>alert('<%= Util.quotesEsc(Util.getUserMessage(ex)) %>')</script><%
  }
%></t:request>

<%!
static final int si_success = SI("Успешно выполнено!","Муваффа&#1179;иятли  бажарилди!","Muvaffaqiyatli bajarildi!","Successfully executed!");
static final int si_confirm = SI("Вы уверены, что хотите деактивировать свой аккаунт?","","","");



//-------------------------------------------------------------------------------------------------
%><%@ include file="/language.jsp" %>