:- module(inference_engine,
          [ evaluate/2,
            prove_issue/3,
            issue_rule/4,
            forward_chain/3,
            issue_rule_count/1
          ]).

:- use_module('knowledge_base.pl').
:- use_module(library(aggregate)).
:- use_module(library(lists)).

% Twenty explicit IF-THEN issue rules. Applicability is inferred first.
% An answer of "no" means the assessor observed a possible failure.
issue_rule(r01, c111, F, [applicable(c111), obs(alt_text,no)]) :-
    memberchk(applicable(c111), F), memberchk(obs(alt_text,no), F).
issue_rule(r02, c131, F, [applicable(c131), obs(programmatic_structure,no)]) :-
    memberchk(applicable(c131), F), memberchk(obs(programmatic_structure,no), F).
issue_rule(r03, c133, F, [applicable(c133), obs(sensory_independent,no)]) :-
    memberchk(applicable(c133), F), memberchk(obs(sensory_independent,no), F).
issue_rule(r04, c141, F, [applicable(c141), obs(colour_not_only_cue,no)]) :-
    memberchk(applicable(c141), F), memberchk(obs(colour_not_only_cue,no), F).
issue_rule(r05, c143, F, [applicable(c143), obs(text_contrast_ok,no)]) :-
    memberchk(applicable(c143), F), memberchk(obs(text_contrast_ok,no), F).
issue_rule(r06, c144, F, [applicable(c144), obs(text_resizes,no)]) :-
    memberchk(applicable(c144), F), memberchk(obs(text_resizes,no), F).
issue_rule(r07, c1410, F, [applicable(c1410), obs(reflow_ok,no)]) :-
    memberchk(applicable(c1410), F), memberchk(obs(reflow_ok,no), F).
issue_rule(r08, c1411, F, [applicable(c1411), obs(nontext_contrast_ok,no)]) :-
    memberchk(applicable(c1411), F), memberchk(obs(nontext_contrast_ok,no), F).
issue_rule(r09, c211, F, [applicable(c211), obs(keyboard_operable,no)]) :-
    memberchk(applicable(c211), F), memberchk(obs(keyboard_operable,no), F).
issue_rule(r10, c212, F, [applicable(c212), obs(focus_can_leave,no)]) :-
    memberchk(applicable(c212), F), memberchk(obs(focus_can_leave,no), F).
issue_rule(r11, c242, F, [applicable(c242), obs(view_title_descriptive,no)]) :-
    memberchk(applicable(c242), F), memberchk(obs(view_title_descriptive,no), F).
issue_rule(r12, c243, F, [applicable(c243), obs(focus_order_ok,no)]) :-
    memberchk(applicable(c243), F), memberchk(obs(focus_order_ok,no), F).
issue_rule(r13, c244, F, [applicable(c244), obs(link_purpose_clear,no)]) :-
    memberchk(applicable(c244), F), memberchk(obs(link_purpose_clear,no), F).
issue_rule(r14, c246, F, [applicable(c246), obs(headings_labels_descriptive,no)]) :-
    memberchk(applicable(c246), F), memberchk(obs(headings_labels_descriptive,no), F).
issue_rule(r15, c247, F, [applicable(c247), obs(focus_visible,no)]) :-
    memberchk(applicable(c247), F), memberchk(obs(focus_visible,no), F).
issue_rule(r16, c253, F, [applicable(c253), obs(name_contains_label,no)]) :-
    memberchk(applicable(c253), F), memberchk(obs(name_contains_label,no), F).
issue_rule(r17, c311, F, [applicable(c311), obs(interface_language_exposed,no)]) :-
    memberchk(applicable(c311), F), memberchk(obs(interface_language_exposed,no), F).
issue_rule(r18, c331, F, [applicable(c331), obs(errors_identified,no)]) :-
    memberchk(applicable(c331), F), memberchk(obs(errors_identified,no), F).
issue_rule(r19, c332, F, [applicable(c332), obs(inputs_labelled,no)]) :-
    memberchk(applicable(c332), F), memberchk(obs(inputs_labelled,no), F).
issue_rule(r20, c333, F, [applicable(c333), obs(correction_suggested,no)]) :-
    memberchk(applicable(c333), F), memberchk(obs(correction_suggested,no), F).

issue_rule_count(Count) :-
    aggregate_all(count, clause(issue_rule(_,_,_,_), _), Count).

% A closed-world answer is never assumed: absent or "unknown" inputs remain
% unresolved. The UI sends answers as a JSON dict; tests can pass a dict too.
observations(AnswerDict, Observations) :-
    dict_pairs(AnswerDict, _, Pairs),
    maplist(pair_observation, Pairs, Observations).

pair_observation(Key-Value, obs(Key, Answer)) :-
    ( Value == yes ; Value == "yes" ), !, Answer = yes.
pair_observation(Key-Value, obs(Key, Answer)) :-
    ( Value == no ; Value == "no" ), !, Answer = no.
pair_observation(interface_type-Value, obs(interface_type, Answer)) :-
    ( Value == web ; Value == "web" ), !, Answer = web.
pair_observation(interface_type-Value, obs(interface_type, Answer)) :-
    ( Value == desktop ; Value == "desktop" ), !, Answer = desktop.
pair_observation(interface_type-Value, obs(interface_type, Answer)) :-
    ( Value == mobile ; Value == "mobile" ), !, Answer = mobile.
pair_observation(Key-_, obs(Key, unknown)).

selected_type(Facts, Type) :-
    memberchk(obs(interface_type,Type), Facts),
    interface_type(Type,_).

required_features(Type, Id, Base, Required) :-
    ( Type == web -> Extras = []
    ; findall(Key, extra_gate(Id,native,Key), Extras) ),
    append(Base, Extras, Required).

all_features_yes([], _).
all_features_yes([Key|Rest], Facts) :-
    memberchk(obs(Key,yes), Facts),
    all_features_yes(Rest, Facts).

% Data-driven applicability is the first inference layer. Issue rules form
% the second layer and recommendations the third layer.
inference(Facts, applicable(Id), applicability(Id), Evidence) :-
    criterion(Id,_,_,_,_,Base,_,_,_,_,_),
    selected_type(Facts, Type),
    required_features(Type, Id, Base, Features),
    all_features_yes(Features, Facts),
    findall(obs(Key,yes), member(Key,Features), FeatureEvidence),
    Evidence = [obs(interface_type,Type)|FeatureEvidence].
inference(Facts, not_applicable(Id), applicability(Id),
          [obs(interface_type,Type),obs(Key,no)]) :-
    criterion(Id,_,_,_,_,Base,_,_,_,_,_),
    selected_type(Facts, Type),
    required_features(Type, Id, Base, Features),
    once((member(Key, Features), memberchk(obs(Key,no), Facts))).
inference(Facts, issue(Id), Rule, Evidence) :-
    issue_rule(Rule, Id, Facts, Evidence).
inference(Facts, recommendation(Id), recommendation(Id), [issue(Id)]) :-
    memberchk(issue(Id), Facts).

forward_chain(InitialFacts, FinalFacts, Trace) :-
    forward_step(InitialFacts, [], FinalFacts, Trace).

forward_step(Facts, AccTrace, FinalFacts, Trace) :-
    findall(step(Rule, Conclusion, Evidence),
            ( inference(Facts, Conclusion, Rule, Evidence),
              \+ memberchk(Conclusion, Facts) ),
            RawSteps),
    sort(RawSteps, Steps),
    ( Steps == [] -> FinalFacts = Facts, Trace = AccTrace
    ; findall(Conclusion, member(step(_,Conclusion,_), Steps), Conclusions),
      append(Facts, Conclusions, NextFacts),
      append(AccTrace, Steps, NextTrace),
      forward_step(NextFacts, NextTrace, FinalFacts, Trace)
    ).

evaluate(AnswerDict, Output) :-
    observations(AnswerDict, Observations),
    forward_chain(Observations, FinalFacts, Trace),
    findall(Result,
            ( criterion(Id,_,_,_,_,_,_,_,_,_,_),
              result_dict(Id, Observations, FinalFacts, Trace, Result) ),
            Results),
    findall(Item, (member(Step,Trace), trace_dict(Step,Item)), TraceItems),
    count_status(Results, possible_issue, Issues),
    count_status(Results, no_issue_reported, NoIssue),
    count_status(Results, not_applicable, NotApplicable),
    count_status(Results, needs_review, NeedsReview),
    knowledge_counts(Criteria, DomainFacts, _),
    issue_rule_count(IssueRules),
    Output = _{ results:Results, trace:TraceItems,
                counts:_{possible_issue:Issues, no_issue_reported:NoIssue,
                         not_applicable:NotApplicable, needs_review:NeedsReview},
                knowledge:_{criteria:Criteria, domain_facts:DomainFacts,
                            issue_rules:IssueRules} }.

count_status(Results, Status, Count) :-
    include(has_status(Status), Results, Matching),
    length(Matching, Count).
has_status(Status, Result) :- Result.status == Status.

result_dict(Id, Observations, Facts, Trace, Result) :-
    criterion(Id, Number, Title, Level, Group, Base, CheckKey,
              Question, _Help, Advice, Fragment),
    ( selected_type(Observations, Type)
    -> required_features(Type, Id, Base, Features)
    ;  Type = unknown, Features = Base ),
    status(Id, CheckKey, Observations, Facts, Status),
    status_explanation(Status, Id, Features, CheckKey, Observations,
                       Trace, Explanation, RuleId, Evidence),
    format(string(Source), 'https://www.w3.org/TR/WCAG22/#~w', [Fragment]),
    ( ( Type == web ; Type == unknown ) -> Guidance = ""
    ; Guidance = "https://www.w3.org/TR/wcag2ict-22/" ),
    Result = _{ key:Id, number:Number, title:Title, level:Level,
                group:Group, question:Question, status:Status,
                rule_id:RuleId, explanation:Explanation,
                evidence:Evidence, advice:Advice, source:Source,
                guidance:Guidance }.

status(Id, _, _, Facts, possible_issue) :- memberchk(issue(Id), Facts), !.
status(Id, _, _, Facts, not_applicable) :- memberchk(not_applicable(Id), Facts), !.
status(Id, CheckKey, Obs, Facts, no_issue_reported) :-
    memberchk(applicable(Id), Facts), memberchk(obs(CheckKey,yes), Obs), !.
status(_, _, _, _, needs_review).

status_explanation(possible_issue, Id, _, _, _, Trace, Explanation, Rule, Evidence) :-
    memberchk(step(Rule,issue(Id),Premises), Trace),
    maplist(evidence_label, Premises, Evidence),
    atomic_list_concat(Evidence, '; ', Joined),
    format(string(Explanation), 'Rule ~w fired because ~w. This is a possible issue requiring review.',
           [Rule,Joined]).
status_explanation(not_applicable, _, Features, _, Obs, _, Explanation, '', Evidence) :-
    member(Key, Features), memberchk(obs(Key,no), Obs), !,
    observation_label(Key, Label),
    format(string(Explanation), 'This check does not apply because you answered No to "~w".', [Label]),
    Evidence = [Explanation].
status_explanation(no_issue_reported, _, _, CheckKey, _, _, Explanation, '', Evidence) :-
    observation_label(CheckKey, Label),
    format(string(Explanation), 'This check applies and you answered Yes to "~w". No issue was reported for this check.', [Label]),
    Evidence = [Explanation].
status_explanation(needs_review, _, _, _, Obs, _,
                   'Choose the interface type before evaluating these checks.', '', []) :-
    \+ selected_type(Obs,_), !.
status_explanation(needs_review, _, Features, CheckKey, Obs, _, Explanation, '', Evidence) :-
    ( member(Key, Features), \+ memberchk(obs(Key,yes), Obs) -> true
    ; Key = CheckKey ),
    observation_label(Key, Label),
    format(string(Explanation), 'Answer "~w" after inspecting the interface to decide this check.', [Label]),
    Evidence = [Explanation].

observation_label(interface_type, 'Interface type') :- !.
observation_label(Key, Label) :- feature(Key, Label, _), !.
observation_label(Key, Label) :- criterion(_,_,_,_,_,_,Key,Label,_,_,_), !.
observation_label(Key, Label) :- atom_string(Key, Label).

evidence_label(obs(Key,Value), Label) :-
    observation_label(Key, Question),
    format(string(Label), '~w = ~w', [Question,Value]).
evidence_label(applicable(Id), Label) :-
    criterion(Id, Number, _, _, _, _, _, _, _, _, _),
    format(string(Label), 'WCAG ~w applies', [Number]).
evidence_label(issue(Id), Label) :-
    criterion(Id, Number, _, _, _, _, _, _, _, _, _),
    format(string(Label), 'WCAG ~w was flagged', [Number]).

trace_dict(step(Rule,Conclusion,Premises), Item) :-
    term_string(Conclusion, ConclusionText),
    term_string(Rule, RuleText),
    maplist(evidence_label, Premises, Evidence),
    Item = _{rule:RuleText, conclusion:ConclusionText, premises:Evidence}.

% Backward chaining starts with a single requested goal and proves its
% applicability subgoal from the observations before trying its issue rule.
prove_issue(Id, AnswerDict, Proof) :-
    observations(AnswerDict, Observations),
    criterion(Id, Number, Title, _, _, Base, _, _, _, _, _),
    ( selected_type(Observations, Type),
      required_features(Type, Id, Base, Features),
      prove_applicable(Features, Observations, FeatureProof),
      issue_rule(Rule, Id, [applicable(Id)|Observations], RuleProof)
    -> append([obs(interface_type,Type)|FeatureProof], RuleProof, RawEvidence),
       sort(RawEvidence, Premises),
       maplist(evidence_label, Premises, Evidence),
       Proof = _{criterion:Number, title:Title, provable:true,
                 rule:Rule, premises:Evidence,
                 explanation:'The applicability facts and the issue-rule condition are both supported by your answers.'}
    ;  Proof = _{criterion:Number, title:Title, provable:false,
                 rule:'', premises:[],
                 explanation:'The current answers do not prove an issue for this criterion. It may be satisfied, not applicable, or still need review.'}
    ).

prove_applicable([], _, []).
prove_applicable([Key|Rest], Observations, [obs(Key,yes)|Evidence]) :-
    memberchk(obs(Key,yes), Observations),
    prove_applicable(Rest, Observations, Evidence).
