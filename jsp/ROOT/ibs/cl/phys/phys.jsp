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
                url: "phys_s.jsp?process_code=CREATE_CL_PHYS",
                target: "modalE",
                dialogHeight: 600,
                dialogWidth: 900,
                lock: false,
                callback: responseModal
            });
        }

        function edit() {
            if (!getDOM("bEdit").disabled) {
                go({
                    url: "phys_s.jsp?process_code=EDIT_CL_PHYS",
                    param: {
                        model_process_code: "MODEL_CL_PHYS",
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

        function view() {
            if (!getDOM("bView").disabled) {
                var id = getData(1);
                if (!id) {
                    return;
                }

                go({
                    url: "phys_s.jsp?process_code=GET_CL_PHYS_PERSONAL",
                    param: {
                        client_id: id
                    },

                    target: "modalE",
                    dialogHeight: 600,
                    dialogWidth: 900,
                    lock: false,
                    callback: responseModal
                });
            }
        }

        function protocol() {
            if (!getDOM("bProtocol").disabled) {

                var id = getData(1);

                if (!id) {
                    return;
                }

                go({
                    url: "phys_s.jsp?process_code=PROTOCOL_CL_PHYS",

                    param: {
                        client_id: id
                    },

                    target: "modalE",
                    dialogHeight: 600,
                    dialogWidth: 900,
                    lock: false,
                    callback: responseModal
                });
            }
        }

        function onAction() {
            edit();
        }

        function onLoad() {

            if (!dataExist()) {
                getDOM("bEdit").setDisable(true);
                getDOM("bView").setDisable(true);
                getDOM("bProtocol").setDisable(true);
            }

        }

    </script>
    <table class="formToolbar" align="center">
        <tr>
            <td colspan="3">
            </td>
        </tr>

        <tr>
            <td>
                <input type="button" name="bView" onclick="view();" value="<%=lang.get(si_view)%>">
                <input type="button" name="bAdd" onclick="add();" value="<%=lang.get(si_add)%>">
                <input type="button" name="bProtocol" onclick="protocol();" value="<%=lang.get(si_protocol)%>">
            </td>
        </tr>
    </table>

    <table class="formToolbar" align="center">
        <tr>
            <td id="filterControls" align="left"></td>
            <td id="tableControls" align="right"></td>
        </tr>
    </table>
    <div class="data-grid">
        <t:dynamicGrid gridId="11"/>
    </div>

</t:form>
</t:page>
<%!
    static final int si_title = SI("Пользователи", "Фойдаланувчилар", "Foydalanuvchilar", "Users");
    static final int si_add = SI("Добавить", "Кушиш", "Qo'shish", "Add");
    static final int si_protocol = SI("Протокол", "Протокол", "Protokol", "Protocol");
    static final int si_view = SI("Просмотр", "Кўриш", "Ko‘rish", "View");
%>
<%@ include file="/language.jsp" %>
