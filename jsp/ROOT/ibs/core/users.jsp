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
%><t:page><%
%><t:form title="<%=si_title%>" minWidth="fill" minHeight="fill">
    <script>
        function responseModal(r) {
            if (r) {
                go({});
            }
        }

        function add() {
            go({
                url: "user.jsp?process_code=CREATE_USER",
                target: "modalE",
                dialogHeight: 480,
                dialogWidth: 900,
                lock: false,
                callback: responseModal
            });
        }

        function edit() {
            if (!getDOM("bEdit").disabled) {
                go({
                    url: "user.jsp?process_code=EDIT_USER",
                    param: {
                        model_process_code: "MODEL_USER",
                        user_id: getData(1),
                    },
                    target: "modalE",
                    dialogHeight: 480,
                    dialogWidth: 900,
                    lock: false,
                    callback: responseModal
                });
            }
        }

        function resetPwd() {
            if (!getDOM("bReset").disabled) {
                go({
                    url: "user_reset_password.jsp?process_code=RESET_USER_PASSWORD",
                    param: {
                        user_id: getData(1),
                        login: getData(10)
                    },
                    target: "modalE",
                    dialogHeight: 320,
                    dialogWidth: 500,
                    lock: false,
                    callback: responseModal
                });
            }
        }

        function onAction() {
            edit();
        }

        function access() {
        	 go({
                   url: "adm_user_access.jsp?process_code=ADM_USER_ACCESS",
                   param: {
                             user_id: getData(1)
                          },
                   target: "modalE",
                   dialogHeight: 600,
                   dialogWidth: 1000,
                   lock: false,
                   callback: responseModal
             });
        }

        function local() {
        	 go({
                	url: "adm_user_locals.jsp?process_code=ADM_USER_LOCALS",
                	param: {
                              user_id: getData(1)
                            },
                	target: "modalE",
                	dialogHeight: 500,
                	dialogWidth: 1000,
                	lock: false,
                	callback: responseModal
             });
        }

        function onLoad() {
            if (!dataExist()) {
                getDOM("bEdit").setDisable(true);
                getDOM("bReset").setDisable(true);
                getDOM("bLocal").setDisable(true);
                getDOM("bAccess").setDisable(true);
            }
        }
    </script>
    <table class="formToolbar" align="center">
        <tr>
            <td>
                <input type="button" name="bAdd" onclick="add();" value="<%=lang.get(si_add)%>">
                <input type="button" name="bEdit" onclick="edit();" value="<%=lang.get(si_edit)%>">
                <input type="button" name="bReset" onclick="resetPwd();" value="<%=lang.get(si_reset_password)%>">
                <input type="button" name="bLocal" onclick="local()" value="<%=lang.get(si_local_code)%>">
                <input type="button" name="bAccess" onclick="access();" value="<%=lang.get(si_is_access_denied)%>">
            </td>
            <td id="tableControls" align="right"></td>
        </tr>
        <tr align="center">
            <td colspan="2">
                <b><%=lang.get(si_search)%>
                </b><span id="filterControls"></span></td>
        </tr>
    </table>
    <t:table from="core_users_v">
        <t:field id="1" name="user_id" label="<%=si_user_id%>">
            <t:filter mask="9|0-9-"/>
        </t:field>
        <t:field id="2" name="cb_code" label="<%=si_cb_code%>">
            <t:filter mask="5|0-9"/>
        </t:field>
        <t:field id="3" name="local_code" label="<%=si_local_code%>">
            <t:filter mask="5|0-9"/>
        </t:field>
        <t:field id="4" name="user_type_id" label="<%=si_user_type_id%>"/>
        <t:field id="5" name="user_type_name" label="<%=si_user_type_name%>" type="quote"/>
        <t:field id="6" name="name" label="<%=si_name%>" type="quote">
            <t:filter operator="_search_" mask="80|"/>
        </t:field>
        <t:field id="7" name="pinfl" label="<%=si_pinfl%>">
            <t:filter operator="_like_" mask="14|0-9"/>
        </t:field>
        <t:field id="8" name="date_birth" label="<%=si_date_birth%>" type="date">
            <t:filter mask="date"/>
        </t:field>
        <t:field id="9" name="hr_user_id" label="<%=si_hr_user_id%>">
            <t:filter operator="_like_" mask="10|0-9"/>
        </t:field>
        <t:field id="10" name="login" label="<%=si_login%>" type="quote">
            <t:filter operator="_search_" mask="100|"/>
        </t:field>
        <t:field id="11" name="phone_number" label="<%=si_phone_number%>">
            <t:filter operator="_like_" mask="15|"/>
        </t:field>
        <t:field id="12" name="email" label="<%=si_email%>" type="quote">
            <t:filter operator="_search_" mask="100|"/>
        </t:field>
        <t:field id="13" name="language" label="<%=si_language%>"/>
        <t:field id="14" name="is_access_denied" label="<%=si_is_access_denied%>"/>
        <t:field id="15" name="is_access_denied_name" label="<%=si_is_access_denied_name%>" type="quote"/>
        <t:field id="16" name="state" label="<%=si_state%>"/>
        <t:field id="17" name="state_name" label="<%=si_state_name%>" type="quote"/>
        <t:field id="18" name="activate_date" label="<%=si_activate_date%>" type="date"/>
        <t:field id="19" name="deactivate_date" label="<%=si_deactivate_date%>" type="date"/>
        <t:field id="20" name="created_by" label="<%=si_created_by%>">
            <t:filter mask="10|0-9-"/>
        </t:field>
        <t:field id="21" name="created_by_name" label="<%=si_created_by_name%>" type="quote"/>
        <t:field id="22" name="created_on" label="<%=si_created_on%>" type="datetime">
            <t:filter operator="range" mask="datetime"/>
        </t:field>
        <t:field id="23" name="modified_by" label="<%=si_modified_by%>">
            <t:filter mask="10|0-9-"/>
        </t:field>
        <t:field id="24" name="modified_by_name" label="<%=si_modified_by_name%>" type="quote"/>
        <t:field id="25" name="modified_on" label="<%=si_modified_on%>" type="datetime">
            <t:filter operator="range" mask="datetime"/>
        </t:field>
        <t:grid page="" numbering="" withoutCursor="">
            <t:column for="1"/>
            <t:column for="2"/>
            <t:column for="3"/>
            <t:column for="5"/>
            <t:column for="6" align="left"/>
            <t:column for="7"/>
            <t:column for="9"/>
            <t:column for="10"/>
            <t:column for="15"/>
            <t:column for="17"/>
            <t:foot><t:row>
                <t:cell for="8" size="100%"/>
                <t:cell for="11" size="100%"/>
                <t:cell for="12" size="100%"/>
                <t:cell for="18" size="100%"/>
                <t:cell for="19" size="100%"/>
                <t:cell for="21" size="100%"/>
                <t:cell for="22" size="100%"/>
                <t:cell for="24" size="100%"/>
                <t:cell for="25" size="100%"/>
            </t:row></t:foot>
        </t:grid>
    </t:table>
</t:form>
</t:page>
<%!
    static final int si_title = SI("Пользователи", "Фойдаланувчилар", "Foydalanuvchilar", "Users");
    static final int si_add = SI("Добавить", "Кушиш", "Qo'shish", "Add");
    static final int si_edit = SI("Изменить", "Узгартириш", "O'zgartirish", "Edit");
    static final int si_reset_password = SI("Сбросить пароль", "Паролни тиклаш", "Parolni tiklash", "Reset password");
    static final int si_success = SI("Успешно выполнено!", "Муваффакиятли бажарилди!", "Muvaffaqiyatli bajarildi!", "Successfully executed!");
    static final int si_search = SI("Поиск:", "Кидирув:", "Qidiruv:", "Search:");
    static final int si_user_id = SI("Таб.№", "Таб.№", "Tab.№", "ID");
    static final int si_cb_code = SI("Код банка", "Банк коди", "Bank kodi", "Bank code");
    static final int si_local_code = SI("Локальный код", "Локал код", "Lokal kod", "Local code");
    static final int si_user_type_id = SI("Тип", "Тури", "Turi", "Type");
    static final int si_user_type_name = SI("Тип пользователя", "Фойдаланувчи тури", "Foydalanuvchi turi", "User type");
    static final int si_name = SI("ФИО", "Ф.И.Ш.", "F.I.Sh.", "Full name");
    static final int si_pinfl = SI("ПИНФЛ", "ПИНФЛ", "PINFL", "PINFL");
    static final int si_date_birth = SI("Дата рождения", "Тугилган сана", "Tug'ilgan sana", "Date of birth");
    static final int si_hr_user_id = SI("HR ID", "HR ID", "HR ID", "HR ID");
    static final int si_login = SI("Логин", "Логин", "Login", "Login");
    static final int si_phone_number = SI("Телефон", "Телефон", "Telefon", "Phone");
    static final int si_email = SI("Email", "Email", "Email", "Email");
    static final int si_language = SI("Язык", "Тил", "Til", "Language");
    static final int si_is_access_denied = SI("Доступ", "Кириш", "Kirish", "Access");
    static final int si_is_access_denied_name = SI("Доступ к системе", "Тизимга кириш", "Tizimga kirish", "System access");
    static final int si_state = SI("Состояние", "Холати", "Holati", "State");
    static final int si_state_name = SI("Состояние", "Холати", "Holati", "State");
    static final int si_activate_date = SI("Активен с", "Фаол бошланиш санаси", "Faol boshlanish sanasi", "Active from");
    static final int si_deactivate_date = SI("Активен до", "Фаол муддати", "Faol muddati", "Active until");
    static final int si_created_by = SI("Кем создан", "Ким яратган", "Kim yaratgan", "Created by");
    static final int si_created_by_name = SI("Кем создан", "Ким яратган", "Kim yaratgan", "Created by");
    static final int si_created_on = SI("Дата создания", "Яратилган сана", "Yaratilgan sana", "Created on");
    static final int si_modified_by = SI("Кем изменен", "Ким узгартирган", "Kim o'zgartirgan", "Modified by");
    static final int si_modified_by_name = SI("Кем изменен", "Ким узгартирган", "Kim o'zgartirgan", "Modified by");
    static final int si_modified_on = SI("Дата изменения", "Узгартирилган сана", "O'zgartirilgan sana", "Modified on");
%>
<%@ include file="/language.jsp" %>
