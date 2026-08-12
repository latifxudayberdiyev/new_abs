<%@ page contentType="text/html;charset=WINDOWS-1251" pageEncoding="WINDOWS-1251" language="java" %>
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
    /* mode=all: chap panelda operatsiya amallari emas, butun amallar reyestri turadi.
       Ro'yxat server tomonda ACTION_V'dan chiziladi, loadActions() chaqirilmaydi. */
    String operation_id = request.getParameter("operation_id");
    boolean allMode = "all".equals(request.getParameter("mode"));
%>
<%-- title atributi ataylab yo'q: bo'sh title="" da ham freymvork sarlavha qatorini
     chizadi. Quyidagi ochilish tegini o'chirmang - u fayl oxiridagi yopilish
     tegi bilan juftlashadi, aks holda JSP kompilyatsiya qilinmaydi. --%>
<t:form  minWidth="fill" minHeight="fill">
    <link rel="stylesheet" type="text/css" href="css/osm_settings.css?v=12">

    <script>
        var OPERATION_ID     = "<%=(operation_id != null) ? operation_id : ""%>";
        var ALL_MODE         = <%=allMode%>;
        var selectedActionId = null;

        /* Ikkala panel ham ishlatadigan konstantalar */
        var SI_ACTIVE  = "<%=lang.get(si_active)%>";
        var SI_PASSIVE = "<%=lang.get(si_passive)%>";
        var SI_STATE   = "<%=lang.get(si_state)%>";
        var SI_NO_DATA = "<%=lang.get(si_no_data)%>";
        var SI_LOADING = "<%=lang.get(si_loading)%>";
        var SI_YES     = "<%=lang.get(si_yes)%>";
        var SI_NO      = "<%=lang.get(si_no)%>";
        var SI_SAVE    = "<%=lang.get(si_save)%>";
        var SI_DELETE  = "<%=lang.get(si_delete)%>";

        function onLoad() {
            unlockContentCell();
            fitPanes();
            if (window.addEventListener) window.addEventListener("resize", fitPanes, false);
            /* loadActions() shu yerda chaqirilmaydi: 14 ta yashirin forma bitta osmFrame
               iframe'iga yuboriladi, so'rovlar ketma-ket ketishi shart. Ro'yxat refForm
               tugagach onRefsLoaded() ichidan ishga tushadi (settings_postings.jsp). */
            document.getElementById("refForm").submit();
        }

        function unlockContentCell() {
            var base = document.getElementById("base");
            if (!base || !base.tBodies || !base.tBodies[0]) return;
            var row = base.tBodies[0].rows[0];
            if (!row || !row.cells[0]) return;
            if (row.cells[0].className !== "formTitle") {
                row.cells[0].onmousedown = null;
            }
        }
        function fitPanes() {
            var split = document.getElementById("splitBox");
            if (!split) return;
            var top    = split.getBoundingClientRect().top;
            var winH   = window.innerHeight || document.documentElement.clientHeight;
            var h      = Math.max(240, winH - top - 14);
            var bodies = document.getElementsByClassName("pane-body");
            for (var i = 0; i < bodies.length; i++) {
                bodies[i].style.maxHeight = h + "px";
            }
        }

        function esc(v) {
            if (v === null || v === undefined) return "";
            return String(v).replace(/&/g, "&amp;").replace(/</g, "&lt;")
                            .replace(/>/g, "&gt;").replace(/"/g, "&quot;");
        }

        function pill(text, bg, fg) {
            return '<span class="pill" style="background:' + bg + ';color:' + fg + '">' +
                   esc(text) + '</span>';
        }


        function fld(label, ctl, cls) {
            if (cls === true) cls = "wide";
            return '<div class="form-group' + (cls ? " " + cls : "") + '">' +
                   ctl + '<label>' + label + '</label></div>';
        }

        /* placeholder=" " shart: floating label shunga qarab ko'tariladi */
        function txt(nm, val) {
            return '<input type="text" name="' + nm + '" value="' + esc(val ? val : "") +
                   '" placeholder=" ">';
        }

        var ICO_TRASH =
            '<svg viewBox="0 0 16 16" width="13" height="13" fill="currentColor">' +
            '<path d="M6.5 1h3a.5.5 0 0 1 .5.5V2h3.5a.5.5 0 0 1 0 1H13l-.6 10.1a1.5 1.5 0 0 1-1.5 1.4H5.1a1.5 1.5 0 0 1-1.5-1.4L3 3h-.5a.5.5 0 0 1 0-1H6v-.5a.5.5 0 0 1 .5-.5zM4 3l.6 10a.5.5 0 0 0 .5.5h5.8a.5.5 0 0 0 .5-.5L12 3H4zm2.5 2a.5.5 0 0 1 .5.5v6a.5.5 0 0 1-1 0v-6a.5.5 0 0 1 .5-.5zm3 0a.5.5 0 0 1 .5.5v6a.5.5 0 0 1-1 0v-6a.5.5 0 0 1 .5-.5z"/>' +
            '</svg>';

        function ynSelect(nm, val) {
            return '<select name="' + nm + '">' +
                   '<option value="Y"' + (val !== "N" ? ' selected' : '') + '>' + SI_YES + '</option>' +
                   '<option value="N"' + (val === "N" ? ' selected' : '') + '>' + SI_NO  + '</option>' +
                   '</select>';
        }

        function stateSelect(nm, val) {
            return '<select name="' + nm + '">' +
                   '<option value="A"' + (val !== "P" ? ' selected' : '') + '>' + SI_ACTIVE  + '</option>' +
                   '<option value="P"' + (val === "P" ? ' selected' : '') + '>' + SI_PASSIVE + '</option>' +
                   '</select>';
        }

        var activeTab = "post";
        var loadedFor = { post: null, fields: null, valid: null };

        /* tab kodi -> [panel id, tab tugmasi id, yuklovchi funksiya] */
        var TABS = {
            post:   ["ptBody",        "tabPost",   function () { loadPostTemplates();   }],
            fields: ["paneFields",    "tabFields", function () { loadActionFields();    }],
            valid:  ["paneValidates", "tabValid",  function () { loadActionValidates(); }]
        };

        function showTab(name) {
            activeTab = name;
            for (var k in TABS) {
                document.getElementById(TABS[k][0]).style.display = (k === name) ? "" : "none";
                document.getElementById(TABS[k][1]).className = "osm-tab" + (k === name ? " active" : "");
            }
            loadActiveTab();
        }

        function loadActiveTab() {
            if (!selectedActionId) return;
            if (loadedFor[activeTab] === selectedActionId) return;
            loadedFor[activeTab] = selectedActionId;
            TABS[activeTab][2]();
        }

        /* Chap panelda boshqa amal tanlanganda barcha tablar eskiradi */
        function resetTabCache() {
            loadedFor = { post: null, fields: null, valid: null };
        }

        function back() {
            go({ url: "osms.jsp" });
        }
    </script>

<%  if (allMode) { %>
    <div class="osm-tabs">
        <span class="osm-tab" onclick="document.location='osm_methods.jsp';"><%=lang.get(si_tab_validate)%></span>
        <span class="osm-tab" onclick="document.location='osm_getters.jsp';"><%=lang.get(si_tab_getter)%></span>
        <span class="osm-tab active"><%=lang.get(si_actions)%></span>
    </div>
    <table class="formToolbar" align="center">
        <tr>
            <td></td>
            <td id="tableControls" align="right"></td>
        </tr>
    </table>
<%  } else { %>
    <table class="formToolbar" align="center">
        <tr>
            <td>
                <span class="opbadge" id="opCode">&nbsp;</span>
            </td>
            <td id="tableControls" align="right">
                <input type="button" onclick="back();" value="<%=lang.get(si_back)%>">
            </td>
        </tr>
    </table>
<%  } %>

    <div class="split" id="splitBox">
<%@ include file="inc/settings_actions.jsp" %>

        <div class="pane">
            <div class="pane-head tabbar">
                <span class="osm-tab active" id="tabPost" onclick="showTab('post');"><%=lang.get(si_post_templates)%></span>
                <span class="osm-tab" id="tabFields" onclick="showTab('fields');"><%=lang.get(si_fields)%></span>
                <span class="osm-tab" id="tabValid" onclick="showTab('valid');"><%=lang.get(si_validates)%></span>
            </div>
            <div class="pane-body">
<%@ include file="inc/settings_postings.jsp" %>
<%@ include file="inc/settings_fields.jsp" %>
<%@ include file="inc/settings_validates.jsp" %>
            </div>
        </div>

    </div>

    <iframe name="osmFrame" style="display:none"></iframe>

    <%-- state=A: uzilgan (Passiv) bog'lanishlar ro'yxatda ko'rinmaydi.
         Kernel buni Select_Operation_Actions'ning i_State parametriga uzatadi. --%>
    <form id="actForm" method="post" action="osm_settings.jsp" target="osmFrame" style="display:none">
        <input type="hidden" name="request" value="load_actions">
        <input type="hidden" name="process_code" value="GET_OPERATION_ACTIONS">
        <input type="hidden" name="state" value="A">
        <input type="hidden" name="operation_id" value="<%=(operation_id != null) ? operation_id : ""%>">
    </form>

    <form id="oaSaveForm" method="post" action="osm_settings.jsp" target="osmFrame" style="display:none">
        <input type="hidden" name="request" value="save_operation_action">
        <input type="hidden" name="process_code" value="SAVE_OPERATION_ACTION">
        <input type="hidden" name="operation_id">
        <input type="hidden" name="action_id">
        <input type="hidden" name="sort_ord">
        <input type="hidden" name="process_type">
        <input type="hidden" name="is_optional">
        <input type="hidden" name="is_create">
    </form>

    <form id="oaDelForm" method="post" action="osm_settings.jsp" target="osmFrame" style="display:none">
        <input type="hidden" name="request" value="del_operation_action">
        <input type="hidden" name="process_code" value="DEL_OPERATION_ACTION">
        <input type="hidden" name="operation_id">
        <input type="hidden" name="action_id">
    </form>

    <%-- mode=all: amalning o'zini o'chirish (osm_r_actions) --%>
    <form id="acDelForm" method="post" action="osm_settings.jsp" target="osmFrame" style="display:none">
        <input type="hidden" name="request" value="del_action">
        <input type="hidden" name="process_code" value="DEL_ACTION">
        <input type="hidden" name="action_id">
    </form>

    <form id="ptForm" method="post" action="osm_settings.jsp" target="osmFrame" style="display:none">
        <input type="hidden" name="request" value="load_templates">
        <input type="hidden" name="process_code" value="GET_ACTION_POST_TEMPLATES">
        <input type="hidden" name="action_id" id="pt_action_id" value="">
    </form>

    <form id="afForm" method="post" action="osm_settings.jsp" target="osmFrame" style="display:none">
        <input type="hidden" name="request" value="load_fields">
        <input type="hidden" name="process_code" value="GET_ACTION_FIELDS">
        <input type="hidden" name="action_id" id="af_action_id" value="">
    </form>

    <form id="afSaveForm" method="post" action="osm_settings.jsp" target="osmFrame" style="display:none">
        <input type="hidden" name="request" value="save_field">
        <input type="hidden" name="process_code" value="SAVE_ACTION_FIELD">
        <input type="hidden" name="action_field_id">
        <input type="hidden" name="action_id">
        <input type="hidden" name="field_code">
        <input type="hidden" name="field_type">
        <input type="hidden" name="label_mll_code">
        <input type="hidden" name="module_mll_code">
        <input type="hidden" name="description">
        <input type="hidden" name="row_ord">
        <input type="hidden" name="column_ord">
        <input type="hidden" name="placeholder_text">
        <input type="hidden" name="field_mask">
        <input type="hidden" name="field_max_length">
        <input type="hidden" name="is_f9">
        <input type="hidden" name="sql_text">
        <input type="hidden" name="check_value">
        <input type="hidden" name="load_param">
        <input type="hidden" name="sql_exec_loading">
        <input type="hidden" name="is_read_only">
        <input type="hidden" name="is_visible">
        <input type="hidden" name="is_def_sql">
        <input type="hidden" name="def_value">
        <input type="hidden" name="is_required">
        <input type="hidden" name="field_color">
        <input type="hidden" name="text_color">
        <input type="hidden" name="text_size">
        <input type="hidden" name="text_weight">
        <input type="hidden" name="text_align">
        <input type="hidden" name="state">
    </form>

    <form id="afDelForm" method="post" action="osm_settings.jsp" target="osmFrame" style="display:none">
        <input type="hidden" name="request" value="del_field">
        <input type="hidden" name="process_code" value="DEL_ACTION_FIELD">
        <input type="hidden" name="action_field_id">
    </form>

    <form id="avForm" method="post" action="osm_settings.jsp" target="osmFrame" style="display:none">
        <input type="hidden" name="request" value="load_validates">
        <input type="hidden" name="process_code" value="GET_ACTION_VALIDATES">
        <input type="hidden" name="action_id" id="av_action_id" value="">
    </form>

    <%-- Qiymatlar Tekshiruvlar tabi ichida chiziladi (settings_validates.jsp) --%>
    <form id="mbForm" method="post" action="osm_settings.jsp" target="osmFrame" style="display:none">
        <input type="hidden" name="request" value="load_members">
        <input type="hidden" name="process_code" value="GET_VALIDATE_MEMBERS">
        <input type="hidden" name="action_validate_id" id="mb_action_validate_id" value="">
    </form>

    <form id="mbSaveForm" method="post" action="osm_settings.jsp" target="osmFrame" style="display:none">
        <input type="hidden" name="request" value="save_member">
        <input type="hidden" name="process_code" value="SAVE_VALIDATE_MEMBER">
        <input type="hidden" name="member_id">
        <input type="hidden" name="action_validate_id">
        <input type="hidden" name="member_code">
        <input type="hidden" name="name">
        <input type="hidden" name="sort_ord">
        <input type="hidden" name="state">
    </form>

    <form id="mbDelForm" method="post" action="osm_settings.jsp" target="osmFrame" style="display:none">
        <input type="hidden" name="request" value="del_member">
        <input type="hidden" name="process_code" value="DEL_VALIDATE_MEMBER">
        <input type="hidden" name="member_id" id="mb_del_member_id">
    </form>

    <form id="avSaveForm" method="post" action="osm_settings.jsp" target="osmFrame" style="display:none">
        <input type="hidden" name="request" value="save_validate">
        <input type="hidden" name="process_code" value="SAVE_ACTION_VALIDATE">
        <input type="hidden" name="action_validate_id">
        <input type="hidden" name="action_id">
        <input type="hidden" name="code">
        <input type="hidden" name="name">
        <input type="hidden" name="function_id">
        <input type="hidden" name="is_value_check">
        <input type="hidden" name="sort_ord">
        <input type="hidden" name="state">
    </form>

    <form id="avDelForm" method="post" action="osm_settings.jsp" target="osmFrame" style="display:none">
        <input type="hidden" name="request" value="del_validate">
        <input type="hidden" name="process_code" value="DEL_ACTION_VALIDATE">
        <input type="hidden" name="action_validate_id">
    </form>

    <form id="refForm" method="post" action="osm_settings.jsp" target="osmFrame" style="display:none">
        <input type="hidden" name="request" value="load_refs">
        <input type="hidden" name="process_code" value="GET_POST_TEMPLATE_REFS">
    </form>

    <form id="saveForm" method="post" action="osm_settings.jsp" target="osmFrame" style="display:none">
        <input type="hidden" name="request" value="save_template">
        <input type="hidden" name="process_code" value="SAVE_POST_TEMPLATE">
        <input type="hidden" name="post_template_id">
        <input type="hidden" name="action_id">
        <input type="hidden" name="sort_ord">
        <input type="hidden" name="dt_account_type_id">
        <input type="hidden" name="is_dt_own">
        <input type="hidden" name="ct_account_type_id">
        <input type="hidden" name="is_ct_own">
        <input type="hidden" name="summ_getter">
        <input type="hidden" name="purpose_code_getter">
        <input type="hidden" name="purpose_code">
        <input type="hidden" name="purpose_getter">
        <input type="hidden" name="purpose">
        <input type="hidden" name="state">
    </form>

    <form id="delForm" method="post" action="osm_settings.jsp" target="osmFrame" style="display:none">
        <input type="hidden" name="request" value="del_template">
        <input type="hidden" name="process_code" value="DEL_POST_TEMPLATE">
        <input type="hidden" name="post_template_id">
    </form>

</t:form>
</t:page>
<t:requests>
    <t:request name="load_actions"><%
        try {
            String result = stored.execJsonRequestFunction("Core.Mlt_Api.Get_Model_Clob", request);
            out.print("<script>");
            out.print("try { parent.onActionsLoaded(" + result + "); }");
            out.print("catch(e) { parent.onActionsLoaded(null); }");
            out.print("</script>");
        } catch (Exception ex) {
            out.print("<script>parent.onActionsLoaded(null);</script>");
            response.setHeader("RT", "alert");
            Util.alertUserMessage(ex, out);
        }
    %></t:request>

    <t:request name="load_templates"><%
        try {
            String result = stored.execJsonRequestFunction("Core.Mlt_Api.Get_Model_Clob", request);
            out.print("<script>");
            out.print("try { parent.onPostTemplatesLoaded(" + result + "); }");
            out.print("catch(e) { parent.onPostTemplatesLoaded(null); }");
            out.print("</script>");
        } catch (Exception ex) {
            out.print("<script>parent.onPostTemplatesLoaded(null);</script>");
            response.setHeader("RT", "alert");
            Util.alertUserMessage(ex, out);
        }
    %></t:request>

    <t:request name="load_fields"><%
        try {
            String result = stored.execJsonRequestFunction("Core.Mlt_Api.Get_Model_Clob", request);
            out.print("<script>");
            out.print("try { parent.onActionFieldsLoaded(" + result + "); }");
            out.print("catch(e) { parent.onActionFieldsLoaded(null); }");
            out.print("</script>");
        } catch (Exception ex) {
            out.print("<script>parent.onActionFieldsLoaded(null);</script>");
            response.setHeader("RT", "alert");
            Util.alertUserMessage(ex, out);
        }
    %></t:request>

    <t:request name="load_refs"><%
        try {
            String result = stored.execJsonRequestFunction("Core.Mlt_Api.Get_Model_Clob", request);
            out.print("<script>");
            out.print("try { parent.onRefsLoaded(" + result + "); }");
            out.print("catch(e) { parent.onRefsLoaded(null); }");
            out.print("</script>");
        } catch (Exception ex) {
            out.print("<script>parent.onRefsLoaded(null);</script>");
            response.setHeader("RT", "alert");
            Util.alertUserMessage(ex, out);
        }
    %></t:request>

    <t:request name="save_operation_action"><%
        try {
            stored.execJsonRequestProcedure("Core.Mlt_Api.Execute_Process_Clob", request);
            out.print("<script>parent.onActionLinkSaved(true, \"" + lang.get(si_success) + "\");</script>");
        } catch (Exception ex) {
            response.setHeader("RT", "alert");
            Util.alertUserMessage(ex, out);
            out.print("<script>parent.pageLock(false);</script>");
        }
    %></t:request>

    <%-- mode=all: amal o'chirilgach sahifa qayta yuklanadi, ro'yxat server tomonda chiziladi --%>
    <t:request name="del_action"><%
        try {
            stored.execJsonRequestProcedure("Core.Mlt_Api.Execute_Process_Clob", request);
            out.print("<script>parent.onActionRegistrySaved(true, \"" + lang.get(si_deleted) + "\");</script>");
        } catch (Exception ex) {
            response.setHeader("RT", "alert");
            Util.alertUserMessage(ex, out);
            out.print("<script>parent.pageLock(false);</script>");
        }
    %></t:request>

    <t:request name="del_operation_action"><%
        try {
            stored.execJsonRequestProcedure("Core.Mlt_Api.Execute_Process_Clob", request);
            out.print("<script>parent.onActionLinkSaved(true, \"" + lang.get(si_deleted) + "\");</script>");
        } catch (Exception ex) {
            response.setHeader("RT", "alert");
            Util.alertUserMessage(ex, out);
            out.print("<script>parent.pageLock(false);</script>");
        }
    %></t:request>

    <%-- Saqlash/o'chirishdan keyin muvaffaqiyat xabari chiqadi va ro'yxat yangilanadi.
         Xatolik bo'lsa Util.alertUserMessage o'zi alert qiladi, pageLock ochiladi. --%>
    <t:request name="save_template"><%
        try {
            stored.execJsonRequestProcedure("Core.Mlt_Api.Execute_Process_Clob", request);
            out.print("<script>parent.onPtSaved(true, \"" + lang.get(si_success) + "\");</script>");
        } catch (Exception ex) {
            response.setHeader("RT", "alert");
            Util.alertUserMessage(ex, out);
            out.print("<script>parent.pageLock(false);</script>");
        }
    %></t:request>

    <t:request name="del_template"><%
        try {
            stored.execJsonRequestProcedure("Core.Mlt_Api.Execute_Process_Clob", request);
            out.print("<script>parent.onPtSaved(true, \"" + lang.get(si_deleted) + "\");</script>");
        } catch (Exception ex) {
            response.setHeader("RT", "alert");
            Util.alertUserMessage(ex, out);
            out.print("<script>parent.pageLock(false);</script>");
        }
    %></t:request>

    <t:request name="load_validates"><%
        try {
            String result = stored.execJsonRequestFunction("Core.Mlt_Api.Get_Model_Clob", request);
            out.print("<script>");
            out.print("try { parent.onActionValidatesLoaded(" + result + "); }");
            out.print("catch(e) { parent.onActionValidatesLoaded(null); }");
            out.print("</script>");
        } catch (Exception ex) {
            out.print("<script>parent.onActionValidatesLoaded(null);</script>");
            response.setHeader("RT", "alert");
            Util.alertUserMessage(ex, out);
        }
    %></t:request>

    <t:request name="load_members"><%
        try {
            String result = stored.execJsonRequestFunction("Core.Mlt_Api.Get_Model_Clob", request);
            out.print("<script>");
            out.print("try { parent.onMembersLoaded(" + result + "); }");
            out.print("catch(e) { parent.onMembersLoaded(null); }");
            out.print("</script>");
        } catch (Exception ex) {
            out.print("<script>parent.onMembersLoaded(null);</script>");
            response.setHeader("RT", "alert");
            Util.alertUserMessage(ex, out);
        }
    %></t:request>

    <t:request name="save_member"><%
        try {
            stored.execJsonRequestProcedure("Core.Mlt_Api.Execute_Process_Clob", request);
            out.print("<script>parent.onMbSaved(true, \"" + lang.get(si_success) + "\");</script>");
        } catch (Exception ex) {
            response.setHeader("RT", "alert");
            Util.alertUserMessage(ex, out);
            out.print("<script>parent.pageLock(false);</script>");
        }
    %></t:request>

    <t:request name="del_member"><%
        try {
            stored.execJsonRequestProcedure("Core.Mlt_Api.Execute_Process_Clob", request);
            out.print("<script>parent.onMbSaved(true, \"" + lang.get(si_deleted) + "\");</script>");
        } catch (Exception ex) {
            response.setHeader("RT", "alert");
            Util.alertUserMessage(ex, out);
            out.print("<script>parent.pageLock(false);</script>");
        }
    %></t:request>

    <t:request name="save_validate"><%
        try {
            stored.execJsonRequestProcedure("Core.Mlt_Api.Execute_Process_Clob", request);
            out.print("<script>parent.onAvSaved(true, \"" + lang.get(si_success) + "\");</script>");
        } catch (Exception ex) {
            response.setHeader("RT", "alert");
            Util.alertUserMessage(ex, out);
            out.print("<script>parent.pageLock(false);</script>");
        }
    %></t:request>

    <t:request name="del_validate"><%
        try {
            stored.execJsonRequestProcedure("Core.Mlt_Api.Execute_Process_Clob", request);
            out.print("<script>parent.onAvSaved(true, \"" + lang.get(si_deleted) + "\");</script>");
        } catch (Exception ex) {
            response.setHeader("RT", "alert");
            Util.alertUserMessage(ex, out);
            out.print("<script>parent.pageLock(false);</script>");
        }
    %></t:request>

    <t:request name="save_field"><%
        try {
            stored.execJsonRequestProcedure("Core.Mlt_Api.Execute_Process_Clob", request);
            out.print("<script>parent.onAfSaved(true, \"" + lang.get(si_success) + "\");</script>");
        } catch (Exception ex) {
            response.setHeader("RT", "alert");
            Util.alertUserMessage(ex, out);
            out.print("<script>parent.pageLock(false);</script>");
        }
    %></t:request>

    <t:request name="del_field"><%
        try {
            stored.execJsonRequestProcedure("Core.Mlt_Api.Execute_Process_Clob", request);
            out.print("<script>parent.onAfSaved(true, \"" + lang.get(si_deleted) + "\");</script>");
        } catch (Exception ex) {
            response.setHeader("RT", "alert");
            Util.alertUserMessage(ex, out);
            out.print("<script>parent.pageLock(false);</script>");
        }
    %></t:request>
</t:requests>
<%!
    static final int si_back =
            SI("Назад", "Оркага", "Orqaga", "Back");

    static final int si_tab_validate =
            SI("Функции проверки", "Текшириш функциялари", "Tekshiruv funksiyalari", "Validation Functions");

    static final int si_tab_getter =
            SI("Функции геттеров", "Геттер функциялари", "Getter funksiyalari", "Getter Functions");

    static final int si_state =
            SI("Статус", "Холати", "Holati", "Status");

    static final int si_active =
            SI("Активный", "Актив", "Aktiv", "Active");

    static final int si_passive =
            SI("Пассивный", "Пассив", "Passiv", "Passive");

    static final int si_no_data =
            SI("Данные отсутствуют", "Маълумот йўк", "Ma'lumot yo'q", "No data");

    static final int si_loading =
            SI("Загрузка...", "Юкланмокда...", "Yuklanmoqda...", "Loading...");

    static final int si_success =
            SI("Успешно выполнено!", "Муваффакиятли бажарилди!", "Muvaffaqiyatli bajarildi!",
               "Successfully executed!");

    static final int si_deleted =
            SI("Удалено", "Учирилди", "O'chirildi", "Deleted");

    static final int si_yes = SI("Да", "Ха", "Ha", "Yes");
    static final int si_no  = SI("Нет", "Йук", "Yo'q", "No");

    static final int si_save =
            SI("Сохранить", "Саклаш", "Saqlash", "Save");

    static final int si_delete =
            SI("Удалить", "Учириш", "O'chirish", "Delete");
%>
<%@ include file="/language.jsp" %>
