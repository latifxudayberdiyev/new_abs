<%@page language="java" import="uz.fido_biznes.cms.*" %>
<%
	User user = (User) session.getValue(Resource.STR_USER);
	Resource.evalRequest(user, request, response);
	uz.fido_biznes.cms.Resource resource = new uz.fido_biznes.cms.Resource();
%>
<link rel=stylesheet type="text/css" href="/<%=user.getContextPath()%>themes/<%=resource.getThemeURL()%>.css">