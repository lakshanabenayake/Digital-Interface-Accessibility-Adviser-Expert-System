# Digital Interface Accessibility Adviser Expert System

## 1. Domain and objective

The domain is **software user interface accessibility**. A reviewer can examine one website/web app, desktop app, or mobile app. The system applies 20 selected Level A and AA accessibility checks, reports possible issues, suggests actions, and explains its reasoning. It is a read-only aid to a human reviewer; it does not access or change the target interface. Physical hardware controls and full accessibility conformance are outside the scope.

## 2. Knowledge engineering

### Source documents

The primary rule source is the W3C [*Web Content Accessibility Guidelines (WCAG) 2.2*](https://www.w3.org/TR/WCAG22/). For desktop and mobile applications, interpretations come from the W3C [*Guidance on Applying WCAG 2 to Non-Web Information and Communications Technologies (WCAG2ICT)*](https://www.w3.org/TR/wcag2ict-22/). WCAG2ICT is an informative Group Note rather than a conformance standard. The [rule-to-source table](RULES_AND_SOURCES.md) links each of the 20 rules to its WCAG success criterion and identifies important native-app conditions. No interview answers are presented as source material.

### Facts and rules

`knowledge_base.pl` contains **50 domain facts**:

| Fact type | Count | Example |
| --- | ---: | --- |
| `criterion/11` | 20 | WCAG number, question, applicability features, action, source fragment |
| `feature/3` | 17 | Interactive controls, input fields, platform keyboard service |
| `threshold/2` | 6 | Text contrast 4.5:1; reflow width 320 CSS pixels |
| `interface_type/2` | 3 | Web, desktop, mobile |
| `extra_gate/3` | 4 | Native keyboard and title-property conditions |

`inference_engine.pl` has **20 explicit `issue_rule/4` IF–THEN clauses**, `r01` to `r20`. Each pairs one criterion with its failed observation. The system also has general clauses for applicability, non-applicability, recommendations, and results. An example is:

> IF the reviewer chose a desktop app, interactive controls exist, the platform provides a keyboard interface, and a function is not keyboard-operable, THEN `r09` flags a possible issue related to WCAG 2.1.1.

Questions intentionally summarize complex criteria. Reviewers must consult the linked W3C text for exceptions and formal decisions.

### Uncertainty and type-dependent applicability

Questionnaire answers are `yes`, `no`, or `unknown`; the interface type is `web`, `desktop`, `mobile`, or `unknown`. The engine does not infer a pass from an absent answer. The type must be known before any check becomes applicable. For desktop and mobile software, keyboard-operation, keyboard-trap, and keyboard-focus visibility checks also require a platform keyboard service. The title check requires a platform title property. The web version of those checks uses ordinary WCAG wording without these native gates. WCAG2ICT also informs the wording of text resize and reflow questions for software platforms.

## 3. Architecture and inference engine

```text
Human inspection of one interface
             ↓
Browser questionnaire: type + features + observations
             ↓ JSON
Local SWI-Prolog HTTP server
             ↓
Knowledge base and 20 rules
             ↓
Forward chaining → results, actions, trace
Backward goal query → proof or unproved result
```

The browser receives definitions from `/api/knowledge`, submits answers to `/api/evaluate`, and requests a goal proof from `/api/prove`. The server binds to localhost and stores no review history.

### Forward chaining

`forward_chain/3` begins with the reported observations. It repeatedly derives new conclusions until no more can be added:

1. Infer `applicable(Criterion)` when the interface type is known and every required feature is Yes.
2. Infer `not_applicable(Criterion)` when a required feature is No.
3. Apply the corresponding explicit issue rule when an applicable check is answered No.
4. Infer a recommendation from each issue.

Every inference records its rule, conclusion, and premises. The final result for each criterion is **Possible issue**, **Not applicable**, **No issue reported**, or **Needs review**.

### Backward chaining

`prove_issue/3` starts from one requested issue goal. It proves the chosen interface type and required feature observations, then checks the criterion's No answer against the issue rule. If a premise is missing, the goal remains unproved. An unproved issue can mean a pass, a non-applicable criterion, or insufficient answers.

## 4. User interface and flow

The user chooses web, desktop, or mobile; describes the interface; answers 20 selected checks; and reviews the outcomes. Native-only feature questions appear only for desktop and mobile. Each result has a criterion source link; native results also link to WCAG2ICT guidance. A separate goal control runs backward chaining, and an expandable list shows the forward trace. The [README](README.md) contains installation and usage steps.

## 5. Test cases and actual results

The test suite was run with SWI-Prolog using `bash test.sh`. **All 18 automated tests passed.** Its 20 independent fixtures each exercise one explicit rule with the necessary features present and the target observation set to No.

| Case | Inputs | Expected | Actual |
| --- | --- | --- | --- |
| All 20 issue rules | Web type; each rule's relevant feature Yes and check No | Every `r01`–`r20` fires in its own fixture | Passed |
| Unknown answers | No type or check answers | 20 Needs review; zero passes | Passed |
| Feature absent | Web; informative images No; alternative text No | WCAG 1.1.1 Not applicable | Passed |
| Check answered Yes | Web; informative images Yes; alternative text Yes | No issue reported for 1.1.1 | Passed |
| Multiple findings | Web; alternative text, keyboard operation, title answered No with gates satisfied | Three possible issues | Passed |
| Error suggestion safety exception | Mobile; error and known correction Yes; safe suggestion No | 3.3.3 Not applicable | Passed |
| Forward order | Web; informative image Yes; text alternative No | Applicability appears before issue | Passed |
| Backward proof | Desktop; informative image Yes; text alternative No | `r01` goal proven | Passed |
| Type omitted | Title check No; no type | Needs review, no issue | Passed |
| Web title | Web; native title property No; descriptive title No | `r11` still fires | Passed |
| Native title unavailable | Desktop; title property No; title answer No | Not applicable | Passed |
| Native title available | Mobile; title property Yes; title answer No | `r11` fires | Passed |
| Native keyboard unavailable | Mobile; keyboard service No; function not keyboard-operable | 2.1.1 Not applicable | Passed |
| Native keyboard available | Desktop; keyboard service Yes; function not keyboard-operable | `r09` fires | Passed |
| Native source | Desktop; language check No | Result links to WCAG2ICT | Passed |
| Knowledge identifiers | Inspect criteria, facts, rule IDs and source fragments | 50 facts, 20 rules, unique IDs | Passed |

An integration check confirmed that `/api/knowledge` returns three interface types, 20 criteria, and 50 facts; a desktop evaluation returned `r09` with the WCAG2ICT guidance link. Browser checks confirmed that native-only feature questions appear for desktop/mobile, are hidden for web, and that a desktop keyboard finding and its backward proof display correctly.

## 6. Limitations and future work

The adviser depends on accurate human observations and covers only 20 selected criteria. Its Yes/No questions simplify detailed normative requirements and cannot determine complete WCAG conformance. Some platform capabilities and assistive-technology behaviour require expert testing. Future work could add more criteria, platform-specific questions, saved review reports, and optional automated checks while retaining human judgment.

## References

1. World Wide Web Consortium. [*Web Content Accessibility Guidelines (WCAG) 2.2*](https://www.w3.org/TR/WCAG22/). W3C Recommendation, 12 December 2024.
2. World Wide Web Consortium. [*Guidance on Applying WCAG 2 to Non-Web Information and Communications Technologies (WCAG2ICT)*](https://www.w3.org/TR/wcag2ict-22/). W3C Group Note.
