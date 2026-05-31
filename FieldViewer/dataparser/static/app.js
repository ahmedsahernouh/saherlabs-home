let currentJobId = null;
let pollTimer = null;
let currentBrowsePath = "";
let parserTodayIso = "";
let scannedWellRows = [];
const BASE_PATH = (() => {
  const p = window.location.pathname || "/";
  const idx = p.indexOf("/dataparser/");
  if (idx >= 0) return "/dataparser";
  return "";
})();

const el = (id) => document.getElementById(id);

function setStatus(text) {
  el("statusText").textContent = text;
}

function setSpinner(on) {
  const sp = el("spinner");
  if (on) sp.classList.remove("hidden");
  else sp.classList.add("hidden");
}

function setLog(text) {
  const node = el("logTail");
  node.textContent = text || "";
  node.scrollTop = node.scrollHeight;
}

function fmtErr(err) {
  if (!err) return "Unknown error";
  if (typeof err === "string") return err;
  if (err.error) return err.error;
  return JSON.stringify(err);
}

function isoToSlash(iso) {
  if (!iso) return "";
  const s = String(iso);
  return s.replaceAll("-", "/");
}

function clearQc() {
  const sec = el("qcSection");
  const meta = el("qcMeta");
  const gal = el("qcGallery");
  sec.classList.add("hidden");
  meta.textContent = "No QC images yet.";
  gal.innerHTML = "";
}

function renderQc(images, jobId) {
  const sec = el("qcSection");
  const meta = el("qcMeta");
  const gal = el("qcGallery");
  gal.innerHTML = "";
  if (!images || images.length === 0) {
    sec.classList.remove("hidden");
    meta.textContent = "No QC images generated for this run.";
    return;
  }
  sec.classList.remove("hidden");
  meta.textContent = `Showing ${images.length} QC image(s) for job ${jobId}.`;
  images.forEach((img) => {
    const item = document.createElement("div");
    item.className = "qc-item";
    const link = document.createElement("a");
    link.target = "_blank";
    link.rel = "noopener noreferrer";
    link.className = "qc-open";
    const node = document.createElement("img");
    node.loading = "lazy";
    const rel = String(img.path || "")
      .split("/")
      .map((x) => encodeURIComponent(x))
      .join("/");
    const imgUrl = `${BASE_PATH}/qc_image/${encodeURIComponent(jobId)}/${rel}`;
    node.src = imgUrl;
    node.alt = img.name || img.path;
    link.href = imgUrl;
    link.appendChild(node);
    const cap = document.createElement("div");
    cap.className = "qc-caption";
    const txt = document.createElement("span");
    txt.textContent = `${img.path} `;
    const openLink = document.createElement("a");
    openLink.className = "qc-open";
    openLink.target = "_blank";
    openLink.rel = "noopener noreferrer";
    openLink.href = imgUrl;
    openLink.textContent = "open full";
    cap.appendChild(txt);
    cap.appendChild(openLink);
    item.appendChild(link);
    item.appendChild(cap);
    gal.appendChild(item);
  });
}

async function loadQc(jobId) {
  try {
    const data = await api(`/qc/${encodeURIComponent(jobId)}`);
    renderQc(data.images || [], jobId);
  } catch (err) {
    const sec = el("qcSection");
    const meta = el("qcMeta");
    sec.classList.remove("hidden");
    meta.textContent = `QC preview failed: ${fmtErr(err)}`;
  }
}

async function api(url, opts = {}) {
  const full = `${BASE_PATH}${url}`;
  const res = await fetch(full, opts);
  let body = null;
  try {
    body = await res.json();
  } catch (_) {
    body = null;
  }
  if (!res.ok) {
    throw body || { error: `${res.status} ${res.statusText}` };
  }
  return body;
}

function setDateDefaults(todayIso) {
  parserTodayIso = todayIso || "";
  const minDate = el("minDate");
  const maxDate = el("maxDate");
  maxDate.value = todayIso;
  maxDate.max = todayIso;

  const d = new Date(todayIso);
  d.setMonth(d.getMonth() - 1);
  const yyyy = d.getFullYear();
  const mm = String(d.getMonth() + 1).padStart(2, "0");
  const dd = String(d.getDate()).padStart(2, "0");
  minDate.value = `${yyyy}-${mm}-${dd}`;
}

function buildDrives(drives) {
  const wrap = el("driveList");
  wrap.innerHTML = "";
  (drives || []).forEach((d) => {
    const chip = document.createElement("button");
    chip.type = "button";
    chip.className = "drive-chip";
    chip.textContent = d;
    chip.addEventListener("click", () => browse(d));
    wrap.appendChild(chip);
  });
}

function selectedWellsValues() {
  const sel = el("selectedWells");
  if (!sel) return [];
  return Array.from(sel.selectedOptions || []).map((o) => String(o.value || "").trim()).filter(Boolean);
}

function refreshWellSelectionSummary() {
  const node = el("wellSelectSummary");
  if (!node) return;
  const total = Array.isArray(scannedWellRows) ? scannedWellRows.length : 0;
  const selected = selectedWellsValues().length;
  if (total <= 0) {
    node.textContent = "Selected wells: ALL (all folders in input root)";
    return;
  }
  if (selected <= 0) {
    node.textContent = `Loaded wells: ${total} | Selected wells: ALL`;
    return;
  }
  node.textContent = `Loaded wells: ${total} | Selected wells: ${selected}`;
}

function renderWellOptions(rows, keepSelected = true) {
  const sel = el("selectedWells");
  if (!sel) return;
  const prev = keepSelected ? new Set(selectedWellsValues()) : new Set();
  sel.innerHTML = "";

  (rows || []).forEach((r) => {
    const folder = String(r.folder || "").trim();
    const uwi = String(r.uwi || "").trim();
    const csv = Number.parseInt(r.csv_count || 0, 10);
    const opt = document.createElement("option");
    // Use folder as value to match parser input root tree exactly.
    opt.value = folder || uwi;
    opt.textContent = `${uwi || folder}  [${folder}]  (${Number.isFinite(csv) ? csv : 0} csv)`;
    if (prev.has(opt.value)) opt.selected = true;
    sel.appendChild(opt);
  });
  refreshWellSelectionSummary();
}

async function loadWellsFromInputRoot() {
  const inputRoot = el("inputRoot").value.trim();
  if (!inputRoot) {
    alert("Input root is required before loading wells.");
    return;
  }
  try {
    const query = `?input_root=${encodeURIComponent(inputRoot)}`;
    const data = await api(`/well_folders${query}`);
    scannedWellRows = Array.isArray(data.wells) ? data.wells : [];
    renderWellOptions(scannedWellRows, false);
  } catch (err) {
    scannedWellRows = [];
    renderWellOptions([], false);
    alert(`Load wells failed: ${fmtErr(err)}`);
  }
}

async function browse(path = "") {
  try {
    const query = path ? `?path=${encodeURIComponent(path)}` : "";
    const data = await api(`/browse${query}`);
    currentBrowsePath = data.current || "";
    el("browsePath").value = currentBrowsePath;
    buildDrives(data.drives || []);

    const list = el("browseList");
    list.innerHTML = "";
    (data.subdirs || []).forEach((d) => {
      const item = document.createElement("div");
      item.className = "browse-item";
      item.textContent = d.name;
      item.title = d.path;
      item.addEventListener("dblclick", () => browse(d.path));
      item.addEventListener("click", () => {
        currentBrowsePath = d.path;
        el("browsePath").value = d.path;
      });
      list.appendChild(item);
    });

    el("browseUpBtn").disabled = !data.parent;
    el("browseUpBtn").dataset.parent = data.parent || "";
  } catch (err) {
    alert(`Browse failed: ${fmtErr(err)}`);
  }
}

function stopPolling() {
  if (pollTimer) {
    clearInterval(pollTimer);
    pollTimer = null;
  }
}

async function refreshStatus() {
  if (!currentJobId) return;
  try {
    const data = await api(`/status/${encodeURIComponent(currentJobId)}`);
    setLog(data.log_tail || "");
    const st = data.status || "unknown";
    if (st === "running" || st === "queued") {
      setStatus(`Status: ${st}`);
      setSpinner(true);
      el("downloadBtn").disabled = true;
      el("runBtn").disabled = true;
      return;
    }
    if (st === "done") {
      setStatus("Status: done");
      setSpinner(false);
      stopPolling();
      el("runBtn").disabled = false;
      el("downloadBtn").disabled = !data.download_ready;
      if (data.make_qc_plots) {
        loadQc(currentJobId);
      } else {
        clearQc();
      }
      return;
    }
    setStatus(`Status: ${st}${data.error ? ` (${data.error})` : ""}`);
    setSpinner(false);
    stopPolling();
    el("runBtn").disabled = false;
    el("downloadBtn").disabled = true;
  } catch (err) {
    const msg = fmtErr(err);
    if (String(msg).toLowerCase().includes("job_id not found")) {
      currentJobId = null;
      setStatus("Status: no active job (job id expired after restart). Run again.");
    } else {
      setStatus(`Status error: ${msg}`);
    }
    setSpinner(false);
    stopPolling();
    el("runBtn").disabled = false;
    el("downloadBtn").disabled = true;
  }
}

async function runJob() {
  const inputRoot = el("inputRoot").value.trim();
  const minDate = el("minDate").value;
  const maxDate = el("maxDate").value;
  const jobNameInput = (el("jobName")?.value || "").trim();
  const makeReport = el("makeReport").checked;
  const makeQc = el("makeQc").checked;
  const zipOutputs = el("zipOutputs").checked;
  const selectedWells = selectedWellsValues();

  if (!inputRoot) {
    alert("Input root is required.");
    return;
  }
  if (!minDate) {
    alert("Min Date is required.");
    return;
  }

  el("downloadBtn").disabled = true;
  clearQc();
  setLog("");
  setStatus("Starting...");
  setSpinner(true);
  el("runBtn").disabled = true;

  try {
    const today = parserTodayIso || new Date().toISOString().slice(0, 10);
    const defaultJobName = `${today.replaceAll("-", "")}_${minDate.replaceAll("-", "")}_${(maxDate || minDate).replaceAll("-", "")}`;
    const body = {
      input_root: inputRoot,
      min_date: minDate,
      max_date: maxDate || undefined,
      job_name: jobNameInput || defaultJobName,
      make_report: makeReport,
      make_qc_plots: makeQc,
      zip_outputs: zipOutputs,
      selected_wells: selectedWells,
    };

    const data = await api("/run", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(body),
    });

    currentJobId = data.job_id;
    setStatus(
      `Status: ${data.status} (job ${currentJobId}) | Name: ${body.job_name} | Date range: ${isoToSlash(minDate)} .. ${isoToSlash(maxDate || minDate)} | Wells: ${selectedWells.length > 0 ? selectedWells.length : "ALL"}`
    );
    stopPolling();
    pollTimer = setInterval(refreshStatus, 1200);
    refreshStatus();
  } catch (err) {
    setSpinner(false);
    setStatus(`Start failed: ${fmtErr(err)}`);
    el("runBtn").disabled = false;
  }
}

function downloadResults() {
  if (!currentJobId) return;
  window.location.href = `${BASE_PATH}/download/${encodeURIComponent(currentJobId)}`;
}

function init() {
  el("browseBtn").addEventListener("click", async () => {
    const panel = el("browserPanel");
    panel.classList.toggle("hidden");
    if (!panel.classList.contains("hidden")) {
      const p = el("inputRoot").value.trim();
      await browse(p || "");
    }
  });

  el("browseGoBtn").addEventListener("click", () => {
    const p = el("browsePath").value.trim();
    browse(p);
  });

  el("browseUpBtn").addEventListener("click", () => {
    const p = el("browseUpBtn").dataset.parent || "";
    if (p) browse(p);
  });

  el("selectCurrentBtn").addEventListener("click", () => {
    const p = el("browsePath").value.trim();
    if (p) {
      el("inputRoot").value = p;
      currentBrowsePath = p;
    }
  });

  el("loadWellsBtn").addEventListener("click", loadWellsFromInputRoot);
  el("selectAllWellsBtn").addEventListener("click", () => {
    const sel = el("selectedWells");
    if (!sel) return;
    Array.from(sel.options || []).forEach((o) => { o.selected = true; });
    refreshWellSelectionSummary();
  });
  el("clearWellsBtn").addEventListener("click", () => {
    const sel = el("selectedWells");
    if (!sel) return;
    Array.from(sel.options || []).forEach((o) => { o.selected = false; });
    refreshWellSelectionSummary();
  });
  el("selectedWells").addEventListener("change", refreshWellSelectionSummary);
  el("inputRoot").addEventListener("change", () => {
    scannedWellRows = [];
    renderWellOptions([], false);
  });

  el("runBtn").addEventListener("click", runJob);
  el("downloadBtn").addEventListener("click", downloadResults);

  api("/meta")
    .then((data) => {
      setDateDefaults(data.today);
      setStatus("Idle");
      clearQc();
      renderWellOptions([], false);
    })
    .catch((err) => {
      setStatus(`Meta load failed: ${fmtErr(err)}`);
    });
}

document.addEventListener("DOMContentLoaded", init);
