; PROJETO Ingo
; AUTOR Felipe Holanda Bezerra
; DATA 04-05-2021

; ---- Tela de Abertura

startgame
    set kernel_options pfcolors
     
startLoop

    COLUBK=$00      

      playfield:
................................
.........X......................
.......XXX......................
......X..X..XX....XX...XX.......
.......X.X..X.X..X..X.X..X......
.........X..X..X..XXX..XX.......
.........X..........X...........
.........X..........X...........
.....X..X.......X..X............
......XX.........XX.............
................................
end 

  pfcolors:
   $1E
   $1C
   $1A
   $18
   $16
   $16
   $14
   $12
   $10
   $10
   $0E
end

 drawscreen
 goto startLoop  
 


main
  f=f+1
  rem POSSIBLY INEFFICIENT CODE, SEPARATE COLOR INFO FOR EACH FRAME...
  if f = 10 then player0:
        %00100100
        %10100100
        %01111100
        %00111100
        %00001110
        %00000110
        %00000001
        %00000000
end
   if f = 10 then player0color:
    $0E;
    $0E;
    $0E;
    $0E;
    $0E;
    $0E;
    $0E;
    $0E;
end
  if f = 20 then player0:
        %00010000
        %00100000
        %01100010
        %01111100
        %00111100
        %00001110
        %00000110
        %00000001
end
   if f = 20 then player0color:
    $0E;
    $0E;
    $0E;
    $0E;
    $0E;
    $0E;
    $0E;
    $0E;
end
  if f = 30 then player0:
        %01000100
        %00100100
        %11111100
        %00111100
        %00001110
        %00000110
        %00000001
        %00000000
end
   if f = 30 then player0color:
    $0E;
    $0E;
    $0E;
    $0E;
    $0E;
    $0E;
    $0E;
    $0E;
end

  if f=30 then f=0

  if joy0right then REFP0 = 0
  if joy0left then REFP0 = 8

  drawscreen

  if joy0right then player0x = player0x + 1
  if joy0left then player0x = player0x - 1
  if joy0up then player0y = player0y - 1
  if joy0down then player0y = player0y + 1

  goto main


