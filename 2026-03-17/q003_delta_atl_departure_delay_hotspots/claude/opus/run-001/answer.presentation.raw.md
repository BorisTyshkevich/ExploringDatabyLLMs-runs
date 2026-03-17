Now I have the design system and patterns. Let me create the report template and the visual.html dashboard.

```report
# {{question_title}}

**Generated:** {{generated_at}}  
**Rows returned:** {{row_count}}

## Data Overview

{{data_overview_md}}

## Analysis

This analysis identifies departure delay hotspots for Delta (DL) flights leaving Atlanta Hartsfield-Jackson (ATL). Each hotspot is a destination–time block pair that qualifies for analysis based on flight volume thresholds.

### Key Observations

- **Worst Hotspot:** The destination and time block with the highest average departure delay represents the most persistent pressure point in Delta's ATL departure network.
- **Hotspot Persistence:** Compare `FirstQualifyingMonth` and `LastQualifyingMonth` to assess whether the hotspot is a chronic issue or concentrated in a narrower period.
- **Top 5 Pattern:** The top five hotspot cells reveal whether ATL departure pressure clusters in specific time blocks (e.g., evening departures) or specific destinations (e.g., high-volume domestic hubs).

### Interpreting the Results

| Column | Meaning |
|--------|---------|
| `Dest` | Destination airport code |
| `DepTimeBlk` | Departure time block (e.g., 0600-0659) |
| `AvgDepDelayMinutes` | Mean departure delay across qualifying flights |
| `P90DepDelayMinutes` | 90th percentile departure delay |
| `DepDel15Pct` | Percentage of flights delayed 15+ minutes |
| `QualifyingMonths` | Number of months the cell met volume thresholds |
| `HotspotRank` | Rank by delay severity |

## Result Data

{{result_table_md}}
```

```html
<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Delta ATL Departure Delay Hotspots</title>
    <style>
        :root {
            --bg-top: #eaf3f8;
            --bg-bottom: #f6fafc;
            --panel: #ffffff;
            --panel-alt: #f3f7fa;
            --ink: #163244;
            --muted: #5d7485;
            --navy: #0e3a52;
            --slate: #5c7080;
            --sky: #3c88b5;
            --teal: #1f8a70;
            --amber: #d48a1f;
            --red: #c54f36;
            --grid: rgba(22, 50, 68, 0.12);
            --border: rgba(22, 50, 68, 0.10);
            --shadow: 0 18px 45px rgba(14, 58, 82, 0.10);
            --radius-xl: 22px;
            --radius-lg: 16px;
            --radius-md: 12px;
            --radius-sm: 8px;
        }
        *, *::before, *::after { box-sizing: border-box; }
        body {
            margin: 0;
            font-family: "Segoe UI", "Helvetica Neue", sans-serif;
            background: linear-gradient(180deg, var(--bg-top) 0%, var(--bg-bottom) 100%);
            color: var(--ink);
            min-height: 100vh;
        }
        .container {
            max-width: 1280px;
            margin: 0 auto;
            padding: 24px 20px;
        }
        header {
            background: linear-gradient(135deg, var(--navy) 0%, #1a5a78 100%);
            color: #fff;
            padding: 32px 24px;
            border-radius: var(--radius-xl);
            margin-bottom: 24px;
            box-shadow: var(--shadow);
        }
        header h1 {
            margin: 0 0 8px 0;
            font-family: Georgia, ui-serif, serif;
            font-size: 1.75rem;
            font-weight: 600;
        }
        header .subtitle {
            margin: 0;
            font-size: 0.95rem;
            opacity: 0.85;
        }
        .kpi-strip {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 16px;
            margin-bottom: 24px;
        }
        .kpi-card {
            background: var(--panel);
            border-radius: var(--radius-md);
            padding: 20px;
            box-shadow: var(--shadow);
            text-align: center;
        }
        .kpi-card .label {
            font-size: 0.8rem;
            color: var(--muted);
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 6px;
        }
        .kpi-card .value {
            font-size: 1.6rem;
            font-weight: 700;
            color: var(--navy);
        }
        .kpi-card .detail {
            font-size: 0.85rem;
            color: var(--slate);
            margin-top: 4px;
        }
        .kpi-card.highlight .value { color: var(--red); }
        .card {
            background: var(--panel);
            border-radius: var(--radius-lg);
            padding: 24px;
            margin-bottom: 24px;
            box-shadow: var(--shadow);
        }
        .card h2 {
            margin: 0 0 16px 0;
            font-family: Georgia, ui-serif, serif;
            font-size: 1.15rem;
            color: var(--navy);
        }
        .heatmap-container {
            overflow-x: auto;
        }
        .heatmap-table {
            border-collapse: collapse;
            font-size: 0.85rem;
            min-width: 100%;
        }
        .heatmap-table th, .heatmap-table td {
            border: 1px solid var(--border);
            padding: 8px 10px;
            text-align: center;
            white-space: nowrap;
        }
        .heatmap-table th {
            background: var(--panel-alt);
            color: var(--navy);
            font-weight: 600;
            position: sticky;
            top: 0;
        }
        .heatmap-table th.row-header {
            position: sticky;
            left: 0;
            background: var(--panel-alt);
            z-index: 2;
        }
        .heatmap-table td.row-header {
            position: sticky;
            left: 0;
            background: var(--panel);
            font-weight: 600;
            color: var(--navy);
            text-align: left;
        }
        .heatmap-cell {
            min-width: 60px;
            font-weight: 500;
        }
        .heatmap-cell.worst {
            outline: 3px solid var(--red);
            outline-offset: -3px;
            font-weight: 700;
        }
        .legend {
            display: flex;
            align-items: center;
            gap: 16px;
            margin-top: 16px;
            flex-wrap: wrap;
            font-size: 0.8rem;
            color: var(--muted);
        }
        .legend-bar {
            display: flex;
            align-items: center;
            gap: 4px;
        }
        .legend-bar .swatch {
            width: 60px;
            height: 14px;
            border-radius: 3px;
            background: linear-gradient(90deg, var(--teal), #f9dc5c, var(--amber), var(--red));
        }
        .trend-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
            gap: 16px;
        }
        .trend-card {
            background: var(--panel-alt);
            border-radius: var(--radius-sm);
            padding: 16px;
        }
        .trend-card h3 {
            margin: 0 0 12px 0;
            font-size: 0.95rem;
            color: var(--navy);
        }
        .trend-chart {
            height: 120px;
            position: relative;
        }
        .trend-chart canvas {
            width: 100% !important;
            height: 100% !important;
        }
        .rank-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 0.85rem;
        }
        .rank-table th, .rank-table td {
            border-bottom: 1px solid var(--border);
            padding: 10px 8px;
            text-align: left;
        }
        .rank-table th {
            background: var(--panel-alt);
            color: var(--navy);
            font-weight: 600;
            position: sticky;
            top: 0;
        }
        .rank-table tbody tr:hover { background: var(--panel-alt); }
        .rank-table .num { text-align: right; font-variant-numeric: tabular-nums; }
        .rank-table .rank-1 { background: rgba(197, 79, 54, 0.08); }
        .rank-table .rank-2, .rank-table .rank-3 { background: rgba(212, 138, 31, 0.06); }
        .ledger {
            background: var(--panel-alt);
            border-radius: var(--radius-sm);
            padding: 16px;
            margin-top: 24px;
            font-size: 0.8rem;
        }
        .ledger h3 {
            margin: 0 0 10px 0;
            font-size: 0.9rem;
            color: var(--navy);
        }
        .ledger-item {
            display: flex;
            gap: 12px;
            padding: 6px 0;
            border-bottom: 1px solid var(--border);
        }
        .ledger-item:last-child { border-bottom: none; }
        .ledger-item .role {
            background: var(--sky);
            color: #fff;
            padding: 2px 8px;
            border-radius: 4px;
            font-size: 0.7rem;
            text-transform: uppercase;
        }
        .ledger-item .status { color: var(--teal); }
        .ledger-item .status.error { color: var(--red); }
        .control-footer {
            background: var(--panel);
            border-radius: var(--radius-lg);
            padding: 24px;
            margin-top: 32px;
            box-shadow: var(--shadow);
        }
        .control-footer h3 {
            margin: 0 0 16px 0;
            font-size: 1rem;
            color: var(--navy);
        }
        .control-row {
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
            margin-bottom: 12px;
            align-items: center;
        }
        .control-row label {
            font-size: 0.85rem;
            color: var(--muted);
            min-width: 80px;
        }
        .control-row input[type="password"] {
            flex: 1;
            min-width: 200px;
            padding: 8px 12px;
            border: 1px solid var(--border);
            border-radius: var(--radius-sm);
            font-size: 0.9rem;
        }
        .control-row textarea {
            flex: 1;
            min-width: 200px;
            padding: 8px 12px;
            border: 1px solid var(--border);
            border-radius: var(--radius-sm);
            font-family: monospace;
            font-size: 0.8rem;
            resize: vertical;
            min-height: 120px;
        }
        .btn {
            padding: 10px 20px;
            border: none;
            border-radius: var(--radius-sm);
            font-size: 0.9rem;
            cursor: pointer;
            transition: background 0.2s;
        }
        .btn-primary {
            background: var(--sky);
            color: #fff;
        }
        .btn-primary:hover { background: var(--navy); }
        .btn-secondary {
            background: var(--panel-alt);
            color: var(--slate);
        }
        .btn-secondary:hover { background: var(--grid); }
        .btn-export {
            background: var(--teal);
            color: #fff;
        }
        .btn-export:hover { background: #176b58; }
        .status-text {
            font-size: 0.85rem;
            color: var(--muted);
            margin-top: 8px;
        }
        .status-text.error { color: var(--red); }
        .status-text.success { color: var(--teal); }
        .empty-state {
            text-align: center;
            padding: 48px 24px;
            color: var(--muted);
        }
        .empty-state h3 {
            color: var(--navy);
            margin-bottom: 8px;
        }
        #dashboard-content { display: none; }
        #dashboard-content.visible { display: block; }
        .warning-panel {
            background: rgba(212, 138, 31, 0.1);
            border: 1px solid var(--amber);
            border-radius: var(--radius-sm);
            padding: 16px;
            color: var(--ink);
            margin-bottom: 16px;
        }
        @media (max-width: 600px) {
            header h1 { font-size: 1.3rem; }
            .kpi-card .value { font-size: 1.3rem; }
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>Delta ATL Departure Delay Hotspots</h1>
            <p class="subtitle">Destination × Time Block Analysis for DL Departures from Atlanta</p>
        </header>

        <div id="empty-state" class="card empty-state">
            <h3>No Data Loaded</h3>
            <p>Enter your JWE token and fetch data using the controls below.</p>
        </div>

        <div id="dashboard-content">
            <div class="kpi-strip" id="kpi-strip"></div>

            <div class="card">
                <h2>Departure Delay Heatmap: Destination × Time Block</h2>
                <div class="heatmap-container" id="heatmap-container"></div>
                <div class="legend">
                    <span>Avg Delay:</span>
                    <div class="legend-bar">
                        <span>Low</span>
                        <div class="swatch"></div>
                        <span>High</span>
                    </div>
                    <span style="margin-left: 12px;">■ Outlined = Worst hotspot</span>
                </div>
            </div>

            <div class="card">
                <h2>Monthly Trends: Top 3 Hotspot Cells</h2>
                <div class="trend-grid" id="trend-grid"></div>
            </div>

            <div class="card">
                <h2>Top 20 Hotspot Cells</h2>
                <div style="overflow-x: auto;">
                    <table class="rank-table" id="rank-table">
                        <thead>
                            <tr>
                                <th>Rank</th>
                                <th>Dest</th>
                                <th>Time Block</th>
                                <th class="num">Avg Delay</th>
                                <th class="num">P90 Delay</th>
                                <th class="num">Del15%</th>
                                <th class="num">Flights</th>
                                <th class="num">Months</th>
                                <th>Period</th>
                            </tr>
                        </thead>
                        <tbody id="rank-tbody"></tbody>
                    </table>
                </div>
                <div style="margin-top: 16px;">
                    <button class="btn btn-export" id="export-btn">Export CSV</button>
                </div>
            </div>

            <div class="ledger" id="query-ledger">
                <h3>Query Ledger</h3>
                <div id="ledger-items"></div>
            </div>
        </div>

        <div class="control-footer">
            <h3>Data Controls</h3>
            <div class="control-row">
                <label>JWE Token:</label>
                <input type="password" id="jwe-input" placeholder="Enter JWE token">
                <button class="btn btn-secondary" id="forget-btn">Forget</button>
            </div>
            <div class="control-row">
                <label>SQL Query:</label>
                <textarea id="sql-input"></textarea>
            </div>
            <div class="control-row">
                <button class="btn btn-primary" id="fetch-btn">Fetch Data</button>
            </div>
            <div class="status-text" id="status-text"></div>
        </div>
    </div>

    <script>
    (function() {
        const STORAGE_KEY = 'OnTimeAnalystDashboard::auth::jwe';
        const SAVED_SQL = `WITH
-- Step 1: Base filtered flights for DL departures from ATL
base_flights AS (
    SELECT
        toStartOfMonth(FlightDate) AS MonthStart,
        Dest,
        DepTimeBlk,
        DepDelayMinutes,
        DepDel15
    FROM default.ontime_v2
    WHERE IATA_CODE_Reporting_Airline = 'DL'
      AND Origin = 'ATL'
      AND Cancelled = 0
),

-- Step 2: Monthly aggregation with qualification (>= 40 flights)
monthly_qualified AS (
    SELECT
        MonthStart,
        Dest,
        DepTimeBlk,
        count(*) AS MonthlyFlights
    FROM base_flights
    GROUP BY MonthStart, Dest, DepTimeBlk
    HAVING MonthlyFlights >= 40
),

-- Step 3: Hotspot-level stats from raw flights in qualifying monthly cells
hotspot_raw AS (
    SELECT
        bf.Dest,
        bf.DepTimeBlk,
        bf.DepDelayMinutes,
        bf.DepDel15,
        bf.MonthStart
    FROM base_flights bf
    INNER JOIN monthly_qualified mq
        ON bf.MonthStart = mq.MonthStart
       AND bf.Dest = mq.Dest
       AND bf.DepTimeBlk = mq.DepTimeBlk
),

-- Step 4: Compute hotspot-level metrics from raw flights
hotspot_metrics AS (
    SELECT
        Dest,
        DepTimeBlk,
        count(*) AS CompletedFlights,
        avg(DepDelayMinutes) AS AvgDepDelayMinutes,
        quantile(0.9)(DepDelayMinutes) AS P90DepDelayMinutes,
        100.0 * sum(DepDel15) / count(*) AS DepDel15Pct,
        count(DISTINCT MonthStart) AS QualifyingMonths,
        min(MonthStart) AS FirstQualifyingMonth,
        max(MonthStart) AS LastQualifyingMonth
    FROM hotspot_raw
    GROUP BY Dest, DepTimeBlk
    HAVING CompletedFlights >= 1000
),

-- Step 5: Rank hotspots
ranked_hotspots AS (
    SELECT
        *,
        row_number() OVER (
            ORDER BY AvgDepDelayMinutes DESC, P90DepDelayMinutes DESC, DepDel15Pct DESC, CompletedFlights DESC
        ) AS HotspotRank
    FROM hotspot_metrics
),

-- Step 6: Top 20 hotspots
top_hotspots AS (
    SELECT * FROM ranked_hotspots WHERE HotspotRank <= 20
),

-- Step 7: Monthly trend rows for top 20 hotspots (from raw flights in qualifying months)
monthly_trends AS (
    SELECT
        hr.MonthStart,
        hr.Dest,
        hr.DepTimeBlk,
        count(*) AS CompletedFlights,
        avg(hr.DepDelayMinutes) AS AvgDepDelayMinutes,
        quantile(0.9)(hr.DepDelayMinutes) AS P90DepDelayMinutes,
        100.0 * sum(hr.DepDel15) / count(*) AS DepDel15Pct
    FROM hotspot_raw hr
    INNER JOIN top_hotspots th ON hr.Dest = th.Dest AND hr.DepTimeBlk = th.DepTimeBlk
    GROUP BY hr.MonthStart, hr.Dest, hr.DepTimeBlk
),

-- Step 8: Attach hotspot metadata to monthly trends
monthly_trends_with_meta AS (
    SELECT
        mt.MonthStart,
        mt.Dest,
        mt.DepTimeBlk,
        mt.CompletedFlights,
        mt.AvgDepDelayMinutes,
        mt.P90DepDelayMinutes,
        mt.DepDel15Pct,
        th.QualifyingMonths,
        th.FirstQualifyingMonth,
        th.LastQualifyingMonth,
        th.HotspotRank
    FROM monthly_trends mt
    INNER JOIN top_hotspots th ON mt.Dest = th.Dest AND mt.DepTimeBlk = th.DepTimeBlk
),

-- Step 9: Hotspot summary rows
hotspot_summary AS (
    SELECT
        'hotspot_summary' AS RowType,
        toNullable(toDate('1970-01-01')) AS MonthStart,
        Dest,
        DepTimeBlk,
        QualifyingMonths,
        CompletedFlights,
        round(AvgDepDelayMinutes, 2) AS AvgDepDelayMinutes,
        round(P90DepDelayMinutes, 2) AS P90DepDelayMinutes,
        round(DepDel15Pct, 2) AS DepDel15Pct,
        FirstQualifyingMonth,
        LastQualifyingMonth,
        HotspotRank
    FROM top_hotspots
),

-- Step 10: Monthly trend rows
monthly_trend_rows AS (
    SELECT
        'monthly_trend' AS RowType,
        toNullable(MonthStart) AS MonthStart,
        Dest,
        DepTimeBlk,
        QualifyingMonths,
        CompletedFlights,
        round(AvgDepDelayMinutes, 2) AS AvgDepDelayMinutes,
        round(P90DepDelayMinutes, 2) AS P90DepDelayMinutes,
        round(DepDel15Pct, 2) AS DepDel15Pct,
        FirstQualifyingMonth,
        LastQualifyingMonth,
        HotspotRank
    FROM monthly_trends_with_meta
),

-- Final union
combined AS (
    SELECT * FROM hotspot_summary
    UNION ALL
    SELECT * FROM monthly_trend_rows
)

SELECT
    RowType,
    if(RowType = 'hotspot_summary', NULL, MonthStart) AS MonthStart,
    Dest,
    DepTimeBlk,
    QualifyingMonths,
    CompletedFlights,
    AvgDepDelayMinutes,
    P90DepDelayMinutes,
    DepDel15Pct,
    FirstQualifyingMonth,
    LastQualifyingMonth,
    HotspotRank
FROM combined
ORDER BY RowType ASC, HotspotRank ASC, MonthStart ASC, Dest ASC, DepTimeBlk ASC`;

        const jweInput = document.getElementById('jwe-input');
        const sqlInput = document.getElementById('sql-input');
        const fetchBtn = document.getElementById('fetch-btn');
        const forgetBtn = document.getElementById('forget-btn');
        const statusText = document.getElementById('status-text');
        const emptyState = document.getElementById('empty-state');
        const dashboardContent = document.getElementById('dashboard-content');
        const exportBtn = document.getElementById('export-btn');

        let allRows = [];
        let summaryRows = [];
        let trendRows = [];
        const queryLedger = [];

        function normalizeDate(val) {
            return String(val ?? '').slice(0, 10);
        }

        function init() {
            const storedJwe = localStorage.getItem(STORAGE_KEY);
            if (storedJwe) {
                jweInput.value = '••••••••';
                jweInput.dataset.stored = storedJwe;
            }
            sqlInput.value = SAVED_SQL;
            fetchBtn.addEventListener('click', fetchData);
            forgetBtn.addEventListener('click', forgetToken);
            exportBtn.addEventListener('click', exportCsv);
        }

        function forgetToken() {
            localStorage.removeItem(STORAGE_KEY);
            jweInput.value = '';
            delete jweInput.dataset.stored;
            statusText.textContent = 'Token forgotten.';
            statusText.className = 'status-text';
        }

        function getToken() {
            const typed = jweInput.value.trim();
            if (typed && !typed.startsWith('••')) return typed;
            return jweInput.dataset.stored || '';
        }

        async function fetchData() {
            const token = getToken();
            const sql = sqlInput.value.trim();
            if (!token) {
                statusText.textContent = 'Please enter a JWE token.';
                statusText.className = 'status-text error';
                return;
            }
            if (!sql) {
                statusText.textContent = 'SQL query is empty.';
                statusText.className = 'status-text error';
                return;
            }
            statusText.textContent = 'Fetching data...';
            statusText.className = 'status-text';
            const url = `https://mcp.demo.altinity.cloud/${token}/openapi/execute_query?query=${encodeURIComponent(sql)}`;
            try {
                const resp = await fetch(url);
                if (!resp.ok) {
                    const errText = await resp.text();
                    throw new Error(`HTTP ${resp.status}: ${errText.slice(0, 200)}`);
                }
                const data = await resp.json();
                localStorage.setItem(STORAGE_KEY, token);
                if (jweInput.value && !jweInput.value.startsWith('••')) {
                    jweInput.dataset.stored = token;
                    jweInput.value = '••••••••';
                }
                addLedgerEntry('Primary Query', 'primary', 'success', data.count ?? (data.rows?.length ?? 0));
                processData(data);
            } catch (err) {
                statusText.textContent = err.message;
                statusText.className = 'status-text error';
                addLedgerEntry('Primary Query', 'primary', 'error', 0);
            }
        }

        function addLedgerEntry(label, role, status, rowCount) {
            queryLedger.push({ label, role, status, rowCount });
            renderLedger();
        }

        function renderLedger() {
            const container = document.getElementById('ledger-items');
            container.innerHTML = queryLedger.map(q => `
                <div class="ledger-item">
                    <span class="role">${q.role}</span>
                    <span>${q.label}</span>
                    <span class="status ${q.status === 'error' ? 'error' : ''}">${q.status}</span>
                    <span>${q.rowCount} rows</span>
                </div>
            `).join('');
        }

        function processData(data) {
            const cols = data.columns || [];
            const rows = data.rows || [];
            if (!cols.length || !rows.length) {
                emptyState.innerHTML = '<h3>No Results</h3><p>The query returned no data.</p>';
                dashboardContent.classList.remove('visible');
                statusText.textContent = 'Query returned 0 rows.';
                statusText.className = 'status-text';
                return;
            }
            allRows = rows.map(r => {
                const obj = {};
                cols.forEach((c, i) => obj[c] = r[i]);
                return obj;
            });
            summaryRows = allRows.filter(r => r.RowType === 'hotspot_summary').sort((a, b) => a.HotspotRank - b.HotspotRank);
            trendRows = allRows.filter(r => r.RowType === 'monthly_trend');
            emptyState.style.display = 'none';
            dashboardContent.classList.add('visible');
            statusText.textContent = `Loaded ${allRows.length} rows.`;
            statusText.className = 'status-text success';
            renderKpis();
            renderHeatmap();
            renderTrends();
            renderRankTable();
        }

        function renderKpis() {
            const strip = document.getElementById('kpi-strip');
            if (!summaryRows.length) {
                strip.innerHTML = '<div class="warning-panel">No hotspot summary data available.</div>';
                return;
            }
            const worst = summaryRows[0];
            const totalFlights = summaryRows.reduce((s, r) => s + (r.CompletedFlights || 0), 0);
            const maxMonths = Math.max(...summaryRows.map(r => r.QualifyingMonths || 0));
            strip.innerHTML = `
                <div class="kpi-card highlight">
                    <div class="label">Worst Hotspot</div>
                    <div class="value">${worst.Dest} @ ${worst.DepTimeBlk}</div>
                    <div class="detail">Rank #1</div>
                </div>
                <div class="kpi-card">
                    <div class="label">Worst Avg Delay</div>
                    <div class="value">${worst.AvgDepDelayMinutes?.toFixed(1) ?? '—'} min</div>
                    <div class="detail">P90: ${worst.P90DepDelayMinutes?.toFixed(1) ?? '—'} min</div>
                </div>
                <div class="kpi-card">
                    <div class="label">Top 20 Flights</div>
                    <div class="value">${totalFlights.toLocaleString()}</div>
                    <div class="detail">Across ${summaryRows.length} hotspots</div>
                </div>
                <div class="kpi-card">
                    <div class="label">Max Persistence</div>
                    <div class="value">${maxMonths} months</div>
                    <div class="detail">Qualifying period</div>
                </div>
            `;
        }

        function renderHeatmap() {
            const container = document.getElementById('heatmap-container');
            if (!summaryRows.length) {
                container.innerHTML = '<div class="warning-panel">No heatmap data.</div>';
                return;
            }
            const dests = [...new Set(summaryRows.map(r => r.Dest))].sort();
            const timeBlks = [...new Set(summaryRows.map(r => r.DepTimeBlk))].sort();
            const dataMap = {};
            let minDelay = Infinity, maxDelay = -Infinity;
            summaryRows.forEach(r => {
                const key = `${r.Dest}|${r.DepTimeBlk}`;
                dataMap[key] = r;
                const d = r.AvgDepDelayMinutes ?? 0;
                if (d < minDelay) minDelay = d;
                if (d > maxDelay) maxDelay = d;
            });
            const worstKey = `${summaryRows[0].Dest}|${summaryRows[0].DepTimeBlk}`;
            function delayColor(val) {
                if (val == null) return 'var(--panel-alt)';
                const t = maxDelay > minDelay ? (val - minDelay) / (maxDelay - minDelay) : 0;
                if (t < 0.33) return `rgba(31, 138, 112, ${0.3 + t * 0.5})`;
                if (t < 0.66) return `rgba(212, 138, 31, ${0.4 + (t - 0.33) * 0.5})`;
                return `rgba(197, 79, 54, ${0.5 + (t - 0.66) * 0.5})`;
            }
            let html = '<table class="heatmap-table"><thead><tr><th class="row-header">Dest \\ Time</th>';
            timeBlks.forEach(tb => { html += `<th>${tb}</th>`; });
            html += '</tr></thead><tbody>';
            dests.forEach(dest => {
                html += `<tr><td class="row-header">${dest}</td>`;
                timeBlks.forEach(tb => {
                    const key = `${dest}|${tb}`;
                    const r = dataMap[key];
                    const val = r?.AvgDepDelayMinutes;
                    const isWorst = key === worstKey;
                    const bg = delayColor(val);
                    html += `<td class="heatmap-cell${isWorst ? ' worst' : ''}" style="background:${bg}" title="${dest} ${tb}: ${val?.toFixed(1) ?? '—'} min avg">${val != null ? val.toFixed(1) : ''}</td>`;
                });
                html += '</tr>';
            });
            html += '</tbody></table>';
            container.innerHTML = html;
        }

        function renderTrends() {
            const grid = document.getElementById('trend-grid');
            const top3 = summaryRows.slice(0, 3);
            if (!top3.length) {
                grid.innerHTML = '<div class="warning-panel">No trend data.</div>';
                return;
            }
            grid.innerHTML = top3.map((hs, idx) => {
                const cellTrends = trendRows.filter(r => r.Dest === hs.Dest && r.DepTimeBlk === hs.DepTimeBlk)
                    .sort((a, b) => normalizeDate(a.MonthStart).localeCompare(normalizeDate(b.MonthStart)));
                const canvasId = `trend-canvas-${idx}`;
                return `
                    <div class="trend-card">
                        <h3>#${hs.HotspotRank}: ${hs.Dest} @ ${hs.DepTimeBlk}</h3>
                        <div class="trend-chart"><canvas id="${canvasId}"></canvas></div>
                    </div>
                `;
            }).join('');
            top3.forEach((hs, idx) => {
                const cellTrends = trendRows.filter(r => r.Dest === hs.Dest && r.DepTimeBlk === hs.DepTimeBlk)
                    .sort((a, b) => normalizeDate(a.MonthStart).localeCompare(normalizeDate(b.MonthStart)));
                drawSparkline(`trend-canvas-${idx}`, cellTrends.map(r => r.AvgDepDelayMinutes ?? 0), cellTrends.map(r => normalizeDate(r.MonthStart)));
            });
        }

        function drawSparkline(canvasId, values, labels) {
            const canvas = document.getElementById(canvasId);
            if (!canvas || !values.length) return;
            const ctx = canvas.getContext('2d');
            const dpr = window.devicePixelRatio || 1;
            const rect = canvas.getBoundingClientRect();
            canvas.width = rect.width * dpr;
            canvas.height = rect.height * dpr;
            ctx.scale(dpr, dpr);
            const w = rect.width, h = rect.height;
            const pad = 8;
            const minV = Math.min(...values), maxV = Math.max(...values);
            const range = maxV - minV || 1;
            ctx.clearRect(0, 0, w, h);
            ctx.strokeStyle = '#3c88b5';
            ctx.lineWidth = 2;
            ctx.beginPath();
            values.forEach((v, i) => {
                const x = pad + (i / (values.length - 1 || 1)) * (w - 2 * pad);
                const y = h - pad - ((v - minV) / range) * (h - 2 * pad);
                if (i === 0) ctx.moveTo(x, y);
                else ctx.lineTo(x, y);
            });
            ctx.stroke();
            ctx.fillStyle = '#c54f36';
            const maxIdx = values.indexOf(Math.max(...values));
            const mx = pad + (maxIdx / (values.length - 1 || 1)) * (w - 2 * pad);
            const my = h - pad - ((values[maxIdx] - minV) / range) * (h - 2 * pad);
            ctx.beginPath();
            ctx.arc(mx, my, 4, 0, 2 * Math.PI);
            ctx.fill();
        }

        function renderRankTable() {
            const tbody = document.getElementById('rank-tbody');
            if (!summaryRows.length) {
                tbody.innerHTML = '<tr><td colspan="9">No data</td></tr>';
                return;
            }
            tbody.innerHTML = summaryRows.map(r => {
                const rankClass = r.HotspotRank === 1 ? 'rank-1' : (r.HotspotRank <= 3 ? 'rank-2' : '');
                const first = normalizeDate(r.FirstQualifyingMonth);
                const last = normalizeDate(r.LastQualifyingMonth);
                return `<tr class="${rankClass}">
                    <td>${r.HotspotRank}</td>
                    <td>${r.Dest}</td>
                    <td>${r.DepTimeBlk}</td>
                    <td class="num">${r.AvgDepDelayMinutes?.toFixed(2) ?? '—'}</td>
                    <td class="num">${r.P90DepDelayMinutes?.toFixed(2) ?? '—'}</td>
                    <td class="num">${r.DepDel15Pct?.toFixed(1) ?? '—'}%</td>
                    <td class="num">${(r.CompletedFlights ?? 0).toLocaleString()}</td>
                    <td class="num">${r.QualifyingMonths ?? '—'}</td>
                    <td>${first} – ${last}</td>
                </tr>`;
            }).join('');
        }

        function exportCsv() {
            if (!summaryRows.length) return;
            const headers = ['Rank','Dest','DepTimeBlk','AvgDepDelayMinutes','P90DepDelayMinutes','DepDel15Pct','CompletedFlights','QualifyingMonths','FirstMonth','LastMonth'];
            const csvRows = [headers.join(',')];
            summaryRows.forEach(r => {
                csvRows.push([
                    r.HotspotRank,
                    r.Dest,
                    r.DepTimeBlk,
                    r.AvgDepDelayMinutes,
                    r.P90DepDelayMinutes,
                    r.DepDel15Pct,
                    r.CompletedFlights,
                    r.QualifyingMonths,
                    normalizeDate(r.FirstQualifyingMonth),
                    normalizeDate(r.LastQualifyingMonth)
                ].join(','));
            });
            const blob = new Blob([csvRows.join('\n')], { type: 'text/csv' });
            const url = URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = 'delta_atl_hotspots.csv';
            a.click();
            URL.revokeObjectURL(url);
        }

        init();
    })();
    </script>
</body>
</html>
```
