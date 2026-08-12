<%@ page pageEncoding="WINDOWS-1251" %>

<div class="pane">
    <div class="pane-head">
<%      if (allMode) { %>
        <span>
            <button type="button" class="btn-pri" onclick="addAction();">+&nbsp;<%=lang.get(si_ac_add)%></button>
            <button type="button" class="ico" onclick="editAction();"
                    style="width:auto;padding:0 10px"><%=lang.get(si_ac_edit)%></button>
            <button type="button" class="ico" onclick="delAction();"
                    style="width:auto;padding:0 10px"><%=lang.get(si_delete)%></button>
        </span>
<%      } else { %>
        <button type="button" class="btn-pri" onclick="openActionsModal();"
                id="oaAddBtn">+&nbsp;<%=lang.get(si_oa_add)%></button>
<%      } %>
    </div>
    <div class="pane-body">
        <table class="lst">
            <thead>
                <tr>
<%              if (allMode) { %>
                    <th class="st"><%=lang.get(si_ac_code)%></th>
<%              } %>
                    <th><%=lang.get(si_action_name)%></th>
                    <th class="st"><%=lang.get(si_state)%></th>
<%              if (!allMode) { %>
                    <th class="st"></th>
<%              } %>
                </tr>
            </thead>
            <tbody id="actTbody" onclick="onActionRowClick(event);">
<%          if (allMode) {
                /* mode=all: ro'yxat SM orqali emas, ACTION_V'dan server tomonda chiziladi */
                java.sql.PreparedStatement psAll = null;
                java.sql.ResultSet rsAll = null;
                boolean anyRow = false;
                try {
                    psAll = conn.prepareStatement(
                        "select action_id, action_code, name, state from Core.Action_V order by name");
                    rsAll = psAll.executeQuery();
                    while (rsAll.next()) {
                        anyRow = true;
                        boolean act = "A".equals(rsAll.getString("state"));
                        String acCode = rsAll.getString("action_code");
%>              <tr data-id="<%=rsAll.getString("action_id")%>">
                    <td class="st"><%=(acCode != null) ? acCode : ""%></td>
                    <td><%=rsAll.getString("name")%></td>
                    <td class="st"><span class="pill" style="background:<%=act?"#e0f2ea":"#eef1f5"%>;color:<%=act?"#1a7f5a":"#667085"%>"><%=lang.get(act?si_active:si_passive)%></span></td>
                </tr>
<%                  }
                } catch (Exception ex) {
                } finally {
                    if (rsAll != null) try { rsAll.close(); } catch (Exception e) {}
                    if (psAll != null) try { psAll.close(); } catch (Exception e) {}
                }
                if (!anyRow) { %>
                <tr><td colspan="3" class="no-data"><%=lang.get(si_no_data)%></td></tr>
<%              }
            } else { %>
                <tr><td colspan="3" class="no-data"><%=lang.get(si_loading)%></td></tr>
<%          } %>
            </tbody>
        </table>
    </div>
</div>

<script>
    var SI_OA_CONFIRM_DEL = "<%=lang.get(si_oa_confirm_del)%>";
    var SI_AC_NEED_SEL    = "<%=lang.get(si_ac_need_sel)%>";
    var SI_AC_CONFIRM_DEL = "<%=lang.get(si_ac_confirm_del)%>";

    /* Amallar ro'yxatini yuklash.
       Natija load_actions so'rov blokidan onActionsLoaded()'ga keladi. */
    function loadActions() {
        var tb = document.getElementById("actTbody");
        tb.innerHTML = '<tr><td colspan="5" class="no-data">' + SI_LOADING + '</td></tr>';
        document.getElementById("actForm").submit();
    }

    function onActionsLoaded(model) {
        var rows = (model && model.list) ? model.list : [];
        var tb   = document.getElementById("actTbody");

        /* mode=all da opCode elementi yo'q */
        var badge = document.getElementById("opCode");
        if (badge && model && model.operation_code) {
            badge.innerHTML = esc(model.operation_code);
        }

        if (!rows.length) {
            tb.innerHTML = '<tr><td colspan="3" class="no-data">' + SI_NO_DATA + '</td></tr>';
            return;
        }

        var html = "";
        for (var i = 0; i < rows.length; i++) {
            var r     = rows[i];
            var name  = r.action_name ? r.action_name : r.name_mll_code;
            var isAct = (r.link_state === "A");

            html += '<tr data-id="' + esc(r.action_id) + '">' +
                    '<td>' + esc(name) + '</td>' +
                    '<td class="st">' + pill(isAct ? SI_ACTIVE : SI_PASSIVE,
                                             isAct ? "#e0f2ea" : "#eef1f5",
                                             isAct ? "#1a7f5a" : "#667085") + '</td>' +
                    '<td class="st mem-act">' +
                    (isAct ? '<span class="ico del" title="' + SI_DELETE + '"' +
                             ' onclick="event.stopPropagation();delActionLink(\'' + esc(r.action_id) + '\');">' +
                             ICO_TRASH + '</span>' : '') +
                    '</td></tr>';
        }
        tb.innerHTML = html;
    }

    /* Biriktirish va tartib modal oynada: butun ro'yxat bitta so'rovda saqlanadi,
       aks holda tartibni almashtirishda OSM_R_OPERATION_ACTIONS_U1 to'qnashadi. */
    function openActionsModal() {
        go({
            url: "osm_operation_action.jsp",
            param: { operation_id: OPERATION_ID },
            target: "modalE",
            dialogHeight: 520,
            dialogWidth: 760,
            lock: false,
            callback: function (r) { if (r) loadActions(); }
        });
    }

    /* Yumshoq o'chirish: qator ro'yxatdan yo'qolmaydi, holati Passiv bo'ladi */
    function delActionLink(actionId) {
        if (!confirm(SI_OA_CONFIRM_DEL)) return;
        var f = document.getElementById("oaDelForm");
        f.elements["operation_id"].value = OPERATION_ID;
        f.elements["action_id"].value    = actionId;
        f.submit();
    }

    function onActionLinkSaved(ok, msg) {
        if (!ok) { alert(msg); return; }
        if (msg) alert(msg);
        loadActions();
    }

    /* --- mode=all: amallar reyestri (osm_r_actions) ------------------------------ */
    function acModal(param) {
        go({
            url: "osm_action.jsp",
            param: param,
            target: "modalE",
            dialogHeight: 340,
            dialogWidth: 620,
            lock: false,
            callback: function (r) { if (r) document.location.reload(); }
        });
    }

    function addAction() {
        acModal({});
    }

    function editAction() {
        if (!selectedActionId) { alert(SI_AC_NEED_SEL); return; }
        acModal({ action_id: selectedActionId });
    }

    function delAction() {
        if (!selectedActionId) { alert(SI_AC_NEED_SEL); return; }
        if (!confirm(SI_AC_CONFIRM_DEL)) return;
        var f = document.getElementById("acDelForm");
        f.elements["action_id"].value = selectedActionId;
        f.submit();
    }

    /* Ro'yxat server tomonda chizilgani uchun sahifa to'liq qayta yuklanadi */
    function onActionRegistrySaved(ok, msg) {
        if (!ok) { alert(msg); return; }
        if (msg) alert(msg);
        document.location.reload();
    }

    function onActionRowClick(e) {
        var tr = e.target;
        while (tr && tr.tagName !== "TR") tr = tr.parentNode;
        if (!tr || !tr.getAttribute("data-id")) return;

        var tb = document.getElementById("actTbody");
        for (var i = 0; i < tb.rows.length; i++) tb.rows[i].className = "";
        tr.className = "sel";

        selectedActionId = tr.getAttribute("data-id");
        resetTabCache();
        loadActiveTab();
    }
</script>
<%!
    static final int si_actions =
            SI("Действия", "Амаллар", "Amallar", "Actions");

    static final int si_action_name =
            SI("Наименование действия", "Амал номи", "Amal nomi", "Action name");

    static final int si_oa_add =
            SI("Привязать", "Бириктириш", "Biriktirish", "Attach");

    static final int si_oa_confirm_del =
            SI("Отвязать действие от операции?", "Амал операциядан узилсинми?",
               "Amal operatsiyadan uzilsinmi?", "Detach the action from the operation?");

    static final int si_ac_code =
            SI("Код", "Коди", "Kodi", "Code");

    static final int si_ac_add =
            SI("Добавить", "Кўшиш", "Qo'shish", "Add");

    static final int si_ac_edit =
            SI("Изменить", "Ўзгартириш", "O'zgartirish", "Edit");

    static final int si_ac_need_sel =
            SI("Выберите действие в списке", "Рўйхатдан амални танланг",
               "Ro'yxatdan amalni tanlang", "Select an action in the list");

    static final int si_ac_confirm_del =
            SI("Удалить действие?", "Амал учирилсинми?", "Amal o'chirilsinmi?", "Delete the action?");
%>
