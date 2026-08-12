<%@ page contentType="text/html;charset=WINDOWS-1251" language="java" %>
<%@ page import="java.sql.*,java.util.*, uz.fido_biznes.cms.*" %>
<%@ page import="oracle.sql.*, oracle.jdbc.*" %>
<%
	if (iabs.ChatService.running()) {
		out.println("chat is running");
	} else {
		out.println("chat is not running");
	}

	out.println(iabs.ChatService.getChatState());
%>