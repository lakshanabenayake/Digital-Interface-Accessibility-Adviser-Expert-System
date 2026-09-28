# Website Accessibility Adviser Expert System

This project is a read-only expert system that guides a person through an accessibility review of one webpage. It asks what is present on the page, checks the person's observations against **20 selected WCAG 2.2 Level A and AA success criteria**, and explains the results.

## What is website accessibility?

Website accessibility means designing and building websites so people with disabilities can perceive the content, understand it, navigate it, and interact with it. For example, a person who cannot see an image may need a meaningful text alternative; a person who cannot use a mouse may need to operate every function with a keyboard. Readable contrast, clear links, visible keyboard focus, and understandable form errors also matter. See the [W3C introduction to web accessibility](https://www.w3.org/WAI/fundamentals/accessibility-intro/).

## What problem does this system address?

Accessibility problems can be easy to overlook when a webpage looks and works normally for its developer. A reviewer also has to decide which accessibility requirements apply to the page and understand what a failed check means. Reading the full standard for every initial review can be difficult for someone learning the subject.

The adviser provides a structured first review. It turns 20 selected requirements from the [Web Content Accessibility Guidelines (WCAG) 2.2](https://www.w3.org/TR/WCAG22/) into questions, applies explicit rules to the answers, and points the reviewer to possible problems and relevant guidance. It helps students, developers, and testers learn *why* a page feature may need attention.

## What does the expert system do?

1. **Collects observations:** You inspect a webpage and answer Yes, No, or Not sure to questions about its features and accessibility behaviour.
2. **Checks applicability:** It works out whether each selected WCAG check applies. For example, a check about informative images does not apply if the page has no informative images.
3. **Applies rules:** Its Prolog inference engine uses 20 explicit IF–THEN issue rules to flag possible problems. It also handles absent features and uncertain answers.
4. **Explains the result:** It shows the rule and answers behind each finding, suggests an action, and links to the exact W3C success criterion. You can also ask it to prove why a particular issue was flagged.

For example, if an informative image is present but its text alternative does not convey its meaning, the system flags a **possible issue with WCAG 1.1.1** and suggests an equivalent text alternative.

**Scope:** This is a guided preliminary review, not an automatic website scanner. It does not fetch, change, or store the target webpage. It covers 20 selected criteria rather than the whole of WCAG 2.2. A “No issue reported” result means only that you answered Yes to that particular question; the system does not establish WCAG conformance. Human verification against the linked W3C criterion is still needed.

## Requirements

- On Windows with Git Bash: no separate install is required; `runtime/swipl/` includes a portable SWI-Prolog runtime.
- On macOS or Linux: install [SWI-Prolog](https://www.swi-prolog.org/Download.html).
- A current web browser

The project has no JavaScript packages or build step. Internet access is needed only to open the W3C reference links; the adviser itself runs locally.

## Run the adviser

In the Git Bash terminal already open at `/d/ExpertSystem`, run **only this command**:

```bash
bash run.sh
```

Open [http://localhost:8081/](http://localhost:8081/) in a browser. Port 8080 is already used by another service on this computer. If port 8081 is in use later, run `bash run.sh 8082` and open port 8082 instead. Press **Ctrl+C** in the terminal to stop the server. The `bash` line is the command; the word after the opening code fence is only a display label.

On macOS or Linux, the same script uses an installed `swipl` executable.

### How to use it

1. Choose one webpage to review. Inspect it manually, including keyboard navigation and any relevant form errors.
2. In **Describe the webpage**, mark whether each feature exists. Use **Not sure** if uncertain.
3. In **Check what you observed**, answer each relevant criterion question. A **No** answer can trigger a possible issue when the criterion applies.
4. Select **Show results**. Review the issue cards, suggested actions, W3C links, and the expandable forward-chaining trace.
5. Select a criterion under **Ask why a criterion was flagged** and choose **Check this goal** to run the backward-chaining proof.
6. Select **Clear answers** to review a different page.

The four result states are:

| State | Meaning |
| --- | --- |
| Possible issue | The page feature applies and you answered No to the check. Verify it against the full WCAG criterion. |
| No issue reported | The page feature applies and you answered Yes to this check. |
| Not applicable | You answered No to a required page feature. |
| Needs review | An applicability answer or the check answer is missing or Not sure. |

### Example

For a page with an informative image whose alternative text does not convey its meaning, answer **Yes** to “Informative non-text content” and **No** to WCAG 1.1.1. The adviser reports a possible issue under rule `r01`, recommends an equivalent text alternative, and shows the supporting answers.

## Run the tests

```bash
bash test.sh
```

The test suite checks the 20 rules individually, unknown and non-applicable answers, multiple findings, rule order, backward proof, and source identifiers. A successful run exits with code 0.

## Project files

| File | Purpose |
| --- | --- |
| `knowledge_base.pl` | 20 sourced criterion facts, 15 page-feature facts, and six numeric facts. |
| `inference_engine.pl` | 20 explicit issue rules, forward chaining, explanations, and backward proof. |
| `web_server.pl` | Local HTTP routes and JSON API. |
| `web/` | Browser interface. |
| `runtime/swipl/` | Portable Windows SWI-Prolog runtime. |
| `run.sh`, `test.sh` | Git Bash launchers for the adviser and tests. |
| `tests.pl` | Automated cases. |
| `RULES_AND_SOURCES.md` | Full rule-to-source mapping. |
| `REPORT.md` | Assignment report, design, and test evidence. |

## Source and scope

The knowledge source is the [W3C Web Content Accessibility Guidelines 2.2](https://www.w3.org/TR/WCAG22/). Each rule maps to a specific success criterion; see [RULES_AND_SOURCES.md](RULES_AND_SOURCES.md). The plain-language prompts intentionally simplify some criteria and exceptions. Consult the linked normative text before making a formal accessibility judgment.
