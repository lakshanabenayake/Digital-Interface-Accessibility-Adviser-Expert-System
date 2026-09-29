# Digital Interface Accessibility Adviser Expert System

A read-only expert system for a **guided review of one website, desktop application, or mobile application**. It asks a human reviewer what the interface contains and how it behaves, applies 20 explicit Prolog rules, then explains possible accessibility issues and suggested actions.

## What is digital interface accessibility?

An accessible interface lets people with different visual, hearing, physical, and cognitive abilities perceive information and operate software. Examples include meaningful text alternatives for informative icons, readable contrast, keyboard operation where supported, clear labels, visible focus, and understandable error messages. The [W3C introduction to accessibility](https://www.w3.org/WAI/fundamentals/accessibility-intro/) explains why these features matter.

## What problem does this adviser solve?

Accessibility problems can be overlooked when an interface appears usable to its developer. A reviewer must also decide which checks apply: a screen with no links does not need a link-purpose check, and a native app on a platform without a keyboard service does not need a keyboard-operation finding. This adviser structures that first review and shows the reasoning behind each result.

The rules are based on **20 selected Level A and AA criteria** in [WCAG 2.2](https://www.w3.org/TR/WCAG22/). The [W3C WCAG2ICT Group Note](https://www.w3.org/TR/wcag2ict-22/) guides how those criteria are interpreted for non-web software. WCAG2ICT is informative guidance, not a separate conformance standard. The final assignment PDF contains the complete rule-to-source mapping and interpretation notes.

Complete installation and operating instructions are available in [HOW TO RUN.md](HOW%20TO%20RUN.md).

## What does the system do?

1. You choose **website/web app**, **desktop app**, or **mobile app** and inspect one interface yourself.
2. You answer Yes, No, or Not sure about features and accessibility behaviour.
3. The inference engine decides which checks apply. Native software has extra gates for platform keyboard and window/screen title support.
4. Twenty IF-THEN issue rules identify possible problems. The interface gives a suggested action, links to W3C sources, and shows the forward-chaining trace.
5. You can ask why a selected issue was flagged; a backward-chaining proof lists its supporting answers.

Results are **Possible issue**, **No issue reported**, **Not applicable**, or **Needs review**. Unknown answers are never treated as passes.

**Scope:** This is a preliminary manual review, not an automatic scanner. It does not fetch, change, or store the target interface. It does not assess physical hardware controls or all of WCAG. A “No issue reported” result only reflects one question and does not establish conformance. Verify findings against the linked W3C text.

## Requirements

- SWI-Prolog 9.0 or later: <https://www.swi-prolog.org/Download.html>
- A modern web browser

The HTTP and unit-testing libraries used by this project are included with a standard SWI-Prolog installation. No JavaScript packages or database are required.

## Run it

Download or extract the project, open a terminal in its root folder, and use one of these commands.

Windows PowerShell:

```powershell
.\run.ps1
```

Git Bash, macOS, or Linux:

```bash
bash run.sh
```

Open <http://localhost:8080/>. If port 8080 is already in use, choose another port, for example `bash run.sh 8081` or `.\run.ps1 -Port 8081`, and open that port in the browser. Press **Ctrl+C** in the terminal to stop the server.

### Example review

Choose **Desktop application**. If the app has interactive controls, its platform supplies a keyboard interface, and one control cannot be operated through it, answer Yes to the **Interactive functions** and **Platform keyboard service** feature questions and No to **2.1.1 Keyboard**. Rule `r09` produces a possible issue and shows the answers that support it.

## Run tests

Windows PowerShell:

```powershell
.\test.ps1
```

Git Bash, macOS, or Linux:

```bash
bash test.sh
```

The 18 automated tests check all 20 issue rules individually, unknown answers, feature applicability, desktop and mobile gates, backward proof, and source identifiers.

## Files

| File | Purpose |
| --- | --- |
| `knowledge_base.pl` | 20 criterion facts, 17 feature facts, six numeric facts, three interface types, and four native gates. |
| `inference_engine.pl` | 20 explicit issue rules, forward chaining, result explanations, and backward proof. |
| `web_server.pl` | Local HTTP server and JSON API. |
| `web/` | Browser questionnaire and result view. |
| `tests.pl` | Automated test cases. |
| `HOW TO RUN.md` | Separate installation, operation, example, testing, and troubleshooting guide. |
| `run.ps1`, `test.ps1` | Windows PowerShell launchers. |
| `run.sh`, `test.sh` | Git Bash, macOS, and Linux launchers. |
| `output/pdf/Digital_Interface_Accessibility_Adviser_Report.pdf` | Complete assignment report, rule sources, knowledge engineering, tests, user manual, and requirement coverage. |
