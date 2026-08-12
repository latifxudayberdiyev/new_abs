<%@ page contentType="text/html;charset=WINDOWS-1251" language="java" %>
<%@ page import="java.sql.*,java.util.*, uz.fido_biznes.cms.*" %>
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
//-------------------------------------------------------------------------------------------------
%><t:page><%
    String user_id = request.getParameter("user_id");
	try {
		ServletCallableStatement cs = new ServletCallableStatement(stored, request);
		cs.setProcedure("User_Session.PUT_Number");
		cs.setString("i_Key", "adm_user_id_locals");
		cs.setString("i_Value", user_id);
		cs.execute();
	} catch (Exception ex) {
		Util.alertUserMessage(ex, out);
	}
%>
    <t:form title="<%=si_title%>" minWidth="fill" minHeight="fill">

        <div id="basepanel" class="panel">
            <iframe name="frm" style="display:none"></iframe>

            <form name="fm" method="post" target="frm">

                <input type="hidden" name="request" value="save">
                <input type="hidden" name="user_id" value="<%=user_id%>">

                <table class="formToolbar">
                    <tr>
                        <td>
                            <input type="submit" value="<%=lang.get(si_save)%>">
                        </td>
                        <td id="tableControls" align="right">
                            <input type="button" value="<%=lang.get(si_exit)%>" onclick="top.close()">
                        </td>
                    </tr>
                </table>

                <t:table from="adm_rel_user_locals_v">
                    <t:field id="1" name="code" label="<%=si_local_code%>">
                        <t:filter operator="like"/>
                    </t:field>
                    <t:field id="2" name="local_code" label="<%=si_local_code%>"/>
                    <t:field id="3" name="name" label="<%=si_name%>" type="quote" />
                    <t:field id="4" name="filial_code" label="<%=si_filial_code%>"/>
                    <t:field id="5" name="branch_id" label="<%=si_branch_id%>"/>
                    <t:field id="6" name="region_name" label="<%=si_region%>" type="quote" />
                    <t:field id="7" name="Is_Checked">
                        <t:sort orderKey="1" direction="desc" />
                    </t:field>
                    <t:field id="8" name="region_code" label="<%=si_region%>" type="quote">
                        <t:filter optionSQL="select '<option value='|| code ||'>' || name from cbr_region_v " />
                    </t:field>

                    <t:grid numbering="" withoutCursor="" rowColor="d(7)=='1'?'blue':'black'">
                        <t:column for="1" type="checkbox" name="attached" checked="7" />
                        <t:column for="2" align="left" />
                        <t:column for="3" align="left" />
                        <t:column for="4" align="left" />
                        <t:column for="5" align="left" />
                        <t:column for="6" align="left" />
                        <t:column for="1" type="quote" name="user_locals" />
                    </t:grid>
                </t:table>

            </form>
        </div>

    </t:form>
</t:page>

<t:requests>

    <t:request name="save"><%
        try {
            stored.execJsonRequestProcedure("Core_Api.Execute_Process_Clob", request);
            out.print("<script>" +
                    "alert('" + lang.get(si_success) + "');" +
                    "parent.returnValue=true;" +
                    "parent.close();" +
                    "</script>");
        } catch (Exception ex) {
            response.setHeader("RT", "alert");
            Util.alertUserMessage(ex, out);
            out.print("<script>parent.pageLock(false);</script>");
        }
    %></t:request>

</t:requests>

<%!
    static final int si_title = SI("Закрепление локального кода", "Фойдаланувчига локал бириктириш", "Foydalanuvchiga lokal biriktirish", "Assign Locals to User");
    static final int si_save = SI("Сохранить", "Са?лаш", "Saqlash", "Save");
    static final int si_exit = SI("Закрыть", "Ёпиш", "Yopish", "Exit");
    static final int si_search = SI("Поиск:", "?идирув:", "Qidiruv:", "Search:");
    static final int si_name = SI("Наименование", "Номи", "Nomi", "Name");
    static final int si_local_code = SI("Код локала", "Локал коди", "Lokal kodi", "Local code");
    static final int si_region = SI("Регион", "Вилоят", "Viloyat", "Region");
    static final int si_filial_code = SI("Код филиала", "Филиал коди", "Filial kodi", "Filial code");
    static final int si_branch_id = SI("Код отделения", "Бранч коди", "Branch kodi", "Branch id");
    static final int si_success = SI("Успешно выполнено!", "Муваффа?иятли бажарилди!", "Muvaffaqiyatli bajarildi!", "Successfully executed!");
	//-------------------------------------------------------------------------------------------------
%>
<%@ include file="/language.jsp" %>
