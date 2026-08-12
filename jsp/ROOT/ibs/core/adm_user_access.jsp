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
//-------------------------------------------------------------------------------------------------
%><t:page><%
    String user_id = request.getParameter("user_id");

    try {
        ServletCallableStatement cs = new ServletCallableStatement(stored, request);
        cs.setProcedure("User_Session.Put_Number");
        cs.setString("i_Key", "adm_user_access_id");
        cs.setString("i_Value", user_id);
        cs.execute();
    } catch (Exception ex) {
        Util.alertUserMessage(ex, out);
    }

    try {
        StringBuilder sb = new StringBuilder("[");
        boolean first = true;
        PreparedStatement ps = conn.prepareStatement(
            "SELECT id, parent_id, name, is_checked, type, raw_id, raw_menu_id, " +
            "TO_CHAR(date_activate,'YYYY-MM-DD') AS date_activate, " +
            "TO_CHAR(date_deactivate,'YYYY-MM-DD') AS date_deactivate " +
            "FROM ADM_USER_ACCESS_V ORDER BY order_by"
        );
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            if (!first) sb.append(",");
            sb.append("{");
            sb.append("\"ID\":\"").append(rs.getString("id")).append("\",");
            sb.append("\"PARENT_ID\":\"").append(rs.getString("parent_id")).append("\",");
            sb.append("\"NAME\":\"").append(rs.getString("name") != null ? rs.getString("name").replace("\"", "\\\"") : "").append("\",");
            sb.append("\"IS_CHECKED\":\"").append(rs.getString("is_checked")).append("\",");
            sb.append("\"TYPE\":\"").append(rs.getString("type")).append("\",");
            sb.append("\"RAW_ID\":").append(rs.getString("raw_id") != null ? rs.getString("raw_id") : "null").append(",");
            sb.append("\"RAW_MENU_ID\":").append(rs.getString("raw_menu_id") != null ? rs.getString("raw_menu_id") : "null").append(",");
            sb.append("\"DATE_ACTIVATE\":\"").append(rs.getString("date_activate") != null ? rs.getString("date_activate") : "").append("\",");
            sb.append("\"DATE_DEACTIVATE\":\"").append(rs.getString("date_deactivate") != null ? rs.getString("date_deactivate") : "").append("\"");
            sb.append("}");
            first = false;
        }
        sb.append("]");
        rs.close();
        ps.close();
        out.println("<script>var modulesData=" + sb.toString() + ";</script>");
    } catch (Exception ex) {
        out.println("<script>var modulesData=[];</script>");
        Util.alertUserMessage(ex, out);
    }
%>
<t:form title="<%=si_title%>" minWidth="fill" minHeight="fill">

<script>
// ---------- Tarjimalar (backenddan Language orqali dinamik keladi) ----------
var I18N = {
    periodTitle:  "<%=lang.get(si_period_title)%>",
    resetLabel:   "<%=lang.get(si_reset_label)%>",
    accessFrom:   "<%=lang.get(si_access_from)%>",
    accessTo:     "<%=lang.get(si_access_to)%>",
    periodNote:   "<%=lang.get(si_period_note)%>",
    buttonsLabel: "<%=lang.get(si_buttons_label)%>",
    untilTpl:     "<%=lang.get(si_until_template)%>",
    loading:      "<%=lang.get(si_loading)%>"
};

function untilText(dateStr) {
    return I18N.untilTpl.replace('%s', dateStr);
}

// ---------- Sana yordamchilari ----------
function pad2(n) { return (n < 10 ? '0' : '') + n; }
function toISO(d) { return d.getFullYear() + '-' + pad2(d.getMonth() + 1) + '-' + pad2(d.getDate()); }
function defaultFrom() { return toISO(new Date()); }
function defaultTo() {
    var d = new Date();
    d.setFullYear(d.getFullYear() + 10);
    return toISO(d);
}
function isoToDisplay(iso) {
    if (!iso) return '';
    var p = iso.split('-');
    if (p.length !== 3) return iso;
    return p[2] + '.' + p[1] + '.' + p[0];
}
function getDateValue(id) {
    var el = document.getElementById(id);
    return el ? el.value : null;
}
function resetDates(fromId, toId, summaryId) {
    document.getElementById(fromId).value = defaultFrom();
    document.getElementById(toId).value = defaultTo();
    if (summaryId) {
        var s = document.getElementById(summaryId);
        if (s) s.textContent = untilText(isoToDisplay(defaultTo()));
    }
}

// ---------- Daraxt qurish ----------
function isLeafMenu(m) {
    if (m.TYPE != 'MENU') return false;
    return !modulesData.some(function(x) { return x.PARENT_ID == m.ID && x.TYPE == 'MENU'; });
}

function buildTree(parentId, level) {
    var children = modulesData.filter(function(m) {
        return m.PARENT_ID == parentId && m.TYPE != 'BUTTON';
    });
    if (children.length == 0) return '';

    var html = '';
    children.forEach(function(m) {
        var isMenu   = m.TYPE == 'MENU';
        var isModule = m.TYPE == 'MODULE';
        var leaf = isLeafMenu(m);
        var checked = (m.IS_CHECKED == '1');

        var childMenus   = modulesData.filter(function(x) { return x.PARENT_ID == m.ID && x.TYPE == 'MENU'; });
        var childButtons = modulesData.filter(function(x) { return x.PARENT_ID == m.ID && x.TYPE == 'BUTTON'; });

        var hasChildren;
        if (isModule) {
            hasChildren = modulesData.some(function(x) { return x.PARENT_ID == m.ID; });
        } else if (leaf) {
            hasChildren = true;
        } else {
            hasChildren = childMenus.length > 0;
        }

        var totalChildren = 0, checkedChildren = 0;
        if (hasChildren && !leaf) {
            modulesData.forEach(function(x) {
                if (x.PARENT_ID == m.ID && x.TYPE != 'BUTTON') {
                    totalChildren++;
                    if (x.IS_CHECKED == '1') checkedChildren++;
                }
            });
        }

        var rowClass = 'row';
        if (isModule && level == 0) rowClass += ' row-module';
        else if (isModule)          rowClass += ' row-sub';
        else                        rowClass += ' row-menu';

        html += '<div class="tree-node" id="node_' + m.ID + '">';
        html += '<div class="' + rowClass + '"';
        if (hasChildren) html += ' onclick="toggleNode(\'' + m.ID + '\')"';
        html += ' style="padding-left:' + (level * 22 + 12) + 'px">';

        html += '<input type="checkbox" value="' + m.TYPE + ':' + m.ID + '"';
        html += ' id="chk_' + m.ID + '"';
        html += ' data-own="' + (checked ? '1' : '0') + '"';
        html += ' onclick="event.stopPropagation();onCheck(\'' + m.ID + '\',\'' + (m.PARENT_ID || '0') + '\',\'' + m.TYPE + '\')"';
        if (checked) html += ' checked';
        html += '>';

        html += '<span class="row-name ' + (isModule && level == 0 ? 'name-module' : (isModule ? 'name-sub' : 'name-menu')) + '">';
        html += m.NAME;
        html += '</span>';

        if (leaf) {
            var toVal = m.DATE_DEACTIVATE || defaultTo();
            html += '<span class="row-summary" id="summary_' + m.ID + '" style="display:' + (checked ? 'inline' : 'none') + '">' + untilText(isoToDisplay(toVal)) + '</span>';
        } else if (hasChildren) {
            html += '<span class="row-counter" id="counter_' + m.ID + '">' + checkedChildren + '/' + totalChildren + '</span>';
        }

        if (hasChildren) {
            html += '<span class="row-toggle" id="icon_' + m.ID + '">&#8250;</span>';
        }

        html += '</div>';

        if (hasChildren) {
            html += '<div id="children_' + m.ID + '" style="display:none">';
            if (leaf) {
                html += renderLeafPanel(m, level);
            } else {
                html += buildTree(m.ID, level + 1);
            }
            html += '</div>';
        }

        html += '</div>';
    });
    return html;
}

// ---------- Leaf-menu paneli ----------
function renderLeafPanel(menuNode, level) {
    var mid = menuNode.ID;
    var checked = (menuNode.IS_CHECKED == '1');
    var fromVal = menuNode.DATE_ACTIVATE || defaultFrom();
    var toVal   = menuNode.DATE_DEACTIVATE || defaultTo();
    var indent = (level + 1) * 22 + 12;

    var html = '<div class="leaf-panel">';

    html += '<div class="period-box" id="period_' + mid + '" style="display:' + (checked ? 'block' : 'none') + '; margin-left:' + indent + 'px">';
    html += '<div class="period-header">';
    html += '<span class="period-title">' + I18N.periodTitle + '</span>';
    html += '<span class="period-reset" onclick="resetMenuDates(\'' + mid + '\')" title="' + I18N.resetLabel + '">&#8635; ' + I18N.resetLabel + '</span>';
    html += '</div>';
    html += '<div class="period-fields">';
    html += '<div class="period-field"><label>' + I18N.accessFrom + '</label><input type="date" id="date_from_' + mid + '" value="' + fromVal + '" max="' + toVal + '" onchange="onOwnDateChanged(\'' + mid + '\')"></div>';
    html += '<span class="period-dash">&mdash;</span>';
    html += '<div class="period-field"><label>' + I18N.accessTo + '</label><input type="date" id="date_to_' + mid + '" value="' + toVal + '" min="' + fromVal + '" onchange="onOwnDateChanged(\'' + mid + '\')"></div>';
    html += '</div>';
    html += '<div class="period-note">' + I18N.periodNote + '</div>';
    html += '</div>';

    var buttons = modulesData.filter(function(x) { return x.PARENT_ID == mid && x.TYPE == 'BUTTON'; });
    if (buttons.length > 0) {
        html += '<div class="section-label" style="margin-left:' + indent + 'px">' + I18N.buttonsLabel + '</div>';
        html += '<div class="buttons-list">';
        buttons.forEach(function(b) { html += renderButtonRow(b, level + 1, fromVal, toVal); });
        html += '</div>';
    }

    html += '</div>';
    return html;
}

// ---------- Button qatori (parentFrom/parentTo - min/max cheklovi uchun) ----------
function renderButtonRow(b, level, parentFrom, parentTo) {
    var childButtons = modulesData.filter(function(x) { return x.PARENT_ID == b.ID && x.TYPE == 'BUTTON'; });
    var hasChildren = childButtons.length > 0;
    var checked = (b.IS_CHECKED == '1');
    var fromVal = clampToRange(b.DATE_ACTIVATE || parentFrom || defaultFrom(), parentFrom, parentTo);
    var toVal   = clampToRange(b.DATE_DEACTIVATE || parentTo || defaultTo(), parentFrom, parentTo);
    var indent = level * 22 + 12;

    var html = '<div class="tree-node" id="node_' + b.ID + '">';
    html += '<div class="row row-button"';
    if (hasChildren) html += ' onclick="toggleNode(\'' + b.ID + '\')"';
    html += ' style="padding-left:' + indent + 'px">';

    html += '<input type="checkbox" value="BUTTON:' + b.ID + '"';
    html += ' id="chk_' + b.ID + '"';
    html += ' data-own="' + (checked ? '1' : '0') + '"';
    html += ' onclick="event.stopPropagation();onButtonCheck(\'' + b.ID + '\',\'' + (b.PARENT_ID || '0') + '\')"';
    if (checked) html += ' checked';
    html += '>';

    html += '<span class="row-name name-button">' + b.NAME + '</span>';
    html += '<span class="button-dates" id="dates_' + b.ID + '" style="display:' + (checked ? 'flex' : 'none') + '">';
    html += '<input type="date" id="date_from_' + b.ID + '" value="' + fromVal + '"';
    if (parentFrom) html += ' min="' + parentFrom + '"';
    html += ' max="' + toVal + '" onclick="event.stopPropagation()" onchange="onOwnDateChanged(\'' + b.ID + '\')">';
    html += '<span class="period-dash-sm">&mdash;</span>';
    html += '<input type="date" id="date_to_' + b.ID + '" value="' + toVal + '" min="' + fromVal + '"';
    if (parentTo) html += ' max="' + parentTo + '"';
    html += ' onclick="event.stopPropagation()" onchange="onOwnDateChanged(\'' + b.ID + '\')">';
    html += '<span class="period-reset-sm" onclick="event.stopPropagation();resetButtonDates(\'' + b.ID + '\',\'' + (parentFrom||'') + '\',\'' + (parentTo||'') + '\')" title="' + I18N.resetLabel + '">&#8635;</span>';
    html += '</span>';

    if (hasChildren) {
        html += '<span class="row-toggle" id="icon_' + b.ID + '">&#8250;</span>';
    }

    html += '</div>';

    if (hasChildren) {
        html += '<div class="child-buttons-wrap" id="children_' + b.ID + '" style="display:none">';
        childButtons.forEach(function(cb) { html += renderButtonRow(cb, level + 1, fromVal, toVal); });
        html += '</div>';
    }

    html += '</div>';
    return html;
}

// ---------- Sana chegaralarini avtomatik moslash ----------
function clampToRange(iso, minIso, maxIso) {
    if (!iso) return iso;
    if (minIso && iso < minIso) return minIso;
    if (maxIso && iso > maxIso) return maxIso;
    return iso;
}

function onOwnDateChanged(id) {
    var fromVal = getDateValue('date_from_' + id);
    var toVal   = getDateValue('date_to_' + id);

    var toInput = document.getElementById('date_to_' + id);
    var fromInput = document.getElementById('date_from_' + id);
    if (toInput) toInput.min = fromVal;
    if (fromInput) fromInput.max = toVal;

    var summaryEl = document.getElementById('summary_' + id);
    if (summaryEl) summaryEl.textContent = untilText(isoToDisplay(toVal));

    propagateDateConstraints(id, fromVal, toVal);
}

function propagateDateConstraints(id, parentFrom, parentTo) {
    var children = modulesData.filter(function(x) { return x.PARENT_ID == id && x.TYPE == 'BUTTON'; });
    children.forEach(function(c) {
        var cFromInput = document.getElementById('date_from_' + c.ID);
        var cToInput   = document.getElementById('date_to_' + c.ID);
        if (!cFromInput || !cToInput) return;

        cFromInput.min = parentFrom;
        cToInput.max   = parentTo;

        var newFrom = clampToRange(cFromInput.value, parentFrom, parentTo);
        var newTo   = clampToRange(cToInput.value, parentFrom, parentTo);
        if (newFrom > newTo) newFrom = newTo;

        cFromInput.value = newFrom;
        cToInput.value   = newTo;
        cFromInput.max = newTo;
        cToInput.min   = newFrom;

        propagateDateConstraints(c.ID, newFrom, newTo);
    });
}

function resetMenuDates(mid) {
    var f = defaultFrom(), t = defaultTo();
    document.getElementById('date_from_' + mid).value = f;
    document.getElementById('date_to_' + mid).value = t;
    document.getElementById('date_from_' + mid).max = t;
    document.getElementById('date_to_' + mid).min = f;
    var s = document.getElementById('summary_' + mid);
    if (s) s.textContent = untilText(isoToDisplay(t));
    propagateDateConstraints(mid, f, t);
}

function resetButtonDates(bid, parentFrom, parentTo) {
    var f = parentFrom || defaultFrom();
    var t = parentTo || defaultTo();
    document.getElementById('date_from_' + bid).value = f;
    document.getElementById('date_to_' + bid).value = t;
    document.getElementById('date_from_' + bid).max = t;
    document.getElementById('date_to_' + bid).min = f;
    propagateDateConstraints(bid, f, t);
}

function toggleNode(id) {
    var children = document.getElementById('children_' + id);
    var icon = document.getElementById('icon_' + id);
    if (!children) return;
    if (children.style.display == 'none') {
        children.style.display = 'block';
        if (icon) icon.innerHTML = '&#8964;';
    } else {
        children.style.display = 'none';
        if (icon) icon.innerHTML = '&#8250;';
    }
}

function uncheckAllDescendants(id) {
    var childrenDiv = document.getElementById('children_' + id);
    if (!childrenDiv) return;
    var boxes = childrenDiv.querySelectorAll('input[type=checkbox]');
    boxes.forEach(function(cb) {
        cb.checked = false;
        cb.dataset.own = '0';
        var cid = cb.id.replace('chk_', '');
        var datesEl = document.getElementById('dates_' + cid);
        if (datesEl) datesEl.style.display = 'none';
        var periodEl = document.getElementById('period_' + cid);
        if (periodEl) periodEl.style.display = 'none';
        var summaryEl = document.getElementById('summary_' + cid);
        if (summaryEl) summaryEl.style.display = 'none';
    });
}

function onCheck(id, parentId, type) {
    var chk = document.getElementById('chk_' + id);
    var checked = chk.checked;

    chk.dataset.own = checked ? '1' : '0';

    if (type == 'MODULE') {
        checkAllChildren(id, checked);
    }

    if (type == 'MENU') {
        var periodEl = document.getElementById('period_' + id);
        if (periodEl) periodEl.style.display = checked ? 'block' : 'none';
        var summaryEl = document.getElementById('summary_' + id);
        if (summaryEl) summaryEl.style.display = checked ? 'inline' : 'none';

        if (checked) {
            var f = getDateValue('date_from_' + id), t = getDateValue('date_to_' + id);
            propagateDateConstraints(id, f, t);
        } else {
            uncheckAllDescendants(id);
        }
    }

    updateParent(parentId);
    updateCounter(parentId);
}

function onButtonCheck(id, parentId) {
    var chk = document.getElementById('chk_' + id);
    var checked = chk.checked;
    chk.dataset.own = checked ? '1' : '0';

    var datesEl = document.getElementById('dates_' + id);
    if (datesEl) datesEl.style.display = checked ? 'flex' : 'none';

    if (checked) {
        forceAncestorsChecked(parentId);
        var f = getDateValue('date_from_' + id), t = getDateValue('date_to_' + id);
        propagateDateConstraints(id, f, t);
    } else {
        uncheckAllDescendants(id);
    }

    updateParent(parentId);
    updateCounter(parentId);
}

function forceAncestorsChecked(parentId) {
    while (parentId && parentId != '0') {
        var pNode = modulesData.find(function(m) { return m.ID == parentId; });
        if (!pNode || pNode.TYPE == 'MODULE') break;
        var pChk = document.getElementById('chk_' + parentId);
        if (pChk) {
            pChk.dataset.own = '1';
            pChk.checked = true;
            pChk.indeterminate = false;

            if (pNode.TYPE == 'MENU') {
                var periodEl = document.getElementById('period_' + parentId);
                if (periodEl) periodEl.style.display = 'block';
                var summaryEl = document.getElementById('summary_' + parentId);
                if (summaryEl) summaryEl.style.display = 'inline';
            } else if (pNode.TYPE == 'BUTTON') {
                var datesEl = document.getElementById('dates_' + parentId);
                if (datesEl) datesEl.style.display = 'flex';
            }
        }
        parentId = pNode.PARENT_ID;
    }
}

function checkAllChildren(id, checked) {
    var children = document.getElementById('children_' + id);
    if (!children) return;
    var boxes = children.querySelectorAll('input[type=checkbox]');
    boxes.forEach(function(cb) {
        if (cb.value.indexOf('BUTTON:') !== 0) {
            cb.checked = checked;
            cb.dataset.own = checked ? '1' : '0';
        }
    });
}

function updateCounter(parentId) {
    if (!parentId || parentId == '0') return;
    var counter = document.getElementById('counter_' + parentId);
    if (!counter) return;
    var childrenDiv = document.getElementById('children_' + parentId);
    if (!childrenDiv) return;
    var directRows = childrenDiv.querySelectorAll(':scope > .tree-node > div > input[type=checkbox]');
    var total = directRows.length, checked = 0;
    directRows.forEach(function(cb) { if (cb.checked) checked++; });
    counter.innerHTML = checked + '/' + total;

    var parentNode = modulesData.find(function(m) { return m.ID == parentId; });
    if (parentNode) updateCounter(parentNode.PARENT_ID);
}

function updateParent(parentId) {
    if (!parentId || parentId == '0') return;
    var parentChk = document.getElementById('chk_' + parentId);
    if (!parentChk) return;
    var childrenDiv = document.getElementById('children_' + parentId);
    if (!childrenDiv) return;
    var boxes = childrenDiv.querySelectorAll('input[type=checkbox]');
    var anyChecked = false, allChecked = true;
    boxes.forEach(function(cb) {
        if (cb.checked) anyChecked = true;
        else allChecked = false;
    });

    var parentNode = modulesData.find(function(m) { return m.ID == parentId; });
    var isModuleType = parentNode && parentNode.TYPE == 'MODULE';

    if (isModuleType) {
        parentChk.checked = anyChecked;
        parentChk.indeterminate = anyChecked && !allChecked;
    } else {
        var ownChecked = parentChk.dataset.own == '1';
        parentChk.checked = ownChecked;
        parentChk.indeterminate = !ownChecked && anyChecked;
    }

    if (parentNode) updateParent(parentNode.PARENT_ID);
}

function buildSavePayload() {
    var menus = [];
    var menuByRawId = {};
    var buttonsByMenu = {};

    modulesData.forEach(function(m) {
        if (m.TYPE == 'MODULE') return;

        var chk = document.getElementById('chk_' + m.ID);
        if (!chk) return;

        var wasChecked = (m.IS_CHECKED == '1');
        var isChecked  = chk.checked;

        if (m.TYPE == 'MENU') {
            var hasDateUI = document.getElementById('date_from_' + m.ID) != null;

            var action = null;
            var newFrom = null, newTo = null;

            if (!wasChecked && isChecked) {
                action = 'ADD';
                newFrom = hasDateUI ? getDateValue('date_from_' + m.ID) : defaultFrom();
                newTo   = hasDateUI ? getDateValue('date_to_' + m.ID)   : defaultTo();
            } else if (wasChecked && !isChecked) {
                action = 'DELETE';
            } else if (wasChecked && isChecked && hasDateUI) {
                var curFrom = getDateValue('date_from_' + m.ID);
                var curTo   = getDateValue('date_to_' + m.ID);
                var origFrom = m.DATE_ACTIVATE || null;
                var origTo   = m.DATE_DEACTIVATE || null;
                if (curFrom !== origFrom || curTo !== origTo) {
                    action = 'EDIT';
                    newFrom = curFrom;
                    newTo   = curTo;
                }
            }

            if (action === null) return;

            var menuObj = { menu_id: m.RAW_ID, action: action, buttons: [] };
            if (action == 'ADD' || action == 'EDIT') {
                menuObj.date_activate   = newFrom;
                menuObj.date_deactivate = newTo;
            }
            menus.push(menuObj);
            menuByRawId[m.RAW_ID] = menuObj;

        } else if (m.TYPE == 'BUTTON') {
            var action = null;
            var newFrom = null, newTo = null;

            if (!wasChecked && isChecked) {
                action = 'ADD';
                newFrom = getDateValue('date_from_' + m.ID);
                newTo   = getDateValue('date_to_' + m.ID);
            } else if (wasChecked && !isChecked) {
                action = 'DELETE';
            } else if (wasChecked && isChecked) {
                var curFrom = getDateValue('date_from_' + m.ID);
                var curTo   = getDateValue('date_to_' + m.ID);
                var origFrom = m.DATE_ACTIVATE || null;
                var origTo   = m.DATE_DEACTIVATE || null;
                if (curFrom !== origFrom || curTo !== origTo) {
                    action = 'EDIT';
                    newFrom = curFrom;
                    newTo   = curTo;
                }
            }

            if (action === null) return;

            var key = m.RAW_MENU_ID;
            if (!buttonsByMenu[key]) buttonsByMenu[key] = [];
            var btnObj = { button_id: m.RAW_ID, action: action };
            if (action == 'ADD' || action == 'EDIT') {
                btnObj.date_activate   = newFrom;
                btnObj.date_deactivate = newTo;
            }
            buttonsByMenu[key].push(btnObj);
        }
    });

    Object.keys(buttonsByMenu).forEach(function(menuId) {
        var key = Number(menuId);
        if (menuByRawId[key]) {
            menuByRawId[key].buttons = buttonsByMenu[key];
        } else {
            menus.push({ menu_id: key, action: null, buttons: buttonsByMenu[key] });
        }
    });

    return {
        user_id: Number(document.querySelector('input[name=user_id]').value),
        menus: menus
    };
}

function doSave() {
    var payload = buildSavePayload();
    document.getElementById('menusJson').value = JSON.stringify({ menus: payload.menus });
    go({
        form: document.getElementById('moduleForm'),
        param: {action: 1}
    });
}

window.onload = function() {
    document.getElementById('moduleTree').innerHTML = buildTree('0', 0);

    modulesData.forEach(function(m) {
        if (m.IS_CHECKED == '1' && m.PARENT_ID != '0') {
            var ch = document.getElementById('children_' + m.PARENT_ID);
            var ic = document.getElementById('icon_' + m.PARENT_ID);
            if (ch) ch.style.display = 'block';
            if (ic) ic.innerHTML = '&#8964;';
        }
    });

    modulesData.forEach(function(m) {
        updateParent(m.PARENT_ID);
    });

    modulesData.forEach(function(m) {
        updateCounter(m.PARENT_ID);
    });
};
</script>

<style>
* { box-sizing: border-box; }

.row {
    display: flex;
    align-items: center;
    padding: 9px 12px 9px 0;
    border-bottom: 1px solid #eee;
    cursor: pointer;
}
.row:hover { background: #f7f7f8; }

.row-button { border-bottom: 1px solid #f0f0f0; }
.row-button:hover { background: #f7f7f8; }

input[type=checkbox] {
    cursor: pointer;
    width: 16px;
    height: 16px;
    flex-shrink: 0;
    margin-right: 10px;
    accent-color: #2f6fed;
}

.row-name { flex: 1; user-select: none; color: #222; }
.name-module { font-size: 14px; font-weight: 600; }
.name-sub    { font-size: 13px; font-weight: 500; color: #333; }
.name-menu   { font-size: 13px; font-weight: 500; color: #333; }
.name-button { font-size: 12.5px; font-weight: 400; color: #555; }

.row-counter {
    font-size: 12px;
    color: #9aa0a6;
    margin-right: 8px;
}

.row-summary {
    font-size: 12px;
    color: #9aa0a6;
    margin-right: 8px;
    white-space: nowrap;
}

.row-toggle {
    font-size: 16px;
    color: #b0b3b8;
    padding: 0 2px;
}

.leaf-panel {
    background: #f7f8fa;
    padding: 4px 12px 10px 0;
}

.period-box { padding: 10px 0 10px 0; }

.period-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 8px;
}
.period-title {
    font-size: 11px;
    font-weight: 600;
    color: #9aa0a6;
    letter-spacing: .04em;
    text-transform: uppercase;
}
.period-reset {
    font-size: 11.5px;
    color: #9aa0a6;
    cursor: pointer;
    user-select: none;
}
.period-reset:hover { color: #2f6fed; }

.period-fields { display: flex; align-items: flex-end; gap: 10px; }
.period-field label { font-size: 12px; color: #888; display: block; margin-bottom: 3px; }
.period-field input[type=date] {
    padding: 5px 8px;
    border: 1px solid #e0e1e5;
    border-radius: 5px;
    font-size: 13px;
    width: 150px;
    background: #fff;
}
.period-dash { color: #c2c4c8; margin-bottom: 7px; }
.period-note { font-size: 11.5px; color: #aaacb0; margin-top: 8px; }

.section-label {
    font-size: 11px;
    font-weight: 600;
    color: #9aa0a6;
    letter-spacing: .03em;
    text-transform: uppercase;
    margin: 4px 0 2px;
}

.button-dates { display: flex; align-items: center; gap: 6px; margin-left: auto; }
.button-dates input[type=date] {
    padding: 4px 7px;
    border: 1px solid #e0e1e5;
    border-radius: 5px;
    font-size: 12.5px;
    width: 130px;
    background: #fff;
}
.period-dash-sm { color: #c2c4c8; }
.period-reset-sm { color: #b0b3b8; cursor: pointer; font-size: 14px; margin-left: 2px; }
.period-reset-sm:hover { color: #2f6fed; }
</style>

<table class="formToolbar">
    <tr>
        <td>
            <input type="button" value="<%=lang.get(si_save)%>" onclick="doSave()">
        </td>
        <td id="tableControls" align="right">
            <input type="button" value="<%=lang.get(si_exit)%>" onclick="top.close()">
        </td>
    </tr>
</table>

<form id="moduleForm" name="moduleForm" method="post">
    <input type="hidden" name="request" value="save">
    <input type="hidden" name="user_id" value="<%=user_id%>">
    <input type="hidden" id="menusJson" name="menus" value="">
    <div id="moduleTree"><%=lang.get(si_loading)%></div>
</form>

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
    static final int si_title = SI("Назначение модулей", "Модулларни бириктириш", "Modullarni biriktirish", "Assign Modules", "", "");
    static final int si_save = SI("Сохранить", "Са?лаш", "Saqlash", "Save", "", "");
    static final int si_exit = SI("Закрыть", "Ёпиш", "Yopish", "Exit", "", "");
    static final int si_success = SI("Успешно выполнено!", "Муваффа?иятли бажарилди!", "Muvaffaqiyatli bajarildi!", "Successfully executed!", "", "");

    static final int si_period_title = SI("ПЕРИОД ДОСТУПА К МЕНЮ", "МЕНЮГА КИРИШ ДАВРИ", "MENYUGA KIRISH DAVRI", "MENU ACCESS PERIOD", "", "");
    static final int si_reset_label = SI("10 лет", "10 йил", "10 yil", "10 years", "", "");
    static final int si_access_from = SI("Доступ с", "Кириш бошланиши", "Kirish boshlanishi", "Access from", "", "");
    static final int si_access_to = SI("Доступ по", "Кириш тугаши", "Kirish tugashi", "Access to", "", "");
    static final int si_period_note = SI("По умолчанию доступ выдаётся на 10 лет. Можно указать другой период.", "Одатда 10 йиллик давр берилади, бош?а муддат киритиш мумкин.", "Odatda 10 yillik davr beriladi, boshqa muddat kiritish mumkin.", "By default access is granted for 10 years. You can specify a different period.", "", "");
    static final int si_buttons_label = SI("КНОПКИ — страницы и действия, период по каждой", "ТУГМАЛАР — са?ифалар ва амаллар, ?ар бирига ало?ида давр", "TUGMALAR — sahifalar va amallar, har biriga alohida davr", "BUTTONS — pages and actions, period for each", "", "");
    static final int si_until_template = SI("до %s", "%s гача", "%s gacha", "until %s", "", "");
    static final int si_loading = SI("Загрузка...", "Юкланмо?да...", "Yuklanmoqda...", "Loading...", "", "");
%>
<%@ include file="/language.jsp" %>