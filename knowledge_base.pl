:- module(knowledge_base, [criterion/11, feature/3, threshold/2,
                           interface_type/2, extra_gate/3, knowledge_counts/3]).

% Each criterion is a sourced domain fact for a web, desktop, or mobile
% software interface:
% criterion(Key, WCAGNumber, Title, Level, Group, RequiredFeatures,
%           AnswerKey, Question, Help, SuggestedAction, WCAGFragment).
% A "no" answer to a criterion question is evaluated by its named rule in
% inference_engine.pl. WCAG2ICT guides non-web interpretation. These selected
% checks are not full WCAG conformance or a hardware accessibility review.

interface_type(web, 'Website or web app').
interface_type(desktop, 'Desktop application').
interface_type(mobile, 'Mobile application').

% Additional gates apply only to native desktop/mobile software. For web
% content, the browser supplies the relevant keyboard and title facilities.
extra_gate(c211, native, keyboard_service).
extra_gate(c212, native, keyboard_service).
extra_gate(c247, native, keyboard_service).
extra_gate(c242, native, title_property_supported).

criterion(c111, '1.1.1', 'Non-text Content', 'A', 'Content',
          [informative_images], alt_text,
          'Does each informative image, icon, or other non-text item have an equivalent text alternative?',
          'Exclude purely decorative items. Check the meaning exposed to assistive technology, not merely whether a label exists.',
          'Add an equivalent text alternative to each informative non-text item.',
          'non-text-content').

criterion(c131, '1.3.1', 'Info and Relationships', 'A', 'Content',
          [visual_structure], programmatic_structure,
          'Can visual structure and relationships be determined programmatically or from available text?',
          'Check headings, groups, labels, lists, and table relationships, not only their visual appearance.',
          'Use semantic markup, platform accessibility information, or text to convey the structure and relationships.',
          'info-and-relationships').

criterion(c133, '1.3.3', 'Sensory Characteristics', 'A', 'Content',
          [instructions], sensory_independent,
          'Can users follow the instructions without relying only on shape, colour, size, position, or sound?',
          'For example, "press the green button on the right" needs another identifying cue in a web, desktop, or mobile interface.',
          'Identify controls and information with text or another non-sensory cue.',
          'sensory-characteristics').

criterion(c141, '1.4.1', 'Use of Color', 'A', 'Presentation',
          [colour_conveys_information], colour_not_only_cue,
          'Is information conveyed by colour also available through another visual cue?',
          'Consider errors, required fields, charts, and status indicators.',
          'Add text, patterns, shapes, or another visual cue alongside colour.',
          'use-of-color').

criterion(c143, '1.4.3', 'Contrast (Minimum)', 'AA', 'Presentation',
          [text_content], text_contrast_ok,
          'Does applicable normal text meet 4.5:1 contrast and large text meet 3:1?',
          'Use a contrast checker. WCAG includes exceptions such as incidental text and logos.',
          'Adjust applicable text and background colours to meet the WCAG contrast threshold.',
          'contrast-minimum').

criterion(c144, '1.4.4', 'Resize Text', 'AA', 'Presentation',
          [text_content], text_resizes,
          'Can text enlarge without loss of content or functionality, to 200% or to the platform-supported limit?',
          'For web content use 200%. WCAG2ICT recommends that native software support platform text sizing where its limit is lower. Captions and images of text are excluded.',
          'Support the applicable text enlargement or platform text settings without clipping or loss of function.',
          'resize-text').

criterion(c1410, '1.4.10', 'Reflow', 'AA', 'Presentation',
          [], reflow_ok,
          'When the view is narrowed or scaled, does applicable content remain usable without two-dimensional scrolling?',
          'Test 320 CSS-pixel equivalent width (or 256 height for horizontal content) when supported; otherwise use the nearest supported size. Layouts needing two dimensions for meaning are excepted.',
          'Adapt the layout so applicable content reflows without losing information or function.',
          'reflow').

criterion(c1411, '1.4.11', 'Non-text Contrast', 'AA', 'Presentation',
          [visual_controls], nontext_contrast_ok,
          'Do required visual controls, states, and graphical information meet 3:1 contrast against adjacent colours?',
          'Check the visible information needed to identify a control, state, or meaningful graphic.',
          'Increase contrast of required controls, states, or graphical information.',
          'non-text-contrast').

criterion(c211, '2.1.1', 'Keyboard', 'A', 'Interaction',
          [interactive_controls], keyboard_operable,
          'Can all applicable interface functions be operated through a keyboard interface?',
          'Test buttons, menus, and dialogs. For native software this check applies when the platform provides a device-independent keyboard service.',
          'Provide keyboard operation for every applicable function.',
          'keyboard').

criterion(c212, '2.1.2', 'No Keyboard Trap', 'A', 'Interaction',
          [focusable_controls], focus_can_leave,
          'Can keyboard focus leave every interface component using the keyboard?',
          'If a special method is needed to leave a component, the user must be told how.',
          'Remove the keyboard trap or clearly explain the required exit method.',
          'no-keyboard-trap').

criterion(c242, '2.4.2', 'Page or View Titled', 'A', 'Navigation',
          [], view_title_descriptive,
          'Does the page, window, or screen have a programmatic title that describes its topic or purpose?',
          'For web, inspect the page title. For native software, this applies where the platform supports a title property for windows or screens.',
          'Give the page, window, or screen a descriptive programmatic title.',
          'page-titled').

criterion(c243, '2.4.3', 'Focus Order', 'A', 'Navigation',
          [focusable_controls], focus_order_ok,
          'Does sequential focus order preserve meaning and operability?',
          'Use keyboard or assistive-technology focus navigation as supported by the interface.',
          'Arrange focus in a sequence that preserves meaning and operation.',
          'focus-order').

criterion(c244, '2.4.4', 'Link Purpose (In Context)', 'A', 'Navigation',
          [links], link_purpose_clear,
          'Can users determine each hyperlink-style control\'s purpose from its text or programmatically determined context?',
          'In native software, this applies to controls that behave like hypertext links.',
          'Use link text or associated context that identifies each link\'s purpose.',
          'link-purpose-in-context').

criterion(c246, '2.4.6', 'Headings and Labels', 'AA', 'Navigation',
          [headings_or_labels], headings_labels_descriptive,
          'Do headings and labels describe their topic or purpose?',
          'Check the wording of headings and form or control labels.',
          'Rewrite headings and labels so they describe their topic or purpose.',
          'headings-and-labels').

criterion(c247, '2.4.7', 'Focus Visible', 'AA', 'Navigation',
          [focusable_controls], focus_visible,
          'Is the keyboard focus indicator visible when navigating controls?',
          'Use a keyboard interface to inspect the visible focus indicator. For native software, this check requires platform keyboard support.',
          'Provide a visible keyboard focus indicator.',
          'focus-visible').

criterion(c253, '2.5.3', 'Label in Name', 'A', 'Interaction',
          [visibly_labelled_controls], name_contains_label,
          'Does each applicable control\'s accessible name contain its visible text label?',
          'This matters for controls with visible text labels and speech input.',
          'Include the visible label text in the control\'s accessible name.',
          'label-in-name').

criterion(c311, '3.1.1', 'Interface Language', 'A', 'Language and forms',
          [], interface_language_exposed,
          'Can software determine the default human language of the interface?',
          'For web, inspect the document language. For native software, inspect the platform locale or an accessibility-supported language method.',
          'Expose the interface\'s default human language through an appropriate platform or markup method.',
          'language-of-page').

criterion(c331, '3.3.1', 'Error Identification', 'A', 'Language and forms',
          [auto_detected_errors], errors_identified,
          'When the interface detects an input error, does it identify the affected item and describe the error in text?',
          'This applies only when an input error is automatically detected.',
          'Identify the affected input and describe its error in text.',
          'error-identification').

criterion(c332, '3.3.2', 'Labels or Instructions', 'A', 'Language and forms',
          [input_fields], inputs_labelled,
          'Are labels or instructions provided wherever the interface requires user input?',
          'Test each field or other user-input control.',
          'Provide labels or instructions for required user input.',
          'labels-or-instructions').

criterion(c333, '3.3.3', 'Error Suggestion', 'AA', 'Language and forms',
          [auto_detected_errors, correction_known, suggestion_safe], correction_suggested,
          'When a known, safe correction exists for a detected error, does the interface suggest it?',
          'WCAG permits an exception when a suggestion would jeopardize security or the purpose of the content.',
          'Offer a known correction suggestion when it is safe and appropriate.',
          'error-suggestion').

% Additional source-grounded domain facts used to explain numerical checks.
threshold(normal_text_contrast, 4.5).
threshold(large_text_contrast, 3.0).
threshold(non_text_contrast, 3.0).
threshold(resize_text_percent, 200).
threshold(reflow_width_css_pixels, 320).
threshold(reflow_height_css_pixels, 256).

feature(informative_images, 'Informative non-text content',
        'The interface contains an image, icon, chart, or other non-text item that conveys information.').
feature(visual_structure, 'Visual structure or relationships',
        'The interface conveys structure through visual formatting, headings, tables, lists, groups, or labels.').
feature(instructions, 'Instructions',
        'The interface gives instructions for understanding content or operating controls.').
feature(colour_conveys_information, 'Colour conveys information',
        'The interface uses colour to indicate status, an action, a distinction, or required information.').
feature(text_content, 'Text content',
        'The interface has text to evaluate for contrast and resizing.').
feature(visual_controls, 'Visual controls or meaningful graphics',
        'The interface has visible controls, states, icons, or graphical information that needs contrast.').
feature(interactive_controls, 'Interactive functions',
        'The interface has menus, buttons, dialogs, or other interactive functions.').
feature(focusable_controls, 'Sequentially focusable controls',
        'The interface has controls that receive sequential keyboard or assistive-technology focus.').
feature(links, 'Hyperlink-style controls',
        'The interface contains links or controls that behave like hypertext links.').
feature(headings_or_labels, 'Headings or labels',
        'The interface contains headings or visible labels.').
feature(visibly_labelled_controls, 'Controls with visible text labels',
        'At least one control has a visible label containing text.').
feature(auto_detected_errors, 'Automatically detected form errors',
        'The interface can automatically detect an input error.').
feature(input_fields, 'User-input fields',
        'The interface asks the user to enter information.').
feature(correction_known, 'Known correction suggestions',
        'A useful suggestion for correcting a detected error is known.').
feature(suggestion_safe, 'Suggestions are safe and appropriate',
        'Giving the correction would not jeopardize security or the purpose of the content.').
feature(keyboard_service, 'Platform keyboard service',
        'For a native app, the platform supplies device-independent keyboard input to this software.').
feature(title_property_supported, 'Platform title property',
        'For a native app, the platform supports a programmatic title or name for windows or screens.').

knowledge_counts(Criteria, DomainFacts, IssueRules) :-
    aggregate_all(count, criterion(_,_,_,_,_,_,_,_,_,_,_), Criteria),
    aggregate_all(count, feature(_,_,_), FeatureFacts),
    aggregate_all(count, threshold(_,_), ThresholdFacts),
    aggregate_all(count, interface_type(_,_), Types),
    aggregate_all(count, extra_gate(_,_,_), Gates),
    DomainFacts is Criteria + FeatureFacts + ThresholdFacts + Types + Gates,
    IssueRules = Criteria.
