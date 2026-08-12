<%
  if (request.getHeader("Referer") == null) {
	out.print("Access denied.");
	return;
  }
%>