

program SnakeGame;

uses crt;

var
direction, nextdirection: integer;

x, y, foodx, foody: integer;

score: longint;

grid: array[1..20,1..20] of char;

procedure setup;
var
i, j: integer;
begin
randomize;

direction := 0;
nextdirection := 0;

score := 0;

x := 10;
y := 10;

foodx := 0;
foody := 0;

for i := 1 to 20 do
begin
for j := 1 to 20 do
grid[i, j] := ' ';
end;

end;

procedure input;
var
ch: char;
begin
if keypressed then
begin
ch := readkey;
case ch of
'w': nextdirection := 1;
's': nextdirection := 2;
'a': nextdirection := 3;
'd': nextdirection := 4;
'x': direction := 0;
end;
end;
end;

procedure update;
var
i: integer;
begin

if direction = 0 then
exit;

//update position
case direction of
1: dec(y);
2: inc(y);
3: dec(x);
4: inc(x);
end;

//boundary check
if (x < 1) then x := 20;
if (x > 20) then x := 1;
if (y < 1) then y := 20;
if (y > 20) then y := 1;

//food check
if (x = foodx) and (y = foody) then
begin
inc(score);

repeat
foodx := random(19) + 1;
foody := random(19) + 1;
until grid[foodx, foody] = ' ';
end;

//update grid
grid[x, y] := '#';

for i := 1 to 20 do
begin
for j := 1 to 20 do
write(grid[i, j]);
writeln;
end;

writeln;
writeln('score: ', score);

direction := nextdirection;

end;

begin

setup;

repeat

clrscr;

input;

update;

delay(100);

until direction = 0;

end.
