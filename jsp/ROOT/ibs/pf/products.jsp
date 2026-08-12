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
		/* dynamicGrid'da getData(N) dagi N - core_grid_fields.FIELD_ORDER (grid_id=9).
		   select field_order, field_name from core_grid_fields where grid_id = 9 order by field_order. */
		var FO_ID          = 1;
		var FO_CODE        = 2;
		var FO_NAME        = 3;
		var FO_STATE       = 8;
		var FO_VERSION_NO  = 9;

		/* Eski pf-css jadvaldagi rangli badge/chip ko'rinishini dynamicGrid ustida
		   qayta hosil qilamiz - errors.jsp'dagi stylizeModules() bilan bir xil usul:
		   sarlavha matnidan ustun indeksini topib, har bir qatorda katak ichini
		   <span> bilan almashtiramiz. Maxsus (o'zbekcha) harflar bo'lgan matnlarni
		   <script> ichida emas, yashirin <span>'lardan (HTML entity to'g'ri
		   dekodlanadigan joy) o'qiymiz. */
		var pfColors = ["#3457EF", "#7C5CFC", "#178A4C", "#C88A1B", "#D64545", "#0E9A93", "#DB2777"];
		var stateColors = {DRAFT:"#9AA1B2", ON_APPROVAL:"#C88A1B", ACTIVE:"#178A4C", SUSPENDED:"#D64545", PASSIVE:"#0E9A93", ARCHIVED:"#6B7280"};
		var stateTextIds = {DRAFT:"pfStDraft", ON_APPROVAL:"pfStOnApproval", ACTIVE:"pfStActive", SUSPENDED:"pfStSuspended", PASSIVE:"pfStPassive", ARCHIVED:"pfStArchived"};

		var hdrId = "", hdrCategory = "", hdrType = "", hdrStatus = "", hdrVersion = "", hdrHistory = "";
		var colIdIdx = -1, colCategoryIdx = -1, colTypeIdx = -1, colStatusIdx = -1, colVersionIdx = -1, colHistoryIdx = -1;
		var colsResolved = false;

		function pfHash(s) {
			var h = 0;
			for (var i = 0; i < s.length; i++) {
				h = (h * 31 + s.charCodeAt(i)) & 0xffffffff;
			}
			return Math.abs(h);
		}

		function findColIndex(headerText) {
			var table = document.getElementById("tbl");
			if (!table || !table.tHead || !table.tHead.rows.length || !headerText) return -1;
			var cells = table.tHead.rows[0].cells;
			for (var i = 0; i < cells.length; i++) {
				var txt = cells[i].textContent.replace(/\s+/g, " ").trim();
				if (txt === headerText) return i;
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

		function pfChip(text, color) {
			var span = document.createElement("span");
			span.setAttribute("data-pf-pill", "1");
			span.style.cssText = "display:inline-flex;align-items:center;gap:6px;font:600 12px Arial,sans-serif;padding:4px 9px 4px 6px;border-radius:20px;white-space:nowrap;background:" + color + "18;color:" + color + ";";
			var dot = document.createElement("span");
			dot.style.cssText = "width:7px;height:7px;border-radius:50%;flex-shrink:0;background:" + color + ";";
			span.appendChild(dot);
			span.appendChild(document.createTextNode(text));
			return span;
		}

		function pfMono(text) {
			var span = document.createElement("span");
			span.setAttribute("data-pf-pill", "1");
			span.style.cssText = "font-family:'SF Mono',ui-monospace,Menlo,Consolas,monospace;font-size:12px;color:#6B7280;";
			span.textContent = text;
			return span;
		}

		function pfAlreadyStyled(td) {
			return td && td.firstChild && td.firstChild.getAttribute && td.firstChild.getAttribute("data-pf-pill");
		}

		function pfStylizeGrid() {
			var table = document.getElementById("tbl");
			if (!table || !table.tBodies.length) return;
			if (!colsResolved) {
				colIdIdx       = findColIndex(hdrId);
				colCategoryIdx = findColIndex(hdrCategory);
				colTypeIdx     = findColIndex(hdrType);
				colStatusIdx   = findColIndex(hdrStatus);
				colVersionIdx  = findColIndex(hdrVersion);
				colHistoryIdx  = findColIndex(hdrHistory);
				colsResolved = true;
			}
			var rows = table.tBodies[0].rows;
			for (var r = 0; r < rows.length; r++) {
				var row = rows[r];
				if (colIdIdx >= 0) {
					var tdId = row.cells[colIdIdx];
					if (!pfAlreadyStyled(tdId)) {
						var rawId = tdId.textContent.trim();
						var n = parseInt(rawId, 10);
						if (!isNaN(n)) {
							var padded = ("0000" + n).slice(-4);
							tdId.innerHTML = "";
							tdId.appendChild(pfMono("PRD-" + padded));
						}
					}
				}
				if (colCategoryIdx >= 0) {
					var tdCat = row.cells[colCategoryIdx];
					if (!pfAlreadyStyled(tdCat)) {
						var catName = tdCat.textContent.trim();
						if (catName) {
							var color = pfColors[pfHash(catName) % pfColors.length];
							tdCat.innerHTML = "";
							tdCat.appendChild(pfChip(catName, color));
						}
					}
				}
				if (colTypeIdx >= 0) {
					var tdType = row.cells[colTypeIdx];
					if (!pfAlreadyStyled(tdType)) {
						var typeName = tdType.textContent.trim();
						if (typeName) {
							tdType.innerHTML = "";
							tdType.appendChild(pfPill(typeName, "#EEF0F4", "#6B7280"));
						}
					}
				}
				if (colStatusIdx >= 0) {
					var tdStatus = row.cells[colStatusIdx];
					if (!pfAlreadyStyled(tdStatus)) {
						var stateCode = tdStatus.textContent.trim();
						if (stateCode) {
							var stColor = stateColors[stateCode] || "#98A2B3";
							var stTextEl = document.getElementById(stateTextIds[stateCode]);
							var stText = stTextEl ? stTextEl.textContent : stateCode;
							tdStatus.innerHTML = "";
							tdStatus.appendChild(pfPill(stText, stColor + "18", stColor));
						}
					}
				}
				if (colVersionIdx >= 0) {
					var tdVer = row.cells[colVersionIdx];
					if (!pfAlreadyStyled(tdVer)) {
						var verNo = tdVer.textContent.trim();
						if (verNo) {
							tdVer.innerHTML = "";
							tdVer.appendChild(pfPill("v" + verNo, "#F1EDFF", "#7C5CFC"));
						}
					}
				}
				if (colHistoryIdx >= 0) {
					var tdHist = row.cells[colHistoryIdx];
					if (!pfAlreadyStyled(tdHist)) {
						var histCount = tdHist.textContent.trim();
						tdHist.innerHTML = "";
						tdHist.appendChild(pfPill(histCount, "#EEF0F4", "#6B7280"));
					}
				}
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
				url: "product.jsp?process_code=CREATE_PF_PRODUCT",
				target: "modalE",
				dialogHeight: 700,
				dialogWidth: 820,
				lock: false,
				callback: responseModal
			});
		}
		function view() {
			if (!getDOM("bView").disabled) {
				location.href = "product_view.jsp?id=" + getData(FO_ID) + "&version_no=" + getData(FO_VERSION_NO);
			}
		}
		function edit() {
			if (!getDOM("bEdit").disabled) {
				go({
					url: "product.jsp?process_code=EDIT_PF_PRODUCT",
					param: {
						model_process_code: "MODEL_PF_PRODUCT",
						code: getData(FO_CODE),
						product_id: getData(FO_ID)
					},
					target: "modalE",
					dialogHeight: 700,
					dialogWidth: 820,
					lock: false,
					callback: responseModal
				});
			}
		}
		function del() {
			if (!getDOM("bDelete").disabled) {
				if (confirm("<%=lang.get(si_confirm_delete)%> \"" + getData(FO_NAME) + "\"?")) {
					document.getElementById("pfProdDelRelId").value = getData(FO_ID);
					document.fmProdDel.submit();
				}
			}
		}
		/* Жизненный цикл (hayot sikli) - "Жизненный цикл - статусы.xlsx" bo'yicha
		   tasdiqlangan o'tishlar. Har bir tugma faqat joriy holatdan RUXSAT
		   ETILGAN bo'lganda yoqiladi (onSelect'da), backend (Pf_Kernel.Change_Product_State)
		   ham xuddi shu qoidani mustaqil tekshiradi - frontend faqat qulaylik uchun. */
		var STATE_BUTTONS = [
			{ name: "bStSendApproval", newState: "ON_APPROVAL", fromStates: ["DRAFT"],		color: "#3457EF" },
			{ name: "bStApprove",	    newState: "ACTIVE",      fromStates: ["ON_APPROVAL"],		color: "#178A4C" },
			{ name: "bStCancel",	    newState: "DRAFT",       fromStates: ["ON_APPROVAL"],		color: "#6B7280" },
			{ name: "bStSuspend",	    newState: "SUSPENDED",   fromStates: ["ACTIVE"],		color: "#C88A1B" },
			{ name: "bStMovePassive",  newState: "PASSIVE",     fromStates: ["SUSPENDED"],		color: "#0E9A93" },
			{ name: "bStMoveActive",   newState: "ACTIVE",      fromStates: ["SUSPENDED", "PASSIVE"],	color: "#178A4C" },
			{ name: "bStArchive",	    newState: "ARCHIVED",    fromStates: ["SUSPENDED"],		color: "#D64545" }
		];
		function changeState(newState, confirmLabel) {
			if (confirm(confirmLabel + "?")) {
				document.getElementById("pfStateProdId").value = getData(FO_ID);
				document.getElementById("pfStateNewState").value = newState;
				document.fmProdState.submit();
			}
		}
		function onSelect() {
			/* Faqat joriy holatdan RUXSAT ETILGAN amallar ko'rinadi (disable emas,
			   butunlay yashirinadi) - foydalanuvchi bosishi mumkin bo'lmagan
			   tugmalarni umuman ko'rmasligi kerak. */
			var curState = dataExist() ? getData(FO_STATE) : null;
			for (var i = 0; i < STATE_BUTTONS.length; i++) {
				var btn = STATE_BUTTONS[i];
				var allowed = curState != null && btn.fromStates.indexOf(curState) >= 0;
				getDOM(btn.name).style.display = allowed ? "inline-block" : "none";
			}
		}
		function onAction() {
			view();
		}
		function onLoad() {
			if (!dataExist()) {
				getDOM("bView").setDisable(true);
				getDOM("bEdit").setDisable(true);
				getDOM("bDelete").setDisable(true);
			}
			/* form.css'da INPUT/BUTTON uchun rang qoidalari haqiqiy CSS
			   xususiyatlari emas (button-background va h.k.), freymvork ularni
			   initElement() orqali sahifa yuklanganda JS bilan qo'llaydi - shu
			   sabab statik inline style o'rniga rangni SHU YERDA, freymvork
			   ishlab bo'lgandan keyin, JS orqali qo'yamiz. initElement() bu
			   tugmalarga o'zining onmouseover/onmouseout handler'ini ham
			   o'rnatgan (kulrang hover foni bilan) - shu sabab ularni ham
			   o'zimizniki bilan qayta yozamiz, aks holda sichqoncha olib
			   borilganda rang yo'qolib qoladi. */
			for (var i = 0; i < STATE_BUTTONS.length; i++) {
				(function(btn) {
					var el = getDOM(btn.name);
					el.style.display = "none";
					el.style.setProperty("background", btn.color, "important");
					el.style.setProperty("border-color", btn.color, "important");
					el.style.setProperty("color", "#fff", "important");
					el.onmouseover = function() {
						this.style.setProperty("background", btn.color, "important");
					};
					el.onmouseout = function() {
						this.style.setProperty("background", btn.color, "important");
					};
				})(STATE_BUTTONS[i]);
			}
			hdrId       = document.getElementById("pfHdrId").textContent;
			hdrCategory = document.getElementById("pfHdrCategory").textContent;
			hdrType     = document.getElementById("pfHdrType").textContent;
			hdrStatus   = document.getElementById("pfHdrStatus").textContent;
			hdrVersion  = document.getElementById("pfHdrVersion").textContent;
			hdrHistory  = document.getElementById("pfHdrHistory").textContent;
			pfStylizeGrid();
			pfObserveGrid();
		}
	</script>
	<span id="pfHdrId" style="display:none"><%=lang.get(si_col_id)%></span>
	<span id="pfHdrCategory" style="display:none"><%=lang.get(si_col_category)%></span>
	<span id="pfHdrType" style="display:none"><%=lang.get(si_col_type)%></span>
	<span id="pfHdrStatus" style="display:none"><%=lang.get(si_col_status)%></span>
	<span id="pfHdrVersion" style="display:none"><%=lang.get(si_col_version)%></span>
	<span id="pfHdrHistory" style="display:none"><%=lang.get(si_col_history)%></span>
	<span id="pfStDraft" style="display:none"><%=lang.get(si_state_draft)%></span>
	<span id="pfStOnApproval" style="display:none"><%=lang.get(si_state_on_approval)%></span>
	<span id="pfStActive" style="display:none"><%=lang.get(si_state_active)%></span>
	<span id="pfStSuspended" style="display:none"><%=lang.get(si_state_suspended)%></span>
	<span id="pfStPassive" style="display:none"><%=lang.get(si_state_passive)%></span>
	<span id="pfStArchived" style="display:none"><%=lang.get(si_state_archived)%></span>
	<table class="formToolbar" align="center">
		<tr>
			<td>
				<div style="display:flex;align-items:center;gap:6px;">
					<input type="button" name="bAdd" onclick="add();" value="<%=lang.get(si_add)%>">
					<input type="button" name="bView" onclick="view();" value="<%=lang.get(si_view)%>">
					<input type="button" name="bEdit" onclick="edit();" value="<%=lang.get(si_edit)%>">
					<input type="button" name="bDelete" onclick="del();" value="<%=lang.get(si_delete)%>">
					<span style="width:1px;align-self:stretch;background:#D0D0BF;margin:0 6px;"></span>
					<input type="button" name="bStSendApproval" style="display:none;" onclick="changeState('ON_APPROVAL', '<%=lang.get(si_action_send_approval)%>');" value="<%=lang.get(si_action_send_approval)%>">
					<input type="button" name="bStApprove" style="display:none;" onclick="changeState('ACTIVE', '<%=lang.get(si_action_approve)%>');" value="<%=lang.get(si_action_approve)%>">
					<input type="button" name="bStCancel" style="display:none;" onclick="changeState('DRAFT', '<%=lang.get(si_action_cancel)%>');" value="<%=lang.get(si_action_cancel)%>">
					<input type="button" name="bStSuspend" style="display:none;" onclick="changeState('SUSPENDED', '<%=lang.get(si_action_suspend)%>');" value="<%=lang.get(si_action_suspend)%>">
					<input type="button" name="bStMovePassive" style="display:none;" onclick="changeState('PASSIVE', '<%=lang.get(si_action_move_passive)%>');" value="<%=lang.get(si_action_move_passive)%>">
					<input type="button" name="bStMoveActive" style="display:none;" onclick="changeState('ACTIVE', '<%=lang.get(si_action_move_active)%>');" value="<%=lang.get(si_action_move_active)%>">
					<input type="button" name="bStArchive" style="display:none;" onclick="changeState('ARCHIVED', '<%=lang.get(si_action_archive)%>');" value="<%=lang.get(si_action_archive)%>">
				</div>
			<td id="tableControls" align="right">
		</tr>
	</table>
	<%-- table.js grid_id=9'da IS_FILTER='Y' maydonlar (NAME/CURRENT_STATE) borligi
	     sababli shu ID'li elementni MAJBURIY talab qiladi, aks holda butun
	     sahifa JS'i "filterControls is not found" xatosi bilan to'xtaydi va
	     grid bo'sh ko'rinadi (2026-08-07, parameters.jsp'da topilgan/tuzatilgan
	     muammo bilan bir xil - PF modulidagi bir nechta gridda mustaqil
	     ravishda ham mavjud ekan). --%>
	<span id="filterControls" style="display:none"></span>
	<div class="grid-card">
		<t:dynamicGrid gridId="9" />
	</div>
	<iframe name="frmProdDel" style="display:none"></iframe>
	<form name="fmProdDel" method="post" target="frmProdDel">
		<input type="hidden" name="request" value="delete">
		<input type="hidden" name="process_code" value="DELETE_PF_PRODUCT">
		<input type="hidden" name="product_id" id="pfProdDelRelId" value="">
		<input type="hidden" name="user_id" value="<%=user.getUserCode()%>">
	</form>
	<iframe name="frmProdState" style="display:none"></iframe>
	<form name="fmProdState" method="post" target="frmProdState">
		<input type="hidden" name="request" value="change_state">
		<input type="hidden" name="process_code" value="CHANGE_PF_PRODUCT_STATE">
		<input type="hidden" name="product_id" id="pfStateProdId" value="">
		<input type="hidden" name="new_state" id="pfStateNewState" value="">
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
	<t:request name="change_state"><%
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
	static final int si_view           = SI("Просмотр", "Кўриш", "Ko'rish", "View");
	static final int si_edit           = SI("Изменить", "&#1038;згартириш", "O'zgartirish", "Edit");
	static final int si_delete         = SI("Удалить", "&#1038;чириш", "O'chirish", "Delete");
	static final int si_confirm_delete = SI("Удалить продукт", "Ма&#1203;сулотни &#1118;чирасизми", "Mahsulotni o'chirasizmi", "Delete product");
	static final int si_col_id         = SI("ID", "ID", "ID", "ID");
	static final int si_col_category   = SI("Категория", "Категория", "Kategoriya", "Category");
	static final int si_col_type       = SI("Тип", "Тури", "Turi", "Type");
	static final int si_col_status     = SI("Статус", "&#1202;олати", "Holati", "Status");
	static final int si_col_version    = SI("Версия", "Версия", "Versiya", "Version");
	static final int si_col_history    = SI("История", "Тарих", "Tarix", "History");
	static final int si_state_draft        = SI("Черновик", "&#1178;оралама", "Qoralama", "Draft");
	static final int si_state_on_approval  = SI("На согласовании", "Келишувда", "Kelishuvda", "In approval");
	static final int si_state_active       = SI("Активен", "Фаол", "Faol", "Active");
	static final int si_state_suspended    = SI("Приостановлен", "Т&#1118;хтатилган", "To'xtatilgan", "Suspended");
	static final int si_state_archived     = SI("В архиве", "Архивда", "Arxivda", "Archived");
	static final int si_state_passive      = SI("Пассивный режим", "Пассив режим", "Passiv rejim", "Passive mode");
	static final int si_action_send_approval = SI("Отправить на согласование", "Келишувга юбориш", "Kelishuvga yuborish", "Send for approval");
	static final int si_action_approve       = SI("Согласовать", "Келишувни тасди&#1179;лаш", "Kelishuvni tasdiqlash", "Approve");
	static final int si_action_cancel        = SI("Отменить согласование", "Келишувни бекор &#1179;илиш", "Kelishuvni bekor qilish", "Cancel approval");
	static final int si_action_suspend       = SI("Приостановить", "Т&#1118;хтатиш", "To'xtatish", "Suspend");
	static final int si_action_move_passive  = SI("Перевести в пассивный режим", "Пассив &#1203;олатга &#1118;тказиш", "Passiv holatga o'tkazish", "Move to passive mode");
	static final int si_action_move_active   = SI("Перевести в активный режим", "Фаол &#1203;олатга &#1118;тказиш", "Faol holatga o'tkazish", "Move to active mode");
	static final int si_action_archive       = SI("Архивировать", "Архивлаш", "Arxivlash", "Archive");
%>
<%@ include file="/language.jsp" %>
