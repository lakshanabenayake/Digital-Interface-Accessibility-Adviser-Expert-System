# Knowledge base: 20 rules and their sources

**Primary document:** World Wide Web Consortium (W3C), *Web Content Accessibility Guidelines (WCAG) 2.2*, W3C Recommendation, 12 December 2024, <https://www.w3.org/TR/WCAG22/>. The table links each rule directly to its supporting success criterion. The prompts and actions are short operational interpretations for this adviser, not quotations or complete substitutes for the normative text.

For each rule, **IF** the relevant page feature applies **AND** the user answers **No** to the check, **THEN** the system records a *possible issue* and suggests the action shown. For `r07`, `r11`, and `r17`, applicability is unconditional because the checks concern the page itself. A negative required-feature answer instead yields *Not applicable*. Missing or uncertain answers yield *Needs review*.

| Rule | WCAG 2.2 source | IF the applicable check fails | THEN suggest |
| --- | --- | --- | --- |
| `r01` | [1.1.1 Non-text Content](https://www.w3.org/TR/WCAG22/#non-text-content) | Informative non-text content lacks an equivalent text alternative. | Add an equivalent text alternative. |
| `r02` | [1.3.1 Info and Relationships](https://www.w3.org/TR/WCAG22/#info-and-relationships) | Visual structure or relationships cannot be determined programmatically or through text. | Use semantic markup or explanatory text. |
| `r03` | [1.3.3 Sensory Characteristics](https://www.w3.org/TR/WCAG22/#sensory-characteristics) | Instructions rely only on sensory characteristics. | Add a non-sensory identifying cue. |
| `r04` | [1.4.1 Use of Color](https://www.w3.org/TR/WCAG22/#use-of-color) | Colour alone conveys information. | Add another visual cue. |
| `r05` | [1.4.3 Contrast (Minimum)](https://www.w3.org/TR/WCAG22/#contrast-minimum) | Applicable normal or large text misses its contrast threshold. | Adjust text or background contrast. |
| `r06` | [1.4.4 Resize Text](https://www.w3.org/TR/WCAG22/#resize-text) | Text cannot be enlarged to 200% without loss. | Allow resizing without lost content or function. |
| `r07` | [1.4.10 Reflow](https://www.w3.org/TR/WCAG22/#reflow) | Applicable content needs two-dimensional scrolling at the specified viewport size. | Adapt the layout to reflow. |
| `r08` | [1.4.11 Non-text Contrast](https://www.w3.org/TR/WCAG22/#non-text-contrast) | Required visual controls, states, or graphics miss 3:1 contrast. | Increase their contrast. |
| `r09` | [2.1.1 Keyboard](https://www.w3.org/TR/WCAG22/#keyboard) | An applicable function cannot be operated by keyboard. | Provide keyboard operation. |
| `r10` | [2.1.2 No Keyboard Trap](https://www.w3.org/TR/WCAG22/#no-keyboard-trap) | Focus cannot leave a component by keyboard. | Remove the trap or explain the exit method. |
| `r11` | [2.4.2 Page Titled](https://www.w3.org/TR/WCAG22/#page-titled) | The page title does not describe its topic or purpose. | Give the document a descriptive title. |
| `r12` | [2.4.3 Focus Order](https://www.w3.org/TR/WCAG22/#focus-order) | Focus order does not preserve meaning and operation. | Correct the focus sequence. |
| `r13` | [2.4.4 Link Purpose (In Context)](https://www.w3.org/TR/WCAG22/#link-purpose-in-context) | A link's purpose is not clear from text or programmatically determined context. | Improve link text or context. |
| `r14` | [2.4.6 Headings and Labels](https://www.w3.org/TR/WCAG22/#headings-and-labels) | Headings or labels do not describe topic or purpose. | Rewrite them descriptively. |
| `r15` | [2.4.7 Focus Visible](https://www.w3.org/TR/WCAG22/#focus-visible) | Keyboard focus is not visible. | Provide a visible focus indicator. |
| `r16` | [2.5.3 Label in Name](https://www.w3.org/TR/WCAG22/#label-in-name) | A control's accessible name omits its visible text label. | Include the visible label in the accessible name. |
| `r17` | [3.1.1 Language of Page](https://www.w3.org/TR/WCAG22/#language-of-page) | Software cannot determine the page's default human language. | Identify the default language in markup. |
| `r18` | [3.3.1 Error Identification](https://www.w3.org/TR/WCAG22/#error-identification) | A detected error lacks text identifying the item and describing the problem. | Identify the item and error in text. |
| `r19` | [3.3.2 Labels or Instructions](https://www.w3.org/TR/WCAG22/#labels-or-instructions) | Required user input lacks a label or instruction. | Provide labels or instructions. |
| `r20` | [3.3.3 Error Suggestion](https://www.w3.org/TR/WCAG22/#error-suggestion) | A known, safe correction is not suggested for a detected error. | Offer an appropriate correction suggestion. |

## Supporting domain facts

The knowledge base also records 15 page-feature definitions and six numerical facts: normal text contrast **4.5:1**, large text contrast **3:1**, non-text contrast **3:1**, text resize **200%**, reflow width **320 CSS pixels**, and reflow height **256 CSS pixels** for horizontal content. Together with the 20 criterion facts, the knowledge base contains **41 domain facts**. The engine has **20 explicit issue rules**, plus general applicability and recommendation inference clauses.

The chosen 20 criteria are a teaching subset of WCAG 2.2. Other success criteria, techniques, exceptions, and whole-page conformance requirements are outside this system's decision scope.
