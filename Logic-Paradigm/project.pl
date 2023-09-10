%% do not forget to remove X Y Z header from xyz files
%% start directly from numbers
read_xyz_file(File, Points) :-
  open(File, read, Stream),
  read_xyz_points(Stream,Points),
  close(Stream).

read_xyz_points(Stream, []) :-
  at_end_of_stream(Stream).
read_xyz_points(Stream, [Point|Points]) :-
  \+ at_end_of_stream(Stream),
  read_line_to_string(Stream,L),
  split_string(L, "\s\t\n", "\s\t\n", XYZ),
  convert_to_float(XYZ,Point),
  read_xyz_points(Stream, Points).
convert_to_float([],[]).
convert_to_float([H|T],[HH|TT]) :-
  atom_number(H, HH),
  convert_to_float(T,TT).


get_element(Points, Index, Element) :-
    nth1(Index, Points, Element).

collect_random_indices(Count, _Total, Acc, Indices) :-
    Count = 0,
    Indices = Acc.
collect_random_indices(Count, Total, Acc, Indices) :-
    Count \= 0,
    Total1 is Total+1,
    random(1,Total1, Index),
    (
    	member(Index, Acc) ->
    		collect_random_indices(Count, Total, Acc, Indices)
    ;   Count1 is Count-1,
    	collect_random_indices(Count1, Total, [Index | Acc], Indices)
    ).

random3points(Points, Point3) :-
    length(Points, Total),
    collect_random_indices(3, Total, [], Indices),
    maplist(get_element(Points), Indices, Point3).
    

plane(Point3, Plane) :-
    [[X1,Y1,Z1],[X2,Y2,Z2],[X3,Y3,Z3]] = Point3,
    A1 is X2-X1,
    B1 is Y2-Y1,
    C1 is Z2-Z1,
    A2 is X3-X1,
    B2 is Y3-Y1,
    C2 is Z3-Z1,
    A is B1*C2 - B2*C1,
    B is A2*C1 - A1*C2,
    C is A1*B2 - B1*A2,
    D is -A*X1 - B*Y1 - C*Z1,
    Plane = [A, B, C, D].

in_plane(Eps, Plane, Point) :-
    Plane = [A, B, C, D],
    Point = [X, Y, Z],
    Coef is abs(A*X + B*Y + C*Z + D)/sqrt(A*A + B*B + C*C),
    Coef < Eps.

support(Plane, Points, Eps, N) :-
    include(in_plane(Eps, Plane), Points, PointsInPlane),
    length(PointsInPlane, N).

test_data(1, Points) :-
    Points = [
      [0, 0, 0], [-17.14862926, -14.46566552, 1.655006276],
      [-17.32256838, -14.26493547, 2.482171338],
      [-17.07511689, -13.96103739, 1.627050147],
      [-17.30372157, -13.98265816, 4.128879587],
      [-17.14921483, -13.76022588, 1.621973858]
    ].
test_data(2, Points) :-
    Points = [
      [1, 0, 0],
      [0, 1, 0],
      [0, 0, 1]
    ].

ransac_number_of_iterations(Confidence, Percentage, N) :-
    N is round(log(1 - Confidence) / log(1 - Percentage*Percentage*Percentage)).
    

member_inv(List, Elem) :-
    member(Elem, List).

test(random3points, 1) :-
    test_data(2, IdentityPoints),
    random3points(IdentityPoints, Point3),
    member([1,0,0], Point3),
    member([0,1,0], Point3),
    member([0,0,1], Point3).
test(random3points, 2) :-
    Points = [
             [0, 0, 1],
             [0, 0, 2],
             [0, 0, 3],
             [0, 0, 4],
             [0, 0, 5]
    ],
    random3points(Points, Point3),
    exclude(member_inv(Points), Point3, []).
test(random3points, 3) :-
	test_data(1, Points),
    random3points(Points, Point3),
    exclude(member_inv(Points), Point3, []).

test(plane, 1) :-
    A = -3, B = 6, C = 0, D = 0,
    Plane = [A, B, C, D],
    Point3 = [
             [2, 1, 1],
             [6, 3, 0],
             [-4, -2, 1]
    ],
    plane(Point3, Plane).

test(support, 1) :-
    A = -3, B = 6, C = 0, D = 0,
    Plane = [A, B, C, D],
    Points = [
              [-17.32256838, -14.26493547, 2.482171338],
      			[-17.07511689, -13.96103739, 1.627050147],
      		[-17.30372157, -13.98265816, 4.128879587],
             [2, 1, 1],
             [6, 3, 0],
             [-4, -2, 1]
    ],
    Eps = 0.01,
    support(Plane, Points, Eps, N),
    N = 3.

test(ransac_number_of_iterations, 1) :-
    ransac_number_of_iterations(0.95, 0.3, 109).
test(ransac_number_of_iterations, 2) :-
    ransac_number_of_iterations(0.98, 0.2, 487).
test(ransac_number_of_iterations, 3) :-
    ransac_number_of_iterations(0.99, 0.1, 4603).
