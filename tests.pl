:- use_module('knowledge_base.pl').
:- use_module('inference_engine.pl').
:- use_module(library(plunit)).

:- begin_tests(accessibility_adviser).

% These fixtures are deliberately independent of the engine's rule clauses.
% Each tests one published criterion with the page feature present and the
% relevant observation answered No.
issue_case(c111, r01, [informative_images-yes, alt_text-no]).
issue_case(c131, r02, [visual_structure-yes, programmatic_structure-no]).
issue_case(c133, r03, [instructions-yes, sensory_independent-no]).
issue_case(c141, r04, [colour_conveys_information-yes, colour_not_only_cue-no]).
issue_case(c143, r05, [text_content-yes, text_contrast_ok-no]).
issue_case(c144, r06, [text_content-yes, text_resizes-no]).
issue_case(c1410, r07, [reflow_ok-no]).
issue_case(c1411, r08, [visual_controls-yes, nontext_contrast_ok-no]).
issue_case(c211, r09, [interactive_controls-yes, keyboard_operable-no]).
issue_case(c212, r10, [focusable_controls-yes, focus_can_leave-no]).
issue_case(c242, r11, [page_title_descriptive-no]).
issue_case(c243, r12, [focusable_controls-yes, focus_order_ok-no]).
issue_case(c244, r13, [links-yes, link_purpose_clear-no]).
issue_case(c246, r14, [headings_or_labels-yes, headings_labels_descriptive-no]).
issue_case(c247, r15, [focusable_controls-yes, focus_visible-no]).
issue_case(c253, r16, [visibly_labelled_controls-yes, name_contains_label-no]).
issue_case(c311, r17, [page_language_set-no]).
issue_case(c331, r18, [auto_detected_errors-yes, errors_identified-no]).
issue_case(c332, r19, [input_fields-yes, inputs_labelled-no]).
issue_case(c333, r20, [auto_detected_errors-yes, correction_known-yes,
                       suggestion_safe-yes, correction_suggested-no]).

test(knowledge_base_has_required_counts) :-
    knowledge_counts(20, DomainFacts, _),
    DomainFacts >= 20,
    issue_rule_count(20).

test(all_20_rules_fire_in_their_individual_case) :-
    findall(Id, issue_case(Id,_,_), Cases),
    length(Cases, 20),
    forall(issue_case(Id, Rule, Pairs),
           ( dict_create(Answers, answers, Pairs),
             evaluate(Answers, Output),
             member(Result, Output.results), Result.key == Id,
             Result.status == possible_issue,
             Result.rule_id == Rule )).

test(unknown_answers_are_not_counted_as_passes) :-
    evaluate(_{}, Output),
    Output.counts.needs_review == 20,
    Output.counts.no_issue_reported == 0.

test(absent_feature_is_not_applicable) :-
    evaluate(_{informative_images:no, alt_text:no}, Output),
    once((member(Result, Output.results), Result.key == c111)),
    Result.status == not_applicable,
    Output.counts.possible_issue == 0.

test(answered_yes_reports_no_issue_for_that_check) :-
    evaluate(_{informative_images:yes, alt_text:yes}, Output),
    once((member(Result, Output.results), Result.key == c111)),
    Result.status == no_issue_reported.

test(multiple_independent_findings) :-
    evaluate(_{informative_images:yes, alt_text:no,
               interactive_controls:yes, keyboard_operable:no,
               page_title_descriptive:no}, Output),
    Output.counts.possible_issue == 3.

test(error_suggestion_exception_does_not_flag) :-
    evaluate(_{auto_detected_errors:yes, correction_known:yes,
               suggestion_safe:no, correction_suggested:no}, Output),
    once((member(Result, Output.results), Result.key == c333)),
    Result.status == not_applicable.

test(applicability_precedes_issue_in_forward_trace) :-
    evaluate(_{informative_images:yes, alt_text:no}, Output),
    once((nth0(AppIndex, Output.trace, AppStep),
          AppStep.conclusion == "applicable(c111)")),
    once((nth0(IssueIndex, Output.trace, IssueStep),
          IssueStep.conclusion == "issue(c111)")),
    AppIndex < IssueIndex.

test(backward_proof_succeeds_with_supporting_facts) :-
    prove_issue(c111, _{informative_images:yes, alt_text:no}, Proof),
    Proof.provable == true,
    Proof.rule == r01.

test(backward_proof_fails_when_condition_is_absent) :-
    prove_issue(c111, _{informative_images:no, alt_text:no}, Proof),
    Proof.provable == false.

test(source_urls_and_rule_ids_are_unique) :-
    findall(Id, criterion(Id,_,_,_,_,_,_,_,_,_,_), Ids),
    sort(Ids, UniqueIds), length(UniqueIds, 20),
    findall(Number, criterion(_,Number,_,_,_,_,_,_,_,_,_), Numbers),
    sort(Numbers, UniqueNumbers), length(UniqueNumbers, 20),
    forall(criterion(_,_,_,_,_,_,_,_,_,_,Fragment),
           ( atom(Fragment), Fragment \== '' )).

:- end_tests(accessibility_adviser).
