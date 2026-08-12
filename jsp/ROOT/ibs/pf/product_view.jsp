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

	long productId = 0;
	try {
		productId = Long.parseLong(request.getParameter("id"));
	} catch (Exception ex) {
		productId = 0;
	}
	String tabParam = request.getParameter("tab");
	if (tabParam == null) tabParam = "info";

	/* 2026-08-07: products.jsp grid'i endi HAR BIR versiyani alohida qator
	   sifatida ko'rsatadi - "Ko'rish" tugmasi endi qaysi qatordan
	   bosilganiga qarab version_no'ni ham yuboradi (VERSION_ID emas -
	   grid'ning hidden/IS_COLUMN='N' maydonlari getData() orqali ishonchli
	   o'qilishi tasdiqlanmagan edi, shu sabab allaqachon ISHLAB TURGAN
	   ko'rinadigan ustun - CURRENT_VERSION_NO - orqali aniqlanadi, product_id
	   bilan birga bitta versiyani noyob belgilaydi). Agar berilgan bo'lsa va
	   productga tegishli bo'lsa - pastda ANIQ shu versiya ko'rsatiladi
	   (tarixiy/yopilgan versiyalar uchun - faqat ko'rish, isReadOnlyVersion
	   shuni boshqaradi). Aks holda (parametr yo'q/noto'g'ri) - avvalgidek
	   eng so'nggi versiya. */
	long requestedVersionNo = 0;
	try {
		requestedVersionNo = Long.parseLong(request.getParameter("version_no"));
	} catch (Exception ex) {
		requestedVersionNo = 0;
	}

	String prodCode = null, prodName = null, categoryName = null, deliveryTypeName = null, currentState = null;
	long categoryId = 0;
	java.sql.Date startDate = null, endDate = null;
	int versionNo = 0;

	if (productId > 0) {
		Statement st = null;
		ResultSet rs = null;
		try {
			st = conn.createStatement();
			rs = st.executeQuery(
				"select CODE, NAME, CATEGORY_ID, CATEGORY_NAME, DELIVERY_TYPE_NAME, START_DATE, END_DATE, CURRENT_STATE, CURRENT_VERSION_NO" +
				"  from PF_PRODUCTS_V where ID = " + productId
			);
			if (rs.next()) {
				prodCode = rs.getString("CODE");
				prodName = rs.getString("NAME");
				categoryId = rs.getLong("CATEGORY_ID");
				categoryName = rs.getString("CATEGORY_NAME");
				deliveryTypeName = rs.getString("DELIVERY_TYPE_NAME");
				startDate = rs.getDate("START_DATE");
				endDate = rs.getDate("END_DATE");
				currentState = rs.getString("CURRENT_STATE");
				versionNo = rs.getInt("CURRENT_VERSION_NO");
			}
		} finally {
			if (rs != null) rs.close();
			if (st != null) st.close();
		}
	}
	boolean found = (prodName != null);

	/* Nomi/tavsifni HAMMA tillarda ko'rsatish uchun - PF_PRODUCTS_V.NAME/DESCRIPTION
	   faqat JORIY sessiya tilidagi BITTA qiymatni beradi (Mll_Core_Api.Get_Label
	   orqali ichida), shu sabab xom (raw) ko'p-tilli qiymatlarni MLT_TEMPLATES'dan
	   to'g'ridan-to'g'ri o'qish kerak (xuddi product.jsp'ning Model_Product orqali
	   tahrirlash formasini to'ldirish uchun qilgani kabi). PF_PRODUCTS (baza jadval,
	   ML_NAME_CODE/ML_DESCRIPTION_CODE saqlaydi) va MLT_TEMPLATES uchun UAPP
	   grant+synonym shu funksiya uchun maxsus qo'shildi (avval faqat _V view'lar
	   orqali kirilgan, bu safar birinchi marta bazaviy jadvalga to'g'ridan-to'g'ri
	   so'rov kerak bo'ldi). */
	java.util.Map<Integer, String> langNameMap = new java.util.LinkedHashMap<Integer, String>();
	String[] nameByLang = new String[7];
	String[] descByLang = new String[7];
	if (found) {
		Statement stLang = null;
		ResultSet rsLang = null;
		try {
			stLang = conn.createStatement();
			rsLang = stLang.executeQuery("select LANG_INDEX, NAME from MLT_LANGUAGES where STATE = 'A' order by LANG_INDEX");
			while (rsLang.next()) {
				langNameMap.put(rsLang.getInt("LANG_INDEX"), rsLang.getString("NAME"));
			}
		} finally {
			if (rsLang != null) rsLang.close();
			if (stLang != null) stLang.close();
		}

		String mlNameCode = null, mlDescCode = null;
		Statement stMlp = null;
		ResultSet rsMlp = null;
		try {
			stMlp = conn.createStatement();
			rsMlp = stMlp.executeQuery("select ML_NAME_CODE, ML_DESCRIPTION_CODE from PF_PRODUCTS where ID = " + productId);
			if (rsMlp.next()) {
				mlNameCode = rsMlp.getString("ML_NAME_CODE");
				mlDescCode = rsMlp.getString("ML_DESCRIPTION_CODE");
			}
		} finally {
			if (rsMlp != null) rsMlp.close();
			if (stMlp != null) stMlp.close();
		}

		if (mlNameCode != null) {
			Statement stMt = null;
			ResultSet rsMt = null;
			try {
				stMt = conn.createStatement();
				rsMt = stMt.executeQuery(
					"select MESSAGE_MASK_LANG1, MESSAGE_MASK_LANG2, MESSAGE_MASK_LANG3, MESSAGE_MASK_LANG4, MESSAGE_MASK_LANG5, MESSAGE_MASK_LANG6" +
					"  from MLT_TEMPLATES where MESSAGE_CODE = '" + mlNameCode.replace("'", "''") + "'"
				);
				if (rsMt.next()) {
					for (int mi = 1; mi <= 6; mi++) nameByLang[mi] = rsMt.getString("MESSAGE_MASK_LANG" + mi);
				}
			} finally {
				if (rsMt != null) rsMt.close();
				if (stMt != null) stMt.close();
			}
		}
		if (mlDescCode != null) {
			Statement stMd = null;
			ResultSet rsMd = null;
			try {
				stMd = conn.createStatement();
				rsMd = stMd.executeQuery(
					"select MESSAGE_MASK_LANG1, MESSAGE_MASK_LANG2, MESSAGE_MASK_LANG3, MESSAGE_MASK_LANG4, MESSAGE_MASK_LANG5, MESSAGE_MASK_LANG6" +
					"  from MLT_TEMPLATES where MESSAGE_CODE = '" + mlDescCode.replace("'", "''") + "'"
				);
				if (rsMd.next()) {
					for (int mi = 1; mi <= 6; mi++) descByLang[mi] = rsMd.getString("MESSAGE_MASK_LANG" + mi);
				}
			} finally {
				if (rsMd != null) rsMd.close();
				if (stMd != null) stMd.close();
			}
		}
	}

	Integer continueOnExpiry = null;
	long versionId = 0;
	long latestVersionId = 0;
	boolean isReadOnlyVersion = false;
	if (found) {
		Statement stLatest = null;
		ResultSet rsLatest = null;
		try {
			stLatest = conn.createStatement();
			rsLatest = stLatest.executeQuery(
				"select ID, VERSION_NO, STATE, START_DATE, END_DATE, CONTINUE_ON_EXPIRY" +
				"  from PF_PRODUCT_VERSIONS where PRODUCT_ID = " + productId +
				" order by VERSION_NO desc"
			);
			if (rsLatest.next()) {
				latestVersionId  = rsLatest.getLong("ID");
				versionId	 = latestVersionId;
				versionNo	 = rsLatest.getInt("VERSION_NO");
				currentState	 = rsLatest.getString("STATE");
				startDate	 = rsLatest.getDate("START_DATE");
				endDate		 = rsLatest.getDate("END_DATE");
				continueOnExpiry = rsLatest.getInt("CONTINUE_ON_EXPIRY");
			}
		} finally {
			if (rsLatest != null) rsLatest.close();
			if (stLatest != null) stLatest.close();
		}

		/* IDOR/mos kelmaslik himoyasi: version_no shu productga tegishli
		   bo'lmasa - "and PRODUCT_ID=" sharti tufayli rsReq bo'sh qaytadi va
		   yuqoridagi eng so'nggi versiya sukut bo'yicha ko'rsatilaveradi. */
		if (requestedVersionNo > 0 && requestedVersionNo != versionNo) {
			Statement stReq = null;
			ResultSet rsReq = null;
			try {
				stReq = conn.createStatement();
				rsReq = stReq.executeQuery(
					"select ID, VERSION_NO, STATE, START_DATE, END_DATE, CONTINUE_ON_EXPIRY" +
					"  from PF_PRODUCT_VERSIONS" +
					" where VERSION_NO = " + requestedVersionNo +
					"   and PRODUCT_ID = " + productId
				);
				if (rsReq.next()) {
					versionId	 = rsReq.getLong("ID");
					versionNo	 = rsReq.getInt("VERSION_NO");
					currentState	 = rsReq.getString("STATE");
					startDate	 = rsReq.getDate("START_DATE");
					endDate		 = rsReq.getDate("END_DATE");
					continueOnExpiry = rsReq.getInt("CONTINUE_ON_EXPIRY");
					isReadOnlyVersion = true;
				}
			} finally {
				if (rsReq != null) rsReq.close();
				if (stReq != null) stReq.close();
			}
		}
	}

	/* Kategoriya bilan bog'langan atributlar + IS_DEFAULT=1 atributlar (masalan
	   Umumiy) - ular kategoriyadan qat'i nazar HAR BIR mahsulotga avtomatik
	   biriktiriladi, shu sabab alohida UNION bilan qo'shiladi. SOURCE_TYPE='SPECIAL'
	   (masalan Filial) o'z holicha universal biriktirishga sabab bo'lmaydi -
	   u ham har qanday oddiy atribut kabi faqat tanlangan kategoriyalarga yoki
	   (agar admin shunday belgilasa) Is_Default=1 orqali barcha kategoriyalarga
	   bog'lanishi mumkin; SPECIAL faqat qaysi UI (checklist vs parametr formasi)
	   ko'rsatilishini belgilaydi. */
	java.util.List<long[]> attrIds = new java.util.ArrayList<long[]>();
	java.util.List<String> attrNames = new java.util.ArrayList<String>();
	java.util.List<Boolean> attrIsModule = new java.util.ArrayList<Boolean>();
	java.util.List<Boolean> attrIsSpecial = new java.util.ArrayList<Boolean>();
	java.util.List<String> attrSpecialType = new java.util.ArrayList<String>();
	if (found) {
		Statement stA = null;
		ResultSet rsA = null;
		try {
			stA = conn.createStatement();
			rsA = stA.executeQuery(
				"select ID, NAME, MODULE_CODE, SOURCE_TYPE, SPECIAL_TYPE from (" +
				"  select v.ID, v.NAME, v.MODULE_CODE, v.SOURCE_TYPE, v.SPECIAL_TYPE, v.SORT_ORDER" +
				"    from PF_R_ATTRIBUTE_CATEGORIES ac" +
				"    join PF_R_ATTRIBUTES_V v on v.ID = ac.ATTRIBUTE_ID" +
				"   where ac.CATEGORY_ID = " + categoryId +
				"   union" +
				"  select v.ID, v.NAME, v.MODULE_CODE, v.SOURCE_TYPE, v.SPECIAL_TYPE, v.SORT_ORDER" +
				"    from PF_R_ATTRIBUTES_V v" +
				"   where v.IS_DEFAULT = 1" +
				") order by SORT_ORDER"
			);
			while (rsA.next()) {
				attrIds.add(new long[]{ rsA.getLong("ID") });
				attrNames.add(rsA.getString("NAME"));
				attrIsModule.add(rsA.getString("MODULE_CODE") != null);
				attrIsSpecial.add("SPECIAL".equals(rsA.getString("SOURCE_TYPE")));
				attrSpecialType.add(rsA.getString("SPECIAL_TYPE"));
			}
		} finally {
			if (rsA != null) rsA.close();
			if (stA != null) stA.close();
		}
	}

	boolean isInfoTab = "info".equals(tabParam);
	boolean isLifecycleTab = "lifecycle".equals(tabParam);
	long tabAttrId = 0;
	int tabAttrIdx = -1;
	if (!isInfoTab && !isLifecycleTab) {
		try {
			tabAttrId = Long.parseLong(tabParam);
			for (int i = 0; i < attrIds.size(); i++) {
				if (attrIds.get(i)[0] == tabAttrId) { tabAttrIdx = i; break; }
			}
		} catch (Exception ex) {
			tabAttrIdx = -1;
		}
		if (tabAttrIdx < 0) isInfoTab = true;
	}
%><t:page><%
%><t:form minWidth="fill" minHeight="fill">
	<link rel="stylesheet" href="css/pf.css">
	<style>
		/* stats.jsp/product.jsp'dagi bilan bir xil o'zi yozilgan kalendar popup -
		   DATE turidagi parametr maydonlari uchun. */
		.date-picker-btn {
			position: absolute; right: 8px; top: 50%; transform: translateY(-50%);
			width: 22px; height: 20px;
			border: 1px solid transparent; border-radius: 4px; background: transparent;
			cursor: pointer; font-size: 12px; line-height: 1; padding: 0; color: #666;
		}
		.date-picker-btn:hover { background: #eef2fb; }
		.date-picker-btn:disabled { cursor: not-allowed; opacity: .4; }
		.date-picker-popup {
			position: absolute; left: 0; top: 100%; z-index: 1000; width: 230px; box-sizing: border-box;
			background: #fff; border: 1px solid #d7dee8; border-radius: 6px;
			box-shadow: 0 4px 14px rgba(16,24,40,.12); padding: 8px; font-size: 12px;
		}
		.date-picker-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 6px; }
		.date-picker-label { font-weight: 600; color: #222; font-size: 12px; }
		.date-picker-nav { width: 24px; height: 24px; border: 1px solid transparent; background: transparent; border-radius: 4px; cursor: pointer; color: #666; }
		.date-picker-nav:hover { background: #eef2fb; }
		.date-picker-grid { display: grid; grid-template-columns: repeat(7, 1fr); gap: 2px; }
		.date-picker-dayname { text-align: center; font-size: 10px; color: #888; padding: 3px 0; font-weight: 600; text-transform: uppercase; }
		.date-picker-day { text-align: center; padding: 5px 0; border-radius: 4px; cursor: pointer; color: #222; }
		.date-picker-day:hover { background: #eef2fb; }
		.date-picker-day.other-month { color: #bbb; }
		.date-picker-day.today { font-weight: 700; color: #3457ef; }
		.date-picker-day.selected { background: #3457ef; color: #fff; }
		.pf-param-row { position: relative; padding: 10px 0; border-bottom: 1px solid var(--pf-border); display: flex; justify-content: space-between; gap:16px; align-items:center; }
		.pf-param-row:last-child { border-bottom: none; }
		.pf-param-row .k { font-size: 13px; color: var(--pf-text-muted); font-weight: 500; flex: 0 0 auto; }
		.pf-param-row .pf-param-input-wrap { position: relative; width: 260px; }
		.pf-param-row input.pf-param-input, .pf-param-row select.pf-param-input {
			width: 100%; padding: 7px 10px; border: 1px solid var(--pf-border); border-radius: var(--pf-radius-sm);
			font-size: 13px; font-family: inherit; background: #fff; color: var(--pf-text);
		}
		.pf-param-row .pf-param-view {
			display: inline-block; width: 100%; text-align: right; font-size: 13.4px; font-weight: 600; color: var(--pf-text);
		}
		.pf-bool-toggle { display: flex; gap: 6px; justify-content: flex-end; }
		.pf-bool-btn {
			padding: 6px 16px; border: 1px solid var(--pf-border); border-radius: var(--pf-radius-sm);
			background: #fff; color: var(--pf-text-muted); font-size: 13px; font-family: inherit; cursor: pointer;
		}
		.pf-bool-btn:hover { background: var(--pf-gray-bg); }
		.pf-bool-btn.active { background: var(--pf-accent); border-color: var(--pf-accent); color: #fff; }
		/* .pf-branch-row endi <label> emas, oddiy <div> - freymvorkning umumiy
		   <label> uchun floating-label pozitsiyalash logikasi bunga tegmaydi,
		   shu sabab bu yerda qo'shimcha !important reset kerak emas (aksincha,
		   avvalgi reset JS orqali display:none qilishga to'sqinlik qilardi). */
	</style>
	<script>
		var g_datePicker = null;
		var MONTH_NAMES  = ['Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun', 'Iyul', 'Avgust', 'Sentabr', 'Oktabr', 'Noyabr', 'Dekabr'];
		var DAY_NAMES    = ['Du', 'Se', 'Ch', 'Pa', 'Ju', 'Sh', 'Ya'];

		function fmtDate(d) {
			return ('0' + d.getDate()).slice(-2) + '.' +
				('0' + (d.getMonth() + 1)).slice(-2) + '.' +
				d.getFullYear();
		}
		function parseDMY(str) {
			var p = (str || '').split('.');
			if (p.length !== 3) return null;
			var dt = new Date(parseInt(p[2], 10), parseInt(p[1], 10) - 1, parseInt(p[0], 10));
			return isNaN(dt.getTime()) ? null : dt;
		}
		function sameDay(a, b) {
			return a.getFullYear() === b.getFullYear() && a.getMonth() === b.getMonth() && a.getDate() === b.getDate();
		}
		function closeDatePicker() {
			if (g_datePicker) {
				g_datePicker.remove();
				g_datePicker = null;
			}
			document.removeEventListener('mousedown', onDatePickerOutsideClick, true);
		}
		function onDatePickerOutsideClick(e) {
			if (g_datePicker && !g_datePicker.contains(e.target) && !(e.target.classList && e.target.classList.contains('date-picker-btn'))) {
				closeDatePicker();
			}
		}
		function renderDatePicker(input, viewDate, selectedDate) {
			g_datePicker.innerHTML = '';
			var header = document.createElement('div');
			header.className = 'date-picker-header';
			var prev = document.createElement('button');
			prev.type = 'button'; prev.className = 'date-picker-nav'; prev.textContent = '<';
			prev.onclick = function() { renderDatePicker(input, new Date(viewDate.getFullYear(), viewDate.getMonth() - 1, 1), selectedDate); };
			var label = document.createElement('span');
			label.className = 'date-picker-label';
			label.textContent = MONTH_NAMES[viewDate.getMonth()] + ' ' + viewDate.getFullYear();
			var next = document.createElement('button');
			next.type = 'button'; next.className = 'date-picker-nav'; next.textContent = '>';
			next.onclick = function() { renderDatePicker(input, new Date(viewDate.getFullYear(), viewDate.getMonth() + 1, 1), selectedDate); };
			header.appendChild(prev); header.appendChild(label); header.appendChild(next);
			g_datePicker.appendChild(header);
			var grid = document.createElement('div');
			grid.className = 'date-picker-grid';
			for (var d = 0; d < DAY_NAMES.length; d++) {
				var dayName = document.createElement('div');
				dayName.className = 'date-picker-dayname';
				dayName.textContent = DAY_NAMES[d];
				grid.appendChild(dayName);
			}
			var firstOfMonth = new Date(viewDate.getFullYear(), viewDate.getMonth(), 1);
			var startOffset  = (firstOfMonth.getDay() + 6) % 7;
			var startDate2   = new Date(firstOfMonth);
			startDate2.setDate(startDate2.getDate() - startOffset);
			var today = new Date();
			for (var i = 0; i < 42; i++) {
				var cellDate = new Date(startDate2);
				cellDate.setDate(startDate2.getDate() + i);
				var cell = document.createElement('div');
				cell.className = 'date-picker-day';
				if (cellDate.getMonth() !== viewDate.getMonth()) cell.className += ' other-month';
				if (sameDay(cellDate, today)) cell.className += ' today';
				if (selectedDate && sameDay(cellDate, selectedDate)) cell.className += ' selected';
				cell.textContent = cellDate.getDate();
				(function(value) {
					cell.onclick = function() { input.value = fmtDate(value); closeDatePicker(); };
				})(cellDate);
				grid.appendChild(cell);
			}
			g_datePicker.appendChild(grid);
		}
		function openDatePicker(input) {
			if (input.readOnly) return;
			closeDatePicker();
			var selected = parseDMY(input.value) || new Date();
			var viewDate = new Date(selected.getFullYear(), selected.getMonth(), 1);
			g_datePicker = document.createElement('div');
			g_datePicker.className = 'date-picker-popup';
			/* Sahifa tarkibidagi konteynerlar (kartochka, forma "fill" balandligi
			   va h.k.) overflow tufayli popup'ni pastdan kesib qo'yishi mumkin -
			   shuning uchun to'g'ridan-to'g'ri <body>ga, position:fixed va
			   inputning ekrandagi haqiqiy koordinatalari bilan chiqariladi -
			   hech qanday konteyner uni endi kesa olmaydi. */
			document.body.appendChild(g_datePicker);
			var rect = input.getBoundingClientRect();
			g_datePicker.style.position = 'fixed';
			g_datePicker.style.left = rect.left + 'px';
			g_datePicker.style.top = (rect.bottom + 2) + 'px';
			renderDatePicker(input, viewDate, selected);
			setTimeout(function() { document.addEventListener('mousedown', onDatePickerOutsideClick, true); }, 0);
		}

		var pfParamsTabActive = <%=(!isInfoTab && tabAttrIdx >= 0 && !attrIsModule.get(tabAttrIdx) && !attrIsSpecial.get(tabAttrIdx))%>;

		function pfToggleBranchList(isAll) {
			document.getElementById('pfBranchListWrap').style.display = isAll ? 'none' : '';
			var searchWrap = document.getElementById('pfBranchSearchWrap');
			if (searchWrap) searchWrap.style.display = isAll ? 'none' : '';
		}
		function pfFilterBranches(q) {
			q = q.trim().toLowerCase();
			var rows = document.querySelectorAll('#pfBranchListWrap .pf-branch-row');
			for (var i = 0; i < rows.length; i++) {
				var txt = rows[i].textContent.toLowerCase();
				rows[i].style.display = (q === '' || txt.indexOf(q) >= 0) ? '' : 'none';
			}
		}
		/* .pf-branch-row <label> emas, oddiy <div> - shu sabab qatorning istalgan
		   joyiga bosilganda checkboxni o'zimiz almashtiramiz (checkboxning o'ziga
		   bosilganda esa u tabiiy o'z holicha almashadi, shu yerda qayta bosilib
		   ikki marta almashib ketmasligi uchun tekshiruv bor). */
		function pfToggleBranchCheckbox(e, row) {
			if (e.target && e.target.type === 'checkbox') return;
			var cb = row.querySelector('input[type=checkbox]');
			if (cb) cb.checked = !cb.checked;
		}
		/* Operatsiya tab'ida "Barchasini tanlash/Hech birini tanlamaslik" -
		   Filial'dagi ALL rejimidan farqli, ro'yxatni yashirmaydi, faqat
		   ko'rinadigan checkboxlarning holatini almashtiradi (qidiruv orqali
		   filtrlangan bo'lsa ham, faqat hozir ko'rinayotganlarga ta'sir qiladi -
		   "hammasi" degani "hozir ko'rinayotganlarning hammasi"). */
		function pfSelectAllBranches(checked) {
			var rows = document.querySelectorAll('#pfBranchListWrap .pf-branch-row');
			for (var i = 0; i < rows.length; i++) {
				if (rows[i].style.display === 'none') continue;
				var cb = rows[i].querySelector('input[type=checkbox]');
				if (cb) cb.checked = checked;
			}
		}
		/* Hujjatlar/Shablonlar (FILE_LIST) - hozircha faqat interfeys qobig'i,
		   haqiqiy fayl-xizmati integratsiyasi alohida tayyorlanmoqda. Bu uchta
		   funksiya integratsiya ulanguncha faqat qobiqni ko'rsatadi; ulanganda
		   ichlari haqiqiy so'rovga almashtiriladi, HTML/CSS o'zgarmaydi. */
		function pfFileAttachChosen(input) {
			alert(pfFilePendingLabel);
			input.value = '';
		}
		function pfFileView(fileId) {
			alert(pfFilePendingLabel);
		}
		function pfFileDelete(fileId) {
			alert(pfFilePendingLabel);
		}
		/* Statik <input>lar bu sahifada (product_view.jsp) klik bilan fokus/klaviatura
		   kiritishida freymvork bilan mojaro qiladi (main.jsp iframe konteksti bilan
		   bog'liq - parametr maydonlari ham shu sabab document.createElement orqali
		   qurilgan, pfBuildParamInput'ga qarang). Shu sabab qidiruv maydoni ham xuddi
		   shunday, sahifa yuklangach dinamik yaratiladi. */
		function pfInitBranchSearch() {
			var wrap = document.getElementById('pfBranchSearchWrap');
			if (!wrap) return;
			var inp = document.createElement('input');
			inp.type = 'text';
			inp.className = 'form-control';
			inp.placeholder = pfBranchSearchLabel;
			inp.style.width = '100%';
			inp.style.boxSizing = 'border-box';
			inp.addEventListener('input', function() { pfFilterBranches(inp.value); });
			inp.addEventListener('mousedown', function() {
				setTimeout(function() { inp.focus(); }, 0);
			});
			wrap.appendChild(inp);
		}

		function onLoad() {
			pfInitBranchSearch();
		}
		function editProduct() {
			go({
				url: "product.jsp?process_code=EDIT_PF_PRODUCT",
				param: {
					model_process_code: "MODEL_PF_PRODUCT",
					code: "<%=prodCode != null ? esc(prodCode) : ""%>",
					product_id: <%=productId%>
				},
				target: "modalE",
				dialogHeight: 520,
				dialogWidth: 560,
				lock: false,
				callback: function(r) { if (r) location.reload(); }
			});
		}
		function topEditClick() {
			if (pfParamsTabActive) pfParamsEdit();
			else editProduct();
		}

		var pfYesLabel    = "<%=lang.get(si_yes)%>";
		var pfNoLabel     = "<%=lang.get(si_no)%>";
		var pfBranchSearchLabel = "<%=lang.get(si_branch_search)%>";
		var pfFilePendingLabel = "<%=lang.get(si_file_pending_alert)%>";

		/* pf-param-input-wrap ichidagi ko'rish rejimidagi <span>'ni haqiqiy, freymvork
		   umuman teginmagan (shu sababli mask/readonly kelishmovchiliklaridan holi) yangi
		   DOM elementi bilan almashtiradi - forma freymvorki faqat sahifa yuklanganda
		   mavjud bo'lgan elementlarni qayta ishlaydi, keyinroq yaratilganlarga tegmaydi. */
		/* Sichqoncha bosilganda brauzerning odatiy "fokus ber" harakati negadir
		   ishlamayapti (main.jsp ichidagi iframe konteksti bilan bog'liq ko'rinadi) -
		   shuning uchun fokusni mousedown'da o'zimiz aniq chaqiramiz, bu esa
		   preventDefault'dan qat'iy nazar ishonchli ishlaydi. */
		function pfForceFocusOnMouseDown(el) {
			el.addEventListener('mousedown', function() {
				var self = this;
				setTimeout(function() { self.focus(); }, 0);
			});
		}
		/* REFERENCE turidagi parametrlar uchun spravochnik qatorlari - server
		   tarafda har bir parametr uchun pfRefOptions[fieldName] = [{code,label},...]
		   ko'rinishida to'ldiriladi (pastga, parametr tsiklidagi <script> qarang). */
		var pfRefOptions = {};
		var pfSelectLabel = "<%=lang.get(si_reference_select)%>";
		/* Native <select> bu sahifada ishonchsiz (avval Filial/Operatsiya va
		   parameters.jsp'da aniqlangan) - shu sabab REFERENCE parametr ham
		   xuddi shu tugma+menyu texnikasi bilan quriladi, faqat BITTA
		   qiymat tanlanadi (radio xatti-harakati - menyu qatori bosilganda
		   avvalgi tanlov almashtiriladi, ro'yxat yopiladi). */
		function pfBuildReferenceSelect(wrap, name, value) {
			var options = pfRefOptions[name] || [];
			var hid = document.createElement('input');
			hid.type = 'hidden';
			hid.name = name;
			hid.value = value;

			var btnWrap = document.createElement('div');
			btnWrap.style.cssText = 'position:relative;';
			var btn = document.createElement('button');
			btn.type = 'button';
			var btnLabel = document.createElement('span');
			btnLabel.style.cssText = 'overflow:hidden;text-overflow:ellipsis;white-space:nowrap;';
			var btnIcon = document.createElement('span');
			btnIcon.textContent = String.fromCharCode(9662);
			btnIcon.style.cssText = 'flex-shrink:0;margin-left:8px;color:#9AA1B2;';
			btn.appendChild(btnLabel);
			btn.appendChild(btnIcon);
			btn.style.cssText = 'display:flex;align-items:center;justify-content:space-between;width:100%;box-sizing:border-box;padding:7px 10px;font-size:13px;font-family:inherit;border:1px solid #ccd2dc;border-radius:7px;cursor:pointer;text-align:left;';
			function pfApplyRefBtnColors() {
				btn.style.setProperty('background', '#fff', 'important');
				btn.style.setProperty('color', '#1C2333', 'important');
			}
			function refreshLabel() {
				var found = null;
				for (var i = 0; i < options.length; i++) {
					if (options[i].code === hid.value) { found = options[i]; break; }
				}
				btnLabel.textContent = found ? found.label : pfSelectLabel;
			}
			pfApplyRefBtnColors();
			refreshLabel();
			btn.onmouseover = function() { pfApplyRefBtnColors(); btn.style.borderColor = '#9AA1B2'; };
			btn.onmouseout = function() { pfApplyRefBtnColors(); btn.style.borderColor = '#ccd2dc'; };

			var menu = document.createElement('div');
			menu.style.cssText = 'display:none;position:absolute;top:100%;left:0;margin-top:4px;min-width:100%;max-height:260px;overflow:auto;background:#fff;border:1px solid #e4e7ef;border-radius:8px;box-shadow:0 6px 18px rgba(16,24,52,.12);z-index:1000;padding:4px;';
			function buildMenu() {
				menu.innerHTML = '';
				for (var i = 0; i < options.length; i++) {
					(function(opt) {
						var row = document.createElement('div');
						row.textContent = opt.label;
						var isSelected = (opt.code === hid.value);
						row.style.cssText = 'padding:8px 10px;font-size:13px;cursor:pointer;white-space:nowrap;border-radius:5px;' +
							(isSelected ? 'color:#3457EF;font-weight:600;background:#EAEEFF;' : 'color:#1C2333;');
						row.onmouseover = function() { if (!isSelected) row.style.background = '#F4F5F8'; };
						row.onmouseout = function() { if (!isSelected) row.style.background = ''; };
						row.onclick = function(e) {
							if (e && e.stopPropagation) e.stopPropagation();
							hid.value = opt.code;
							refreshLabel();
							menu.style.display = 'none';
						};
						menu.appendChild(row);
					})(options[i]);
				}
			}
			buildMenu();
			btn.onclick = function(e) {
				if (e && e.stopPropagation) e.stopPropagation();
				buildMenu();
				menu.style.display = (menu.style.display === 'none') ? 'block' : 'none';
			};
			document.addEventListener('click', function() { menu.style.display = 'none'; });

			btnWrap.appendChild(btn);
			btnWrap.appendChild(menu);
			wrap.appendChild(hid);
			wrap.appendChild(btnWrap);
		}
		function pfBuildParamInput(wrap) {
			var type = wrap.getAttribute('data-type');
			var name = wrap.getAttribute('data-name');
			var value = wrap.getAttribute('data-value') || '';
			wrap.innerHTML = '';
			if (wrap.getAttribute('data-input-type') === 'REFERENCE') {
				pfBuildReferenceSelect(wrap, name, value);
			} else if (type === 'BOOLEAN') {
				/* Native <select> dropdown ochilishi ham iframe-focus muammosiga
				   uchraydi (.focus() dropdown ochib bermaydi) - shuning uchun
				   oddiy ikkita tugma bilan almashtirilgan, bular onclick orqali
				   ishlaydi (bu butun sahifada ishonchli ishlaydi). */
				var hid = document.createElement('input');
				hid.type = 'hidden';
				hid.name = name;
				hid.value = (value === '1') ? '1' : '0';
				var toggle = document.createElement('div');
				toggle.className = 'pf-bool-toggle';
				var btnNo = document.createElement('button');
				btnNo.type = 'button';
				btnNo.textContent = pfNoLabel;
				var btnYes = document.createElement('button');
				btnYes.type = 'button';
				btnYes.textContent = pfYesLabel;
				function refreshBoolBtns() {
					btnNo.className = (hid.value === '0') ? 'pf-bool-btn active' : 'pf-bool-btn';
					btnYes.className = (hid.value === '1') ? 'pf-bool-btn active' : 'pf-bool-btn';
				}
				btnNo.onclick = function() { hid.value = '0'; refreshBoolBtns(); };
				btnYes.onclick = function() { hid.value = '1'; refreshBoolBtns(); };
				refreshBoolBtns();
				toggle.appendChild(btnNo);
				toggle.appendChild(btnYes);
				wrap.appendChild(hid);
				wrap.appendChild(toggle);
			} else if (type === 'DATE') {
				var inp = document.createElement('input');
				inp.type = 'text';
				inp.className = 'pf-param-input';
				inp.name = name;
				inp.value = value;
				inp.maxLength = 10;
				inp.style.paddingRight = '28px';
				inp.addEventListener('input', function() {
					/* dd.mm.yyyy formatiga mos - faqat raqam va nuqtaga ruxsat, asosiy kiritish
					   usuli baribir kalendar tugmasi orqali. */
					this.value = this.value.replace(/[^0-9.]/g, '');
				});
				pfForceFocusOnMouseDown(inp);
				wrap.style.position = 'relative';
				wrap.appendChild(inp);
				var btn = document.createElement('button');
				btn.type = 'button';
				btn.className = 'date-picker-btn';
				btn.innerHTML = '&#128197;';
				/* Pozitsiya aniq shu wrap'ga bog'lansin - CSS'dagi
				   .pf-param-input-wrap { position:relative } klassiga
				   bog'liq bo'lib qolmasin, shu joyda ham to'g'ridan-to'g'ri
				   inline belgilanadi (ba'zan yuqoridagi qatorlar balandligi
				   sabab tugma noto'g'ri joyga chiqib qolayotgan edi). */
				btn.style.position = 'absolute';
				btn.style.right = '8px';
				btn.style.top = '50%';
				btn.style.transform = 'translateY(-50%)';
				btn.onclick = function() { openDatePicker(inp); };
				wrap.appendChild(btn);
			} else if (type === 'NUMBER') {
				var inpN = document.createElement('input');
				inpN.type = 'text';
				inpN.className = 'pf-param-input';
				inpN.name = name;
				inpN.value = value;
				inpN.maxLength = 20;
				inpN.style.textAlign = 'right';
				inpN.addEventListener('input', function() {
					/* faqat butun (int) yoki kasr (double) son kiritishga ruxsat beradi:
					   boshida ixtiyoriy minus, raqamlar, bitta nuqta. */
					var v = this.value.replace(/[^0-9.\-]/g, '');
					var neg = v.charAt(0) === '-';
					v = v.replace(/-/g, '');
					var dot = v.indexOf('.');
					if (dot !== -1) v = v.slice(0, dot + 1) + v.slice(dot + 1).replace(/\./g, '');
					this.value = (neg ? '-' : '') + v;
				});
				pfForceFocusOnMouseDown(inpN);
				wrap.appendChild(inpN);
			} else {
				var inp2 = document.createElement('input');
				inp2.type = 'text';
				inp2.className = 'pf-param-input';
				inp2.name = name;
				inp2.value = value;
				inp2.maxLength = 4000;
				pfForceFocusOnMouseDown(inp2);
				wrap.appendChild(inp2);
			}
		}

		/* Atribut tab'idagi parametr maydonlarini tahrirlash rejimiga o'tkazish/qaytarish. */
		function pfParamsEdit() {
			var wraps = document.querySelectorAll('#pfParamsForm .pf-param-input-wrap');
			for (var i = 0; i < wraps.length; i++) {
				pfBuildParamInput(wraps[i]);
			}
			document.getElementById('pfTopEditBtn').style.display = 'none';
			document.getElementById('pfParamsSaveBtn').style.display = '';
			document.getElementById('pfParamsCancelBtn').style.display = '';
		}
		function pfParamsCancel() {
			location.reload();
		}
		function pfParamsSave() {
			document.fmParams.submit();
		}
	</script>
	<div class="pf-page"><%
		if (!found) {
	%>
		<div class="pf-empty"><%=lang.get(si_not_found)%></div><%
		} else {
			String stateColor;
			int stateLabelId;
			if ("DRAFT".equals(currentState)) { stateColor = "#9AA1B2"; stateLabelId = si_state_draft; }
			else if ("ON_APPROVAL".equals(currentState)) { stateColor = "#C88A1B"; stateLabelId = si_state_on_approval; }
			else if ("ACTIVE".equals(currentState)) { stateColor = "#178A4C"; stateLabelId = si_state_active; }
			else if ("SUSPENDED".equals(currentState)) { stateColor = "#D64545"; stateLabelId = si_state_suspended; }
			else if ("PASSIVE".equals(currentState)) { stateColor = "#0E9A93"; stateLabelId = si_state_passive; }
			else { stateColor = "#6B7280"; stateLabelId = si_state_archived; }
			String stateLabel = lang.get(stateLabelId);
			String chipColor = pfColor(categoryId);
	%>
		<div class="pf-breadcrumb">
			<a href="products.jsp"><%=lang.get(si_breadcrumb_products)%></a><span>&rsaquo;</span>
			<a href="products.jsp"><%=esc(categoryName)%></a><span>&rsaquo;</span>
			<span class="pf-crumb-current"><%=esc(prodName)%></span>
		</div><%
		if (isReadOnlyVersion) {
		%>
		<div class="pf-info-note" style="background:#FFF7E6;border-color:#F0C674;color:#8A6417;margin-bottom:12px;">
			<%=lang.get(si_readonly_version_note)%>
			<a href="product_view.jsp?id=<%=productId%>&amp;tab=<%=esc(tabParam)%>" style="margin-left:8px;text-decoration:underline;"><%=lang.get(si_readonly_version_goto_current)%></a>
		</div><%
		}
		%>
		<div class="pf-view-head">
			<div class="pf-view-title-wrap">
				<span class="pf-type-chip" style="background:<%=chipColor%>18;color:<%=chipColor%>">
					<span class="pf-dot" style="background:<%=chipColor%>"></span><%=esc(categoryName)%>
				</span>
				<h1><%=esc(prodName)%></h1>
				<span class="pf-badge" style="background:<%=stateColor%>18;color:<%=stateColor%>">
					<span class="pf-dot-i"></span><%=esc(stateLabel)%>
				</span>
				<span class="pf-badge pf-badge-purple">v<%=versionNo%></span><%
				if (isReadOnlyVersion) {
				%><span class="pf-badge" style="background:#FFF7E6;color:#8A6417;"><%=lang.get(si_readonly_version_badge)%></span><%
				}
				%>
			</div>
			<div><%
				if (!isReadOnlyVersion) {
				%>
				<button type="button" class="pf-btn pf-btn-ghost" id="pfTopEditBtn" onclick="topEditClick();">
					<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.12 2.12 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
					<%=lang.get(si_edit)%>
				</button><%
				}
				%>
			</div>
		</div>
		<div class="pf-view-meta-bar">
			<div class="m"><span class="k"><%=lang.get(si_col_id)%></span><span class="v"><span class="pf-id-pill">PRD-<%=String.format("%04d", productId)%></span></span></div>
			<div class="m"><span class="k"><%=lang.get(si_col_category)%></span><span class="v"><%=esc(categoryName)%></span></div>
			<div class="m"><span class="k"><%=lang.get(si_col_type)%></span><span class="v"><%=esc(deliveryTypeName)%></span></div>
			<div class="m"><span class="k"><%=lang.get(si_col_start)%></span><span class="v"><%=startDate != null ? fmtDate(startDate) : "&mdash;"%></span></div>
			<div class="m"><span class="k"><%=lang.get(si_col_end)%></span><span class="v"><%=endDate != null ? fmtDate(endDate) : "&mdash;"%></span></div>
			<div class="m"><span class="k"><%=lang.get(si_col_status)%></span><span class="v"><%=esc(stateLabel)%></span></div>
		</div>
		<div class="pf-card"><%
			/* Tarixiy versiya korilayotganda tab almashtirilganda ham
			   version_no saqlanib qolishi kerak - aks holda tab bosilgan
			   zahoti sahifa jimgina eng songgi versiyaga qaytib ketadi
			   (2026-08-07 bug fix). Joriy versiyani korayotganda bu
			   qoshimcha hech narsani ozgartirmaydi. */
			String verSuffix = isReadOnlyVersion ? ("&amp;version_no=" + versionNo) : "";
		%>
			<div class="pf-tab-bar">
				<a href="product_view.jsp?id=<%=productId%><%=verSuffix%>&amp;tab=info" class="pf-tab-btn<%=isInfoTab?" active":""%>"><%=lang.get(si_tab_info)%></a><%
				for (int i = 0; i < attrIds.size(); i++) {
					boolean active = (!isInfoTab && tabAttrIdx == i);
			%><a href="product_view.jsp?id=<%=productId%><%=verSuffix%>&amp;tab=<%=attrIds.get(i)[0]%>" class="pf-tab-btn<%=active?" active":""%>"><%=esc(attrNames.get(i))%></a><%
				}
			%><a href="product_view.jsp?id=<%=productId%><%=verSuffix%>&amp;tab=lifecycle" class="pf-tab-btn<%=isLifecycleTab?" active":""%>"><%=lang.get(si_tab_lifecycle)%></a><%
			%>
			</div><%
			if (isInfoTab) {
		%>
			<div>
				<div class="pf-readonly-field" style="align-items:flex-start;">
					<span class="k"><%=lang.get(si_field_name)%></span>
					<span class="v" style="text-align:right;"><%
						boolean anyName = false;
						for (int mi = 1; mi <= 6; mi++) {
							String mv = nameByLang[mi];
							if (mv == null || mv.trim().equals("")) continue;
							anyName = true;
							String mLbl = langNameMap.get(mi);
					%><div style="margin-bottom:2px;"><span style="color:#9AA1B2;font-weight:600;"><%=esc(mLbl != null ? mLbl : ("Lang" + mi))%>:</span> <%=esc(mv)%></div><%
						}
						if (!anyName) {
					%><%=esc(prodName)%><%
						}
					%></span>
				</div><%
				boolean anyDesc = false;
				for (int mi = 1; mi <= 6; mi++) {
					if (descByLang[mi] != null && !descByLang[mi].trim().equals("")) { anyDesc = true; break; }
				}
				if (anyDesc) {
			%>
				<div class="pf-readonly-field" style="align-items:flex-start;">
					<span class="k"><%=lang.get(si_field_description)%></span>
					<span class="v" style="text-align:right;"><%
						for (int mi = 1; mi <= 6; mi++) {
							String mv = descByLang[mi];
							if (mv == null || mv.trim().equals("")) continue;
							String mLbl = langNameMap.get(mi);
					%><div style="margin-bottom:2px;"><span style="color:#9AA1B2;font-weight:600;"><%=esc(mLbl != null ? mLbl : ("Lang" + mi))%>:</span> <%=esc(mv)%></div><%
						}
					%></span>
				</div><%
				}
			%>
				<div class="pf-readonly-field"><span class="k"><%=lang.get(si_field_id)%></span><span class="v pf-mono">PRD-<%=String.format("%04d", productId)%></span></div>
				<div class="pf-readonly-field"><span class="k"><%=lang.get(si_field_category)%></span><span class="v"><%=esc(categoryName)%></span></div>
				<div class="pf-readonly-field"><span class="k"><%=lang.get(si_field_type)%></span><span class="v"><%=esc(deliveryTypeName)%></span></div>
				<div class="pf-readonly-field"><span class="k"><%=lang.get(si_field_start)%></span><span class="v"><%=startDate != null ? fmtDate(startDate) : "&mdash;"%></span></div>
				<div class="pf-readonly-field"><span class="k"><%=lang.get(si_field_end)%></span><span class="v"><%=endDate != null ? fmtDate(endDate) : "&mdash;"%></span></div>
				<div class="pf-readonly-field"><span class="k"><%=lang.get(si_field_continue)%></span><span class="v"><%=(continueOnExpiry != null && continueOnExpiry == 1) ? lang.get(si_continue_yes) : lang.get(si_continue_no)%></span></div>
				<div class="pf-readonly-field">
					<span class="k"><%=lang.get(si_field_attrs)%></span>
					<span class="v"><%
						if (attrIds.isEmpty()) {
					%>&mdash;<%
						} else {
							for (int i = 0; i < attrIds.size(); i++) {
								boolean isModule = attrIsModule.get(i);
					%><span class="pf-badge <%=isModule ? "pf-badge-gray" : "pf-badge-blue"%>" style="margin-left:6px;"><%=esc(attrNames.get(i))%></span><%
							}
						}
					%></span>
				</div>
				<div class="pf-readonly-field"><span class="k"><%=lang.get(si_field_status)%></span><span class="v"><%=esc(stateLabel)%></span></div>
			</div><%
			} else if (isLifecycleTab) {
				java.util.List<String[]> lcStates = new java.util.ArrayList<String[]>();
				Statement stLc = null;
				ResultSet rsLc = null;
				try {
					stLc = conn.createStatement();
					rsLc = stLc.executeQuery(
						"select s.CODE, Mll_Core_Api.Get_Label(i_Module_Code=>'PF', i_Message_Code=>s.ML_NAME_CODE) as NAME" +
						"  from PF_R_PRODUCT_STATES s order by s.SORT_ORDER"
					);
					while (rsLc.next()) {
						lcStates.add(new String[]{ rsLc.getString("CODE"), rsLc.getString("NAME") });
					}
				} finally {
					if (rsLc != null) rsLc.close();
					if (stLc != null) stLc.close();
				}
				int curIdx = -1;
				for (int i = 0; i < lcStates.size(); i++) {
					if (lcStates.get(i)[0].equals(currentState)) { curIdx = i; break; }
				}
		%>
			<div>
				<div class="section-label"><%=lang.get(si_lifecycle_current)%></div>
				<div style="display:flex;align-items:center;flex-wrap:wrap;gap:0;margin:10px 0 20px;"><%
					for (int i = 0; i < lcStates.size(); i++) {
						String stName = lcStates.get(i)[1];
						String pillBg, pillFg;
						if (i < curIdx) { pillBg = "#E7F7EE"; pillFg = "#178A4C"; }
						else if (i == curIdx) { pillBg = "#3457EF"; pillFg = "#fff"; }
						else { pillBg = "#EEF0F4"; pillFg = "#9AA1B2"; }
				%>
					<span style="display:inline-flex;align-items:center;gap:6px;padding:7px 16px;border-radius:20px;font-size:13px;font-weight:600;background:<%=pillBg%>;color:<%=pillFg%>;white-space:nowrap;"><%=esc(stName)%></span><%
						if (i < lcStates.size() - 1) {
					%><span style="margin:0 8px;color:#C0C4CC;">&rarr;</span><%
						}
					}
				%>
				</div>
				<div class="section-label" style="margin-top:20px;"><%=lang.get(si_lifecycle_history)%></div><%
				java.util.List<Object[]> histRows = new java.util.ArrayList<Object[]>();
				Statement stH = null;
				ResultSet rsH = null;
				try {
					stH = conn.createStatement();
					rsH = stH.executeQuery(
						"select h.ACTION_DATE, h.STATE, h.MODIFIED_BY, u.NAME as AUTHOR_NAME" +
						"  from PF_PRODUCT_VERSIONS_H h" +
						"  left join CORE_USERS_V u on u.USER_ID = h.MODIFIED_BY" +
						" where h.PRODUCT_ID = " + productId +
						" order by h.ACTION_DATE asc, h.LOG_ID asc"
					);
					String prevStateCode = null;
					while (rsH.next()) {
						String stCode = rsH.getString("STATE");
						if (prevStateCode != null && prevStateCode.equals(stCode)) {
							continue;
						}
						java.sql.Timestamp actionDate = rsH.getTimestamp("ACTION_DATE");
						String authorName = rsH.getString("AUTHOR_NAME");
						if (authorName == null) authorName = "system (" + rsH.getLong("MODIFIED_BY") + ")";
						histRows.add(new Object[]{ actionDate, prevStateCode, stCode, authorName });
						prevStateCode = stCode;
					}
				} finally {
					if (rsH != null) rsH.close();
					if (stH != null) stH.close();
				}
				java.util.Collections.reverse(histRows);
				java.text.SimpleDateFormat histFmt = new java.text.SimpleDateFormat("dd.MM.yyyy HH:mm");
			%>
				<table class="pf-table" style="width:100%;">
					<thead><tr>
						<th><%=lang.get(si_lifecycle_col_date)%></th>
						<th><%=lang.get(si_lifecycle_col_old)%></th>
						<th><%=lang.get(si_lifecycle_col_new)%></th>
						<th><%=lang.get(si_lifecycle_col_author)%></th>
					</tr></thead>
					<tbody><%
					if (histRows.isEmpty()) {
					%><tr><td colspan="4" class="pf-empty"><%=lang.get(si_lifecycle_empty)%></td></tr><%
					} else {
						for (Object[] row : histRows) {
							java.sql.Timestamp dt = (java.sql.Timestamp) row[0];
							String oldCode = (String) row[1];
							String newCode = (String) row[2];
							String author = (String) row[3];
					%>
					<tr>
						<td><%=histFmt.format(dt)%></td>
						<td><%=oldCode != null ? esc(findStateLabel(lcStates, oldCode)) : "&mdash;"%></td>
						<td><%=esc(findStateLabel(lcStates, newCode))%></td>
						<td><%=esc(author)%></td>
					</tr><%
						}
					}
					%></tbody>
				</table>
			</div><%
			} else {
				boolean isModule = attrIsModule.get(tabAttrIdx);
				boolean isSpecial = attrIsSpecial.get(tabAttrIdx);
				String specialType = attrSpecialType.get(tabAttrIdx);
				if (isSpecial && "BRANCH".equals(specialType)) {
					String scopeMode = "ALL";
					java.util.Set<String> selectedBranches = new java.util.HashSet<String>();
					Statement stSm = null;
					ResultSet rsSm = null;
					try {
						stSm = conn.createStatement();
						rsSm = stSm.executeQuery(
							"select SCOPE_MODE from PF_PRODUCT_SPECIAL_ATTRS" +
							" where VERSION_ID = " + versionId + " and ATTRIBUTE_ID = " + tabAttrId
						);
						if (rsSm.next()) scopeMode = rsSm.getString("SCOPE_MODE");
					} finally {
						if (rsSm != null) rsSm.close();
						if (stSm != null) stSm.close();
					}
					Statement stSi = null;
					ResultSet rsSi = null;
					try {
						stSi = conn.createStatement();
						rsSi = stSi.executeQuery(
							"select ITEM_CODE from PF_PRODUCT_SPECIAL_ATTR_ITEMS" +
							" where VERSION_ID = " + versionId + " and ATTRIBUTE_ID = " + tabAttrId
						);
						while (rsSi.next()) selectedBranches.add(rsSi.getString("ITEM_CODE"));
					} finally {
						if (rsSi != null) rsSi.close();
						if (stSi != null) stSi.close();
					}
					boolean isAll = "ALL".equals(scopeMode);
			%>
			<iframe name="frmSpecialAttr" style="display:none"></iframe>
			<form name="fmSpecialAttr" method="post" action="product_view.jsp?process_code=SAVE_PF_PRODUCT_SPECIAL_ATTR" target="frmSpecialAttr">
				<input type="hidden" name="request" value="save_special_attr">
				<input type="hidden" name="product_id" value="<%=productId%>">
				<input type="hidden" name="attribute_id" value="<%=tabAttrId%>">
				<input type="hidden" name="user_id" value="<%=user.getUserCode()%>">
				<div style="margin-bottom:10px;">
					<label style="display:flex;align-items:center;gap:6px;font-size:13px;margin-bottom:6px;">
						<input type="radio" name="scope_mode" value="ALL" <%=isAll?"checked":""%> onclick="pfToggleBranchList(true);"><%=lang.get(si_branch_all)%>
					</label>
					<label style="display:flex;align-items:center;gap:6px;font-size:13px;">
						<input type="radio" name="scope_mode" value="SPECIFIC" <%=!isAll?"checked":""%> onclick="pfToggleBranchList(false);"><%=lang.get(si_branch_specific)%>
					</label>
				</div>
				<div id="pfBranchSearchWrap" style="<%=isAll?"display:none;":""%>max-width:320px;margin-bottom:8px;"></div>
				<div id="pfBranchListWrap" style="<%=isAll?"display:none;":""%>border:1px solid #d7dee8;border-radius:4px;padding:8px 10px;max-height:480px;overflow:auto;margin-bottom:10px;"><%
					Statement stBr = null;
					ResultSet rsBr = null;
					boolean anyBranch = false;
					try {
						stBr = conn.createStatement();
						rsBr = stBr.executeQuery("select t.BRANCH_ID, t.NAME from ABS_BRANCHES t where t.CONDITION = 'A' and t.CODE_TYPE in (1,4,6,7,8) order by t.BRANCH_ID");
						while (rsBr.next()) {
							anyBranch = true;
							String brCode = String.valueOf(rsBr.getLong("BRANCH_ID"));
							String brName = decodeEntities(rsBr.getString("NAME"));
							boolean checked = selectedBranches.contains(brCode);
				%>
					<div class="pf-branch-row" onclick="pfToggleBranchCheckbox(event, this);" style="display:block;width:100%;font-size:13px;padding:4px 0;white-space:nowrap;cursor:pointer;">
						<input type="checkbox" name="items" value="<%=esc(brCode)%>" <%=checked?"checked":""%> style="vertical-align:middle;margin-right:6px;">
						<span style="vertical-align:middle;"><%=esc(brCode)%> &mdash; <%=esc(brName)%></span>
					</div><%
						}
					} finally {
						if (rsBr != null) rsBr.close();
						if (stBr != null) stBr.close();
					}
					if (!anyBranch) {
				%>
					<div class="pf-empty"><%=lang.get(si_no_branches)%></div><%
					}
				%>
				</div><%
				if (!isReadOnlyVersion) {
				%>
				<div class="pf-form-actions">
					<input type="submit" class="pf-btn pf-btn-primary" value="<%=lang.get(si_save)%>">
				</div><%
				}
				%>
			</form><%
				} else if (isSpecial && "OPERATION".equals(specialType)) {
					/* Operatsiya - Filial (BRANCH) bilan bir xil umumiy meхanizm
					   (PF_PRODUCT_SPECIAL_ATTRS/_ITEMS, SAVE_PF_PRODUCT_SPECIAL_ATTR)
					   orqali ishlaydi, lekin ikki joyda ataylab farq qilinadi:
					   (1) ro'yxat manbai endi PF_R_OPERATIONS/PF_R_CATEGORY_OPERATIONS
					   haqiqiy jadvallaridan, mahsulotning CATEGORY_ID'siga qarab
					   filtrlab olinadi (avvalgi qo'lda yozilgan mockOps massivi
					   o'rniga) - ma'lumotning o'zi hali namunaviy (haqiqiy biznes
					   ro'yxati keyinroq aniqlanadi), lekin MEXANIZM endi to'liq
					   real, DB-asosli; (2) "Barchasini tanlash" qulayligi bor,
					   lekin Filial'dagi kabi ro'yxatni yashirmaydi - tanlangan
					   operatsiyalar har doim ko'zga ko'rinib turishi kerak
					   (foydalanuvchi ko'rsatmasi). SCOPE_MODE doim 'SPECIFIC'
					   qilib yuboriladi - "hammasi" holati ham aslida faqat
					   "hammasi belgilangan holda SPECIFIC" sifatida saqlanadi. */
					java.util.Set<String> selectedOps = new java.util.HashSet<String>();
					Statement stOi = null;
					ResultSet rsOi = null;
					try {
						stOi = conn.createStatement();
						rsOi = stOi.executeQuery(
							"select ITEM_CODE from PF_PRODUCT_SPECIAL_ATTR_ITEMS" +
							" where VERSION_ID = " + versionId + " and ATTRIBUTE_ID = " + tabAttrId
						);
						while (rsOi.next()) selectedOps.add(rsOi.getString("ITEM_CODE"));
					} finally {
						if (rsOi != null) rsOi.close();
						if (stOi != null) stOi.close();
					}
			%>
				<iframe name="frmSpecialAttr" style="display:none"></iframe>
				<form name="fmSpecialAttr" method="post" action="product_view.jsp?process_code=SAVE_PF_PRODUCT_SPECIAL_ATTR" target="frmSpecialAttr">
					<input type="hidden" name="request" value="save_special_attr">
					<input type="hidden" name="product_id" value="<%=productId%>">
					<input type="hidden" name="attribute_id" value="<%=tabAttrId%>">
					<input type="hidden" name="scope_mode" value="SPECIFIC">
					<input type="hidden" name="user_id" value="<%=user.getUserCode()%>">
					<div class="pf-info-note"><%=lang.get(si_operation_mock_note)%></div>
					<div style="display:flex;align-items:center;gap:8px;margin-bottom:8px;">
						<div id="pfBranchSearchWrap" style="max-width:320px;flex:1;"></div>
						<a href="javascript:void(0);" onclick="pfSelectAllBranches(true);" style="font-size:12.5px;color:#3457EF;text-decoration:none;white-space:nowrap;"><%=lang.get(si_select_all)%></a>
						<a href="javascript:void(0);" onclick="pfSelectAllBranches(false);" style="font-size:12.5px;color:#6B7280;text-decoration:none;white-space:nowrap;"><%=lang.get(si_select_none)%></a>
					</div>
					<div id="pfBranchListWrap" style="border:1px solid #d7dee8;border-radius:4px;padding:8px 10px;max-height:480px;overflow:auto;margin-bottom:10px;"><%
						Statement stOp = null;
						ResultSet rsOp = null;
						boolean anyOp = false;
						try {
							stOp = conn.createStatement();
							rsOp = stOp.executeQuery(
								"select o.CODE, o.NAME from PF_R_CATEGORY_OPERATIONS co" +
								"  join PF_R_OPERATIONS o on o.ID = co.OPERATION_ID" +
								" where co.CATEGORY_ID = " + categoryId +
								" order by o.NAME"
							);
							while (rsOp.next()) {
								anyOp = true;
								String opCode = rsOp.getString("CODE");
								String opName = rsOp.getString("NAME");
								boolean checked = selectedOps.contains(opCode);
						%>
							<div class="pf-branch-row" onclick="pfToggleBranchCheckbox(event, this);" style="display:block;width:100%;font-size:13px;padding:4px 0;white-space:nowrap;cursor:pointer;">
								<input type="checkbox" name="items" value="<%=esc(opCode)%>" <%=checked?"checked":""%> style="vertical-align:middle;margin-right:6px;">
								<span style="vertical-align:middle;"><%=esc(opName)%></span>
							</div><%
							}
						} finally {
							if (rsOp != null) rsOp.close();
							if (stOp != null) stOp.close();
						}
						if (!anyOp) {
					%>
						<div class="pf-empty"><%=lang.get(si_no_operations)%></div><%
						}
					%>
					</div><%
					if (!isReadOnlyVersion) {
					%>
					<div class="pf-form-actions">
						<input type="submit" class="pf-btn pf-btn-primary" value="<%=lang.get(si_save)%>">
					</div><%
					}
					%>
				</form><%
				} else if (isSpecial && "FILE_LIST".equals(specialType)) {
					/* Hujjatlar/Shablonlar - haqiqiy fayl-xizmati integratsiyasi
					   (tashqi servisga login/parol bilan ulanib, token orqali
					   yuklash) alohida jar sifatida boshqa joyda tayyorlanmoqda
					   ("keyinroq qilamiz" - foydalanuvchi ko'rsatmasi). Shu sabab
					   bu yerda FAQAT interfeys qobig'i (tugmalar + bo'sh holat) -
					   hech qanday so'rov/baza chaqiruvi yo'q. Integratsiya tayyor
					   bo'lganda: (1) fayllar ro'yxatini FILES/PF_PRODUCT_SPECIAL_ATTR_ITEMS
					   orqali o'qish, (2) pfFileAttachChosen() ichida haqiqiy yuklash
					   chaqiruvini ulash, (3) pfFileView/pfFileDelete funksiyalarini
					   real so'rovlarga bog'lash kifoya - HTML/CSS qobig'i qayta
					   qurilmaydi. */
			%>
				<div class="pf-info-note"><%=lang.get(si_file_pending_note)%></div>
				<div class="pf-form-actions" style="margin-bottom:14px;">
					<input type="file" id="pfFileAttachInput" style="display:none;" onchange="pfFileAttachChosen(this);">
					<button type="button" class="pf-btn pf-btn-primary" onclick="document.getElementById('pfFileAttachInput').click();"><%=lang.get(si_file_attach)%></button>
				</div>
				<div id="pfFileListWrap">
					<div class="pf-empty" id="pfFileListEmpty"><%=lang.get(si_no_files)%></div>
					<table id="pfFileListTable" style="display:none;width:100%;border-collapse:collapse;font-size:13px;">
						<thead>
							<tr style="text-align:left;border-bottom:1px solid #d7dee8;">
								<th style="padding:6px 8px;"><%=lang.get(si_file_col_name)%></th>
								<th style="padding:6px 8px;"><%=lang.get(si_file_col_date)%></th>
								<th style="padding:6px 8px;text-align:right;"><%=lang.get(si_file_col_actions)%></th>
							</tr>
						</thead>
						<tbody id="pfFileListBody"></tbody>
					</table>
				</div><%
				} else if (isModule) {
		%>
			<div class="pf-info-note"><%=lang.get(si_module_note1)%> &laquo;<%=esc(attrNames.get(tabAttrIdx))%>&raquo; <%=lang.get(si_module_note2)%></div><%
					Statement stP0 = null;
					ResultSet rsP0 = null;
					boolean anyParam0 = false;
					try {
						stP0 = conn.createStatement();
						rsP0 = stP0.executeQuery(
							"select p.NAME, p.VALUE_TYPE, v.VALUE, p.DEFAULT_VALUE, p.CHANGE_POLICY from PF_R_PARAMETERS_V p" +
							"  left join PF_PRODUCT_PARAMETER_VALUES v on v.PARAMETER_ID = p.ID and v.VERSION_ID = " + versionId +
							" where p.ATTRIBUTE_ID = " + tabAttrId +
							" order by p.SORT_ORDER"
						);
						while (rsP0.next()) {
							anyParam0 = true;
							String pn = rsP0.getString("NAME");
							String pv = rsP0.getString("VALUE");
							if (pv == null) pv = rsP0.getString("DEFAULT_VALUE");
							String cp0 = rsP0.getString("CHANGE_POLICY");
				%>
			<div class="pf-readonly-field"><span class="k"><%=esc(pn)%><%=pfChangePolicyBadge(cp0, lang)%></span><span class="v"><%=pv != null ? esc(pv) : "&mdash;"%></span></div><%
						}
					} finally {
						if (rsP0 != null) rsP0.close();
						if (stP0 != null) stP0.close();
					}
					if (!anyParam0) {
				%>
			<div class="pf-empty"><%=lang.get(si_no_params)%></div><%
					}
				} else {
					/* FUNCTION turidagi parametrlar hech qachon bazadagi eski (oxirgi
					   saqlangan) qiymatni ko'rsatmasligi kerak - funksiya yoki qoida
					   o'zgargan bo'lishi mumkin. Shuning uchun har safar sahifa
					   ochilganda Pf_Kernel.Preview_Product_Parameters (hech narsani
					   bazaga yozmaydi) chaqirilib, joriy holatga mos yangi qiymatlar
					   olinadi. */
					java.util.Map<String, String> funcValues = new java.util.HashMap<String, String>();
					try {
						String previewJson = "{\"process_code\":\"PREVIEW_PF_PRODUCT_PARAMS\",\"product_id\":\"" + productId + "\",\"attribute_id\":\"" + tabAttrId + "\"}";
						CallableStatement cstmt = conn.prepareCall("{? = call CORE.CORE_API.GET_MODEL_CLOB(?)}");
						try {
							cstmt.registerOutParameter(1, java.sql.Types.CLOB);
							cstmt.setString(2, previewJson);
							cstmt.execute();
							String previewResult = cstmt.getString(1);
							if (previewResult != null) {
								java.util.regex.Matcher pm = java.util.regex.Pattern.compile("\"(param_\\d+)\":\"((?:[^\"\\\\]|\\\\.)*)\"").matcher(previewResult);
								while (pm.find()) {
									funcValues.put(pm.group(1), pm.group(2));
								}
							}
						} finally {
							cstmt.close();
						}
					} catch (Exception ignoredPreviewEx) {
						/* preview muvaffaqiyatsiz bo'lsa - pastda oddiy saqlangan qiymatga qaytiladi */
					}
					Statement stP = null;
					ResultSet rsP = null;
					boolean anyParam = false;
					try {
						stP = conn.createStatement();
						rsP = stP.executeQuery(
							"select p.ID, p.NAME, p.VALUE_TYPE, p.IS_REQUIRED, p.DEFAULT_VALUE, p.INPUT_TYPE, p.CHANGE_POLICY, rv.VIEW_NAME, v.VALUE" +
							"  from PF_R_PARAMETERS_V p" +
							"  left join PF_R_PARAMETERS bp on bp.ID = p.ID" +
							"  left join PF_R_REFERENCE_VIEWS rv on rv.ID = bp.REFERENCE_ID" +
							"  left join PF_PRODUCT_PARAMETER_VALUES v on v.PARAMETER_ID = p.ID and v.VERSION_ID = " + versionId +
							" where p.ATTRIBUTE_ID = " + tabAttrId +
							" order by p.SORT_ORDER"
						);
			%>
			<iframe name="frmParams" style="display:none"></iframe>
			<form name="fmParams" method="post" action="product_view.jsp?process_code=SAVE_PF_PRODUCT_PARAMS" target="frmParams" id="pfParamsForm">
				<input type="hidden" name="request" value="save_params">
				<input type="hidden" name="product_id" value="<%=productId%>">
				<input type="hidden" name="attribute_id" value="<%=tabAttrId%>">
				<input type="hidden" name="user_id" value="<%=user.getUserCode()%>"><%
						while (rsP.next()) {
							anyParam = true;
							long paramId = rsP.getLong("ID");
							String paramName = rsP.getString("NAME");
							String valueType = rsP.getString("VALUE_TYPE");
							String inputType = rsP.getString("INPUT_TYPE");
							String refViewName = rsP.getString("VIEW_NAME");
							String changePolicy = rsP.getString("CHANGE_POLICY");
							boolean required = rsP.getInt("IS_REQUIRED") == 1;
							String savedValue = rsP.getString("VALUE");
							String curValue = (savedValue != null) ? savedValue : rsP.getString("DEFAULT_VALUE");
							if (curValue == null) curValue = "";
							String fieldName = "param_" + paramId;
				%>
				<div class="pf-param-row">
					<span class="k"><%=esc(paramName)%><%=pfChangePolicyBadge(changePolicy, lang)%><%
						if (required) {
					%> <span class="pf-badge pf-badge-amber" style="padding:2px 7px;font-size:10px;"><%=lang.get(si_required)%></span><%
						}
					%></span><%
						if ("FUNCTION".equals(inputType)) {
							/* Hisoblanadigan parametr - qo'lda kiritilmaydi. Bazadagi oxirgi
							   saqlangan qiymat emas, balki yuqorida Preview_Product_Parameters
							   orqali HOZIR qayta hisoblangan qiymat ko'rsatiladi - shunda
							   funksiya yoki qoida o'zgargani darhol sahifada ko'rinadi,
							   qayta saqlashni kutmasdan. */
							String funcDisp = funcValues.get(fieldName);
							if (funcDisp == null) funcDisp = curValue;
					%>
					<span class="pf-param-view"><%=funcDisp.isEmpty() ? "&mdash;" : esc(funcDisp)%></span><%
						} else if ("REFERENCE".equals(inputType) && refViewName != null) {
							/* 2026-08-07: avval REFERENCE parametr HAR DOIM faqat ko'rish
							   uchun edi (spravochnikning barcha qatorlari ro'yxat sifatida
							   chiqardi, formaga umuman kirmasdi). Endi "O'zgartirish"
							   bosganda foydalanuvchi spravochnikdan ANIQ BITTA qiymatni
							   tanlaydi (tugma+menyu texnikasi - parameters.jsp'dagi atribut
							   filtri bilan bir xil, native <select> bu ilovada ishonchsiz
							   ekani avval aniqlangan edi) va shu tanlov saqlanadi -
							   keyinchalik faqat o'sha saqlangan qiymat ko'rinadi, butun
							   ro'yxat emas. Backend tarafida hech narsa o'zgartirilmadi -
							   Pf_Kernel.Save_Product_Parameter_Values REFERENCE'ni MANUAL
							   bilan bir xil "Input_Type != 'FUNCTION'" shartida allaqachon
							   qabul qiladi. */
							java.util.List<String[]> refPairs = new java.util.ArrayList<String[]>();
							Statement stRv = null;
							ResultSet rsRv = null;
							try {
								stRv = conn.createStatement();
								/* refViewName PF_R_REFERENCE_VIEWS'dan keladi - admin tomonidan
								   ro'yxatga olingan ishonchli nom, foydalanuvchi kiritmaydi. */
								rsRv = stRv.executeQuery("select * from " + refViewName);
								ResultSetMetaData rvMeta = rsRv.getMetaData();
								int codeCol = 1, valueCol = (rvMeta.getColumnCount() >= 2 ? 2 : 1);
								for (int c = 1; c <= rvMeta.getColumnCount(); c++) {
									if ("CODE".equalsIgnoreCase(rvMeta.getColumnName(c))) codeCol = c;
									if ("VALUE".equalsIgnoreCase(rvMeta.getColumnName(c))) valueCol = c;
								}
								while (rsRv.next()) {
									refPairs.add(new String[]{ rsRv.getString(codeCol), rsRv.getString(valueCol) });
								}
							} finally {
								if (rsRv != null) rsRv.close();
								if (stRv != null) stRv.close();
							}
							String refCurLabel = null;
							for (String[] pair : refPairs) {
								if (pair[0] != null && pair[0].equals(curValue)) { refCurLabel = pair[1]; break; }
							}
							StringBuilder refJson = new StringBuilder("[");
							for (int ri = 0; ri < refPairs.size(); ri++) {
								String[] pair = refPairs.get(ri);
								if (ri > 0) refJson.append(",");
								String pc = pair[0] == null ? "" : pair[0].replace("\\", "\\\\").replace("\"", "\\\"");
								String pv = pair[1] == null ? "" : pair[1].replace("\\", "\\\\").replace("\"", "\\\"");
								refJson.append("{\"code\":\"").append(pc).append("\",\"label\":\"").append(pv).append("\"}");
							}
							refJson.append("]");
					%>
					<div class="pf-param-input-wrap" data-type="<%=valueType%>" data-input-type="REFERENCE" data-name="<%=fieldName%>" data-value="<%=esc(curValue)%>">
						<span class="pf-param-view"><%=refCurLabel != null ? esc(refCurLabel) : (curValue.isEmpty() ? "&mdash;" : esc(curValue))%></span>
					</div>
					<script>pfRefOptions["<%=fieldName%>"] = <%=refJson%>;</script><%
						} else {
							String dispValue;
							if ("BOOLEAN".equals(valueType)) {
								dispValue = "1".equals(curValue) ? lang.get(si_yes) : lang.get(si_no);
							} else {
								dispValue = curValue;
							}
					%>
					<div class="pf-param-input-wrap" data-type="<%=valueType%>" data-name="<%=fieldName%>" data-value="<%=esc(curValue)%>">
						<span class="pf-param-view"><%=dispValue.isEmpty() ? "&mdash;" : esc(dispValue)%></span>
					</div><%
						}
					%>
				</div><%
						}
					} finally {
						if (rsP != null) rsP.close();
						if (stP != null) stP.close();
					}
					if (anyParam) {
				%>
				<div class="pf-form-actions">
					<button type="button" class="pf-btn pf-btn-ghost" id="pfParamsCancelBtn" style="display:none;" onclick="pfParamsCancel();"><%=lang.get(si_cancel)%></button>
					<input type="submit" class="pf-btn pf-btn-primary" id="pfParamsSaveBtn" style="display:none;" value="<%=lang.get(si_save)%>">
				</div><%
					}
			%>
			</form><%
					if (!anyParam) {
				%>
			<div class="pf-empty"><%=lang.get(si_no_params)%></div><%
					}
				}
			}
		%>
		</div><%
		}
	%>
	</div>
</t:form>
</t:page>
<t:requests>
	<t:request name="save_params"><%
		try {
			stored.execJsonRequestProcedure("Core_Api.Execute_Process_Clob", request);
			out.print("<script>parent.location.reload();</script>");
		} catch (Exception ex) {
			response.setHeader("RT", "alert");
			Util.alertUserMessage(ex, out);
		}
	%></t:request>
	<t:request name="save_special_attr"><%
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
	static String findStateLabel(java.util.List<String[]> states, String code) {
		if (code == null) return null;
		for (String[] s : states) {
			if (s[0].equals(code)) return s[1];
		}
		return code;
	}
	static String esc(String s) {
		if (s == null) return "";
		/* Sahifa WINDOWS-1251'da chiqadi, lekin bu kodировкada 4 ta o'zbekcha
		   harf (breve-U, descender-Ka, stroke-Ghe, descender-Ha, katta/kichik)
		   mavjud emas - shu harflar raqamli HTML entity'ga aylantiriladi, aks
		   holda encoder ularni "?" bilan almashtirib qo'yadi (ABS_BRANCHES.NAME
		   kabi manbalarda uchraydi). Codepoint'lardan (char) cast orqali -
		   CP1251 fayliga bu harflarning o'zini literal yozib bo'lmaydi. */
		return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;")
			.replace(String.valueOf((char)0x040E), "&#1038;").replace(String.valueOf((char)0x045E), "&#1118;")
			.replace(String.valueOf((char)0x049A), "&#1178;").replace(String.valueOf((char)0x049B), "&#1179;")
			.replace(String.valueOf((char)0x0492), "&#1170;").replace(String.valueOf((char)0x0493), "&#1171;")
			.replace(String.valueOf((char)0x04B2), "&#1202;").replace(String.valueOf((char)0x04B3), "&#1203;");
	}
	/* ABS_BRANCHES.NAME kabi manba jadvallarida ba'zi &#1179; uslubidagi HTML
	   entity kodlari haqiqiy belgi o'rniga XOM matn sifatida (harfma-harf)
	   saqlangan bo'ladi - esc() ularni yana escape qilib "&amp;#1179;" qilib
	   qo'yadi, natijada brauzerda "&#1179;" deb ochiq ko'rinadi. Shu sabab
	   ko'rsatishdan oldin ularni haqiqiy belgiga aylantiramiz. */
	static String decodeEntities(String s) {
		if (s == null) return null;
		java.util.regex.Matcher m = java.util.regex.Pattern.compile("&#(\\d+);").matcher(s);
		StringBuffer sb = new StringBuffer();
		while (m.find()) {
			m.appendReplacement(sb, java.util.regex.Matcher.quoteReplacement(String.valueOf((char) Integer.parseInt(m.group(1)))));
		}
		m.appendTail(sb);
		return sb.toString();
	}
	static String fmtDate(java.sql.Date d) {
		java.text.SimpleDateFormat f = new java.text.SimpleDateFormat("dd.MM.yyyy");
		return f.format(d);
	}
	static String pfColor(long categoryId) {
		String[] colors = {"#3457EF", "#7C5CFC", "#178A4C", "#C88A1B", "#D64545", "#0E9A93", "#DB2777"};
		return colors[(int) (Math.abs(categoryId) % colors.length)];
	}
	/* Parametr nomi yonida CHANGE_POLICY belgisi - "versioned" o'zgartirilsa
	   mahsulotning yangi versiyasi ochilishini, "inplace" esa joriy versiyada
	   tinch o'zgarishini bildiradi (2026-08-07, foydalanuvchi ko'rsatmasi:
	   "inplace va versioned ni bilib turish uchun belgi qilish kerak").
	   VERSIONED - version raqami badge'i bilan bir xil rangda (pf-badge-purple,
	   semantik bog'liqlik uchun), INPLACE - neytral kulrang. */
	static String pfChangePolicyBadge(String changePolicy, Language lang) throws Exception {
		if ("VERSIONED".equals(changePolicy)) {
			return " <span class=\"pf-badge pf-badge-purple\" style=\"padding:2px 7px;font-size:10px;\">" +
				lang.get(si_change_policy_versioned) + "</span>";
		}
		return " <span class=\"pf-badge\" style=\"padding:2px 7px;font-size:10px;background:#EEF0F4;color:#6B7280;\">" +
			lang.get(si_change_policy_inplace) + "</span>";
	}
	static final int si_not_found         = SI("Продукт не найден.", "Ма&#1203;сулот топилмади.", "Mahsulot topilmadi.", "Product not found.");
	static final int si_change_policy_versioned = SI("Версионный", "Версияли", "Versiyali", "Versioned");
	static final int si_change_policy_inplace   = SI("На месте", "Жойида", "Joyida", "In-place");
	static final int si_readonly_version_note = SI("Это закрытая (историческая) версия - только для просмотра.", "Бу ёпилган (тарихий) версия - фа&#1179;ат к&#1118;риш учун.", "Bu yopilgan (tarixiy) versiya - faqat ko'rish uchun.", "This is a closed (historical) version - view only.");
	static final int si_readonly_version_goto_current = SI("Перейти к текущей версии", "Жорий версияга &#1118;тиш", "Joriy versiyaga o'tish", "Go to current version");
	static final int si_readonly_version_badge = SI("Архивная", "Тарихий", "Tarixiy", "Historical");
	static final int si_breadcrumb_products = SI("Продукты", "Ма&#1203;сулотлар", "Mahsulotlar", "Products");
	static final int si_edit              = SI("Редактировать", "&#1038;згартириш", "O'zgartirish", "Edit");
	static final int si_save              = SI("Сохранить", "Са&#1179;лаш", "Saqlash", "Save");
	static final int si_cancel            = SI("Отмена", "Бекор &#1179;илиш", "Bekor qilish", "Cancel");
	static final int si_yes               = SI("Да", "&#1202;а", "Ha", "Yes");
	static final int si_no                = SI("Нет", "&#1202;а&#1179;", "Yo'q", "No");
	static final int si_col_id            = SI("ID продукта", "ID", "ID", "Product ID");
	static final int si_col_category      = SI("Категория", "Категория", "Kategoriya", "Category");
	static final int si_col_type          = SI("Тип", "Тури", "Turi", "Type");
	static final int si_col_start         = SI("Начало", "Бошланиши", "Boshlanishi", "Start");
	static final int si_col_end           = SI("Окончание", "Тугаши", "Tugashi", "End");
	static final int si_col_status        = SI("Статус", "&#1202;олати", "Holati", "Status");
	static final int si_tab_info          = SI("Сведения", "Маълумотлар", "Ma'lumotlar", "Details");
	static final int si_field_name        = SI("Наименование продукта", "Ма&#1203;сулот номи", "Mahsulot nomi", "Product name");
	static final int si_field_description = SI("Описание", "Тавсиф", "Tavsif", "Description");
	static final int si_field_id          = SI("ID продукта", "Ма&#1203;сулот ID си", "Mahsulot ID si", "Product ID");
	static final int si_field_category    = SI("Категория продукта", "Ма&#1203;сулот категорияси", "Mahsulot kategoriyasi", "Product category");
	static final int si_field_type        = SI("Тип продукта", "Ма&#1203;сулот тури", "Mahsulot turi", "Product type");
	static final int si_field_start       = SI("Дата начала", "Бошланиш санаси", "Boshlanish sanasi", "Start date");
	static final int si_field_end         = SI("Дата окончания", "Тугаш санаси", "Tugash sanasi", "End date");
	static final int si_field_continue    = SI("Связанные продукты при истечении срока", "Бо&#1171;ланган ма&#1203;сулотлар муддати тугаганда", "Bog'langan mahsulotlar muddati tugaganda", "Linked products when this expires");
	static final int si_continue_yes      = SI("Продолжают работать", "Ишлашда давом этади", "Ishlashda davom etadi", "Keep working");
	static final int si_continue_no       = SI("Блокируются", "Блокланади", "Bloklanadi", "Are blocked");
	static final int si_field_attrs       = SI("Подключённые атрибуты", "Уланган атрибутлар", "Ulangan atributlar", "Connected attributes");
	static final int si_field_status      = SI("Статус", "&#1202;олати", "Holati", "Status");
	static final int si_state_draft       = SI("Черновик", "&#1178;оралама", "Qoralama", "Draft");
	static final int si_state_on_approval = SI("На согласовании", "Келишувда", "Kelishuvda", "In approval");
	static final int si_state_active      = SI("Активен", "Фаол", "Faol", "Active");
	static final int si_state_suspended   = SI("Приостановлен", "Т&#1118;хтатилган", "To'xtatilgan", "Suspended");
	static final int si_state_archived    = SI("В архиве", "Архивда", "Arxivda", "Archived");
	static final int si_state_passive     = SI("Пассивный режим", "Пассив режим", "Passiv rejim", "Passive mode");
	static final int si_tab_lifecycle       = SI("Жизненный цикл", "&#1202;аёт цикли", "Hayot sikli", "Lifecycle");
	static final int si_lifecycle_current   = SI("Текущее положение в жизненном цикле", "&#1202;аёт циклидаги жорий &#1203;олат", "Hayot siklidagi joriy holat", "Current position in the lifecycle");
	static final int si_lifecycle_history   = SI("История изменения статусов", "&#1202;олат &#1118;згариши тарихи", "Holat o'zgarishi tarixi", "Status change history");
	static final int si_lifecycle_col_date  = SI("Дата изменения", "&#1038;згариш санаси", "O'zgarish sanasi", "Change date");
	static final int si_lifecycle_col_old   = SI("Старый статус", "Эски &#1203;олат", "Eski holat", "Old status");
	static final int si_lifecycle_col_new   = SI("Новый статус", "Янги &#1203;олат", "Yangi holat", "New status");
	static final int si_lifecycle_col_author = SI("Автор", "Муаллиф", "Muallif", "Author");
	static final int si_lifecycle_empty     = SI("Пока нет изменений статуса.", "&#1202;али &#1203;олат &#1118;згариши й&#1118;&#1179;.", "Hali holat o'zgarishi yo'q.", "No status changes yet.");
	static final int si_module_note1      = SI("Параметры атрибута", "Атрибут параметрлари", "Atribut parametrlari", "Parameters of attribute");
	static final int si_module_note2      = SI("формируются другим модулем системы.", "тизимнинг бош&#1179;а модули томонидан шаклланади.", "tizimning boshqa moduli tomonidan shakllanadi.", "are formed by another module of the system.");
	static final int si_required          = SI("Обязательный", "Мажбурий", "Majburiy", "Required");
	static final int si_no_params         = SI("Параметры не заведены.", "Параметрлар киритилмаган.", "Parametrlar kiritilmagan.", "No parameters defined.");
	static final int si_select            = SI("Выберите...", "Танланг...", "Tanlang...", "Select...");
	static final int si_branch_all        = SI("Во всех филиалах", "Барча филиалларда", "Barcha filiallarda", "In all branches");
	static final int si_branch_specific   = SI("В выбранных филиалах", "Танланган филиалларда", "Tanlangan filiallarda", "In selected branches");
	static final int si_no_branches       = SI("Филиалы не найдены.", "Филиаллар топилмади.", "Filiallar topilmadi.", "No branches found.");
	static final int si_branch_search     = SI("Поиск филиала...", "Филиал излаш...", "Filial qidirish...", "Search branch...");
	static final int si_file_pending_note = SI("Интеграция с файловым сервисом ещё не подключена. Кнопки ниже пока не работают.", "Файл хизмати билан интеграция &#1203;али уланмаган. Пастдаги тугмалар &#1203;озирча ишламайди.", "Fayl xizmati bilan integratsiya hali ulanmagan. Pastdagi tugmalar hozircha ishlamaydi.", "File service integration is not connected yet. The buttons below do not work yet.");
	static final int si_file_attach       = SI("Прикрепить файл", "Файл бириктириш", "Fayl biriktirish", "Attach file");
	static final int si_no_files          = SI("Файлы не прикреплены.", "Файллар бириктирилмаган.", "Fayllar biriktirilmagan.", "No files attached.");
	static final int si_file_col_name     = SI("Название", "Номи", "Nomi", "Name");
	static final int si_file_col_date     = SI("Дата", "Сана", "Sana", "Date");
	static final int si_file_col_actions  = SI("Действия", "Амаллар", "Amallar", "Actions");
	static final int si_file_pending_alert = SI("Функция будет доступна после подключения файлового сервиса.", "Функция файл хизмати уланганидан кейин мавжуд бўлади.", "Funksiya fayl xizmati ulangandan keyin mavjud bo'ladi.", "This feature will be available once the file service is connected.");
	static final int si_operation_mock_note = SI("Список операций временный (демо), реальный справочник будет подключён позже.", "Операциялар р&#1118;йхати ва&#1179;тинчалик (демо), &#1203;а&#1179;и&#1179;ий справочник кейинро&#1179; уланади.", "Operatsiyalar ro'yxati vaqtinchalik (demo), haqiqiy spravochnik keyinroq ulanadi.", "The operations list is temporary (demo); the real reference list will be connected later.");
	static final int si_select_all = SI("Выбрать все", "Барчасини танлаш", "Barchasini tanlash", "Select all");
	static final int si_select_none = SI("Снять выбор", "Танловни бекор &#1179;илиш", "Hech birini tanlamaslik", "Deselect all");
	static final int si_no_operations = SI("Для этой категории операции не найдены.", "Бу категория учун операциялар топилмади.", "Bu kategoriya uchun operatsiyalar topilmadi.", "No operations found for this category.");
	static final int si_reference_select = SI("Выберите значение", "Кийматни танланг", "Qiymatni tanlang", "Select a value");
%>
<%@ include file="/language.jsp" %>
