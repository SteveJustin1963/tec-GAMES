```
// Constants
8 w ! // width and height of game field
2 l ! // initial snake length
0 d ! // initial direction (0: right, 1: down, 2: left, 3: up)
10 s ! // initial speed (lower is faster)

// Variables
[ ] n ! // snake array (each element is x*16 + y)
0 f ! // fruit position
0 g ! // game over flag

// Initialize game
:I
  [ ] n !
  w 2 / " 16 * + n +! // add initial snake head
  1 ( " 1 - 16 * n 0 ? + n +! ) // add initial snake body
  N // new fruit
  0 g ! // reset game over flag
;

// Main game loop
:M
  R // render
  s D // delay based on speed
  U // update
  g @ /F = M // continue if not game over
;

// Render game state
:R
  w w * ( 0 i ! ) // clear screen
  n /S ( n i ? P ) // draw snake
  f @ P // draw fruit
;

// Update game state
:U
  // Move snake
  n 0 ? " // get head position
  d @ 0 = ( 16 + ) // move right
  d @ 1 = ( 1 + ) // move down
  d @ 2 = ( 16 - ) // move left
  d @ 3 = ( 1 - ) // move up
  " 240 & 16 % w * + // wrap around screen
  " n +! // add new head
  
  // Check for fruit
  " f @ = ( 
    l @ 1 + l ! // increase length
    s @ 1 - 1 > ( " 1 - s ! ) // increase speed
    N // new fruit
  ) ( n /S 1 - n ! ) // remove tail if no fruit eaten
  
  // Check for collision with self
  n /S 1 - 1 ( 
    n i ? n 0 ? = ( 1 g ! ) // game over if head hits body
  )
;

// Generate new fruit position
:N
  /r w * w % " 16 * + // random position
  n /S ( " n i ? = N ) // retry if on snake
  " f ! // set new fruit position
;

// Turn on pixel
:P
  " 16 / i ! // x coordinate
  " 15 & j ! // y coordinate
  1 j << i w * + !
;

// Delay
:D ( 1000 * ( 1 - " /W ) ) ;

// Handle input
:H
  0 /I // read input port
  1 = ( d @ 2 = /F 3 d ! ) // up
  2 = ( d @ 3 = /F 1 d ! ) // down
  4 = ( d @ 0 = /F 2 d ! ) // left
  8 = ( d @ 1 = /F 0 d ! ) // right
;

// Set up interrupt handler
:Z H ;
0 /X /v Z !

// Start the game
I M
```

