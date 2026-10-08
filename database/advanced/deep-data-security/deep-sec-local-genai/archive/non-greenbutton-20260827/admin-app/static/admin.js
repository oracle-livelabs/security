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
    const completed = (step.dataset.actionKeys || "").split(",").some((actionKey) => completedSetupActions.has(actionKey));
    step.classList.remove("is-locked");
    step.classList.toggle("is-completed", completed);
    step.classList.toggle("is-current", !completed && key === selectedActionKey);
    button.disabled = false;
    button.setAttribute("aria-disabled", "false");
  });

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
    step.classList.toggle("is-current", selected && !completedSetupActions.has(step.dataset.actionStep));
    step.querySelector(".step-badge")?.setAttribute("aria-current", selected ? "step" : "false");
  });
  if (actionKey === "validate_as_marvin") refreshValidationComparison();
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
  logout.addEventListener("click", async () => {
    await requestJson("/api/logout", {method: "POST", headers: jsonHeaders});
    window.location.assign("/");
  });
}

function validationItem(label, value) {
  const item = document.createElement("li");
  const name = document.createElement("strong");
  name.textContent = `${label}: `;
  item.append(name, document.createTextNode(value || "—"));
  return item;
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
    const grantsTitle = document.createElement("h5");
    grantsTitle.textContent = "Applicable data grants";
    card.append(grantsTitle);
    const grants = document.createElement("ul");
    grants.className = "validation-grants";
    if ((persona.grants || []).length) {
      for (const grant of persona.grants) {
        const item = document.createElement("li");
        const name = document.createElement("strong");
        name.textContent = grant.name;
        item.append(name);
        const details = document.createElement("ul");
        details.append(validationItem("Granted through", grant.role));
        details.append(validationItem("Columns", grant.columns));
        details.append(validationItem("Rows", grant.predicate));
        item.append(details);
        grants.append(item);
      }
    } else {
      grants.append(validationItem("No applicable data grants", ""));
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

updateActionAvailability();

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
      if (button.dataset.action === "validate_as_marvin") await refreshValidationComparison();
      if (response.ok && button.dataset.action === "customer_sales") {
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
    status.textContent = "Opening Customer Sales…";

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
  const runOutput = document.querySelector("#vibe-coding-run-output");
  const requestText = document.querySelector("#vibe-coding-request").value;
  const persona = document.querySelector("#vibe-coding-persona").value;
  button.disabled = true;
  status.textContent = "Generating and running…";
  try {
    const {response, payload} = await requestJson("/api/vibe-coding/run", {
      method: "POST",
      headers: jsonHeaders,
      body: JSON.stringify({request: requestText, persona}),
    });
    status.textContent = response.ok ? "Done." : (payload.error || "Failed.");
    if (payload.script) {
      scriptOutput.hidden = false;
      scriptOutput.querySelector("pre").textContent = payload.script;
    }
    if (payload.output || payload.error) {
      runOutput.hidden = false;
      runOutput.querySelector("pre").textContent = payload.output || payload.error;
    }
  } catch (_) {
    status.textContent = "Could not contact the administrator console.";
  } finally {
    button.disabled = false;
  }
});

document.querySelectorAll(".grant-wizard").forEach((wizard) => {
  const apiPrefix = wizard.dataset.apiPrefix;
  const actionKey = wizard.dataset.actionKey;
  const preview = wizard.querySelector(".grant-preview");
  const applyButton = wizard.querySelector(".run-grant-apply");
  const status = wizard.querySelector(".grant-status");
  const output = wizard.querySelector(".grant-output");
  const outputText = output?.querySelector("pre");
  const isAllExcept = apiPrefix === "order-history-grant";

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
      const {payload} = await requestJson(`/api/${apiPrefix}/preview`, {
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
    applyButton.disabled = true;
    status.textContent = "Applying…";
    try {
      const {response, payload} = await requestJson(`/api/${apiPrefix}/apply`, {
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
      }
    } catch (_) {
      status.textContent = "Could not contact the administrator console.";
    } finally {
      applyButton.disabled = false;
    }
  });
});

const TOUR_STEPS = [
  {selector: '.header-link[href="/db-setup"]', title: "DB Setup", text: "Start here. Creates the schema, table, and the one ordinary Oracle role this lab uses before Deep Sec begins."},
  {selector: '.header-link[href="/deep-sec-basics"]', title: "Deep Sec Setup", text: "Deep Data Security actually starts here: data roles, data grants, and Marvin and Emma."},
  {selector: '.header-link[href="/customer-sales"]', title: "Customer Sales Demo", text: "The live application Marvin and Emma sign into. Come back here after every policy change to see the effect."},
  {selector: '.header-link[href="/build-grant"]', title: "Customize Data Grant", text: "Build Marvin's employee-level access yourself, by choosing which columns his data grant authorizes."},
  {selector: '.header-link[href="/end-user-context"]', title: "End User Context", text: "The most advanced page: a manager lookup, a session-scoped context, and Marvin's promotion to manager."},
  {selector: '.header-link[href="/vibe-coding"]', title: "Vibe Coding", text: "Generate and run a standalone query script as an end user. Oracle still decides what it can retrieve."},
  {selector: '.header-link[href="/admin"]', title: "Admin", text: "Run validation queries, or reset the whole lab back to nothing and start over."},
];

function startTour() {
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
    tooltip.innerHTML = `<h3>${step.title}</h3><p>${step.text}</p><div class="tour-actions"><button class="secondary small tour-skip" type="button">Skip tour</button><button class="primary small tour-next" type="button">${index === TOUR_STEPS.length - 1 ? "Done" : "Next"}</button></div>`;
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
    <img src="/static/images/DeeBee.png" alt="DeeBee" class="deebee-icon deebee-icon-large">
    <div>
      <p class="deebee-greeting">Hi, I'm DeeBee. I'll have tips for you along the way. Start by pressing the ? to learn about the menu items.</p>
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
