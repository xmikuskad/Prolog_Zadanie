%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mame predikat student,ktory ma 8 argumentov a potrebujeme
% povedat prologu, ze sa pocet jeho klauzul moze menit.
% student(Meno,Priezvisko,StupenStudia,Odbor,Rocnik,DatumPrijatia,
% DatumUkoncenia,Status).
:- dynamic student/8.
%%%
% zadefinujeme operatory - len priklad

:- op(600,xfy,::).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Hlavny cyklus programu
% main()

main:-	        %uz pri spusteni moze nacitat databazu
	repeat,
	menu,
	get(C),
	vykonaj(C),
	C == 57,
	writeln('Koniec prace.').

%%%
% Menu rozsirite podla zadania
% menu
menu:-
	nl,
	writeln('1 - citanie zo suboru'),
	writeln('2 - zapis do suboru'),
	writeln('3 - vypis vsetkych studentov'),
	writeln('4 - pridanie studenta'),
	writeln('5 - pridanie studenta'),
	writeln('9 - koniec prace systemu'),
	writeln('------------------------'),
	nl.

%%%
% vykonanie vybranej moznosti
% vykonaj(+Code)

vykonaj(48):-
	retractall(student(_,_,_,_,_,_,_,_)),
	!.
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
vykonaj(52):-pridaj(),!.
vykonaj(53):-vymaz(),!.
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

pridaj():-
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
	writeln('Zadaj datum prijatia'),
	read_string(Prijatie),
	writeln('Zadaj datum ukoncenia'),
	read_string(Ukoncenie),
	writeln('Zadaj status'),
	read_string(Status),
	write(Meno),
	write(Priezvisko),
	write(Stupen),
	write(Odbor),
	write(Rocnik),
	write(Prijatie),
	write(Ukoncenie),
	writeln(Status),
	assertz(student(Meno,Priezvisko,Stupen,Odbor,Rocnik,Prijatie,Ukoncenie,Status)).

vymaz().
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





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Pomocne predikaty - priklady
% Predikat, ktory nacita string aj ked tam je velke zaciatocne pismeno
% read_string(?String) argument je ale vhodnejsie pouzivat ako vystupny

read_string(String):-
	current_input(Input),
	read_line_to_codes(Input,Codes),
	string_codes(String,Codes).

%%%
% Predikat sa vykonava opakovane kym pouzivatel nezada korektne cislo
% read_num(?Number) argument je velmi vhodne pouzivat len ako vystupny

read_num(Num) :-
	read_string(Str),
	number_string(Num, Str), !.

read_num(Num) :-
	write('\tMusite zadat cislo: '),
	read_num(Num).


%%%
% Konverzia retazca na atom
% read_atom(?Atom)

read_atom(A):-
	read_string(Str),
	atom_string(A,Str).

%%%
% Najde vsetky riesenia pre dany ciel
% findall(+Template, :Goal, -Bag)
% vrati zoznam Mien a Priezvisk pre vsetkych zakaznikov v databaze
% findall(M^P , zakaznik(M,P,A,O), List).
% findall(M-P-A>O,zakaznik(M,P,A,O),List).
