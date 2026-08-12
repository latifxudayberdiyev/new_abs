<%@ page contentType="text/html;charset=WINDOWS-1251" language="java" %>
<%@ page import="java.sql.*,java.util.*, uz.fido_biznes.cms.*" %>
<%@ page import="oracle.sql.*, oracle.jdbc.*" %>
<%@ taglib uri="/WEB-INF/cms.tld" prefix="t" %>
<jsp:useBean id="cods" class="iabs.oraDBConnection" scope="session"/>
<jsp:useBean id="stored" class="uz.fido_biznes.sql.StoredObject" scope="session"/>
<jsp:useBean id="user" class="iabs.User" scope="session"/>
<%
    Connection conn = cods.getConnection();
    if (conn == null || user.getUserCode() == null)
        pageContext.setAttribute(Resource.SESSION_EXPIRED, Boolean.TRUE);
    Language lang = new Language(user.getLanguageIndex(), sentences);
    pageContext.setAttribute(Resource.STR_LANGUAGE, lang);
//-------------------------------------------------------------------------------------------------
%><t:page><%
%><t:form title="<%=si_title%>" minWidth="fill" minHeight="fill">
    <style>
        #form, p {
            margin-left: 50px;
        }

        p {
            display: none;
            height: 25px;
            width: 800px;
            padding-left: 6px;
        }

        i {
            font-size: 16px;
        }

        #searchable {
            width: 600px;
            height: 27px;
            padding-top: 3px;
        }

        u {
            color: dodgerblue;
            cursor: hand;
        }

        #focuser {
            width: 1px;
            height: 1px;
        }

        #basepanel {
            margin: 10px 0 10px 20px;
            height: 500px;
            overflow: hidden !important;
        }

        #forms_lists {
            overflow: auto;
            height: 450px;
        }
    </style>
    <script>
        var pos = k = t = m = 0;

        function onLoad() {
            getDOM("searchable").focus();
            em_tags = _.getElementsByTagName("em");
            u_tags = _.getElementsByTagName("u");
            getDOM("forms_lists").innerHTML = parent.global_search;
        }

        document.onclick = function () {
            getDOM("searchable").focus();
        }

        function gcf(code) { //go_clicked_form
            AJAX.load({
                POST: {
                    request: "registerForm",
                    formCode: code
                },
                onSuccess: function (d) {
                    var fc = code,
                        v = [{
                            label: top.hm[fc],
                            formCode: fc,
                            action: top.goUrl
                        }
                        ];
                    for (var i = 0; i < top.mn[1].items.length && v.length <= 20; i++)
                        if (top.mn[1].items[i].formCode != fc)
                            v.push(top.mn[1].items[i]);
                    top.mn[1].items = v;
                    top.fc = fc;
                    top.formTitle.innerHTML = fc + '-' + top.hm[fc].substr(0, top.hm[fc].indexOf('<font'));
                    go({
                        url: d,
                        target: top.contents,
                        lock: false
                    });
                }
            });
        }

        function search_sort(txt) {
            key = window.event.keyCode;
            up_down();
            k = 0;
            for (var j = 0; j < txt.length; j++) {
                if (txt == "\\" || txt == "(" || txt == ")") {
                    txt = txt.replace("\\", "/");
                    txt = txt.replace("(", "");
                    txt = txt.replace(")", "");
                }
            }
            for (i = 0; i < em_tags.length; i++) {
                if (u_tags[i].parentNode.style.display != "none") {
                    if (key == 38 || key == 40) {
                        set_color('n');
                        k++;
                        if (k == pos)
                            set_color('y');
                    } else {
                        pos = t = 0;
                        getDOM('forms_lists').scrollTop = 0;
                        set_color('n');
                        em_tags[i].innerText = em_tags[i].innerText.replace("<b>", "").replace("</b>", "");
                        em_tags[i].innerHTML = replace_to_bold(em_tags[i].innerText, txt);
                    }
                }
                if (txt != "")
                    em_tags[i].parentNode.style.display = "block";
                if (em_tags[i].innerHTML.toUpperCase().search(txt.toUpperCase()) == "-1")
                    em_tags[i].parentNode.style.display = "none";
            }
        }

        function up_down() {
            if (key == "40") { //down
                if (pos < k || k == 0)
                    pos = pos + 1;
                if (pos - t == 10) {
                    getDOM('forms_lists').scrollTop = getDOM('forms_lists').scrollTop + 51;
                    t = t + 1;
                }
            }
            if (key == "38" && pos > 1) { // up
                if (pos - t == 1) {
                    getDOM('forms_lists').scrollTop = getDOM('forms_lists').scrollTop - 51;
                    t = t - 1;
                }
                pos = pos - 1;
            }
        }

        function set_color(is) { // y/n
            if (is == 'y') {
                em_tags[i].parentNode.style.backgroundColor = "#C6DEFF";
                em_tags[i].parentNode.style.border = "1px solid dodgerblue";
            } else if (is == 'n') {
                em_tags[i].parentNode.style.border = "0px";
                em_tags[i].parentNode.style.backgroundColor = "";
            }
        }

        function replace_to_bold(full_txt, srch_txt) {
            var position = full_txt.toUpperCase().indexOf(srch_txt.toUpperCase());
            var midl_txt = full_txt.substring(position, srch_txt.length + position);
            return full_txt.replace(midl_txt, midl_txt.bold());
        }

        function clicking_current() {
            for (var i = 0; i < u_tags.length; i++) {
                if (em_tags[i].parentNode.style.backgroundColor != "")
                    u_tags[i].click();
            }
        }
    </script>
    <form name=fm id=form>
    <br>
    <i><%=lang.get(si_search)%> :</i><input id=searchable onkeyup="search_sort(this.value)"/>
    <input type=button onfocus="clicking_current()" id=focuser>
    <div id=basepanel>
        <div id=forms_lists>
        </div>
    </div>
</t:form>
</t:page>
<t:requests>
    <t:request name="registerForm" responseType="text"><%
        // Используется для регистрация формы с код формы
        String formCode = request.getParameter("formCode");
        session.removeValue("form_code");
        session.removeValue("subsystem");
        session.removeValue("ibs.task");
        try {
            ServletCallableStatement cs = new ServletCallableStatement(stored, request);
            cs.setProcedure("User_Api.Set_Form_Code");
            cs.setNumber("i_Form_Code", formCode);
            cs.setString("i_Put_Recent_Form", "Y");
            cs.registerString("o_Subsystem_Code");
            cs.registerString("o_Task_Code");
            cs.registerString("o_Url");
            cs.execute();
            session.putValue("form_code", formCode);
            session.putValue("subsystem", cs.getString("o_Subsystem_Code"));
            session.putValue("ibs.task", cs.getString("o_Task_Code"));
            session.putValue("form_type", "1");
            out.print(cs.getString("o_Url"));
        } catch (Exception ex) {
            response.setHeader("RT", "script");
    %>alert('<%=Util.quotesEsc(Util.getUserMessage(ex))%>')<%
        }
    %></t:request>
</t:requests>
<%!
    static final int si_title = SI("Поиск формы", "&#1178;идирув формаси", "Qidiruv formasi", "Form search");
    static final int si_search = SI("Поиск", "&#1178;идирув", "Qidiruv", "Search");
    static final int si_template = SI("Искать форму по наименование", "", "", "");
//-------------------------------------------------------------------
%>
<%@ include file="/language.jsp" %>