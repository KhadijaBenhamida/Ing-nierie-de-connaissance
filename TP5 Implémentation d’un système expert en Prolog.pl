% Symptômes pour patients fictifs
symptome(p1, fievre).
symptome(p1, toux).
symptome(p1, fatigue).

symptome(p2, mal_gorge).
symptome(p2, fievre).

symptome(p3, eternuements).
symptome(p3, nez_qui_coule).

% Diagnostic basé sur les symptômes
diagnostic(Patient, grippe) :-
    symptome(Patient, fievre),
    symptome(Patient, courbatures),
    symptome(Patient, fatigue).

diagnostic(Patient, angine) :-
    symptome(Patient, mal_gorge),
    symptome(Patient, fievre).

diagnostic(Patient, covid) :-
    symptome(Patient, fievre),
    symptome(Patient, toux),
    symptome(Patient, fatigue).

diagnostic(Patient, allergie) :-
    symptome(Patient, eternuements),
    symptome(Patient, nez_qui_coule),
    \+ symptome(Patient, fievre).





:- dynamic(answer/2).

% Questions pour chaque symptôme
question(fievre, 'Avez-vous de la fievre (o/n) ?').
question(toux, 'Avez-vous de la toux (o/n) ?').
question(mal_gorge, 'Avez-vous mal de gorge (o/n) ?').
question(fatigue, 'Ressentez-vous de la fatigue (o/n) ?').
question(courbatures, 'Avez-vous des courbatures (o/n) ?').
question(mal_tete, 'Avez-vous mal de tete (o/n) ?').
question(eternuements, 'Avez-vous des eternuements (o/n) ?').
question(nez_qui_coule, 'Avez-vous le nez qui coule (o/n) ?').

read_yes_no(yes) :-
    read_line_to_string(user_input, S),
    string_lower(S, S2),
    sub_string(S2, 0, 1, _, "o"), !.
read_yes_no(no).

ask_symptom(Symptom) :-
    question(Symptom, Prompt),
    format('~w ', [Prompt]),
    read_yes_no(Resp),
    assertz(answer(Symptom, Resp)).

has_symptom(Symptom) :-
    answer(Symptom, yes), !.
has_symptom(Symptom) :-
    answer(Symptom, no), !, fail.
has_symptom(Symptom) :-
    ask_symptom(Symptom),
    answer(Symptom, yes).

maladie(grippe) :- has_symptom(fievre), has_symptom(courbatures), has_symptom(fatigue).
maladie(angine) :- has_symptom(mal_gorge), has_symptom(fievre).
maladie(covid) :- has_symptom(fievre), has_symptom(toux), has_symptom(fatigue).
maladie(allergie) :- has_symptom(eternuements), has_symptom(nez_qui_coule),
                     (answer(fievre, no) -> true; \+ answer(fievre, yes)).

expert :-
    retractall(answer(_, _)),
    writeln('--- Debut du diagnostic ---'),
    findall(M, maladie(M), Liste),
    afficher_resultats(Liste),
    writeln('--- Fin du diagnostic ---').







disease_symptoms(grippe, [fievre, courbatures, fatigue, toux]).
disease_symptoms(angine, [mal_gorge, fievre]).
disease_symptoms(covid,  [fievre, toux, fatigue]).
disease_symptoms(allergie, [eternuements, nez_qui_coule]).

expliquer(Maladie, Confirmes) :-
    disease_symptoms(Maladie, Symptomes),
    include(symptom_confirmed, Symptomes, Confirmes).

symptom_confirmed(S) :- answer(S, yes).

afficher_resultats([]) :-
    writeln('Aucune maladie probable trouvee.'),
    writeln('Consultez un professionnel de sante si vous etes inquiet.').

afficher_resultats(L) :-
    writeln('Diagnostic(s) possible(s) :'),
    forall(member(M, L),
           (expliquer(M, Confirmes),
            format('- ~w : ~w~n', [M, Confirmes])
           )).
