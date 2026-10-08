const csrfToken = document.querySelector("meta[name='csrf-token']")?.content;
const jsonHeaders = {"Content-Type": "application/json", "X-CSRFToken": csrfToken};
function loadSetupProgress() {
  try {
    return new Set(JSON.parse(document.body?.dataset.completedActions || "[]"));
  } catch (_) {
    return new Set();
  }
}

let completedSetupActions = loadSetupProgress();
let selectedActionKey = null;

function stepIsCompleted(step) {
  return (step.dataset.actionKeys || "").split(",").some((actionKey) => completedSetupActions.has(actionKey));
}

function updateNavigationProgress() {
  const links = Array.from(document.querySelectorAll("[data-progress-steps]"));
  let total = 0;
  let completed = 0;
  links.forEach((link) => {
    let groups = [];
    try {
      groups = JSON.parse(link.dataset.progressSteps || "[]");
    } catch (_) {
      groups = [];
    }
    const excluded = link.dataset.progressExcluded === "true";
    const isCompleted = !excluded && groups.length > 0 && groups.every((group) =>
      group.some((actionKey) => completedSetupActions.has(actionKey))
    );
    link.classList.toggle("is-completed", isCompleted);
    link.querySelector(".page-check")?.toggleAttribute("hidden", !isCompleted);
    if (!excluded) {
      total += 1;
      if (isCompleted) completed += 1;
    }
  });
}

function updateActionAvailability() {
  document.querySelectorAll(".run-action").forEach((button) => {
    const actionArea = button.closest(".toggle-half") || button.closest(".action-card");
    const status = actionArea.querySelector(".action-status");
    button.disabled = false;
    if (status.dataset.lockMessage && status.textContent === status.dataset.lockMessage) {
      status.textContent = "";
    }
  });

  document.querySelectorAll(".step-item").forEach((step) => {
    const key = step.dataset.actionStep;
    const button = step.querySelector(".step-badge");
    const completed = stepIsCompleted(step);
    step.classList.remove("is-locked");
    step.classList.toggle("is-completed", completed);
    step.classList.toggle("is-current", !completed && key === selectedActionKey);
    button.disabled = false;
    button.setAttribute("aria-disabled", "false");
  });
  updateNavigationProgress();

  if (!selectedActionKey) {
    const firstStep = document.querySelector("[data-select-action]");
    if (firstStep) selectAction(firstStep.dataset.selectAction);
  }
}

function selectAction(actionKey) {
  const targetStep = document.querySelector(`.step-item[data-action-step="${actionKey}"]`);
  if (!targetStep) return;
  selectedActionKey = actionKey;
  document.querySelectorAll("[data-action-panel]").forEach((panel) => {
    panel.hidden = panel.dataset.actionPanel !== actionKey;
  });
  document.querySelectorAll(".step-item").forEach((step) => {
    const selected = step.dataset.actionStep === actionKey;
    step.classList.toggle("is-selected", selected);
    step.classList.toggle("is-current", selected && !stepIsCompleted(step));
    step.querySelector(".step-badge")?.setAttribute("aria-current", selected ? "step" : "false");
  });
  const validationButton = document.querySelector(`[data-action="${actionKey}"][data-validation-comparison="true"]`);
  if (validationButton) refreshValidationComparison();
}

async function requestJson(url, options, {redirectOn401 = true} = {}) {
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

const loginForm = document.querySelector("#login-form");
if (loginForm) {
  loginForm.addEventListener("submit", async (event) => {
    event.preventDefault();
    const password = document.querySelector("#password");
    const button = document.querySelector("#login");
    const error = document.querySelector("#error");
    error.textContent = "";
    button.disabled = true;
    button.textContent = "Signing in…";
    try {
      const {response, payload} = await requestJson("/api/login", {
        method: "POST", headers: jsonHeaders, body: JSON.stringify({password: password.value})
      }, {redirectOn401: false});
      if (response.ok) {
        window.location.assign("/console");
        return;
      }
      error.textContent = payload.error || "Database sign-in failed.";
    } catch (_) {
      error.textContent = "Unable to sign in. Please try again.";
    } finally {
      button.disabled = false;
      button.textContent = "Sign in to Admin Console";
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
        method: "POST", headers: jsonHeaders, cache: "no-store", credentials: "same-origin"
      });
    } finally {
      // Replace the protected page so Back cannot restore it from history.
      window.location.replace("/");
    }
  });
}

function validationItem(label, value) {
  const item = document.createElement("li");
  const name = document.createElement("strong");
  name.textContent = `${label}: `;
  item.append(name, document.createTextNode(value || "—"));
  return item;
}

function describeRowPredicate(predicate) {
  if (!predicate || predicate.trim().toUpperCase() === "1=1" || predicate.trim().toUpperCase() === "1 = 1") {
    return "Every row";
  }
  const normalized = predicate.toLowerCase();
  const hasOwnRows = normalized.includes("sales_rep");
  const hasManagerOr = normalized.includes(" or ") && normalized.includes("manager_id");
  if (hasManagerOr) return "Their own rows, plus their team's";
  if (hasOwnRows) return "Only their own rows";
  if (normalized.includes("customer_id in")) return "Rows for customers they can already see";
  return predicate;
}

function columnPills(columns) {
  const list = Array.isArray(columns) ? columns : String(columns || "").split(",").map((column) => column.trim()).filter(Boolean);
  const wrap = document.createElement("div");
  wrap.className = "column-pills";
  list.forEach((column) => {
    const pill = document.createElement("span");
    pill.className = "column-pill";
    pill.textContent = column;
    wrap.append(pill);
  });
  return wrap;
}

function renderValidationComparison(snapshot) {
  const target = document.querySelector("#validation-personas");
  const query = document.querySelector("#validation-query");
  if (!target) return;
  target.replaceChildren();
  if (!snapshot.available) {
    const message = document.createElement("p");
    message.className = "muted";
    message.textContent = snapshot.message || "Create Emma, Marvin, and the data roles before running this comparison.";
    target.append(message);
    return;
  }
  if (query) query.textContent = snapshot.query || query.textContent;
  for (const persona of snapshot.personas || []) {
    const card = document.createElement("article");
    card.className = "validation-persona";
    const title = document.createElement("h4");
    title.textContent = persona.username;
    card.append(title);
    if (!persona.available) {
      const message = document.createElement("p");
      message.className = "error";
      message.textContent = `${persona.username} is not available yet.`;
      card.append(message);
      target.append(card);
      continue;
    }
    const details = document.createElement("dl");
    [["Active data roles", (persona.roles || []).join(", ") || "No active data role"], ["Rows returned", String(persona.row_count ?? "—")]].forEach(([label, value]) => {
      const term = document.createElement("dt");
      term.textContent = label;
      const description = document.createElement("dd");
      description.textContent = value;
      details.append(term, description);
    });
    card.append(details);
    if (persona.columns?.length) card.append(columnPills(persona.columns));
    const grantsTitle = document.createElement("h5");
    grantsTitle.textContent = "Applicable data grants";
    card.append(grantsTitle);
    const grants = document.createElement("ul");
    grants.className = "validation-grants";
    if ((persona.grants || []).length) {
      for (const grant of persona.grants) {
        const item = document.createElement("li");
        item.className = "grant-card";
        const name = document.createElement("div");
        name.className = "grant-name";
        name.textContent = grant.name;
        const via = document.createElement("div");
        via.className = "grant-via muted";
        via.textContent = `via ${grant.role}`;
        const rows = document.createElement("div");
        rows.className = "grant-rows";
        rows.textContent = describeRowPredicate(grant.predicate);
        item.append(name, via, columnPills(grant.columns), rows);
        grants.append(item);
      }
    } else {
      const empty = document.createElement("li");
      empty.className = "muted";
      empty.textContent = "No applicable data grants";
      grants.append(empty);
    }
    card.append(grants);
    target.append(card);
  }
}

async function refreshValidationComparison() {
  if (!document.querySelector("#validation-personas")) return;
  try {
    const {response, payload} = await requestJson("/api/validation-comparison");
    renderValidationComparison(response.ok ? payload : {available: false, message: payload.error});
  } catch (_) {
    renderValidationComparison({available: false, message: "Could not read the Oracle authorization comparison."});
  }
}

function renderGrantComparison(snapshot) {
  const target = document.querySelector("#customize-grant-states");
  const query = document.querySelector("#customize-grant-query");
  if (!target) return;
  target.replaceChildren();
  if (!snapshot.available) {
    const message = document.createElement("p");
    message.className = "muted";
    message.textContent = snapshot.message || "Marvin's authorization is not available yet.";
    target.append(message);
    return;
  }
  if (query) query.textContent = snapshot.query || query.textContent;
  [["Before", snapshot.before], ["After", snapshot.after]].forEach(([label, state]) => {
    const card = document.createElement("article");
    card.className = "grant-state-card";
    const heading = document.createElement("h4");
    heading.textContent = label;
    card.append(heading);
    const summary = document.createElement("p");
    summary.className = "grant-state-summary";
    summary.textContent = state
      ? `${state.row_count} rows, ${state.columns.length} columns.`
      : "Pending Apply.";
    card.append(summary);
    if (state) {
      const columns = document.createElement("p");
      columns.className = "grant-state-columns";
      columns.textContent = `Visible columns: ${state.columns.join(", ")}`;
      card.append(columns);
    }
    target.append(card);
  });
}

async function refreshGrantComparison(method = "GET") {
  if (!document.querySelector("#customize-grant-states")) return;
  try {
    const {response, payload} = await requestJson("/api/customize-grant-comparison", {
      method,
      headers: jsonHeaders,
    });
    renderGrantComparison(response.ok ? payload : {available: false, message: payload.error});
  } catch (_) {
    renderGrantComparison({available: false, message: "Could not read Marvin's authorization comparison."});
  }
}

updateActionAvailability();
refreshGrantComparison();

document.querySelectorAll("[data-select-action]").forEach((button) => {
  button.addEventListener("click", () => selectAction(button.dataset.selectAction));
});

document.querySelectorAll(".next-button").forEach((button) => {
  button.addEventListener("click", () => {
    const nextKey = button.dataset.nextStep;
    if (!nextKey) return;
    selectAction(nextKey);
    document.querySelector(`[data-action-panel="${nextKey}"]`)?.scrollIntoView({behavior: "smooth", block: "start"});
  });
});

document.querySelectorAll(".run-action").forEach((button) => {
  button.addEventListener("click", async () => {
    const card = button.closest(".action-card");
    const actionArea = button.closest(".toggle-half") || card;
    const status = actionArea.querySelector(".action-status");
    const output = actionArea.querySelector(".action-output");
    const outputText = output.querySelector("pre");
    if (button.dataset.resetsSetup === "true" && !window.confirm("Run this administrative action?")) return;
    button.disabled = true;
    status.textContent = "Running SQL*Plus…";
    output.hidden = true;
    try {
      const {response, payload} = await requestJson(`/api/actions/${button.dataset.action}`, {
        method: "POST", headers: jsonHeaders
      });
      outputText.textContent = payload.output || payload.error || "No output was returned.";
      output.hidden = false;
      output.open = true;
      status.textContent = response.ok ? "Completed" : "Action did not complete";
      if (response.ok) {
        if (Array.isArray(payload.completed_actions)) {
          completedSetupActions = new Set(payload.completed_actions);
        } else if (button.dataset.resetsSetup === "true") {
          completedSetupActions = new Set();
        } else {
          completedSetupActions.add(button.dataset.action);
        }
        updateActionAvailability();
      }
      if (response.ok && button.dataset.validationComparison === "true") await refreshValidationComparison();
      if (response.ok && button.dataset.linkTarget === "customer_sales_app") {
        window.location.href = "/build-grant";
      }
    } catch (_) {
      status.textContent = "Action failed";
      outputText.textContent = "Could not contact the administrator console.";
      output.hidden = false;
      output.open = true;
    } finally {
      updateActionAvailability();
    }
  });
});

document.querySelectorAll(".customer-sales-link[data-complete-action]").forEach((link) => {
  link.addEventListener("click", () => {
    const actionKey = link.dataset.completeAction;
    const actionArea = link.closest(".action-card");
    const status = actionArea.querySelector(".action-status");
    const output = actionArea.querySelector(".action-output");
    const outputText = output.querySelector("pre");
    status.textContent = "Opening Customer Sales App…";

    // Do not prevent the link's default target=_blank navigation. The demo
    // opens immediately, while this page records the same link-step action
    // that the former Continue button used.
    void requestJson(`/api/actions/${actionKey}`, {method: "POST", headers: jsonHeaders})
      .then(({response, payload}) => {
        outputText.textContent = payload.output || payload.error || "No output was returned.";
        output.hidden = false;
        output.open = true;
        status.textContent = response.ok ? "Completed" : "Could not mark this step complete";
        if (response.ok) {
          completedSetupActions = Array.isArray(payload.completed_actions)
            ? new Set(payload.completed_actions)
            : new Set([...completedSetupActions, actionKey]);
          updateActionAvailability();
        }
      })
      .catch(() => {
        status.textContent = "Could not mark this step complete";
      });
  });
});

document.querySelectorAll(".review-quiz").forEach((quiz) => {
  quiz.querySelector(".check-review-quiz").addEventListener("click", () => {
    const selected = quiz.querySelector("input[type='radio']:checked");
    const feedback = quiz.querySelector(".review-quiz-feedback");
    feedback.hidden = false;
    if (!selected) {
      feedback.className = "review-quiz-feedback error";
      feedback.textContent = "Choose an answer first.";
      return;
    }
    if (selected.value === quiz.dataset.correctAnswer) {
      feedback.className = "review-quiz-feedback correct";
      feedback.textContent = quiz.dataset.correctExplanation;
      return;
    }
    feedback.className = "review-quiz-feedback error";
    feedback.textContent = "Not quite. Review the SQL output and try again.";
  });
});

document.querySelector("#run-vibe-coding")?.addEventListener("click", async () => {
  const button = document.querySelector("#run-vibe-coding");
  const status = document.querySelector("#vibe-coding-status");
  const scriptOutput = document.querySelector("#vibe-coding-script-output");
  const reportLink = document.querySelector("#vibe-coding-report-link");
  const requestText = document.querySelector("#vibe-coding-request").value;
  button.disabled = true;
  status.textContent = "Creating Customer Sales App page…";
  reportLink.hidden = true;
  reportLink.replaceChildren();
  try {
    const {response, payload} = await requestJson("/api/vibe-coding/publish", {
      method: "POST",
      headers: jsonHeaders,
      body: JSON.stringify({request: requestText}),
    });
    status.textContent = response.ok ? "Customer Sales App page created." : (payload.error || "Failed.");
    if (payload.sql) {
      scriptOutput.hidden = false;
      scriptOutput.querySelector("pre").textContent = payload.sql;
    }
    if (response.ok && payload.report_path) {
      const link = document.createElement("a");
      const customerUrl = new URL(payload.report_path, window.location.origin);
      customerUrl.port = "7777";
      link.href = customerUrl.toString();
      link.textContent = "Open the new Customer Sales App report page";
      link.target = "_blank";
      link.rel = "noopener";
      reportLink.append(link);
      reportLink.hidden = false;
    }
  } catch (_) {
    status.textContent = "Could not contact the administrator console.";
  } finally {
    button.disabled = false;
    button.textContent = "Create Customer Sales App page";
  }
});

document.querySelectorAll(".grant-wizard").forEach((wizard) => {
  const actionKey = wizard.dataset.actionKey;
  const preview = wizard.querySelector(".grant-preview");
  const applyButton = wizard.querySelector(".run-grant-apply");
  const status = wizard.querySelector(".grant-status");
  const output = wizard.querySelector(".grant-output");
  const outputText = output?.querySelector("pre");
  const isAllExcept = wizard.dataset.wizardStyle === "all_except";

  function selectedColumns() {
    return Array.from(wizard.querySelectorAll(".grant-column-include:checked")).map((element) => element.value);
  }

  function selectedUpdateColumns() {
    return Array.from(wizard.querySelectorAll(".grant-update-include:checked")).map((element) => element.value);
  }

  function excludedColumns() {
    return Array.from(wizard.querySelectorAll(".grant-exclude-column:checked")).map((element) => element.value);
  }

  function restrictRows() {
    return wizard.querySelector(".grant-restrict-rows")?.checked || false;
  }

  function allowDelete() {
    return wizard.querySelector(".grant-allow-delete")?.checked || false;
  }

  function requestPayload() {
    if (isAllExcept) {
      return {
        excluded_columns: excludedColumns(),
      };
    }
    return {
      columns: selectedColumns(),
      update_columns: selectedUpdateColumns(),
      allow_delete: allowDelete(),
      restrict_rows: restrictRows(),
    };
  }

  async function refreshPreview() {
    if (!preview) return;
    try {
      const {payload} = await requestJson(`/api/actions/${actionKey}/preview`, {
        method: "POST",
        headers: jsonHeaders,
        body: JSON.stringify(requestPayload()),
      });
      preview.textContent = payload.sql || payload.error || "Could not generate a preview.";
    } catch (_) {
      preview.textContent = "Could not contact the administrator console.";
    }
  }

  if (isAllExcept) {
    wizard.querySelectorAll(".grant-exclude-column").forEach((box) => box.addEventListener("change", refreshPreview));
  } else {
    wizard.querySelectorAll(".grant-column-exclude").forEach((radio) => {
      radio.addEventListener("change", () => {
        if (radio.checked) {
          const pairedUpdateExclude = wizard.querySelector(`.grant-update-exclude[value="${radio.value}"]`);
          if (pairedUpdateExclude) pairedUpdateExclude.checked = true;
        }
      });
    });
    wizard.querySelectorAll(".grant-column-include, .grant-column-exclude, .grant-update-include, .grant-update-exclude, .grant-restrict-rows, .grant-allow-delete").forEach((box) => {
      box.addEventListener("change", refreshPreview);
    });
  }
  refreshPreview();

  applyButton?.addEventListener("click", async () => {
    if (wizard.dataset.confirmApply === "true" && !window.confirm("Apply this data grant?")) return;
    applyButton.disabled = true;
    status.textContent = "Applying…";
    try {
      const {response, payload} = await requestJson(`/api/actions/${actionKey}/apply`, {
        method: "POST",
        headers: jsonHeaders,
        body: JSON.stringify(requestPayload()),
      });
      status.textContent = response.ok ? "Applied." : (payload.error || "Failed.");
      if (output) {
        output.hidden = false;
        output.open = true;
        outputText.textContent = payload.output || payload.error || "No output was returned.";
      }
      if (response.ok) {
        if (Array.isArray(payload.completed_actions)) {
          completedSetupActions = new Set(payload.completed_actions);
        } else if (actionKey) {
          completedSetupActions.add(actionKey);
        }
        updateActionAvailability();
        await refreshGrantComparison("POST");
      }
    } catch (_) {
      status.textContent = "Could not contact the administrator console.";
    } finally {
      applyButton.disabled = false;
    }
  });
});

function loadTourSteps() {
  try {
    const steps = JSON.parse(document.body?.dataset.tourSteps || "[]");
    return Array.isArray(steps) ? steps : [];
  } catch (_) {
    return [];
  }
}

const TOUR_STEPS = loadTourSteps();

function startTour() {
  if (!TOUR_STEPS.length) return;
  document.querySelector(".tour-backdrop")?.remove();
  document.querySelector(".tour-tooltip")?.remove();
  let index = 0;
  const backdrop = document.createElement("div");
  backdrop.className = "tour-backdrop";
  const tooltip = document.createElement("div");
  tooltip.className = "tour-tooltip";
  document.body.append(backdrop, tooltip);

  function end() {
    backdrop.remove();
    tooltip.remove();
    document.cookie = "hol_tour_seen=1; path=/; max-age=31536000";
  }

  function render() {
    const step = TOUR_STEPS[index];
    const target = document.querySelector(step.selector);
    if (!target) {
      index += 1;
      if (index < TOUR_STEPS.length) return render();
      return end();
    }
    const rect = target.getBoundingClientRect();
    backdrop.style.setProperty("--spot-top", `${rect.top - 4}px`);
    backdrop.style.setProperty("--spot-left", `${rect.left - 4}px`);
    backdrop.style.setProperty("--spot-width", `${rect.width + 8}px`);
    backdrop.style.setProperty("--spot-height", `${rect.height + 8}px`);
    tooltip.style.top = `${Math.min(window.innerHeight - 180, rect.bottom + 12)}px`;
    tooltip.style.left = `${Math.max(12, Math.min(rect.left, window.innerWidth - 292))}px`;
    tooltip.replaceChildren();
    const heading = document.createElement("h3");
    heading.textContent = step.title;
    const text = document.createElement("p");
    text.textContent = step.text;
    const actions = document.createElement("div");
    actions.className = "tour-actions";
    actions.innerHTML = '<button class="secondary small tour-skip" type="button">Skip tour</button><button class="primary small tour-next" type="button"></button>';
    actions.querySelector(".tour-next").textContent = index === TOUR_STEPS.length - 1 ? "Done" : "Next";
    tooltip.append(heading, text, actions);
    tooltip.querySelector(".tour-skip").addEventListener("click", end);
    tooltip.querySelector(".tour-next").addEventListener("click", () => {
      index += 1;
      if (index < TOUR_STEPS.length) render(); else end();
    });
  }

  render();
}

document.querySelector("#tour-replay")?.addEventListener("click", startTour);
if (!document.cookie.includes("hol_tour_seen=1")) {
  window.addEventListener("load", () => setTimeout(() => {
    if (!document.querySelector(".deebee-popup")) startTour();
  }, 400));
}

function showDeebeePopup() {
  const backdrop = document.createElement("div");
  backdrop.className = "deebee-popup-backdrop";
  const popup = document.createElement("div");
  popup.className = "deebee-popup";
  popup.innerHTML = `
    <img src="/static/images/deebee.png" alt="DeeBee" class="deebee-icon deebee-icon-large">
    <div>
      <p class="deebee-greeting">Hi, I'm DeeBee, your Oracle LiveLabs assistant. I will guide you through Oracle Deep Data Security, help you test each policy from the user's side, and point out patterns you can apply in your own environment.</p>
      <button class="primary small deebee-popup-dismiss" type="button">Got it</button>
    </div>
  `;
  document.body.append(backdrop, popup);

  function close() {
    backdrop.remove();
    popup.remove();
    document.cookie = "hol_deebee_greeted=1; path=/; max-age=31536000";
    if (!document.cookie.includes("hol_tour_seen=1")) setTimeout(startTour, 150);
  }

  backdrop.addEventListener("click", close);
  popup.querySelector(".deebee-popup-dismiss").addEventListener("click", close);
}

if (document.querySelector(".overview-card") && !document.cookie.includes("hol_deebee_greeted=1")) {
  window.addEventListener("load", () => setTimeout(showDeebeePopup, 300));
}
