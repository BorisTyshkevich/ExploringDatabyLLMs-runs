```report
# {{question_title}}

{{data_overview_md}}

## Analytical Findings

### Maximum Hop Count and Operational Pattern
The dataset isolates the most extreme multi-leg operations performed by a single aircraft (tail number) operating under one flight number on a single day. Reviewing these top {{row_count}} records clarifies whether the maximum hop count observed is part of a repeated, structural operating pattern—such as a dedicated regional multi-stop route—or a one-off irregular routing caused by operational necessity.

### Lead Itinerary Details
The single most recent itinerary among the maximum-hop flights is listed at the top of the data table. This entry captures the specific carrier, flight number, flight date, and the complete step-by-step route sequence, offering a clear view of the aircraft's movement throughout the day.

### Route Repetition and Clustering
Examining the full route paths across the longest daily itineraries reveals notable route repetition and hub clustering. These patterns highlight how carriers string together multiple short-haul segments and whether similar extreme-hop sequences are executed repeatedly within the top tier of operations.

## Detailed Itineraries

{{result_table_md}}
```

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Highest Daily Hops Dashboard</title>
  <link rel="stylesheet" href="https://unpkg.com/leaflet/dist/leaflet.css" />
  <script src="https://unpkg.com/leaflet/dist/leaflet.js"></script>
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
    body {
        margin: 0;
        padding: 0;
        font-family: "Segoe UI", "Helvetica Neue", sans-serif;
        background: linear-gradient(180deg, var(--bg-top) 0%, var(--bg-bottom) 100%);
        color: var(--ink);
        min-height: 100vh;
        display: flex;
        flex-direction: column;
    }
    .container {
        max-width: 1280px;
        margin: 0 auto;
        padding: 2rem;
        flex: 1;
        width: 100%;
        box-sizing: border-box;
    }
    h1 {
        font-family: "Georgia", ui-serif, serif;
        color: var(--navy);
        margin-top: 0;
    }
    .kpi-strip {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
        gap: 1.5rem;
        margin-bottom: 2rem;
    }
    .kpi-card {
        background: var(--panel);
        border-radius: var(--radius-md);
        padding: 1.5rem;
        box-shadow: var(--shadow);
        border: 1px solid var(--border);
    }
    .kpi-value {
        font-size: 2rem;
        font-weight: bold;
        color: var(--navy);
        margin-top: 0.5rem;
    }
    .kpi-label {
        font-size: 0.9rem;
        color: var(--slate);
        text-transform: uppercase;
        letter-spacing: 0.05em;
    }
    .main-grid {
        display: grid;
        grid-template-columns: 2fr 1fr;
        gap: 2rem;
        margin-bottom: 2rem;
    }
    @media(max-width: 900px) {
        .main-grid { grid-template-columns: 1fr; }
    }
    .card {
        background: var(--panel);
        border-radius: var(--radius-lg);
        padding: 1.5rem;
        box-shadow: var(--shadow);
        border: 1px solid var(--border);
    }
    #map {
        height: 500px;
        border-radius: var(--radius-md);
        background: var(--panel-alt);
        z-index: 1;
    }
    table {
        width: 100%;
        border-collapse: collapse;
        font-size: 0.9rem;
    }
    th, td {
        padding: 0.75rem 1rem;
        text-align: left;
        border-bottom: 1px solid var(--border);
    }
    th {
        background: var(--panel-alt);
        color: var(--slate);
        font-weight: 600;
        position: sticky;
        top: 0;
    }
    tr:hover { background: var(--panel-alt); }
    .footer-block {
        background: var(--navy);
        color: white;
        padding: 2rem;
        margin-top: auto;
    }
    .footer-container {
        max-width: 1280px;
        margin: 0 auto;
    }
    .control-form {
        display: flex;
        flex-direction: column;
        gap: 1rem;
    }
    .control-group {
        display: flex;
        gap: 1rem;
        align-items: center;
    }
    input[type="password"], textarea {
        padding: 0.75rem;
        border-radius: var(--radius-sm);
        border: 1px solid rgba(255,255,255,0.2);
        background: rgba(255,255,255,0.1);
        color: white;
        font-family: monospace;
    }
    textarea {
        width: 100%;
        min-height: 250px;
        resize: vertical;
    }
    button {
        padding: 0.75rem 1.5rem;
        border: none;
        border-radius: var(--radius-sm);
        background: var(--teal);
        color: white;
        font-weight: bold;
        cursor: pointer;
    }
    button:hover { background: #1a755f; }
    button.secondary { background: var(--slate); }
    button.secondary:hover { background: #4a5a68; }
    .ledger {
        margin-top: 1.5rem;
        background: rgba(0,0,0,0.2);
        padding: 1rem;
        border-radius: var(--radius-sm);
        font-family: monospace;
        font-size: 0.85rem;
    }
    .ledger-item {
        display: flex;
        justify-content: space-between;
        padding: 0.5rem 0;
        border-bottom: 1px solid rgba(255,255,255,0.1);
    }
    .ledger-item:last-child { border-bottom: none; }
    #dashboard-content { display: none; }
    .status-msg { margin-top: 1rem; font-weight: bold; padding: 1rem; border-radius: var(--radius-sm); background: var(--panel); border: 1px solid var(--border); display: inline-block;}
    .status-msg:empty { display: none; }
    .error { color: var(--red); border-color: var(--red); }
    .warning { color: var(--amber); border-color: var(--amber); }
  </style>
</head>
<body>

<div class="container">
    <h1>Highest Daily Hops for One Aircraft</h1>
    <p style="color: var(--slate); margin-bottom: 2rem;">Analyzing extreme multi-leg operational patterns and route repetition for individual aircraft within a single day.</p>

    <div id="status-container" class="status-msg">Please enter your JWE token and run the query.</div>

    <div id="dashboard-content">
        <div class="kpi-strip">
            <div class="kpi-card">
                <div class="kpi-label">Lead Itinerary Date</div>
                <div class="kpi-value" id="kpi-date">-</div>
            </div>
            <div class="kpi-card">
                <div class="kpi-label">Tail & Flight</div>
                <div class="kpi-value" id="kpi-tail-flight">-</div>
            </div>
            <div class="kpi-card">
                <div class="kpi-label">Max Hops</div>
                <div class="kpi-value" id="kpi-hops" style="color: var(--red);">-</div>
            </div>
            <div class="kpi-card">
                <div class="kpi-label">Top 10 Route Repetition</div>
                <div class="kpi-value" id="kpi-repetition" style="font-size: 1.1rem; margin-top: 1rem; font-weight: 500;">-</div>
            </div>
        </div>

        <div class="main-grid">
            <div class="card" style="padding: 0; overflow: hidden; display: flex; flex-direction: column;">
                <div style="padding: 1.5rem; border-bottom: 1px solid var(--border);">
                    <h2 style="margin: 0; font-size: 1.2rem; color: var(--navy);">Lead Itinerary Route Map</h2>
                </div>
                <div id="map"></div>
                <div id="map-legend" style="padding: 1rem 1.5rem; background: var(--panel-alt); font-size: 0.85rem; color: var(--slate);">
                    <span style="display:inline-block; width: 12px; height: 12px; background: var(--red); border-radius: 50%; margin-right: 6px; vertical-align: middle;"></span> Lead Route Path
                    <span style="display:inline-block; width: 12px; height: 12px; background: var(--navy); border-radius: 50%; margin-right: 6px; margin-left: 15px; vertical-align: middle;"></span> Airport Stops
                </div>
            </div>
            <div class="card" style="overflow-y: auto; max-height: 600px;">
                <h2 style="margin-top: 0; font-size: 1.2rem; color: var(--navy);">Top 10 Itineraries</h2>
                <table id="results-table">
                    <thead>
                        <tr>
                            <th>Rank</th>
                            <th>Tail</th>
                            <th>Hops</th>
                            <th>Date</th>
                        </tr>
                    </thead>
                    <tbody></tbody>
                </table>
            </div>
        </div>
        
        <div class="card">
            <h2 style="margin-top: 0; font-size: 1.2rem; color: var(--navy);">Route Sequences</h2>
            <div id="route-sequences" style="font-family: monospace; font-size: 0.9rem; line-height: 1.6;"></div>
        </div>
    </div>
</div>

<div class="footer-block">
    <div class="footer-container">
        <h3 style="margin-top:0;">Data Control</h3>
        <div class="control-form">
            <div class="control-group">
                <input type="password" id="jwe-token" placeholder="JWE Token" style="flex: 1; max-width: 400px;">
                <button onclick="forgetToken()" class="secondary">Forget Token</button>
            </div>
            <textarea id="sql-query" spellcheck="false">SELECT
    TailNum,
    FlightNum,
    Carrier,
    FlightDate,
    length(legs) AS Hops,
    arrayStringConcat(
        arrayPushBack(
            arrayMap(x -> concat(x.1, ' (', toString(x.3), ')'), legs),
            tupleElement(legs[-1], 2)
        ),
        ' - '
    ) AS Route
FROM (
    SELECT
        TailNum,
        FlightNum,
        Carrier,
        FlightDate,
        arraySort(x -> toFloat64OrZero(toString(x.3)), groupArray(tuple(Origin, Dest, DepTime))) AS legs
    FROM default.ontime_v2
    WHERE TailNum != ''
      AND toString(FlightNum) != ''
      AND toString(DepTime) != ''
      AND Cancelled = 0
    GROUP BY
        TailNum,
        FlightNum,
        Carrier,
        FlightDate
)
ORDER BY
    Hops DESC,
    FlightDate DESC
LIMIT 10</textarea>
            <div>
                <button onclick="fetchData()">Run Analysis</button>
            </div>
        </div>
        
        <div class="ledger">
            <div style="font-weight: bold; margin-bottom: 0.5rem; color: var(--sky);">Query Ledger</div>
            <div id="ledger-entries"></div>
        </div>
    </div>
</div>

<script>
    const AUTH_KEY = 'OnTimeAnalystDashboard::auth::jwe';
    let mapInstance = null;
    
    document.addEventListener('DOMContentLoaded', () => {
        const token = localStorage.getItem(AUTH_KEY);
        if (token) {
            document.getElementById('jwe-token').value = token;
        }
    });

    function forgetToken() {
        localStorage.removeItem(AUTH_KEY);
        document.getElementById('jwe-token').value = '';
        updateStatus('Token removed from storage.', '');
        document.getElementById('dashboard-content').style.display = 'none';
        document.getElementById('ledger-entries').innerHTML = '';
    }

    function updateStatus(msg, type = '') {
        const el = document.getElementById('status-container');
        el.textContent = msg;
        el.className = `status-msg ${type}`;
    }

    function addLedgerEntry(purpose, status, rows = '-') {
        const container = document.getElementById('ledger-entries');
        const entry = document.createElement('div');
        entry.className = 'ledger-item';
        entry.innerHTML = `
            <span><strong>${purpose}</strong></span>
            <span>Status: ${status} | Rows: ${rows}</span>
        `;
        container.appendChild(entry);
    }

    async function executeQuery(token, sql) {
        const url = `https://mcp.demo.altinity.cloud/${token}/openapi/execute_query?query=${encodeURIComponent(sql)}`;
        const response = await fetch(url);
        if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${await response.text()}`);
        }
        return await response.json();
    }

    async function fetchData() {
        const token = document.getElementById('jwe-token').value.trim();
        const sql = document.getElementById('sql-query').value.trim();
        
        if (!token || !sql) {
            updateStatus('Please provide both JWE token and SQL query.', 'warning');
            return;
        }

        document.getElementById('ledger-entries').innerHTML = '';
        updateStatus('Fetching data...', '');
        document.getElementById('dashboard-content').style.display = 'none';

        try {
            const data = await executeQuery(token, sql);
            localStorage.setItem(AUTH_KEY, token);
            
            if (data.count === 0 || !data.rows || data.rows.length === 0) {
                updateStatus('Query successful, but returned 0 rows.', 'warning');
                addLedgerEntry('Primary Analysis', 'Success', 0);
                return;
            }

            addLedgerEntry('Primary Analysis', 'Success', data.count);
            
            const rows = data.rows.map(row => {
                const obj = {};
                data.columns.forEach((col, i) => {
                    obj[col] = row[i];
                });
                return obj;
            });

            await renderDashboard(rows, token);
            updateStatus('');
            document.getElementById('dashboard-content').style.display = 'block';

        } catch (err) {
            updateStatus(`Error: ${err.message}`, 'error');
            addLedgerEntry('Primary Analysis', 'Failed', '-');
        }
    }

    async function fetchCoordinates(token, allAirports) {
        if (!allAirports || allAirports.length === 0) return {};
        
        try {
            const schemaSql = `SELECT * FROM default.airports_bts LIMIT 1`;
            const schemaData = await executeQuery(token, schemaSql);
            
            let iataCol = schemaData.columns.find(c => ['iata', 'code', 'airport_code', 'airport'].includes(c.toLowerCase())) || 'IATA';
            let latCol = schemaData.columns.find(c => ['latitude', 'lat'].includes(c.toLowerCase())) || 'Latitude';
            let lonCol = schemaData.columns.find(c => ['longitude', 'lon'].includes(c.toLowerCase())) || 'Longitude';

            const codesList = allAirports.map(c => `'${c}'`).join(',');
            const enrichSql = `SELECT ${iataCol} as iata, ${latCol} as lat, ${lonCol} as lon FROM default.airports_bts WHERE ${iataCol} IN (${codesList})`;
            
            const enrichData = await executeQuery(token, enrichSql);
            addLedgerEntry('Airport-Coordinate Enrichment', 'Success', enrichData.count);
            
            const coords = {};
            if (enrichData.rows) {
                enrichData.rows.forEach(r => {
                    coords[r[0]] = { lat: parseFloat(r[1]), lon: parseFloat(r[2]) };
                });
            }
            return coords;
        } catch (err) {
            console.error('Enrichment failed:', err);
            addLedgerEntry('Airport-Coordinate Enrichment', 'Failed (Degraded Map)', '-');
            return {};
        }
    }

    async function renderDashboard(rows, token) {
        const lead = rows[0];
        
        // Normalize temporal keys securely
        const flightDateKey = String(lead.FlightDate ?? '').slice(0, 10);
        
        document.getElementById('kpi-date').textContent = flightDateKey;
        document.getElementById('kpi-tail-flight').textContent = `${lead.TailNum} / ${lead.Carrier}${lead.FlightNum}`;
        document.getElementById('kpi-hops').textContent = lead.Hops;
        
        let maxRepetition = 1;
        const routeCounts = {};
        rows.forEach(r => {
            const cleanRoute = String(r.Route).replace(/\s*\([^\)]+\)\s*/g, ' - ').replace(/ \- \- /g, ' - ');
            routeCounts[cleanRoute] = (routeCounts[cleanRoute] || 0) + 1;
            if (routeCounts[cleanRoute] > maxRepetition) {
                maxRepetition = routeCounts[cleanRoute];
            }
        });
        
        if (maxRepetition > 1) {
            document.getElementById('kpi-repetition').textContent = `Multiple clustered paths`;
            document.getElementById('kpi-repetition').style.color = 'var(--amber)';
        } else {
            document.getElementById('kpi-repetition').textContent = `Highly distinct operations`;
            document.getElementById('kpi-repetition').style.color = 'var(--sky)';
        }

        const tbody = document.querySelector('#results-table tbody');
        tbody.innerHTML = '';
        rows.forEach((r, i) => {
            const tr = document.createElement('tr');
            if (i === 0) tr.style.backgroundColor = 'rgba(197, 79, 54, 0.05)';
            
            tr.innerHTML = `
                <td>#${i + 1}</td>
                <td><strong>${r.TailNum}</strong><br><span style="color:var(--slate);font-size:0.8em">${r.Carrier}${r.FlightNum}</span></td>
                <td style="color:var(--red); font-weight:bold;">${r.Hops}</td>
                <td>${String(r.FlightDate ?? '').slice(0, 10)}</td>
            `;
            tbody.appendChild(tr);
        });

        const seqContainer = document.getElementById('route-sequences');
        seqContainer.innerHTML = '';
        rows.forEach((r, i) => {
            const div = document.createElement('div');
            div.style.marginBottom = '1rem';
            div.style.padding = '1rem';
            div.style.borderRadius = 'var(--radius-sm)';
            div.style.borderLeft = i === 0 ? '4px solid var(--red)' : '4px solid var(--sky)';
            div.style.background = 'var(--panel-alt)';
            div.innerHTML = `<strong style="color:var(--navy);">Rank ${i+1} (${r.Hops} legs)</strong><br><span style="color:var(--slate);">${r.Route}</span>`;
            seqContainer.appendChild(div);
        });

        const leadRoute = lead.Route;
        const sequenceMatches = [...leadRoute.matchAll(/([A-Z]{3})/g)].map(m => m[1]);
        const uniqueAirports = [...new Set(sequenceMatches)];
        
        const coords = await fetchCoordinates(token, uniqueAirports);
        
        renderMap(sequenceMatches, coords);
    }

    function renderMap(sequenceCodes, coordsMap) {
        if (!mapInstance) {
            mapInstance = L.map('map');
            L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                attribution: '&copy; OpenStreetMap contributors'
            }).addTo(mapInstance);
        } else {
            mapInstance.eachLayer(layer => {
                if (layer instanceof L.Marker || layer instanceof L.Polyline || layer instanceof L.CircleMarker) {
                    mapInstance.removeLayer(layer);
                }
            });
            // remove degraded overlay if it exists
            const existingOverlay = document.getElementById('map-degraded-overlay');
            if (existingOverlay) existingOverlay.remove();
        }

        const validPoints = [];
        let mapDegraded = false;
        
        sequenceCodes.forEach((code, index) => {
            if (coordsMap[code]) {
                const pt = [coordsMap[code].lat, coordsMap[code].lon];
                validPoints.push(pt);
                
                L.circleMarker(pt, {
                    radius: 7,
                    fillColor: 'var(--navy)',
                    color: '#ffffff',
                    weight: 2,
                    opacity: 1,
                    fillOpacity: 1
                }).addTo(mapInstance)
                  .bindTooltip(`<strong>${code}</strong> (Stop ${index+1})`, { direction: 'top' });
            } else {
                mapDegraded = true;
            }
        });

        if (validPoints.length > 1) {
            L.polyline(validPoints, {
                color: 'var(--red)',
                weight: 4,
                opacity: 0.8,
                dashArray: '5, 10',
                lineCap: 'round'
            }).addTo(mapInstance);
            
            setTimeout(() => {
                mapInstance.invalidateSize();
                mapInstance.fitBounds(L.polyline(validPoints).getBounds(), { padding: [50, 50] });
            }, 300);
        } else {
            mapDegraded = true;
            setTimeout(() => {
                mapInstance.invalidateSize();
                mapInstance.setView([39.8283, -98.5795], 4);
            }, 300);
        }

        if (mapDegraded) {
            const msg = document.createElement('div');
            msg.id = 'map-degraded-overlay';
            msg.style.position = 'absolute';
            msg.style.top = '10px';
            msg.style.left = '50px';
            msg.style.background = 'var(--panel)';
            msg.style.padding = '0.5rem 1rem';
            msg.style.borderRadius = 'var(--radius-sm)';
            msg.style.zIndex = '1000';
            msg.style.color = 'var(--amber)';
            msg.style.border = '1px solid var(--border)';
            msg.style.boxShadow = 'var(--shadow)';
            msg.innerHTML = '<strong>Map Degraded:</strong> Coordinates not fully available for all route stops.';
            document.getElementById('map').appendChild(msg);
        }
    }
</script>
</body>
</html>
```
