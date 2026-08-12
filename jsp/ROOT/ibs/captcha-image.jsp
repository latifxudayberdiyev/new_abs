<%@ page import="java.net.*, java.io.*" %>
<%
    String imgData = "";
    String errorMessage = null;
	try {
        String url = "http://localhost:3167/captcha/base64";
        URL obj = new URL(url);
        HttpURLConnection con = (HttpURLConnection) obj.openConnection();
        con.setRequestMethod("GET");
        con.setRequestProperty("Content-Type", "application/json");
        con.setDoOutput(true);
	    
	    
        BufferedReader br = new BufferedReader(new InputStreamReader(con.getInputStream(), "utf-8"));
        StringBuilder resp = new StringBuilder();
        String respLine = null;
        while ((respLine = br.readLine()) != null) {
            resp.append(respLine.trim());
        }
	    
        String responseJson = resp.toString();
        String captchaResult = responseJson.split("\"captcha_result\":")[1].split(",")[0];
        String base64 = responseJson.split("\"base64\":\"")[1].split("\"")[0];
        session.setAttribute("captchaResult",Integer.parseInt(captchaResult));
	    
	    imgData =  "data:image/png;base64,"+base64;
	} catch(Exception e) {
		errorMessage = "Captcha server ishlamayapti: " + e.getMessage();
	}
%>

