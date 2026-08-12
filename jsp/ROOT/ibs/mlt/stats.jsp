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
%><t:form title="<%=si_title%>" minWidth="fill" minHeight="fill">

    <link rel="stylesheet" href="css/stats.css?v=<%= System.currentTimeMillis() %>">

    <script src="chart.umd.min.js"></script>

    <script>
        var g_statsData  = null;
        var g_lineChart  = null;
        var g_typesChart = null;

        function fmtNum(n) {
            return Number(n || 0).toLocaleString('en-US');
        }

        function paletteVar(name) {
            return getComputedStyle(document.querySelector('.stats-container')).getPropertyValue(name).trim();
        }

        // ---- Sana formati: mask="date" maydonlari "dd.mm.yyyy" ko'rinishida qiymat beradi (backend ham shuni kutadi) ----
        function fmtDate(d) {
            return ('0' + d.getDate()).slice(-2) + '.' +
                ('0' + (d.getMonth() + 1)).slice(-2) + '.' +
                d.getFullYear();
        }

        function defaultFilters() {
            var today = new Date();
            var from  = new Date(today); from.setDate(from.getDate() - 30);
            return { from_date: fmtDate(from), to_date: fmtDate(today), period_type: 'DAILY', user_id: '', error_id: '' };
        }


        var g_datePicker = null;
        var MONTH_NAMES  = ['Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun', 'Iyul', 'Avgust', 'Sentabr', 'Oktabr', 'Noyabr', 'Dekabr'];
        var DAY_NAMES    = ['Du', 'Se', 'Ch', 'Pa', 'Ju', 'Sh', 'Ya'];

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
            prev.type = 'button';
            prev.className = 'date-picker-nav';
            prev.textContent = '<';
            prev.onclick = function() {
                renderDatePicker(input, new Date(viewDate.getFullYear(), viewDate.getMonth() - 1, 1), selectedDate);
            };

            var label = document.createElement('span');
            label.className = 'date-picker-label';
            label.textContent = MONTH_NAMES[viewDate.getMonth()] + ' ' + viewDate.getFullYear();

            var next = document.createElement('button');
            next.type = 'button';
            next.className = 'date-picker-nav';
            next.textContent = '>';
            next.onclick = function() {
                renderDatePicker(input, new Date(viewDate.getFullYear(), viewDate.getMonth() + 1, 1), selectedDate);
            };

            header.appendChild(prev);
            header.appendChild(label);
            header.appendChild(next);
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
            var startDate    = new Date(firstOfMonth);
            startDate.setDate(startDate.getDate() - startOffset);
            var today = new Date();

            for (var i = 0; i < 42; i++) {
                var cellDate = new Date(startDate);
                cellDate.setDate(startDate.getDate() + i);

                var cell = document.createElement('div');
                cell.className = 'date-picker-day';
                if (cellDate.getMonth() !== viewDate.getMonth()) cell.className += ' other-month';
                if (sameDay(cellDate, today)) cell.className += ' today';
                if (selectedDate && sameDay(cellDate, selectedDate)) cell.className += ' selected';
                cell.textContent = cellDate.getDate();

                (function(value) {
                    cell.onclick = function() {
                        input.value = fmtDate(value);
                        closeDatePicker();
                    };
                })(cellDate);

                grid.appendChild(cell);
            }

            g_datePicker.appendChild(grid);
        }

        function openDatePicker(input) {
            closeDatePicker();

            var selected = parseDMY(input.value) || new Date();
            var viewDate = new Date(selected.getFullYear(), selected.getMonth(), 1);
            var holder = input.parentNode;

            g_datePicker = document.createElement('div');
            g_datePicker.className = 'date-picker-popup';
            holder.appendChild(g_datePicker);

            renderDatePicker(input, viewDate, selected);

            setTimeout(function() {
                document.addEventListener('mousedown', onDatePickerOutsideClick, true);
            }, 0);
        }
        function applyFilters(f) {
            document.getElementById('from_date').value   = f.from_date;
            document.getElementById('to_date').value     = f.to_date;
            document.getElementById('period_type').value = f.period_type;
            document.getElementById('user_id').value      = f.user_id;
            document.getElementById('error_id').value     = f.error_id;
        }

        // ---- Filtrlarni dastlabki holatga qaytarish ----
        function resetFilters() {
            applyFilters(defaultFilters());
            loadStats();
        }

        // ---- So'rov yuborish (POST, save patterniga mos) ----
        function loadStats() {
            document.getElementById('stats_from_date').value   = document.getElementById('from_date').value;
            document.getElementById('stats_to_date').value     = document.getElementById('to_date').value;
            document.getElementById('stats_period_type').value = document.getElementById('period_type').value;

            // "0" / bo'sh qiymatlarni filtr sifatida yubormaymiz - aks holda backend
            // "user_id = 0" yoki "error_id = 0" deb tor filtrlab, haqiqiy natijalarni yashiradi.
            var uid = document.getElementById('user_id').value;
            var eid = document.getElementById('error_id').value;
            document.getElementById('stats_user_id').value  = (uid && uid !== '0') ? uid : '';
            document.getElementById('stats_error_id').value = (eid && eid !== '0') ? eid : '';

            document.querySelector('.stats-container').classList.add('is-loading');
            document.getElementById('statsForm').submit();
        }

        // ---- Server javobi kelgandan keyin chaqiriladi ----
        function onStatsLoaded(data) {
            document.querySelector('.stats-container').classList.remove('is-loading');
            g_statsData = data || [];
            renderSummary(g_statsData);
            renderLineChart(g_statsData);
            renderTypesChart(g_statsData);
            renderTable(g_statsData);
        }

        // ---- Umumiy ko'rsatkichlar ----
        function renderSummary(data) {
            var total = 0, unique = {}, maxCount = 0, maxError = '-';
            var errCounts = {};

            data.forEach(function(r) {
                total += r.error_count || 0;
                if (r.message_code) unique[r.message_code] = true;
                if (!errCounts[r.message_code]) errCounts[r.message_code] = 0;
                errCounts[r.message_code] += r.error_count || 0;
            });

            Object.keys(errCounts).forEach(function(k) {
                if (errCounts[k] > maxCount) {
                    maxCount = errCounts[k];
                    maxError = k;
                }
            });

            var periods = {};
            data.forEach(function(r) { if (r.period_label) periods[r.period_label] = true; });

            document.getElementById('total_errors').textContent  = fmtNum(total);
            document.getElementById('unique_errors').textContent = fmtNum(Object.keys(unique).length);
            document.getElementById('total_periods').textContent = fmtNum(Object.keys(periods).length);
            document.getElementById('top_error').textContent     = maxError;
        }

        // ---- Chiziqli diagramma (vaqt bo'yicha) ----
        function renderLineChart(data) {
            var periodMap = {};
            data.forEach(function(r) {
                var lbl = r.period_label || '';
                if (!periodMap[lbl]) periodMap[lbl] = 0;
                periodMap[lbl] += r.error_count || 0;
            });

            var labels = Object.keys(periodMap).sort();
            var counts = labels.map(function(l) { return periodMap[l]; });

            var seriesColor = paletteVar('--series-1');
            var seriesWash  = paletteVar('--series-1-wash');
            var gridColor   = paletteVar('--grid');
            var axisColor   = paletteVar('--axis');
            var mutedColor  = paletteVar('--ink-muted');

            var ctx = document.getElementById('lineChart').getContext('2d');
            if (g_lineChart) g_lineChart.destroy();

            g_lineChart = new Chart(ctx, {
                type: 'line',
                data: {
                    labels: labels,
                    datasets: [{
                        label: '<%=lang.get(si_error_count)%>',
                        data: counts,
                        borderColor: seriesColor,
                        backgroundColor: seriesWash,
                        borderWidth: 2,
                        pointRadius: 4,
                        pointHoverRadius: 6,
                        pointBackgroundColor: seriesColor,
                        pointBorderColor: '#fff',
                        pointBorderWidth: 2,
                        tension: 0.3,
                        fill: true
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: { display: false },
                        tooltip: {
                            mode: 'index',
                            intersect: false,
                            backgroundColor: '#0b0b0b',
                            titleColor: '#ffffff',
                            bodyColor: '#ffffff',
                            borderColor: 'rgba(255,255,255,0.12)',
                            borderWidth: 1,
                            padding: 8,
                            displayColors: false,
                            callbacks: {
                                label: function(ctx) { return fmtNum(ctx.parsed.y); }
                            }
                        }
                    },
                    scales: {
                        x: {
                            grid: { color: gridColor, drawTicks: false },
                            border: { color: axisColor },
                            ticks: { font: { size: 11 }, color: mutedColor, maxRotation: 0, autoSkip: true }
                        },
                        y: {
                            beginAtZero: true,
                            grid: { color: gridColor },
                            border: { color: axisColor },
                            ticks: {
                                font: { size: 11 },
                                color: mutedColor,
                                precision: 0,
                                callback: function(v) { return fmtNum(v); }
                            }
                        }
                    }
                }
            });
        }
        
        function renderTypesChart(data) {
            var errMap = {};
            data.forEach(function(r) {
                var k = (r.message_code || 'UNKNOWN') + ' (' + (r.module_code || '') + ')';
                if (!errMap[k]) errMap[k] = 0;
                errMap[k] += r.error_count || 0;
            });

            var sorted = Object.keys(errMap)
                .map(function(k) { return { k: k, v: errMap[k] }; })
                .sort(function(a, b) { return b.v - a.v; });

            var top    = sorted.slice(0, 8);
            var others = sorted.slice(8).reduce(function(s, r) { return s + r.v; }, 0);
            if (others > 0) top.push({ k: '<%=lang.get(si_others)%>', v: others });
            top.reverse(); // eng kattasi tepada chiqishi uchun

            var seriesColor = paletteVar('--series-1');
            var gridColor   = paletteVar('--grid');
            var axisColor   = paletteVar('--axis');
            var mutedColor  = paletteVar('--ink-muted');

            var ctx = document.getElementById('typesChart').getContext('2d');
            if (g_typesChart) g_typesChart.destroy();

            g_typesChart = new Chart(ctx, {
                type: 'bar',
                data: {
                    labels: top.map(function(r) { return r.k; }),
                    datasets: [{
                        data: top.map(function(r) { return r.v; }),
                        backgroundColor: seriesColor,
                        borderRadius: 4,
                        borderSkipped: false,
                        maxBarThickness: 22,
                        categoryPercentage: 0.7
                    }]
                },
                options: {
                    indexAxis: 'y',
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: { display: false },
                        tooltip: {
                            mode: 'nearest',
                            intersect: true,
                            backgroundColor: '#0b0b0b',
                            titleColor: '#ffffff',
                            bodyColor: '#ffffff',
                            borderColor: 'rgba(255,255,255,0.12)',
                            borderWidth: 1,
                            padding: 8,
                            displayColors: false,
                            callbacks: {
                                label: function(ctx) { return fmtNum(ctx.parsed.x); }
                            }
                        }
                    },
                    scales: {
                        x: {
                            beginAtZero: true,
                            grid: { color: gridColor },
                            border: { color: axisColor },
                            ticks: { font: { size: 11 }, color: mutedColor, precision: 0, callback: function(v) { return fmtNum(v); } }
                        },
                        y: {
                            grid: { display: false },
                            border: { color: axisColor },
                            ticks: { font: { size: 11 }, color: mutedColor }
                        }
                    }
                }
            });
        }

        function makeCell(text, cls) {
            var td = document.createElement('td');
            if (cls) td.className = cls;
            td.textContent = text;
            return td;
        }

        // ---- Umumiy songa nisbatan rang: eng ko'p - qizil, o'rtacha - sariq, kam - yashil ----
        function countBadgeClass(count, maxCount) {
            var ratio = maxCount > 0 ? (count / maxCount) : 0;
            if (ratio >= 0.66) return 'badge-critical';
            if (ratio >= 0.33) return 'badge-warning';
            return 'badge-good';
        }

        function makeCountCell(count, maxCount) {
            var td = document.createElement('td');
            td.className = 'num';
            var badge = document.createElement('span');
            badge.className = 'count-badge ' + countBadgeClass(count, maxCount);
            badge.textContent = fmtNum(count);
            td.appendChild(badge);
            return td;
        }

        // ---- Jadval ----
        function renderTable(data) {
            var errMap = {};
            data.forEach(function(r) {
                var k = r.message_code || '';
                if (!errMap[k]) {
                    errMap[k] = {
                        module_code:  r.module_code  || '',
                        error_code:   r.error_code   || '',
                        message_code: r.message_code || '',
                        description:  r.description  || '',
                        count: 0
                    };
                }
                errMap[k].count += r.error_count || 0;
            });

            var rows  = Object.values(errMap).sort(function(a, b) { return b.count - a.count; });
            var tbody = document.getElementById('summaryTbody');
            while (tbody.firstChild) tbody.removeChild(tbody.firstChild);

            if (rows.length === 0) {
                var emptyRow  = document.createElement('tr');
                var emptyCell = makeCell('<%=lang.get(si_no_data).replace("'", "\\'")%>', 'no-data');
                emptyCell.colSpan = 5;
                emptyRow.appendChild(emptyCell);
                tbody.appendChild(emptyRow);
                return;
            }

            var maxCount = rows.reduce(function(m, r) { return Math.max(m, r.count); }, 0);

            rows.forEach(function(r, i) {
                var tr = document.createElement('tr');
                tr.appendChild(makeCell(String(i + 1)));
                tr.appendChild(makeCell(r.module_code));
                tr.appendChild(makeCell(String(r.error_code)));
                tr.appendChild(makeCell(r.message_code + ' ' + String.fromCharCode(0x2014) + ' ' + r.description));
                tr.appendChild(makeCountCell(r.count, maxCount));
                tbody.appendChild(tr);
            });
        }

        function onLoad() {
            applyFilters(defaultFilters());
            loadStats();
        }
    </script>

    <div class="stats-container">
            <%-- Filter paneli --%>
        <div class="stats-filters">
            <form name="fm">
                <div class="filter-field">
                    <label><%=lang.get(si_from_date)%></label>
                    <div class="date-input-wrap">
                        <input type="text" id="from_date" name="from_date" mask="date" placeholder="dd.mm.yyyy" class="form-control">
                        <button type="button" class="date-picker-btn" onclick="openDatePicker(document.getElementById('from_date'));">&#128197;</button>
                    </div>
                </div>
                <div class="filter-field">
                    <label><%=lang.get(si_to_date)%></label>
                    <div class="date-input-wrap">
                        <input type="text" id="to_date" name="to_date" mask="date" placeholder="dd.mm.yyyy" class="form-control">
                        <button type="button" class="date-picker-btn" onclick="openDatePicker(document.getElementById('to_date'));">&#128197;</button>
                    </div>
                </div>
                <div class="filter-field">
                    <label><%=lang.get(si_period_type)%></label>
                    <select id="period_type" name="period_type" class="form-control">
                        <option value="DAILY"><%=lang.get(si_daily)%></option>
                        <option value="WEEKLY"><%=lang.get(si_weekly)%></option>
                        <option value="MONTHLY"><%=lang.get(si_monthly)%></option>
                    </select>
                </div>
                <div class="filter-field">
                    <label><%=lang.get(si_user_id)%></label>
                    <select id="user_id" name="user_id" class="form-control">
                        <option value=""></option>
                        <%
                            PreparedStatement psUsers = null;
                            ResultSet rsUsers = null;
                            try {
                                psUsers = conn.prepareStatement(
                                        "select user_id, name from core.users_v order by name"
                                );
                                rsUsers = psUsers.executeQuery();
                                while (rsUsers.next()) {
                                    String userId = rsUsers.getString("user_id");
                                    String userName = rsUsers.getString("name");
                        %>
                        <option value="<%=userId%>"><%=userId%> - <%=userName%></option>
                        <%
                                }
                            } catch (Exception ex) {
                                Util.alertUserMessage(ex, out);
                            } finally {
                                if (rsUsers != null) try { rsUsers.close(); } catch (Exception ignore) {}
                                if (psUsers != null) try { psUsers.close(); } catch (Exception ignore) {}
                            }
                        %>
                    </select>
                </div>
                <div class="filter-field">
                    <label><%=lang.get(si_error_id)%></label>
                    <select id="error_id" name="error_id" class="form-control">
                        <option value=""></option>
                        <%
                            PreparedStatement psErrors = null;
                            ResultSet rsErrors = null;
                            try {
                                psErrors = conn.prepareStatement(
                                        "select error_id, message_code from core.errors_v order by message_code"
                                );
                                rsErrors = psErrors.executeQuery();
                                while (rsErrors.next()) {
                                    String errorId = rsErrors.getString("error_id");
                                    String messageCode = rsErrors.getString("message_code");
                        %>
                        <option value="<%=errorId%>"><%=messageCode%></option>
                        <%
                                }
                            } catch (Exception ex) {
                                Util.alertUserMessage(ex, out);
                            } finally {
                                if (rsErrors != null) try { rsErrors.close(); } catch (Exception ignore) {}
                                if (psErrors != null) try { psErrors.close(); } catch (Exception ignore) {}
                            }
                        %>
                    </select>
                </div>
            </form>
            <div class="btn-group">
                <input type="button" value="<%=lang.get(si_search)%>" onclick="loadStats();">
                <input type="button" class="secondary" value="<%=lang.get(si_reset)%>" onclick="resetFilters();">
            </div>
        </div>

            <%-- Umumiy ko'rsatkichlar --%>
        <div class="stats-total">
            <div class="stat-tile" style="--accent:#d03b3b">
                <div class="stat-label"><%=lang.get(si_total_errors)%></div>
                <div class="stat-value" id="total_errors">-</div>
            </div>
            <div class="stat-tile" style="--accent:#2a78d6">
                <div class="stat-label"><%=lang.get(si_unique_errors)%></div>
                <div class="stat-value" id="unique_errors">-</div>
            </div>
            <div class="stat-tile" style="--accent:#898781">
                <div class="stat-label"><%=lang.get(si_total_periods)%></div>
                <div class="stat-value" id="total_periods">-</div>
            </div>
            <div class="stat-tile" style="--accent:#fab219">
                <div class="stat-label"><%=lang.get(si_top_error)%></div>
                <div class="stat-value stat-value--small" id="top_error">-</div>
            </div>
        </div>

            <%-- Diagrammalar --%>
        <div class="chart-grid">
            <div class="chart-box">
                <h3><%=lang.get(si_chart_line)%></h3>
                <div class="chart-canvas"><canvas id="lineChart"></canvas></div>
            </div>
            <div class="chart-box">
                <h3><%=lang.get(si_chart_pie)%></h3>
                <div class="chart-canvas"><canvas id="typesChart"></canvas></div>
            </div>
        </div>

            <%-- Xato turlari jadvali --%>
        <div class="chart-box">
            <h3><%=lang.get(si_table_title)%></h3>
            <table class="summary-table">
                <thead>
                <tr>
                    <th>#</th>
                    <th><%=lang.get(si_module)%></th>
                    <th><%=lang.get(si_error_code)%></th>
                    <th><%=lang.get(si_message_code)%></th>
                    <th><%=lang.get(si_error_count)%></th>
                </tr>
                </thead>
                <tbody id="summaryTbody">
                <tr><td colspan="5" class="no-data"><%=lang.get(si_no_data)%></td></tr>
                </tbody>
            </table>
        </div>

    </div>

    <%-- Yashirin iframe: POST natijalari shu yerga keladi --%>
    <iframe name="statsFrame" style="display:none"></iframe>

    <%-- Yashirin POST forma: save patterniga mos, request=load_stats orqali t:request bloki ushlanadi --%>
    <form id="statsForm" method="post" action="stats.jsp" target="statsFrame" style="display:none">
        <input type="hidden" name="request" value="load_stats">
        <input type="hidden" name="process_code" value="GET_ERROR_STATS">
        <input type="hidden" id="stats_from_date"   name="from_date">
        <input type="hidden" id="stats_to_date"     name="to_date">
        <input type="hidden" id="stats_period_type" name="period_type">
        <input type="hidden" id="stats_user_id"     name="user_id">
        <input type="hidden" id="stats_error_id"    name="error_id">
    </form>

</t:form>
</t:page>

<t:requests>
    <t:request name="load_stats"><%
        try {
            String result = stored.execJsonRequestFunction("Core.Mlt_Api.Get_Model_Clob", request);
            // result = {"stats":[{...},{...},...]}
            // JS'ga uzatamiz
            out.print("<script>");
            out.print("try {");
            out.print("  var _raw = " + result + ";");
            out.print("  var _stats = (_raw && _raw.stats) ? _raw.stats : [];");
            out.print("  parent.onStatsLoaded(_stats);");
            out.print("} catch(e) { parent.onStatsLoaded([]); }");
            out.print("</script>");
        } catch (Exception ex) {
            out.print("<script>parent.onStatsLoaded([]);</script>");
            response.setHeader("RT", "alert");
            Util.alertUserMessage(ex, out);
        }
    %></t:request>
</t:requests>
<%!
    static final int si_title        = SI("Xato statistikasi", "Статистика ошибок", "Xato statistikasi", "Error Statistics");
    static final int si_from_date    = SI("Dan", "От", "Dan", "From");
    static final int si_to_date      = SI("Gacha", "До", "Gacha", "To");
    static final int si_period_type  = SI("Davr turi", "Тип периода", "Davr turi", "Period Type");
    static final int si_daily        = SI("Kunlik", "По дням", "Kunlik", "Daily");

    static final int si_weekly       = SI("Haftalik", "По неделям", "Haftalik", "Weekly");
    static final int si_monthly      = SI("Oylik", "По месяцам", "Oylik", "Monthly");
    static final int si_user_id      = SI("Foydalanuvchi ID", "ID пользователя", "Foydalanuvchi ID", "User ID");
    static final int si_error_id     = SI("Xato ID", "ID ошибки", "Xato ID", "Error ID");
    static final int si_search       = SI("Ko'rish", "Показать", "Ko'rish", "Search");
    static final int si_reset        = SI("Tozalash", "Очистить", "Tozalash", "Reset");
    static final int si_total_errors = SI("Jami xatolar", "Всего ошибок", "Jami xatolar", "Total Errors");
    static final int si_unique_errors= SI("Turli xato turlari", "Уникальные ошибки", "Turli xato turlari", "Unique Errors");
    static final int si_total_periods= SI("Davrlar soni", "Количество периодов", "Davrlar soni", "Periods");
    static final int si_top_error    = SI("Eng ko'p xato", "Частая ошибка", "Eng ko'p xato", "Top Error");
    static final int si_chart_line   = SI("Vaqt bo'yicha xatolar", "Ошибки по времени", "Vaqt bo'yicha xatolar", "Errors by Period");
    static final int si_chart_pie    = SI("Xato turlari", "Типы ошибок", "Xato turlari", "Error Types");
    static final int si_table_title  = SI("Xato turlari jadvali", "Таблица типов ошибок", "Xato turlari jadvali", "Error Summary");
    static final int si_module       = SI("Modul", "Модуль", "Modul", "Module");
    static final int si_error_code   = SI("Xato kodi", "Код ошибки", "Xato kodi", "Error Code");
    static final int si_message_code = SI("Xabar kodi", "Код сообщения", "Xabar kodi", "Message Code");
    static final int si_error_count  = SI("Soni", "Количество", "Soni", "Count");
    static final int si_no_data      = SI("Ma'lumot yo'q", "Нет данных", "Ma'lumot yo'q", "No data");
    static final int si_others       = SI("Boshqalar", "Другие", "Boshqalar", "Others");
%>
<%@ include file="/language.jsp" %>









