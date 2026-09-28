"use strict";

const featureHost = document.getElementById("features");
const interfaceTypeSelect = document.getElementById("interface-type");
const checkHost = document.getElementById("checks");
const form = document.getElementById("review-form");
const resultsSection = document.getElementById("results");
const summaryHost = document.getElementById("summary");
const findingsHost = document.getElementById("findings");
const goalSelect = document.getElementById("goal-select");
const proofHost = document.getElementById("proof");
const traceHost = document.getElementById("trace");

let knowledge = null;
let lastAnswers = null;

function element(tag, className, textValue) {
  const node = document.createElement(tag);
  if (className) node.className = className;
  if (textValue !== undefined) node.textContent = textValue;
  return node;
}

function createQuestion(id, labelText, helpText, key, kind) {
  const box = element("div", "question");
  const label = element("label", "question-label", labelText);
  label.htmlFor = id;
  const help = element("p", "question-help", helpText);
  help.id = `${id}-help`;
  const select = element("select", "answer-select");
  select.id = id;
  select.name = key;
  select.dataset.key = key;
  select.dataset.kind = kind;
  select.setAttribute("aria-describedby", help.id);
  select.add(new Option("Not sure", "unknown"));
  select.add(new Option("Yes", "yes"));
  select.add(new Option("No", "no"));
  box.append(label, help, select);
  return box;
}

function renderKnowledge(data) {
  knowledge = data;
  interfaceTypeSelect.replaceChildren(new Option("Not sure", "unknown"));
  for (const type of data.interface_types) {
    interfaceTypeSelect.add(new Option(type.label, type.key));
  }
  featureHost.replaceChildren();
  checkHost.replaceChildren();
  goalSelect.replaceChildren();

  for (const feature of data.features) {
    featureHost.append(createQuestion(`feature-${feature.key}`, feature.label,
      feature.help, feature.key, "feature"));
  }

  const groups = [...new Set(data.criteria.map(item => item.group))];
  for (const group of groups) {
    const fieldset = element("fieldset", "check-group");
    const legend = element("legend", "group-title", group);
    fieldset.append(legend);
    const grid = element("div", "question-grid");
    for (const item of data.criteria.filter(entry => entry.group === group)) {
      const box = createQuestion(`check-${item.key}`, `${item.number} ${item.title}: ${item.question}`,
        item.help, item.check_key, "check");
      box.dataset.gates = item.gates.join(",");
      box.dataset.nativeGates = item.native_gates.join(",");
      const note = element("p", "applicability-note");
      note.hidden = true;
      box.append(note);
      grid.append(box);
      goalSelect.add(new Option(`${item.number} ${item.title}`, item.key));
    }
    fieldset.append(grid);
    checkHost.append(fieldset);
  }
  featureHost.addEventListener("change", updateApplicability);
  interfaceTypeSelect.addEventListener("change", updateApplicability);
  updateApplicability();
}

function updateApplicability() {
  const answers = collectAnswers();
  const isNative = answers.interface_type === "desktop" || answers.interface_type === "mobile";
  for (const key of ["keyboard_service", "title_property_supported"]) {
    const control = featureHost.querySelector(`[data-key="${key}"]`);
    if (control) control.closest(".question").hidden = !isNative;
  }
  for (const box of checkHost.querySelectorAll(".question")) {
    const gates = box.dataset.gates ? box.dataset.gates.split(",") : [];
    if (isNative) {
      gates.push(...(box.dataset.nativeGates ? box.dataset.nativeGates.split(",") : []));
    }
    const missing = gates.find(key => answers[key] === "no");
    const note = box.querySelector(".applicability-note");
    if (answers.interface_type === "unknown") {
      note.textContent = "Choose an interface type to evaluate this check.";
      note.hidden = false;
      box.classList.remove("not-applicable-question");
    } else if (missing) {
      const feature = knowledge.features.find(item => item.key === missing);
      note.textContent = `Not applicable based on your answer to “${feature.label}”.`;
      note.hidden = false;
      box.classList.add("not-applicable-question");
    } else {
      note.hidden = true;
      box.classList.remove("not-applicable-question");
    }
  }
}

function collectAnswers() {
  const answers = {};
  for (const select of form.querySelectorAll("select[data-key]")) {
    answers[select.dataset.key] = select.value;
  }
  return answers;
}

async function postJson(path, payload) {
  const response = await fetch(path, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload)
  });
  const data = await response.json();
  if (!response.ok) throw new Error(data.error || `Request failed (${response.status})`);
  return data;
}

function resultLabel(status) {
  return {
    possible_issue: "Possible issue",
    no_issue_reported: "No issue reported",
    not_applicable: "Not applicable",
    needs_review: "Needs review"
  }[status] || status;
}

function renderResults(data) {
  resultsSection.classList.remove("hidden");
  summaryHost.replaceChildren();
  findingsHost.replaceChildren();
  traceHost.replaceChildren();
  proofHost.replaceChildren();

  const counts = data.counts;
  const selectedType = knowledge.interface_types.find(type => type.key === lastAnswers.interface_type);
  const issueWord = counts.possible_issue === 1 ? "possible issue" : "possible issues";
  const summary = element("p", "summary-text",
    `${selectedType ? selectedType.label + " · " : "Choose an interface type · "}` +
    `${counts.possible_issue} ${issueWord} · ${counts.no_issue_reported} with no issue reported · ` +
    `${counts.not_applicable} not applicable · ${counts.needs_review} needing review`);
  summaryHost.append(summary);

  const order = { possible_issue: 0, needs_review: 1, no_issue_reported: 2, not_applicable: 3 };
  const sorted = [...data.results].sort((a, b) => order[a.status] - order[b.status]);
  for (const item of sorted) {
    const article = element("article", `finding ${item.status}`);
    const heading = element("h3", "finding-heading", `${item.number} ${item.title}`);
    const badge = element("span", "status-badge", resultLabel(item.status));
    const explanation = element("p", "finding-explanation", item.explanation);
    article.append(heading, badge, explanation);
    if (item.status === "possible_issue") {
      article.append(element("p", "advice", `Suggested action: ${item.advice}`));
    }
    const source = element("a", "source-link", "Read the W3C criterion");
    source.href = item.source;
    source.target = "_blank";
    source.rel = "noopener noreferrer";
    article.append(source);
    if (item.guidance) {
      const guidance = element("a", "guidance-link", "How W3C applies this to non-web software");
      guidance.href = item.guidance;
      guidance.target = "_blank";
      guidance.rel = "noopener noreferrer";
      article.append(guidance);
    }
    findingsHost.append(article);
  }

  for (const step of data.trace) {
    const item = element("li", "trace-step");
    item.append(element("strong", "", `${step.rule}: ${step.conclusion}`));
    if (step.premises.length) item.append(element("p", "", step.premises.join("; ")));
    traceHost.append(item);
  }
  const firstIssue = data.results.find(item => item.status === "possible_issue");
  if (firstIssue) goalSelect.value = firstIssue.key;
  showBackwardProof();
  resultsSection.scrollIntoView({ behavior: "smooth", block: "start" });
}

async function showBackwardProof() {
  proofHost.replaceChildren();
  if (!lastAnswers) {
    proofHost.append(element("p", "", "Show results first to save the answers for this goal."));
    return;
  }
  try {
    const proof = await postJson("/api/prove", {
      criterion: goalSelect.value,
      answers: lastAnswers
    });

    proofHost.append(element("p", "proof-result",
      proof.provable
        ? `Goal proved: ${proof.criterion} ${proof.title} is a possible issue.`
        : `Goal not proved: ${proof.criterion} ${proof.title} is not established as a possible issue.`));

    const steps = element("ol", "backward-proof");
    steps.append(element("li", "", `Goal: prove that criterion ${proof.criterion} has a possible issue.`));
    if (proof.provable) {
      steps.append(element("li", "", `Rule selected: ${proof.rule}.`));
      const premiseStep = element("li", "", "Required premises checked against the supplied facts:");
      const premises = element("ul", "proof-premises");
      for (const premise of proof.premises) premises.append(element("li", "", premise));
      premiseStep.append(premises);
      steps.append(premiseStep);
      steps.append(element("li", "", `Conclusion: all premises succeeded, so rule ${proof.rule} proves the goal.`));
    } else {
      steps.append(element("li", "", "Rule search: the system could not satisfy every required premise from the supplied facts."));
      steps.append(element("li", "", "Conclusion: the goal cannot be proved with the current answers."));
    }
    proofHost.append(steps, element("p", "proof-explanation", proof.explanation));
  } catch (error) {
    proofHost.append(element("p", "", `Could not check the goal: ${error.message}`));
  }
}

form.addEventListener("submit", async event => {
  event.preventDefault();
  lastAnswers = collectAnswers();
  const button = document.getElementById("evaluate-button");
  button.disabled = true;
  button.textContent = "Checking…";
  try {
    const data = await postJson("/api/evaluate", { answers: lastAnswers });
    renderResults(data);
  } catch (error) {
    summaryHost.textContent = `Could not evaluate this interface: ${error.message}`;
    resultsSection.classList.remove("hidden");
  } finally {
    button.disabled = false;
    button.textContent = "Show results";
  }
});

form.addEventListener("reset", () => {
  setTimeout(() => {
    updateApplicability();
    lastAnswers = null;
    resultsSection.classList.add("hidden");
    proofHost.replaceChildren();
  }, 0);
});

document.getElementById("prove-button").addEventListener("click", showBackwardProof);

fetch("/api/knowledge")
  .then(response => { if (!response.ok) throw new Error("Knowledge base unavailable"); return response.json(); })
  .then(renderKnowledge)
  .catch(error => {
    featureHost.textContent = `Could not load questions: ${error.message}`;
    checkHost.replaceChildren();
  });
