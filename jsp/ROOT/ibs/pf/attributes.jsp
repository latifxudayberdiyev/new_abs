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
%><t:page><%
%><t:form minWidth="fill" minHeight="fill">
	<script>
		/* dynamicGrid'da getData(N) dagi N - core_grid_fields.FIELD_ORDER (grid_id=8).
		   select field_order, field_name from core_grid_fields where grid_id = 8 order by field_order. */
		var FO_ID          = 1;
		var FO_CODE        = 2;
		var FO_NAME        = 3;
		var FO_MODULE_CODE = 5;
		var FO_IS_DEFAULT  = 9;

		/* Eski pf-css jadvaldagi rangli badge ko'rinishini dynamicGrid ustida
		   qayta hosil qilamiz: sarlavha matnidan ustun indeksini topamiz (barcha
		   4 til varianti bo'yicha), keyin har bir qatorda shu katakni <span> pill
		   bilan almashtiramiz. errors.jsp'dagi stylizeModules() bilan bir xil usul. */
		var TXT_TYPE_HEADERS    = ["Тип", "Тури", "Turi", "Type"];
		var TXT_CAT_HEADERS     = ["Категорий", "Категориялар", "Kategoriyalar", "Categories"];
		var TXT_PARAM_HEADERS   = ["Параметров", "Параметрлар", "Parametrlar", "Parameters"];
		var TXT_DEFAULT_HEADERS = ["По умолчанию", "Стандарт", "Standart", "Default"];
		/* HTML entity (masalan &#1203;) faqat markup kontekstida dekodlanadi,
		   <script> ichidagi qator literalida emas - shu uchun matnni to'g'ridan-to'g'ri
		   emas, yashirin <span>'dan (onLoad'da, DOM tayyor bo'lgach) textContent
		   orqali o'qiymiz. */
		var TXT_TYPE_EDITABLE = "";
		var TXT_TYPE_MODULE   = "";
		var TXT_TYPE_SPECIAL  = "";
		var TXT_DEFAULT_YES   = "";

		var colTypeIdx = -1, colCatIdx = -1, colParamIdx = -1, colDefaultIdx = -1, colsResolved = false;

		function findColIndex(headerTexts) {
			var table = document.getElementById("tbl");
			if (!table || !table.tHead || !table.tHead.rows.length) return -1;
			var cells = table.tHead.rows[0].cells;
			for (var i = 0; i < cells.length; i++) {
				var txt = cells[i].textContent.replace(/\s+/g, " ").trim();
				for (var j = 0; j < headerTexts.length; j++) {
					if (txt === headerTexts[j]) return i;
				}
			}
			return -1;
		}

		function pfPill(text, bg, fg) {
			var span = document.createElement("span");
			span.setAttribute("data-pf-pill", "1");
			span.style.cssText = "display:inline-block;padding:3px 10px;border-radius:999px;font:700 11px Arial,sans-serif;white-space:nowrap;background:" + bg + ";color:" + fg + ";";
			span.textContent = text;
			return span;
		}

		function pfStylizeCell(td, kind) {
			if (!td || (td.firstChild && td.firstChild.getAttribute && td.firstChild.getAttribute("data-pf-pill"))) return;
			var raw = td.textContent.trim();
			var span;
			if (kind === "type") {
				if (raw === "EDITABLE") {
					span = pfPill(TXT_TYPE_EDITABLE, "#e8f0fe", "#1a56db");
				} else if (raw === "SPECIAL") {
					span = pfPill(TXT_TYPE_SPECIAL, "#fdf0e0", "#c07a1b");
				} else {
					span = pfPill(TXT_TYPE_MODULE, "#eef0f4", "#667085");
				}
			} else if (kind === "default") {
				/* raw="0" holatida ko'rinadigan pill kerak emas, lekin bo'sh
				   <td> qoldirilsa yuqoridagi "allaqachon ishlangan" belgisi
				   (data-pf-pill) yo'qolib, MutationObserver har safar qayta
				   ishlashga urinadi va raw qiymatini abadiy yo'qotadi - shu
				   sabab har doim (ko'rinmas bo'lsa ham) belgilangan span
				   qoldiramiz. */
				span = raw === "1" ? pfPill(TXT_DEFAULT_YES, "#e0f2ea", "#1a7f5a") : pfPill("", "transparent", "transparent");
			} else {
				var n = parseInt(raw, 10) || 0;
				span = n > 0 ? pfPill(String(n), "#e0f2ea", "#1a7f5a") : pfPill(String(n), "#eef0f4", "#98a2b3");
			}
			td.innerHTML = "";
			td.appendChild(span);
		}

		function pfStylizeGrid() {
			var table = document.getElementById("tbl");
			if (!table || !table.tBodies.length) return;
			if (!colsResolved) {
				colTypeIdx    = findColIndex(TXT_TYPE_HEADERS);
				colCatIdx     = findColIndex(TXT_CAT_HEADERS);
				colParamIdx   = findColIndex(TXT_PARAM_HEADERS);
				colDefaultIdx = findColIndex(TXT_DEFAULT_HEADERS);
				colsResolved = (colTypeIdx >= 0 || colCatIdx >= 0 || colParamIdx >= 0 || colDefaultIdx >= 0);
			}
			var rows = table.tBodies[0].rows;
			for (var r = 0; r < rows.length; r++) {
				if (colTypeIdx    >= 0) pfStylizeCell(rows[r].cells[colTypeIdx], "type");
				if (colCatIdx     >= 0) pfStylizeCell(rows[r].cells[colCatIdx], "count");
				if (colParamIdx   >= 0) pfStylizeCell(rows[r].cells[colParamIdx], "count");
				if (colDefaultIdx >= 0) pfStylizeCell(rows[r].cells[colDefaultIdx], "default");
			}
		}

		function pfObserveGrid() {
			var table = document.getElementById("tbl");
			if (!table || !window.MutationObserver) return;
			new MutationObserver(function () { pfStylizeGrid(); }).observe(table, { childList: true, subtree: true });
		}

		function responseModal(r) {
			if (r) {
				go({});
			}
		}
		function add() {
			go({
				url: "attribute.jsp?process_code=CREATE_PF_ATTRIBUTE",
				target: "modalE",
				dialogHeight: 460,
				dialogWidth: 520,
				lock: false,
				callback: responseModal
			});
		}
		function edit() {
			if (!getDOM("bEdit").disabled) {
				go({
					url: "attribute.jsp?process_code=EDIT_PF_ATTRIBUTE",
					param: {
						model_process_code: "MODEL_PF_ATTRIBUTE",
						code: getData(FO_CODE),
						attribute_id: getData(FO_ID)
					},
					target: "modalE",
					dialogHeight: 460,
					dialogWidth: 520,
					lock: false,
					callback: responseModal
				});
			}
		}
		function del() {
			if (!getDOM("bDelete").disabled) {
				if (confirm("<%=lang.get(si_confirm_delete)%> \"" + getData(FO_NAME) + "\"?")) {
					document.getElementById("pfAttrDelRelId").value = getData(FO_ID);
					document.fmAttrDel.submit();
				}
			}
		}
		function onAction() {
			edit();
		}
		function onSelect() {
			/* "Har doim ko'rsatilsin" deb belgilangan atributlar (masalan
			   Umumiy, Filial) - tizim darajasidagi doimiy atributlar,
			   gridda ham o'chirish tugmasi bloklanadi (Pf_Kernel.Delete_Attribute
			   serverda ham xuddi shunday rad etadi). */
			getDOM("bDelete").setDisable(!!getData(FO_MODULE_CODE) || getData(FO_IS_DEFAULT) == 1);
		}
		function onLoad() {
			if (!dataExist()) {
				getDOM("bEdit").setDisable(true);
				getDOM("bDelete").setDisable(true);
			}
			TXT_TYPE_EDITABLE = document.getElementById("pfTxtTypeEditable").textContent;
			TXT_TYPE_MODULE   = document.getElementById("pfTxtTypeModule").textContent;
			TXT_TYPE_SPECIAL  = document.getElementById("pfTxtTypeSpecial").textContent;
			TXT_DEFAULT_YES   = document.getElementById("pfTxtDefaultYes").textContent;
			pfStylizeGrid();
			pfObserveGrid();
		}
	</script>
	<span id="pfTxtTypeEditable" style="display:none"><%=lang.get(si_type_editable)%></span>
	<span id="pfTxtTypeModule" style="display:none"><%=lang.get(si_type_module)%></span>
	<span id="pfTxtTypeSpecial" style="display:none"><%=lang.get(si_type_special)%></span>
	<span id="pfTxtDefaultYes" style="display:none"><%=lang.get(si_default_yes)%></span>
	<table class="formToolbar" align="center">
		<tr>
			<td>
				<input type="button" name="bAdd" onclick="add();" value="<%=lang.get(si_add)%>">
				<input type="button" name="bEdit" onclick="edit();" value="<%=lang.get(si_edit)%>">
				<input type="button" name="bDelete" onclick="del();" value="<%=lang.get(si_delete)%>">
			<td id="tableControls" align="right">
		</tr>
	</table>
	<%-- table.js grid_id=8'da IS_FILTER='Y' maydon (NAME) borligi sababli
	     shu ID'li elementni MAJBURIY talab qiladi, aks holda butun sahifa
	     JS'i "filterControls is not found" xatosi bilan to'xtaydi va grid
	     bo'sh ko'rinadi (2026-08-07, parameters.jsp'da xuddi shu sabab bilan
	     topilgan/tuzatilgan muammo bilan bir xil - bu yerda mustaqil
	     ravishda ham mavjud ekan). --%>
	<span id="filterControls" style="display:none"></span>
	<div class="grid-card">
		<t:dynamicGrid gridId="8" />
	</div>
	<iframe name="frmAttrDel" style="display:none"></iframe>
	<form name="fmAttrDel" method="post" target="frmAttrDel">
		<input type="hidden" name="request" value="delete">
		<input type="hidden" name="process_code" value="DELETE_PF_ATTRIBUTE">
		<input type="hidden" name="attribute_id" id="pfAttrDelRelId" value="">
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
	static final int si_confirm_delete = SI("Удалить атрибут", "Атрибутни &#1118;чирасизми", "Atributni o'chirasizmi", "Delete attribute");
	static final int si_type_editable  = SI("Редактируемый", "Та&#1203;рирланадиган", "Tahrirlanadigan", "Editable");
	static final int si_type_module    = SI("От модуля", "Модулдан", "Moduldan", "From module");
	static final int si_type_special   = SI("Специальный", "Махсус", "Maxsus", "Special");
	static final int si_default_yes    = SI("Да", "&#1202;а", "Ha", "Yes");
%>
<%@ include file="/language.jsp" %>
