# Knowledge base: 20 rules and sources

**Primary source:** W3C, [*Web Content Accessibility Guidelines (WCAG) 2.2*](https://www.w3.org/TR/WCAG22/), W3C Recommendation, 12 December 2024. **Non-web interpretation:** W3C, [*Guidance on Applying WCAG 2 to Non-Web Information and Communications Technologies (WCAG2ICT)*](https://www.w3.org/TR/wcag2ict-22/), W3C Group Note. WCAG2ICT is informative guidance and does not itself set conformance requirements.

The adviser reviews software user interfaces: websites/web apps, desktop apps, and mobile apps. It does not assess hardware. The rules below use short, operational questions based on selected WCAG criteria. They are not quotations or complete replacements for the W3C texts. Each rule fires only when its check **applies** and the reviewer answers **No**. If a required feature is absent, the result is *Not applicable*; if the interface type or required answer is unknown, the result is *Needs review*.

| Rule | W3C criterion | IF the applicable check fails | THEN suggest |
| --- | --- | --- | --- |
| `r01` | [1.1.1 Non-text Content](https://www.w3.org/TR/WCAG22/#non-text-content) | Informative non-text content lacks an equivalent text alternative. | Add an equivalent text alternative through markup or the platform accessibility API. |
| `r02` | [1.3.1 Info and Relationships](https://www.w3.org/TR/WCAG22/#info-and-relationships) | Visual structure or relationships are unavailable programmatically or in text. | Expose the structure through semantic markup, platform accessibility information, or text. |
| `r03` | [1.3.3 Sensory Characteristics](https://www.w3.org/TR/WCAG22/#sensory-characteristics) | Instructions rely only on shape, colour, size, position, or sound. | Add a non-sensory identifying cue. |
| `r04` | [1.4.1 Use of Color](https://www.w3.org/TR/WCAG22/#use-of-color) | Colour alone conveys information. | Add another visual cue. |
| `r05` | [1.4.3 Contrast (Minimum)](https://www.w3.org/TR/WCAG22/#contrast-minimum) | Applicable normal or large text misses its contrast threshold. | Adjust text/background contrast. |
| `r06` | [1.4.4 Resize Text](https://www.w3.org/TR/WCAG22/#resize-text) | Text cannot enlarge without loss at the applicable size. | Support 200% for web, or the applicable platform-supported extent for native software. |
| `r07` | [1.4.10 Reflow](https://www.w3.org/TR/WCAG22/#reflow) | Applicable content loses information/function or requires two-dimensional scrolling when narrowed or scaled. | Make the content reflow at the specified or nearest supported size. |
| `r08` | [1.4.11 Non-text Contrast](https://www.w3.org/TR/WCAG22/#non-text-contrast) | Required visual controls, states, or graphics miss 3:1 contrast. | Increase their contrast. |
| `r09` | [2.1.1 Keyboard](https://www.w3.org/TR/WCAG22/#keyboard) | An applicable function cannot be operated through a keyboard interface. | Provide keyboard operation. |
| `r10` | [2.1.2 No Keyboard Trap](https://www.w3.org/TR/WCAG22/#no-keyboard-trap) | Keyboard focus cannot leave a component. | Remove the trap or explain the exit method. |
| `r11` | [2.4.2 Page Titled](https://www.w3.org/TR/WCAG22/#page-titled) | A web page, native window, or native screen lacks a descriptive programmatic title. | Supply a descriptive title using the available platform facility. |
| `r12` | [2.4.3 Focus Order](https://www.w3.org/TR/WCAG22/#focus-order) | Sequential focus order does not preserve meaning and operation. | Correct the focus sequence. |
| `r13` | [2.4.4 Link Purpose (In Context)](https://www.w3.org/TR/WCAG22/#link-purpose-in-context) | A hyperlink-style control's purpose is unclear from text or context. | Improve its text or programmatically determined context. |
| `r14` | [2.4.6 Headings and Labels](https://www.w3.org/TR/WCAG22/#headings-and-labels) | Headings or labels do not describe topic or purpose. | Rewrite them descriptively. |
| `r15` | [2.4.7 Focus Visible](https://www.w3.org/TR/WCAG22/#focus-visible) | Keyboard focus has no visible indicator. | Provide a visible focus indicator. |
| `r16` | [2.5.3 Label in Name](https://www.w3.org/TR/WCAG22/#label-in-name) | A control's accessible name omits its visible text label. | Include the visible label in the accessible name. |
| `r17` | [3.1.1 Language of Page](https://www.w3.org/TR/WCAG22/#language-of-page) | The interface's default human language cannot be determined programmatically. | Expose its language through markup, locale, or an accessibility-supported method. |
| `r18` | [3.3.1 Error Identification](https://www.w3.org/TR/WCAG22/#error-identification) | A detected input error lacks text identifying the item and describing the problem. | Identify the item and error in text. |
| `r19` | [3.3.2 Labels or Instructions](https://www.w3.org/TR/WCAG22/#labels-or-instructions) | Required user input lacks a label or instruction. | Provide labels or instructions. |
| `r20` | [3.3.3 Error Suggestion](https://www.w3.org/TR/WCAG22/#error-suggestion) | A known, safe correction is not suggested for a detected error. | Offer an appropriate correction suggestion. |

## Applicability by interface type

- **All three types:** The ordinary feature gates apply. For example, `r13` requires hyperlink-style controls; `r18` requires automatically detected errors.
- **Desktop and mobile apps:** `r09`, `r10`, and `r15` additionally require a platform device-independent keyboard service. [WCAG2ICT explains this condition for non-web software](https://www.w3.org/TR/wcag2ict-22/).
- **Desktop and mobile apps:** `r11` additionally requires a platform title property for windows or screens. WCAG2ICT recommends this [software-specific interpretation of 2.4.2](https://www.w3.org/TR/wcag2ict-22/).
- **Text resizing and reflow:** For native software, the reviewer considers platform capabilities and relevant exceptions described in WCAG2ICT. A short questionnaire cannot resolve every technical detail.

The knowledge base contains **20 criterion facts, 17 page-feature facts, six threshold facts, three interface-type facts, and four native applicability facts: 50 domain facts total**. The 20 explicit issue rules are in `inference_engine.pl`. General applicability and recommendation clauses are additional inference logic.
