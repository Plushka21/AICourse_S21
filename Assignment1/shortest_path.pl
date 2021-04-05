/*
    Anton Buguev BS19-02
    a.buguev@innopolis.university
*/


:- dynamic([
    /* Size of the map */
    size/1,
    /* Number of covid cells */
    covids/1,
    /* Number of doctor cells */
    doctors/1,
    /* Number of mask cells */
    masks/1,
    /* Final array with coordinates of elements */
    world/1
]).

/*
    configurate the world
*/
world_init:-
    size(S),
    /* Size if used in random generation */
    Size is S + 1,

    /* Initial map only with actor at starting position */
    EmptyWorld=[1/1-actor],

    /* Get the number of covid cells */
    covids(C),
    /* Generate required number of covid cells */
    create_covids(Size,C,CovidCell),
    /* Update map */
    append(EmptyWorld,CovidCell,CovidWorld),

    /* Generate postition of home */
    create_home(Size, HomeCell, CovidWorld),
    /* Update map */
    append(CovidWorld,HomeCell,HomeWorld),

    /* Get the number of doctors */
    doctors(D),
    /* Generate required number of doctor cells */
    create_doctors(Size,D,DoctorCell,HomeWorld),
    /* Update map */
    append(HomeWorld,DoctorCell,DoctorWorld),

    /* Get the number of masks */
    masks(M),
    /* Generate required number of mask cells */
    create_masks(Size,M,MaskCell,DoctorWorld),
    /* Update map */
    append(DoctorWorld,MaskCell,W),
    /* Save resulting map */
    assert(world(W)), !.

/* Covid cells generator */
create_covids(_, 0, []).
create_covids(Size, C, CovidCell):-
    C > 0,        
    C1 is C - 1,
    /* Keep generating until actor is not in covid area */
    repeat,
    random(2, Size, CX),
    random(2, Size, CY),
    (
        \+CX < 3; \+CY < 3
    ),
    CovidCell = [CX/CY-covid|T],
    create_covids(Size, C1, T).

/* Home cell generator */
create_home(Size, HomeCell, CovidWorld):-
    /* Keep generating until actor is not at home and home is not in covid area */
    repeat,
    random(2,Size,HX),
    random(2,Size,HY),
    (
        \+ covid_area(HX/HY, CovidWorld),
        (\+HX = 1; \+HY = 1)
    ),
    HomeCell = [HX/HY-home].

/* Doctor cell generator */
create_doctors(_, 0, [], _).
create_doctors(Size, D, DoctorCell, HomeWorld):-
    D > 0,        
    D1 is D - 1,
    coor_actor_array(HX/HY,home,HomeWorld),
    /* Keep generating until actor is not at doctor, doctor is not at home and doctor is not in covid area */
    repeat,
    random(2, Size, DX),
    random(2, Size, DY),
    (
        \+covid_area(DX/DY, HomeWorld),
        (\+DX = 1; \+DY = 1),
        (\+DX == HX, \+DY == HY)
    ),
    DoctorCell = [DX/DY-doctor|T],
    create_doctors(Size, D1, T, HomeWorld).

create_masks(_, 0, [], _).
create_masks(S, M, MaskCell, DoctorWorld):-
    M > 0,        
    M1 is M - 1,
    coor_actor_array(HX/HY,home,DoctorWorld),
    coor_actor_array(DX/DY,doctor,DoctorWorld),
    /* Keep generating until actor is not at mask, mask is not at home, 
    mask is not at doctor and mask is not in covid area */
    repeat,
    random(2, S, MX),
    random(2, S, MY),
    (
        \+covid_area(MX/MY, DoctorWorld),
        (\+MX = HX; \+MY = HY),
        (\+MX = DX; \+MY = DY)
    ),

    MaskCell = [MX/MY-mask|T],
    create_masks(S, M1, T, DoctorWorld).


/*
    get coordinate or name of agent
*/
coor_actor(Pos, Ent) :-
    world(W),
    member(Pos-Ent, W).

/*
    get coordinates or name of agent in current world
*/
coor_actor_array(Pos, Actor, Array):-
    member(Pos-Actor, Array).


/*
    check whether cells are adjacent by their coordinates
    or return adjacent cells
*/
pos_neighbour(X/Y, NX/NY) :-
        (
            (NX is X + 1, NY = Y);
            (NX = X, NY is Y + 1);
            (NX is X + 1, NY is Y + 1);
            (NX is X - 1, NY = Y);
            (NX = X, NY is Y - 1);
            (NX is X + 1, NY is Y - 1);
            (NX is X - 1, NY is Y + 1);
            (NX is X - 1, NY is Y - 1)
        ),
        size(S), Size is S + 1,
        NX > 0, NY > 0, NX < Size, NY < Size.
/*
    check whether requested cell is infected,
    i.e. whethere it is neighbour to the cell with covid
*/
covid_area(X/Y):-
    coor_actor(CX/CY,covid),
    (
        pos_neighbour(X/Y, CX/CY); (X = CX,Y = CY)
    ).

covid_area(Actor):-
    coor_actor(X/Y,Actor),
    coor_actor(CX/CY,covid),
    (
        pos_neighbour(X/Y, CX/CY); (X = CX,Y = CY)
    ).

covid_area(X/Y,Array):-
    coor_actor_array(CX/CY,covid,Array),
    (
        pos_neighbour(X/Y,CX/CY); (X = CX,Y = CY)
    ).

/*
    check whether requested move is valid,
    is is valid if this cell is inside square and 
    if actor does not have mask or have not visited doctor, there is not covid zone
*/
valid_move(X/Y, Path):-
    size(S), Size is S + 1,
    X > 0, Y > 0,
    X < Size, Y < Size,
    \+ member(X/Y, Path),
    (
        \+ covid_area(X/Y);
        has_protection(Path)
    ).


/*
    check whether mask, doctor or home is located in requested cell
*/
is_doctor(X/Y):-
    coor_actor(DX/DY,doctor),
    X = DX, Y = DY, !.

is_mask(X/Y):-
    coor_actor(MX/MY,mask),
    X = MX, Y = MY, !.

is_home(X/Y):-
    coor_actor(HX/HY,home),
    X = HX, Y = HY, !.

/*
    check whether actor has visited doctor or has a mask, i.e. has protection from covid
    check the path
*/
has_protection(Path):-
    coor_actor(DX/DY,doctor),
    coor_actor(MX/MY,mask),
    (
        member(DX/DY, Path);
        member(MX/MY, Path)    
    ).

/*
    find possible way
*/
/*
    If current cell, i.e. last in the array with path, is at home
    we compare length of this route is less than max length, we save this route and its length 
    and stop searching path from current cell and return to the previous cell
*/
find_way_backtracking(Path, MinLen, Result, PathLength):-
    last(Path,X/Y), 
    coor_actor(HX/HY,home),

    nb_getval(maxPathLen, MaxLen),
    length(Path,SomePathLength),
    SomePathLength < MaxLen,

    CurLen is MinLen + max(abs(HX-X),abs(HY-Y)),
    CurLen < MaxLen,
    is_home(X/Y),

    nb_setval(maxPathLen, SomePathLength),
    
    Result = Path,
    PathLength = SomePathLength.


/*
    If current cell is not at home, we compare remaining distance to the home,
    if it is bigger than max length and stop searching path from current cell and return to the previous cell,
    otherwise we find adjacent cell, check whether it is possible to go there, if so add new cell to the array with path,
    then compare current path with max length, if current length is bigger we again return to the previous cell
*/
find_way_backtracking(Path, MinLen, Result, PathLength):-
    last(Path,X/Y),
    coor_actor(HX/HY,home),
    \+ is_home(X/Y),
    
    nb_getval(maxPathLen, MaxLen),

    CurLen is MinLen + max(abs(HX-X),abs(HY-Y)),
    CurLen < MaxLen,

    length(Path,SomePathLength),
    SomePathLength < MaxLen,

    pos_neighbour(X/Y, NX/NY), valid_move(NX/NY, Path),
    append(Path, [NX/NY], NPath),

    NewCurLen is MinLen + 1,
    find_way_backtracking(NPath, NewCurLen, Result, PathLength).

/*
    A* algorithm searches for path until open list is empty or until actor reaches home

    If open list is empty and actor has not reached home, 
    it means that all cells are considered, but home is impossible to reach
*/
find_way_astar:-
    nb_getval(openList, OpenList),
    length(OpenList, L), L == 0,

    nth0(0,OpenList,Cell), nth0(0,Cell,X/Y),
    \+ is_home(X/Y),
    writeln("Path has not been found").

/*
    Otherwise if actor has reached home, we find current path and stop execution
*/
find_way_astar:-
    nb_getval(openList, OpenList),
    length(OpenList, L), L >= 0,

    nth0(0,OpenList,Cell), nth0(0,Cell,X/Y), nth0(4,Cell,PX/PY),
    is_home(X/Y),

    delete(OpenList,[X/Y,_,_,_,_],SomeOpenList),
    nb_setval(openList,SomeOpenList),
    
    nb_getval(closedList,ClosedList),
    append(ClosedList,[[X/Y,PX/PY]],NewClosedList),
    nb_setval(closedList,NewClosedList),

    nb_setval(astarPath, [X/Y]),
    
    getPath(X/Y), !.


find_way_astar:-
    nb_getval(openList, OpenList),
    length(OpenList, L), L > 0,

    /*
        If actor has not reached home, we pick cell with lowest F value, 
        delete it from open list and add this cell with its parent into closed list,
    */
    nth0(0,OpenList,Cell), nth0(0,Cell,X/Y), nth0(4,Cell,PX/PY),
    delete(OpenList,[X/Y,_,_,_,_],SomeOpenList),
    nb_setval(openList,SomeOpenList),
    
    nb_getval(closedList,ClosedList),
    append(ClosedList,[[X/Y,PX/PY]],NewClosedList),
    nb_setval(closedList,NewClosedList),
    
    \+ is_home(X/Y),

    /*
        search its adjacent cells and calculate G, H and F values for them,
        then sort open list in increasing order by G value and continue searching recursively.
    */
    nb_setval(astarPath, []),
    getPath(X/Y),
    get_adj_nodes(X/Y),

    nb_getval(openList,NewOpenList),
    sort(2, @=<, NewOpenList, SortedOpenList),
    nb_setval(openList,SortedOpenList),

    find_way_astar.

/*
    Get path from initial point to home
*/
getPath(1/1):-
    nb_getval(astarPath,Path),
    reverse(Path,NPath),
    nb_setval(astarPath,NPath).
/*
    Since we keep in closed list cell with its parent, 
    we can get parent of current cell, then its parent etc. until we reach intial point,
    the we just reverse this path and it will be path to the current cell
*/
getPath(X/Y):-
    nb_getval(closedList, ClosedList),
    nb_getval(astarPath, Path),
    member([X/Y,PX/PY],ClosedList)->
    (
        append(Path,[PX/PY],NPath),
        nb_setval(astarPath,NPath),
        getPath(PX/PY)
    );
    nb_setval(astarPath,[]),!.

/*
    Check properties of current cell
*/
checkPos(NX/NY, X/Y):-
/* First we check whether actor has already visited this cell, then whether this cell is valid, i.e. there is no covid */
    nb_getval(closedList,ClosedList),
    \+member([NX/NY,_/_],ClosedList),

    nb_getval(astarPath, Path),
    valid_move(NX/NY, Path)->
        (
            /*  Second, we check whether current cell is already in open list */
            nb_getval(openList,OpenList),
            
            \+member([NX/NY,_,_,_,_], OpenList)->
                (
                    /* if it is not, we just calculate G, H and F values and add this cell into open list */
                    calculateF(NX/NY,G,H,F),
                    append(OpenList,[[NX/NY,G,H,F,X/Y]],NewOpenList),
                    nb_setval(openList, NewOpenList)
                );
                (
                    /* otherwise, we need to celculate G, H and F values and compare with already existed G value */
                    nb_getval(openList,OpenList),
                    calculateF(NX/NY,F,G,H),
                    member([NX/NY,_,SG,_,_], OpenList),
                    /* if current G values is smallerm we replace old cell with current cell
                        otherwise do nothing */
                    G < SG ->
                        (
                            delete(OpenList, [[NX/NY,_,_,_,_]], SomeOpenList), 
                            append(SomeOpenList, [[NX/NY,F,G,H,X/Y]], NewOpenList),
                            nb_setval(openList, NewOpenList)
                        ); !
                )
        ); !.

/*
    Find all adjacent cell for current cell
*/
get_adj_nodes(X/Y):-
    setof(NX/NY, pos_neighbour(X/Y, NX/NY), Set),
    /*
        Then for each of them, check wheter it is valid and do special actions
    */
    forall(member(NX/NY, Set), checkPos(NX/NY, X/Y)).

/*
    Calculate G value
    It is Chebyshev's distance from actor to current cell
*/
calculateG(X/Y,G):-
    coor_actor(AX/AY,actor),
    G is max( abs(AX - X), abs(AY - Y) ).

/*
    Calculate H value
    It is Chebyshev's distance from actor to current cell
*/
calculateH(X/Y,H):-
    coor_actor(HX/HY,home),
    H is max(abs(HX-X),abs(HY-Y)).

/*
    Calculate G value
    If is summ of G and H
*/
calculateF(X/Y, G, H, F):-
    calculateG(X/Y,G),
    calculateH(X/Y,H),
    F is G + H.


/*
    Find set of possible shortest routes to home and find minimal of them
    Taken from https://www.cpp.edu/~jrfisher/www/prolog_tutorial/2_15A.pl 
*/
shortest(Path,Length):-
    setof([R,L], find_way_backtracking([1/1], 1, R, L), Set),
    Set = [_|_],
    minimal(Set,[Path,Length]), !.

/*
    Find the minimal route from set of routes
*/
minimal([F|R],M) :- 
    min(R,F,M).

/*[1/1-actor,3/2-covid,4/6-covid,2/8-home,8/7-doctor,9/2-mask]*/

min([],M,M).
min([[P,L]|R],[_,M],Min) :- 
    L < M, !, 
    min(R,[P,L],Min). 
min([_|R],M,Min) :- 
    min(R,M,Min).


/* Draw a map */
/* If all rows are printed, exit*/
draw_map(0,_):- true.
/* Otherwise, print a row */
draw_map(Y, Path):-
    /* Get a size of the map */
    size(Size),
    /* Go through each element in the row */
    between(1, Size, X),
    (
        (
            /* If it is initial point print 'A' */
            X == 1, Y == 1
        ) -> write("A");  
        (
            /* If it is home print 'H' */
            is_home(X/Y)
        )-> write("H");
        (
            /* If it is doctor print 'D' */
            is_doctor(X/Y)
        )-> write("D");
        (
            /* If it is mask print 'M' */
            is_mask(X/Y)
        )-> write("M");
        (
            /* If it is covid area 'C' */
            covid_area(X/Y),
            \+member(X/Y, Path)
        )-> write("C");
        (
            /* If it is part of the path, print'*' */
            \+is_home(X/Y),
            member(X/Y, Path)
        )-> write("*");
        /* Otherwise, cell is free, so print '.' */
            write(".")
    ),
    /* 
        move cursor to the next line, decrease number of remaining rows 
        And print next rows till the end
    */
    X == Size -> nl,
    NY is Y - 1,
    draw_map(NY, Path).


/* Main function */
main:-
    /* Free atoms */
    retractall(size(_)),
    retractall(home(_)),
    retractall(covids(_)),
    retractall(doctors(_)),
    retractall(masks(_)),
    retractall(world(_)),

    /* Get the size of the map */
    writeln("Please enter the size of the map:"),
    read(Size),
    assert(size(Size)),

/* Get number of covid cells */
    writeln("Please enter the number of cells with covid:"),
    read(Covid),
    assert(covids(Covid)),

/* Get number of doctors */
    writeln("Please enter the number of doctors:"),
    read(Doctor),
    assert(doctors(Doctor)),

/* Get number of masks */
    writeln("Please enter the number of masks:"),
    read(Mask),
    assert(masks(Mask)), nl,

/* Initialze the world */
    world_init,
/* Print postions of important cells */
    writeln("The current world:"), world(W), writeln(W),nl,
    draw_map(Size,[]),

/* Set value of max length that is doubled size of map */
    MaxLen is Size * 2,
    nb_setval(maxPathLen, MaxLen),

/* Find shortest path using backtracking */
    time(shortest(BPath, Length_Back)),

/* Since we need number of steps, we do not need to count starting position,
    so current length of the shortest path will be less */
    CurLen_Back is Length_Back - 1,

/* Print results */
    writeln("One of the shortest routes using backtracking:"),
    draw_map(Size, BPath),
    writeln(BPath),
    
    write("Number of steps = "),
    writeln(CurLen_Back), nl,
    
/* Assert corresponding values for A* algorithm */
/* Set current path and closed list empty, open list will contain initial cell with 0s */
    nb_setval(astarPath,[]), 
    ClosedList = [], 
    nb_setval(closedList, ClosedList), 
    nb_setval(openList, [[1/1,0,0,0,1/1]]),

/* Find shortest path using A* */
    time(find_way_astar),

/* Get path */
    nb_getval(astarPath, APath),

/* Print results */
/* Since we need number of steps, we do not need to count starting position,
    so current length of the shortest path will be less */
    length(APath, Length_AStar),
    CurLen_AStar is Length_AStar - 1,

    writeln("One of the shortest routes using A*:"),
    draw_map(Size, APath),
    writeln(APath),

    write("Number of steps = "),
    writeln(CurLen_AStar).