<%@ page contentType="text/html;charset=WINDOWS-1251" language="java" %>
<%@ page import="java.sql.*,java.util.*, uz.fido_biznes.cms.*" %>
<%@ page import="oracle.sql.*, oracle.jdbc.*" %>
<%@ taglib uri="/WEB-INF/cms.tld" prefix="t" %>
<jsp:useBean id="cods" class="iabs.oraDBConnection" scope="session" />
<jsp:useBean id="stored" class="uz.fido_biznes.sql.StoredObject" scope="session" />
<jsp:useBean id="util" class="iabs.oraUtil" scope="session" />
<jsp:useBean id="user" class="iabs.User" scope="session" />
<jsp:useBean id="storedObj" class="iabs.StoredObject" scope="session" />
<%
	Connection conn = cods.getConnection();
	if (conn == null || user.getUserCode() == null)
		pageContext.setAttribute(Resource.SESSION_EXPIRED, Boolean.TRUE);
	Language lang = new Language(user.getLanguageIndex(), sentences);
	pageContext.setAttribute(Resource.STR_LANGUAGE, lang);
//-------------------------------------------------------------------------------------------------
%><t:page><%
	String theme_id = stored.execFunction("Core_Env.Theme_Id");
	String themeId = (String) session.getValue("ibs.cms.themeId");
	String themeName = "";
	String cssName = "";
	if ("1".equals(themeId)) {
		themeName = "light";
		cssName = "light";
	} else if ("2".equals(themeId)) {
		themeName = "dark";
		cssName = "light";
	} else {
		themeName = "classic";
		cssName = "classic";
	}
%><t:form title="<%=si_title%>" minWidth="fill" minHeight="fill">
	<link id="design_theme" rel="stylesheet" type="text/css" href="\ibs\user\util\profile\css\<%= cssName %>.css" />
	<script>
		var theme_name = "<%=  themeName %>";
		var theme_curr_id = "<%=  theme_id %>";

		function onLoad() {
			var css_theme = getDOM("design_theme");
			getThemeList();
		}

		function getThemeList() {
			AJAX.load({
				POST: {
					request: 'get__theme__list'
				},
				onSuccess: function (d) {
					var tds = getDOM("column");
					var r = eval("(" + d + ")");
					var theme_list = "";
					for (var i = 0; i < r.d.length; i++) {
						theme_list += "<div  class='theme_td'><div class='theme_img'  ><img  src='" + r.d[i].photo_path + "_light.png' onclick='setDOMValue(fm.theme_id," + r.d[i].theme_id + ");changeStyle(this)'>  <img   class='img_active " + r.d[i].is_active_theme + '_class' + "' src='/ibs/user/util/profile/theme-photos/active.png'> <div class='rectangle " + r.d[i].is_active_theme + "_class'>  </div> </div><p class='figcaption'>" + r.d[i].label + "</p></div>";
					}
					if (theme_name == "dark") {
						theme_list = theme_list.split("_light.png").join("_dark.png");
						tds.innerHTML = theme_list;
						initDOM(tds);
					} else {
						tds.innerHTML = theme_list;
						initDOM(tds);
					}
				},
				onError: function (e) {
					alert(e);
				}
			});
		}

		function changeTheme() {
			AJAX.load({
				POST: {
					request: 'change_theme',
					themeId: getDOMValue("theme_id")
				},
				onSuccess: function (d) {
					alert(d);
					go({});
				}
			});
		}

		function changeStyle(obj) {
			var tds = getDOM("column");
			for (var i = 0; i < tds.childNodes.length; i++) {
				tds.childNodes[i].childNodes[0].childNodes[2].className = "img_active N_class";
				tds.childNodes[i].childNodes[0].childNodes[4].className = "rectangle N_class";
			}
			obj.nextSibling.nextSibling.className = "img_active Y_class ";
			obj.nextSibling.nextSibling.nextSibling.nextSibling.className = "rectangle Y_class ";
		}
	</script>
	<form name="fm">
		<input type="hidden" id="theme_id" name="theme_id" value="<%=theme_id%>">
		<div class="design_jsp">
			<div id="basepanel">
				<div id="column"></div>
			</div>
			<table id="save_theme" align="center" class="formToolbar">
				<tr>
					<td><input type="button" value="<%=lang.get(si_save)%>" onclick="changeTheme()">
			</table>
		</div>
	</form>
</t:form></t:page>
<t:requests>
	<t:request name="get__theme__list" responseType="text"><%
		try {
			ServletCallableStatement cs = new ServletCallableStatement(stored, request);
			cs.setFunction("core_menu.Get_Themes");
			cs.execute();
			out.print(cs.getStringResult());
		} catch (Exception ex) {
			response.setHeader("RT", "error");
			out.print(ex.toString());
		}
	%></t:request>
	<t:request name="change_theme" responseType="text"><%
		try {
			ServletCallableStatement cs = new ServletCallableStatement(stored, request);
			cs.setProcedure("core_menu.Change_Theme");
			cs.setStringParameter("i_Theme_Id", "themeId");
			cs.execute();
			out.print(lang.get(si_success));
		} catch (Exception ex) {
			response.setHeader("RT", "alert");
			out.print(ex.getMessage());
		}
	%></t:request>
</t:requests>
<%!
	static final int si_title = SI("Оформление", "Расмийлаштириш", "Rasmiylashtirish", "");
	static final int si_save = SI("Сохранить", "Са&#1179;лаш", "Saqlash", "Save");
	static final int si_exit = SI("Закрыть", "Ёпиш", "Yopish", "Exit");
	static final int si_next = SI("Тема будет приниматься со следующего раза!", "Мавзу кейинги сафардан &#1179;абул &#1179;илина бошлайди!", "Mavzu keyingi safardan qabul qilina boshlaydi!", "");
	static final int si_uzc = SI("узбекский(кириллица)", "ўзбекча(кирил.)", "o`zbekcha(kiril.)", "");
	static final int si_uzl = SI("узбекский(латиница)", "ўзбекча(лотин)", "o`zbekcha(lotin)", "");
	static final int si_eng = SI("английский", "инглизча", "inglizcha", "");
	static final int si_success = SI("Успешно выполнено! Пожалуйста, войдите снова, чтобы применить тему", "Муваффакиятли бажарилди! Илтимос, тема ?ўлланилиши учун тизимга ?айта киринг", "Muvaffaqiyatli bajarildi! Iltimos, tema qo'llanilishi uchun tizimga qayta kiring", "Completed successfully! Please log in again to apply the theme");
//-------------------------------------------------------------------------------------------------
%>
<%@ include file="/language.jsp" %>
