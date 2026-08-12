<%@ page contentType="text/html;charset=WINDOWS-1251" language="java" %>
<%@ page import="java.sql.*, java.util.*, uz.fido_biznes.cms.*" %>
<%@ page import="oracle.sql.*, oracle.jdbc.*" %>
<%@ taglib uri="/WEB-INF/cms.tld" prefix="t" %>

<jsp:useBean id="cods" class="iabs.oraDBConnection" scope="session"/>
<jsp:useBean id="stored" class="uz.fido_biznes.sql.StoredObject" scope="session"/>
<jsp:useBean id="user" class="iabs.User" scope="session"/>

<%
    Connection conn = cods.getConnection();

    if (conn == null || user.getUserCode() == null) {
        pageContext.setAttribute(Resource.SESSION_EXPIRED, Boolean.TRUE);
    }

    Language lang = new Language(user.getLanguageIndex(), sentences);
    pageContext.setAttribute(Resource.STR_LANGUAGE, lang);

    String process_code = request.getParameter("process_code");

    if (process_code == null) {
        process_code = "";
    }

    String client_id = request.getParameter("client_id");

    if (client_id == null || client_id.equals("")) {
        client_id = request.getParameter("user_id");
    }

    boolean is_add = "CREATE_CL_PHYS".equalsIgnoreCase(process_code);

    boolean is_edit = "EDIT_CL_PHYS".equalsIgnoreCase(process_code);

    boolean is_view = "GET_CL_PHYS_PERSONAL".equalsIgnoreCase(process_code);

    boolean is_protocol = "PROTOCOL_CL_PHYS".equalsIgnoreCase(process_code);

    boolean is_readonly = is_view || is_protocol;

    String model_process_code = "MODEL_CL_PHYS";

    if ((is_edit || is_view) &&
            client_id != null &&
            !client_id.equals("")) {

        try {

            out.println(
                    "<script>" +
                            "var data=" +
                            stored.execJsonRequestFunction(
                                    "Core_Api.Get_Model_Clob",
                                    request
                            ) +
                            ";</script>"
            );

        } catch (Exception ex) {

            Util.alertUserMessage(ex, out);
        }
    }
%>

<t:page>

    <t:form
            title="<%= is_add ? si_add_title :
                is_edit ? si_edit_title :
                is_view ? si_view_title :
                si_protocol_title %>"
            minWidth="fill"
            minHeight="fill">

        <script>

            var readOnlyMode = <%=is_readonly ? "true" : "false"%>;

            function onLoad() {

                if (readOnlyMode) {
                    setReadOnly();
                }

            }

            function setReadOnly() {

                var fm = document.forms["fm"];

                if (!fm) {
                    return;
                }

                for (var i = 0; i < fm.elements.length; i++) {

                    var el = fm.elements[i];

                    if (el.type == "hidden" ||
                        el.type == "button" ||
                        el.type == "submit") {
                        continue;
                    }

                    el.disabled = true;
                    el.readOnly = true;
                }
            }

            function saveForm() {

                if (readOnlyMode) {
                    return false;
                }

                return true;
            }

            function closeForm() {
                parent.close();
            }

        </script>


        <div id="basepanel" class="panel">

            <iframe
                    name="frm"
                    style="display:none">
            </iframe>


            <form name="fm" method="post" target="frm" onsubmit="return saveForm();">

                <input type="hidden" name="request" value="save">
                <input type="hidden" name="process_code" value="<%=process_code%>">
                <input type="hidden" name="model_process_code" value="<%=model_process_code%>">
                <input type="hidden" name="client_id" value="<%=client_id == null ? "" : client_id%>">
                <input type="hidden" name="user_id" value="<%=client_id == null ? "" : client_id%>">

                <table
                        class="formToolbar"
                        align="center">

                    <tr>

                        <td>
                            <% if (!is_readonly) { %>
                            <input type="submit" value="<%=lang.get(si_save)%>">
                            <% } %>
                            <input type="button" onclick="closeForm();" value="<%=lang.get(si_exit)%>">
                        </td>

                    </tr>

                </table>

                <div class="form-group">
                    <input name="client_code" mask="6|0-9" maxlength="6" class="form-control">
                    <label><%=lang.get(si_client_code)%>:</label>
                </div>

                <div class="form-group">
                    <input name="full_name" mask="250|" class="form-control">
                    <label><%=lang.get(si_full_name)%>:</label>
                </div>

                <div class="form-group">
                    <input name="last_name" mask="100|" class="form-control">
                    <label><%=lang.get(si_last_name)%>:</label>
                </div>

                <div class="form-group">
                    <input name="first_name" mask="100|" class="form-control">
                    <label><%=lang.get(si_first_name)%>:</label>
                </div>

                <div class="form-group">
                    <input name="patronymic" mask="100|" class="form-control">
                    <label><%=lang.get(si_patronymic)%>:</label>
                </div>

                <div class="form-group">
                    <input name="pinfl" mask="14|0-9" maxlength="14" class="form-control">
                    <label><%=lang.get(si_pinfl)%>:</label>
                </div>

                <div class="form-group">
                    <input name="date_birth" mask="date" class="form-control">
                    <label><%=lang.get(si_date_birth)%>:</label>
                </div>

                <div class="form-group">
                    <input name="segment" mask="100|" class="form-control">
                    <label><%=lang.get(si_segment)%>:</label>
                </div>

                <div class="form-group">
                    <input name="sub_segment" mask="100|" class="form-control">
                    <label><%=lang.get(si_sub_segment)%>:</label>
                </div>

                <fieldset>
                    <legend><%=lang.get(si_document)%>
                    </legend>
                    <div class="form-group">
                        <input name="doc_type_cd" mask="30|" class="form-control">
                        <label><%=lang.get(si_doc_type)%>:</label>
                    </div>

                    <div class="form-group">

                        <input name="doc_number" mask="50|" class="form-control">

                        <label>
                            <%=lang.get(si_doc_number)%>:
                        </label>
                    </div>

                    <div class="form-group">
                        <input name="doc_date" mask="date" class="form-control">
                        <label><%=lang.get(si_doc_date)%>:</label>
                    </div>

                </fieldset>


                <div class="form-group">

                    <input name="mobile_phone" mask="20|0-9+()-" class="form-control">

                    <label>
                        <%=lang.get(si_mobile_phone)%>:
                    </label>

                </div>

                <div class="form-group">
                    <input name="segment_code" mask="50|" class="form-control">

                    <label><%=lang.get(si_segment_code)%>:</label>

                </div>

                <div class="form-group">

                    <select name="state" class="form-control">
                        <t:options code="code" name="name" from="r_state_v"/>

                    </select>

                    <label>
                        <%=lang.get(si_state)%>:
                    </label>

                </div>

            </form>

        </div>

    </t:form>

</t:page>

<t:requests>

    <t:request name="save">

        <%

            try {

                if (!is_add && !is_edit) {
                    throw new Exception("Invalid process");
                }

                stored.execJsonRequestProcedure(
                        "Core_Api.Execute_Process_Clob",
                        request
                );

                out.print(
                        "<script>" +
                                "alert('" +
                                lang.get(si_success) +
                                "');" +
                                "parent.returnValue=true;" +
                                "parent.close();" +
                                "</script>"
                );

            } catch (Exception ex) {
                response.setHeader("RT", "alert");
                Util.alertUserMessage(ex, out);
                out.print(
                        "<script>" +
                                "parent.pageLock(false);" +
                                "</script>"
                );
            }

        %>

    </t:request>

    <t:request name="get_full_name">

        <%

            try {
                String last_name = request.getParameter("last_name");
                String first_name = request.getParameter("first_name");
                String patronymic = request.getParameter("patronymic");
                StringBuilder fullName = new StringBuilder();

                if (last_name != null && !last_name.trim().equals("")) {
                    fullName.append(last_name.trim());
                }

                if (first_name != null && !first_name.trim().equals("")) {

                    if (fullName.length() > 0) {
                        fullName.append(" ");
                    }

                    fullName.append(first_name.trim());
                }

                if (patronymic != null &&
                        !patronymic.trim().equals("")) {
                    if (fullName.length() > 0) {
                        fullName.append(" ");
                    }
                    fullName.append(patronymic.trim());
                }

                JArray result = new JArray();
                result.push(fullName.toString());
                out.print(result.toString());

            } catch (Exception ex) {
                response.setHeader("RT", "error");
                out.print(Util.getUserMessage(ex));
            }

        %>
    </t:request>
</t:requests>

<%!
    static final int si_add_title = SI("Добавление физического лица", "Жисмоний шахс кушиш", "Jismoniy shaxs qo'shish", "Add physical person");
    static final int si_edit_title = SI("Изменение физического лица", "Жисмоний шахсни узгартириш", "Jismoniy shaxsni o'zgartirish", "Edit physical person");
    static final int si_view_title = SI("Просмотр физического лица", "Жисмоний шахсни куриш", "Jismoniy shaxsni ko'rish", "View physical person");
    static final int si_protocol_title = SI("Протокол физического лица", "Жисмоний шахс протоколи", "Jismoniy shaxs protokoli", "Physical person protocol");
    static final int si_save = SI("Сохранить", "Саклаш", "Saqlash", "Save");
    static final int si_exit = SI("Выход", "Чикиш", "Chiqish", "Exit");
    static final int si_success = SI("Успешно выполнено!", "Муваффакиятли бажарилди!", "Muvaffaqiyatli bajarildi!", "Successfully executed!");
    static final int si_client_code = SI("Код клиента", "Мижоз коди", "Mijoz kodi", "Client code");
    static final int si_full_name = SI("ФИО", "Ф.И.Ш.", "F.I.Sh.", "Full name");
    static final int si_last_name = SI("Фамилия", "Фамилия", "Familiya", "Last name");
    static final int si_first_name = SI("Имя", "Исм", "Ism", "First name");
    static final int si_patronymic = SI("Отчество", "Отасининг исми", "Otasining ismi", "Patronymic");
    static final int si_pinfl = SI("ПИНФЛ", "ПИНФЛ", "PINFL", "PINFL");
    static final int si_date_birth = SI("Дата рождения", "Тугилган сана", "Tug'ilgan sana", "Date of birth");
    static final int si_segment = SI("Сегмент", "Сегмент", "Segment", "Segment");
    static final int si_sub_segment = SI("Под-сегмент", "?уйи сегмент", "Quyi segment", "Sub-segment");
    static final int si_document = SI("Документ", "Хужжат", "Hujjat", "Document");
    static final int si_doc_type = SI("Тип документа", "Хужжат тури", "Hujjat turi", "Document type");
    static final int si_doc_number = SI("Номер документа", "Хужжат раками", "Hujjat raqami", "Document number");
    static final int si_doc_date = SI("Дата документа", "Хужжат санаси", "Hujjat sanasi", "Document date");
    static final int si_mobile_phone = SI("Мобильный номер", "Мобил телефон", "Mobil telefon", "Mobile number");
    static final int si_segment_code = SI("Код сегмента", "Сегмент коди", "Segment kodi", "Segment code");
    static final int si_state = SI("Состояние клиента", "Мижоз холати", "Mijoz holati", "Client state");

%>

<%@ include file="/language.jsp" %>