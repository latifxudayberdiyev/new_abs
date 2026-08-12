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
	String pers_id = stored.execFunction("Core_Env.Pers_Id");
	String themeId = (String) session.getValue("ibs.cms.themeId");
	String themeName = "";
	String cssName = "";
	if("1".equals(themeId)) {
		themeName = "light";
		cssName = "LIGHT";
	} else if("2".equals(themeId)) {
		themeName = "light";
		cssName = "DARK";
	} else {
		themeName = "classic";
	}
%><t:form emptyForm="">
<link rel="stylesheet" type="text/css" href="/ibs/user/font/inter/inter.css" />
<link id="option_theme" rel="stylesheet" type="text/css" href="/ibs/user/util/profile/css/<%= themeName %>.css" />

<script type="text/javascript">
	var dark = "<%= cssName %>";
	function onLoad() {
			document.body.className="bgc_theme";
		ajax.load({
			POST: {
			  request:'get__menu__list'
			},
			async: false,
			onSuccess:function(d) {
				var menuList = getDOM("menuList");
				var r = eval("("+ d +")");
				var menu = "";
				for(var i =0; i<r.d.length; i++) {
					menu+="<li onclick='handleClick(this,"+'"'+'/'+r.d[i].url+'"'+")' class='link'> <span><img class='img' src='/ibs/user/util/profile/icons/" +r.d[i].icon+ "'></span> <a> "+r.d[i].label+"</a> </li>"
				}
				if (isCross()) {
					function replaceAll(text, searchChar, replaceChar) {
						return text.replace(new RegExp(searchChar, 'g'), replaceChar);
					}
					if(dark == "DARK") {
						menuList.innerHTML = replaceAll(menu, ".png", "_active.svg");
						initDOM(menuList);
					}
					else {
						menuList.innerHTML = replaceAll(menu, "png", "svg");
						menuList.innerHTML = replaceAll(menu, "salary.svg", "salary.png");
						initDOM(menuList);
					}
				}
				else {
					menuList.innerHTML = menu;
					initDOM(menuList);
				}
			},onError:function(e) {
				alert(e);
			}
		  })
	}
	function handleClick(elem, url) {
		go({
			url: url,
			target: parent._right,
			lock: false
		});
		if (isCross()) {
			var objs = getDOM("profDiv");
			var liss = objs.getElementsByTagName("li");
			if(dark=="DARK"){
				for (var i = 0; i < liss.length; i++) {
				liss[i].classList.remove("active");
				liss[i].childNodes[3].classList.remove("color");
			}
			elem.classList.add("active");
			elem.childNodes[3].classList.add("color");
			}
			else {
				for (var i = 0; i < liss.length; i++) {
					liss[i].classList.remove("active");
					liss[i].childNodes[1].childNodes[0].classList.remove("active_svg");
					liss[i].childNodes[3].classList.remove("color");
				}
				elem.classList.add("active");
				elem.childNodes[1].childNodes[0].classList.add("active_svg");
				elem.childNodes[3].classList.add("color");
			}
		}
		else {
			var objs = getDOM("profDiv");
			var liss = objs.getElementsByTagName("li");
			for (var i = 0; i < liss.length; i++) {
				liss[i].style.backgroundColor ="#F5F5F5";
				liss[i].childNodes[2].style.color = '#2E2E3A';
				liss[i].childNodes[0].childNodes[0].src=liss[i].childNodes[0].childNodes[0].src.split("_active.png").join(".png");
			}
			elem.style.backgroundColor ="#4785ef";
			elem.childNodes[2].style.color = '#FFFFFF';
			elem.childNodes[0].childNodes[0].src=elem.childNodes[0].childNodes[0].src.split(".png").join("_active.png");
		}
	}
</script>

<div class="main option_jsp">
	<div  class="photo_div">
	<% if(pers_id==null){%>
		<img  style="width:100px; height: auto;" id="photo_user" class="photo_user" src="/ibs/user/util/profile/icons/user_photo_default<%= (("DARK".equals(cssName))?"_dark":"") %>.png"  border=0 width=150 >
	<% } else { %>
		<img  style="width:100px; height: auto;" id="photo_user" class="photo_user" src="get_image.jsp?id=<%=pers_id%>&image_type=EMP"  border=0 width=150 >
	<% } %>
	</div>
	<div id="profDiv">
		<ul id="menuList"></ul>
	</div>
</div>

</t:form>
</t:page>
<t:requests>
<t:request name="get__menu__list" responseType="text"><%
	try {
	  ServletCallableStatement cs = new ServletCallableStatement(stored, request);
	  cs.setFunction("Core_Menu.Get_User_Panel_Menu");
	  cs.execute();
	  out.print(cs.getStringResult());
	} catch (Exception ex) {
	  response.setHeader("RT", "error");
	  out.print(ex.toString());
	}
%>
</t:request>
</t:requests>
<%!
//-------------------------------------------------------------------------------------------------
%><%@ include file="/language.jsp" %>