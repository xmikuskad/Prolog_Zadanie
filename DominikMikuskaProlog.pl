% Pred pouzitim programu je potrebne nainstalovat pack regex nasledovnym
% prikazom:
% pack_install(regex).
% Tuto kniznicu pouzivam na overenie
% regularnych vyrazoch DD - MM - RR pri datume
:-use_module(library(regex)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mame predikat student,ktory ma 8 argumentov a potrebujeme
% povedat prologu, ze sa pocet jeho klauzul moze menit.
% student(Meno,Priezvisko,StupenStudia,Odbor,Rocnik,DatumPrijatia,
% DatumUkoncenia,Status).
:- dynamic student/8.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Hlavny cyklus programu
% main()

main:-
	repeat,
	menu,
	get(C),
	vykonaj(C),
	C == 57,
	writeln('Koniec prace.').

%%%
% menu
menu:-
	nl,
	writeln('1 - citanie zo suboru'),
	writeln('2 - zapis do suboru'),
	writeln('3 - vypis vsetkych studentov'),
	writeln('4 - pridanie studenta'),
	writeln('5 - zmazanie studenta'),
	writeln('6 - zoradit zostupne'),
	writeln('7 - zoradit vzostupne'),
	writeln('8 - vyhladat studenta'),
	writeln('9 - koniec prace systemu'),
	writeln('------------------------'),
	nl.

%%%
% vykonanie vybranej moznosti
% vykonaj(+Code)
vykonaj(49):-
	read_atom(BezTohtoToNejde),
	write('Zadaj meno suboru na citanie: '),
	read_atom(MenoSuboru),
	citaj(MenoSuboru),
	!.
vykonaj(50):-
	read_atom(BezTohtoToNejde),
	write('Zadaj meno suboru na zapisanie: '),
	read_atom(MenoSuboru),
	zapis(MenoSuboru),!.
vykonaj(51):-vypis,!.
vykonaj(52):-pridaj,!.
vykonaj(53):-vymaz,!.
vykonaj(54):-zorad_zostupne_ponuka,!.
vykonaj(55):-zorad_vzostupne_ponuka,!.
vykonaj(56):-vyhladaj,!.
vykonaj(57):-!.
vykonaj(_):-writeln('Pouzivaj len urcene znaky!').


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sluzi na citanie zo suboru, najprv vyprazdni existujucu DB.
% citaj(+Subor)
citaj(S):-
	retractall(student(_,_,_,_,_,_,_,_)),
	see(S),
	repeat,
	read(Term),
	(
	    Term = end_of_file,
	    !,
	    seen
	    ;
	    assertz(Term),
	    fail
	).

%%%
% Sluzi na zapis textoveho suboru.
% zapis(+Subor)
zapis(S):-
	tell(S),
        student(Meno,Priezvisko,Stupen,Odbor,Rocnik,Prijatie,Ukoncenie,Status),
	writeq(student(Meno,Priezvisko,Stupen,Odbor,Rocnik,Prijatie,Ukoncenie,Status)),
	write('.'),
	nl,
	fail.
zapis(_):-told.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sluzi na vypis
% vypis()
vypis:-
	student(Meno,Priezvisko,Stupen,Odbor,Rocnik,Prijatie,Ukoncenie,Status),
        write(Meno),
	write(" "),
	write(Priezvisko),
	write(" "),
	write(Stupen),
	write(" "),
        write(Odbor),
        write(" "),
	write(Rocnik),
	write(" "),
        write(Prijatie),
        write(" "),
        write(Ukoncenie),
        write(" "),
	writeln(Status),
	fail.
vypis.

% Prida studenta do databazy
pridaj:-
	read_string(BezTohtoToNejde),
	writeln('Zadaj meno'),
	read_string_not_empty(Meno),
	writeln('Zadaj priezvisko'),
	read_string_not_empty(Priezvisko),
	writeln('Zadaj stupen studia'),
	read_string(Stupen),
	writeln('Zadaj odbor'),
	read_string(Odbor),
	writeln('Zadaj rocnik'),
	read_num(Rocnik),
	writeln('Zadaj datum prijatia (DD - MM - RR)'),
	read_string(Prijatie),
	over_datum(Prijatie),
	writeln('Zadaj datum ukoncenia (DD - MM - RR'),
	read_string(Ukoncenie),
	over_datum(Ukoncenie),
	writeln('Zadaj status'),
	read_string(Status),
	!,
	assertz(student(Meno,Priezvisko,Stupen,Odbor,Rocnik,Prijatie,Ukoncenie,Status)).

pridaj:-
	writeln('Zly format datumu!').

% Vymaze studenta z databazy
vymaz:-
	read_string(BezTohtoToNejde),
	writeln('Zadaj meno'),
	read_string(Meno),
	writeln('Zadaj priezvisko'),
	read_string(Priezvisko),
	writeln('Zadaj stupen studia'),
	read_string(Stupen),
	writeln('Zadaj odbor'),
	read_string(Odbor),
	writeln('Zadaj rocnik'),
	read_num(Rocnik),
	writeln('Zadaj datum prijatia (DD - MM - RR)'),
	read_string(Prijatie),
	writeln('Zadaj datum ukoncenia (DD - MM - RR)'),
	read_string(Ukoncenie),
	writeln('Zadaj status'),
	read_string(Status),
	retract(student(Meno,Priezvisko,Stupen,Odbor,Rocnik,Prijatie,Ukoncenie,Status)),
	!.

% Otvori ponuku pre zoradovanie zostupne
zorad_zostupne_ponuka:-
	zorad_menu,
	get(C),
	zorad_zostupne(C).

% Vypise text pre zoradovanie
zorad_menu:-
	nl,
	writeln('Zadajte moznost, podla coho chcete zoradit'),
	writeln('1 - Meno'),
	writeln('2 - Priezvisko'),
	writeln('3 - Stupen studia'),
	writeln('4 - Odbor'),
	writeln('5 - Rocnik'),
	writeln('6 - Datum prijatia'),
	writeln('7 - Datum ukoncenia'),
	writeln('8 - Status'),
	writeln('9 - Zrusit'),
	writeln('------------------------'),
	nl.

% Zoradi zostupne podla parametra v Code
% Pri zoradovani pouzivam to, ze dany parameter si dam ako kluc a ten
% nasledne zoradim a kluc odstranim
% zorad_zostupne(+Code).
zorad_zostupne(49):-
	findall(N-student(N,A,B,C,D,E,F,G),student(N,A,B,C,D,E,F,G),L),
	keysort(L,X),
	pairs_values(X,Sorted), %vrati naspat tvar bez klucov
	retractall(student(_,_,_,_,_,_,_,_)),
	pridaj_zoradene(Sorted),!.
zorad_zostupne(50):-
	findall(N-student(A,N,B,C,D,E,F,G),student(A,N,B,C,D,E,F,G),L),
	keysort(L,X),
	pairs_values(X,Sorted), %vrati naspat tvar bez klucov
	retractall(student(_,_,_,_,_,_,_,_)),
	pridaj_zoradene(Sorted),!.
zorad_zostupne(51):-
	findall(N-student(A,B,N,C,D,E,F,G),student(A,B,N,C,D,E,F,G),L),
	keysort(L,X),
	pairs_values(X,Sorted), %vrati naspat tvar bez klucov
	retractall(student(_,_,_,_,_,_,_,_)),
	pridaj_zoradene(Sorted),!.
zorad_zostupne(52):-
	findall(N-student(A,B,C,N,D,E,F,G),student(A,B,C,N,D,E,F,G),L),
	keysort(L,X),
	pairs_values(X,Sorted), %vrati naspat tvar bez klucov
	retractall(student(_,_,_,_,_,_,_,_)),
	pridaj_zoradene(Sorted),!.
zorad_zostupne(53):-
	findall(N-student(A,B,C,D,N,E,F,G),student(A,B,C,D,N,E,F,G),L),
	keysort(L,X),
	pairs_values(X,Sorted), %vrati naspat tvar bez klucov
	retractall(student(_,_,_,_,_,_,_,_)),
	pridaj_zoradene(Sorted),!.
zorad_zostupne(54):-
	findall(student(A,B,C,D,N,E,F,G),student(A,B,C,D,N,E,F,G),TT),
	map_list_to_pairs(my_reverse_date1,TT,L),
	keysort(L,X),
	pairs_values(X,Sorted), %vrati naspat tvar bez klucov
	retractall(student(_,_,_,_,_,_,_,_)),
	pridaj_zoradene(Sorted),!.
zorad_zostupne(55):-
	findall(student(A,B,C,D,N,E,F,G),student(A,B,C,D,N,E,F,G),TT),
	map_list_to_pairs(my_reverse_date2,TT,L),
	keysort(L,X),
	pairs_values(X,Sorted), %vrati naspat tvar bez klucov
	retractall(student(_,_,_,_,_,_,_,_)),
	pridaj_zoradene(Sorted),!.

zorad_zostupne(56):-
	findall(N-student(A,B,C,D,E,F,G,N),student(A,B,C,D,E,F,G,N),L),
	keysort(L,X),
	pairs_values(X,Sorted), %vrati naspat tvar bez klucov
	retractall(student(_,_,_,_,_,_,_,_)),
	pridaj_zoradene(Sorted).

zorad_zostupne(57):-
	writeln('Rusim zoradovanie'),!.
zorad_zostupne(_):-
	writeln('Zla moznost').

% Otvori ponuku pre zoradovanie vzostupne
zorad_vzostupne_ponuka:-
	zorad_menu,
	get(C),
	zorad_vzostupne(C).

% Zoradi vzostupne podla parametra v Code
% Pri zoradovani pouzivam to, ze dany parameter si dam ako kluc a ten
% nasledne zoradim a kluc odstranim. Kedze zoradujem vzostupne tak
% vysledny list este otocim
% zorad_vzostupne(+Code).
zorad_vzostupne(49):-
	findall(N-student(N,A,B,C,D,E,F,G),student(N,A,B,C,D,E,F,G),L),
	keysort(L,X),
	pairs_values(X,Sorted), %vrati naspat tvar bez klucov
	retractall(student(_,_,_,_,_,_,_,_)),
	my_reverse(Sorted,Sorted2),
	pridaj_zoradene(Sorted2),!.
zorad_vzostupne(50):-
	findall(N-student(A,N,B,C,D,E,F,G),student(A,N,B,C,D,E,F,G),L),
	keysort(L,X),
	pairs_values(X,Sorted), %vrati naspat tvar bez klucov
	retractall(student(_,_,_,_,_,_,_,_)),
	my_reverse(Sorted,Sorted2),
	pridaj_zoradene(Sorted2),!.
zorad_vzostupne(51):-
	findall(N-student(A,B,N,C,D,E,F,G),student(A,B,N,C,D,E,F,G),L),
	keysort(L,X),
	pairs_values(X,Sorted), %vrati naspat tvar bez klucov
	retractall(student(_,_,_,_,_,_,_,_)),
	my_reverse(Sorted,Sorted2),
	pridaj_zoradene(Sorted2),!.
zorad_vzostupne(52):-
	findall(N-student(A,B,C,N,D,E,F,G),student(A,B,C,N,D,E,F,G),L),
	keysort(L,X),
	pairs_values(X,Sorted), %vrati naspat tvar bez klucov
	retractall(student(_,_,_,_,_,_,_,_)),
	my_reverse(Sorted,Sorted2),
	pridaj_zoradene(Sorted2),!.
zorad_vzostupne(53):-
	findall(N-student(A,B,C,D,N,E,F,G),student(A,B,C,D,N,E,F,G),L),
	keysort(L,X),
	pairs_values(X,Sorted), %vrati naspat tvar bez klucov
	retractall(student(_,_,_,_,_,_,_,_)),
	my_reverse(Sorted,Sorted2),
	pridaj_zoradene(Sorted2),!.
zorad_vzostupne(54):-
	findall(student(A,B,C,D,N,E,F,G),student(A,B,C,D,N,E,F,G),TT),
	map_list_to_pairs(my_reverse_date1,TT,L),
	keysort(L,X),
	pairs_values(X,Sorted), %vrati naspat tvar bez klucov
	retractall(student(_,_,_,_,_,_,_,_)),
	my_reverse(Sorted,Sorted2),
	pridaj_zoradene(Sorted2),!.
zorad_vzostupne(55):-
	findall(student(A,B,C,D,N,E,F,G),student(A,B,C,D,N,E,F,G),TT),
	map_list_to_pairs(my_reverse_date2,TT,L),
	keysort(L,X),
	pairs_values(X,Sorted), %vrati naspat tvar bez klucov
	retractall(student(_,_,_,_,_,_,_,_)),
	my_reverse(Sorted,Sorted2),
	pridaj_zoradene(Sorted2),!.

zorad_vzostupne(56):-
	findall(N-student(A,B,C,D,E,F,G,N),student(A,B,C,D,E,F,G,N),L),
	keysort(L,X),
	pairs_values(X,Sorted), %vrati naspat tvar bez klucov
	retractall(student(_,_,_,_,_,_,_,_)),
	my_reverse(Sorted,Sorted2),
	pridaj_zoradene(Sorted2).

zorad_vzostupne(57):-
	writeln('Rusim zoradovanie'),!.
zorad_vzostupne(_):-
	writeln('Zla moznost').

% Tato funkcia vyhlada studenta podla parametrov. Ak je parameter
% prazdny tak ho pri vyhladavani neberie do uvahy
vyhladaj:-
	writeln('Ak nechcete vyhladat podla daneho parametru tak nechajte pole prazdne'),
	read_string(BezTohtoToNejde),
	writeln('Zadaj meno'),
	read_search_string(Meno),
	writeln('Zadaj priezvisko'),
	read_search_string(Priezvisko),
	writeln('Zadaj stupen studia'),
	read_search_string(Stupen),
	writeln('Zadaj odbor'),
	read_search_string(Odbor),
	writeln('Zadaj rocnik'),
	read_search_string(Rocnik),
	writeln('Zadaj datum prijatia (DD - MM - RR)'),
	read_search_string(Prijatie),
	writeln('Zadaj datum ukoncenia (DD - MM - RR)'),
	read_search_string(Ukoncenie),
	writeln('Zadaj status'),
	read_search_string(Status),

	findall(student(Meno,Priezvisko,Stupen,Odbor,Rocnik,Prijatie,Ukoncenie,Status),student(Meno,Priezvisko,Stupen,Odbor,Rocnik,Prijatie,Ukoncenie,Status),L),
	nl,writeln('Najdene vysledky:'),nl,
	vypis_hladanie(L).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Pomocne predikaty - priklady
% Predikat, ktory nacita string aj ked tam je velke zaciatocne pismeno
% read_string(?String) argument je ale vhodnejsie pouzivat ako vystupny
read_string(String):-
	current_input(Input),
	read_line_to_codes(Input,Codes),
	string_codes(String,Codes).

% Predikat, ktory nacita string aj ked tam je velke zaciatocne pismeno.
% String nemoze byt prazdny
% read_string_not_empty(?String) argument je
% ale vhodnejsie pouzivat ako vystupny
read_string_not_empty(String):-
	current_input(Input),
	read_line_to_codes(Input,Codes),
	not(is_empty_arr(Codes)),
	string_codes(String,Codes),!.

read_string_not_empty(String):-
	write('\tPole nesmie byt prazdne, zadajte znova: '),
	read_string_not_empty(String).

%%%
% Predikat sa vykonava opakovane kym pouzivatel nezada korektne cislo
% alebo enter
% read_num(?Number) argument je velmi vhodne pouzivat len
% ako vystupny
read_num(Num) :-
	read_string(Str),
	check_num(Num, Str), !.

read_num(Num) :-
	write('\tMusite zadat cislo: '),
	read_num(Num).

% Overuje, ci je dany string cislo, popripade enter ak uzivateln nechce
% zadat datum
% check_num(?Number,+String).
check_num(Num,Str):-
	number_string(Num, Str), !.
check_num(Str,Str):-
	string_codes(Str,Codes),
	is_empty_arr(Codes),!.

%%%
% Konverzia retazca na atom
% read_atom(?Atom)
read_atom(A):-
	read_string(Str),
	atom_string(A,Str).

% Overi spravne formatovanie datumu DD - MM - RR alebo prazdny string ak
% uzivatel nechce zadat datumn
% over_datum(+String).
over_datum(X):-
	X=~'[0-9]{2} - [0-9]{2} - [0-9]{2}',!.
over_datum(Z):-
	string_codes(Z,Code),
	is_empty_arr(Code),!.

% Rekurzivne pridava studentov z listu do databazy
% pridaj_zoradene(+List).
pridaj_zoradene([H|T]):-
	assertz(H),
	pridaj_zoradene(T),!.
pridaj_zoradene([]).

% Rekurzivne otoci poradie listu
% my_reverse(+List,-List).
my_reverse(List,R) :-
     my_reverse(List,[],R).

% Pomocna funkcia na otacanie
% my_reverse(+List,:Acc,-List).
my_reverse([],List,List).
my_reverse([H|T],R,List) :-
     my_reverse(T,[H|R],List).

% Pomocna funkcia, ktora otoci datum aby sa dola podla neho zoradovat.
% Vyuzivam ju pri vytvarani klucov pri sortovani.
% my_reverse_date(+Student,-Kluc).
my_reverse_date1(student(_,_,_,_,_,F,_,_),I):-
	reverse_string(F,I).
my_reverse_date2(student(_,_,_,_,_,_,G,_),I):-
	reverse_string(G,I).

% Funkcia, ktora otoci prichadzajuci string
% reverse_string(+String,-String).
reverse_string(XX,YY):-
	string_codes(XX,X),
	my_reverse(X,Y),
	string_codes(YY,Y).

% Pomocna funkcia, ktora sa vyuziva pri vyhladavani.
% Overujem, ci uzivatel zadal argument na hladanie (vtedy ho
% vraciam) alebo mam dane hladanie preskocit.
% read_search_string(-String).
read_search_string(String):-
	current_input(Input),
	read_line_to_codes(Input,Codes),
	not(is_empty_arr(Codes)),
	string_codes(String,Codes),
	!.
read_search_string(_).

% Funkcia, ktora overuje ci je list prazdny
% is_empty_arr(+List).
is_empty_arr([]).

% Funkcia, ktore vypise vysledky vyhladania
% vypis_hladanie(+List).
vypis_hladanie([student(Meno,Priezvisko,Stupen,Odbor,Rocnik,Prijatie,Ukoncenie,Status)|T]):-
        write(Meno),
	write(" "),
	write(Priezvisko),
	write(" "),
	write(Stupen),
	write(" "),
        write(Odbor),
        write(" "),
	write(Rocnik),
	write(" "),
        write(Prijatie),
        write(" "),
        write(Ukoncenie),
        write(" "),
	writeln(Status),
	vypis_hladanie(T).
vypis_hladanie([]).
