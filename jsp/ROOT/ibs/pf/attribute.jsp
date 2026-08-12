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
	String code = request.getParameter("code");
	boolean is_edit = (code != null && !code.equals(""));
	if (is_edit) {
		try {
			out.println("<script>var data=" + stored.execJsonRequestFunction("Core_Api.Get_Model_Clob", request) + ";</script>");
			/* fillForm() (form.js) "data" ichidagi HAR BIR kalitni forma elementiga
			   avtomatik yozishga urinadi (initForm -> fillForm) va mos elementi yo'q
			   kalitda (masalan module_code, category_ids) xato tashlab, butun
			   window.onload'ni to'xtatadi (brauzer konsolida tasdiqlangan: "Cannot read
			   properties of null (reading 'setValue')" at fillForm). Shu uchun asl
			   modelni pfAttrModel'ga ko'chirib, "data"ni bo'shatamiz - fillForm bo'sh
			   obyektda hech nima qilmay xavfsiz o'tadi, haqiqiy to'ldirishni esa
			   o'zimiz pfAttrModel orqali onLoad()da qilamiz. */
			out.println("<script>window.pfAttrModel={};for(var k in data){window.pfAttrModel[k]=data[k];delete data[k];}</script>");
		} catch (Exception ex) {
			Util.alertUserMessage(ex, out);
		}
	}
%><t:form title="<%=is_edit?si_edit_title:si_add_title%>" minWidth="fill" minHeight="fill">
	<script>
		var pfAttrIsModule = false;
		/* MUHIM: HTML'da disabled maydon FORMA BILAN UMUMAN YUBORILMAYDI -
		   shu sabab "qulflash" uchun disabled ishlatilsa, saqlashda o'sha
		   qiymat serverga yetib bormaydi (name uchun bu ORA-01403 "no data
		   found" bilan tugaydi, chunki Pf_Kernel majburiy deb kutadi).
		   Shu sabab: (1) nom maydoni uchun disabled emas, readOnly ishlatiladi
		   (readOnly maydon HAM qiymatini yuboradi, faqat tahrirlab bo'lmaydi);
		   (2) is_default checkbox uchun ko'rinadigan checkbox HECH QACHON
		   name="is_default" olib yurmaydi - haqiqiy yuboriladigan qiymat
		   alohida yashirin maydonda (pfAttrIsDefaultHidden) saqlanadi va
		   checkbox qulflangan bo'lsa ham har doim sinxron yangilanadi. */
		function pfSyncIsDefault() {
			var checked = document.getElementById("pfAttrIsDefaultUi").checked;
			document.getElementById("pfAttrIsDefaultHidden").value = checked ? "1" : "0";
		}
		function toggleAttrType() {
			/* Ikki xil qulflash qoidasi bor:
			   - EDITABLE atributda Is_Default belgilansa (masalan Umumiy) -
			     bu qaytarib bo'lmaydigan qaror: nom va checkbox darhol
			     qulflanadi, faqat parametr qo'shish (parameter.jsp) qoladi.
			   - SPECIAL atributda (masalan Filial) nom doim qulflangan, lekin
			     Is_Default/kategoriya doim erkin qoladi - chunki uning vazifasi
			     aynan kategoriya bo'yicha cheklanishi mumkinligida. */
			var isSpecial = (document.fm.source_type.value === "SPECIAL");
			var isDefault = document.getElementById("pfAttrIsDefaultUi").checked;
			var isPermanentDefault = !isSpecial && isDefault;
			document.fm.name.readOnly = pfAttrIsModule || isSpecial || isPermanentDefault;
			document.fm.name.style.background = document.fm.name.readOnly ? "#f0f2f5" : "";
			document.getElementById("pfAttrIsDefaultUi").disabled = pfAttrIsModule || isPermanentDefault;
			document.getElementById("pfAttrCategoriesRow").style.display = isDefault ? "none" : "";
			document.getElementById("pfAttrDefaultLockNote").style.display = isPermanentDefault ? "" : "none";
			pfSyncIsDefault();
		}
		function onLoad() {
			var m = window.pfAttrModel;
			if (m) {
				/* SM_R_PROCESSES.RELATION_KEY = 'attribute_id' EDIT_PF_ATTRIBUTE uchun -
				   Sm_Kernel.Set_Object aynan shu nomdagi maydonni qidiradi, "sm_relation_id"
				   emas. Noto'g'ri nom bilan saqlashda "ORA-01403: no data found" xato beradi
				   (Sm_Kernel.Set_Object -> Get_Object_By_Rel). */
				document.fm.attribute_id.value = m.attribute_id;
				document.fm.code.value = m.code;
				document.fm.name.value = m.name;
				document.fm.source_type.value = m.source_type || "EDITABLE";
				document.fm.special_type.value = m.special_type || "";
				document.getElementById("pfAttrIsDefaultUi").checked = (m.is_default == 1);
				if (m.is_module == 1) {
					pfAttrIsModule = true;
					document.getElementById("pfAttrModuleNote").style.display = "";
				}
				var ids = m.category_ids || [];
				for (var i = 0; i < ids.length; i++) {
					var cb = document.getElementById("pfAttrCat_" + ids[i]);
					if (cb) cb.checked = true;
				}
			}
			toggleAttrType();
		}
	</script>
	<div id="basepanel" class="panel">
		<iframe name="frm" style="display:none"></iframe>
		<form name="fm" method="post" action="attribute.jsp?process_code=<%=is_edit?"EDIT_PF_ATTRIBUTE":"CREATE_PF_ATTRIBUTE"%>" target="frm">
			<input type="hidden" name="request" value="save">
			<input type="hidden" name="attribute_id" value="">
			<input type="hidden" name="code" value="">
			<input type="hidden" name="user_id" value="<%=user.getUserCode()%>">
			<table class="formToolbar" align="center">
				<tr>
					<td>
						<input type="submit" value="<%=lang.get(si_save)%>">
					<td id="tableControls" align="right">
						<input type="button" onclick="parent.close();" value="<%=lang.get(si_exit)%>">
			</table>
			<div id="pfAttrModuleNote" style="display:none;font-size:12px;color:#666;padding:0 0 8px;"><%=lang.get(si_module_note)%></div>
			<div style="display:grid;grid-template-columns:2fr;gap:5px">
				<div class="form-group">
					<input name="name" r="1" mask="200|" class="form-control">
					<label><%=lang.get(si_name)%> <q></q>:</label>
				</div>
			</div>
			<%-- "Тип атрибута" (source_type) va "Вид специального атрибута" (special_type)
			     frontenddan boshqarilmaydi - SPECIAL faqat backend/DB darajasida
			     tayyorlanadi (hozircha Filial/BRANCH), shu sabab bu ikkalasi endi
			     ko'rinmas maydonlar: yangi atributda EDITABLE bo'lib qoladi, mavjud
			     atributni tahrirlashda esa joriy qiymati o'zgarishsiz saqlanib
			     qoladi (onLoad() orqali modeldan to'ldiriladi). --%>
			<input type="hidden" name="source_type" value="EDITABLE">
			<input type="hidden" name="special_type" value="">
			<input type="hidden" id="pfAttrIsDefaultHidden" name="is_default" value="0">
			<div style="margin-bottom:12px;display:flex;align-items:center;gap:6px;">
				<input type="checkbox" id="pfAttrIsDefaultUi" onchange="toggleAttrType();">
				<label for="pfAttrIsDefaultUi" style="font-size:13px;"><%=lang.get(si_is_default)%></label>
			</div>
			<div style="font-size:11px;color:#888;margin:-8px 0 12px;"><%=lang.get(si_is_default_hint)%></div>
			<div id="pfAttrDefaultLockNote" style="display:none;font-size:11px;color:#b45309;margin:-8px 0 12px;"><%=lang.get(si_default_lock_note)%></div>
			<div style="margin-bottom:16px;" id="pfAttrCategoriesRow">
				<label style="display:block;font-size:12.5px;font-weight:600;margin-bottom:4px;"><%=lang.get(si_categories)%>:</label>
				<div style="font-size:11px;color:#888;margin-bottom:6px;"><%=lang.get(si_categories_hint)%></div>
				<div style="border:1px solid #d7dee8;border-radius:4px;padding:8px 10px;max-height:160px;overflow:auto;"><%
						Statement st = null;
						ResultSet rs = null;
						try {
							st = conn.createStatement();
							rs = st.executeQuery("select ID, NAME from PF_R_CATEGORIES_V order by NAME");
							boolean any = false;
							while (rs.next()) {
								any = true;
								long catId = rs.getLong("ID");
								String catName = rs.getString("NAME");
					%>
						<label style="display:flex;align-items:center;gap:6px;font-size:13px;padding:3px 0;">
							<input type="checkbox" id="pfAttrCat_<%=catId%>" name="category_ids" value="<%=catId%>">
							<%=esc(catName)%>
						</label><%
							}
							if (!any) {
					%>
						<div style="font-size:12px;color:#888;"><%=lang.get(si_no_categories)%></div><%
							}
						} finally {
							if (rs != null) rs.close();
							if (st != null) st.close();
						}
					%>
					</div>
			</div>
		</form>
	</div>
</t:form>
</t:page>
<t:requests>
	<t:request name="save"><%
		try {
			stored.execJsonRequestProcedure("Core_Api.Execute_Process_Clob", request);
			out.print("<script>alert('" + lang.get(si_success) + "');parent.returnValue=true;parent.close();</script>");
		} catch (Exception ex) {
			response.setHeader("RT", "alert");
			Util.alertUserMessage(ex, out);
			out.print("<script>parent.pageLock(false);</script>");
		}
	%></t:request>
</t:requests>
<%!
	static String esc(String s) {
		if (s == null) return "";
		return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
	}
	static final int si_add_title = SI("Добавить атрибут", "Атрибут &#1179;&#1118;шиш", "Atribut qo'shish", "Add attribute");
	static final int si_edit_title = SI("Изменить атрибут", "Атрибутни &#1118;згартириш", "Atributni o'zgartirish", "Edit attribute");
	static final int si_save = SI("Сохранить", "Са&#1179;лаш", "Saqlash", "Save");
	static final int si_success = SI("Успешно выполнено!", "Муваффа&#1179;иятли бажарилди!", "Muvaffaqiyatli bajarildi!", "Successfully executed!");
	static final int si_exit = SI("Отмена", "Бекор &#1179;илиш", "Bekor qilish", "Cancel");
	static final int si_name = SI("Наименование атрибута", "Атрибут номи", "Atribut nomi", "Attribute name");
	static final int si_is_default = SI("Всегда показывать (во всех категориях)", "Доим кўрсатилсин (барча категорияларда)", "Doim ko'rsatilsin (barcha kategoriyalarda)", "Always show (in all categories)");
	static final int si_is_default_hint = SI("Атрибут будет отображаться на всех продуктах, независимо от категории.", "Атрибут категориядан &#1179;атъи назар барча ма&#1203;сулотларда кўринади.", "Atribut kategoriyadan qat'i nazar barcha mahsulotlarda ko'rinadi.", "The attribute will appear on all products, regardless of category.");
	static final int si_default_lock_note = SI("Внимание: это решение необратимо. После сохранения название и этот флажок нельзя будет изменить - можно будет только добавлять параметры.", "Ди&#1179;&#1179;ат: бу &#1179;арорни &#1179;айта ўзгартириб бўлмайди. Са&#1179;лангандан кейин номи ва бу белги ўзгартирилмайди - фа&#1179;ат параметр &#1179;ўшиш мумкин &#1179;олади.", "Diqqat: bu qarorni qaytarib bo'lmaydi. Saqlangandan keyin nomi va bu belgi o'zgartirilmaydi - faqat parametr qo'shish mumkin qoladi.", "Warning: this decision is irreversible. After saving, the name and this checkbox cannot be changed - only adding parameters will remain possible.");
	static final int si_categories = SI("Категории", "Категориялар", "Kategoriyalar", "Categories");
	static final int si_categories_hint = SI("Атрибут будет отображаться как вкладка только для продуктов в выбранных категориях.", "Атрибут белгиланган категориялардаги ма&#1203;сулотларда вкладка сифатида кўринади.", "Atribut belgilangan kategoriyalar mahsulotlarida vkladka sifatida ko'rinadi.", "The attribute will appear as a tab only for products in the selected categories.");
	static final int si_no_categories = SI("Сначала создайте категорию.", "Аввал категория яратинг.", "Avval kategoriya yarating.", "Create a category first.");
	static final int si_module_note = SI("Параметры этого атрибута формируются другим модулем. Здесь можно только изменить категории, где он доступен.", "Бу атрибутнинг параметрлари бош&#1179;а модул томонидан яратилади. Бу ерда фа&#1179;ат у мавжуд бўлган категорияларни ўзгартириш мумкин.", "Bu atributning parametrlari boshqa modul tomonidan yaratiladi. Bu yerda faqat u mavjud bo'lgan kategoriyalarni o'zgartirish mumkin.", "This attribute's parameters are formed by another module. Here you can only change the categories where it is available.");
%>
<%@ include file="/language.jsp" %>
