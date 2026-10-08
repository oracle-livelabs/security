const csrfToken = document.querySelector("meta[name='csrf-token']")?.content;
const requestHeaders = {"Content-Type": "application/json", "X-CSRFToken": csrfToken};
const error = document.querySelector("#error");
let authorizationState = {
  customers: {available: false, columns: {}},
  orderHistory: {available: false, columns: {}}
};
let currentAuthorization = authorizationState.customers;
let authorizationTrigger = null;
let aiPromptMode = "protected";

function showError(message) {
  if (error) error.textContent = message || "";
}

async function copyToClipboard(text, button) {
  const original = button.textContent;
  try {
    if (navigator.clipboard?.writeText) {
      await navigator.clipboard.writeText(text);
    } else {
      // The workshop may use HTTP, where the Clipboard API is unavailable.
      const input = document.createElement("textarea");
      input.value = text;
      input.className = "visually-hidden";
      document.body.append(input);
      input.select();
      try {
        if (!document.execCommand("copy")) throw new Error("Clipboard unavailable");
      } finally {
        input.remove();
        button.focus();
      }
    }
    button.textContent = "Copied";
  } catch (_) {
    button.textContent = "Copy manually";
  }
  setTimeout(() => { button.textContent = original; }, 2000);
}

function renderErrorCard(error) {
  const card = document.querySelector("#error-card");
  if (!card) return;
  card.replaceChildren();
  card.hidden = !error;
  if (!error) return;
  if (typeof error === "string") {
    card.textContent = error;
    return;
  }
  // Exception metadata is text, never HTML. Links are restricted to Oracle docs.
  const appendText = (parent, tag, text, className = "") => {
    const element = document.createElement(tag);
    element.textContent = text;
    element.className = className;
    parent.append(element);
    return element;
  };
  appendText(card, "p", error.summary, "error-summary");
  if (error.next_step) appendText(card, "p", error.next_step, "error-next-step");
  if (error.reference) appendText(card, "p", `Diagnostic reference: ${error.reference}`, "error-reference");

  const details = document.createElement("details");
  details.className = "error-details";
  appendText(details, "summary", "Troubleshooting");
  card.append(details);
  appendText(details, "h4", "Diagnostic details");
  const diagnostics = error.diagnostics || [];
  const list = document.createElement("dl");
  list.className = "error-diagnostics";
  for (const item of diagnostics) {
    appendText(list, "dt", item.label);
    appendText(list, "dd", item.value);
  }
  details.append(list);
  const copyDetails = appendText(details, "button", "Copy diagnostic details", "copy-button");
  copyDetails.type = "button";
  copyDetails.addEventListener("click", () => copyToClipboard(
    [error.summary, ...diagnostics.map((item) => `${item.label}: ${item.value}`)].join("\n"), copyDetails
  ));

  appendText(details, "h4", "Use a JupyterLab Terminal");
  const steps = document.createElement("ol");
  for (const step of error.terminal_steps || []) appendText(steps, "li", step);
  details.append(steps);
  for (const command of error.commands || []) {
    const block = document.createElement("div");
    block.className = "error-command";
    appendText(block, "span", command.label, "error-command-label");
    const row = document.createElement("div");
    row.className = "error-command-row";
    const pre = document.createElement("pre");
    appendText(pre, "code", command.command);
    row.append(pre);
    const copy = appendText(row, "button", "Copy", "copy-button");
    copy.type = "button";
    copy.setAttribute("aria-label", `Copy command: ${command.label}`);
    copy.addEventListener("click", () => copyToClipboard(command.command, copy));
    block.append(row);
    details.append(block);
  }
  if (error.note) appendText(details, "p", error.note, "error-note");
  appendText(details, "h4", "Oracle logging guidance");
  if (error.logging_note) appendText(details, "p", error.logging_note, "error-note");
  const links = document.createElement("ul");
  for (const link of error.links || []) {
    let url;
    try { url = new URL(link.url); } catch (_) { continue; }
    if (url.origin !== "https://docs.oracle.com" || url.username || url.password) continue;
    const item = document.createElement("li");
    const anchor = appendText(item, "a", link.label);
    anchor.href = url.href;
    anchor.target = "_blank";
    anchor.rel = "noopener noreferrer";
    links.append(item);
  }
  details.append(links);
}

function formatNumber(value) {
  return new Intl.NumberFormat("en-US").format(value);
}

async function jsonRequest(url, options, {redirectOn401 = true} = {}) {
  const response = await fetch(url, options);
  let payload = {};
  try {
    payload = await response.json();
  } catch (_) {
    payload = {error: "The server returned an unexpected response."};
  }
  if (response.status === 401 && redirectOn401) window.location.assign("/");
  return {response, payload};
}

const login = document.querySelector("#login");
const loginForm = document.querySelector("#login-form");
if (login && loginForm) {
  loginForm.addEventListener("submit", async (event) => {
    event.preventDefault();
    showError("");
    login.disabled = true;
    try {
      const {response, payload} = await jsonRequest("/api/login", {
        method: "POST", headers: requestHeaders,
        body: JSON.stringify({persona: document.querySelector("#persona").value, password: document.querySelector("#password").value})
      }, {redirectOn401: false});
      if (!response.ok) {
        showError(payload.error || "Database sign-in failed");
        login.disabled = false;
        return;
      }
      window.location.assign("/query");
    } catch (_) {
      showError("Unable to sign in. Please try again.");
      login.disabled = false;
    }
  });
}

const logout = document.querySelector("#logout");
if (logout) {
  logout.addEventListener("click", async (event) => {
    event.preventDefault();
    logout.disabled = true;
    document.cookie = "hol_tour_seen=; path=/; max-age=0; samesite=Lax";
    document.cookie = "hol_deebee_greeted=; path=/; max-age=0; samesite=Lax";
    try {
      await fetch("/api/logout", {
        method: "POST", headers: requestHeaders, cache: "no-store", credentials: "same-origin"
      });
    } finally {
      // Replace the protected page so Back cannot restore it from history.
      window.location.replace("/");
    }
  });
}

const load = document.querySelector("#load");
if (load) {
  load.addEventListener("click", async () => {
    showError("");
    const status = document.querySelector("#load-status");
    load.disabled = true;
    load.textContent = "Loading customer accounts…";
    status.textContent = "Loading customer accounts…";
    try {
      const {response, payload} = await jsonRequest("/api/customers", {method: "POST", headers: requestHeaders});
      if (!response.ok) {
        showError(payload.error || "Unable to load customer accounts.");
        return;
      }
      renderSecurityContext(payload.context, payload.row_count);
      authorizationState.customers = payload.authorization || {available: false, columns: {}};
      currentAuthorization = authorizationState.customers;
      renderCustomers(payload.rows, currentAuthorization);
    } catch (_) {
      showError("Unable to load customer accounts. Please try again.");
    } finally {
      load.disabled = false;
      load.textContent = "Customer Report";
      status.textContent = "";
    }
  });
}

const loadOrderHistory = document.querySelector("#load-order-history");
if (loadOrderHistory) {
  loadOrderHistory.addEventListener("click", async () => {
    const result = document.querySelector("#order-history-result");
    const status = document.querySelector("#order-history-status");
    result.replaceChildren(makeMessage("Loading…", "muted"));
    loadOrderHistory.disabled = true;
    loadOrderHistory.textContent = "Loading Iceberg…";
    status.textContent = "Loading Iceberg…";
    try {
      const {response, payload} = await jsonRequest("/api/order-history", {method: "POST", headers: requestHeaders});
      if (!response.ok) {
        renderOrderHistoryMessage(payload.error || "Iceberg is unavailable.", "warning-banner");
      } else if (Array.isArray(payload.rows)) {
        authorizationState.orderHistory = payload.authorization || {available: false, columns: {}};
        renderOrderHistoryTable(payload.rows || [], payload.context, payload.row_count, authorizationState.orderHistory);
      } else {
        renderOrderHistoryMessage(payload.error || "Iceberg is unavailable.", "warning-banner");
      }
    } catch (_) {
      renderOrderHistoryMessage("Could not contact the server.", "warning-banner");
    } finally {
      loadOrderHistory.disabled = false;
      loadOrderHistory.textContent = "Iceberg Report";
      status.textContent = "";
    }
  });
}

function makeMessage(message, className = "") {
  const paragraph = document.createElement("p");
  paragraph.className = className;
  paragraph.textContent = message;
  return paragraph;
}

function renderOrderHistoryMessage(message, className) {
  const result = document.querySelector("#order-history-result");
  const banner = document.createElement("div");
  banner.className = className;
  banner.textContent = message;
  result.replaceChildren(banner);
}

function renderOrderHistoryTable(rows, contextData, rowCount, authorization) {
  const result = document.querySelector("#order-history-result");
  const context = document.querySelector("#order-history-context");
  const details = document.querySelector("#order-history-context-details");
  details.replaceChildren();
  appendContextItem(details, "End User", contextData?.end_user);
  appendContextItem(details, "Active Data Roles", contextData?.data_role);
  appendContextItem(details, "Rows Returned by Oracle", rowCount ?? rows.length);
  context.hidden = false;
  if (!rows.length) {
    result.replaceChildren(makeMessage("No Iceberg rows are authorized for this account.", "muted"));
    return;
  }
  const columns = Object.keys(rows[0]);
  const columnLabels = {order_id: "Order ID", customer_id: "Customer ID"};
  const table = document.createElement("table");
  table.className = "results-table";
  const head = document.createElement("thead");
  const headRow = document.createElement("tr");
  for (const column of columns) {
    const cell = document.createElement("th");
    cell.textContent = columnLabels[column] || column.split("_").map((word) => word.charAt(0).toUpperCase() + word.slice(1)).join(" ");
    headRow.append(cell);
  }
  head.append(headRow);
  const body = document.createElement("tbody");
  for (const row of rows) {
    const tableRow = document.createElement("tr");
    for (const column of columns) {
      const numericColumn = ["order_id", "customer_id", "amount"].includes(column);
      const formatValue = column === "amount" ? formatNumber : (value) => value;
      tableRow.append(makeDataCell(row[column], column, authorization, numericColumn ? "number" : "", formatValue, row));
    }
    body.append(tableRow);
  }
  table.append(head, body);
  const wrap = document.createElement("div");
  wrap.className = "table-wrap";
  wrap.append(table);
  result.replaceChildren(wrap);
}

const loadVibeReport = document.querySelector("#load-vibe-report");
if (loadVibeReport) {
  loadVibeReport.addEventListener("click", async () => {
    const result = document.querySelector("#vibe-report-result");
    const status = document.querySelector("#vibe-report-status");
    const reportId = loadVibeReport.dataset.reportId;
    loadVibeReport.disabled = true;
    loadVibeReport.textContent = "Running statement…";
    status.textContent = "Sending the generated SQL statement to Oracle…";
    result.replaceChildren(makeMessage("Loading…", "muted"));
    try {
      const {response, payload} = await jsonRequest(`/api/vibe-report/${encodeURIComponent(reportId)}`, {method: "POST", headers: requestHeaders});
      if (!response.ok) {
        result.replaceChildren(makeMessage(payload.error || "This statement is unavailable.", "warning-banner"));
        return;
      }
      if (["INSERT", "UPDATE", "DELETE"].includes(payload.operation)) {
        renderSecurityContext(payload.context, payload.affected_rows, "Rows changed by Oracle");
        const verb = payload.operation === "DELETE" ? "deleted" : payload.operation === "INSERT" ? "inserted" : "updated";
        result.replaceChildren(makeMessage(`Oracle authorized and committed the ${payload.operation} statement. ${payload.affected_rows} row${payload.affected_rows === 1 ? " was" : "s were"} ${verb}.`, "success-banner"));
        return;
      }
      renderSecurityContext(payload.context, payload.row_count);
      renderDynamicReportTable(result, payload.rows || []);
      if (payload.displayed_count < payload.row_count) {
        result.prepend(makeMessage(`Showing the first ${payload.displayed_count} of ${payload.row_count} rows returned by Oracle.`, "muted"));
      }
    } catch (_) {
      result.replaceChildren(makeMessage("Could not contact the server.", "warning-banner"));
    } finally {
      loadVibeReport.disabled = false;
      loadVibeReport.textContent = "Run statement";
      status.textContent = "";
    }
  });
}

function renderDynamicReportTable(target, rows) {
  if (!rows.length) {
    target.replaceChildren(makeMessage("Oracle returned no rows for this database identity.", "muted"));
    return;
  }
  const columns = Object.keys(rows[0]);
  const table = document.createElement("table");
  table.className = "results-table";
  const head = document.createElement("thead");
  const headRow = document.createElement("tr");
  for (const column of columns) {
    const cell = document.createElement("th");
    cell.textContent = column.split("_").map((word) => word.charAt(0).toUpperCase() + word.slice(1)).join(" ");
    headRow.append(cell);
  }
  head.append(headRow);
  const body = document.createElement("tbody");
  for (const row of rows) {
    const tableRow = document.createElement("tr");
    for (const column of columns) {
      tableRow.append(row[column] == null
        ? makeUnauthorizedCell(column, null)
        : makeCell(row[column]));
    }
    body.append(tableRow);
  }
  table.append(head, body);
  const wrap = document.createElement("div");
  wrap.className = "table-wrap";
  wrap.append(table);
  target.replaceChildren(wrap);
}

function appendContextItem(container, label, value) {
  const term = document.createElement("dt");
  term.textContent = label;
  const description = document.createElement("dd");
  description.textContent = String(value ?? "Not available");
  container.append(term, description);
}

function renderSecurityContext(context, rowCount, countLabel = "Rows Returned by Oracle") {
  const panel = document.querySelector("#security-context");
  const container = document.querySelector("#context");
  container.replaceChildren();
  appendContextItem(container, "End User", context?.end_user);
  appendContextItem(container, "Active Data Roles", context?.data_role);
  appendContextItem(container, countLabel, rowCount);
  panel.hidden = false;
}

function appendInsightInline(container, text) {
  const tokenPattern = /(\*\*[^*]+\*\*|`[^`]+`|\*[^*\n]+\*)/g;
  let cursor = 0;
  for (const match of text.matchAll(tokenPattern)) {
    const token = match[0];
    const index = match.index ?? 0;
    if (index > cursor) container.append(document.createTextNode(text.slice(cursor, index)));
    const element = document.createElement(token.startsWith("`") ? "code" : token.startsWith("**") ? "strong" : "em");
    element.textContent = token.replace(/^\*\*?|\*\*?$|^`|`$/g, "");
    container.append(element);
    cursor = index + token.length;
  }
  if (cursor < text.length) container.append(document.createTextNode(text.slice(cursor)));
}

function parseInsightCustomerRecord(line) {
  const source = line.replace(/^\s*[*-]\s+/, "").trim();
  const fields = [];
  const markers = [...source.matchAll(/\*\*([^*]+?)\*\*\s*/g)];
  for (let index = 0; index < markers.length; index += 1) {
    const marker = markers[index];
    const valueStart = (marker.index ?? 0) + marker[0].length;
    const valueEnd = index + 1 < markers.length ? markers[index + 1].index ?? source.length : source.length;
    const label = marker[1].replace(/:\s*$/, "").trim();
    const value = source.slice(valueStart, valueEnd).replace(/,\s*$/, "").trim();
    fields.push({label, value});
  }
  return fields.length >= 3 && fields.some(({label}) => label.toLowerCase() === "customer id") ? fields : null;
}

function makeInsightCustomerTable(records) {
  const preferredOrder = [
    "Customer ID", "Customer Name", "Region", "Sales Rep", "Manager ID",
    "Revenue", "Credit Limit", "Sensitive Identifier"
  ];
  const labels = [];
  for (const record of records) {
    for (const {label} of record) {
      if (!labels.some((item) => item.toLowerCase() === label.toLowerCase())) labels.push(label);
    }
  }
  labels.sort((left, right) => {
    const leftIndex = preferredOrder.findIndex((item) => item.toLowerCase() === left.toLowerCase());
    const rightIndex = preferredOrder.findIndex((item) => item.toLowerCase() === right.toLowerCase());
    return (leftIndex < 0 ? preferredOrder.length : leftIndex) - (rightIndex < 0 ? preferredOrder.length : rightIndex);
  });
  const table = document.createElement("table");
  table.className = "results-table insight-table";
  const caption = document.createElement("caption");
  caption.className = "visually-hidden";
  caption.textContent = "Customer records returned by Oracle";
  const head = document.createElement("thead");
  const headRow = document.createElement("tr");
  for (const label of labels) {
    const cell = document.createElement("th");
    cell.scope = "col";
    cell.textContent = label;
    headRow.append(cell);
  }
  head.append(headRow);
  const body = document.createElement("tbody");
  for (const record of records) {
    const values = new Map(record.map(({label, value}) => [label.toLowerCase(), value]));
    const row = document.createElement("tr");
    for (const label of labels) {
      const cell = document.createElement("td");
      cell.textContent = values.get(label.toLowerCase()) || "Not available";
      row.append(cell);
    }
    body.append(row);
  }
  table.append(caption, head, body);
  const wrap = document.createElement("div");
  wrap.className = "table-wrap insight-table-wrap";
  wrap.append(table);
  return wrap;
}

function renderInsightAnswer(answer) {
  const target = document.querySelector("#ai-answer");
  target.replaceChildren();
  const lines = String(answer || "").split(/\r?\n/);
  let records = [];
  let paragraphLines = [];
  let bulletItems = [];

  const flushRecords = () => {
    if (records.length) target.append(makeInsightCustomerTable(records));
    records = [];
  };
  const flushParagraph = () => {
    if (!paragraphLines.length) return;
    const paragraph = document.createElement("p");
    appendInsightInline(paragraph, paragraphLines.join(" "));
    target.append(paragraph);
    paragraphLines = [];
  };
  const flushBullets = () => {
    if (!bulletItems.length) return;
    const list = document.createElement("ul");
    for (const item of bulletItems) {
      const listItem = document.createElement("li");
      appendInsightInline(listItem, item);
      list.append(listItem);
    }
    target.append(list);
    bulletItems = [];
  };

  for (const rawLine of lines) {
    const line = rawLine.trim();
    const record = line ? parseInsightCustomerRecord(line) : null;
    if (record) {
      flushParagraph();
      flushBullets();
      records.push(record);
      continue;
    }
    if (records.length) flushRecords();
    if (!line) {
      flushParagraph();
      flushBullets();
      continue;
    }
    const heading = line.match(/^#{1,3}\s+(.+)$/);
    if (heading) {
      flushParagraph();
      flushBullets();
      const title = document.createElement("h4");
      appendInsightInline(title, heading[1]);
      target.append(title);
      continue;
    }
    const bullet = line.match(/^(?:[*-]|\d+[.)])\s+(.+)$/);
    if (bullet) {
      flushParagraph();
      bulletItems.push(bullet[1]);
      continue;
    }
    flushBullets();
    paragraphLines.push(line);
  }
  flushRecords();
  flushParagraph();
  flushBullets();
}

function renderAiExchange(question, payload, promptMode = "protected") {
  const panel = document.querySelector("#ai-exchange");
  if (!panel) return;
  const exchange = payload.ai_exchange || {};
  const setText = (selector, text) => {
    const element = panel.querySelector(selector);
    if (element) element.textContent = text;
  };
  const shorten = (text, limit = 160) => {
    const value = String(text || "").replace(/\s+/g, " ").trim();
    return value.length > limit ? `${value.slice(0, limit)}…` : value;
  };
  const writeJson = (selector, value) => {
    const target = panel.querySelector(selector);
    if (target) target.textContent = JSON.stringify(value ?? {}, null, 2);
  };
  writeJson("#ai-browser-request", {method: "POST", path: "/api/ai", body: {question, prompt_mode: promptMode}});
  setText("#ai-browser-request-summary", `You asked: "${shorten(question)}"`);

  writeJson("#ai-oci-request", exchange.request);
  const requestMessage = exchange.request?.payload?.messages?.find((message) => message.role === "USER");
  const requestText = requestMessage?.content?.find((content) => content.type === "TEXT")?.text || "";
  const authorizedRowCount = exchange.request?.authorized_row_count;
  const rowLabel = Number.isFinite(authorizedRowCount) ? `${authorizedRowCount} Oracle-authorized customer rows` : "Oracle-authorized customer rows";
  const systemText = requestText.split("\n\nUser request:", 1)[0].trim();
  setText(
    "#ai-oci-request-summary",
    systemText ? `${shorten(systemText, 140)} ${rowLabel} attached.` : "Authorized rows and your question were sent to OCI GenAI."
  );

  writeJson("#ai-oci-response", exchange.response);
  const modelAnswer = exchange.response?.payload?.message?.content?.find((content) => content.type === "TEXT")?.text || "(see raw payload)";
  setText("#ai-oci-response-summary", `OCI GenAI answered: "${shorten(modelAnswer)}"`);

  const toolTrace = exchange.response?.payload?.tool_calls || [];
  const toolTracePanel = panel.querySelector("#ai-tool-trace");
  if (toolTracePanel) toolTracePanel.hidden = toolTrace.length === 0;
  if (toolTrace.length) {
    const summary = toolTrace.map((call) => {
      const result = call.result || {};
      const oracleError = result.oracle_error ? ` (${result.oracle_error})` : "";
      return `${call.name || "database tool"} as ${result.executed_as || "current end user"} → ${result.status || "unknown"}${oracleError}`;
    }).join("\n");
    setText("#ai-tool-trace-content", `${summary}\n\n${JSON.stringify(toolTrace, null, 2)}`);
  } else {
    setText("#ai-tool-trace-content", "");
  }

  writeJson("#ai-browser-response", {
    answer: payload.answer,
    context: payload.context,
    row_count: payload.row_count,
  });
  setText("#ai-browser-response-summary", "Same answer, unchanged, passed back to your browser.");
  const details = panel.querySelector("details");
  if (details) details.open = false;
  panel.hidden = false;
}

const aiForm = document.querySelector("#ai-form");
if (aiForm) {
  aiForm.addEventListener("submit", async (event) => {
    event.preventDefault();
    const ask = document.querySelector("#ask-ai");
    const status = document.querySelector("#ai-status");
    const question = document.querySelector("#ai-question").value.trim();
    const promptMode = aiPromptMode;
    renderErrorCard(null);
    if (!question) {
      renderErrorCard("Enter a question for Customer Insights.");
      return;
    }
    document.querySelector("#ai-result").hidden = true;
    document.querySelector("#security-context").hidden = true;
    ask.disabled = true;
    ask.textContent = "Generating insights…";
    status.textContent = "Loading Oracle-authorized customer data…";
    try {
      const {response, payload} = await jsonRequest("/api/ai", {
        method: "POST", headers: requestHeaders, body: JSON.stringify({question, prompt_mode: promptMode})
      });
      if (!response.ok) {
        renderErrorCard(payload.error || "Customer Insights request failed.");
        return;
      }
      renderInsightAnswer(payload.answer);
      renderAiExchange(question, payload, promptMode);
      document.querySelector("#ai-result").hidden = false;
      renderSecurityContext(payload.context, payload.row_count);
    } catch (_) {
      renderErrorCard("Could not contact the Customer Sales App. Please try again.");
    } finally {
      ask.disabled = false;
      ask.textContent = "Generate Insights";
      status.textContent = "";
    }
  });
}

for (const prompt of document.querySelectorAll("[data-insight-question]")) {
  prompt.addEventListener("click", () => {
    const question = document.querySelector("#ai-question");
    if (!question) return;
    question.value = prompt.dataset.insightQuestion || "";
    aiPromptMode = prompt.dataset.insightMode === "red-team" ? "red-team" : "protected";
    renderErrorCard(null);
    question.focus();
  });
}

const aiQuestion = document.querySelector("#ai-question");
if (aiQuestion) aiQuestion.addEventListener("input", () => { aiPromptMode = "protected"; });

function makeCell(value, className = "") {
  const cell = document.createElement("td");
  if (className) cell.className = className;
  cell.textContent = value;
  return cell;
}

function humanizeColumn(column) {
  return String(column || "column")
    .split("_")
    .map((word) => word.charAt(0).toUpperCase() + word.slice(1))
    .join(" ");
}

function grantName(grant) {
  return grant?.grant_name || grant?.name || "the applicable data grant";
}

function grantPageLabel(grant) {
  return grant?.page_label || "Data Grants";
}

function grantCoversColumn(grant, column) {
  const normalizedColumn = String(column || "").toUpperCase();
  const columns = (grant?.columns || []).map((item) => String(item).toUpperCase());
  if (columns.length) return columns.includes(normalizedColumn);
  const excludedColumns = (grant?.excluded_columns || []).map((item) => String(item).toUpperCase());
  return !excludedColumns.includes(normalizedColumn);
}

function authorizationForCell(row, column, authorization) {
  const columnDetails = authorization?.available ? authorization.columns?.[column] : null;
  const rowKey = authorization?.row_key;
  const rowGrants = rowKey && row
    ? authorization?.row_grants?.[String(row[rowKey])] || []
    : [];
  if (!rowGrants.length) return columnDetails;

  if (rowGrants.some((grant) => grantCoversColumn(grant, column))) return columnDetails;
  const deniedGrant = rowGrants.find((grant) => !grantCoversColumn(grant, column));
  if (!deniedGrant) return columnDetails;
  const otherGrant = (columnDetails?.other_grants || []).find(
    (grant) => grantName(grant) !== grantName(deniedGrant)
  );
  return {...columnDetails, authorized: false, row_grant: deniedGrant, other_grant: otherGrant};
}

function closeAuthorizationPopover(restoreFocus = true) {
  const popover = document.querySelector("#authorization-popover");
  if (popover) {
    popover.hidden = true;
    popover.replaceChildren();
  }
  if (authorizationTrigger) {
    authorizationTrigger.setAttribute("aria-expanded", "false");
    if (restoreFocus) authorizationTrigger.focus();
  }
  authorizationTrigger = null;
}

function showAuthorizationPopover(trigger, column, details) {
  const popover = document.querySelector("#authorization-popover");
  if (!popover) return;
  closeAuthorizationPopover(false);
  authorizationTrigger = trigger;
  trigger.setAttribute("aria-expanded", "true");

  const heading = document.createElement("div");
  heading.className = "authorization-popover-heading";
  const title = document.createElement("h3");
  title.id = "authorization-popover-title";
  title.textContent = `Why ${humanizeColumn(column)} is not authorized`;
  const close = document.createElement("button");
  close.type = "button";
  close.className = "authorization-popover-close";
  close.setAttribute("aria-label", "Close authorization explanation");
  close.textContent = "×";
  close.addEventListener("click", () => closeAuthorizationPopover());
  heading.append(title, close);

  const explanation = document.createElement("p");
  const columnLabel = humanizeColumn(column);
  if (column === "manager_id") {
    explanation.textContent = "Manager ID is a join column the manager rule uses internally. No data grant includes it, and none needs to.";
  } else if (details?.row_grant) {
    const grant = details.row_grant;
    const firstLine = document.createElement("p");
    const columnName = document.createElement("strong");
    columnName.textContent = columnLabel;
    firstLine.append(columnName, document.createTextNode(" isn't in this row's grant."));

    const secondLine = document.createElement("p");
    const rowGrant = document.createElement("strong");
    rowGrant.textContent = grantName(grant);
    const excludedColumn = document.createElement("strong");
    excludedColumn.textContent = columnLabel;
    const page = document.createElement("strong");
    page.textContent = grantPageLabel(grant);
    secondLine.append(
      document.createTextNode("You see this row through "),
      rowGrant,
      document.createTextNode(", and that grant's SELECT list leaves out "),
      excludedColumn,
      document.createTextNode(". You excluded it on the "),
      page,
      document.createTextNode(" page.")
    );

    popover.append(heading, firstLine, secondLine);
    if (details.other_grant) {
      const otherLine = document.createElement("p");
      const otherGrant = document.createElement("strong");
      otherGrant.textContent = grantName(details.other_grant);
      const otherColumn = document.createElement("strong");
      otherColumn.textContent = columnLabel;
      otherLine.append(
        document.createTextNode("Other rows may show "),
        otherColumn,
        document.createTextNode(" because they reach you through "),
        otherGrant,
        document.createTextNode(", which includes it.")
      );
      popover.append(otherLine);
    }
  } else {
    const reason = details?.reasons?.[0];
    const reasonGrant = reason ? document.createElement("strong") : null;
    if (reasonGrant) {
      reasonGrant.textContent = grantName(reason);
      explanation.append(
        document.createTextNode(columnLabel + " is not included in "),
        reasonGrant,
        document.createTextNode("'s SELECT list.")
      );
    } else {
      explanation.textContent = `${columnLabel} is not included in an applicable SELECT data grant.`;
    }
    popover.append(heading, explanation);
  }
  popover.hidden = false;

  const triggerBox = trigger.getBoundingClientRect();
  const popoverBox = popover.getBoundingClientRect();
  const left = Math.min(Math.max(12, triggerBox.left), window.innerWidth - popoverBox.width - 12);
  const top = triggerBox.bottom + popoverBox.height + 12 <= window.innerHeight
    ? triggerBox.bottom + 8
    : Math.max(12, triggerBox.top - popoverBox.height - 8);
  popover.style.left = `${left}px`;
  popover.style.top = `${top}px`;
  close.focus();
}

function makeUnauthorizedCell(column, details, className = "") {
  const cell = document.createElement("td");
  if (className) cell.className = className;
  const trigger = document.createElement("span");
  trigger.className = "cell-denied";
  trigger.textContent = "—";
  const excludedGrant = details?.row_grant || details?.reasons?.[0];
  const grantSuffix = excludedGrant ? ` (${grantName(excludedGrant)})` : "";
  trigger.title = `Not authorized: this column is excluded by the data grant for your current role${grantSuffix}`;
  trigger.setAttribute("role", "button");
  trigger.tabIndex = 0;
  trigger.setAttribute("aria-label", `Why is ${humanizeColumn(column)} not authorized?`);
  trigger.setAttribute("aria-controls", "authorization-popover");
  trigger.setAttribute("aria-expanded", "false");
  trigger.addEventListener("click", () => showAuthorizationPopover(trigger, column, details));
  trigger.addEventListener("keydown", (event) => {
    if (event.key === "Enter" || event.key === " ") {
      event.preventDefault();
      showAuthorizationPopover(trigger, column, details);
    }
  });
  cell.append(trigger);
  return cell;
}

function makeDataCell(value, column, authorization, className = "", formatValue = (item) => item, row = null) {
  if (value == null) {
    const details = authorizationForCell(row, column, authorization);
    if (details?.authorized === false) return makeUnauthorizedCell(column, details, className);
    return makeCell("—", className);
  }
  return makeCell(formatValue(value), className);
}

document.addEventListener("click", (event) => {
  if (!event.target.closest(".cell-denied, #authorization-popover")) closeAuthorizationPopover(false);
});

document.addEventListener("keydown", (event) => {
  if (event.key === "Escape" && authorizationTrigger) closeAuthorizationPopover();
});

let currentRows = [];
let currentSort = {key: null, direction: "asc"};

function sortRows(rows, key, type, direction) {
  const sorted = [...rows];
  sorted.sort((a, b) => {
    const aVal = a[key];
    const bVal = b[key];
    if (aVal == null && bVal == null) return 0;
    if (aVal == null) return 1;
    if (bVal == null) return -1;
    if (type === "number") return direction === "asc" ? aVal - bVal : bVal - aVal;
    return direction === "asc"
      ? String(aVal).localeCompare(String(bVal))
      : String(bVal).localeCompare(String(aVal));
  });
  return sorted;
}

function renderCustomers(rows, authorization = currentAuthorization) {
  currentRows = rows || [];
  const results = document.querySelector("#results");
  const accountCount = document.querySelector("#account-count");
  accountCount.textContent = `${rows?.length || 0} Customer Account${rows?.length === 1 ? "" : "s"}`;
  results.replaceChildren();
  if (!rows?.length) {
    const row = document.createElement("tr");
    row.className = "empty";
    const cell = document.createElement("td");
    cell.colSpan = 7;
    cell.textContent = "No customers were returned.";
    row.append(cell);
    results.append(row);
    return;
  }
  for (const customer of rows) {
    const row = document.createElement("tr");
    row.append(
      makeDataCell(customer.customer_id, "customer_id", authorization, "number", formatNumber, customer),
      makeDataCell(customer.customer_name, "customer_name", authorization, "", (value) => value, customer),
      makeDataCell(customer.sales_rep, "sales_rep", authorization, "", (value) => value, customer),
      makeDataCell(customer.region, "region", authorization, "", (value) => value, customer),
      makeDataCell(customer.revenue, "revenue", authorization, "number", formatNumber, customer),
      makeDataCell(customer.credit_limit, "credit_limit", authorization, "number", formatNumber, customer),
      makeDataCell(customer.sensitive_identifier, "sensitive_identifier", authorization, "", (value) => value, customer)
    );
    results.append(row);
  }
}

document.querySelectorAll("th.sortable").forEach((header) => {
  header.addEventListener("click", () => {
    const key = header.dataset.sortKey;
    const type = header.dataset.sortType;
    const direction = currentSort.key === key && currentSort.direction === "asc" ? "desc" : "asc";
    currentSort = {key, direction};
    document.querySelectorAll("th.sortable").forEach((th) => th.classList.remove("sort-asc", "sort-desc"));
    header.classList.add(direction === "asc" ? "sort-asc" : "sort-desc");
    renderCustomers(sortRows(currentRows, key, type, direction));
  });
});
