PLEASE, run this code on your machine, not in browser because it does not work in browser.
It is more convinient to run this code on linux machine.

To run this program you need to:

1. Install swipl, run these commands in terminal in linux machine:
	% sudo apt-add-repository ppa:swi-prolog/stable
	% sudo apt-get update
	% sudo apt-get install swi-prolog

2. Copy source code in some directory

3. Using terminal go to that directory where source code is located

4. Write command:
	% swipl Anton_Buguev.pl

5. Then you need to write the size of the map, for example 9, number of covid sources, number of doctors and number of masks and locations of each element will be generated randomly.
IMPORTANT: AFTER EACH NUMBER TYPE '.' (dot) AND THEN ENTER

6. After execution you will see:
	- the map that was generated with coordinates of each agent
	- path that program found using backtracking, number of steps and representation of path on the map
	- path that program found using A*, number of steps and representation of path on the map


How map looks like:

...CCCM..
...CCC...
.........
...CCC...
...CCC..H
...CCC...
....D....
.........
A........

- A - initial position of actor
- H - home
- D - doctor
- M - mask
- C - infected cells by covid

How output will look like:

[1/1,2/1,3/1,4/1,5/1,6/2,7/3,8/4,9/5] - path to home

...CCCM..
...CCC...
.........
...CCC...
...CCC..H
...CCC.*.
....D.*..
.....*...
A****....

- A - initial position of actor
- H - home
- D - doctor
- M - mask
- C - infected cells by covid
- * - cell where actor goes

However, if there is no path home, program will return 'false'.