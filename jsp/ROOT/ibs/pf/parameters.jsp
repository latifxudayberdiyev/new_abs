<%@ page contentType="text/html;charset=WINDOWS-1251" language="java" %>
<%@ page import="java.sql.*, java.util.*, uz.fido_biznes.cms.*" %>
<%@ page import="oracle.sql.*, oracle.jdbc.*" %>
<%@ taglib uri="/WEB-INF/cms.tld" prefix="t" %>
<jsp:useBean id="cods" class="iabs.oraDBConnection" scope="session" />
<jsp:useBean id="stored" class="uz.fido_biznes.sql.StoredObject" scope="session" />
<jsp:useBean id="user" class="iabs.User" scope="session" />
<%
	Connection conn = cods.getConnection();
	if (conn == null || user.getUserCode() == null) {
		pageContext.setAttribute(Resource.SESSION_EXPIRED, Boolean.TRUE);
	}
	Language lang = new Language(user.getLanguageIndex(), sentences);
	pageContext.setAttribute(Resource.STR_LANGUAGE, lang);

	/* Grid ustidagi doim ko'rinadigan atribut filtri - dynamicGrid'ning o'z
	   filter paneli (t:dynamicGrid'ning framework darajasidagi IS_FILTER
	   mexanizmi) tugma orqasida yashiringan bo'lib chiqdi, foydalanuvchi esa
	   aynan gridning tepasida doim ko'rinadigan dropdown so'radi. Shu sabab
	   oddiy <select> + to'liq sahifa qayta yuklash (attribute_id so'rov
	   parametri orqali) ishlatiladi, dynamicGrid'ning "where" atributiga
	   (cms.tld'da tasdiqlangan, rtexprvalue=true) uzatiladi. */
	Long selectedAttrId = null;
	String attrIdParam = request.getParameter("attribute_id");
	if (attrIdParam != null && !attrIdParam.equals("")) {
		try {
			selectedAttrId = Long.valueOf(attrIdParam);
		} catch (NumberFormatException ex) {
			selectedAttrId = null;
		}
	}
	String gridWhere = (selectedAttrId != null) ? ("ATTRIBUTE_ID = " + selectedAttrId) : "1=1";

	/* Native <select> BU SAHIFADA UCH XIL usulda ham (statik, JS orqali
	   yaratilgan, formToolbar jadvali ichida/tashqarisida) sinab ko'rildi -
	   hech biri klikka javob bermadi, garchi DOM'da to'g'ri va konsolda xato
	   yo'q edi (foydalanuvchi tomonidan bevosita tekshirilgan va tasdiqlangan).
	   Sabab noma'lum bo'lib qoldi, shu sabab NATIVE SELECT'DAN BUTUNLAY VOZ
	   KECHILDI - o'rniga shu ilovada ANIQ ishlayotgan element turlaridan
	   (input type=button + onclick bilan div qatorlar - xuddi Filial
	   checklist'idagi kabi) o'zining dropdown'i qurilgan (pastga qarang,
	   pfInitAttrFilter()). Atributlar ro'yxati JS massiviga JSON sifatida
	   chiqariladi (statik HTML emas), chunki bu ham document.createElement
	   orqali, sahifa to'liq yuklanganidan keyin (onLoad()da) qurib chiqiladi. */
	StringBuilder attrListJson = new StringBuilder("[");
	String currentFilterLabel = null;
	{
		Statement stAf = null;
		ResultSet rsAf = null;
		boolean firstAf = true;
		try {
			stAf = conn.createStatement();
			rsAf = stAf.executeQuery("select ID, NAME from PF_R_ATTRIBUTES_V order by SORT_ORDER, NAME");
			while (rsAf.next()) {
				if (!firstAf) attrListJson.append(",");
				firstAf = false;
				long afId = rsAf.getLong("ID");
				String afName = rsAf.getString("NAME");
				if (afName == null) afName = "";
				if (selectedAttrId != null && selectedAttrId.longValue() == afId) currentFilterLabel = afName;
				/* Bu qiymat JS satr literaliga qo'yiladi (document.createElement
				   orqali .textContent sifatida ishlatiladi) - HTML entity
				   (&#NNNN;) emas, sof JS-satr escaping kerak, chunki <script>
				   ichida entity hech qachon dekodlanmaydi (xuddi shu xato bu
				   loyihada bir necha marta uchragan - esc() bu yerda NOTO'G'RI). */
				afName = afName.replace("\\", "\\\\").replace("\"", "\\\"");
				attrListJson.append("{\"id\":").append(afId)
					.append(",\"name\":\"").append(afName).append("\"}");
			}
		} finally {
			if (rsAf != null) rsAf.close();
			if (stAf != null) stAf.close();
		}
	}
	attrListJson.append("]");
%><t:page><%
%><t:form minWidth="fill" minHeight="fill">
	<script>
		/* dynamicGrid'da getData(N) dagi N - core_grid_fields.FIELD_ORDER (grid_id=7).
		   select field_order, field_name from core_grid_fields where grid_id = 7 order by field_order. */
		var FO_ID   = 1;
		var FO_CODE = 2;
		var FO_NAME = 3;

		var pfAttrList = <%=attrListJson%>;
		var pfAllAttrsLabel = "<%=lang.get(si_filter_all)%>";
		var pfCurrentFilterLabel = <%=currentFilterLabel != null ? ("\"" + currentFilterLabel.replace("\\","\\\\").replace("\"","\\\"") + "\"") : "null"%>;
		function pfFilterByAttribute(v) {
			location.href = "parameters.jsp" + (v ? ("?attribute_id=" + v) : "");
		}
		/* Native <select> uch xil usulda ham (statik, JS orqali yaratilgan,
		   formToolbar jadvali ichida/tashqarisida) ishlamadi (klikka umuman
		   javob bermadi, konsolda xatosiz) - sababi noma'lum qoldi. Shu sabab
		   shu ilovada ANIQ ishlayotgan element turlaridan (input type=button,
		   onclick bilan div qatorlar - Filial checklist bilan bir xil texnika)
		   o'z dropdown'imiz qurilgan, native select butunlay ishlatilmaydi. */
		function pfInitAttrFilter() {
			var cell = document.getElementById("pfAttrFilterCell");
			if (!cell) return;
			cell.style.paddingLeft = "8px";
			var wrap = document.createElement("div");
			wrap.style.cssText = "position:relative;display:inline-block;margin-right:12px;";

			/* <input type=button> emas, <button> ishlatiladi - ichida ikkita
			   <span> (matn + ikonka) bilan flex joylashuv qilib, ikonkani
			   o'ngning eng chetiga surish uchun (input'ning value'si oddiy
			   matn, ichiga HTML/flex joylashtirib bo'lmaydi). */
			var btn = document.createElement("button");
			btn.type = "button";
			var btnLabel = document.createElement("span");
			btnLabel.textContent = (pfCurrentFilterLabel !== null ? pfCurrentFilterLabel : pfAllAttrsLabel);
			btnLabel.style.cssText = "overflow:hidden;text-overflow:ellipsis;white-space:nowrap;";
			var btnIcon = document.createElement("span");
			/* Pastga qaragan uchburchak belgisi String.fromCharCode orqali
			   quriladi - literal Unicode belgi CP1251'ga o'girishda xato beradi
			   (bu loyihada bir necha marta uchragan xato turi). */
			btnIcon.textContent = String.fromCharCode(9662);
			btnIcon.style.cssText = "flex-shrink:0;margin-left:10px;color:#9AA1B2;";
			btn.appendChild(btnLabel);
			btn.appendChild(btnIcon);
			btn.style.cssText = "display:flex;align-items:center;justify-content:space-between;padding:7px 14px;font-size:13px;font-family:inherit;border:1px solid #ccd2dc;border-radius:7px;cursor:pointer;min-width:170px;text-align:left;transition:border-color .15s;";
			/* form.css'da input[type=button]:hover uchun umumiy qoida bor -
			   u sichqoncha ustiga kelganda background/color'ni oq/oq qilib
			   yozuvni yo'qotib qo'yadi (bu tugma sahifa yuklanganda freymvork
			   initElement()'idan o'tmagan bo'lsa ham, oddiy CSS :hover qoidasi
			   baribir ishlaydi, chunki u JS bilan emas, statik CSS orqali).
			   Shu sabab background/color har doim setProperty(...,'important')
			   bilan majburlanadi - hover holatida ham qayta tiklanadi (xuddi
			   products.jsp'dagi holat tugmalari bilan bo'lgan xato kabi). */
			function pfApplyBtnColors() {
				btn.style.setProperty("background", "#fff", "important");
				btn.style.setProperty("color", "#1C2333", "important");
			}
			pfApplyBtnColors();
			btn.onmouseover = function() { pfApplyBtnColors(); btn.style.borderColor = "#9AA1B2"; };
			btn.onmouseout = function() { pfApplyBtnColors(); btn.style.borderColor = "#ccd2dc"; };

			var menu = document.createElement("div");
			menu.style.cssText = "display:none;position:absolute;top:100%;left:0;margin-top:4px;min-width:100%;max-height:320px;overflow:auto;background:#fff;border:1px solid #e4e7ef;border-radius:8px;box-shadow:0 6px 18px rgba(16,24,52,.12);z-index:1000;padding:4px;";

			function addRow(id, name, isSelected) {
				var row = document.createElement("div");
				row.textContent = name;
				row.style.cssText = "padding:8px 12px;font-size:13px;cursor:pointer;white-space:nowrap;border-radius:5px;" +
					(isSelected ? "color:#3457EF;font-weight:600;background:#EAEEFF;" : "color:#1C2333;");
				row.onmouseover = function() { if (!isSelected) row.style.background = "#F4F5F8"; };
				row.onmouseout = function() { if (!isSelected) row.style.background = ""; };
				row.onclick = function(e) {
					if (e && e.stopPropagation) e.stopPropagation();
					pfFilterByAttribute(id);
				};
				menu.appendChild(row);
			}
			addRow("", pfAllAttrsLabel, pfCurrentFilterLabel === null);
			for (var i = 0; i < pfAttrList.length; i++) {
				addRow(String(pfAttrList[i].id), pfAttrList[i].name, pfAttrList[i].name === pfCurrentFilterLabel);
			}

			btn.onclick = function(e) {
				if (e && e.stopPropagation) e.stopPropagation();
				menu.style.display = (menu.style.display === "none") ? "block" : "none";
			};
			document.addEventListener("click", function() {
				menu.style.display = "none";
			});

			wrap.appendChild(btn);
			wrap.appendChild(menu);
			cell.appendChild(wrap);
		}

		function responseModal(r) {
			if (r) {
				go({});
			}
		}
		function add() {
			go({
				url: "parameter.jsp?process_code=CREATE_PF_PARAMETER",
				target: "modalE",
				dialogHeight: 560,
				dialogWidth: 640,
				lock: false,
				callback: responseModal
			});
		}
		function edit() {
			if (!getDOM("bEdit").disabled) {
				go({
					url: "parameter.jsp?process_code=EDIT_PF_PARAMETER",
					param: {
						model_process_code: "MODEL_PF_PARAMETER",
						code: getData(FO_CODE),
						parameter_id: getData(FO_ID)
					},
					target: "modalE",
					dialogHeight: 560,
					dialogWidth: 640,
					lock: false,
					callback: responseModal
				});
			}
		}
		function del() {
			if (!getDOM("bDelete").disabled) {
				if (confirm("<%=lang.get(si_confirm_delete)%> \"" + getData(FO_NAME) + "\"?")) {
					document.getElementById("pfParamDelRelId").value = getData(FO_ID);
					document.fmParamDel.submit();
				}
			}
		}
		function rules() {
			if (!getDOM("bRules").disabled) {
				go({
					url: "parameter_rules.jsp?parameter_id=" + getData(FO_ID),
					target: "modalE",
					dialogHeight: 500,
					dialogWidth: 700,
					lock: false,
					callback: responseModal
				});
			}
		}
		function onAction() {
			edit();
		}
		function onLoad() {
			/* Filter select'ni birinchi bo'lib, alohida try/catch ichida quramiz -
			   pastdagi grid-bog'liq chaqiruvlar (dataExist/getDOM) xato tashlasa
			   ham (masalan grid hali umuman bo'sh bo'lgan holatda), dropdown baribir
			   qurilib qolishi kerak. */
			try {
				pfInitAttrFilter();
			} catch (e) {}
			if (!dataExist()) {
				getDOM("bEdit").setDisable(true);
				getDOM("bDelete").setDisable(true);
				getDOM("bRules").setDisable(true);
			}
		}
	</script>
	<div style="display:flex;align-items:center;">
		<span id="pfAttrFilterCell" style="display:inline-block;"></span>
		<table class="formToolbar" align="center" style="flex:1;">
			<tr>
				<td>
					<input type="button" name="bAdd" onclick="add();" value="<%=lang.get(si_add)%>">
					<input type="button" name="bEdit" onclick="edit();" value="<%=lang.get(si_edit)%>">
					<input type="button" name="bDelete" onclick="del();" value="<%=lang.get(si_delete)%>">
					<input type="button" name="bRules" onclick="rules();" value="<%=lang.get(si_rules)%>">
				<td id="tableControls" align="right">
			</tr>
		</table>
	</div>
	<%-- table.js (umumiy grid freymvorki) grid_id=7'da IS_FILTER='Y' maydonlar
	     bo'lsa (CODE/NAME/ATTRIBUTE_ID - boshqa dasturchi qo'shgan), shu ID'li
	     element sahifada MAJBURIY bo'lishi kerak, aks holda butun sahifa JS'i
	     "filterControls is not found" xatosi bilan to'xtaydi (2026-08-07,
	     shu xato tufayli butun grid ishlamay qolgan edi). Bizning har doim
	     ko'rinadigan atribut dropdown'imiz (yuqorida, pfAttrFilterCell) asosiy
	     filtr sifatida qoladi - bu esa freymvorkning o'zi talab qiladigan,
	     ichki (native) tezkor-filtr joyi, uni olib tashlab bo'lmaydi. --%>
	<span id="filterControls" style="display:none"></span>
	<div class="grid-card">
		<t:dynamicGrid gridId="7" where="<%=gridWhere%>" />
	</div>
	<iframe name="frmParamDel" style="display:none"></iframe>
	<form name="fmParamDel" method="post" target="frmParamDel">
		<input type="hidden" name="request" value="delete">
		<input type="hidden" name="process_code" value="DELETE_PF_PARAMETER">
		<input type="hidden" name="parameter_id" id="pfParamDelRelId" value="">
		<input type="hidden" name="user_id" value="<%=user.getUserCode()%>">
	</form>
</t:form>
</t:page>
<t:requests>
	<t:request name="delete"><%
		try {
			stored.execJsonRequestProcedure("Core_Api.Execute_Process_Clob", request);
			out.print("<script>parent.location.reload();</script>");
		} catch (Exception ex) {
			response.setHeader("RT", "alert");
			Util.alertUserMessage(ex, out);
		}
	%></t:request>
</t:requests>
<%!
	static final int si_add            = SI("Добавить", "&#1178;&#1118;шиш", "Qo'shish", "Add");
	static final int si_edit           = SI("Изменить", "&#1038;згартириш", "O'zgartirish", "Edit");
	static final int si_delete         = SI("Удалить", "&#1038;чириш", "O'chirish", "Delete");
	static final int si_confirm_delete = SI("Удалить параметр", "Параметрни &#1118;чирасизми", "Parametrni o'chirasizmi", "Delete parameter");
	static final int si_rules          = SI("Правила", "&#1178;оидалар", "Qoidalar", "Rules");
	static final int si_filter_all     = SI("Все атрибуты", "Барча атрибутлар", "Barcha atributlar", "All attributes");
%>
<%@ include file="/language.jsp" %>
