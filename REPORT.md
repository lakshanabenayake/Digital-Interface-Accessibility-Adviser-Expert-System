# Website Accessibility Adviser Expert System

## 1. Domain and objective

The selected domain is **website accessibility**. The system helps a human reviewer examine one webpage against 20 selected Level A and AA success criteria from the [W3C Web Content Accessibility Guidelines (WCAG) 2.2](https://www.w3.org/TR/WCAG22/). Its output is a set of possible issues, suggested actions, source links, and explanations. It is useful internationally because its knowledge source is a web standard rather than local law or policy.

The system is deliberately **read-only**. It neither visits the target page nor changes its code. The reviewer supplies observations through a guided questionnaire. The system does not replace a full accessibility audit or make a conformance claim.

## 2. Knowledge engineering

### Knowledge source and acquisition

Knowledge was extracted from the W3C WCAG 2.2 Recommendation, especially the 20 linked success criteria listed in [RULES_AND_SOURCES.md](RULES_AND_SOURCES.md). No interview answers or invented expert claims are used. Each selected criterion was turned into:

1. A short question the reviewer can answer Yes, No, or Not sure.
2. Zero or more page-feature conditions that determine whether the check applies.
3. An explicit rule that flags a possible issue when the feature applies and the answer is No.
4. A suggested action and a direct link to the normative criterion.

The knowledge base also stores numerical values used by several checks, such as contrast ratios and viewport sizes. The wording of the questions is simplified for learning purposes. The W3C source remains authoritative when a criterion has exceptions or interpretation details.

### Knowledge representation

`knowledge_base.pl` contains **20 `criterion/11` facts**, **15 `feature/3` facts**, and **six `threshold/2` facts**: **41 domain facts** in total. `inference_engine.pl` contains **20 explicit `issue_rule/4` clauses**, named `r01` through `r20`. The full one-to-one mapping from rules to W3C source sections is in [RULES_AND_SOURCES.md](RULES_AND_SOURCES.md).

An example rule, expressed in ordinary language, is:

> IF informative non-text content is present AND its equivalent text alternative is absent, THEN flag a possible WCAG 1.1.1 issue and advise adding equivalent alternative text.

The corresponding Prolog rule is `r01`. It requires both `applicable(c111)` and `obs(alt_text,no)`. A single No answer is therefore insufficient if applicability has not been established.

### Handling uncertainty and exceptions

The system uses three-valued questionnaire answers: `yes`, `no`, and `unknown`. An unanswered or Not sure response remains unknown. It is never treated as a pass. A known absent page feature produces *Not applicable* for its dependent checks. For WCAG 3.3.3, the rule requires an automatically detected error, a known correction, and a safe, appropriate suggestion; the safety condition reflects the criterion's exception.

## 3. Architecture and inference engine

```text
Human review of one webpage
          ↓
Questionnaire (HTML/CSS/JavaScript)
          ↓ JSON answers
Local SWI-Prolog HTTP server
          ↓
Knowledge base + 20 issue rules
          ↓
Forward chain → results, advice, rule trace
Backward goal query → proof or unproved result
```

The browser interface requests the question and feature definitions from `/api/knowledge`, submits answers to `/api/evaluate`, and can request a proof from `/api/prove`. The server binds to localhost. It stores no review history and does not send target-page information to an external service.

### Forward chaining

`forward_chain/3` begins with the questionnaire observations. It repeatedly adds consequences until no new conclusion can be added:

1. If every required feature for a criterion is Yes, infer `applicable(Criterion)`.
2. If a required feature is No, infer `not_applicable(Criterion)`.
3. If an applicable criterion's explicit issue rule has a No check answer, infer `issue(Criterion)`.
4. If an issue exists, infer `recommendation(Criterion)`.

Each inference records its rule name, conclusion, and premises. A result is classified as *Possible issue*, *Not applicable*, *No issue reported*, or *Needs review*. The trace is displayed in the interface.

### Backward chaining

`prove_issue/3` starts from a user-selected goal such as `issue(c111)`. It looks for the relevant `issue_rule/4`, proves its applicability subgoal from the required feature observations, and checks the No answer. If every premise is present, it returns the rule and supporting answers. Otherwise it reports that the current answers do not prove the issue; this can mean the check passed, is not applicable, or still needs review.

## 4. User interface and flow

The user first describes which page features exist, then answers the 20 criterion questions. The results view presents all 20 outcomes, counts by state, a W3C source link for each check, an action for possible issues, and an expandable forward trace. A separate control asks why a chosen issue was flagged through backward chaining. A reset button clears the review. The [README.md](README.md) gives installation and use instructions.

The interface uses labelled native select controls, grouped questions, a skip link, visible focus styling, and a live results region. These help with its own usability, but the interface has not been certified as WCAG conformant.

## 5. Test cases and observed results

The automated test suite is `tests.pl`. It was run with SWI-Prolog 10.0.2 using:

```text
swipl -q -s tests.pl -g run_tests -t halt
```

The 20 individual issue fixtures cover every rule `r01`–`r20`. Each fixture supplies the required page features as Yes and the associated criterion check as No. The suite also covers these decision paths:

| Case | Inputs | Expected result | Observed result / explanation |
| --- | --- | --- | --- |
| 20 individual issue cases | Required feature(s) Yes; target check No | Each of `r01`–`r20` flags its own criterion | Passed: all 20 rules fired in their respective fixtures. |
| Unknown answers | All answers omitted | 20 Needs review; zero passes | Passed: 20 Needs review, zero No issue reported. |
| Absent feature | Informative images No; alternative text No | WCAG 1.1.1 Not applicable; no issue | Passed: applicability gate prevented `r01`. |
| Passing check | Informative images Yes; alternative text Yes | WCAG 1.1.1 No issue reported | Passed: the check was applicable and answered Yes. |
| Multiple issues | Image Yes/alt text No; interactive controls Yes/keyboard No; page title No | Three possible issues | Passed: `r01`, `r09`, and `r11` yielded three findings. |
| Error-suggestion exception | Detected errors Yes; correction known Yes; suggestion safe No; suggestion absent | WCAG 3.3.3 Not applicable | Passed: the safety gate prevented `r20`. |
| Forward rule order | Informative images Yes; alternative text No | Applicability before issue | Passed: `applicable(c111)` appeared before `issue(c111)` in the trace. |
| Backward proof success | Informative images Yes; alternative text No; goal WCAG 1.1.1 | Proven by `r01` with both premises | Passed: proof returned `provable=true` and `r01`. |
| Backward proof failure | Informative images No; alternative text No; goal WCAG 1.1.1 | Issue not proven | Passed: proof returned `provable=false`. |
| Knowledge and identifiers | Inspect counts and identifiers | At least 20 facts, exactly 20 issue rules, unique source IDs | Passed: 41 facts, 20 rules, unique criterion numbers and keys. |

An integration check also confirmed the page, JavaScript, stylesheet, and knowledge endpoint returned HTTP 200; evaluation returned 20 result records; and the browser displayed a WCAG 1.1.1 finding with the `r01` explanation and a successful backward proof.

## 6. Limitations and future work

The adviser covers only 20 selected criteria and depends on the reviewer's observations. Its prompts compress complex normative requirements and exceptions into short questions, so a flagged item requires human verification. A Yes answer does not prove the entire criterion passes, and a collection of No issue reported results does not establish WCAG conformance. Future work could add the remaining criteria, more detailed exception questions, saved review reports, and optional automated checks while retaining human review for criteria that require judgment.

## References

1. World Wide Web Consortium. [*Web Content Accessibility Guidelines (WCAG) 2.2*](https://www.w3.org/TR/WCAG22/). W3C Recommendation, 12 December 2024. See the criterion-level references in [RULES_AND_SOURCES.md](RULES_AND_SOURCES.md).
2. SWI-Prolog. [Download and installation information](https://www.swi-prolog.org/Download.html). Runtime used to execute the expert system.
