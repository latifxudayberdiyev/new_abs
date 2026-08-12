<%@ page contentType="text/html;charset=WINDOWS-1251" language="java" %>
<t:requests>
	<t:request name="get_sum_to_word"><%
		String sum = request.getParameter("sum");
		String currency = request.getParameter("currency");
		try {
			ServletCallableStatement cs = new ServletCallableStatement(stored, request);
			cs.setFunction("Core_menu.Get_Sum_Word");
			cs.setNumber("i_Sum", sum);
			cs.setString("i_Code_Currency", currency);
			cs.execute();
			JArray result = new JArray();
			result.push(cs.getStringResult());
			out.print(result.toString());
		} catch (Exception ex) {
			response.setHeader("RT", "error");
			out.print(Util.getUserMessage(ex));
		}
	%></t:request>
	<t:request name="loadForm"><%
		try {
			conn.setAutoCommit(true);
			String formCode = request.getParameter("formCode");
			String recentForm = Util.nvl(request.getParameter("recentForm"), "Y");
			ServletCallableStatement cs = new ServletCallableStatement(stored, request);
			cs.setProcedure("Core_menu.Set_Form_Code");
			cs.setNumber("i_Form_Code", formCode);
			cs.setString("i_Put_Recent_Form", recentForm);
			cs.setString("i_Is_Cross", (Util.isCross(request) ? "Y" : "N"));
			cs.registerString("o_Subsystem_Code");
			cs.registerString("o_Task_Code");
			cs.registerString("o_Url");
			cs.registerArrayString("o_Sub_Menu");
			cs.registerString("o_Support_Page");
			cs.registerString("o_version");
			cs.execute();
			session.putValue("form_code", formCode);
			session.putValue("subsystem", cs.getString("o_Subsystem_Code"));
			session.putValue("ibs.task", cs.getString("o_Task_Code"));
			session.putValue("form_type", "1");
			String sub_menu = "{items:[]}";
/*	String[]sub_menus = cs.getArray("o_Sub_Menu");
	for (int i = 0; i < sub_menus.length; i++) {
		sub_menu += sub_menus[i];
	}*/
			JArray result = new JArray();
			result.push(cs.getString("o_Url"));
			result.push(sub_menu);
			result.push(cs.getString("o_Support_Page"));
			result.push(cs.getString("o_version"));
			out.print(result.toString());
		} catch (Exception ex) {
			response.setHeader("RT", "alert");
			out.print(Util.getUserMessage(ex));
		}
	%></t:request>
	<t:request name="get_help_url"><%
		try {
			ServletCallableStatement cs = new ServletCallableStatement(stored, request);
			cs.setFunction("Core_menu.Help_Url_Data");
			cs.setNumberParameter("i_Form_Code", "formCode");
			cs.execute();
			JArray result = new JArray();
			result.push(cs.getStringResult());
			out.print(result.toString());
		} catch (Exception ex) {
			response.setHeader("RT", "text");
			out.print("NOT_HELP_URL");
		}
	%></t:request>
	<t:request name="change_language"><%
		try {
			ServletCallableStatement cs = new ServletCallableStatement(stored, request);
			cs.setProcedure("Core_Adm_Api.Change_User_Language");
			cs.setNumberParameter("i_Nls_Index", "nls_index");
			cs.execute();
		} catch (Exception ex) {
			response.setHeader("RT", "error");
			out.print(Util.getUserMessage(ex));
		}
	%></t:request>
	<t:request name="chat" responseType="script"><%
		if (!iabs.ChatService.running()) {
			iabs.ChatService.start();
		}
		String lastMessageId = request.getParameter("mID");
		out.print("notifyMsg(" + iabs.ChatService.getNewMessage(user.getFilialCode(), user.getUserCode(), lastMessageId) + ");");
	%></t:request>
	<t:request name="get_menu" responseType="script"><%
		try {
			ServletCallableStatement cs = new ServletCallableStatement(stored, request);
			cs.setProcedure("Core_Menu.Get_Menu_As_Array");
			cs.registerArrayString("o_Array_Menu");
			cs.registerString("o_Recent_Menu");
			cs.execute();
			String menu = "";
			String[] menus = cs.getArray("o_Array_Menu");
			String recent = cs.getString("o_Recent_Menu");
			for (int i = 0; i < menus.length; i++) {
				menu += menus[i];
			}
			out.print("createMenu(" + menu + "," + recent + ");");

	/*
	CallableStatement cs = conn.prepareCall("{? = call Core_menu.Get_Menu_as_clob}");
	cs.registerOutParameter(1, Types.CLOB);
	cs.execute();
	Clob responseBodyClob = cs.getClob(1);
	String menu = responseBodyClob.getSubString(1, (int)responseBodyClob.length());
	String recent = stored.execFunction("Core_menu.Get_Recent_Menu");
	out.print("createMenu(" + menu + "," + recent + ");");
	*/
		} catch (Exception ex) {
			response.setHeader("RT", "alert");
			out.print(Util.getUserMessage(ex));
		}
	%></t:request>
	<t:request name="get_sidebar_menu" responseType="script"><%
		// Ruxsat-nazoratli sidebar (CORE_R_MENUS + CORE_REL_USER_MENUS, rolsiz).
		// get_menu bilan bir xil AJAX-o'ziga-post naqshi: main.jsp'ning o'zi
		// bu so'rovni ushlaydi, sahifa qayta yuklanmaydi (getSidebarMenu(),
		// main.jsp'ning o'z <script> blokida).
		try {
			ServletCallableStatement cs = new ServletCallableStatement(stored, request);
			cs.setProcedure("Core_Sidebar.Get_User_Menu");
			cs.registerArrayString("o_Items");
			cs.execute();
			String[] items = cs.getArray("o_Items");
			JArray result = new JArray();
			for (int i = 0; i < items.length; i++) {
				if (items[i] != null) result.push(items[i]);
			}
			out.print("renderSidebarMenu(" + result.toString() + ");");
		} catch (Exception ex) {
			response.setHeader("RT", "alert");
			out.print(Util.getUserMessage(ex));
		}
	%></t:request>
	<t:request name="set_pin_menu" responseType="script"><%
		try {
			ServletCallableStatement cs = new ServletCallableStatement(stored, request);
			cs.setProcedure("Core_menu.Set_Menu_Pinned");
			cs.setNumberParameter("i_Form_Code", "pinned");
			cs.registerString("o_Get_Pinned_Menu");
			cs.execute();
			out.print("createPin(" + cs.getString("o_Get_Pinned_Menu") + ");");
		} catch (Exception ex) {
			response.setHeader("RT", "alert");
			out.print(Util.getUserMessage(ex));
		}
	%></t:request>
	<t:request name="getReportUrl" responseType="text"><%
		try {
			ServletCallableStatement cs = new ServletCallableStatement(stored, request);
			cs.setProcedure("Core_menu.Get_Report_Url");
			cs.setStringParameter("i_Rep_Code", "formCode");
			cs.registerString("o_Url");
			cs.execute();
			out.print(cs.getString("o_Url"));
		} catch (Exception ex) {
			response.setHeader("RT", "alert");
			out.print(Util.getUserMessage(ex));
		}
	%></t:request>
	<t:request name="get_oper_days" responseType="script"><%
		String day_result = request.getParameter("type");
		String result = "";
		OracleStatement st = null;
		OracleResultSet rs = null;
		String themeId = (String) session.getValue("ibs.cms.themeId");
		String themeName = "";
		if ("1".equals(themeId)) {
			themeName = "_light";
		} else if ("2".equals(themeId)) {
			themeName = "_dark";
		}
		String query = "select '<tr><td>' || Decode((select Setup.Get_Operday from Dual), t.Oper_Day,'<img src=\\\"user/img" + themeName + "/checked.png\\\" class=check_opday>','<img src=\\\"user/img" + themeName + "/unchecked.png\\\" class=check_opday >') || '<td>' || to_char(t.Oper_Day, 'dd.mm.yyyy') || '<td>' || t.Status from Core_Ac_Oper_Days_v t order by t.Oper_Day";
		try {
			st = (OracleStatement) conn.createStatement();
			rs = (OracleResultSet) st.executeQuery(query);
			while (rs.next()) {
				result += rs.getString(1);
			}
			out.print("createOperDen('" + result + "')");
		} catch (Exception ex) {
			response.setHeader("RT", "alert");
			out.print(Util.getUserMessage(ex));
		} finally {
			if (rs != null)
				try {
					rs.close();
				} catch (SQLException ignore) {
				}
			if (st != null)
				try {
					st.close();
				} catch (SQLException ignore) {
				}
		}
	%></t:request>
	<t:request name="set_oper_day" responseType="text"><%
		try {
			ServletCallableStatement cs = new ServletCallableStatement(stored, request);
			cs.setProcedure("Core_menu.Set_Oper_Day_Manual");
			cs.setDateParameter("i_new_Day", "new_operden");
			cs.registerString("o_Is_Future_Date");
			cs.registerString("o_New_Operday");
			cs.execute();
			String isFuture = cs.getString("o_Is_Future_Date");
			out.print(isFuture);
			session.putValue("operDay", cs.getString("o_New_Operday"));
			session.putValue("isFuture", Util.nvl(isFuture));
		} catch (Exception ex) {
			response.setHeader("RT", "alert");
			out.print(Util.getUserMessage(ex));
		}
	%></t:request>
	<t:request name="user_cache" responseType="script"><%
		Hashtable userCache = new Hashtable();
		if (userCache == null) {
			userCache = new Hashtable();
			session.putValue("user_cache", userCache);
		}
		String listValue = "";
		int dayState = 0;

		userCache = null;
	%></t:request>
	<t:request name="last_request" responseType="text"><%
		try {
			out.print(session.getValue("last_request"));
		} catch (Exception ex) {
			response.setHeader("RT", "error");
			out.print(Util.getUserMessage(ex));
		}
	%></t:request>
	<t:request name="get_user_image" responseType="text"><%
		try {
			CallableStatement cs = conn.prepareCall("{call Core_Menu.Get_User_Photo(?,?)}");
			cs.registerOutParameter(1, Types.CLOB);
			cs.registerOutParameter(2, Types.VARCHAR);
			cs.execute();
			Clob responseBodyClob = cs.getClob(1);
			String contentType = cs.getString(2);
			String responseBody = responseBodyClob.getSubString(1, (int) responseBodyClob.length());
			out.print("['" + responseBody + "','" + contentType + "']");
		} catch (Exception ex) {
			response.setHeader("RT", "error");
			out.print(Util.getUserMessage(ex));
		}
	%></t:request>
	<t:request name="set_theme" responseType="text"><%
		try {
			ServletCallableStatement cs = new ServletCallableStatement(stored, request);
			cs.setProcedure("Core_Menu.Change_Theme");
			cs.setNumberParameter("i_Theme_Id", "theme_id");
			cs.execute();
			String employeeCode = (String) session.getValue("employee");
			String themeId = request.getParameter("theme_id");
			String themeUrl = request.getParameter("theme_url");
			uz.fido_biznes.cms.Resource.setThemeURL(employeeCode, themeUrl);
			session.putValue("ibs.cms.themeId", themeId);
			session.putValue("ibs.cms.themeUrl", themeUrl);
			out.print("OK");
		} catch (Exception ex) {
			response.setHeader("RT", "error");
			out.print(Util.getUserMessage(ex));
		}
	%></t:request>
	<t:request name="get_notify" responseType="script"><%
		try {
			String ntf_cnt = stored.execFunction("Core_Menu.Get_Fbsd_Count");
			out.print("fbsdMsg(" + ntf_cnt + ");");
		} catch (Exception ex) {
			out.print("fbsdMsg();");
		}
	%></t:request>
	<t:request name="check_feedback" responseType="script"><%
		try {
			String isExist = stored.execFunction("Core_Menu.Has_Fbsd");
			if (isExist.equals("Y")) {
				out.print("if(is.def(getDOM('btnFeedback'))) showDOM('btnFeedback'); ");
				out.print("if(is.def(getDOM('btnSD'))) showDOM('btnSD'); ");
			}
		} catch (Exception ex) {
			response.setHeader("RT", "error");
			out.print(Util.getUserMessage(ex));
		}
	%></t:request>
	<t:request name="delete_message" responseType="text"><%
		try {
			ServletCallableStatement cs = new ServletCallableStatement(stored, request);
			cs.setProcedure("Chat_Mes.Delete_High_Messages");
			cs.setArrayNumberParameter("i_Message_Ids", "messageId");
			cs.execute();
		} catch (Exception ex) {
			Util.alertUserMessage(ex, out, true);
		}
	%></t:request>
</t:requests>