:- module(web_server, [start_server/1, stop_server/1]).

:- use_module('knowledge_base.pl').
:- use_module('inference_engine.pl').
:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_json)).
:- use_module(library(http/http_files)).

:- dynamic project_root/1.
:- prolog_load_context(directory, Directory), asserta(project_root(Directory)).

:- http_handler(root(.), home, []).
:- http_handler(root('app.js'), javascript, []).
:- http_handler(root('style.css'), stylesheet, []).
:- http_handler(root('api/knowledge'), knowledge_api, []).
:- http_handler(root('api/evaluate'), evaluate_api, []).
:- http_handler(root('api/prove'), prove_api, []).

web_file(Name, Path) :-
    project_root(Root),
    directory_file_path(Root, web, WebDirectory),
    directory_file_path(WebDirectory, Name, Path).

% These paths are fixed by the application, not supplied by the request.
home(Request) :- web_file('index.html', Path), http_reply_file(Path, [unsafe(true)], Request).
javascript(Request) :- web_file('app.js', Path), http_reply_file(Path, [unsafe(true)], Request).
stylesheet(Request) :- web_file('style.css', Path), http_reply_file(Path, [unsafe(true)], Request).

knowledge_api(_Request) :-
    findall(_{key:Type,label:Label}, interface_type(Type,Label), InterfaceTypes),
    findall(Item,
            ( feature(Key, Label, Help),
              Item = _{key:Key, label:Label, help:Help} ),
            Features),
    findall(Item,
            ( criterion(Key, Number, Title, Level, Group, Gates, CheckKey,
                        Question, Help, _Advice, Fragment),
              findall(NativeGate, extra_gate(Key,native,NativeGate), NativeGates),
              format(string(Source), 'https://www.w3.org/TR/WCAG22/#~w', [Fragment]),
              Item = _{key:Key, number:Number, title:Title, level:Level,
                       group:Group, gates:Gates, native_gates:NativeGates,
                       check_key:CheckKey,
                       question:Question, help:Help, source:Source} ),
            Criteria),
    knowledge_counts(CriteriaCount, DomainFacts, _),
    issue_rule_count(IssueRules),
    reply_json_dict(_{interface_types:InterfaceTypes,
                      features:Features, criteria:Criteria,
                      knowledge:_{criteria:CriteriaCount,
                                  domain_facts:DomainFacts,
                                  issue_rules:IssueRules}}).

evaluate_api(Request) :-
    ( memberchk(method(post), Request),
      catch(http_read_json_dict(Request, Input), _, fail),
      get_dict(answers, Input, Answers), is_dict(Answers)
    -> evaluate(Answers, Output), reply_json_dict(Output)
    ;  reply_json_dict(_{error:'Send POST JSON with an answers object.'},
                       [status(400)])
    ).

prove_api(Request) :-
    ( memberchk(method(post), Request),
      catch(http_read_json_dict(Request, Input), _, fail),
      get_dict(answers, Input, Answers), is_dict(Answers),
      get_dict(criterion, Input, Requested),
      ( atom(Requested) -> Key = Requested
      ; string(Requested) -> atom_string(Key, Requested) ),
      criterion(Key,_,_,_,_,_,_,_,_,_,_)
    -> prove_issue(Key, Answers, Proof), reply_json_dict(Proof)
    ;  reply_json_dict(_{error:'Send POST JSON with a valid criterion and answers object.'},
                       [status(400)])
    ).

start_server(Port) :-
    integer(Port), Port > 0, Port < 65536,
    http_server(http_dispatch, [port(localhost:Port)]).

stop_server(Port) :- http_stop_server(localhost:Port, []).

main :-
    current_prolog_flag(argv, Arguments),
    ( Arguments = [PortText|_], catch(atom_number(PortText, Port), _, fail)
    -> true ; Port = 8080 ),
    start_server(Port),
    format('Digital Interface Accessibility Adviser: http://localhost:~w/~n', [Port]),
    format('Press Ctrl+C to stop.~n'),
    thread_get_message(stop).

:- initialization(main, main).
